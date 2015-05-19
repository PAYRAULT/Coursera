# Ou aller chercher le compilo... Avec un / a la fin
BINDIR=
CAMLC=$(BINDIR)ocamlopt
CAML=$(BINDIR)ocamlopt
CAMLDEP=$(BINDIR)ocamldep.opt
CAMLLEX=$(BINDIR)ocamllex
CAMLYACC=$(BINDIR)ocamlyacc
CAMLFIND=$(BINDIR)ocamlfind

# User definitions must be here
EXEC = logappend
SOURCES = rand.ml crypt_util.ml gallery.ml parserlist.ml logappend.ml
GENERATED = parser.ml lexer.ml
OBJS =  rand.cmx parserlist.cmx crypt_util.cmx gallery.cmx \
parser.cmx lexer.cmx \
logappend.cmx

EXEC2 = logread
SOURCES2 = rand.ml crypt_util.ml gallery.ml logread.ml 
GENERATED2 = 
OBJS2 = rand.cmx crypt_util.cmx gallery.cmx logread.cmx

# Building the world
all: depend $(EXEC2) $(EXEC)

$(EXEC): $(OBJS)
	$(CAMLC) -I +cryptokit  unix.cmxa nums.cmxa cryptokit.cmxa $(OBJS) -o $(EXEC) 

$(EXEC2): $(OBJS2)
	$(CAMLC) -I +cryptokit unix.cmxa nums.cmxa cryptokit.cmxa $(OBJS2) -o $(EXEC2) 

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx .cmx
.SUFFIXES: .mll .mly

.ml.cmo:
	$(CAMLFIND) $(CAML) -linkpkg -thread -package cryptokit -c $<

.ml.cmx:
	$(CAMLFIND) $(CAML) -linkpkg -thread -package cryptokit -c $<

.mli.cmi:
	$(CAMLC) -c $<

.mll.ml:
	$(CAMLLEX) $<

.mly.ml:
	$(CAMLYACC) $<

# Clean up
clean:
	rm -f *.cm[io] *.cmx *~ .*~  *.o
	rm -f $(GENERATED2) $(GENERATED)
	rm -f $(EXEC2) $(EXEC)

# Dependencies
depend: $(SOURCES2) $(GENERATED2) $(SOURCES) $(GENERATED) parser.mli
	$(CAMLDEP) $(SOURCES2) $(GENERATED2) $(SOURCES) $(GENERATED) parser.mli > .depend

include .depend
