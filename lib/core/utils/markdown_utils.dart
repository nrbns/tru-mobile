// Simple Markdown helper utilities used by the app.
// Provides a conservative markdown-to-plain-text converter so UI code
// can render summaries without pulling in a full Markdown widget.

String markdownToText(String? markdown) {
  if (markdown == null || markdown.isEmpty) return '';

  var text = markdown;

  // Replace common markdown links: [label](url) -> label
  text = text.replaceAllMapped(RegExp(r"\[(.*?)\]\(.*?\)"), (m) => m[1] ?? '');

  // Remove images syntax ![alt](url) -> alt
  text = text.replaceAllMapped(RegExp(r"!\[(.*?)\]\(.*?\)"), (m) => m[1] ?? '');

  // Remove emphasis markers (*, **, _, __, `)
  text = text.replaceAll(RegExp(r"\*\*|\*|__|_|`"), '');

  // Remove headings (# ## ###) at line starts
  text = text.replaceAll(RegExp(r"^#+\s*", multiLine: true), '');

  // Replace HTML entities for common cases
  text = text.replaceAll('&nbsp;', ' ');
  text = text.replaceAll('&lt;', '<');
  text = text.replaceAll('&gt;', '>');
  text = text.replaceAll('&amp;', '&');

  // Collapse multiple newlines to a single newline
  text = text.replaceAll(RegExp(r"\n{3,}"), '\n\n');

  // Trim whitespace
  return text.trim();
}
