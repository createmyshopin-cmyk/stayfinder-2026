#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const p = path.join(__dirname, "..", "src", "components", "admin", "StayForm.tsx");
let s = fs.readFileSync(p, "utf8");
// Normalize line endings
s = s.replace(/\r\n/g, "\n");

// 1.
if (!s.includes("justSavedRef")) {
  s = s.replace(
    "  const ogInputRef = useRef<HTMLInputElement>(null);\n\n  // Load existing data when editing\n",
    "  const ogInputRef = useRef<HTMLInputElement>(null);\n  const justSavedRef = useRef(false);\n\n  // Load existing data when editing\n"
  );
}

// 2.
s = s.replace(
  /    if \(!open\) return;\n    if \(stay\) \{/,
  "    if (!open) return;\n    justSavedRef.current = false;\n    if (stay) {"
);

// 3.
s = s.replace(
  /    toast\(\{\n      title: isDraft \? "Draft saved"/,
  "    justSavedRef.current = true;\n    toast({\n      title: isDraft ? \"Draft saved\""
);

// 4.
s = s.replace(
  /  const removeReview = \(i: number\) => setReviews\(prev => prev\.filter\(\(_, idx\) => idx !== i\)\);\n\n  return \(\n    <Dialog open=\{open\} onOpenChange=\{onOpenChange\}>/,
  `  const removeReview = (i: number) => setReviews(prev => prev.filter((_, idx) => idx !== i));

  const hasUnsavedContent = () =>
    !!(form.name?.trim() || form.location?.trim() || form.description?.trim() ||
    photos.length > 0 || reels.length > 0 || nearby.length > 0 ||
    reviews.some(r => !r.id) || roomCategories.length > 0 ||
    seo.seo_title || seo.seo_description || seo.og_image_url);

  const handleOpenChange = (nextOpen: boolean) => {
    if (!nextOpen && !stay && hasUnsavedContent() && !justSavedRef.current && !loading && !savingDraft) {
      saveStay("draft");
      return;
    }
    onOpenChange(nextOpen);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>`
);

// 5. Cancel button in footer
s = s.replace(
  /onClick=\{\(\) => onOpenChange\(false\)\} className="flex-1">/,
  "onClick={() => handleOpenChange(false)} className=\"flex-1\">"
);

fs.writeFileSync(p, s);
console.log("Draft autosave patches applied.");
