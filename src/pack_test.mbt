// Tests for struct packing and unpacking operations

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
