set unstable

readme-typ-file := 'README.typ'
assets-dir := 'assets'
_package-version := `sed -n 's/^version = "\(.*\)"/\1/p' typst.toml`
tmpdir := env('XDG_RUNTIME_DIR', '/tmp') / 'frame-it'
compile-html := 'typst compile --features html -f "html"'

unexport TYPST_FEATURES

default:
    just --list

# –––––– [ Release ] ––––––
_version-regex := '[0-9]+\.[0-9]+\.[0-9]+'
release new-version packages-repo-root: && (cp-to-packages new-version packages-repo-root)
    @echo Testing if index and staging area are empty
    test -z "$(git status --porcelain)"
    sed -Ei 's|#import "@preview/frame-it:{{_version-regex}}"|#import "@preview/frame-it:{{new-version}}"|g' {{readme-typ-file}}
    sed -Ei 's|version = "{{_version-regex}}"|version = "{{new-version}}"|g' typst.toml
    sed -i "s/CURRENT/{{new-version}}/" CHANGELOG.md
    {{just_executable()}} update-assets
    git add {{readme-typ-file}} typst.toml CHANGELOG.md README.md {{assets-dir}}
    git commit -m "Bump version to {{new-version}}."
    test -z "$(git status --porcelain)" # Just to make sure we didn't screw up
    git tag -a {{new-version}} -m "Release {{new-version}}"
    @echo Don\'t forget to push the commit and tag, and to open a pull request for the new version!

# Only README, LICENSE, typst.toml, src/ and assets/ are copied. assets/ stays in the repository but is excluded from the bundle via typst.toml. Tests, CI, build scripts, CHANGELOG and README.typ are not published.

_packages-suffix := "packages/preview/frame-it/"

# Copy the publishable files into the packages repository
[script]
cp-to-packages new-version packages-repo-root:
    folder={{packages-repo-root / _packages-suffix / new-version}}
    rm -rf $folder
    mkdir -p $folder
    git ls-files -co --exclude-standard -- README.md LICENSE typst.toml src {{assets-dir}} \
        | grep -vF '{{assets-dir}}/README-stub.html' \
        | tar -cf - -T - | tar -xf - -C $folder

# –––––– [ README & assets ] ––––––

[script('nu')]
update-html dir:
    ^mkdir -p {{dir}}/{{assets-dir}}
    let light = {{compile-html}} {{readme-typ-file}} - | htmlq "body > *"
    let dark = {{compile-html}} --input theme=dark {{readme-typ-file}} - | htmlq "body > *"
    let light_split = ^cat {{assets-dir}}/README-stub.html | split row LIGHT
    let full_split = [$light_split.0, ...($light_split.1 | split row DARK)]
    echo $full_split.0 $light $full_split.1 $dark $full_split.2 | str join
        | htmlq -r 'body > div > style:first-child' | save -f {{dir}}/{{assets-dir}}/README.html

[script('nu')]
update-readme dir:
    ^mkdir -p {{tmpdir}} {{dir}}/{{assets-dir}}
    {{compile-html}} --input svg-frames=true {{readme-typ-file}} {{tmpdir / "light.html"}}
    {{compile-html}} --input svg-frames=true --input theme=dark {{readme-typ-file}} {{tmpdir / "dark.html"}}
    ^cat {{tmpdir / "light.html"}} | pandoc -f html -t gfm -o {{tmpdir / "README-v1.md"}}

    let svgs_light = htmlq -f {{tmpdir / "light.html"}} "svg" | split row "<svg"
        | where {($in | str length) > 0} | each {"<svg" + $in}
    let svgs_dark = htmlq -f {{tmpdir / "dark.html"}} "svg" | split row "<svg"
        | where {($in | str length) > 0} | each {"<svg" + $in}

    # Remove frames of a previous run, so no stale SVGs are left behind
    glob $"{{dir}}/{{assets-dir}}/README-svg-*.svg" | each {|f| rm $f}
    for row in ($svgs_light | enumerate | rename index svg) {
        $row.svg | save -f $"{{dir}}/{{assets-dir}}/README-svg-light-($row.index).svg"
    }
    for row in ($svgs_dark | enumerate | rename index svg) {
        $row.svg | save -f $"{{dir}}/{{assets-dir}}/README-svg-dark-($row.index).svg"
    }

    echo '> This is the version of the readme adapted for Markdown renderers.
    > This adaption is less than ideal.
      If you want to copy text and have a faithful render, go to [this link](https://html-preview.github.io/?url=https://github.com/marc-thieme/frame-it/blob/{{_package-version}}/{{assets-dir}}/README.html).
    '
        | cat - {{tmpdir / "README-v1.md"}} | save -f {{tmpdir / "README-v2.md"}}

    mut readme = open --raw {{tmpdir / "README-v2.md"}}

    def "str erase" [...patterns: string] {
        let text = $in
        $patterns | reduce --fold $text { |pattern, acc| $acc | str replace -rma $pattern '' }
    }

    # pandoc turns each inline <svg> into a data URI image, in document order.
    # Replace them one by one with theme-responsive pictures pointing at the files in assets/.
    for i in 0..($svgs_light | length) {
        let idx = $i | into string
        $readme = $readme | str replace -rm '!\[\]\(data:image/svg\+xml;base64,[A-Za-z0-9+/=]+\)' ('
            <picture>
              <source media="(prefers-color-scheme: dark)" srcset="{{assets-dir}}/README-svg-dark-' + $idx + '.svg">
              <img alt="Frame example" src="{{assets-dir}}/README-svg-light-' + $idx + '.svg">
            </picture>
        ' | str replace -ra '\s+' ' ')
    }

    $readme | str erase '\n*</?div[^>]*>' '^\s*</?figure>\s*$' | save -f {{dir / "README.md"}}

check-style staging-only="false":
    typos
    files=$(if [ "{{staging-only}}" = true ]; then git diff --cached --name-only --diff-filter=d -- '*.typ'; else git ls-files '*.typ'; fi); [ -z "$files" ] || typstyle --check $files

# Regenerate README.md and everything in assets/ from README.typ
update-assets: (update-html ".") (update-readme ".")

test-compile: (update-html tmpdir) (update-readme tmpdir)
    typst compile README.typ {{tmpdir / "README.pdf"}}

# –––––– [ Setup ] ––––––
setup: setup-pre-commit-hooks

[confirm("Add pre-commit hook to .git/hooks/pre-commit?")]
setup-pre-commit-hooks:
    echo "just pre-commit" >> .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit

pre-commit: (check-style "true") test-compile
