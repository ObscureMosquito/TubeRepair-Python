TARGET := iphone:clang:latest:3.0
export TARGET=iphone:clang:3.0
ARCHS= armv6 armv7

INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TubeRepair-Tweak

TubeRepair-Tweak_FILES = Tweak.x
TubeRepair-Tweak_FRAMEWORKS = UIKit Foundation
TubeRepair-Tweak_CFLAGS = -Wno-deprecated-declarations -Wno-format

include $(THEOS_MAKE_PATH)/tweak.mk
