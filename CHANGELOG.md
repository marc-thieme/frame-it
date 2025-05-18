## CURRENT
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
