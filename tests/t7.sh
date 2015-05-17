rm -f ~/.logdb
rm -f log2
./logappend -K secret -T 0 -A -E John log2
./logappend -K secret -T 1 -A -R 0 -E John log2
./logappend -K secret -T 2 -A -G James log2
./logappend -K secret -T 3 -A -L 0 -E John log2
./logappend -K secret -T 5 -A -R 0 -G James log2
./logappend -K secret -T 6 -A -R 1 -E John log2
./logappend -K secret -T 9 -A -L 0 -G James log2
./logappend -K secret -T 10 -A -L 1 -E John log2
./logappend -K secret -T 13 -A -R 2 -G James log2
