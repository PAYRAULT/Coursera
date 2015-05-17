#ReInit
rm -f log1
rm -f $HOME/.logdb

../build/logappend -T 0 -K secret -A -G Jane log1
../build/logappend -T 1 -K secret -A -E Fred log1
../build/logappend -T 3 -K secret -A -G John log1
../build/logappend -T 4 -K secret -A -G John -R 12 log1
../build/logappend -T 6 -K secret -A -E Fred -R 12 log1
../build/logappend -T 7 -K secret -L -E Fred -R 12 log1
../build/logappend -T 8 -K secret -A -E Fred -R 14 log1
../build/logread -K secret -S log1
../build/logread -K secret -E Fred -R log1

#Invalide secret
../build/logread -K secret1234567890 -S log1

