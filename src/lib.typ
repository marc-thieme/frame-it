#import "styles.typ" as styles
#import "styling.typ" as styling
#import "bundled-layout.typ": divide, breakable-frames

#let make-frames(
  kind,
  style: styles.boxy,
  base-color: purple.lighten(60%).desaturate(40%),
  ..frames,
) = {
  import "parse.typ": fill-missing-colors
  import "bundled-layout.typ": bundled-factory

  for (id, supplement, color) in fill-missing-colors(base-color, frames) {
    ((id): bundled-factory(style, supplement, kind, color))
  }
}

/*
Definition of styling:

let factory(title: content, tags: (content), body: content, supplement: string or content, number, args)
*/
