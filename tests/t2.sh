# Fred goes from room to room and exits
rm -f .logdb; rm -f log1
./logappend -T 1  -K secret -A -E Fred log1
echo "                              " $?
./logappend -T 3  -K secret -A -E Fred -R 1 log1
echo "                              " $?
./logappend -T 5  -K secret -L -E Fred -R 1 log1
echo "                              " $?
./logappend -T 6  -K secret -A -E Fred -R 2 log1
echo "                              " $?
./logappend -T 7  -K secret -L -E Fred -R 2 log1
echo "                              " $?
./logappend -T 8  -K secret -A -E Fred -R 3 log1
echo "                              " $?
./logappend -T 9  -K secret -L -E Fred -R 3 log1
echo "                              " $?
./logread -K secret -R -E Fred log1
echo "                              " $?
./logappend -T 10 -K secret -L -E Fred log1
echo "                              " $?
# Fred re-enters
./logappend -T 11  -K secret -A -E Fred log1
echo "                              " $?
./logappend -T 13  -K secret -A -E Fred -R 4 log1
echo "                              " $?
./logread -K secret -R -E Fred log1
echo "                              " $?
./logread -K secret -S log1
echo "                              " $?
