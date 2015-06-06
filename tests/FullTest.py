import string
import random
import os

ListeOfGuest=[]
build=["../174/code/build/"] # A generer
ListOfToken=range(1,1073741823,1000000)

def allT():	
	print "####All Token####"
	os.system("rm -f log1")
	for log in build:
		print "***********"+log+"***********"
		for i in ListOfToken:
			guest=chercherguest()
			#print "logappend"
			cmd=os.popen(log+"logappend"+" -T "+ str(i)+" -K "+"secret"+ " -A " + "-G "+guest+" log1")
			cmd
			result = cmd.read()
			if result.find("invalid")>0:
				print result
				print "Error logappend with: "+"guest: "+ guest+ " Token: "+ str(i)

		guest=chercherguest()
		cmd=os.popen(log+"logappend"+" -T "+ str(1073741823)+" -K "+"secret"+ " -A " + "-G "+guest+" log1")
		cmd
		result = cmd.read()
		print "T = "+str(1073741823)
		if result.find("invalid")>0:
			print "Error logappend with: "+"guest: "+ guest+ " Token: "+ str(i)
		
		cmd=os.popen(log+"logread"+" -K "+"secret"+ " -S "+"log1")
		cmd
		result=cmd.read()
		if result.find("invalid")>0:
			print "Error logread"
			print result
		
		os.system("rm -f log1")

def allsecret():
	i=0
	print "####Key Test####"
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
			if result1.find("invalid")>0:
				print "Logappend Error with: "+"Key: "+ s+ "in log"+ str(i)
			result2=cmd2.read()
			if result2.find("invalid")>0:
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

#Fonction pour tester une erreur sur le token
def WrongToken():
	print "####Wrong Token####"
	for log in build:
		os.system("rm -f log1")
		print "***********"+log+"***********"
		result=callLogappend(log,0,"secret"," -A ","-E ","Fred","log1")
		if result.find("invalid")<0:
			print "Error logappend 0 is supported"

		result=callLogappend(log,1,"secret"," -A ","-E ","Alfred","log1")
		if result.find("invalid")>0:
			print "Error logappend 1"

		result=callLogappend(log,3,"secret"," -A ","-E ","John","log1")
		if result.find("invalid")>0:
			print "Error logappend 2"

		result=callLogappend(log,2,"secret"," -A ","-E ","Jane","log1")
		if result.find("invalid")>0:
			print result
			print "Error logappend Wrong Token"
		

def SameName():
	print "####Same Name####"
	for log in build:
		os.system("rm -f log1")
		print "***********"+log+"***********"
		result=callLogappend(log,1,"secret"," -A ","-E ","Fred","log1")
		if result.find("invalid")>0:
			print "Error logappend 1"
		result=callLogappend(log,2,"secret"," -A ","-E ","Fred","log1")
		if result.find("invalid")<0:
			print "Error logappend Same Name 1"
		result=callLogappend(log,3,"secret"," -A ","-G ","John","log1")
		if result.find("invalid")>0:
			print "Error logappend 2"
		result=callLogappend(log,4,"secret"," -A ","-G ","John","log1")
		if result.find("invalid")<0:
			print "Error logappend Same Name 2"

def SameNameEG():
	print "####Same Name for Employee ang Guest####"
	for log in build:
		os.system("rm -f log1")
		print "***********"+log+"***********"
		result=callLogappend(log,1,"secret"," -A ","-E ","Fred","log1")
		if result.find("invalid")>0:
			print "Error logappend"
		result=callLogappend(log,2,"secret"," -A ","-G ","Fred","log1")
		if result.find("invalid")>0:
			print "Error logappend Same Name EG"

def StateMachineTest():
	print "####State Machine Test####"
	for log in build:
		os.system("rm -f log1")
		print "***********"+log+"***********"
		result=callLogappend(log,1,"secret"," -A ","-E ","Fred","log1")
		if result.find("invalid")>0:
			print "Error logappend 1"
		result=callLogappend(log,2,"secret"," -A ","-G ","John","log1")
		if result.find("invalid")>0:
			print "Error logappend 2"
		result=callLogappend(log,3,"secret"," -A ","-G ","John","log1",1)
		if result.find("invalid")>0:
			print "Error logappend 3"
		result=callLogappend(log,4,"secret"," -A ","-G ","John","log1",2)
		if result.find("invalid")<0:
			print "Error logappend arrived in a room without leaving previous room"
		result=callLogappend(log,5,"secret"," -L ","-G ","John","log1",2)
		if result.find("invalid")<0:
			print "Error logappend leaved a room which is not in"
		result=callLogappend(log,6,"secret"," -L ","-G ","John","log1")
		if result.find("invalid")<0:
			print "Error logappend leaved gallery without leaving room"
		result=callLogappend(log,7,"secret"," -L ","-G ","John","log1",1)
		if result.find("invalid")>0:
			print "Error logappend 4"


def noargument():
	print "####No Argument####"
	os.system("rm -f log1")
	for log in build:
		os.system("rm -f log1")
		print "***********"+log+"***********"
		cmd=os.popen(log+"logappend")
		cmd
		result=cmd.read()
		if result.find("invalid")<0:
			print "Error No argument Logappend"

		cmd=os.popen(log+"logappend -B batchfile")
		cmd
		result=cmd.read()
		if "invalid" not in result:
			print "Error No argurment Logappend batchfile don't exist"
		cmd=os.popen(log+"logread")
		cmd
		result=cmd.read()
		if "invalid" not in result:
			print "Error No argument LogRead"

		cmd=os.popen(log+"logread"+" -K secret -S log1")
		cmd
		result=cmd.read()
		if "invalid" not in result:
			print "Error No argurment LogRead log don't exist"

		cmd=os.popen(log+"logread"+" -K secret _S")
		cmd
		result=cmd.read()
		if "invalid" not in result:
			print "Error No argurment LogRead _S"


def WrongArgument():
	print "####Wrong Argument"
	for log in build:
		print "***********"+log+"***********"
		os.system("rm -f log1")
		result=callLogappend(log,1,"secret"," -A ","-G ","John@","log1")
		if "invalid" not in result:
			print "Error logappend non alphabetic in name"

		result=callLogappend(log,2,"secret"," -A ","-G ","John01","log1")
		if "invalid" not in result:
			print "Error logappend numeric in name"

		result=callLogappend(log,3,"secret"," -A ","-G ","John01","log1")
		if "invalid" not in result:
			print "Error logappend numeric in name"

		result=callLogappend(log,4,"secret"," -A ","-G ","Fred","log1")
		cmd=os.popen(log+"logappend"+" -T "+ str(5)+" -K secret"+ " -A " + "-G "+"Fred"+ " -R A0"+" log1")
		cmd
		result = cmd.read()
		if result.find("invalid")<0:
			print "Error logappend alphabetic in room"
	os.system("rm -f log1")

#Fonction pour appeler logappend avec les arguments
def callLogappend(path,token, key, AorL,EorG, name,logfile, room=None):
	if room == None:
		cmd = os.popen(path+"logappend"+" -T "+ str(token)+" -K "+key+ AorL +EorG+name+" "+logfile)
	else:
		cmd = os.popen(path+"logappend"+" -T "+ str(token)+" -K "+key+ AorL +EorG+name+" -R "+str(room)+" "+logfile)
	cmd
	result = cmd.read()
	return result

def callLogReadFull(path,key,logfile):
	cmd = os.popen(path+"logread"+" -K "+key+" -S "+logfile)
	cmd
	result = cmd.read()
	return result

allT()
allsecret()
WrongToken()
SameName()
SameNameEG()
StateMachineTest()
noargument()
WrongArgument()







