romname = ProgressBar
srcdir = src
objdir = obj
outdir = bin
extension = gbc
defs=DEBUG

run: $(romname).$(extension)

$(romname).$(extension): $(romname).o
	rgblink -o $(outdir)/$(romname).$(extension) -n $(outdir)/$(romname).sym $(objdir)/$(romname).o
	rgbfix -v -C -p 0 -t "$(romname)" $(outdir)/$(romname).$(extension)

$(romname).o: outdir objdir
	rgbasm -D $(defs) -o $(objdir)/$(romname).o -i $(srcdir)/ $(srcdir)/$(romname).asm

outdir:
ifeq ($(OS), Windows_NT)
	if not exist $(outdir) mkdir $(outdir)
else
	mkdir -p $(outdir)
endif
	
objdir:
ifeq ($(OS), Windows_NT)
	if not exist $(objdir) mkdir $(objdir)
else
	mkdir -p $(objdir)
endif

clean:
ifeq ($(OS), Windows_NT)
	if exist $(outdir) del /F /Q $(outdir)\*.*
	if exist $(objdir) del /F /Q $(objdir)\*.*
else
	rm -r -f $(outdir)/*
	rm -r -f $(objdir)/*
endif