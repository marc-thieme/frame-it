#import "../utils/html.typ": css, target-choose, wants-html
#import "../utils/text-queries.typ": text-is-left-to-right

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let line-width = 3.5pt

#let header-suppl(title, tags, body, supplement, number) = context {
  if title == none {
    none
  } else {
    let title-str = if title != [] { [~~#title~] } else { [] }

    let tag-str = if tags != () {
      [~(#tags.join(", "))~]
    } else {
      []
    }
    let supplement-str = {
      let header-color = text.fill.mix((text.fill.negate(), 20%))
      text(header-color)[#supplement #number]
    }
    let head-body-separator = if body == [] [] else [:]
    if text-is-left-to-right() or wants-html() {
      [~#supplement-str~*#(title-str)*_#(tag-str)_#head-body-separator~]
    } else {
      // Typst does not reorder Latin runs inside RTL text, so lay out the
      // pieces explicitly: title first, then tags, then the supplement.
      // HTML export drops `box`/`stack`, so it keeps the logical order (the browser handles bidi)
      let pieces = ()
      if title != [] { pieces.push(strong(title-str)) }
      if tags != () { pieces.push(emph(tag-str)) }
      pieces.push(supplement-str)
      [~#box(stack(dir: rtl, spacing: 0.5em, ..pieces))~#head-body-separator~]
    }
  }
}

#let hint-html(title, tags, body, supplement, number, accent-color) = {
  let has-body = body != []
  let has-title = title not in ([], "", none)
  let has-headers = int(has-title) + tags.len() > 0
  let body-only = title == none
  show divider: _ => html.hr(
    style: css(
      background: accent-color,
      height: stroke-width,
      border: 0,
      margin: (body-inset, -body-inset),
    ),
  )
  context {
    let css-dict = (padding: body-inset)
    css-dict.insert(
      "border-" + if text-is-left-to-right() { "left" } else { "right" },
      (line-width, "solid", accent-color),
    )
    html.div(
      style: css(css-dict),
      {
        header-suppl(title, tags, body, supplement, number)
        body
      },
    )
  }
}

#let hint-paged(title, tags, body, supplement, number, accent-color) = {
  let stroke = stroke(
    thickness: line-width,
    paint: accent-color,
    cap: "round",
  )

  let header = header-suppl(title, tags, body, supplement, number)
  context layout(((width,)) => {
    let is-ltr = text-is-left-to-right()
    let side = if is-ltr { "left" } else { "right" }
    let text = {
      show divider: _ => {
        v(body-inset - 1em)
        let rule = line(
          length: 100% + body-inset,
          start: (-body-inset, 0pt),
          stroke: accent-color + stroke-width,
        )
        // RTL lines are anchored at their end, so shift them to overshoot the border side like LTR
        if is-ltr { rule } else { move(dx: body-inset, rule) }
        v(body-inset - 1em)
      }

      block(
        width: width,
        stroke: ((side): stroke),
        inset: ((side): 0.7em, y: 0.7em),
        align(start, header + body),
      )
    }

    // At both ends of the line drawn by the border, we overlay lines which
    // extend them by rounded ends. This looks better.
    let length = 0.2em // Arbitrary; if too long, could extend into page margins
    place(line(stroke: stroke, angle: 90deg, length: length))
    text
    place(line(stroke: stroke, angle: 90deg, length: -length))
    // We prefer this setup to only using the block border because we want the
    // rounded edges. We prefer it to one contiguous line because then the
    // line would be missing if the hint breaks across two or more pages.
    // See: https://github.com/marc-thieme/frame-it/issues/1
  })
}

#let hint(title, tags, body, supplement, number, accent-color) = target-choose(
  html: () => hint-html(title, tags, body, supplement, number, accent-color),
  paged: () => hint-paged(title, tags, body, supplement, number, accent-color),
)
