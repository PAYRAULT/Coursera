#ReInit
rm -f log1
rm -f .logdb

../build/logappend -T 1 -K secret -A -G Jane log1
../build/logappend -T 2 -K secret -A -E Fred log1
../build/logappend -T 3 -K secret -A -G John log1
../build/logappend -T 4 -K secret -A -G John -R 12 log1
../build/logappend -T 6 -K secret -A -E Fred -R 12 log1
../build/logappend -T 7 -K secret -L -E Fred -R 12 log1
../build/logappend -T 8 -K secret -A -E Fred -R 14 log1
../build/logread -K secret -S log1
../build/logread -K secret -E Fred -R log1

#Invalid secret
../build/logread -K secret1234567890 -S log1
#Invalid argument
../build/logread -V secret -S log1
../build/logread -K secret -E Fred -G Jane -R log1
../build/logread -K secret -E Fred -E Jane -R log1
../build/logread -K secret -G Fred -G Jane -R log1


