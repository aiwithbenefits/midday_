import { getSession } from "@midday/supabase/cached-queries";
import { type NextRequest, NextResponse } from "next/server";

export async function GET(req: NextRequest) {
  console.log('🔵 PROXY ROUTE CALLED');
  const requestUrl = new URL(req.url);
  const filePath = requestUrl.searchParams.get("filePath");
  console.log('🔵 Requested filePath:', filePath);

  const {
    data: { session },
  } = await getSession();

  if (!filePath) {
    console.error('❌ Missing filePath parameter');
    return new NextResponse("Missing filePath parameter", { status: 400 });
  }

  // Self-hosted mode: Use service role key if no session
  const authToken = session?.access_token || process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!authToken) {
    return new NextResponse("Unauthorized", { status: 401 });
  }

  // Ensure filePath starts with 'vault/'
  const finalFilePath = filePath.startsWith("vault/")
    ? filePath
    : `vault/${filePath}`;

  // Fetch the object from Supabase Storage
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/${finalFilePath}`,
    {
      headers: {
        authorization: `Bearer ${authToken}`,
      },
    },
  );

  // Check if the fetch was successful
  if (!response.ok) {
    console.error(`Failed to fetch file from storage: ${response.status} ${response.statusText}`);
    console.error(`File path: ${finalFilePath}`);
    return new NextResponse(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers,
    });
  }

  // Log content type and size for debugging
  const contentType = response.headers.get('content-type');
  const contentLength = response.headers.get('content-length');
  console.log(`Serving file: ${finalFilePath}`);
  console.log(`Content-Type: ${contentType}, Content-Length: ${contentLength} bytes`);

  // Clone the response to peek at the content without consuming it
  const clonedResponse = response.clone();
  const buffer = await clonedResponse.arrayBuffer();
  const firstBytes = new Uint8Array(buffer.slice(0, 8));
  console.log(`First 8 bytes: ${Array.from(firstBytes).map(b => b.toString(16).padStart(2, '0')).join(' ')}`);
  
  // Check if it's actually a PDF (should start with %PDF)
  const isPDF = firstBytes[0] === 0x25 && firstBytes[1] === 0x50 && firstBytes[2] === 0x44 && firstBytes[3] === 0x46;
  console.log(`Is valid PDF: ${isPDF}`);
  
  if (!isPDF) {
    console.warn(`⚠️  File does not have PDF signature! File may be corrupted or is not a PDF.`);
  }

  return new NextResponse(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers,
  });
}
