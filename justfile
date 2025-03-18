set unstable

readme-typ-file := 'README.typ'
tmpdir := env('XDG_RUNTIME_DIR', '/tmp') / 'frame-it'
dummy := shell('mkdir -p ' + tmpdir)

export TYPST_FEATURES := "html"

default:
    just --list

# –––––– [ Release ] ––––––
_version-regex := '[0-9]+\.[0-9]+\.[0-9]+'
release new-version: && (update-and-push-assets "Release version {{new-version}}")
    @echo Testing if index and staging area are empty
    test -z "$(git status --porcelain)"
    sed -Ei 's|#import "@preview/frame-it:{{_version-regex}}"|#import "@preview/frame-it:{{new-version}}"|g' {{readme-typ-file}}
    sed -Ei 's|version = "{{_version-regex}}"|version = "{{new-version}}"|g' typst.toml
    sed -i "s/CURRENT/1.1.0/" CHANGELOG.md
    git add {{readme-typ-file}} typst.toml CHANGELOG.md
    git commit -m "Bump version to {{new-version}}."
    test -z "$(git status --porcelain)" # Just to make sure we didn't screw up
    git tag -a {{new-version}}
    @echo Don\'t forget to open a pull request for the new version!

[script('nu')]
update-html dir:
    ^mkdir -p {{dir}}/assets
    let light = typst compile -f html {{readme-typ-file}} - | htmlq "body > *"
    let dark = typst compile --input theme=dark -f html {{readme-typ-file}} - | htmlq "body > *"
    let light_split = ^cat assets/README-stub.html | split row LIGHT
    let full_split = [$light_split.0, ...($light_split.1 | split row DARK)]
    echo $full_split.0 $light $full_split.1 $dark $full_split.2 | str join
        | htmlq -p -r 'body > div > style:first-child' | save -f {{dir}}/assets/README.html

[script('nu')]
update-readme dir:
    typst compile --input svg-frames=true {{readme-typ-file}} {{tmpdir / "light.html"}}
    typst compile --input svg-frames=true --input theme=dark {{readme-typ-file}} {{tmpdir / "dark.html"}}
    ^cat {{tmpdir / "light.html"}} | pandoc -f html -t gfm -o {{tmpdir / "README-v1.md"}}

    let svgs_light = htmlq -f {{tmpdir / "light.html"}} "svg" | split row "<svg" | each {"<svg" + $in}
    let svgs_dark = htmlq -f {{tmpdir / "dark.html"}} "svg" | split row "<svg" | each {"<svg" + $in}

    for row in ($svgs_light | enumerate | rename index svg) {
        $row.svg | save -f $"{{dir}}/assets/README-svg-light-($row.index).svg"
    }
    for row in ($svgs_dark | enumerate | rename index svg) {
        $row.svg | save -f $"{{dir}}/assets/README-svg-dark-($row.index).svg"
    }

    echo '> [!NOTE]
    > This is the version of the readme adapted for the Github Readme.
      This adaption is less than ideal.
      For a faithful render, go to [this link](https://html-preview.github.io/?url=https://github.com/marc-thieme/frame-it/blob/assets/README.html)
    '
        | cat - {{tmpdir / "README-v1.md"}} | save -f {{tmpdir / "README-v2.md"}}

    mut readme = open {{tmpdir / "README-v2.md"}}

    for i in 0..($svgs_light | length) {
        let idx = $i | into string
         $readme = $readme | str replace -rm '<img\s+src=".+?"\s+class="typst-doc"\s+/>' ('
            <picture>
              <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-' + $idx + '.svg">
              <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-' + $idx + '.svg">
            </picture>
        ' | str replace -ra '\s+' ' ')
    }
    $readme | save -f {{dir / "README.md"}}

check-style staging-only="false":
    typos --exclude '*.html'
    typstyle --check \
        $({{if staging-only == "false" {"find"} else {"git diff-index --cached --name-only HEAD"} }}\
         | grep '\.typ') README.typ \
        > /dev/null

update-assets: (update-html ".") (update-readme ".")
    
test-compile: (update-html tmpdir) (update-readme tmpdir)

[confirm("Do you want to commit and push all changes on the assets branch?")]
[working-directory("assets")]
update-and-push-assets commit-msg="Update.": update-assets
    git add .
    git commit -m {{commit-msg}} --no-verify
    git push

# –––––– [ Setup ] ––––––
setup: setup-pre-commit-hooks && _add-assets-to-git-exclude
    git worktree add assets assets

[confirm("Add pre-commit hook to .git/hooks/pre-commit?")]
setup-pre-commit-hooks:
    touch .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "just pre-commit" >> .git/hooks/pre-commit

[confirm("Add new worktree 'assets' to '.git/info/exclude'?")]
_add-assets-to-git-exclude:
    echo assets >> .git/info/exclude

pre-commit: (check-style "true") test-compile

