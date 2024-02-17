#import "typst-lecture-notes.typ" as template
#import template: break_page_after_chapters

#let definition = template.note_block.with(
  class: "Definition", fill: rgb("#EDF1D6"), stroke: rgb("#609966")
)

#let theorem = template.note_block.with(
  class: "Theorem", fill: rgb("#FEF2F4"), stroke: rgb("#EE6983")
)

#let lemma = template.note_block.with(
  class: "Lemma", fill: rgb("#FFF4E0"), stroke: rgb("#F4B183")
)

#let corollary = template.note_block.with(
  class: "Corollary", fill: rgb("#F7FBFC"), stroke: rgb("#769FCD")
)

#let note = template.note_block.with(
  class: "Note", fill: rgb("#ef8064"), stroke: rgb("#8c4a39")
)

#let notation = template.note_block.with(
  class: "Notation", fill: rgb("#edcd82"), stroke: rgb("#966901")
)

#let approach = template.note_block.with(
  class: "Approach", fill: rgb("e2c271"), stroke: rgb("635021")
)

#let task = template.note_block.with(
  class: "Exersice", fill: gray.lighten(60%), stroke: gray.darken(60%))
)

#let proof(body) = block(spacing: 11.5pt, {
  emph[Proof.]
  [ ] + body
  h(1fr)
  box(scale(160%, origin: bottom + right, sym.square.stroked))
})

#let project(title, professor, author, body) = {
  let time = datetime.today().display("[day].[month].[year]")
  let abstract = []

  show table: set align(center)
  set table(inset: 3mm)

  // Insert the 0-space to avoid infinit recursion
  show regex("\biff\b"): (body) => [_if#h(0pt)f_]
  show regex("\bAssume\b"): (body) => [_Assum#h(0pt)e_]

  template.note_page(title, author, professor, author, time, abstract, body)
}
