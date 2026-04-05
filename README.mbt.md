# justjavac/ffi
[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-ffi)
[![linux](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?flag=linux&label=linux)](https://codecov.io/gh/justjavac/moonbit-ffi)
[![macos](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?flag=macos&label=macos)](https://codecov.io/gh/justjavac/moonbit-ffi)
[![windows](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?flag=windows&label=windows)](https://codecov.io/gh/justjavac/moonbit-ffi)

Helpers for converting MoonBit `String` values to and from null-terminated
UTF-8 and UTF-16LE buffers at FFI boundaries.

## Usage

```moonbit check
///|
test {
  let c_name = @ffi.to_cstr("ffi")
  assert_eq(c_name, b"ffi\x00")
  assert_eq(@ffi.from_cstr(c_name), "ffi")

  let wide_name = @ffi.to_wstr("世界")
  assert_eq(@ffi.from_wstr_lossy(wide_name), "世界")
}
```
