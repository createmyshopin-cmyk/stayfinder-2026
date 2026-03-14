/**
 * STAY — Google Calendar Sync
 * ───────────────────────────
 * Deploy this script as a Google Apps Script Web App:
 *   Deploy → New Deployment → Web App
 *   Execute as: Me
 *   Who has access: Anyone
 *
 * Required Script Properties (Project Settings → Script Properties):
 *   CALENDAR_ID      — Your Google Calendar ID (e.g. abc123@group.calendar.google.com)
 *   SUPABASE_URL     — Your Supabase project URL (e.g. https://xxxx.supabase.co)
 *   SUPABASE_ANON_KEY — Your Supabase anon/public key
 *
 * The admin dashboard calls this webhook via the "Google Cal" button on /admin/calendar.
 * Payload: { stay_id, stay_name, entries: [{ date, price, original_price, is_blocked, available, min_nights }] }
 */

// ── Entry Point ───────────────────────────────────────────────────────────────

function doPost(e) {
  try {
    var payload = JSON.parse(e.postData.contents);
    var stayId = payload.stay_id;
    var stayName = payload.stay_name || "Stay";
    var entries = payload.entries || [];

    syncEntriesToCalendar(stayId, stayName, entries);

    return ContentService
      .createTextOutput(JSON.stringify({ ok: true, synced: entries.length }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService
      .createTextOutput(JSON.stringify({ ok: false, error: err.message }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// Allow simple GET to verify deployment is alive
function doGet() {
  return ContentService
    .createTextOutput(JSON.stringify({ ok: true, service: "STAY Calendar Sync" }))
    .setMimeType(ContentService.MimeType.JSON);
}

// ── Core Sync Logic ───────────────────────────────────────────────────────────

function syncEntriesToCalendar(stayId, stayName, entries) {
  var calendarId = PropertiesService.getScriptProperties().getProperty("CALENDAR_ID");
  var cal = CalendarApp.getCalendarById(calendarId);
  if (!cal) throw new Error("Calendar not found. Check CALENDAR_ID script property.");

  for (var i = 0; i < entries.length; i++) {
    var entry = entries[i];
    var dateStr = entry.date; // "yyyy-MM-dd"
    var dateParts = dateStr.split("-");
    var year = parseInt(dateParts[0]);
    var month = parseInt(dateParts[1]) - 1; // JS months are 0-indexed
    var day = parseInt(dateParts[2]);
    var eventDate = new Date(year, month, day);

    // Build event title and description
    var title, description, color;
    if (entry.is_blocked) {
      title = "\u26D4 BLOCKED: " + stayName;
      description = "Date blocked by admin.";
      color = CalendarApp.EventColor.RED;
    } else {
      var price = entry.price || 0;
      var originalPrice = entry.original_price || 0;
      title = "\uD83C\uDFE1 " + stayName + " \u2014 \u20B9" + price.toLocaleString("en-IN");
      description = "Price: \u20B9" + price;
      if (originalPrice > 0 && originalPrice !== price) {
        description += " (was \u20B9" + originalPrice + ")";
      }
      if (entry.min_nights > 1) {
        description += "\nMin nights: " + entry.min_nights;
      }
      description += "\nAvailable: " + entry.available;
      color = CalendarApp.EventColor.GREEN;
    }

    // Check for existing event with matching private property
    var existing = findExistingEvent(cal, eventDate, stayId, dateStr);

    if (entry.is_blocked || (entry.available !== undefined && entry.available <= 0)) {
      // If date is blocked/unavailable and event exists, delete it and create blocked event
      if (existing) existing.deleteEvent();
      var blocked = cal.createAllDayEvent(title, eventDate);
      blocked.setDescription(description);
      blocked.setColor(color);
      setEventProps(blocked, stayId, dateStr);
    } else if (existing) {
      // Update existing event
      existing.setTitle(title);
      existing.setDescription(description);
      existing.setColor(color);
    } else {
      // Create new event
      var created = cal.createAllDayEvent(title, eventDate);
      created.setDescription(description);
      created.setColor(color);
      setEventProps(created, stayId, dateStr);
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function findExistingEvent(cal, date, stayId, dateStr) {
  var endDate = new Date(date.getTime() + 24 * 60 * 60 * 1000);
  var events = cal.getEvents(date, endDate);
  var key = stayId + "_" + dateStr;
  for (var i = 0; i < events.length; i++) {
    try {
      var props = events[i].getAllTagKeys();
      if (props.indexOf("stay_date_key") !== -1 && events[i].getTag("stay_date_key") === key) {
        return events[i];
      }
    } catch (e) { /* ignore */ }
  }
  return null;
}

function setEventProps(event, stayId, dateStr) {
  event.setTag("stay_date_key", stayId + "_" + dateStr);
  event.setTag("stay_id", stayId);
  event.setTag("date", dateStr);
}

// ── Optional: Time-Driven Auto-Sync ──────────────────────────────────────────
// If you want automatic sync every hour without needing to press the button:
//   1. Go to Triggers → Add Trigger → Choose function: autoSync → Time-driven → Hour timer → Every hour
//   2. Add SUPABASE_URL and SUPABASE_ANON_KEY to Script Properties

function autoSync() {
  var props = PropertiesService.getScriptProperties();
  var supabaseUrl = props.getProperty("SUPABASE_URL");
  var supabaseKey = props.getProperty("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseKey) return;

  // Fetch all stays
  var staysResp = UrlFetchApp.fetch(supabaseUrl + "/rest/v1/stays?select=id,name", {
    headers: {
      "apikey": supabaseKey,
      "Authorization": "Bearer " + supabaseKey,
    },
  });
  var stays = JSON.parse(staysResp.getContentText());

  for (var i = 0; i < stays.length; i++) {
    var stay = stays[i];
    // Fetch pricing for this stay
    var pricingResp = UrlFetchApp.fetch(
      supabaseUrl + "/rest/v1/calendar_pricing?stay_id=eq." + stay.id + "&select=date,price,original_price,is_blocked,available,min_nights",
      {
        headers: {
          "apikey": supabaseKey,
          "Authorization": "Bearer " + supabaseKey,
        },
      }
    );
    var entries = JSON.parse(pricingResp.getContentText());
    syncEntriesToCalendar(stay.id, stay.name, entries);
  }
}
