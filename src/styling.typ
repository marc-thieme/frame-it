/*
 * This file mainly exports functionality needed when writing your own styling function.
 */
/// Deprecated: use the native `divider()` element instead.
/// Kept for backwards compatibility, it is equivalent to `divider()`.
#let divide() = divider()

/// Deprecated: add `show divider: ...` directly in your styling function instead.
/// Kept for backwards compatibility.
#let dividers-as(divider-element) = (
  document => {
    show divider: _ => divider-element
    document
  }
)
