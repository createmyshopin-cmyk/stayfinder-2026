# Auto-Save Draft When Add Stay Dialog Closed

When adding a new stay, if the user accidentally closes the dialog (click outside, Escape, Cancel), any entered content is auto-saved as draft.

## Apply the patch

Run:
```bash
npm run patch:draft-autosave
```

## Or apply manually

Edit `src/components/admin/StayForm.tsx`:

1. **Add** after `ogInputRef`:
   ```tsx
   const justSavedRef = useRef(false);
   ```

2. **Add** in `useEffect`, after `if (!open) return;`:
   ```tsx
   justSavedRef.current = false;
   ```

3. **Add** in `saveStay`, before `toast({`:
   ```tsx
   justSavedRef.current = true;
   ```

4. **Add** before `return (` (after `removeReview`):
   ```tsx
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
   ```

5. **Change** `<Dialog open={open} onOpenChange={onOpenChange}>` to `onOpenChange={handleOpenChange}`

6. **Change** Cancel button: `onClick={() => onOpenChange(false)}` → `onClick={() => handleOpenChange(false)}`
