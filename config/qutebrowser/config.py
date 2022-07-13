config.load_autoconfig()

# Search
c.url.searchengines = {"DEFAULT": "https://google.com/search?hl=en&q={}"}

# Tab navigation and moving
config.bind("K", "tab-next")
config.bind("J", "tab-prev")
config.bind("<", "tab-move -")
config.bind(">", "tab-move +")

# Tabs and statusbar settings and toggle
config.set("statusbar.show", "always")
config.set("tabs.show", "always")
config.bind('xx', 'config-cycle statusbar.show always in-mode ;; config-cycle tabs.show always switching')

# Prevent default quit binding
config.unbind('<Ctrl-q>', mode='normal')

# Misc
config.set('scrolling.bar', 'when-searching')
config.set("window.hide_decoration", True)
config.set("auto_save.session", True)

# Downloads
config.set('downloads.location.directory', '/home/mike/Downloads')
config.set('downloads.location.prompt', False)
config.set('downloads.location.remember', True)
config.set('downloads.position', 'bottom')
config.set('downloads.remove_finished', 1)

# Tabs
config.set("tabs.background", True)
config.set("tabs.last_close", "close")

# Startup and new tabs
c.url.default_page = "/home/mike/code/dotfiles/config/qutebrowser/blank.html"
c.url.start_pages = ["/home/mike/code/dotfiles/config/qutebrowser/blank.html"]

# Theme
config.set("fonts.default_family", "Fira Code")
config.source('nord-qutebrowser.py')

# Prevents periodic crashes on windows and debian
config.set("qt.workarounds.remove_service_workers", True)
