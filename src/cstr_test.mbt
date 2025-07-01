// Tests for C string operations

///|
test "basic cstr operations" {
  // Test C string conversion
  let data = b"Hello, MoonBit!\x00"
  let s = from_cstr(data)
  assert_eq(s, "Hello, MoonBit!")
  let cstr = to_cstr("Hello, MoonBit!")
  assert_eq(cstr, data)
}

///|
test "safe cstr operations" {
  // Test safe C string conversion
  let data = b"Safe conversion\x00"
  match try_from_cstr(data) {
    Ok(s) => assert_eq(s, "Safe conversion")
    Err(_) => assert_false(true)
  }
  match try_to_cstr("Safe conversion") {
    Ok(cstr) => assert_eq(cstr, data)
    Err(_) => assert_false(true)
  }

  // Test error cases
  match try_from_cstr(b"No null terminator") {
    Ok(_) => assert_false(true)
    Err(NullTerminatorNotFound) => assert_true(true)
    Err(_) => assert_false(true)
  }
}
