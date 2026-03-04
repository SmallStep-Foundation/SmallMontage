# GNUmakefile for SmallMontage (Linux/GNUstep)
#
# Non-linear video editor with multiple video and audio tracks.
# Uses SmallStepLib for app lifecycle, menus, window style, and file dialogs.
# Uses MLT (Media Lovin' Toolkit) for playback and export.
#
# Dependencies:
#   - Build SmallStepLib first: cd ../SmallStepLib && make && make install
#   - MLT development: sudo apt-get install libmlt-dev (Debian/Ubuntu)
#     or install MLT from https://www.mltframework.org/
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallMontage

SmallMontage_OBJC_FILES = \
	main.m \
	App/SMAppDelegate.m \
	Core/SMProject.m \
	Core/SMTrack.m \
	Core/SMClip.m \
	Core/SMEngine.m \
	UI/SMMainWindow.m \
	UI/SMTimelineView.m

SmallMontage_HEADER_FILES = \
	App/SMAppDelegate.h \
	Core/SMProject.h \
	Core/SMTrack.h \
	Core/SMClip.h \
	Core/SMEngine.h \
	UI/SMMainWindow.h \
	UI/SMTimelineView.h

SmallMontage_C_FILES = Core/SMEngineBridge.c

SmallMontage_INCLUDE_DIRS = \
	-I. \
	-IApp \
	-ICore \
	-IUI \
	-I../SmallStepLib/SmallStep/Core \
	-I../SmallStepLib/SmallStep/Platform/Linux

# MLT: try pkg-config first, then common install paths. If not found, build with stub (no preview/export).
MLT_CFLAGS := $(shell pkg-config --cflags mlt-7 2>/dev/null)
MLT_LIBS   := $(shell pkg-config --libs mlt-7 2>/dev/null)
ifeq ($(MLT_CFLAGS),)
  MLT_CFLAGS = $(shell test -f /usr/include/mlt/framework/mlt.h && echo -I/usr/include/mlt -DHAVE_MLT)
  MLT_LIBS = $(shell test -f /usr/include/mlt/framework/mlt.h && echo -lmlt-7)
endif
ifeq ($(MLT_LIBS),)
  MLT_CFLAGS =
  MLT_LIBS =
endif

SmallMontage_ADDITIONAL_CFLAGS = $(MLT_CFLAGS)

SMALLSTEP_FRAMEWORK := $(shell find ../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

SmallMontage_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base -lpthread
SmallMontage_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallMontage_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep $(MLT_LIBS) -lpthread
SmallMontage_TOOL_LIBS = -lSmallStep $(MLT_LIBS) -lobjc

include $(GNUSTEP_MAKEFILES)/application.make
