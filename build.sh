#!/bin/bash
#----------------------------------------
#Put your program name in place of "DEMO"
name='NOTI.rom'
#----------------------------------------

mkdir -p bin

echo "compiling to $name"
./fasmg src/main.asm bin/$name

read -p "Finished. Press any key to exit"
