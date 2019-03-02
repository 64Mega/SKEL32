## SKEL32 - DOS Development Boilerplate

SKEL32 is a quick-start for DOS development.

### Requirements
 - OpenWatcom compiler for DOS (Latest release)
 - NASM for DOS (Latest release)
 - DOSBox or alternative for testing

### Features
 - VGA Mode 13h initialization example
 - Keyboard ISR
 - Some handy assembly macros

### Setting up the Compiler & Assembler
You'll need to make sure that NASM and Watcom are on the path in your test environment. 
Make sure you got the DOS executables for both, and install them from inside your test environment (We're compiling and testing on DOS).

Watcom's installer automatically adds the neccessary paths to `AUTOEXEC.BAT`, but if you're testing in  DOSBox, you'll need to manually call `AUTOEXEC.BAT` from your DOSBox configuration (DOSBox doesn't do it automatically).

NASM will have to be manually added to the path, either inside `AUTOEXEC.BAT` or your DOSBox configuration.

To test, try running `nasm` and `wcl386`. If both return their usage information, you're ready to go.

### Compiling
Compilation should be as simple as navigating to the directory the project is in and running `build.bat`.
If you're running on actual hardware, a VM or FreeDOS, remove the `RESCAN` command from the batch file before compiling - this is a DOSBox-specific command that reloads files from the host before running any further commands.

#### Have fun!
