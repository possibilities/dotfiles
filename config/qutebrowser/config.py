config.load_autoconfig()

# Search
c.url.searchengines = {"DEFAULT": "https://google.com/search?hl=en&q={}"}

# Tab navigation and moving
config.bind("K", "tab-next")
config.bind("J", "tab-prev")
config.bind("<", "tab-move -")
config.bind(">", "tab-move +")

# Prevent default quit binding
config.unbind('<Ctrl-q>', mode='normal')

# Misc
config.set('scrolling.bar', 'when-searching')
config.set("statusbar.show", "in-mode")
config.set("window.hide_decoration", True)
config.set("auto_save.session", True)

# Downloads
config.set('downloads.location.directory', '/home/mike/Downloads')
config.set('downloads.location.prompt', False)
config.set('downloads.location.remember', True)

# Tabs
config.set("tabs.background", True)
config.set("tabs.show", "multiple")
config.set("tabs.last_close", "close")

# Startup and new tabs
c.url.default_page = "about:blank"
c.url.start_pages = ["about:blank"]

# Theme
config.set("fonts.default_family", "Fira Code")
config.source('nord-qutebrowser.py')

# Prevents periodic crashes on windows and debian
config.set("qt.workarounds.remove_service_workers", True)
