# Quick Diagnostic Steps

## 1. Restart Dev Server
The API route changes require a restart:
```bash
# Stop the current server (Ctrl+C)
cd /Users/jacob/Downloads/midday_/apps/dashboard
npm run dev
```

## 2. Check Server Console
After restart, when you click a PDF, you should see:
```
🔵 PROXY ROUTE CALLED
🔵 Requested filePath: bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/inbox/bank.pdf
```

**If you DON'T see these logs**, the proxy route isn't being called!

## 3. Check Browser Network Tab
1. Open DevTools > Network tab
2. Click on a PDF in the inbox
3. Look for `/api/proxy?filePath=...`

**What to check:**
- Is the request there?
- What's the status code?
- What does the response look like?

## 4. Test the Proxy Directly
Open this URL in a new browser tab (replace with your actual file path):
```
http://localhost:3001/api/proxy?filePath=bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/inbox/bank.pdf
```

**Expected result:** The PDF should download or display
**If 404:** The route isn't registered correctly
**If error:** Check the server console for logs

## 5. Check if react-pdf is using the proxy
The URL being passed is: `/api/proxy?filePath=...`
This is a relative URL, which should work, but react-pdf might be handling it differently.

## Most Likely Issues

### Issue 1: Turbopack not picking up API route changes
**Solution:** Restart the dev server

### Issue 2: react-pdf bypassing the proxy
**Solution:** We'll need to adjust how we pass the URL to react-pdf

### Issue 3: CORS or fetch configuration
**Solution:** May need to adjust the proxy response headers

## Next Steps

1. Restart the server
2. Try clicking a PDF
3. Share what you see in:
   - Server console (terminal)
   - Browser Network tab
   - Browser console

This will tell us exactly what's happening!
