import sys, os

chemin = sys.argv[1]
log = sys.argv[2]
logappend=chemin+"logappend"
logread=chemin+"logread"
poblig=['-T','-K','-E','-G','-A','-L']
popt=['-R','-B']
optRead=['-S','-K',]
A = " -A "
L = "-L"
E=" -E "
G=" -G "
def ErrorParameter():
	pass


def ErrorAutomate():
	nom=["Fred", "John", "john"]

	callcmd(logappend,1,"secret",E,nom[0],A,0)
	state=[(nom[0],"Arrived")]
	print state
	callcmd(logread,K="secret")
	os.system("rm -f "+log)



def callcmd(cmd,T=None,K=None,EG=None,Name=None,AL=None,Room=None):
	if "logappend" in cmd:
		os.system(cmd+" -T "+str(T)+" -K "+K+AL+EG+Name+" "+log)
	if "logread" in cmd:
		os.system(cmd+" -K "+K+" -S "+log)


def calculEtat():
	
ErrorAutomate()

