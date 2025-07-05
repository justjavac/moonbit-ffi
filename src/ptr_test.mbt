// Tests for pointer operations

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
