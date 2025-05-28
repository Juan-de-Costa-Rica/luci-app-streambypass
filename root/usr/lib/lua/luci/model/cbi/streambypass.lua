m = Map("streambypass", "Tailscale Stream Bypass")

s = m:section(TypedSection, "streambypass", "Settings")
s.anonymous = true
s:option(Flag, "enabled", "Enable Bypass Script")
s:option(Value, "threshold", "Bandwidth Threshold (bytes)")
s:option(Value, "timeout", "Rule Timeout (seconds)")
s:option(Value, "subnet", "Monitored Subnet (e.g. 192.168.8.0/24)")

return m