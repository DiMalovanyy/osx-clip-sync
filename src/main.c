#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/extensions/Xfixes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to get the clipboard content
void get_clipboard_content(Display *display, Window window) {
    Atom clipboard = XInternAtom(display, "CLIPBOARD", False);
    Atom targets = XInternAtom(display, "TARGETS", False);
    Atom utf8 = XInternAtom(display, "UTF8_STRING", False);
    Atom type;
    int format;
    unsigned long num_items, bytes_after;
    unsigned char *data = NULL;

    // Request the clipboard owner to convert the clipboard to UTF8_STRING
    XConvertSelection(display, clipboard, utf8, clipboard, window, CurrentTime);
    XFlush(display);

    // Wait for the SelectionNotify event
    XEvent event;
    do {
        XNextEvent(display, &event);
    } while (event.type != SelectionNotify);

    if (event.xselection.property) {
        XGetWindowProperty(display, window, clipboard, 0, ~0, False, utf8,
                           &type, &format, &num_items, &bytes_after, &data);
        if (type == utf8) {
            printf("Clipboard updated: %.*s\n", (int)num_items, data);
        } else {
            printf("Clipboard content is not UTF-8\n");
        }
        if (data)
            XFree(data);
    } else {
        printf("Failed to retrieve clipboard content\n");
    }
}

int main() {
    Display *display = XOpenDisplay(NULL);
    if (!display) {
        fprintf(stderr, "Failed to open X display\n");
        return EXIT_FAILURE;
    }

    int event_base, error_base;
    if (!XFixesQueryExtension(display, &event_base, &error_base)) {
        fprintf(stderr, "XFixes extension not supported\n");
        XCloseDisplay(display);
        return EXIT_FAILURE;
    }

    // Create a dummy window to receive events
    Window window = XCreateSimpleWindow(display, DefaultRootWindow(display),
                                        0, 0, 1, 1, 0, 0, 0);

    XFixesSelectSelectionInput(display, window, XInternAtom(display, "CLIPBOARD", False),
                               XFixesSetSelectionOwnerNotifyMask);

    printf("Monitoring clipboard changes...\n");

    while (1) {
        XEvent event;
        XNextEvent(display, &event);

        if (event.type == event_base + XFixesSelectionNotify) {
            XFixesSelectionNotifyEvent *fixes_event = (XFixesSelectionNotifyEvent *)&event;
            if (fixes_event->selection == XInternAtom(display, "CLIPBOARD", False)) {
                get_clipboard_content(display, window);
            }
        }
    }

    XDestroyWindow(display, window);
    XCloseDisplay(display);
    return EXIT_SUCCESS;
}
