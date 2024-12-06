;; If you start Emacs now, you’ll see the GUI elements for a few milliseconds.
;; Let’s fix that by adding these lines to $HOME/.emacs.d/early-init.el2:

;; In hyprland this makes new emacs instance completely fill tile
;; (without it, there's a thick margin of unused screen space)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

; prevent package.el loading packages before their init/config is loaded
(setq package-enable-at-startup nil)
