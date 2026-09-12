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

SHELLCMD_PY_RELPATH:=submodules/shellcmd.py/shellcmd.py
SHELLCMD_PY_REALPATH:=$(realpath $(SHELLCMD_PY_RELPATH))
ifeq ($(strip $(SHELLCMD_PY_REALPATH)),)
$(error $(SHELLCMD_PY_RELPATH) not found. Are submodules missing?)
endif

SHELLCMD:=$(PYTHON) "$(SHELLCMD_PY_REALPATH)"
BUILD:=$(abspath ./build)

##########################################################################
##########################################################################

.PHONY:build
build: _folders
	$(_V)$(PYTHON) "bin/glyphs_data.py" > "$(BUILD)/glyphs_data.generated.s65"

	$(_V)$(MAKE) _build MODEL=b
	$(_V)$(MAKE) _build MODEL=bplus
	$(_V)$(MAKE) _build MODEL=master

	$(_V)$(SHELLCMD) mkdir "$(BUILD)/16" "$(BUILD)/32" "$(BUILD)/64" "$(BUILD)/128"
	$(_V)$(PYTHON) "bin/duplicate_roms.py" -o "$(BUILD)" -n 16 -n 32 "$(BUILD)/beeb_test_os.b*.bin"
	$(_V)$(PYTHON) "bin/duplicate_roms.py" -o "$(BUILD)" -n 32 "$(BUILD)/beeb_test_os.master.bin"
	$(_V)$(PYTHON) "bin/duplicate_roms.py" -o "$(BUILD)" -n 64 "$(BUILD)/beeb_test_os.b*.bin" "$(BUILD)/beeb_test_os.master.bin"
	$(_V)$(PYTHON) "bin/duplicate_roms.py" -o "$(BUILD)" -n 128 "$(BUILD)/beeb_test_os.master.bin"

	$(_V)$(SHELLCMD) rm-file -f "$(BUILD)/multios.bin"

.PHONY:_build
_build: _STEM:=beeb_test_os.$(MODEL)
_build:
	$(_V)$(TASS) "src/beeb_test_os.s65" -Dmodel_$(MODEL)=true $(if $(BUILD_SUFFIX),-Dbuild_suffix="$(BUILD_SUFFIX)") $(if $(ENABLE_TEST_HARDWARE),-Denable_test_hardware=true) "--list=$(BUILD)/$(_STEM).lst" "--output=$(BUILD)/$(_STEM).bin"

# .PHONY:_build_master
# _build_master: _STEM:=beeb_test_os.master$(SUFFIX)
# _build_master:
# 	$(_V)$(TASS) beeb_test_os.s65 --m65c02 -Dmodel_master=true -Dmaster_first_sideways_ram_bank=$(FIRST) -Dmaster_num_sideways_ram_banks=$(NUM) "--list=$(BUILD)/$(_STEM).lst" "--output=$(BUILD)/$(_STEM).bin"

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

# The tom_ targets run on my computer.

.PHONY:tom_laptop
tom_laptop: _CURL:=curl --no-progress-meter --fail-with-body
tom_laptop: _URL:=http://localhost:48075
tom_laptop: _CURLAPI:=$(_CURL) "$(_URL)/api" -H "Content-Type: application/json"
tom_laptop:
	$(_V)$(MAKE) build # ENABLE_TEST_HARDWARE=1
#	$(_V)$(_CURL) --connect-timeout 0.25 -G "http://localhost:48075/reset/b2" --data-urlencode "config=B+128 (Test OS)"
#	$(_V)$(_CURL) --connect-timeout 0.25 -G "http://localhost:48075/reset/b2" --data-urlencode "config=Master 128 (Test OS)"
#	$(_V)$(_CURL) --connect-timeout 0.25 -G "http://localhost:48075/reset/b2" --data-urlencode "config=B (Test OS)"

	$(_V)$(_CURL) "$(_URL)/api-set-globals/b2" --data-urlencode "read_path=$(shell $(SHELLCMD) realpath .)"
#	$(_V)$(_CURLAPI) --data-binary "@etc/b2/b.json"
	$(_V)$(_CURLAPI) --data-binary "@etc/b2/bplus.json"
#	$(_V)$(_CURLAPI) --data-binary "@etc/b2/m128.json"

##########################################################################
##########################################################################

.PHONY:tom_megarom
tom_megarom:
	$(_V)$(MAKE) build
	$(_V)$(SHELLCMD) split -b 131072 "../mos320/orig/multios/multios.bin" "$(BUILD)/multios"
	$(_V)$(SHELLCMD) concat -o "$(BUILD)/multios.bin" "$(BUILD)/multios0" "$(BUILD)/128/beeb_test_os.master.bin" "$(BUILD)/multios2" "$(BUILD)/multios3" 

##########################################################################
##########################################################################

# The ci_ targets run on the CI server, so Linux only.

.PHONY:ci_install_prerequisites
ci_install_prerequisites:
	sudo apt-get update
	sudo apt-get install -y subversion

.PHONY:ci_build_64tass
ci_build_64tass:
	svn checkout -r 3120 https://svn.code.sf.net/p/tass64/code/trunk "$(HOME)/tass64-code"
	cd "$(HOME)/tass64-code" && make -j$(nproc)

.PHONY:ci_build_rom
ci_build_rom:
	$(MAKE) VERBOSE=1 BUILD_SUFFIX="$(shell $(SHELLCMD) git-build-suffix)"

.PHONY:ci_make_release
ci_make_release: _COMMIT:=$(shell git log -1 '--format=%H')
ci_make_release: _NAME:=$(shell $(SHELLCMD) git-build-suffix)
ci_make_release: _ZIP:=beeb_test_os.$(_NAME).zip
ci_make_release: _README_URL:=https://github.com/tom-seddon/beeb_test_os/blob/$(_COMMIT)/README.md
ci_make_release:
	$(SHELLCMD) git-build-suffix --fail-when-dirty-working-copy >/dev/null
	cd "$(BUILD)" && echo "See $(_README_URL)" > README.txt
	cd "$(BUILD)" && zip -9r "$(_ZIP)" 16 32 64 128 README.txt
	gh release create "$(_NAME)" --notes "$(_README_URL)"
	gh release upload "$(_NAME)" "$(BUILD)/$(_ZIP)"
