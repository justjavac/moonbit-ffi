///| Struct packing and unpacking utilities for FFI.
///
/// This module provides utilities for packing MoonBit data structures
/// into binary formats commonly used in FFI operations, and unpacking
/// them back to MoonBit types.

///| Error types for struct packing operations
pub enum PackError {
  InsufficientData
  InvalidFormat
  SizeMismatch
}

///| A utility for packing data into bytes with specific alignment
pub struct StructPacker {
  bytes : Array[Byte]
  mut position : Int
  alignment : Int
}

///| Create a new struct packer with specified alignment
pub fn StructPacker::new(alignment : Int) -> StructPacker {
  { bytes: [], position: 0, alignment }
}

///| Create a struct packer from existing bytes
pub fn StructPacker::from_bytes(data : Bytes, alignment : Int) -> StructPacker {
  let arr : Array[Byte] = []
  let mut i = 0
  while i < data.length() {
    arr.push(data[i])
    i = i + 1
  }
  { bytes: arr, position: 0, alignment }
}

///| Pack an 8-bit integer
pub fn StructPacker::pack_i8(self : StructPacker, value : Int) -> Unit {
  self.bytes.push(value.to_byte())
  self.position = self.position + 1
}

///| Pack a 16-bit integer (little endian)
pub fn StructPacker::pack_i16_le(self : StructPacker, value : Int) -> Unit {
  self.align_to(2)
  let bytes = i16_to_bytes_le(value)
  let mut i = 0
  while i < bytes.length() {
    self.bytes.push(bytes[i])
    i = i + 1
  }
  self.position = self.position + 2
}

///| Pack a 16-bit integer (big endian)
pub fn StructPacker::pack_i16_be(self : StructPacker, value : Int) -> Unit {
  self.align_to(2)
  let bytes = i16_to_bytes_be(value)
  let mut i = 0
  while i < bytes.length() {
    self.bytes.push(bytes[i])
    i = i + 1
  }
  self.position = self.position + 2
}

///| Pack a 32-bit integer (little endian)
pub fn StructPacker::pack_i32_le(self : StructPacker, value : Int) -> Unit {
  self.align_to(4)
  let bytes = i32_to_bytes_le(value)
  let mut i = 0
  while i < bytes.length() {
    self.bytes.push(bytes[i])
    i = i + 1
  }
  self.position = self.position + 4
}

///| Pack a 32-bit integer (big endian)
pub fn StructPacker::pack_i32_be(self : StructPacker, value : Int) -> Unit {
  self.align_to(4)
  let bytes = i32_to_bytes_be(value)
  let mut i = 0
  while i < bytes.length() {
    self.bytes.push(bytes[i])
    i = i + 1
  }
  self.position = self.position + 4
}

///| Pack a boolean as a byte
pub fn StructPacker::pack_bool(self : StructPacker, value : Bool) -> Unit {
  self.pack_i8(bool_to_int(value))
}

///| Pack raw bytes with optional alignment
pub fn StructPacker::pack_bytes(
  self : StructPacker,
  data : Bytes,
  align : Int
) -> Unit {
  if align > 1 {
    self.align_to(align)
  }
  let mut i = 0
  while i < data.length() {
    self.bytes.push(data[i])
    i = i + 1
  }
  self.position = self.position + data.length()
}

///| Pack a string as UTF-8 bytes with length prefix
pub fn StructPacker::pack_string(self : StructPacker, value : String) -> Unit {
  let bytes = value.to_bytes()
  self.pack_i32_le(bytes.length()) // Length prefix
  self.pack_bytes(bytes, 1)
}

///| Align the current position to the specified alignment
pub fn StructPacker::align_to(self : StructPacker, align : Int) -> Unit {
  if align <= 1 {
    return
  }
  let padding = padding_needed(self.position, align)
  let mut i = 0
  while i < padding {
    self.bytes.push(b'\x00')
    i = i + 1
  }
  self.position = self.position + padding
}

///| Get the packed bytes
pub fn StructPacker::to_bytes(self : StructPacker) -> Bytes {
  Bytes::from_array(self.bytes)
}

///| Get the current position in the packer
pub fn StructPacker::position(self : StructPacker) -> Int {
  self.position
}

///| A utility for unpacking data from bytes
pub struct StructUnpacker {
  bytes : Bytes
  mut position : Int
  alignment : Int
}

///| Create a new struct unpacker
pub fn StructUnpacker::new(data : Bytes, alignment : Int) -> StructUnpacker {
  { bytes: data, position: 0, alignment }
}

///| Unpack an 8-bit integer
pub fn StructUnpacker::unpack_i8(
  self : StructUnpacker
) -> Result[Int, PackError] {
  if self.position >= self.bytes.length() {
    return Err(InsufficientData)
  }
  let value = self.bytes[self.position].to_int()
  self.position = self.position + 1
  Ok(value)
}

