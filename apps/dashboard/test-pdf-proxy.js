// Test utility to verify PDF files from the proxy
// Run this in browser console on the inbox page

async function testPDFProxy(filePath) {
  console.log('Testing PDF proxy with path:', filePath);
  
  try {
    const response = await fetch(`/api/proxy?filePath=${encodeURIComponent(filePath)}`);
    console.log('Response status:', response.status);
    console.log('Response headers:', Object.fromEntries(response.headers.entries()));
    
    if (!response.ok) {
      console.error('Failed to fetch:', response.statusText);
      const text = await response.text();
      console.error('Error body:', text);
      return;
    }
    
    const arrayBuffer = await response.arrayBuffer();
    const bytes = new Uint8Array(arrayBuffer);
    
    console.log('Response size:', bytes.length, 'bytes');
    console.log('First 8 bytes (hex):', Array.from(bytes.slice(0, 8)).map(b => b.toString(16).padStart(2, '0')).join(' '));
    console.log('First 8 bytes (ASCII):', String.fromCharCode(...bytes.slice(0, 8)));
    
    // Check PDF signature (%PDF)
    const isPDF = bytes[0] === 0x25 && bytes[1] === 0x50 && bytes[2] === 0x44 && bytes[3] === 0x46;
    console.log('Has PDF signature:', isPDF ? '✅ YES' : '❌ NO');
    
    if (!isPDF) {
      console.warn('⚠️  This file does not appear to be a valid PDF!');
      console.log('First 100 bytes:', String.fromCharCode(...bytes.slice(0, 100)));
    } else {
      console.log('✅ Valid PDF file');
      
      // Try to find PDF version
      const pdfHeader = String.fromCharCode(...bytes.slice(0, 20));
      const versionMatch = pdfHeader.match(/%PDF-(\d+\.\d+)/);
      if (versionMatch) {
        console.log('PDF Version:', versionMatch[1]);
      }
    }
    
  } catch (error) {
    console.error('Error testing proxy:', error);
  }
}

// Usage: 
// testPDFProxy('vault/your-file-path-here.pdf');
console.log('PDF Proxy Test utility loaded. Use: testPDFProxy("vault/path/to/file.pdf")');
