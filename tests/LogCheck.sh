#ReInit
rm -f log1
rm -f log2
rm -f log3
rm -f log4
rm -f log5
rm -f log6
rm -f $HOME/.logdb
../build/logappend -T 0 -K secret -A -G Jane log1
../build/logappend -T 2 -K secret -A -E Fred log1
../build/logappend -T 3 -K secret -A -G John log1

../build/logappend -T 0 -K secret -A -G Jane log2
../build/logappend -T 2 -K secret -A -E Fred log2
../build/logappend -T 3 -K secret -A -G John log2

../build/logappend -T 1 -K secret -A -G Jane log3
../build/logappend -T 2 -K secret -A -E Fred log3
../build/logappend -T 3 -K secret -A -G John log3

../build/logappend -T 1 -K secret -A -G Jane log4
../build/logappend -T 2 -K secret -A -E Fred log4
../build/logappend -T 4 -K secret -A -G John log4

../build/logappend -T 0 -K secret0 -A -G Jane log5
../build/logappend -T 2 -K secret0 -A -E Fred log5
../build/logappend -T 3 -K secret0 -A -G John log5

../build/logappend -T 0 -K secret1 -A -G Jane log6
../build/logappend -T 2 -K secret1 -A -E Fred log6
../build/logappend -T 3 -K secret1 -A -G John log6