///| Common FFI type conversion utilities.
///
/// This module provides utilities for converting between different numeric
/// types commonly used in FFI, similar to Rust's FFI type conversions.

///| Convert a signed integer to unsigned representation within 32-bit range
pub fn i32_to_u32(value : Int) -> Int {
  // For MoonBit's Int range, just return the value as-is
  // In a real implementation, you'd handle the full 32-bit range
  value
}

///| Convert an unsigned integer to signed representation within 32-bit range  
pub fn u32_to_i32(value : Int) -> Int {
  // For MoonBit's Int range, just return the value as-is
  // In a real implementation, you'd handle the full 32-bit range
  value
}

///| Convert bytes to a 16-bit integer (little endian)
pub fn bytes_to_i16_le(bytes : Bytes) -> Int {
  if bytes.length() < 2 {
    abort("Need at least 2 bytes for i16")
  }
  let low = bytes[0].to_int()
  let high = bytes[1].to_int()
  let result = high * 256 + low
  // Convert to signed
  if result >= 32768 { // 0x8000
    result - 65536 // 0x10000
  } else {
    result
  }
}

///| Convert bytes to a 16-bit integer (big endian)
pub fn bytes_to_i16_be(bytes : Bytes) -> Int {
  if bytes.length() < 2 {
    abort("Need at least 2 bytes for i16")
  }
  let high = bytes[0].to_int()
  let low = bytes[1].to_int()
  let result = high * 256 + low
  // Convert to signed
  if result >= 32768 { // 0x8000
    result - 65536 // 0x10000
  } else {
    result
  }
}

///| Convert bytes to a 32-bit integer (little endian)
pub fn bytes_to_i32_le(bytes : Bytes) -> Int {
  if bytes.length() < 4 {
    abort("Need at least 4 bytes for i32")
  }
  let b0 = bytes[0].to_int()
  let b1 = bytes[1].to_int()
  let b2 = bytes[2].to_int()
  let b3 = bytes[3].to_int()
  let result = b3 * 16777216 + b2 * 65536 + b1 * 256 + b0 // 0x1000000, 0x10000, 0x100
  u32_to_i32(result)
}

///| Convert bytes to a 32-bit integer (big endian)
pub fn bytes_to_i32_be(bytes : Bytes) -> Int {
  if bytes.length() < 4 {
    abort("Need at least 4 bytes for i32")
  }
  let b0 = bytes[0].to_int()
  let b1 = bytes[1].to_int()
  let b2 = bytes[2].to_int()
  let b3 = bytes[3].to_int()
  let result = b0 * 16777216 + b1 * 65536 + b2 * 256 + b3 // 0x1000000, 0x10000, 0x100
  u32_to_i32(result)
}

///| Convert a 16-bit integer to bytes (little endian)
pub fn i16_to_bytes_le(value : Int) -> Bytes {
  let unsigned = if value < 0 { value + 65536 } else { value } // 0x10000
  let low = (unsigned % 256).to_byte()
  let high = (unsigned / 256).to_byte()
  Bytes::from_array([low, high])
}

///| Convert a 16-bit integer to bytes (big endian)
pub fn i16_to_bytes_be(value : Int) -> Bytes {
  let unsigned = if value < 0 { value + 65536 } else { value } // 0x10000
  let low = (unsigned % 256).to_byte()
  let high = (unsigned / 256).to_byte()
  Bytes::from_array([high, low])
}

///| Convert a 32-bit integer to bytes (little endian)
pub fn i32_to_bytes_le(value : Int) -> Bytes {
  let unsigned = i32_to_u32(value)
  let b0 = (unsigned % 256).to_byte()
  let b1 = (unsigned / 256 % 256).to_byte()
  let b2 = (unsigned / 65536 % 256).to_byte()
  let b3 = (unsigned / 16777216).to_byte()
  Bytes::from_array([b0, b1, b2, b3])
}

///| Convert a 32-bit integer to bytes (big endian)
pub fn i32_to_bytes_be(value : Int) -> Bytes {
  let unsigned = i32_to_u32(value)
  let b0 = (unsigned % 256).to_byte()
  let b1 = (unsigned / 256 % 256).to_byte()
  let b2 = (unsigned / 65536 % 256).to_byte()
  let b3 = (unsigned / 16777216).to_byte()
  Bytes::from_array([b3, b2, b1, b0])
}

///| Swap bytes in a 16-bit integer (endian conversion)
pub fn bswap16(value : Int) -> Int {
  let unsigned = if value < 0 { value + 65536 } else { value } // 0x10000
  let low = unsigned % 256
  let high = unsigned / 256
  let swapped = low * 256 + high
  if swapped >= 32768 {
    swapped - 65536
  } else {
    swapped
  } // 0x8000, 0x10000
}

///| Swap bytes in a 32-bit integer (endian conversion)
pub fn bswap32(value : Int) -> Int {
  let unsigned = i32_to_u32(value)
  let b0 = unsigned % 256
  let b1 = unsigned / 256 % 256
  let b2 = unsigned / 65536 % 256
  let b3 = unsigned / 16777216
  let swapped = b0 * 16777216 + b1 * 65536 + b2 * 256 + b3
  u32_to_i32(swapped)
}

