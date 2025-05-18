set unstable

readme-typ-file := 'README.typ'
tmpdir := env('XDG_RUNTIME_DIR', '/tmp') / 'frame-it'
dummy := shell('mkdir -p ' + tmpdir)
compile-html := 'typst compile --features html -f "html" --input html-frames=true '

unexport TYPST_FEATURES

default:
    just --list

# –––––– [ Release ] ––––––
_version-regex := '[0-9]+\.[0-9]+\.[0-9]+'
release new-version packages-repo-root: && (update-and-push-assets "Release version {{new-version}}") (cp-to-packages new-version packages-repo-root)
    @echo Testing if index and staging area are empty
    test -z "$(git status --porcelain)"
    sed -Ei 's|#import "@preview/frame-it:{{_version-regex}}"|#import "@preview/frame-it:{{new-version}}"|g' {{readme-typ-file}}
    sed -Ei 's|version = "{{_version-regex}}"|version = "{{new-version}}"|g' typst.toml
    sed -i "s/CURRENT/{{new-version}}/" CHANGELOG.md
    git add {{readme-typ-file}} typst.toml CHANGELOG.md
    git commit -m "Bump version to {{new-version}}."
    test -z "$(git status --porcelain)" # Just to make sure we didn't screw up
    git tag -a {{new-version}}
    @echo Don\'t forget to open a pull request for the new version!

_packages-suffix := "packages/preview/frame-it/"
[script]
cp-to-packages new-version packages-repo-root:
    folder={{packages-repo-root / _packages-suffix / new-version}}
    if [ -d $folder ];
        echo Folder $folder already exists >&2
        exit 1
    fi
    echo $folder
    exit 1
    cp . $folder -r
    cd $folder
    rm .github/ assets/ .git/ -r
    rm CHANGELOG.md justfile .gitignore .typos.toml .envrc
    sed -iE 's|^#import "src/lib.typ"|#import "@preview/frame-it:{{new-version}}"|g' $folder/README.typ
    find . -type f -name "*.pdf" -exec rm -f {}
    

[script('nu')]
update-html dir:
    ^mkdir -p {{dir}}/assets
    let light = {{compile-html}} {{readme-typ-file}} - | htmlq "body > *"
    let dark = {{compile-html}} --input theme=dark {{readme-typ-file}} - | htmlq "body > *"
    let light_split = ^cat assets/README-stub.html | split row LIGHT
    let full_split = [$light_split.0, ...($light_split.1 | split row DARK)]
    echo $full_split.0 $light $full_split.1 $dark $full_split.2 | str join
        | htmlq -r 'body > div > style:first-child' | save -f {{dir}}/assets/README.html

[script('nu')]
update-readme dir:
    {{compile-html}} --input svg-frames=true {{readme-typ-file}} {{tmpdir / "light.html"}}
    {{compile-html}} --input svg-frames=true --input theme=dark {{readme-typ-file}} {{tmpdir / "dark.html"}}
    ^cat {{tmpdir / "light.html"}} | pandoc -f html -t gfm -o {{tmpdir / "README-v1.md"}}

    let svgs_light = htmlq -f {{tmpdir / "light.html"}} "svg" | split row "<svg"
        | filter {($in | str length) > 0} | each {"<svg" + $in}
    let svgs_dark = htmlq -f {{tmpdir / "dark.html"}} "svg" | split row "<svg"
        | filter {($in | str length) > 0} | each {"<svg" + $in}

    for row in ($svgs_light | enumerate | rename index svg) {
        $row.svg | save -f $"{{dir}}/assets/README-svg-light-($row.index).svg"
    }
    for row in ($svgs_dark | enumerate | rename index svg) {
        $row.svg | save -f $"{{dir}}/assets/README-svg-dark-($row.index).svg"
    }

    echo '> [!NOTE]
    > This is the version of the readme adapted for the Github Readme.
      This adaption is less than ideal.
      If you want to copy text and have a faithful render, go to [this link](https://html-preview.github.io/?url=https://github.com/marc-thieme/frame-it/blob/assets/README.html).
    '
        | cat - {{tmpdir / "README-v1.md"}} | save -f {{tmpdir / "README-v2.md"}}

    mut readme = open {{tmpdir / "README-v2.md"}}

    def "str erase" [...patterns: string] {
        let text = $in
        $patterns | reduce --fold $text { |pattern, acc| $acc | str replace -rma $pattern '' }
    }

    for i in 0..($svgs_light | length) {
        let idx = $i | into string
         $readme = $readme | str replace -rm '<img\s+src=".+?"\s+class="typst-doc"\s+/>' ('
            <picture>
              <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-' + $idx + '.svg">
              <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-' + $idx + '.svg">
            </picture>
        ' | str replace -ra '\s+' ' ')
    }

    $readme | str erase '\n*^</?div.*>$' '^\s*</?figure>\s*$' | save -f {{dir / "README.md"}}

check-style staging-only="false":
    typos --exclude '*.html'
    typstyle --check \
        $({{if staging-only == "false" {"find"} else {"git diff-index --cached --name-only HEAD"} }}\
         | grep '\.typ') README.typ \
        > /dev/null

update-assets: (update-html ".") && (update-readme ".")
    git add README.md # Make sure not to override changes in README
    
test-compile: (update-html tmpdir) (update-readme tmpdir)
    typst compile README.typ {{tmpdir / "README.pdf"}}

[confirm("Do you want to commit and push all changes on the assets branch?")]
[working-directory("assets")]
update-and-push-assets commit-msg="chore: update": update-assets
    git add .
    git commit -m "{{commit-msg}}" --no-verify
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

