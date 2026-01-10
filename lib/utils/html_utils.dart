/// Utility functions for handling HTML content in strings
class HtmlUtils {
  /// Checks if a string contains HTML and strips HTML tags if it does
  ///
  /// This function detects HTML tags and removes them, also handling common HTML entities
  /// like &amp;, &nbsp;, etc. If the string doesn't contain HTML, it returns the original.
  static String stripHtmlIfPresent(String text) {
    // Check if the string contains HTML tags
    bool containsHtml = RegExp(r'<[^>]*>').hasMatch(text);

    if (containsHtml) {
      // Remove all HTML tags
      return text
          .replaceAll(RegExp(r'<[^>]*>'), '')
          // Replace common HTML entities
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&bull;', '•')
          .replaceAll('&hellip;', '...')
          .replaceAll('&mdash;', '—')
          .replaceAll('&ndash;', '–')
          .replaceAll('&lsquo;', ''')
          .replaceAll('&rsquo;', ''')
          .replaceAll('&ldquo;', '"')
          .replaceAll('&rdquo;', '"')
          // Remove extra whitespace
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }

    // If it's not HTML, return the original text
    return text;
  }

  /// Checks if a string contains HTML tags
  static bool containsHtml(String text) {
    return RegExp(r'<[^>]*>').hasMatch(text);
  }
}
