import string
import random
import os

ListeOfGuest=[]
build=["../107/code/build/","../108/code/build/"] # A generer

def allT():
	for log in build:
		print "***********"+log+"***********"
		for i in range(1,16777215):
			guest=chercherguest()
			print "Result logappend"
			os.system(log+"logappend"+" -T "+ str(i)+" -K "+"secret"+ " -A " + "-G "+guest+" log1")
		for i in range(16777215,1073741823):
			guest=chercherguest()
			print "Result logappend"
			os.system(log+"logappend"+" -T "+ str(i)+" -K "+"secret"+ " -A " + "-G "+guest+" log1")

		print "Result logread"
		os.system(log+"logread"+" -K "+"secret"+ " -S "+"log1")
		os.system("rm -f log1")

def allsecret():
	i=0
	secret=createlstsecret(65536)
	for log in build:
		print "***********"+log+"***********"
		for s in secret:
			i+=1
			os.system(log+"logappend"+" -T "+ str(i)+" -K "+s+ " -A " + "-G "+"guest"+" log"+str(i))
			os.system(log+"logread"+" -K "+s+ " -S "+"log"+str(i))


def createlstsecret(size):
	s=[]
	for i in range(1000000):
		chars=string.ascii_uppercase+string.ascii_lowercase+string.digits
		g = ''.join(random.choice(chars) for _ in range(size))
		while(g in s):
			chars=string.ascii_uppercase+string.ascii_lowercase
			g = ''.join(random.choice(chars) for _ in range(size))
		s.append(g)
	return s


def chercherguest():
	chars=string.ascii_uppercase+string.ascii_lowercase
	g = ''.join(random.choice(chars) for _ in range(65536))
	while(g in ListeOfGuest):
		chars=string.ascii_uppercase+string.ascii_lowercase
		g = ''.join(random.choice(chars) for _ in range(65536))
	ListeOfGuest.append(g)
	return g


allT()
allsecret()
