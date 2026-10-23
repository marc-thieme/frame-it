#import "../utils/html.typ": css, span, div, hr, target-choose, wants-html
#import "../utils/text-queries.typ": text-is-left-to-right

#let line-width = 3pt
#let body-inset = 1em
#let text-color(accent-color) = (
  accent-color.mix((text.fill.lighten(80%), 100%)).saturate(60%)
)


#let thmbox-html(title, tags, body, supplement, number, accent-color) = context {
  let has-body = body != []
  let has-title = title not in ([], "", none)
  let has-headers = int(has-title) + tags.len() > 0
  let body-only = title == none
  let is-ltr = text-is-left-to-right()
  let border-side = if is-ltr { "left" } else { "right" }
  let frame-css = (padding: body-inset)
  frame-css.insert("border-" + border-side, (line-width, "solid", accent-color))
  div(
    css(frame-css),
    {
      if not body-only {
        context div(
          css(
            ..(
              if has-headers {
                (
                  display: "flex",
                  justify-content: "space-between",
                  align-items: center,
                  flex-direction: if is-ltr { "row" } else { "row-reverse" },
                )
              } else { (:) }
            ),
            color: text-color(accent-color),
          ),
          {
            if has-title {
              div(css(flex: "1.7 1 1", text-align: left), strong(title))
            }
            let is-first = true
            for tag in tags {
              div(css(flex: "1 1 1", text-align: center), tag)
              is-first = false
            }
            div(
              css(
                flex: "1.7 1 1",
                text-align: if has-headers { right } else { left },
              ),
              strong(supplement + " " + number),
            )
          },
        )
      }
      show divider: _ => hr(
        css(
          background: accent-color,
          height: 0.18em,
          border: 0,
          margin: (0, 0, 0, -body-inset),
        ),
      )
      body
    },
  )
}

// Credits to https://github.com/s15n/typst-thmbox
#let thmbox-paged(title, tags, body, supplement, number, accent-color) = context {
  let has-body = body != []
  let has-title = title not in ([], "", none)
  let has-tags = tags.len() > 0
  let has-headers = has-title or has-tags
  let body-only = title == none
  let is-ltr = text-is-left-to-right()
  let side = if is-ltr { "left" } else { "right" }

  let bar = stroke(paint: accent-color, thickness: line-width)

  show divider: _ => {
    let rule = line(
      length: 100% + 1em,
      start: (-1em, 0pt),
      stroke: accent-color + line-width * 0.8,
    )
    // RTL lines are anchored at their end, so shift them to overshoot the border side like LTR
    if is-ltr { rule } else { move(dx: 1em, rule) }
    v(-0.2em)
  }

  // Typst does not reorder Latin runs inside RTL text, so the title bar is
  // built as an explicit row that runs right to left
  let title-bar() = {
    let items = ()
    if has-title { items.push(title) }
    if has-headers { items.push(h(3fr)) }
    if has-tags {
      for tag in tags {
        items.push(text(tag, weight: "regular"))
        items.push(h(1fr))
      }
      items.push(h(2fr))
    }
    items.push(supplement + " " + number)
    if is-ltr {
      items.join()
    } else {
      stack(dir: rtl, ..items)
    }
  }

  block(
    stroke: (
      (side): bar,
    ),
    inset: (
      (side): 1em,
      top: 0.6em,
      bottom: 0.6em,
    ),
    spacing: 1.2em,
  )[
    #set align(start)
    // Title bar
    #if not body-only {
      block(
        above: 0em,
        below: 1.2em,
        context {
          set text(text-color(accent-color), weight: "bold")
          title-bar()
        },
      )
    }
    // Body
    #if has-body {
      block(
        inset: (
          (if is-ltr { "right" } else { "left" }): 1em,
        ),
        spacing: 0em,
        width: 100%,
        body,
      )
    }
  ]
}

#let thmbox(
  title,
  tags,
  body,
  supplement,
  number,
  accent-color,
) = target-choose(
  html: () => thmbox-html(title, tags, body, supplement, number, accent-color),
  paged: thmbox-paged(title, tags, body, supplement, number, accent-color),
)

