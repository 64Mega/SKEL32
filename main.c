// SKEL32 - DOS Development Quickstart
// Check for updates at https://github.com/64Mega/SKEL32

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <malloc.h>

#include "skel32/video.h"
#include "skel32/keyboard.h"

// Pointer to VGA memory
// Set pixels here if you want (E.G: VGA[100*320+64] = 0x0E puts a yellow pixel at 64,100)
// You have 320x200 to work with by default. If you want higher performance and aren't afraid
// at a bit of extra work, look into Mode X and Mode Y (Michael Abrash's Black Book of Graphics Programming
// has useful information on higher-performance VGA modes)

unsigned char* VGA = (unsigned char*) 0xA0000;

int main(void) {
    // Save old video mode
    unsigned old_mode = vid_getmode();
    int px = 160, py = 100;

    // Install new keyboard handler
    kbd_install();

    // Enter Mode13h
    vid_setmode(0x13);

    // Now we can do stuff!
    while(1) {
        if(KBD_KeyDown(KBD_LEFTARROW)) {
            px -= 1;
            if(px < 0) { px = 0; }
        }
        if(KBD_KeyDown(KBD_RIGHTARROW)) {
            px += 1;
            if(px > 319) { px = 319; }
        }
        if(KBD_KeyDown(KBD_UPARROW)) {
            py -= 1;
            if(py < 0) { py = 0; }
        }
        if(KBD_KeyDown(KBD_DOWNARROW)) {
            py += 1;
            if(py > 199) { py = 199; }
        }
        if(KBD_KeyDown(KBD_ESCAPE)) {
            break;
        }

        vid_wait_retrace();

        vid_draw_pixel(px, py, 0x0E);
    }

    // Restore old video mode
    vid_setmode(old_mode);
    // Restore keyboard handler
    kbd_uninstall();

    return(0);
}
