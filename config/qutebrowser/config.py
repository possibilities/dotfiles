config.load_autoconfig()

c.url.searchengines = {"DEFAULT": "https://google.com/search?hl=en&q={}"}

config.bind("K", "tab-next")
config.bind("J", "tab-prev")

config.bind("<<", "tab-move -")
config.bind(">>", "tab-move +")

config.set('scrolling.bar', 'when-searching')

config.set("tabs.background", True)

config.set("tabs.show", "multiple")
config.set("statusbar.show", "in-mode")

config.set("window.hide_decoration", True)

config.set("auto_save.session", True)

c.url.default_page = "about:blank"
c.url.start_pages = ["about:blank"]

config.source('nord-qutebrowser.py')
