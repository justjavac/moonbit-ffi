///| Windows represents Unicode characters using UTF-16 encoding, in which each
/// character is encoded as a 16-bit value.
///
/// UTF-16 characters are called **wide** characters, to distinguish them from
/// 8-bit ANSI characters.

///| Converts a null-terminated UTF-16 byte array to a `String`.
/// 
/// This function handles UTF-16 encoded wide strings commonly used on Windows.
/// It expects the byte array to be null-terminated (ending with two zero bytes).
/// 
/// Parameters:
/// - `b`: A byte array containing UTF-16 encoded data, expected to be null-terminated.
/// 
/// Returns:
/// - A `String` representation of the UTF-16 data, excluding the null terminator.
/// 
/// Example:
/// ```moonbit
/// let s = from_wstr_lossy(b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00")
/// assert_eq(s, "Hello")
/// ```
pub fn from_wstr_lossy(b : Bytes) -> String {
  if b.length() < 2 || b[b.length() - 2] != 0x00 || b[b.length() - 1] != 0x00 {
    abort("expected null-terminated wide strings")
  }
  let decoder = @encoding.decoder(UTF16)
  return decoder.decode_lossy(b[0:b.length() - 2])
}

///| Converts a `String` to a null-terminated UTF-16 byte array.
///
/// This function converts a MoonBit string to UTF-16 encoding with null termination,
/// commonly used for Windows wide string APIs.
///
/// Parameters:
/// - `s`: A `String` that will be converted to a null-terminated UTF-16 byte array.
///
/// Returns:
/// - A `Bytes` object containing the UTF-16 encoded representation with null termination.
///
/// Example:
/// ```moonbit
/// let wstr = to_wstr("Hello")
/// assert_eq(wstr, b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00")
/// ```
pub fn to_wstr(s : String) -> Bytes {
  return @encoding.encode(UTF16, s + "\u{0000}")
}
