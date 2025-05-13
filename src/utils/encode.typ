#let _unique-frame-metadata-tag = "_THIS-IS-METADATA-USED-FOR-FRAME-IT-FRAMES"

// Encode info as invisible metadata so when rendered in outline, only the title is seen
#let encode-title-and-info(title, info) = (
  // Add "" so when title is `none`, result still has type 'sequence'
  metadata((_unique-frame-metadata-tag, ..info)) + "" + title
)
#let retrieve-info-from-code(code) = code.children.first().value.slice(1)
#let code-has-info-attached(code) = (
  code != none
    and "children" in code.fields()
    and code.children.first() != none
    and code.children.first().fields().at("value", default: ()).at(0, default: "")
      == _unique-frame-metadata-tag
)

