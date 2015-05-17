#ReInit
rm -f log1
rm -f log2
rm -f log3
rm -f log4
rm -f log5
rm -f log6
rm -f log7
rm -f log8
rm -f log8b
rm -f log9
rm -f $HOME/.logdb
#Hexa non visible
../build/logappend -T 0 -K secret -A -G Jane log1
../build/logappend -T 2 -K secret -A -E Fred log1
../build/logappend -T 3 -K secret -A -G John log1

#Hexa non visible
../build/logappend -T 0 -K secret -A -G Jane log2
../build/logappend -T 2 -K secret -A -E Fred log2
../build/logappend -T 3 -K secret -A -G John log2

#Hexa non visible
../build/logappend -T 1 -K secret -A -G Jane log3
../build/logappend -T 2 -K secret -A -E Fred log3
../build/logappend -T 3 -K secret -A -G John log3

#Hexa non visible
../build/logappend -T 1 -K secret -A -G Jane log4
../build/logappend -T 2 -K secret -A -E Fred log4
../build/logappend -T 4 -K secret -A -G John log4

#Hexa visible
../build/logappend -T 0 -K secret0 -A -G Jane log5
../build/logappend -T 2 -K secret0 -A -E Fred log5
../build/logappend -T 3 -K secret0 -A -G John log5

#Hexa non visible
../build/logappend -T 0 -K secret -A -G Jane log6
../build/logappend -T 2 -K secret -A -E Fred log6
../build/logappend -T 3 -K secret -A -G John log6

#Hexa non visible
../build/logappend -T 0 -K secrets1 -A -G Jane log7
../build/logappend -T 2 -K secrets1 -A -E Fred log7
../build/logappend -T 3 -K secrets1 -A -G John log7

#Hexa visible
../build/logappend -T 0 -K 000 -A -G Jane log8
../build/logappend -T 2 -K 000 -A -E Fred log8
../build/logappend -T 3 -K 000 -A -G John log8

#Hexa non visible
../build/logappend -T 0 -K 0001 -A -G Jane log8b
../build/logappend -T 2 -K 0001 -A -E Fred log8b
../build/logappend -T 3 -K 0001 -A -G John log8b

#Hexa visible
../build/logappend -T 0 -K 001 -A -G Jane log9
../build/logappend -T 2 -K 001 -A -E Fred log9
../build/logappend -T 3 -K 001 -A -G John log9