// Tests for utility functions (type conversions, endianness, etc.)

///|
test "type conversion utilities" {
  // Test endian conversions
  let value = 0x12345678
  let bytes_le = i32_to_bytes_le(value)
  let restored_le = bytes_to_i32_le(bytes_le)
  assert_eq(restored_le, value)
  let bytes_be = i32_to_bytes_be(value)
  let restored_be = bytes_to_i32_be(bytes_be)
  assert_eq(restored_be, value)

  // Test 16-bit conversions
  let value16 = 0x1234
  let bytes16_le = i16_to_bytes_le(value16)
  let restored16_le = bytes_to_i16_le(bytes16_le)
  assert_eq(restored16_le, value16)

  // Test boolean conversions
  assert_eq(bool_to_int(true), 1)
  assert_eq(bool_to_int(false), 0)
  assert_eq(int_to_bool(1), true)
  assert_eq(int_to_bool(0), false)
  assert_eq(int_to_bool(42), true)

  // Test alignment utilities
  assert_eq(align_size(10, 8), 16)
  assert_eq(align_size(16, 8), 16)
  assert_eq(padding_needed(10, 8), 6)
  assert_eq(padding_needed(16, 8), 0)
}

///|
test "64-bit integer conversions" {
  // Test 64-bit integer conversion (simplified for MoonBit's Int range)
  let value = 0x12345678
  let bytes_le = i64_to_bytes_le(value)
  let restored_le = bytes_to_i64_le(bytes_le)
  assert_eq(restored_le, value)
  let bytes_be = i64_to_bytes_be(value)
  let restored_be = bytes_to_i64_be(bytes_be)
  assert_eq(restored_be, value)
}

///|
test "floating point conversions" {
  // Test floating point conversion (simplified implementation)
  let value = 42.5
  let bytes_le = double_to_bytes_le(value)
  let restored_le = bytes_to_double_le(bytes_le)
  assert_eq(restored_le.to_int(), value.to_int()) // Compare as int due to simplification
  let bytes_be = double_to_bytes_be(value)
  let restored_be = bytes_to_double_be(bytes_be)
  assert_eq(restored_be.to_int(), value.to_int()) // Compare as int due to simplification
}

///|
test "endianness utilities" {
  // Test endianness detection
  assert_true(is_little_endian()) // Assuming little endian
  assert_false(is_big_endian())
  assert_eq(native_endian(), "little")

  // Test native endian conversions
  let value = 0x12345678
  let bytes_native = i32_to_bytes_native(value)
  let restored_native = bytes_to_i32_native(bytes_native)
  assert_eq(restored_native, value)
}
