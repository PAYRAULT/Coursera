#ReInit
rm -f log1
rm -f .logdb

#Order of argument
../build/logappend -T 1 -K secret0 -A -G Fred log1
../build/logappend -T 2 -K secret0 -G Jane -A log1
../build/logappend -T 3 -K secret0 -A -E Toto log1
../build/logread -K secret0 -S log1

#ReInit
rm -f log1
rm -f .logdb
../build/logappend -T 1 -K secret -A -E Fred log1
../build/logappend -T 2 -K secret -A -E Fred -R 1 log1
../build/logappend -T 5 -K secret -L -E Fred -R 1 log1
../build/logappend -T 6 -K secret -A -E Fred -R 2 log1
../build/logappend -T 7 -K secret -L -E Fred -R 2 log1
../build/logappend -T 8 -K secret -A -E Fred -R 3 log1
../build/logappend -T 9 -K secret -L -E Fred -R 3 log1
../build/logappend -T 10 -K secret -A -E Fred -R 1 log1
../build/logread -K secret -R -E Fred log1
