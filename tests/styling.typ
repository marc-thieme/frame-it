#import "../src/styling/export.typ": (
  assert-arg-type, direction-info, frame-structure,
)

#let check(title, tags, body, expected) = {
  let structure = frame-structure(title, tags, body)
  for (key, value) in expected {
    assert.eq(
      structure.at(key),
      value,
      message: "`" + key + "` differs for title " + repr(title),
    )
  }
}

// `none` hides the header, empty values show a header without title
#check(none, (), [Body], (
  shows-header: false,
  has-title-text: false,
  header-joins-body: false,
))
#check([], (), [Body], (
  shows-header: true,
  has-title-text: false,
  has-header-items: false,
))
#check("", (), [Body], (shows-header: true, has-title-text: false))
#check([Title], (), [Body], (shows-header: true, has-title-text: true))

// Header items: the title first, then the tags
#check([Title], ([a], [b]), [Body], (
  has-tags: true,
  has-header-items: true,
  header-items: ([Title], [a], [b]),
))
#check([], ([a],), none, (
  has-title-text: false,
  has-header-items: true,
  header-items: ([a],),
))
#check(none, (), none, (has-header-items: false, header-items: ()))

// No body for none, empty strings, empty content and lone spaces
#for body in (none, "", [], [ ]) {
  check([Title], (), body, (has-body: false, header-joins-body: false))
}

// Header and body share an edge only if both are shown
#check([Title], (), [Body], (has-body: true, header-joins-body: true))
#check(none, (), [Body], (header-joins-body: false))

#let check-direction(expected) = context {
  let info = direction-info()
  for (key, value) in expected {
    assert.eq(info.at(key), value, message: "`" + key + "` differs")
  }
}

#let ltr-info = (is-ltr: true, dir: ltr, start-side: "left", end-side: "right")
#let rtl-info = (is-ltr: false, dir: rtl, start-side: "right", end-side: "left")

// Default left-to-right, then right-to-left by language and by direction
#check-direction(ltr-info)
#{
  set text(lang: "he")
  check-direction(rtl-info)
}
#{
  set text(dir: rtl)
  check-direction(rtl-info)
}

#assert-arg-type(red, color, [Theorem])
