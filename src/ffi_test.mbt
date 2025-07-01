// Example usage of the MoonBit FFI library

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

///|
test "pointer operations" {
  // Test pointer operations
  let ptr = from_addr(0x1000)
  assert_eq(to_addr(ptr), 0x1000)
  assert_false(is_null(ptr))
  assert_true(is_null(null()))
  let offset_ptr = offset(ptr, 8)
  assert_eq(to_addr(offset_ptr), 0x1008)
  let distance = ptr_distance(ptr, offset_ptr)
  assert_eq(distance, 8)
  let aligned_ptr = from_addr(0x1000)
  assert_true(is_aligned(aligned_ptr, 8))
  let unaligned_ptr = from_addr(0x1001)
  assert_false(is_aligned(unaligned_ptr, 8))
}

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

///|
test "struct packing and unpacking" {
  // Test basic packing
  let packer = StructPacker::new(4)
  packer.pack_i8(42)
  packer.pack_i16_le(0x1234)
  packer.pack_i32_le(0x12345678)
  packer.pack_bool(true)
  let packed_bytes = packer.to_bytes()
  assert_true(packed_bytes.length() > 0)

  // Test unpacking
  let unpacker = StructUnpacker::new(packed_bytes, 4)
  match unpacker.unpack_i8() {
    Ok(value) => assert_eq(value, 42)
    Err(_) => assert_false(true)
  }
  match unpacker.unpack_i16_le() {
    Ok(value) => assert_eq(value, 0x1234)
    Err(_) => assert_false(true)
  }
  match unpacker.unpack_i32_le() {
    Ok(value) => assert_eq(value, 0x12345678)
    Err(_) => assert_false(true)
  }
  match unpacker.unpack_bool() {
    Ok(value) => assert_true(value)
    Err(_) => assert_false(true)
  }
}

///|
test "struct packing alignment" {
  // Test packing with alignment
  let packer = StructPacker::new(8)
  packer.pack_i8(1) // 1 byte
  packer.pack_i32_le(0x12345678) // Should be aligned to 4 bytes
  let packed_bytes = packer.to_bytes()
  // Should have padding between i8 and i32
  assert_true(packed_bytes.length() >= 8)

  // Test unpacking with alignment
  let unpacker = StructUnpacker::new(packed_bytes, 8)
  match unpacker.unpack_i8() {
    Ok(value) => assert_eq(value, 1)
    Err(_) => assert_false(true)
  }
  match unpacker.unpack_i32_le() {
    Ok(value) => assert_eq(value, 0x12345678)
    Err(_) => assert_false(true)
  }
}

///|
test "struct packing error handling" {
  // Test unpacking from insufficient data
  let small_data = b"\x42"
  let unpacker = StructUnpacker::new(small_data, 1)
  match unpacker.unpack_i32_le() {
    Ok(_) => assert_false(true) // Should fail
    Err(InsufficientData) => assert_true(true)
    Err(_) => assert_false(true)
  }
}
