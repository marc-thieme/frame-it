## 2.1.0
### API
- use Typst's native `divider()` element for dividers [#22](https://github.com/marc-thieme/frame-it/issues/22)
- deprecate `styling.divide`, use `divider()` instead; `divide()` still works as an alias
- deprecate `styling.dividers-as`, use `show divider: ...` in styling functions instead; still works
- add `styling.direction-info` for the text direction and output target of a frame
- add `styling.frame-structure` with the parts derived from a frame's title, tags and body
- add `styling.assert-arg-type` to check the frame argument of a styling function

### Fixes
- fix(layout): html `id` of referenced frames is set on the frame wrapper, so links to frames work [#23](https://github.com/marc-thieme/frame-it/issues/23)
- fix(styles): `hint` and `thmbox` styles support RTL layout [#14](https://github.com/marc-thieme/frame-it/issues/14)
- fix(styles): `boxy` html output used the invalid CSS property `mragin-right` for the supplement
- fix(styles): an empty title (`""`) no longer counts as a title in `boxy`, so its body corners stay rounded like with `[]`
- fix(styles): a body containing only whitespace is treated as empty

### Implementation
- refactor(html): use Typst's typed `html` functions (e.g. `html.div`) instead of the custom `elem`/`span`/`div`/`hr` wrappers
- refactor(styles): `boxy`, `hint` and `thmbox` share the derived values via `styling.direction-info` and `styling.frame-structure`

## 2.0.0
### API
- BREAKING: remove deprecated `make-frames` function
- remove the need for `--input=html-frames` argument for html export

### Fixes
- fix(styles): support RTL layout [#14](https://github.com/marc-thieme/frame-it/issues/14)
- fix(api): handle `none` as figure numbering [#15](https://github.com/marc-thieme/frame-it/pull/15)

## 1.2.0
### Features
- feat(layout): add frame function to create a single frame
- docs(readme): showcase syntax for individual frame creation

### Fixes
- fix(layout): `frame-style` only applies to specific kind
- fix(styles): accept tags without title in thmbox
- fix: polylux presentation compatibility
- fix(inspection): `is-frame` works for all content

### Implementation
- refactor(layout): ad–hoc style by placing it into metadata

## 1.1.2
- Add inspection functions `lookup-frame-info` and `is-frame`
- Add suggestions for abbreviations to readme
- Fix compilation without feature flag html

## 1.1.1
- Rework README building
- Add abitlity to export to HTML
- Support dark theme for thmbox styling

## 1.1.0
- Add new styling
- In the `(make-)frames`–function, allow supplement to be supplied as single value
  instead of array
- Pass additional arguments in a frame function onto the figure function
  when placing it in the document
- Change API to declare the styling function to use using a show rule
- Refactor layouting system to be simpler and more robust
- Make frames breakable across pages
- Add version of readme for dark mode on GitHub
- Influence the auto–generated colors for the frames using `base-color` parameter
- Improve Readme

## 1.0.0
- Design syntax which minimizes redundancy, is flexible and easy to use
- Create default style `boxy` and `hint`
- Separate components and identify easy api for styling functions
- If colors are missing, generate colors spanning the rainbow
- Add a Readme which is compiled from Typst
