#Example
rm -f log1
rm -f .logdb
./logappend -T 1 -K secret -A -E Fred log1
echo "*************************"
./logappend -T 2 -K secret -A -G Jill log1
echo "*************************"
./logappend -T 3 -K secret -A -E Fred -R 1 log1
echo "*************************"
./logappend -T 4 -K secret -A -G Jill -R 1 log1
echo "*************************"
./logread -K secret -S log1
echo "*************************"
./logappend -T 5 -K secret -L -E Fred -R 1 log1
echo "*************************"
./logappend -T 6 -K secret -A -E Fred -R 2 log1
echo "*************************"
./logappend -T 7 -K secret -L -E Fred -R 2 log1
echo "*************************"
./logappend -T 8 -K secret -A -E Fred -R 3 log1
echo "*************************"
./logappend -T 9 -K secret -L -E Fred -R 3 log1
echo "*************************"
./logappend -T 10 -K secret -A -E Fred -R 1 log1
echo "*************************"
./logread -K secret -R -E Fred log1
echo "*************************"
