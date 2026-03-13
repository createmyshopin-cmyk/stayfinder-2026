
-- Allow authenticated users to upload to branding bucket
CREATE POLICY "Authenticated users can upload branding assets"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'branding');

-- Allow public read access to branding assets
CREATE POLICY "Public can view branding assets"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'branding');

-- Allow authenticated users to update their branding assets
CREATE POLICY "Authenticated users can update branding assets"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'branding');

-- Allow authenticated users to delete their branding assets
CREATE POLICY "Authenticated users can delete branding assets"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'branding');
