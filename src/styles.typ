#import "styling.typ" as styling
#import "bundled-layout.typ": divide

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let corner-radius = 5pt

#let boxy(title, tags, body, supplement, number, accent-color) = {
  assert(
    type(accent-color) == color,
    message: "Please provide a color as argument for the frame instance"
      + supplement,
  )

  let stroke = accent-color + stroke-width

  let round-bottom-corners-of-tags = body == []
  let display-title = title not in ([], "")
  let round-top-left-body-corner = title in ([], none) and tags == ()

  let header() = align(
    left,
    {
      let inset = 0.5em

      let tag-elements = tags
      if display-title {
        let title-cell = grid.cell(fill: accent-color, title)
        tag-elements.insert(0, title-cell)
      }

      let rounded-corners = (top: corner-radius)
      if round-bottom-corners-of-tags {
        rounded-corners.bottom = corner-radius
      }

      let rendered-tags = if tag-elements == () [] else {
        let grid-cells = tag-elements.intersperse(grid.vline(stroke: stroke))
        let tag-grid = grid(columns: tag-elements.len(), align: horizon, inset: inset, ..grid-cells)
        box(clip: true, stroke: stroke, radius: rounded-corners, tag-grid)
        h(1fr)
      }

      let supplement-str = box(inset: inset)[#supplement #number]

      layout(((width: available-width)) => {
        if measure(rendered-tags + supplement-str).width < available-width {
          rendered-tags
          supplement-str
        } else [
          #supplement #number \
          #rendered-tags
        ]
      })
    },
  )

  let board() = {
    let round-corners = (bottom: corner-radius, top-right: corner-radius)
    if round-top-left-body-corner {
      round-corners.top-left = corner-radius
    }
    align(
      left,
      block(
        width: 100%,
        inset: body-inset,
        radius: round-corners,
        stroke: stroke,
        spacing: 0em,
        outset: (y: 0em),
        {
          // Divide constructs a line where we need to inject the stroke style because we only have access to the color here
          show: styling.dividers-as({
            v(body-inset - 1em)
            line(length: 100% + 2 * body-inset, stroke: stroke)
            v(body-inset - 1em)
          })
          body
        },
      ),
    )
  }

  let parts = ()

  let rounded-corners = (bottom: corner-radius)

  if title != none {
    parts.push(header())
  }

  if body != [] {
    parts.push(board())
  }

  stack(..parts)
}

#let hint(title, tags, body, supplement, number, accent-color) = {
  let stroke = stroke(
    thickness: 3.5pt,
    paint: accent-color,
    cap: "round",
  )

  let header = if title == none {
    none
  } else {
    if title != [] {
      title = [~~#title~]
    }

    let tag-str = if tags != () {
      [~(#tags.join(", "))~]
    } else {
      []
    }
    let supplement-str = context {
      let header-color = text.fill.mix((text.fill.negate(), 20%))
      text(header-color)[#supplement #number]
    }
    let head-body-separator = if body == [] [] else [:]
    [~#supplement-str~*#(title)*_#(tag-str)_#head-body-separator~]
  }

  layout(((width,)) => {
    let text = {
      show: styling.dividers-as({
        v(body-inset - 1em)
        line(
          length: 100% + body-inset,
          start: (-body-inset, 0pt),
          stroke: accent-color + stroke-width,
        )
        v(body-inset - 1em)
      })

      block(
        width: width,
        stroke: (left: stroke),
        inset: (left: 0.7em, y: 0.7em),
        align(left, header + body),
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

