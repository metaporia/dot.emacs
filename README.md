# README

- base config is kept in ~/.emacs.d (cloned from minimal-emacs.d)
- user config lives here


## FIX this config, christ bro

currently starts from ~/.emacs.d (which manages only `init.el` and
`early-init.el`). 

Everything else is managed by me. Do we need a separate directory for
minimal-emacs? Apparently, I copied some of the minimal-emacs' files into
my personal repo which thoroughly muddies the otherwise limpid waters of config order.

TODO
- [ ] decide on single config dir (must we plan for updates from `minimal-emacs`?)
- [ ] get config working on windows


### Duplicated Files

- `pre-init.el`
- `pre-early-init.el`

### Load Order

```
/home/aporia/.emacs.d/pre-early-init.el
/home/aporia/.emacs.d/early-init.el
/home/aporia/emacs/pre-init.el
/home/aporia/emacs/org.el
/home/aporia/emacs/completion.el
/home/aporia/emacs/post-init.el
/home/aporia/.emacs.d/init.el
/home/aporia/.emacs.d/pre-early-init.el
/home/aporia/.emacs.d/early-init.el
/home/aporia/emacs/pre-init.el
/home/aporia/emacs/org.el
/home/aporia/emacs/completion.el
/home/aporia/emacs/post-init.el
/home/aporia/.emacs.d/init.el
```

Lmfao this is fucking ridiculous. How does this even work?

NB: We need to load from minimal-emacs only `init.el` and `early-init.el`

Let's just move those here and try to launch it (though we'll need to change
any reference to `minimal-emacs-user-director` and its ilk)
