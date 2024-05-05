Test OS for diagnosing problems with BBC B/B+.

May also work on Master 128/Master Compact.

# Build

## Prerequisites

* Python 3.x

On Unix:

* [`64tass`](http://tass64.sourceforge.net/) (I use r3120)
* GNU Make

(Prebuilt Windows EXEs for 64tass and make are included in the repo.)

## git clone

This repo has submodules. Clone it with `--recursive`:

    git clone --recursive https://github.com/tom-seddon/beeb_test_os
	
Alternatively, if you already cloned it non-recursively, you can do
the following from inside the working copy:

    git submodule init
	git submodule update

(The code won't build without fiddling around if you download one of
the archive files from GitHub - a GitHub limitation. It's easiest to
clone it as above.)

## Build steps

Type `make` from the root of the working copy.

The build process is supposed to be silent when there are no errors.

The output is a 16 KB ROM: `build/beeb_test_os.bin`

# Installation

Write to EPROM (or similar) and insert in OS ROM socket.

# Use

If you are directed to "tap" a key, that means the action will
not occur until the key is released.

Some tests are marked as not using RAM: this means these tests don't
need functioning CPU access to RAM to operate. Other tests rely on RAM
behaving properly and there may be spurious errors if not.

Power on BBC Micro.

On startup, the test OS does 5 writes of $00 to address $0000, does
some minimal system initialisation, then does 10 writes of $00 to
address $0000. (If following along, watch CPU A15 and CPU A8 - all
other writes on startup should be to the I/O region.)

If this is a power-on reset, it selects mode 7.

Then it enters its its "UI", indicated by alternately flashing caps
lock and shift lock LEDs.

You can tap the following keys:

- 0, 4, 7 :: select display mode

- M :: main memory test

- C :: clear memory test

- P :: visual pattern test

- B :: visual bits test

## Main memory test (doesn't use RAM)

Constantly fills main RAM with a series of patterns, checking the
values didn't change when read back. You should see a bunch of
patterns on screen as it runs. The test runs itself, and if there's an
error, it will switch to Mode 7 and print a report.

This does not use RAM for the test. But RAM is used for displaying the
report, so if things are completely hosed then the report may be
readable or incorrect.

## Clear memory test (doesn't use RAM)

Clear main RAM to all $00, and go into infinite loop of reading all of
main RAM. This doesn't perform any checks on the values read; it's
intended for use with a logic analyzer, which should report nothing
but 0s read from the DRAM.
  
The test reads $0000, $0100, $0200 ... $7f00, then $0001, $0101 - and
so on.


## Visual pattern test (doesn't use RAM)

Writes a pattern to all 32 KB of main RAM, then shows it on screen.

Tap P to adjust the pattern.

Tap F to refill memory with the existing pattern.

Tap SPACE to adjust the screen address (see below).

## Visual bits test (doesn't use RAM)

Similar to the visual pattern test, but you can select the value
written.

Tap F to refill memory with the existing value.

Tap SPACE to adjust the screen address (see below).

Tap 0, 1, 2, 3, 4, 5, 6 or 7 to toggle that bit in the fill value.

Tap 8 to fill memory with $00.

Tap 9 to fill memory with $ff.

## Screen start address

Some tests let you select the screen start address when in mode 0 or
mode 4 (the mode 7 address is fixed). The start address is indicated
by the caps lock/shift lock LEDs.

| Caps | Shift | Base |
| --- | --- | --- |
| off | off | $0000 |
| off | on | $2000 |
| on | off | $4000 |
| on | on | $6000 |
  
If the screen wraps round (e.g., displaying Mode 0 starting at $4000),
the flashing cursor indicates where the wraparound back to $3000
occurred. (The wraparound size is always 20 KB.)
