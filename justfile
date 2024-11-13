set unstable

readme-typ-file := 'README.typ'

setup: && _add-assets-to-git-exclude
    git worktree add assets
[confirm("Add new worktree 'assets' to '.git/info/exclude'?")]
_add-assets-to-git-exclude:
    echo assets >> .git/info/exclude

push-new-readme: (example-compile "assets/README.svg") && commit-and-push-assets

[confirm("Do you want to commit and push all changes on the assets branch?")]
[script]
commit-and-push-assets commit-msg="Update.":
    cd assets
    git add .
    git commit -m {{commit-msg}}
    git push

readme-watch output="":
    typst watch {{readme-typ-file}} {{output}} --root ..

readme-compile output="":
    typst compile {{readme-typ-file}} {{output}} --root ..
