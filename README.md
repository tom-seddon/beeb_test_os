Test OS ROM for basic diagnosis of RAM problems on a BBC B/B+/Master
that's too broken to boot the OS as normal.

# Installation

Download ZIP file for latest release: https://github.com/tom-seddon/beeb_test_os/releases/latest

Unzip somewhere.

The ZIP file contains multiple ROM images, organized in folders named
after the ROM size in KB. Pick the right one according to system of
interest and size of PROM you have to hand (see list below).

Program ROM and insert in specified socket.

## BBC B

- `16/beeb_test_os.b.bin`
- `32/beeb_test_os.b.bin`
- `64/beeb_test_os.b.bin`

Insert ROM in socket IC51.

## BBC B+/BBC B+128

(Note that the B+128 sideways RAM is not tested. Sorry!)

- `16/beeb_test_os.bplus.bin`
- `32/beeb_test_os.bplus.bin`
- `64/beeb_test_os.bplus.bin`

Insert ROM in socket IC71.

## Master Compact/Olivetti PC 128 S

- `64/beeb_test_os.master.bin`

Insert ROM in socket IC49.

## Master 128

- `128/beeb_test_os.master.bin`

The MOS ROM socket is IC24. 28-pin 1 Mbit PROMs don't exist; you'll
need an 32-pin PROM with an adapter (e.g.,
https://mdfs.net/Info/Comp/BBC/SROMs/MegaROM.htm), or one of the
commonly available switchable flash ROM MOS devices.

# Use

You'll need a functioning keyboard and system VIA. The system ideally
needs to be able to produce a display of some kind - some basic
testing is posible without (the keyboard LEDs do show some
information) but you don't get much info that way.

If you are directed to "tap" a key, that means the action will
not occur until the key is released.

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

- `0`, `4`, `7` - select display mode and wait for another option

- `2`, `8` - select mode 2/"mode 8", display colour test screen (see
  below), and wait for another option

- `E` - show Ceefax engineering test page and wait for another option

- `M` - memory test

- `M` (while holding shift) - memory test with options

- `B` - visual bits test

- `X` - main memory test failure example display

## Main memory test failure example display

Shows an example of the memory test failure display. (The address and
mask shown are meaningless.)

Should look like this Mode 7: [./mode_7_failure.png](./mode_7_failure.png)

Should look like this otherwise:
[./mode_4_failure.png](./mode_4_failure.png) (this is a bitmap Mode 4
display, not using the teletext-style addressing mode)

## Ceefax engineering test page

Selects mode 7 and shows the Ceefax engineering test page.

There's a PNG here to show you what to expect:
[./engtest.png](./engtest.png).

## Colour test screen

Selects mode 2 or "mode 8" (80x256, 16 colours) and displays a colour
test card. The screen is divided into 8 rows, showing the standard 8
BBC colours in the standard order: from top to bottom, black, red,
green, yellow, blue, magenta, cyan and white.

In both cases it should like this: [./colour_test_screen.png](./colour_test_screen.png)

## Memory test

Lights both LEDs and constantly fills memory with a series of
patterns, checking the values didn't change when read back. You should
see a bunch of patterns on screen as it runs. (If running in mode 0 or
2 on a B+/B+128, a flickering region on the display is normal.)

The test runs indefinitely, and if there's an error it will switch the
LEDs off and display a report. The report uses mode 7 if testing in
mode 7, or mode 4 if testing in another mode.

The error report consists of two rows of large text. The first row
shows the problem address (4 or 5 hex digits - see below), and the
second row is a mask indicating which bits were found to be incorrect
(2 hex digits).

The report is intended to be somewhat readable even if there are stuck
bits or noise, but no guarantees.

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

## Main memory test with options

As main memory test, but you get to choose some options.

Watch the caps lock and shift lock LEDs to see which option you're
selecting at each point, as follows:

### Memory refresh

Caps lock LED off, shift lock LED on.

Press `Y` to pause briefly (~1/6th sec) after each test, giving any
problems caused by faulty memory refresh a chance to reveal
themselves. This is the mode used by the ordinary memory test.

Press `L` to pause for longer (~1 sec) after each test, giving refresh
problems even more chance to show themselves.

Press `N` to test continuously. The continuous memory accesses should
serve to keep the memory refreshed, masking any problems.

### Memory region

Caps lock LED on, shift lock LED off.

Press a key to select the memory region to test. The memory is divided
up into regions corresponding to a group of ICs that you might want to
test separately.

On BBC B, the following regions can be tested:

- `A` - all of memory: &0000-&7FFF inclusive. This is the region
  tested by the ordinary memory test
- `L` - lower RAM: &0000-&3FFF inclusive
- `U` - upper RAM: &4000-&7FFF inclusive

For a BBC B+, there are no regions, as one set of ICs covers all of
memory. All 64 KB of main memory is always tested.

On Master, the following regions can be tested:

- `A` - all 128 KB of memory. This is the region tested by the
  ordinary memory test
- `M` - 64 KB of main memory only
- `S` - 64 KB of sideways RAM only
- `4` - 32 KB of sideways RAM only, banks 4 and 5
- `6` - 32 KB of sideways RAM only, banks 6 and 7

(Regions `4` and `6` are relevant for Master 128 only. You will need
to use these if you have the PCB links set to use the onboard ROM
sockets rather than sideways RAM.)

### Ignore mask

Caps lock LED off, shift lock LED off.

Allows you to specify which bits in memory are actually tested. Enter
an ignore mask: 2 hex digits, 1 bit set for each bit to be ignored
(probably because you suspect it's broken), more significant digit
first. The caps lock LED will light up once the first digit is
entered, and once the second is entered the memory test will start
straight away.

Each bit in the mask indicates that bit of memory should be ignored.
You can use the mask printed by a previous test.

The ordinary memory test uses a mask of `00`, so all bits are tested.

(Note that when a failure report is printed, the values of the ignored
bits are treated as matching, and you will have to manually figure out
what the combined mask for further tests should be. Apologies!)

## Visual bits test

Writes a configurable value - initially zero - to displayable RAM, so
you can see the effect on screen.

Tap F to refill memory with the existing value.

Tap 0, 1, 2, 3, 4, 5, 6 or 7 to toggle that bit in the fill value.

Tap 8 to fill memory with $00.

Tap 9 to fill memory with $ff.

On B+/Master, tap M to display main memory (the default) and S to
display shadow memory.

If not in mode 7, tap SPACE to adjust the screen address. (The start
address in mode 7 is fixed.) The address is indicated by the caps
lock/shift lock LEDs:

| Caps | Shift | Base |
| --- | --- | --- |
| off | off | $0000 |
| off | on | $2000 |
| on | off | $4000 |
| on | on | $6000 |
  
If the screen wraps round (e.g., displaying Mode 0 or 2 starting at
$4000), the flashing cursor indicates where the wraparound back to
$3000 occurred. The wraparound size is always 20 KB.

# Other testing tools

OS ROM replacements for use with completely dead BBC:

- Troubleshooting ROM: https://stardot.org.uk/forums/viewtopic.php?p=139467#p139467

- Diagnostic test ROM for BBC hardware: https://www.stardot.org.uk/forums/viewtopic.php?p=323010

Tools for use with BBC that at least boots to BASIC:

- MartinB's Memory Test Tool: https://stardot.org.uk/forums/viewtopic.php?t=14809

- BBC Micro memory tester (by me): https://github.com/tom-seddon/beeb_memory_tester/

# Build

The source is supplied and you can build it yourself on Windows,
macOS, Linux, and hopefully any other Unix type of system.

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

The output is multiple ROM images, as described above, in folders
inside `build`: `build/16` (16 KB ROMs), `build/32` (32 KB ROMs), and
so on.

# Licence

GPL v3. See [./gpl-3.0.txt](./gpl-3.0.txt).
