include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Tailscale Stream Bypass
LUCI_DEPENDS:=+iptables +luci +ip-full +conntrack
PKG_MAINTAINER:=Your Name <you@example.com>

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-streambypass
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
endef