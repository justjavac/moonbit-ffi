fn main {
  let raw = @ffi.to_cstr("hello")
  println(@ffi.from_cstr(raw))
}
