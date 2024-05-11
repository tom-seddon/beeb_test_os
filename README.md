Test OS for diagnosing basic problems with BBC B/B+/Master.

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

The output is six 16 KB ROMs. There are 3 standard versions

* `build/beeb_test_os.b.bin` - BBC B/B+/B+128 version (tests 32 KB main RAM)
* `build/beeb_test_os.bplus.bin` - BBC B+ version (tests 64 KB RAM)
* `build/beeb_test_os.master.bin` - BBC Master version (tests 128 KB RAM)

There are 3 additional BBC Master versions, that test some subset of
the onboard sideways RAM banks. You might want to use these if you
have paged ROMs installed that are blocking access to the sideways
RAM.

* `build/beeb_test_os.master.sw45.bin` - tests banks 4 and 5 only
* `build/beeb_test_os.master.sw67.bin` - tests banks 6 and 7 only
* `build/beeb_test_os.master.swno.bin` - does not test sideways RAM

# Installation

Write to EPROM (or similar) and insert in OS ROM socket.

# Use

You'll need a functioning keyboard and system VIA. The system ideally
needs to be able to produce a display of some kind - some basic
testing is posible without (the keyboard LEDs do show some
information) but you don't get much info that way.

If you are directed to "tap" a key, that means the action will
not occur until the key is released.

Some tests are marked as not using RAM: this means these tests don't
need functioning RAM to operate. Other tests rely on RAM behaving
properly and there may be spurious errors if not.

Power on BBC Micro.

On startup, the test OS does 5 writes of $00 to address $0000, does
some minimal system initialisation (including attempting to silence
the sound), then does 10 writes of $00 to address $0000. (If following
along, watch CPU A15 and CPU A8 - all other writes on startup should
be to the I/O region and the stack.)

If this is a power-on reset, it selects mode 7.

Then it enters its its "UI", indicated by alternately flashing caps
lock and shift lock LEDs.

You can tap the following keys:

- 0, 4, 7 :: select display mode and wait for another option

- E :: show Ceefax engineering test page and wait for another option

- M :: main memory test

- M (while holding shift) :: main memory test with ignore bits

- B :: visual bits test

- X :: main memory test failure example display

## Main memory test (doesn't use RAM)

Lights both LEDs and constantly fills memory with a series of
patterns, checking the values didn't change when read back. You should
see a bunch of patterns on screen as it runs. The test runs itself,
and if there's an error, it will switch to Mode 7, switch the LEDs
off, and print a report.

The error report consists of two rows of large text. The first row
shows the problem address (4 or 5 hex digits - see below), and the
second row is a mask indicating which bits were found to be incorrect
(2 hex digits).

This does not use RAM for the test, but RAM is necessarily used to
display the report. The report is intended to be somewhat resistant to
stuck bits or noise, but no guarantees.

### Memory test addresses

Addresses shown on BBC B will be 4 digits, 0000-7fff, indicating the
problem address in main RAM.

For B+, the 4-digit addresses relate to the CPU addresses as follows:

| Addresses | Region |
| --- | --- |
| 0000-7fff | 32 KB main RAM |
| 8000-afff | 12 KB extra B+ RAM |
| b000-ffff | 20 KB shadow RAM |

For Master, the 5-digit addresses are as follows:

| Addresses | Region |
| --- | --- |
| 00000-07fff | 32 KB main RAM |
| 08000-08fff | 4 KB ANDY |
| 09000-0afff | 8 KB HAZEL |
| 0b000-0ffff | 20 KB shadow RAM |
| 48000-4bfff | 16 KB sideways RAM bank 4 (if tested) |
| 58000-5bfff | 16 KB sideways RAM bank 5 (if tested) |
| 68000-6bfff | 16 KB sideways RAM bank 6 (if tested) |
| 78000-7bfff | 16 KB sideways RAM bank 7 (if tested) |

## Main memory test with ignore bits (doesn't use RAM)

As main memory test, but you can use the mask printed by the main
memory test to indicate which bits to ignore, to see if the memory
test passes if those bits are ignored.

When the test starts, both LEDs are off, indicating it's waiting for
you to enter the mask for the bad bits. Enter it as two hex digits, as
shown by the main memory test. The caps lock LED will light up after
the first digit is entered, then shift lock after the second (but
hopefully you'll see the test run so it'll be obvious).

If a failure report is printed, the values of the ignored bits are
treated as matching, and you will have to manually figure out what the
combined mask for further tests should be. Apologies!

## Visual bits test (doesn't use RAM)

Writes a configurable value - initially zero - to all 32 KB of main
RAM, so you can see the effect on screen. (This only affects main RAM.
Extra RAM on B+ or Master is not filled.)

Tap F to refill memory with the existing value.

Tap 0, 1, 2, 3, 4, 5, 6 or 7 to toggle that bit in the fill value.

Tap 8 to fill memory with $00.

Tap 9 to fill memory with $ff.

In mode 0 or 4, tap SPACE to adjust the screen address. (The start
address in mode 7 is fixed.) The address is indicated by the caps
lock/shift lock LEDs:

| Caps | Shift | Base |
| --- | --- | --- |
| off | off | $0000 |
| off | on | $2000 |
| on | off | $4000 |
| on | on | $6000 |
  
If the screen wraps round (e.g., displaying Mode 0 starting at $4000),
the flashing cursor indicates where the wraparound back to $3000
occurred. The wraparound size is always 20 KB.

## Ceefax engineering test page

Selects mode 7 and shows the Ceefax engineering test page.

## Main memory test failure example display

Shows an example of the memory test failure display, so you can double
check it'll be readable. The address and mask shown are meaningless.
