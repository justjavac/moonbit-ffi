///| Raw pointer utilities for FFI operations.
///
/// This module provides utilities for working with raw pointers and memory
/// in FFI contexts, similar to Rust's raw pointer operations.

///| Represents a raw pointer address as an integer
pub struct RawPtr {
  addr : Int
} derive(Eq, Compare, Show)

///| Create a null pointer
pub fn null() -> RawPtr {
  { addr: 0 }
}

///| Creates a raw pointer from an integer address.
///
/// Parameters:
/// - `addr`: The memory address as an integer.
///
/// Returns:
/// - A `RawPtr` representing the address.
///
/// Example:
/// ```moonbit
/// let ptr = from_addr(0x1000)
/// ```
pub fn from_addr(addr : Int) -> RawPtr {
  { addr, }
}

///| Gets the address of a raw pointer as an integer.
///
/// Parameters:
/// - `ptr`: The raw pointer.
///
/// Returns:
/// - The address as an integer.
///
/// Example:
/// ```moonbit
/// let ptr = from_addr(0x1000)
/// let addr = to_addr(ptr)
/// ```
pub fn to_addr(ptr : RawPtr) -> Int {
  ptr.addr
}

///| Checks if a pointer is null.
///
/// Parameters:
/// - `ptr`: The raw pointer to check.
///
/// Returns:
/// - `true` if the pointer is null, `false` otherwise.
///
/// Example:
/// ```moonbit
/// assert_eq!(is_null(null()), true)
/// assert_eq!(is_null(from_addr(0x1000)), false)
/// ```
pub fn is_null(ptr : RawPtr) -> Bool {
  ptr.addr == 0
}

///| Adds an offset to a pointer.
///
/// Parameters:
/// - `ptr`: The base pointer.
/// - `offset`: The offset to add (in bytes).
///
/// Returns:
/// - A new pointer with the offset applied.
///
/// Example:
/// ```moonbit
/// let ptr = from_addr(0x1000)
/// let new_ptr = offset(ptr, 8)
/// ```
pub fn offset(ptr : RawPtr, offset : Int) -> RawPtr {
  { addr: ptr.addr + offset }
}

///| Calculates the distance between two pointers.
///
/// Parameters:
/// - `ptr1`: The first pointer.
/// - `ptr2`: The second pointer.
///
/// Returns:
/// - The distance in bytes.
///
/// Example:
/// ```moonbit
/// let ptr1 = from_addr(0x1000)
/// let ptr2 = from_addr(0x1008)
/// let distance = ptr_distance(ptr1, ptr2)
/// ```
pub fn ptr_distance(ptr1 : RawPtr, ptr2 : RawPtr) -> Int {
  if ptr1.addr > ptr2.addr {
    ptr1.addr - ptr2.addr
  } else {
    ptr2.addr - ptr1.addr
  }
}

///| Aligns a pointer to the specified alignment.
///
/// Parameters:
/// - `ptr`: The pointer to align.
/// - `alignment`: The alignment requirement (must be a power of 2).
///
/// Returns:
/// - The aligned pointer address.
///
/// Example:
/// ```moonbit
/// let ptr = from_addr(0x1001)
/// let aligned = align_ptr(ptr, 8) // Align to 8-byte boundary
/// ```
pub fn align_ptr(ptr : RawPtr, alignment : Int) -> RawPtr {
  let mask = alignment - 1
  let aligned_addr = (ptr.addr + mask) / alignment * alignment
  { addr: aligned_addr }
}

///| Checks if a pointer is aligned to the specified alignment.
///
/// Parameters:
/// - `ptr`: The pointer to check.
/// - `alignment`: The alignment requirement (must be a power of 2).
///
/// Returns:
/// - `true` if the pointer is aligned, `false` otherwise.
///
/// Example:
/// ```moonbit
/// let ptr = from_addr(0x1000)
/// assert_eq!(is_aligned(ptr, 8), true)
/// ```
pub fn is_aligned(ptr : RawPtr, alignment : Int) -> Bool {
  ptr.addr % alignment == 0
}
