# MoonBit FFI

A comprehensive utility library for Foreign Function Interface (FFI) operations
in MoonBit, providing utilities for C-style strings, wide strings, raw pointers,
OS strings, and type conversions.

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

## Features

### C String Operations (`@ffi/cstr`)
- **from_cstr**: Convert a null-terminated `Bytes` to a MoonBit `String`
- **to_cstr**: Convert a MoonBit `String` to null-terminated `Bytes`
- **try_from_cstr**: Safe conversion with error handling
- **try_to_cstr**: Safe conversion with validation
- **cstr_len**: Get C string length
- **is_valid_cstr**: Validate C string format
- **cstr_eq**: Compare C strings for equality

### Wide String Operations (`@ffi/wstr`)
- **from_wstr_lossy**: Convert UTF-16 wide strings to `String`
- **to_wstr**: Convert `String` to UTF-16 wide strings
- **try_from_wstr**: Safe wide string conversion
- **try_to_wstr**: Safe wide string creation
- **wstr_len**: Get wide string length
- **is_valid_wstr**: Validate wide string format
- **wstr_eq**: Compare wide strings for equality
- **wstr_concat**: Concatenate wide strings

### Raw Pointer Utilities (`@ffi/ptr`)
- **RawPtr**: Type alias for raw pointer addresses
- **NULL**: Null pointer constant
- **from_addr/to_addr**: Convert between addresses and pointers
- **is_null**: Check if pointer is null
- **offset**: Add offset to pointer
- **ptr_distance**: Calculate distance between pointers
- **align_ptr**: Align pointer to boundary
- **is_aligned**: Check pointer alignment

### OS String Handling (`@ffi/osstr`)
- **OsString**: Platform-agnostic string type
- **from_string/to_string**: Convert to/from regular strings
- **from_bytes/as_bytes**: Work with raw byte data
- **to_string_lossy**: Convert with replacement chars
- **push_string/push_os_string**: Append operations
- **len/is_empty/clear**: Basic operations

### Type Conversion Utilities (`@ffi/utils`)
- **Endian conversions**: `bytes_to_i16_le/be`, `i16_to_bytes_le/be`, etc.
- **64-bit support**: `bytes_to_i64_le/be`, `i64_to_bytes_le/be`
- **Floating point**: `double_to_bytes_le/be`, `bytes_to_double_le/be`
- **Byte swapping**: `bswap16`, `bswap32`
- **Sign conversions**: `i32_to_u32`, `u32_to_i32`
- **Boolean conversions**: `bool_to_int`, `int_to_bool`
- **Alignment helpers**: `align_size`, `padding_needed`
- **Endianness detection**: `is_little_endian`, `native_endian`

### Struct Packing/Unpacking (`@ffi/pack`)
- **StructPacker**: Pack data into binary format with alignment
- **StructUnpacker**: Unpack binary data with error handling
- **Pack functions**: `pack_i8/i16_le/i32_le`, `pack_bool`, `pack_string`
- **Unpack functions**: `unpack_i8/i16_le/i32_le`, `unpack_bool`, `unpack_string`
- **Alignment support**: Automatic padding and alignment handling
- **Error handling**: `PackError` types for robust unpacking

## Installation

Add `justjavac/ffi` to your dependencies:

```shell
moon update
moon add justjavac/ffi
```

## Usage

### Basic C String Operations
```moonbit
// Convert Bytes → String
let data = b"Hello, world!\x00"
let s = @ffi.from_cstr(data)
// assert_eq(s, "Hello, world!")

// Convert String → Bytes
let cstr = @ffi.to_cstr("Hello, world!")
// assert_eq(cstr, data)

// Safe conversions with error handling
match @ffi.try_from_cstr(data) {
  Ok(s) => println(s)
  Err(e) => println("Error: \{e}")
}
```

### Wide String Operations
```moonbit
// Convert UTF-16 wide string
let wdata = b"\x48\x00\x65\x00\x6c\x00\x6c\x00\x6f\x00\x00\x00"
let s = @ffi.from_wstr_lossy(wdata)
// assert_eq(s, "Hello")

// Create wide string
let wstr = @ffi.to_wstr("Hello")
```

### Raw Pointer Operations
```moonbit
// Create and manipulate pointers
let ptr = @ffi.from_addr(0x1000)
let offset_ptr = @ffi.offset(ptr, 8)
// assert_eq(@ffi.is_aligned(ptr, 8), true)
```

### OS String Handling
```moonbit
// Create OS string
let os_str = @ffi.OsString::from_string("Hello")
os_str.push_string(", world!")
match os_str.to_string() {
  Some(s) => println(s)
  None => println("Invalid string")
}
```

### Type Conversions
```moonbit
// Endian conversions
let bytes = @ffi.i32_to_bytes_le(305419896)  // 0x12345678
let value = @ffi.bytes_to_i32_le(bytes)
// assert_eq(value, 305419896)

// Byte swapping
let swapped = @ffi.bswap32(305419896)  // 0x12345678
// assert_eq(swapped, 2018915346)  // 0x78563412
```

### Struct Packing and Unpacking
```moonbit
// Pack data into binary format
let packer = @ffi.StructPacker::new(4)  // 4-byte alignment
packer.pack_i8(42)
packer.pack_i32_le(0x12345678)
packer.pack_bool(true)
let packed = packer.to_bytes()

// Unpack data with error handling
let unpacker = @ffi.StructUnpacker::new(packed, 4)
match unpacker.unpack_i8() {
  Ok(value) => println("i8: \{value}")
  Err(@ffi.InsufficientData) => println("Not enough data")
  Err(_) => println("Other error")
}
```

## Supported Backends

- Wasm & WasmGC
- JavaScript
- Native
- LLVM

## Development

Build the library and run tests (including docs):

```shell
moon build
moon test --doc
```

## License

This project is licensed under the MIT License.\
© justjavac
