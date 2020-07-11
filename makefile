srcdir = src
resdir = res
objdir = obj
outdir = bin
defs=DEBUG


all: resources roms	

resources: palettes tilesets tilemaps
palettes: $(subst .png,.pal,$(wildcard $(resdir)/*.png))
tilesets: $(subst .png,.2bbp,$(wildcard $(resdir)/*.png))
tilemaps: $(subst .png,.tilemap,$(wildcard $(resdir)/*.png))

roms: effectRoms exampleRoms testRoms
effectRoms:  $(patsubst $(srcdir)/%.asm, $(outdir)/%.gbc, $(wildcard $(srcdir)/effects/*.asm))
exampleRoms: $(patsubst $(srcdir)/%.asm, $(outdir)/%.gbc, $(wildcard $(srcdir)/examples/*.asm))
testRoms: 	 $(patsubst $(srcdir)/%.asm, $(outdir)/%.gbc, $(wildcard $(srcdir)/tests/*.asm))

$(resdir)/%.tilemap:
	rgbgfx -T -u $(subst .tilemap,.png,$@)
$(resdir)/%.2bbp:
	rgbgfx -u -o $@ $(subst .2bbp,.png,$@)
$(resdir)/%.pal:
	rgbgfx -P $(subst .pal,.png,$@)

$(outdir)/%.gbc: $(objdir)/%.o outdir
	rgblink -o $(outdir)/$(notdir $@) -n $(outdir)/$(notdir $*).sym $(objdir)/$(notdir $<)
	rgbfix -v -C -p 0 -t "$(notdir $*)" $(outdir)/$(notdir $@)

$(objdir)/%.o: objdir
	rgbasm -D $(defs) -o $(objdir)/$(notdir $@) -i $(srcdir)/ $(srcdir)/$*.asm 

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
	if exist $(objdir) del /F /Q $(resdir)\*.tilemap
	if exist $(objdir) del /F /Q $(resdir)\*.pal
	if exist $(objdir) del /F /Q $(resdir)\*.2bbp
else
	rm -r -f $(outdir)/*
	rm -r -f $(objdir)/*
	rm -r -f $(resdir)/*.pal
	rm -r -f $(resdir)/*.2bbp
	rm -r -f $(resdir)/*.tilemap
endif