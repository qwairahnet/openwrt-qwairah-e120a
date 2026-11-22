module("luci.controller.qwairah", package.seeall)

function index()
	entry({"admin", "qwairah"}, firstchild(), _("QWAIRAH"), 15).dependent = false
	entry({"admin", "qwairah", "quicksetup"}, cbi("qwairah/quicksetup"), _("Quick Setup"), 1)
	entry({"admin", "qwairah", "telegram"}, cbi("qwairah/telegram"), _("Telegram Bot"), 2)
end
