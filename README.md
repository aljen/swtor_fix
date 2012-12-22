Fix for Star Wars: The Old Republic to run on WINE
=========

WINE doesn't handle SW:TOR by default and needs a patch (http://bugs.winehq.org/show_bug.cgi?id=29168)
I wanted to use WINE from a repo without patching, so I implemented this small application to allow SW:TOR to work correctly.
All it does is waiting for swtor.exe to start up, takes his PID and launch two threads.
First thread simply waits for swtor.exe to end to do cleanup, the second one just updates KUSER_SHARED_DATA's time fields, so the game
network code just works as it should be and then copies those into swtor.exe process memory.

This code is based on original patch for WINE by Carsten Juttner & Xolotl Loki

How to:
- copy swtor_fix.exe to ~/.wine/drive_c
- run two terminals
- on first one, run:
$ WINEDEBUG=-all wine c:\swtor_fix.exe
- switch to second one and run:
$ WINEDEBUG=-all wine ~/.wine/drive_c/Program\ Files\ \(x86\)/Electronic\ Arts/BioWare/Star\ Wars\ -\ The\ Old\ Republic/launcher.exe

