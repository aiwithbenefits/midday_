# PDF Error Debugging Guide

## Issue: Valid PDFs Still Getting Invalid PDF Structure Error

### Root Causes Found

1. **Double "vault/" Prefix**
   - **Location**: `src/components/inbox/inbox-details.tsx`
   - **Problem**: URL was constructed as `vault/${data?.filePath.join("/")}` in the component, and the proxy was adding "vault/" again if missing, resulting in `vault/vault/...`
   - **Fix**: Remove "vault/" from the component, let the proxy handle it

2. **Insufficient Error Information**
   - **Problem**: Hard to debug what's wrong with PDF loading
   - **Fix**: Added comprehensive logging at both server and client side

### Changes Applied (Complete List)

#### 1. Fixed Double Vault Prefix
**File**: `src/components/inbox/inbox-details.tsx`

```typescript
// BEFORE (caused vault/vault/ path):
url={`/api/proxy?filePath=vault/${data?.filePath.join("/")}`}

// AFTER (proxy adds vault/ once):
url={`/api/proxy?filePath=${data?.filePath.join("/")}`}
```

#### 2. Enhanced Proxy Route Debugging
**File**: `src/app/api/proxy/route.ts`

Added:
- File path logging
- Content-Type and Content-Length logging
- First 8 bytes inspection (hex dump)
- PDF signature validation (%PDF check)
- Warning when file is not a valid PDF

#### 3. Improved PDF Viewer Error Handling
**File**: `src/components/pdf-viewer.tsx`

Added:
- URL logging on component render
- Detailed error logging (message, name, stack, url)
- Proper Document configuration with:
  - httpHeaders for Accept: application/pdf
  - withCredentials: true
  - standardFontDataUrl, cMapUrl, cMapPacked

#### 4. Smarter FileViewer Logic
**File**: `src/components/file-viewer.tsx`

- Removed blanket octet-stream → PDF conversion
- Added extension-based fallback for octet-stream files
- Only uses PDF viewer for confirmed PDFs

### How to Debug

#### 1. Check Server Logs
Look for these console messages:
```
Serving file: vault/path/to/file.pdf
Content-Type: application/pdf, Content-Length: 12345 bytes
First 8 bytes: 25 50 44 46 2d 31 2e 37 0a
Is valid PDF: true
```

If you see:
- `Is valid PDF: false` → File is corrupted or not a PDF
- `Failed to fetch file from storage: 404` → File path is wrong
- `vault/vault/...` in path → Double prefix issue (should be fixed now)

#### 2. Check Browser Console
Look for these messages:
```
PdfViewer rendering with URL: /api/proxy?filePath=...
PDF Load Error Details: {...}
```

#### 3. Use Test Utility
Copy content from `test-pdf-proxy.js` into browser console:
```javascript
testPDFProxy("path/to/your/file.pdf")
```

This will:
- Fetch the file through the proxy
- Show response headers
- Check PDF signature
- Display first bytes of file

### Common Issues and Solutions

#### Issue: "vault/vault/..." in logs
**Solution**: ✅ FIXED - Component no longer adds "vault/" prefix

#### Issue: Content-Type is not "application/pdf"
**Solution**: File might have wrong MIME type in storage. Check Supabase Storage metadata.

#### Issue: First bytes don't show "25 50 44 46" (hex for "%PDF")
**Solution**: File is corrupted or not actually a PDF. Re-upload the file.

#### Issue: 404 Not Found
**Solution**: Check that `data.filePath` array joins correctly. Log the full URL.

#### Issue: 401 Unauthorized
**Solution**: Check authentication. Verify session token or service role key.

#### Issue: CORS errors
**Solution**: ✅ FIXED - Added withCredentials and proper headers to Document component

### Testing Checklist

- [ ] Check server console for "Serving file:" logs
- [ ] Verify "Is valid PDF: true" in logs
- [ ] Check that path doesn't have "vault/vault/"
- [ ] Open browser console and look for "PdfViewer rendering"
- [ ] If error occurs, check "PDF Load Error Details"
- [ ] Use test-pdf-proxy.js to manually verify file
- [ ] Try downloading file directly from Supabase Storage to verify it's valid

### Next Steps If Still Failing

1. **Verify file in Supabase Storage**
   - Go to Supabase dashboard
   - Check Storage > vault
   - Try downloading the file directly
   - Open in a PDF viewer locally

2. **Check filePath structure**
   - Log `data.filePath` before joining
   - Verify it's an array like `["team-id", "inbox-id", "filename.pdf"]`
   - Make sure joining doesn't create double slashes

3. **Test with a fresh PDF**
   - Upload a known-good PDF file
   - Try viewing it in the inbox

4. **Check Supabase Storage settings**
   - Verify bucket is public or authentication is working
   - Check if RLS policies allow reading files

