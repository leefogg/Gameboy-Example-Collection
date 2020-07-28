srcdir = src
resdir = res
objdir = obj
outdir = bin


all: resources roms	

resources: palettes tilesets tilemaps
palettes: $(subst .png,.pal,$(wildcard $(resdir)/*.png))
tilesets: $(subst .png,.2bpp,$(wildcard $(resdir)/*.png))
tilemaps: $(subst .png,.tilemap,$(wildcard $(resdir)/*.png))

roms: effectRoms exampleRoms testRoms
effectRoms:  $(patsubst $(srcdir)/%.asm, $(outdir)/%.gbc, $(wildcard $(srcdir)/effects/*.asm))
exampleRoms: $(patsubst $(srcdir)/%.asm, $(outdir)/%.gbc, $(wildcard $(srcdir)/examples/*.asm))
testRoms: 	 $(patsubst $(srcdir)/%.asm, $(outdir)/%.gbc, $(wildcard $(srcdir)/tests/*.asm))

$(resdir)/%.tilemap:
	rgbgfx -T -u $(subst .tilemap,.png,$@)
$(resdir)/%.2bpp:
	rgbgfx -u -o $@ $(subst .2bpp,.png,$@)
$(resdir)/%.pal:
	rgbgfx -P $(subst .pal,.png,$@)

$(outdir)/%.gbc: $(objdir)/%.o outdir
	rgblink --sym $(outdir)/$(notdir $*).sym --output $(outdir)/$(notdir $@) $(objdir)/$(notdir $<)
	rgbfix --validate --non-japanese --color-only --mbc-type 0x1A --ram-size 0x05 --title "$(notdir $*)" $(outdir)/$(notdir $@)

$(objdir)/%.o: objdir
	rgbasm --output $(objdir)/$(notdir $@) --export-all --include $(srcdir)/ $(srcdir)/$*.asm 

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
	if exist $(objdir) del /F /Q $(resdir)\*.2bpp
else
	rm -r -f $(outdir)/*
	rm -r -f $(objdir)/*
	rm -r -f $(resdir)/*.pal
	rm -r -f $(resdir)/*.2bpp
	rm -r -f $(resdir)/*.tilemap
endif