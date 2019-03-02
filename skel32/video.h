#ifndef VIDEO_H
#define VIDEO_H

// Some basic video routines, including a wait-for-retrace function and an example
// of drawing a pixel in assembly. Note that just directly poking single pixels into memory
// will be faster in the long run than calling this single assembly routine, due to
// function call overhead. 

extern void             vid_setmode(unsigned char mode);
extern unsigned char    vid_getmode();
extern void             vid_wait_retrace();
extern void             vid_draw_pixel(int x, int y, int color);

#endif