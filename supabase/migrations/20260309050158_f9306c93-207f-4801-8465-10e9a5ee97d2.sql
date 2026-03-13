
INSERT INTO storage.buckets (id, name, public)
VALUES ('stay-images', 'stay-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Anyone can view stay images"
ON storage.objects FOR SELECT
USING (bucket_id = 'stay-images');

CREATE POLICY "Admins can upload stay images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'stay-images');

CREATE POLICY "Admins can delete stay images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'stay-images');
