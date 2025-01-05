#import "styles.typ" as styles
#import "styling.typ" as styling
#import "layout.typ": divide, breakable-frames

#let make-frames(
  kind,
  style: styles.boxy,
  base-color: purple.lighten(60%).desaturate(40%),
  ..frames,
) = {
  import "parse.typ"
  import "layout.typ"

  for (id, supplement, color) in parse.fill-missing-colors(base-color, frames) {
    ((id): layout.factory(style, supplement, kind, color))
  }
}

/*
Definition of styling:

let factory(title: content, tags: (content), body: content, supplement: string or content, number, args)
*/
