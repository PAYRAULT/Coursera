# Error in the invocation
rm -f log1
./logappend -T -10 -K secret -A -E Fred log1
echo "                       " $?
./logappend -T -10 -K secret -A Fred log1
echo "                       " $?
./logappend -K secret -A Fred log1
echo "                       " $?
./logappend -T secret -A Fred log1
echo "                       " $?
./logappend -T secret log1
echo "                       " $?
./logappend -A Fred log1
echo "                       " $?
./logappend -U Fred log1
echo "                       " $?
