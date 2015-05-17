#ReInit
rm -f log1
rm -f $HOME/.logdb

#Order of argument
../build/logappend -T 0 -K secret -E Fred -A log1
../build/logread -K secret log1

# Incorrect Name employee
echo "Incorrect name employee: 5 invalid expected"
../build/logappend -T 1 -K secret -A -E 01Fred log1
../build/logappend -T 2 -K secret -A -E Fred01 log1
../build/logappend -T 3 -K secret -A -E @Fred log1
../build/logappend -T 4 -K secret -A -E Fre01d log1
../build/logappend -T 5 -K secret -A -E Fre@d log1

#Incorrect name guest
rm -f log1
rm -f $HOME/.logdb
echo "Incorrect name guest: 5 invalid expected"
../build/logappend -T 1 -K secret -A -G 01Fred log1
../build/logappend -T 2 -K secret -A -G Fred01 log1
../build/logappend -T 3 -K secret -A -G @Fred log1
../build/logappend -T 4 -K secret -A -G Fre01d log1
../build/logappend -T 5 -K secret -A -G Fre@d log1

#Incorrect Timestamp
rm -f log1
rm -f $HOME/.logdb
../build/logappend -T 0 -K secret -A -G Fred log1
../build/logappend -T 1 -K secret -A -G Jane log1
../build/logappend -T 3 -K secret -A -G Bob log1
echo "Error time stamp expected"
../build/logappend -T 2 -K secret -A -G Alex log1


#Incorrect Token
rm -f log1
rm -f $HOME/.logdb

../build/logappend -T 0 -K secret0 -A -G Fred log1
echo "Invalid expected: Error on Token"
../build/logappend -T 0 -K secret1 -A -G Jane log1

rm -f log1
rm -f $HOME/.logdb
echo "Invalid expected: Error on Token"
../build/logappend -T 0 -K secret@ -A -G Fred log1


#Incorrect option -A / -L
rm -f log1
rm -f $HOME/.logdb
echo "Invalid expected: Error on option"
../build/logappend -T 0 -K secret0 -N -G Fred log1

#Incorrect RoomID
rm -f log1
rm -f $HOME/.logdb
echo "invalid roomID"
../build/logappend -T 0 -K secret1 -A -G Fred log1
../build/logappend -T 1 -K secret1 -A -R a -G Fred log1

#same name
rm -f log1
rm -f $HOME/.logdb
echo "same name wih different case"
../build/logappend -T 0 -K secret1 -A -G Fred log1
../build/logappend -T 1 -K secret1 -A -G fred log1

#Incorrect Name Leave
rm -f log1
rm -f $HOME/.logdb
../build/logappend -T 0 -K secret1 -A -G Fred log1
../build/logappend -T 1 -K secret1 -A -G fred log1
echo "leave without arrival"
../build/logappend -T 2 -K secret1 -L -G fred1 log1
../build/logappend -T 3 -K secret1 -L -G fred log1







