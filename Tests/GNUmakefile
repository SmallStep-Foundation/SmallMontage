#
# SmallMontage unit tests
# Build from SmallMontage: make -f Tests/GNUmakefile
# Run: ./Tests/obj/test_SmallMontage
#

include $(GNUSTEP_MAKEFILES)/common.make

SMALLSTEP_FRAMEWORK := $(shell find ../../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

MLT_CFLAGS := $(shell pkg-config --cflags mlt-7 2>/dev/null)
MLT_LIBS   := $(shell pkg-config --libs mlt-7 2>/dev/null)
ifeq ($(MLT_CFLAGS),)
  MLT_CFLAGS = $(shell test -f /usr/include/mlt/framework/mlt.h && echo -I/usr/include/mlt -DHAVE_MLT)
  MLT_LIBS = $(shell test -f /usr/include/mlt/framework/mlt.h && echo -lmlt-7)
endif

TOOL_NAME = test_SmallMontage
test_SmallMontage_OBJC_FILES = SmallMontageTests.m ../App/SMAppDelegate.m ../Core/SMProject.m ../Core/SMTrack.m ../Core/SMClip.m ../Core/SMEngine.m ../UI/SMMainWindow.m ../UI/SMTimelineView.m
test_SmallMontage_C_FILES = ../Core/SMEngineBridge.c
test_SmallMontage_INCLUDE_DIRS = -I.. -I../App -I../Core -I../UI
test_SmallMontage_INCLUDE_DIRS += -I../../SmallStepLib/SmallStep/Core -I../../SmallStepLib/SmallStep/Platform/Linux -I../../SmallStepLib/Tests
test_SmallMontage_INCLUDE_DIRS += $(MLT_CFLAGS)
test_SmallMontage_ADDITIONAL_CFLAGS = $(MLT_CFLAGS)
test_SmallMontage_TOOL_LIBS = -lSmallStep -lgnustep-gui -lgnustep-base -lobjc $(MLT_LIBS) -lpthread
test_SmallMontage_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined

before-all::
	$(MAKE) -C ../../SmallStepLib
	$(MAKE) -C ..

include $(GNUSTEP_MAKEFILES)/tool.make
