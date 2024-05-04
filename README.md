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

Some tests are marked as not using RAM: these tests don't need
functioning CPU access to RAM to operate. All other tests rely on RAM
behaving properly and there may be spurious errors if not.

Power on BBC Micro.

After initial bootup, the test OS switches off the keyboard LEDs and
then does nothing obvious. It's waiting for input.

You can tap the following keys:

- Caps Lock/Shift Lock - toggle both caps lock/shift lock LEDs

- M - memory test of the 32 KB of main RAM. This runs in mode 0,
  constantly filling main RAM with a series of patterns and checking
  the values didn't change when read back. You should see a bunch of
  patterns on screen as it runs. The test runs itself, and if there's
  an error, it will stop with a report.
  
  This test does not use RAM

- 0 - clear main RAM to all $00, select Mode 7, and go into infinite
  loop of reading all of main RAM. This doesn't perform any checks on
  the values read; it's intended for use with a logic analyzer, which
  should report nothing but 0s read from the DRAM.
  
  The test reads $0000, $0100, $0200 ... $7f00, then $0001, $0101 -
  and so on. 
  
  This test does not use RAM
  
