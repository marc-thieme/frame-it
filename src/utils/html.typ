#let wants-html() = {
  let html-frames = sys.inputs.at("html-frames", default: "false")
  assert(
    html-frames in ("true", "false"),
    message: html-frames
      + " is not valid for `--input html-frames={true|false}`",
  )
  (
    html-frames == "true" and target() == "html"
  )
}

#let target-choose(html: none, paged: none) = context {
  assert(
    html != none and paged != none,
    message: "Please provide options for both `html` and `paged`.",
  )
  if wants-html() {
    if type(html) == function { html() } else { html }
  } else {
    if type(paged) == function { paged() } else { paged }
  }
}

#let span(style, body, ..attrs) = target-choose(
  paged: body,
  html: html.elem("span", attrs: (style: style, ..attrs.named()), body),
)
#let div(style, body, ..attrs) = target-choose(
  paged: body,
  html: html.elem("div", attrs: (style: style, ..attrs.named()), body),
)

#let css(..args) = {
  assert(
    args.pos().map(type) in ((), (dictionary,)),
    message: "CSS function only accepts named arguments or one dictionary.",
  )
  let css-dict = if args.pos().len() == 1 {
    assert(args.named() == (:))
    args.pos().first()
  } else {
    args.named()
  }

  let parse(val) = if type(val) == color {
    val.to-hex()
  } else if type(val) != str {
    repr(val)
  } else {
    val
  }

  for (key, value) in css-dict {
    value = if type(value) == array {
      value.map(parse).join(" ")
    } else {
      parse(value)
    }
    key + ": " + value + "; "
  }
}
