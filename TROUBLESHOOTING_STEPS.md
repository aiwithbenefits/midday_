# PDF Loading Issues - Troubleshooting Steps

Based on the error still occurring, here are the immediate troubleshooting steps:

## 1. Check Server Console Output

When you click on a PDF in the inbox, you should see these logs in your terminal where `npm run dev` is running:

```
Serving file: vault/...
Content-Type: application/pdf, Content-Length: ... bytes
First 8 bytes: 25 50 44 46 ...
Is valid PDF: true/false
```

**What to look for:**
- Is the path correct? (should be `vault/team-id/inbox-id/filename.pdf`)
- Is `Is valid PDF: false`? This means the file isn't actually a PDF
- Any 404 or auth errors?

## 2. Check Browser Console

Open DevTools Console and look for:
```
PdfViewer rendering with URL: /api/proxy?filePath=...
PDF Load Error Details: {...}
```

## 3. Check Network Tab

1. Open DevTools > Network tab
2. Click on a PDF in inbox
3. Look for the `/api/proxy?filePath=...` request
4. Check:
   - Status code (should be 200)
   - Response Headers > Content-Type (should be `application/pdf`)
   - Response size (should match file size)
   - Preview tab - can you see the PDF?

## 4. Verify File in Supabase

1. Go to your Supabase Dashboard
2. Navigate to Storage > vault
3. Find the file
4. Try downloading it directly
5. Open it locally to verify it's a valid PDF

## 5. Common Issues

### Issue: "Is valid PDF: false" in logs
**Cause**: File is corrupted or not actually a PDF
**Solution**: Re-upload the file to Supabase Storage

### Issue: 404 Not Found
**Cause**: File path is wrong
**Solution**: Check that `data.filePath` in inbox-details is correct

### Issue: Path shows "vault/vault/..."
**Cause**: Double prefix (should be fixed now)
**Solution**: Already fixed in inbox-details.tsx

### Issue: Content-Type is not "application/pdf"
**Cause**: File has wrong MIME type in storage
**Solution**: Update file metadata in Supabase Storage

## 6. Manual Test

Run this in browser console while on the inbox page:

```javascript
// Replace with actual file path from your inbox
const testPath = "team-id/inbox-id/filename.pdf";

fetch(`/api/proxy?filePath=${testPath}`)
  .then(r => {
    console.log('Status:', r.status);
    console.log('Headers:', Object.fromEntries(r.headers.entries()));
    return r.arrayBuffer();
  })
  .then(buffer => {
    const bytes = new Uint8Array(buffer);
    console.log('Size:', bytes.length);
    console.log('First 4 bytes:', 
      String.fromCharCode(...bytes.slice(0, 4)));
    console.log('Is PDF:', 
      bytes[0] === 0x25 && bytes[1] === 0x50 && 
      bytes[2] === 0x44 && bytes[3] === 0x46);
  });
```

## 7. What We Fixed

1. ✅ Removed double "vault/" prefix
2. ✅ Added comprehensive logging
3. ✅ Improved error messages
4. ✅ Better MIME type handling
5. ✅ Proper PDF viewer configuration

## 8. Next Steps

If the error persists:

1. **Capture the logs** - Share what you see in server console and browser console
2. **Check Network tab** - What does the actual response look like?
3. **Verify the file** - Can you download it directly from Supabase?
4. **Try test utility** - Run the JavaScript test above

The most likely issues are:
- File is corrupted or not actually a PDF
- File path is still malformed somehow
- Supabase Storage authentication issue
- Content-Type mismatch

Please check the logs and let me know what you see!
