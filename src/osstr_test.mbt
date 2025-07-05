// Tests for OS string operations

///|
test "os string operations" {
  // Test OS string operations
  let os_str = OsString::from_string("Hello")
  assert_eq(os_str.len(), 5) // Should be 5 bytes for UTF-8 "Hello"
  assert_false(os_str.is_empty())
  match os_str.to_string() {
    Some(s) => assert_eq(s, "Hello")
    None => assert_false(true)
  }
  os_str.push_string(", World!")
  match os_str.to_string() {
    Some(s) => assert_eq(s, "Hello, World!")
    None => assert_false(true)
  }
  let empty_str = OsString::new()
  assert_true(empty_str.is_empty())
}
