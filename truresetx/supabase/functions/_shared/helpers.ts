/* eslint-disable */
declare const Deno: any;
// Minimal helpers for Edge Functions
export function json(x: unknown, s = 200) {
  return new Response(JSON.stringify(x), { status: s, headers: { 'content-type': 'application/json' } });
}

// Extract user id from Authorization: Bearer <jwt> without verifying signature.
// This is a best-effort approach; for production verify tokens properly via Supabase or JWKS.
export function getUserIdFromRequest(req: Request) {
  try {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth) return null;
    const parts = auth.split(' ');
    if (parts.length !== 2) return null;
    const jwt = parts[1];
    const payload = jwt.split('.')[1];
    const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
    const obj = JSON.parse(decoded);
    return obj.sub || obj.user_id || obj.sub || null;
  } catch (e) {
    return null;
  }
}