///| Unpack a 16-bit integer (little endian)
pub fn StructUnpacker::unpack_i16_le(
  self : StructUnpacker
) -> Result[Int, PackError] {
  match self.align_to(2) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if self.position + 2 > self.bytes.length() {
    return Err(InsufficientData)
  }
  let slice_bytes = Bytes::from_array([
    self.bytes[self.position],
    self.bytes[self.position + 1],
  ])
  let value = bytes_to_i16_le(slice_bytes)
  self.position = self.position + 2
  Ok(value)
}

///| Unpack a 16-bit integer (big endian)
pub fn StructUnpacker::unpack_i16_be(
  self : StructUnpacker
) -> Result[Int, PackError] {
  match self.align_to(2) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if self.position + 2 > self.bytes.length() {
    return Err(InsufficientData)
  }
  let slice_bytes = Bytes::from_array([
    self.bytes[self.position],
    self.bytes[self.position + 1],
  ])
  let value = bytes_to_i16_be(slice_bytes)
  self.position = self.position + 2
  Ok(value)
}

///| Unpack a 32-bit integer (little endian)
pub fn StructUnpacker::unpack_i32_le(
  self : StructUnpacker
) -> Result[Int, PackError] {
  match self.align_to(4) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if self.position + 4 > self.bytes.length() {
    return Err(InsufficientData)
  }
  let slice_bytes = Bytes::from_array([
    self.bytes[self.position],
    self.bytes[self.position + 1],
    self.bytes[self.position + 2],
    self.bytes[self.position + 3],
  ])
  let value = bytes_to_i32_le(slice_bytes)
  self.position = self.position + 4
  Ok(value)
}

///| Unpack a 32-bit integer (big endian)
pub fn StructUnpacker::unpack_i32_be(
  self : StructUnpacker
) -> Result[Int, PackError] {
  match self.align_to(4) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if self.position + 4 > self.bytes.length() {
    return Err(InsufficientData)
  }
  let slice_bytes = Bytes::from_array([
    self.bytes[self.position],
    self.bytes[self.position + 1],
    self.bytes[self.position + 2],
    self.bytes[self.position + 3],
  ])
  let value = bytes_to_i32_be(slice_bytes)
  self.position = self.position + 4
  Ok(value)
}

///| Unpack a boolean
pub fn StructUnpacker::unpack_bool(
  self : StructUnpacker
) -> Result[Bool, PackError] {
  match self.unpack_i8() {
    Ok(value) => Ok(int_to_bool(value))
    Err(e) => Err(e)
  }
}

///| Unpack raw bytes of specified length
pub fn StructUnpacker::unpack_bytes(
  self : StructUnpacker,
  length : Int,
  align : Int
) -> Result[Bytes, PackError] {
  if align > 1 {
    match self.align_to(align) {
      Ok(_) => ()
      Err(e) => return Err(e)
    }
  }
  if self.position + length > self.bytes.length() {
    return Err(InsufficientData)
  }
  let arr : Array[Byte] = []
  let mut i = 0
  while i < length {
    arr.push(self.bytes[self.position + i])
    i = i + 1
  }
  self.position = self.position + length
  Ok(Bytes::from_array(arr))
}

///| Unpack a string with length prefix
pub fn StructUnpacker::unpack_string(
  self : StructUnpacker
) -> Result[String, PackError] {
  let length = match self.unpack_i32_le() {
    Ok(len) => len
    Err(e) => return Err(e)
  }
  let bytes = match self.unpack_bytes(length, 1) {
    Ok(b) => b
    Err(e) => return Err(e)
  }
  // Simple conversion from UTF-8 bytes to string
  // In practice, you'd want more robust UTF-8 validation
  let chars : Array[Char] = []
  let mut i = 0
  while i < bytes.length() {
    let byte_val = bytes[i].to_int()
    if byte_val < 128 { // ASCII range
      chars.push(byte_val.unsafe_to_char())
    } else {
      chars.push('?') // Replace non-ASCII with placeholder
    }
    i = i + 1
  }
  Ok(String::from_array(chars))
}

///| Align the current position to the specified alignment
pub fn StructUnpacker::align_to(
  self : StructUnpacker,
  align : Int
) -> Result[Unit, PackError] {
  if align <= 1 {
    return Ok(())
  }
  let padding = padding_needed(self.position, align)
  if self.position + padding > self.bytes.length() {
    return Err(InsufficientData)
  }
  self.position = self.position + padding
  Ok(())
}

///| Get the current position in the unpacker
pub fn StructUnpacker::position(self : StructUnpacker) -> Int {
  self.position
}

///| Check if there's more data to unpack
pub fn StructUnpacker::has_more(self : StructUnpacker) -> Bool {
  self.position < self.bytes.length()
}

///| Get remaining bytes count
pub fn StructUnpacker::remaining(self : StructUnpacker) -> Int {
  self.bytes.length() - self.position
}
