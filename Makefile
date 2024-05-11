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

TASS:="$(TASSCMD)" -C -Wall --line-numbers $(_TASSQ) --verbose-list --long-branch --nostart
SHELLCMD:=$(PYTHON) $(realpath submodules/shellcmd.py/shellcmd.py)
BUILD:=$(abspath ./build)

##########################################################################
##########################################################################

.PHONY:build
build: _folders
	$(_V)$(PYTHON) glyphs_data.py > "$(BUILD)/glyphs_data.generated.s65"
	$(_V)$(TASS) beeb_test_os.s65 --m65xx -Dmodel_b=true "--list=$(BUILD)/beeb_test_os.b.lst" "--output=$(BUILD)/beeb_test_os.b.bin"
	$(_V)$(TASS) beeb_test_os.s65 --m65xx -Dmodel_bplus=true "--list=$(BUILD)/beeb_test_os.bplus.lst" "--output=$(BUILD)/beeb_test_os.bplus.bin"
	$(_V)$(MAKE) _build_master FIRST=4 NUM=4 SUFFIX=
	$(_V)$(MAKE) _build_master FIRST=4 NUM=2 SUFFIX=.sw45
	$(_V)$(MAKE) _build_master FIRST=6 NUM=2 SUFFIX=.sw67
	$(_V)$(MAKE) _build_master FIRST=0 NUM=0 SUFFIX=.swno

.PHONY:_build_master
_build_master: _STEM=beeb_test_os.master$(SUFFIX)
_build_master:
	$(_V)$(TASS) beeb_test_os.s65 --m65c02 -Dmodel_master=true -Dmaster_first_sideways_ram_bank=$(FIRST) -Dmaster_num_sideways_ram_banks=$(NUM) "--list=$(BUILD)/$(_STEM).lst" "--output=$(BUILD)/$(_STEM).bin"

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
#	$(_V)$(_CURL) --connect-timeout 0.25 -G "http://localhost:48075/reset/b2" --data-urlencode "config=B+128 (Test OS)"
	$(_V)$(_CURL) --connect-timeout 0.25 -G "http://localhost:48075/reset/b2" --data-urlencode "config=Master 128 (Test OS)"
