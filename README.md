# MoonBit Foreign Function Interface.

A small utility library for converting between C-style null-terminated byte
strings (`Bytes`) and MoonBit `String` values.

## Features

- `from_cstr`: Convert a null-terminated `Bytes` to `String` (stripping the
  terminator)
- `to_cstr`: Convert a `String` to null-terminated `Bytes`

## Installation

Add `justjavac/ffi` to your dependencies:

```shell
moon update
moon add justjavac/ffi
```

## Usage

```moonbit
let data = b"Hello, world!\x00"
let s = @ffi.from_cstr(data)
assert_eq!(s, "Hello, world!")

let cstr = @ffi.to_cstr("Hello, world!")
assert_eq!(cstr, data)
```

## Supported Backends

- Wasm & WasmGC
- JavaScript
- Native
- LLVM

## Development

Build and test:

```shell
moon build
moon test --doc
```

## License

MIT © justjavac
