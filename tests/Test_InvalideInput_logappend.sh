#! /bin/sh
#ReInit

#LOG="log1"
BUILD=$1
LOG=$2
echo $BUILD
echo $LOG
rm -f $LOG
# Incorrect Name employee
echo "Incorrect name employee: 5 invalid expected"
$BUILD/logappend -T 1 -K secret -A -E 01Fred $LOG
$BUILD/logappend -T 2 -K secret -A -E Fred01 $LOG
$BUILD/logappend -T 3 -K secret -A -E @Fred $LOG
$BUILD/logappend -T 4 -K secret -A -E Fre01d $LOG
$BUILD/logappend -T 5 -K secret -A -E Fre@d $LOG

#Incorrect name guest
echo "Incorrect name guest: 5 invalid expected"
$BUILD/logappend -T 1 -K secret -A -G 01Fred $LOG
$BUILD/logappend -T 2 -K secret -A -G Fred01 $LOG
$BUILD/logappend -T 3 -K secret -A -G @Fred $LOG
$BUILD/logappend -T 4 -K secret -A -G Fre01d $LOG
$BUILD/logappend -T 5 -K secret -A -G Fre@d $LOG
rm -f $LOG

#Incorrect Timestamp
echo "Error invalid time stamp expected 0"
$BUILD/logappend -T 0 -K secret -A -G Fred $LOG
echo "correct timestamp"
$BUILD/logappend -T 1 -K secret -A -G Jane $LOG
$BUILD/logappend -T 3 -K secret -A -G Bob $LOG
echo "Error time stamp expected"
$BUILD/logappend -T 2 -K secret -A -G Alex $LOG

$BUILD/logread -K secret -S $LOG
rm -f $LOG

#Incorrect Token
$BUILD/logappend -T 1 -K secret0 -A -G Fred $LOG
echo "Invalid expected: Error on Token"
$BUILD/logappend -T 1 -K secret1 -A -G Jane $LOG
$BUILD/logread -K secret0 -S $LOG
rm -f $LOG

echo "Invalid expected: Error on Token"
$BUILD/logappend -T 1 -K secret@ -A -G Fred $LOG
rm -f $LOG

#Incorrect option -A / -L
echo "Invalid expected: Error on option"
$BUILD/logappend -T 1 -K secret0 -N -G Fred $LOG

rm -f $LOG
#Incorrect RoomID
$BUILD/logappend -T 1 -K secret1 -A -G Fred $LOG
echo "invalid roomID"
$BUILD/logappend -T 2 -K secret1 -A -R a -G Fred $LOG
echo "Correct roomID"
$BUILD/logappend -T 3 -K secret1 -A -R 0 -G Fred $LOG
$BUILD/logread -K secret1 -S $LOG
echo "Correct Person type"
$BUILD/logread -K secret1 -G Fred -R $LOG
echo "InCorrect Person type"
$BUILD/logread -K secret1 -E Fred -R $LOG
rm -f $LOG

echo "same name wih different case"
$BUILD/logappend -T 1 -K secret1 -A -G Fred $LOG
$BUILD/logappend -T 2 -K secret1 -A -G fred $LOG
$BUILD/logread -K secret1 -S $LOG

rm -f $LOG

#Incorrect Name Leave

$BUILD/logappend -T 1 -K secret1 -A -G Fred $LOG
$BUILD/logappend -T 2 -K secret1 -A -G fred $LOG
echo "leave without arrival"
$BUILD/logappend -T 3 -K secret1 -L -G John $LOG
$BUILD/logappend -T 4 -K secret1 -L -G fred $LOG
$BUILD/logappend -T 5 -K secret1 -A -G Fred -R 0 $LOG
$BUILD/logappend -T 6 -K secret1 -A -G John -R 0 $LOG
$BUILD/logread -K secret1 -S $LOG
rm -f $LOG

#Guest & Employee with same name
$BUILD/logappend -T 1 -K secret -A -G John $LOG
$BUILD/logappend -T 2 -K secret -A -E John $LOG
$BUILD/logread -K secret -S $LOG
rm -f $LOG





