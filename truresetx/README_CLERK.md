Clerk integration notes

- Clerk is primarily a web-first authentication provider. For Flutter, typical approaches:
  1) WebView/OAuth redirect: host Clerk sign-in UI in a web flow and capture the session via redirect URI.
  2) Use a backend: your server exchanges Clerk session tokens and issues app-specific sessions.
  3) Clerk REST API: use server-side API keys (NOT from client) to validate sessions.

Starter adapter
- `lib/core/services/clerk_auth_adapter.dart` contains a minimal scaffold implementing `AuthRepository` that throws `UnimplementedError` for key methods.

Next steps to implement Clerk in-app:
- Decide on a flow: embedded web sign-in vs backend-mediated session exchange.
- If using backend-mediated flow, implement server endpoints to handle Clerk session verification and return a short-lived token the app uses.
- For web-based flow, implement a WebView or external browser flow and capture redirect URIs.

Security
- Never embed Clerk secret API keys in the mobile client. Use a backend for any admin or secret operations.
- Follow Clerk docs for recommended mobile integrations.
