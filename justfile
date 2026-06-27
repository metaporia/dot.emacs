# Pull personal config from github remote
pull:
    git pull github main

# Update base files from minimal-emacs.d upstream
pull-base:
    git fetch upstream
    git checkout upstream/main -- init.el early-init.el
    git add init.el early-init.el
    git commit -m "chore: sync init.el and early-init.el from minimal-emacs.d upstream"
