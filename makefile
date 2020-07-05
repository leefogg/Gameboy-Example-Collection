srcdir = src
resdir = res
objdir = obj
outdir = bin
defs=DEBUG


all: resources roms	

resources: $(resdir)/Gameboy.pal \
	$(resdir)/Gameboy.2bbp \
	$(resdir)/Gameboy.tilemap \
	$(resdir)/ZoomScroller.2bbp \
	$(resdir)/ZoomScroller.tilemap \
	$(resdir)/font.2bbp

roms: $(outdir)/ScanlineLength.gbc \
	$(outdir)/Demotronic.gbc \
	$(outdir)/ProgressBar.gbc \
	$(outdir)/RGBGFX.gbc \
	$(outdir)/RepeatTiles.gbc \
	$(outdir)/ZoomingGrid.gbc

$(resdir)/%.tilemap:
	rgbgfx -T -u $(subst .tilemap,.png,$@)
$(resdir)/%.2bbp:
	rgbgfx -u -o $@ $(subst .2bbp,.png,$@)
$(resdir)/%.pal:
	rgbgfx -P $(subst .pal,.png,$@)

$(outdir)/%.gbc: $(objdir)/%.o outdir
	rgblink -o $@ -n $(outdir)/$*.sym $<
	rgbfix -v -C -p 0 -t "$*" $@

$(objdir)/%.o: objdir
	rgbasm -D $(defs) -o $@ -i $(srcdir)/ $(srcdir)/$*.asm 

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