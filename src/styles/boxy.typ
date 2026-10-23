#import "../styling/export.typ": (
  assert-arg-type, css, direction-info, frame-structure, target-choose,
)

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let corner-radius = 5pt

#let boxy-html(title, tags, body, supplement, number, accent-color) = context {
  let (
    shows-header,
    has-title-text,
    has-body,
    has-header-items,
    header-joins-body,
    header-items,
    ..,
  ) = frame-structure(title, tags, body)

  let header-styles = (
    padding: "5px 10px",
    border: (stroke-width, "solid", accent-color),
    margin-left: "-2px",
  )
  let first-overlay = (margin-left: 0, border-top-left-radius: corner-radius)
  let last-overlay = (border-top-right-radius: corner-radius)
  if header-joins-body {
    header-styles.border-bottom = none
  } else {
    first-overlay.border-bottom-left-radius = corner-radius
    last-overlay.border-bottom-right-radius = corner-radius
  }

  if shows-header {
    html.div(style: css(display: "flex", align-items: center), {
      if has-header-items {
        let header-css = (header-styles,) * header-items.len()
        header-css.first() += first-overlay
        header-css.last() += last-overlay
        if has-title-text {
          header-css.first() += (background-color: accent-color)
        }
        for (content, css-dict) in header-items.zip(header-css) {
          html.span(style: css(..css-dict), content)
        }
      }
      html.span(
        style: css(
          ..header-styles,
          border-color: "transparent",
          margin-left: if has-header-items { auto } else { 0 },
          margin-right: body-inset,
        ),
        supplement + " " + number,
      )
    })
  }

  if has-body {
    show divider: _ => html.hr(style: css(
      border: 0,
      height: stroke-width,
      background: accent-color,
      margin: (0, -body-inset),
    ))
    let css-dict = (
      border: (stroke-width, "solid", accent-color),
      border-radius: (0, corner-radius, corner-radius, corner-radius),
      padding: body-inset,
    )
    if not has-header-items { css-dict.border-top-left-radius = corner-radius }
    html.div(style: css(css-dict), body)
  }
}

#let boxy-paged(title, tags, body, supplement, number, accent-color) = context {
  let (dir, start-side, ..) = direction-info()
  let (
    shows-header,
    has-title-text,
    has-body,
    has-header-items,
    header-joins-body,
    ..,
  ) = frame-structure(
    title,
    tags,
    body,
  )
  let stroke = accent-color + stroke-width

  let header() = align(start, {
    let inset = 0.5em
    let tag-elements = tags
    if has-title-text {
      tag-elements.insert(0, grid.cell(fill: accent-color, title))
    }

    let rounded-corners = (top: corner-radius)
    if not header-joins-body { rounded-corners.bottom = corner-radius }

    let rendered-tags = if tag-elements == () [] else {
      let grid-cells = tag-elements.intersperse(grid.vline(stroke: stroke))
      box(
        clip: true,
        stroke: stroke,
        radius: rounded-corners,
        grid(columns: tag-elements.len(), align: horizon, inset: inset, ..grid-cells),
      )
      h(1fr)
    }

    let supplement-str = box(inset: inset, stack(
      dir: dir,
      supplement,
      [~],
      number,
    ))

    layout(((width: available-width)) => {
      if measure(rendered-tags + supplement-str).width < available-width {
        rendered-tags
        supplement-str
      } else [
        #supplement #number \
        #rendered-tags
      ]
    })
  })

  let board() = {
    let round-corners = (rest: corner-radius)
    if has-header-items { round-corners.insert("top-" + start-side, 0%) }
    align(start, block(
      width: 100%,
      inset: body-inset,
      radius: round-corners,
      stroke: stroke,
      spacing: 0em,
      outset: (y: 0em),
      {
        // Divide constructs a line where we need to inject the stroke style because we only have access to the color here
        show divider: _ => {
          v(-0.5em + stroke-width)
          line(
            start: (-body-inset, 0em),
            length: 100% + 2 * body-inset,
            stroke: stroke,
          )
          v(-0.5em + stroke-width)
        }
        body
      },
    ))
  }

  stack(..(if shows-header { header() }, if has-body { board() }).filter(
    part => (
      part != none
    ),
  ))
}

#let boxy(title, tags, body, supplement, number, accent-color) = {
  assert-arg-type(accent-color, color, supplement)
  target-choose(
    html: () => boxy-html(title, tags, body, supplement, number, accent-color),
    paged: () => boxy-paged(
      title,
      tags,
      body,
      supplement,
      number,
      accent-color,
    ),
  )
}
