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

define Package/luci-app-streambypass/description
  LuCI app to manage Tailscale stream bypass with bandwidth-based routing.
endef

define Build/Compile
  true
endef

define Package/luci-app-streambypass/install
  $(INSTALL_DIR) $(1)/etc/config
  $(INSTALL_DATA) ./luci-app-streambypass/etc/config/streambypass $(1)/etc/config/

  $(INSTALL_DIR) $(1)/etc/init.d
  $(INSTALL_BIN) ./luci-app-streambypass/etc/init.d/streambypass $(1)/etc/init.d/

  $(INSTALL_DIR) $(1)/usr/bin
  $(INSTALL_BIN) ./luci-app-streambypass/usr/bin/streambypass $(1)/usr/bin/

  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
  $(INSTALL_DATA) ./luci-app-streambypass/usr/lib/lua/luci/controller/streambypass.lua $(1)/usr/lib/lua/luci/controller/

  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/streambypass
  $(INSTALL_DATA) ./luci-app-streambypass/usr/lib/lua/luci/model/cbi/streambypass/*.lua $(1)/usr/lib/lua/luci/model/cbi/streambypass/
endef

$(eval $(call BuildPackage,luci-app-streambypass))
