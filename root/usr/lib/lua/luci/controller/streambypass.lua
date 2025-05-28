module("luci.controller.streambypass", package.seeall)

function index()
  entry({"admin", "services", "streambypass"}, cbi("streambypass"), _("Stream Bypass"), 60).dependent = true
  entry({"admin", "services", "streambypass", "status"}, template("streambypass_status"), _("Status"), 61).leaf = true
end