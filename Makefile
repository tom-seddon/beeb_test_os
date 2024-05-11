# -*- mode:makefile-gmake; -*-

ifeq ($(OS),Windows_NT)
PYTHON:=py -3
TASSCMD:=bin\64tass.exe
else
PYTHON:=/usr/bin/python3
TASSCMD:=64tass
endif

##########################################################################
##########################################################################

ifeq ($(VERBOSE),1)
_V:=
_TASSQ:=
else
_V:=@
_TASSQ:=-q
endif

TASS:="$(TASSCMD)" --m65xx -C -Wall --line-numbers $(_TASSQ) --verbose-list --long-branch
SHELLCMD:=$(PYTHON) $(realpath submodules/shellcmd.py/shellcmd.py)
BUILD:=$(abspath ./build)

##########################################################################
##########################################################################

.PHONY:build
build: _folders
	$(_V)$(PYTHON) glyphs_data.py > "$(BUILD)/glyphs_data.generated.s65"
	$(_V)$(TASS) beeb_test_os.s65 --nostart "--list=$(BUILD)/beeb_test_os.lst" "--output=$(BUILD)/beeb_test_os.bin"

##########################################################################
##########################################################################

.PHONY:_folders
_folders:
	$(_V)$(SHELLCMD) mkdir "$(BUILD)"

##########################################################################
##########################################################################

.PHONY:clean
clean:
	$(_V)$(SHELLCMD) rm-tree "$(BUILD)"

##########################################################################
##########################################################################

.PHONY:tom_laptop
tom_laptop: _CURL:=curl --no-progress-meter
tom_laptop:
	$(_V)$(MAKE) build
	$(_V)$(_CURL) --connect-timeout 0.25 -G "http://localhost:48075/reset/b2" --data-urlencode "config=B+128 (Test OS)"
