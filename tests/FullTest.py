import string
import random
import os

ListeOfGuest=[]
build=["../115/code/build/"] # A generer
ListOfToken=range(1,1073741823,1000000)

def allT():
	os.system("rm -f log1")
	for log in build:
		print "***********"+log+"***********"
		for i in ListOfToken:
			guest=chercherguest()
			#print "logappend"
			cmd=os.popen(log+"logappend"+" -T "+ str(i)+" -K "+"secret"+ " -A " + "-G "+guest+" log1")
			cmd
			result = cmd.read()
			if "invalid" in result:
				print "Error with: "+"guest: "+ guest+ " Token: "+ str(i)

		guest=chercherguest()
		cmd=os.popen(log+"logappend"+" -T "+ str(1073741823)+" -K "+"secret"+ " -A " + "-G "+guest+" log1")
		cmd
		result = cmd.read()
		print "T = "+str(1073741823)
		if "invalid" in result:
			print "Error with: "+"guest: "+ guest+ " Token: "+ str(i)


		
		cmd=os.popen(log+"logread"+" -K "+"secret"+ " -S "+"log1")
		cmd
		result=cmd.read()
		if "invalid" in result:
			print "Error logread"
		#print result
		os.system("rm -f log1")

def allsecret():
	i=0
	secret=createlstsecret(1000)
	for log in build:
		print "***********"+log+"***********"
		for s in secret:
			i+=1
			cmd1=os.popen(log+"logappend"+" -T "+ str(i)+" -K "+s+ " -A " + "-G "+"guest"+" log"+str(i))
			cmd2=os.popen(log+"logread"+" -K "+s+ " -S "+"log"+str(i))
			cmd1
			cmd2
			result1=cmd1.read()
			if "invalid" in result1:
				print "Logappend Error with: "+"Key: "+ s+ "in log"+ str(i)
			result2=cmd2.read()
			if "invalid" in result2:
				print "Logread Error with: "+"Key: "+ s+ "in log"+ str(i)
		os.system("rm -f log*")		


def createlstsecret(size):
	s=[]
	for i in range(100):
		chars=string.ascii_uppercase+string.ascii_lowercase+string.digits
		g = ''.join(random.choice(chars) for _ in range(size))
		while(g in s):
			chars=string.ascii_uppercase+string.ascii_lowercase
			g = ''.join(random.choice(chars) for _ in range(size))
		s.append(g)
	return s


def chercherguest():
	chars=string.ascii_uppercase+string.ascii_lowercase
	g = ''.join(random.choice(chars) for _ in range(100))
	while(g in ListeOfGuest):
		chars=string.ascii_uppercase+string.ascii_lowercase
		g = ''.join(random.choice(chars) for _ in range(100))
	ListeOfGuest.append(g)
	return g


allT()
allsecret()
