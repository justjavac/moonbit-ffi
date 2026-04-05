# MoonBit FFI
[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-ffi)
[![linux](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?flag=linux&label=linux)](https://codecov.io/gh/justjavac/moonbit-ffi)
[![macos](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?flag=macos&label=macos)](https://codecov.io/gh/justjavac/moonbit-ffi)
[![windows](https://img.shields.io/codecov/c/github/justjavac/moonbit-ffi/main?flag=windows&label=windows)](https://codecov.io/gh/justjavac/moonbit-ffi)

`justjavac/ffi` is a small MoonBit library for string-oriented FFI boundaries.
It converts MoonBit `String` values to and from:

- C `char*`-style null-terminated UTF-8 byte buffers
- Windows `wchar_t*`-style null-terminated UTF-16LE byte buffers

This README is the repository guide. Package consumers can use
[`README.mbt.md`](./README.mbt.md) for the shorter package-facing version that is
published with the module metadata.

## Why This Repo Exists

MoonBit already gives you low-level access to `Bytes`, but native APIs often want
strings in ABI-specific layouts:

- POSIX-style and many cross-platform libraries use null-terminated UTF-8 bytes
- Win32 APIs commonly use null-terminated UTF-16 wide strings

This package keeps those conversions in one place, with tests for the normal
paths and failure paths.

## Exported API

- `@ffi.from_cstr(Bytes) -> String`
  Converts a null-terminated UTF-8 buffer to a MoonBit string. It aborts when
  the buffer does not end with `\x00`. Invalid UTF-8 sequences are decoded
  lossily with replacement characters.
- `@ffi.to_cstr(String) -> Bytes`
  Encodes a MoonBit string as UTF-8 and appends a trailing `\x00`.
- `@ffi.from_wstr_lossy(Bytes) -> String`
  Decodes a null-terminated UTF-16LE buffer. It aborts when the input does not
  end with `\x00\x00`.
- `@ffi.to_wstr(String) -> Bytes`
  Encodes a MoonBit string as UTF-16LE and appends a trailing wide null.

## Installation

```shell
moon update
moon add justjavac/ffi
```

## Quick Start

```moonbit
let c_name = @ffi.to_cstr("hello.txt")
let display_name = @ffi.from_cstr(c_name)

let wide_title = @ffi.to_wstr("Hello, 世界")
let title = @ffi.from_wstr_lossy(wide_title)

assert_eq(display_name, "hello.txt")
assert_eq(title, "Hello, 世界")
```

## Platform Notes

- `from_cstr` and `to_cstr` are appropriate for UTF-8 `char*` APIs on all
  supported backends.
- `from_wstr_lossy` and `to_wstr` are primarily for Windows APIs, but they are
  deterministic and testable on any backend.
- Missing terminators are treated as programmer errors and abort immediately.

## Repository Layout

- `README.md`: detailed repository overview
- `README.mbt.md`: concise package documentation with tested examples
- `src/cstr.mbt`: UTF-8 C string helpers
- `src/wstr.mbt`: UTF-16 wide string helpers
- `src/ffi_test.mbt`: black-box API and panic-path coverage tests
- `.github/workflows/ci.yml`: multi-platform checks plus coverage upload

## Development

Run the normal validation loop from the repository root:

```shell
moon fmt
moon check --target all --deny-warn
moon test --target all
moon test --target native --enable-coverage
moon coverage analyze -p justjavac/ffi -- -f summary
```

## Coverage Reporting

CI keeps the existing Linux, macOS, and Windows matrix, then uploads a native
coverage report for each platform to Codecov using platform flags:

- `linux`
- `macos`
- `windows`

The badges above update after the branch workflow finishes and Codecov finishes
processing the uploads.

## License

MIT
