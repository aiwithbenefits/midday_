"use client";

import { FeedbackForm } from "./feedback-form";

// Trial component disabled for self-hosted deployment
// All teams default to 'pro' plan with no restrictions
export function Trial() {
  return <FeedbackForm />;
}
