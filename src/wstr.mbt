///| Windows represents Unicode characters using UTF-16 encoding, in which each
/// character is encoded as a 16-bit value.
///
/// UTF-16 characters are called **wide** characters, to distinguish them from
/// 8-bit ANSI characters.

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
/// let wstr = to_wstr("Hello")
/// assert_eq(wstr, b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00")
/// ```
pub fn to_wstr(s : String) -> Bytes {
  return @encoding.encode(UTF16, s + "\u{0000}")
}

///| Safely converts a wide string byte array to a `String` with error handling.
/// 
/// Parameters:
/// - `b`: A byte array representing UTF-16 encoded wide string.
/// 
/// Returns:
/// - `Ok(String)` if conversion succeeds, `Err(String)` with error message otherwise.
/// 
/// Example:
/// ```moonbit
/// let result = try_from_wstr(b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00")
/// match result {
///   Ok(s) => println(s)
///   Err(e) => println("Error: \{e}")
/// }
/// ```
pub fn try_from_wstr(b : Bytes) -> Result[String, String] {
  if b.length() < 2 {
    return Err("Buffer too small for wide string")
  }
  if b.length() % 2 != 0 {
    return Err("Wide string buffer length must be even")
  }
  if b[b.length() - 2] != 0x00 || b[b.length() - 1] != 0x00 {
    return Err("Expected null-terminated wide string")
  }
  let decoder = @encoding.decoder(UTF16)
  Ok(decoder.decode_lossy(b[0:b.length() - 2]))
}

///| Safely converts a `String` to a wide string byte array with validation.
///
/// Parameters:
/// - `s`: A `String` to convert.
///
/// Returns:
/// - `Ok(Bytes)` if conversion succeeds, `Err(String)` with error message otherwise.
///
/// Example:
/// ```moonbit
/// let result = try_to_wstr("Hello")
/// match result {
///   Ok(wstr) => println("Converted successfully: \{wstr}")
///   Err(e) => println("Error: \{e}")
/// }
/// ```
pub fn try_to_wstr(s : String) -> Result[Bytes, String] {
  // Check for null characters which would interfere with null termination
  for char in s {
    if char == '\u{0000}' {
      return Err("String contains null character")
    }
  }
  Ok(@encoding.encode(UTF16, s + "\u{0000}"))
}

///| Returns the length of a wide string in characters (excluding null terminator).
///
/// Parameters:
/// - `b`: A null-terminated wide string byte array.
///
/// Returns:
/// - The length of the string in UTF-16 code units.
///
/// Example:
/// ```moonbit
/// let len = wstr_len(b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00")
/// assert_eq(len, 5)
/// ```
pub fn wstr_len(b : Bytes) -> Int {
  if b.length() < 2 {
    return 0
  }
  let mut len = 0
  let mut i = 0
  while i < b.length() - 1 {
    if b[i] == 0x00 && b[i + 1] == 0x00 {
      return len
    }
    len = len + 1
    i = i + 2
  }
  len
}

///| Checks if a byte array is a valid null-terminated wide string.
///
/// Parameters:
/// - `b`: A byte array to validate.
///
/// Returns:
/// - `true` if the array is a valid UTF-16 null-terminated string, `false` otherwise.
///
/// Example:
/// ```moonbit
/// assert_eq(is_valid_wstr(b"\x48\x00\x65\x00\x00\x00"), true)
/// assert_eq(is_valid_wstr(b"\x48\x00\x65"), false)
/// ```
pub fn is_valid_wstr(b : Bytes) -> Bool {
  if b.length() < 2 || b.length() % 2 != 0 {
    return false
  }
  if b[b.length() - 2] != 0x00 || b[b.length() - 1] != 0x00 {
    return false
  }

  // Check for interior null terminators
  let mut i = 0
  while i < b.length() - 2 {
    if b[i] == 0x00 && b[i + 1] == 0x00 {
      return false
    }
    i = i + 2
  }
  true
}

///| Compares two wide strings for equality.
///
/// Parameters:
/// - `a`: First null-terminated wide string byte array.
/// - `b`: Second null-terminated wide string byte array.
///
/// Returns:
/// - `true` if the strings are equal (excluding null terminators), `false` otherwise.
///
/// Example:
/// ```moonbit
/// let str1 = b"\x48\x00\x65\x00\x00\x00"  // "He"
/// let str2 = b"\x48\x00\x65\x00\x00\x00"  // "He"
/// assert_eq(wstr_eq(str1, str2), true)
/// ```
pub fn wstr_eq(a : Bytes, b : Bytes) -> Bool {
  let len_a = wstr_len(a)
  let len_b = wstr_len(b)
  if len_a != len_b {
    return false
  }
  let mut i = 0
  while i < len_a * 2 {
    if a[i] != b[i] {
      return false
    }
    i = i + 1
  }
  true
}

///| Concatenates two wide strings.
///
/// Parameters:
/// - `a`: First null-terminated wide string.
/// - `b`: Second null-terminated wide string.
///
/// Returns:
/// - A new null-terminated wide string containing the concatenation.
///
/// Example:
/// ```moonbit
/// let hello = b"\x48\x00\x65\x00\x00\x00"  // "He"
/// let world = b"\x6c\x00\x6c\x00\x6f\x00\x00\x00"  // "llo"
/// let result = wstr_concat(hello, world)
/// assert_eq(result, b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00")
/// assert_eq(result.length(), 12) // 6 characters + 2 null terminators
/// ```
pub fn wstr_concat(a : Bytes, b : Bytes) -> Bytes {
  let a_len = wstr_len(a) * 2 // Convert to byte length
  let b_len = wstr_len(b) * 2 // Convert to byte length
  let result = Array::new()

  // Copy first string (without null terminator)
  for i = 0; i < a_len; i = i + 1 {
    result.push(a[i])
  }

  // Copy second string (without null terminator)
  for i = 0; i < b_len; i = i + 1 {
    result.push(b[i])
  }

  // Add null terminator
  result.push(b'\x00')
  result.push(b'\x00')
  Bytes::from_array(result)
}