///| Convert a boolean to an integer (0 or 1)
pub fn bool_to_int(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///| Convert an integer to a boolean (0 is false, non-zero is true)
pub fn int_to_bool(value : Int) -> Bool {
  value != 0
}

///| Align a size to the next multiple of alignment
pub fn align_size(size : Int, alignment : Int) -> Int {
  let mask = alignment - 1
  (size + mask) / alignment * alignment
}

///| Calculate padding needed to align to the specified alignment
pub fn padding_needed(size : Int, alignment : Int) -> Int {
  let aligned = align_size(size, alignment)
  aligned - size
}

///| Convert bytes to a 64-bit integer (little endian) - simplified for MoonBit Int range
pub fn bytes_to_i64_le(bytes : Bytes) -> Int {
  if bytes.length() < 8 {
    abort("Need at least 8 bytes for i64")
  }
  // For MoonBit's limited Int range, we only use the lower 4 bytes
  bytes_to_i32_le(bytes)
}

///| Convert bytes to a 64-bit integer (big endian) - simplified for MoonBit Int range
pub fn bytes_to_i64_be(bytes : Bytes) -> Int {
  if bytes.length() < 8 {
    abort("Need at least 8 bytes for i64")
  }
  // For MoonBit's limited Int range, we only use the lower 4 bytes
  let offset_bytes = Bytes::from_array([bytes[4], bytes[5], bytes[6], bytes[7]])
  bytes_to_i32_be(offset_bytes)
}

///| Convert a 64-bit integer to bytes (little endian) - simplified for MoonBit Int range
pub fn i64_to_bytes_le(value : Int) -> Bytes {
  let lower = i32_to_bytes_le(value)
  let upper = i32_to_bytes_le(0) // Zero-extend for MoonBit's range
  let arr : Array[Byte] = []
  // Add lower bytes first (little endian)
  let mut i = 0
  while i < 4 {
    arr.push(lower[i])
    i = i + 1
  }
  // Add upper bytes
  i = 0
  while i < 4 {
    arr.push(upper[i])
    i = i + 1
  }
  Bytes::from_array(arr)
}

///| Convert a 64-bit integer to bytes (big endian) - simplified for MoonBit Int range
pub fn i64_to_bytes_be(value : Int) -> Bytes {
  let lower = i32_to_bytes_be(value)
  let upper = i32_to_bytes_be(0) // Zero-extend for MoonBit's range
  let arr : Array[Byte] = []
  // Add upper bytes first (big endian)
  let mut i = 0
  while i < 4 {
    arr.push(upper[i])
    i = i + 1
  }
  // Add lower bytes
  i = 0
  while i < 4 {
    arr.push(lower[i])
    i = i + 1
  }
  Bytes::from_array(arr)
}

///| Convert a Double to bytes (IEEE 754 little endian) - simplified implementation
pub fn double_to_bytes_le(value : Double) -> Bytes {
  // This is a simplified implementation. In real FFI, you'd need proper IEEE 754 handling
  let int_repr = value.to_int()
  i32_to_bytes_le(int_repr)
}

///| Convert a Double to bytes (IEEE 754 big endian) - simplified implementation
pub fn double_to_bytes_be(value : Double) -> Bytes {
  // This is a simplified implementation. In real FFI, you'd need proper IEEE 754 handling
  let int_repr = value.to_int()
  i32_to_bytes_be(int_repr)
}

///| Convert bytes to a Double (IEEE 754 little endian) - simplified implementation
pub fn bytes_to_double_le(bytes : Bytes) -> Double {
  // This is a simplified implementation. In real FFI, you'd need proper IEEE 754 handling
  bytes_to_i32_le(bytes).to_double()
}

///| Convert bytes to a Double (IEEE 754 big endian) - simplified implementation
pub fn bytes_to_double_be(bytes : Bytes) -> Double {
  // This is a simplified implementation. In real FFI, you'd need proper IEEE 754 handling
  bytes_to_i32_be(bytes).to_double()
}

///| Check if the current system is little endian
pub fn is_little_endian() -> Bool {
  // In a real implementation, this would check the system's endianness
  // For now, assume little endian (most common)
  true
}

///| Check if the current system is big endian
pub fn is_big_endian() -> Bool {
  not(is_little_endian())
}

///| Get the native byte order for the current system
pub fn native_endian() -> String {
  if is_little_endian() {
    "little"
  } else {
    "big"
  }
}

///| Convert bytes based on native endianness
pub fn bytes_to_i32_native(bytes : Bytes) -> Int {
  if is_little_endian() {
    bytes_to_i32_le(bytes)
  } else {
    bytes_to_i32_be(bytes)
  }
}

///| Convert integer to bytes based on native endianness
pub fn i32_to_bytes_native(value : Int) -> Bytes {
  if is_little_endian() {
    i32_to_bytes_le(value)
  } else {
    i32_to_bytes_be(value)
  }
}
