# PDF Fix - Quick Reference

## 🔴 CRITICAL FIX: Double Vault Prefix
**File**: `apps/dashboard/src/components/inbox/inbox-details.tsx` (Line ~397)

**BEFORE** ❌:
```typescript
url={`/api/proxy?filePath=vault/${data?.filePath.join("/")}`}
```

**AFTER** ✅:
```typescript
url={`/api/proxy?filePath=${data?.filePath.join("/")}`}
```

**Why**: Prevented double "vault/" prefix (`vault/vault/...`) causing 404 errors

---

## 🔍 Quick Debugging

### 1. Server Console (Terminal)
```bash
Serving file: vault/team-id/inbox-id/filename.pdf
Content-Type: application/pdf, Content-Length: 12345 bytes
First 8 bytes: 25 50 44 46 2d 31 2e 37 0a
Is valid PDF: true ✅
```

### 2. Browser Console (DevTools)
```bash
PdfViewer rendering with URL: /api/proxy?filePath=team-id/inbox-id/filename.pdf
```

### 3. Test Utility
```javascript
// Paste in browser console:
testPDFProxy("team-id/inbox-id/filename.pdf")
```

---

## ✅ What's Fixed

1. ✅ Removed double "vault/" prefix
2. ✅ Added comprehensive logging
3. ✅ Improved error messages
4. ✅ Better MIME type detection
5. ✅ Proper PDF viewer configuration

---

## 🚨 If Still Broken

1. **Restart dev server** (API routes need restart)
2. **Check logs** (server + browser console)
3. **Use test utility** (`test-pdf-proxy.js`)
4. **Verify file exists** (Supabase Storage dashboard)
5. **Check path structure** (should be array: `["team", "inbox", "file.pdf"]`)

---

## 📁 Files Modified

1. `src/components/inbox/inbox-details.tsx` - Fixed path
2. `src/app/api/proxy/route.ts` - Added logging
3. `src/components/pdf-viewer.tsx` - Better error handling
4. `src/components/file-viewer.tsx` - Smarter MIME detection

---

## 📚 Full Documentation

- `COMPLETE_PDF_FIX_SUMMARY.md` - Complete details
- `PDF_DEBUGGING_GUIDE.md` - Step-by-step debugging
- `test-pdf-proxy.js` - Browser test utility

---

## 🎯 Expected Result

Valid PDFs should now:
1. Load without errors
2. Display correctly
3. Show helpful messages if something fails
4. Be easy to debug with comprehensive logs
