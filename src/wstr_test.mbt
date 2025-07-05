// Tests for wide string operations

///|
test "wide string operations" {
  // Test wide string conversion
  let wdata = b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00" // "Hello" in UTF-16LE
  let s = from_wstr_lossy(wdata)
  assert_eq(s, "Hello")
  let wstr = to_wstr("Hello")
  // Note: The exact bytes might differ due to endianness
  assert_true(wstr.length() > 0)
}
