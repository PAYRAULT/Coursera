#ReInit
rm -f log1
rm -f $HOME/.logdb

#Order of argument
../build/logappend -T 0 -K secret0 -A -G Fred log1
../build/logappend -T 1 -K secret0 -G Jane -A log1
../build/logread -K secret0 -S log1



