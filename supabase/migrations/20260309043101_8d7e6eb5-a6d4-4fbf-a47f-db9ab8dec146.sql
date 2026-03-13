CREATE UNIQUE INDEX IF NOT EXISTS calendar_pricing_unique_date_stay_room 
ON calendar_pricing (date, stay_id, COALESCE(room_category_id, '00000000-0000-0000-0000-000000000000'::uuid));