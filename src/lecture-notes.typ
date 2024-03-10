#import "styling.typ": break-page-after-chapters
#import "theorems.typ" : init-theorems, theorem-factory

#let zb = $dot.circle$

#let proof_styling(thm) = block(breakable: true, {
    let params = lemmify.get-theorem-parameters(thm)
    emph[Proof.]
    [ ] + params.body
    h(1fr)
    box(scale(160%, origin: bottom + right, sym.square.stroked))
  })

#let proof(body) = block(breakable: true, {
  emph[Proof.]
  [ ] + body
  h(1fr)
  box(scale(160%, origin: bottom + right, sym.square.stroked))
})

#let project(title, professor, author, body) = {
  import "styling.typ" as styling
  let time = datetime.today().display("[day].[month].[year]")
  let abstract = []

  show table: set align(center)
  set table(inset: 0.7em)

  // Insert the 0-space to avoid infinit recursion
  show regex("\biff\b"): (body) => [_if#h(0pt)f_]
  show regex("\bAssume\b"): (body) => [_Assum#h(0pt)e_]

  styling.note-page(title, author, professor, author, time, abstract, body)
}
