include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-openvohive
PKG_VERSION?=2.0.2
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=Open-VoHive
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-openvohive
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for Open-VoHive
  DEPENDS:=+luci-base +rpcd +rpcd-mod-file +curl +ca-bundle +jsonfilter
  PKGARCH:=all
endef

define Package/luci-app-openvohive/description
  LuCI management page for Open-VoHive 4G/5G module manager.
  Provides service control, status monitoring, log viewing and basic configuration.
endef

define Build/Compile
endef

define Package/luci-app-openvohive/conffiles
/etc/config/openvohive
endef

define Package/luci-app-openvohive/install
	$(CP) ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/share/openvohive
	echo "$(PKG_VERSION)" > $(1)/usr/share/openvohive/plugin_version
endef

define Package/luci-app-openvohive/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	mkdir -p /opt/openvohive/config /opt/openvohive/data /tmp/openvohive
	if [ -x /etc/init.d/rpcd ]; then
		/etc/init.d/rpcd reload >/dev/null 2>&1 || /etc/init.d/rpcd restart >/dev/null 2>&1 || true
	fi
}
exit 0
endef

$(eval $(call BuildPackage,luci-app-openvohive))
