export interface TeamEligibilityData {
  plan: "trial" | "starter" | "pro";
  created_at: string;
}

/**
 * Checks if a team is eligible for sync operations.
 * For self-hosted deployment: all teams are eligible (no restrictions)
 */
export function isTeamEligibleForSync(_team?: TeamEligibilityData): boolean {
  // Self-hosted deployment: all teams have full access
  return true;
}
