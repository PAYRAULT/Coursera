#Example
rm -f log1
rm -f $HOME/.logdb

# Incorrect Name
../build/logappend -T 1 -K secret -A -E 01Fred log1
../build/logappend -T 1 -K secret -A -E Fred01 log1
../build/logappend -T 1 -K secret -A -E @Fred log1
../build/logappend -T 1 -K secret -A -E Fre01d log1
../build/logappend -T 1 -K secret -A -E Fre@d log1





#Incorrect Token




#Incorrect secret



#Incorrect option -A / -L



#Incorrect Timestamp



