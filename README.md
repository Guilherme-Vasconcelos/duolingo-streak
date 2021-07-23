# duolingo-streak
duolingo-streak is an Emacs package to remind you about your Duolingo daily tasks via D-Bus notifications.

Be aware that duolingo-streak is NOT official (in the sense that it is not endorsed/associated with Duolingo).

### Usage
Set the environment variables: `DUOLINGO_USERNAME` and `DUOLINGO_PASSWORD`.

To install the package, move `duolingo-streak.el` to some known path and add to your config:
``` emacs-lisp
(add-to-list 'load-path "path/to/duolingo-streak.el")  ; Only required if path is not yet added
(require 'duolingo-streak)
```

You also need to install the [request](https://github.com/tkf/emacs-request) library (already installed on Doom Emacs).

Then run `(duolingo-streak--verify)` to perform a verification.

You can schedule the function to run hourly by adding to your config:
``` emacs-lisp
(run-with-timer 1800 3600 #'duolingo-streak--verify)  ; 1800 is the delay before running for the first time
```

### Contact
If you'd like to talk to me, please use either the [discussions](https://github.com/Guilherme-Vasconcelos/duolingo-streak/discussions)
or [issues](https://github.com/Guilherme-Vasconcelos/duolingo-streak/issues) pages.

### Acknowledgements
- Thanks to the [unofficial Duolingo API wrapper](https://github.com/KartikTalwar/Duolingo) made by KartikTalwar (and contributors), which I have used to check API endpoints.

### License
Copyright (C) Guilherme-Vasconcelos

duolingo-streak is licensed under the GNU General Public License, either version 3 or any later versions. Please refer to LICENSE for more details.
