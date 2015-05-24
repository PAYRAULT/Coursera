#! /bin/sh
#ReInit

#LOG="log1"
BUILD=$1
LOG=$2
echo $BUILD
echo $LOG
rm -f $LOG
#ReInit
rm -f log1
rm -f log2
rm -f log3
rm -f log4
rm -f log5
rm -f log6
rm -f log7
rm -f log8
rm -f log8b
rm -f log9

#Hexa non visible
$BUILD/logappend -T 1 -K secret -A -G Jane log1
$BUILD/logappend -T 2 -K secret -A -E Fred log1
$BUILD/logappend -T 3 -K secret -A -G John log1

#Hexa non visible
$BUILD/logappend -T 1 -K secret -A -G Jane log2
$BUILD/logappend -T 2 -K secret -A -E Fred log2
$BUILD/logappend -T 3 -K secret -A -G John log2

#Hexa non visible
$BUILD/logappend -T 2 -K secret -A -G Jane log3
$BUILD/logappend -T 3 -K secret -A -E Fred log3
$BUILD/logappend -T 4 -K secret -A -G John log3

#Hexa non visible
$BUILD/logappend -T 1 -K secret -A -G Jane log4
$BUILD/logappend -T 2 -K secret -A -E Fred log4
$BUILD/logappend -T 4 -K secret -A -G John log4

#Hexa visible
$BUILD/logappend -T 1 -K secret0 -A -G Jane log5
$BUILD/logappend -T 2 -K secret0 -A -E Fred log5
$BUILD/logappend -T 3 -K secret0 -A -G John log5

#Hexa non visible
$BUILD/logappend -T 1 -K secret -A -G Jane log6
$BUILD/logappend -T 2 -K secret -A -E Fred log6
$BUILD/logappend -T 3 -K secret -A -G John log6

#Hexa non visible
$BUILD/logappend -T 1 -K secrets1 -A -G Jane log7
$BUILD/logappend -T 2 -K secrets1 -A -E Fred log7
$BUILD/logappend -T 3 -K secrets1 -A -G John log7

#Hexa visible
$BUILD/logappend -T 1 -K 000 -A -G Jane log8
$BUILD/logappend -T 2 -K 000 -A -E Fred log8
$BUILD/logappend -T 3 -K 000 -A -G John log8

#Hexa non visible
$BUILD/logappend -T 1 -K 0001 -A -G Jane log8b
$BUILD/logappend -T 2 -K 0001 -A -E Fred log8b
$BUILD/logappend -T 3 -K 0001 -A -G John log8b

#Hexa visible
$BUILD/logappend -T 1 -K 001 -A -G Jane log9
$BUILD/logappend -T 2 -K 001 -A -E Fred log9
$BUILD/logappend -T 3 -K 001 -A -G John log9
