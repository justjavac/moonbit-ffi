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

///| Error type for C string operations
pub enum CStrError {
  NullTerminatorNotFound
  InteriorNull
}

///|
pub impl Show for CStrError with output(self, logger) {
  match self {
    NullTerminatorNotFound => logger.write_string("NullTerminatorNotFound")
    InteriorNull => logger.write_string("InteriorNull")
  }
}

///| Safely converts a byte array to a `String` with error handling.
/// 
/// Parameters:
/// - `b`: A byte array that should be null-terminated.
/// 
/// Returns:
/// - `Ok(String)` if conversion succeeds, `Err(CStrError)` otherwise.
/// 
/// Example:
/// ```moonbit
/// let result = try_from_cstr(b"Hello, world!\x00")
/// match result {
///   Ok(s) => println(s)
///   Err(e) => println("Error: \{e}")
/// }
/// ```
pub fn try_from_cstr(b : Bytes) -> Result[String, CStrError] {
  if b.length() == 0 {
    return Err(NullTerminatorNotFound)
  }
  if b[b.length() - 1] != 0x00 {
    return Err(NullTerminatorNotFound)
  }

  // Check for interior nulls
  for i = 0; i < b.length() - 1; i = i + 1 {
    if b[i] == 0x00 {
      return Err(InteriorNull)
    }
  }
  let b = b.to_array()
  let _ = b.pop()

  // Convert to string - basic validation for valid characters
  let result = b.map(fn(c) { c.to_char() }) |> String::from_array
  Ok(result)
}

///| Safely converts a `String` to a null-terminated byte array with validation.
///
/// Parameters:
/// - `s`: A `String` to convert. Must not contain null characters.
///
/// Returns:
/// - `Ok(Bytes)` if conversion succeeds, `Err(CStrError)` if string contains null chars.
///
/// Example:
/// ```moonbit
/// let result = try_to_cstr("Hello, world!")
/// match result {
///   Ok(cstr) => println("Converted successfully: \{cstr}")
///   Err(e) => println("Error: \{e}")
/// }
/// ```
pub fn try_to_cstr(s : String) -> Result[Bytes, CStrError] {
  // Check for interior nulls
  for char in s {
    if char == '\u{0000}' {
      return Err(InteriorNull)
    }
  }
  let s = s.to_array()
  s.push('\u{0000}')
  Ok(s.map(fn(c) { c.to_int().to_byte() }) |> Bytes::from_array)
}

///| Returns the length of a C string (excluding null terminator).
///
/// Parameters:
/// - `b`: A null-terminated byte array.
///
/// Returns:
/// - The length of the string excluding the null terminator.
///
/// Example:
/// ```moonbit
/// let len = cstr_len(b"Hello\x00")
/// assert_eq(len, 5)
/// ```
pub fn cstr_len(b : Bytes) -> Int {
  for i = 0; i < b.length(); i = i + 1 {
    if b[i] == 0x00 {
      return i
    }
  }
  b.length()
}

///| Checks if a byte array is a valid null-terminated C string.
///
/// Parameters:
/// - `b`: A byte array to validate.
///
/// Returns:
/// - `true` if the array is null-terminated with no interior nulls, `false` otherwise.
///
/// Example:
/// ```moonbit
/// assert_eq(is_valid_cstr(b"Hello\x00"), true)
/// assert_eq(is_valid_cstr(b"Hello"), false)
/// assert_eq(is_valid_cstr(b"Hel\x00lo\x00"), false)
/// ```
pub fn is_valid_cstr(b : Bytes) -> Bool {
  if b.length() == 0 || b[b.length() - 1] != 0x00 {
    return false
  }

  // Check for interior nulls
  for i = 0; i < b.length() - 1; i = i + 1 {
    if b[i] == 0x00 {
      return false
    }
  }
  true
}

///| Compares two C strings for equality.
///
/// Parameters:
/// - `a`: First null-terminated byte array.
/// - `b`: Second null-terminated byte array.
///
/// Returns:
/// - `true` if the strings are equal (excluding null terminators), `false` otherwise.
///
/// Example:
/// ```moonbit
/// assert_eq(cstr_eq(b"Hello\x00", b"Hello\x00"), true)
/// assert_eq(cstr_eq(b"Hello\x00", b"World\x00"), false)
/// ```
pub fn cstr_eq(a : Bytes, b : Bytes) -> Bool {
  let len_a = cstr_len(a)
  let len_b = cstr_len(b)
  if len_a != len_b {
    return false
  }
  for i = 0; i < len_a; i = i + 1 {
    if a[i] != b[i] {
      return false
    }
  }
  true
}
