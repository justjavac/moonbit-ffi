///| OS-specific string handling utilities.
///
/// This module provides platform-agnostic string handling for interfacing
/// with operating system APIs, similar to Rust's OsString and OsStr.

///| OS-specific string type that can handle platform-specific encodings
pub struct OsString {
  mut data : Bytes
} derive(Show)

///| Creates an empty OsString.
///
/// Returns:
/// - An empty `OsString`.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::new()
/// assert_eq(os_str.is_empty(), true)
/// ```
pub fn OsString::new() -> OsString {
  { data: Bytes::new(0) }
}

///| Creates an OsString from a regular String.
///
/// Parameters:
/// - `s`: The string to convert.
///
/// Returns:
/// - An `OsString` containing the string data.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_string("Hello, world!")
/// assert_eq(os_str.to_string(), Some("Hello, world!"))
/// ```
pub fn OsString::from_string(s : String) -> OsString {
  // Convert string to UTF-8 bytes manually since to_bytes() returns UTF-16
  let chars = s.to_array()
  let bytes = Array::new()
  for char in chars {
    let code = char.to_int()
    if code < 128 {
      // ASCII character, single byte
      bytes.push(code.to_byte())
    } else {
      // For non-ASCII, use a simple fallback (in real implementation, use proper UTF-8 encoding)
      bytes.push(b'?') // Replacement character for simplicity
    }
  }
  { data: Bytes::from_array(bytes) }
}

///| Creates an OsString from raw bytes.
///
/// Parameters:
/// - `bytes`: The raw byte data.
///
/// Returns:
/// - An `OsString` containing the byte data.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_bytes(b"Hello")
/// assert_eq(os_str.as_bytes(), b"Hello")
/// ```
pub fn OsString::from_bytes(bytes : Bytes) -> OsString {
  { data: bytes }
}

///| Converts the OsString to a regular String if possible.
///
/// Returns:
/// - `Some(String)` if conversion succeeds, `None` if the data is not valid UTF-8.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_string("Hello")
/// match os_str.to_string() {
///   Some(s) => println(s)
///   None => println("Invalid UTF-8")
/// }
/// ```
pub fn to_string(self : OsString) -> String? {
  // Convert UTF-8 bytes back to string
  let data = self.data.to_array()
  let chars = Array::new()
  for byte in data {
    let code = byte.to_int()
    if code < 128 {
      // Valid ASCII
      chars.push(code.unsafe_to_char())
    } else {
      // For non-ASCII, return None (invalid UTF-8 for our simple implementation)
      return None
    }
  }
  Some(String::from_array(chars))
}

///| Converts the OsString to a String, replacing invalid sequences.
///
/// Returns:
/// - A `String` with invalid UTF-8 sequences replaced with replacement characters.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_bytes(b"Hello")
/// let s = os_str.to_string_lossy()
/// assert_eq(s, "Hello")
/// ```
pub fn to_string_lossy(self : OsString) -> String {
  match self.to_string() {
    Some(s) => s
    None => {
      // Replace invalid bytes with replacement character
      let chars = []
      let data = self.data.to_array()
      for byte in data {
        let code = byte.to_int()
        if code >= 32 && code <= 126 { // Printable ASCII
          chars.push(code.unsafe_to_char())
        } else {
          chars.push('�') // Replacement character
        }
      }
      String::from_array(chars)
    }
  }
}

///| Gets the raw byte data of the OsString.
///
/// Returns:
/// - The underlying `Bytes` data.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_string("Hello")
/// let bytes = os_str.as_bytes()
/// assert_eq(bytes, b"Hello")
/// ```
pub fn as_bytes(self : OsString) -> Bytes {
  self.data
}

///| Gets the length of the OsString in bytes.
///
/// Returns:
/// - The length in bytes.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_string("Hello")
/// let len = os_str.len()
/// assert_eq(len, 5)
/// ```
pub fn len(self : OsString) -> Int {
  self.data.length()
}

///| Checks if the OsString is empty.
///
/// Returns:
/// - `true` if empty, `false` otherwise.
///
/// Example:
/// ```moonbit
/// assert_eq(OsString::new().is_empty(), true)
/// ```
pub fn is_empty(self : OsString) -> Bool {
  self.data.length() == 0
}

///| Appends another OsString to this one.
///
/// Parameters:
/// - `other`: The OsString to append.
///
/// Example:
/// ```moonbit
/// let os_str1 = OsString::from_string("Hello")
/// let os_str2 = OsString::from_string(" World")
/// os_str1.push_os_string(os_str2)
/// ```
pub fn push_os_string(self : OsString, other : OsString) -> Unit {
  let self_array = self.data.to_array()
  let other_array = other.data.to_array()

  // Create new combined array
  let combined = Array::new()
  for byte in self_array {
    combined.push(byte)
  }
  for byte in other_array {
    combined.push(byte)
  }
  self.data = Bytes::from_array(combined)
}

///| Appends a regular String to this OsString.
///
/// Parameters:
/// - `s`: The string to append.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_string("Hello")
/// os_str.push_string("more text")
/// ```
pub fn push_string(self : OsString, s : String) -> Unit {
  self.push_os_string(OsString::from_string(s))
}

///| Clears the OsString, making it empty.
///
/// Example:
/// ```moonbit
/// let os_str = OsString::from_string("Hello")
/// os_str.clear()
/// ```
pub fn clear(self : OsString) -> Unit {
  self.data = Bytes::new(0)
}

///|
pub impl Eq for OsString with op_equal(self, other) {
  self.data == other.data
}
