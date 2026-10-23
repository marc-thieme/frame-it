#import "utils/encode.typ": (
  encode-title-and-info,
  retrieve-info-from-code,
  code-has-info-attached,
)

#let spawn-frame(
  kind,
  title,
  tags,
  body,
  supplement,
  custom-arg,
  style,
  ..figure-params,
) = {
  figure(
    caption: encode-title-and-info(
      kind,
      title,
      tags,
      body,
      supplement,
      custom-arg,
      style,
    ),
    supplement: supplement,
    kind: kind,
    ..figure-params,
    none,
  )
}

#let frame-style(
  kind,
  style,
) = document => {
  // Don't restrict to correct kind. We already discern between frames and user–figures
  // inspecting the metadata. This way, the user can manipulate the kind if desired.
  show figure.caption: caption => {
    let code = caption.body
    if not code-has-info-attached(code) or retrieve-info-from-code(code).kind != kind {
      caption
    } else {
      let number = if caption.numbering != none {
        context caption.counter.display(caption.numbering)
      }
      let (
        title,
        tags,
        body,
        supplement,
        custom-arg,
        style: bundled-style,
      ) = retrieve-info-from-code(code)
      let actual-style = if bundled-style != auto { bundled-style } else {
        style
      }
      actual-style(title, tags, body, supplement, number, custom-arg)
    }
  }
  import "utils/html.typ": elem-ident, elem-ignore
  show figure
    .where(kind: kind)
    .or(figure.where(kind: kind + "-wrapper")): it => {
    // Necessary because html-figure unfortunately inserts padding we don't want.
    // The style sits inside the div so the div is the first element and gets the label's id.
    // If not html, this will just equate to { it }
    elem-ident("div", class: "frame-it-wrapper", {
      elem-ignore("style", ".frame-it-wrapper > figure { margin-left: 0; margin-right: 0 }")
      it
    })
  }
  document
}

#let frame-factory(kind, supplement, custom-arg) = (
  (..title-and-tags, body, style: auto, arg: custom-arg) => {
    let title = none
    let tags = ()
    if title-and-tags.pos() != () {
      (title, ..tags) = title-and-tags.pos()
    }
    spawn-frame(
      kind,
      title,
      tags,
      body,
      supplement,
      arg,
      style,
      ..title-and-tags.named(),
    )
  }
)
