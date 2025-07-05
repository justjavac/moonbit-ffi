///| This module provides functions to convert between C-style null-terminated byte strings and MoonBit's `String` type.
///
/// It includes functions to convert from a byte array to a `String` and from a `String` to a byte array.

///|! Converts a byte array to a `String` and vice versa, handling null-termination.
/// 
/// Parameters:
/// - `b`: A byte array that is expected to be null-terminated.
/// 
/// Returns:
/// - A `String` representation of the byte array, excluding the null terminator.
/// 
/// Example:
/// ```moonbit
/// let s = from_cstr(b"Hello, world!\x00")
/// assert_eq(s, "Hello, world!")
/// ```
pub fn from_cstr(b : Bytes) -> String {
  if b[b.length() - 1] != 0x00 {
    abort("expected null-terminated byte strings")
  }
  let b = b.to_array()
  let _ = b.pop()
  return b.map(fn(c) { c.to_char() }) |> String::from_array
}

///| Converts a `String` to a C-style null-terminated byte array.
///
/// Parameters:
/// - `s`: A `String` that will be converted to a null-terminated byte array.
///
/// Returns:
/// - A `Bytes` object containing the null-terminated byte representation of the string.
///
/// Example:
/// ```moonbit
/// let cstr = to_cstr("Hello, world!")
/// assert_eq(cstr, b"Hello, world!\x00")
/// ```
pub fn to_cstr(s : String) -> Bytes {
  let s = s.to_array()
  s.push('\u{0000}')
  return s.map(fn(c) { c.to_int().to_byte() }) |> Bytes::from_array
}
