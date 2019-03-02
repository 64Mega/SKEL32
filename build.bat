@ECHO OFF
REM Set up some compiler switches
REM Brief explanation:
REM  -zq : Quiet mode. Turns off verbose logging.
REM  -zdp : Not really necessary, but here for safety.
REM  -wcd=138 : Turn this off if you love getting -error- messages about not having a newline at the
REM             end of a file. This supresses that error.
REM  -ecc : Enables CDECL calling convention instead of Watcom's WATCALL.
REM  -4s : Generate 386 instructions optimized for the 486, use stack call convention.
REM  -mf : Use the FLAT memory model
REM  -fp3 : Generate floating point instructions optimized for the 80387 FPU
REM  -od : Disable optimizations. When you want to make a release build, try out -ox instead

SET WCL386=-zq -zdp -wcd=138 -ecc -4s -mf -fp3 -od

REM Now process all the assembly files in the project.
REM To add more, just add a duplicate line with the output and inputs changed.
NASM skel32\video.asm -fobj -o obj\video.obj
NASM skel32\keyboard.asm -fobj -o obj\keyboard.obj

REM Pause here to allow you to process any error messages from the assembler
PAUSE

REM Now we compile our C source
WCL386 main.c -c -fo=obj\main.obj

REM Check for error files and stop if we find any
IF EXIST *.ERR GOTO CompilerError
GOTO CompilerOK

:CompilerError
    ECHO COMPILATION FAILED: ERRORS FOUND!
    ECHO =-------------------------------=
    ECHO List of error files:
    DIR
    GOTO EndOfBatch

:CompilerOK
    REM Link the EXE
    ECHO Compilation OK
    ECHO =------------=
    WCL386 obj\*.obj -fe=GAME.EXE

ECHO Done!

:EndOfBatch