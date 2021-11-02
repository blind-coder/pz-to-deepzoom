THREADS := 1
LAYER := 0

all: tmp/Makefile.deepzoom
	make -f tmp/Makefile.deepzoom -j $(THREADS) all

tmp/Makefile.deepzoom: tmp/stitch.ok
	bash ./deepzoom.sh -a 1024 -o png -p tmp/output -s png
	sed -e 's,output,tmp/output,g' -i tmp/Makefile.deepzoom

tmp/stitch.ok: tmp/Makefile.stitch
	make -f tmp/Makefile.stitch -ik -j $(THREADS) all
	./filltransparent.sh
	touch tmp/stitch.ok

tmp/Makefile.stitch: tmp/vectorcache.txt
	./stitch.sh mapmap_output/cell_*_$(LAYER).png
	mv Makefile.stitch tmp/Makefile.stitch

tmp/vectorcache.txt: mapmap_output
	mkdir tmp
	./addtocache.sh mapmap_output/*
	mv tmp/vectorcache.tmp tmp/vectorcache.txt

mapmap_output: map texturepacks/ApCom_old.pack texturepacks/ApCom.pack texturepacks/ApComUI.pack texturepacks/Erosion.pack texturepacks/IconsMoveables.pack texturepacks/JumboTrees1x.pack texturepacks/JumboTrees2x.pack texturepacks/Mechanics.pack texturepacks/RadioIcons.pack texturepacks/Tiles1x.floor.pack texturepacks/Tiles1x.pack texturepacks/Tiles2x.floor.pack texturepacks/Tiles2x.pack texturepacks/UI2.pack texturepacks/UI.pack texturepacks/WeatherFx.pack 
	@echo "Warning! Running this command with the Mono project causes issues with transparency. Unfortunately, Mono refused to fix it when I reported it way back when. See https://github.com/blind-coder/pz-mapmap/tree/master/MonoTransparanceBug for an example of this issue."
	@echo "Please press enter to continue anyway."
	@read x
	@mkdir mapmap_output/
	./MapMap.exe \
		-gfxsource texturepacks/ApCom_old.pack \
		-gfxsource texturepacks/ApCom.pack \
		-gfxsource texturepacks/ApComUI.pack \
		-gfxsource texturepacks/Erosion.pack \
		-gfxsource texturepacks/IconsMoveables.pack \
		-gfxsource texturepacks/JumboTrees2x.pack \
		-gfxsource texturepacks/Mechanics.pack \
		-gfxsource texturepacks/RadioIcons.pack \
		-gfxsource texturepacks/Tiles2x.floor.pack \
		-gfxsource texturepacks/Tiles2x.pack \
		-gfxsource texturepacks/UI2.pack \
		-gfxsource texturepacks/UI.pack \
		-gfxsource texturepacks/WeatherFx.pack \
		-mapsource "map/" \
		-output "mapmap_output/" \
		-dolayers true \
		-divider 4 \
		-threads $(THREADS)

map:
	@echo "Please put the map (.lotpack file) you want to process into a directory called map/"

MapMap.exe:
	@echo "Please download MapMap.exe from https://github.com/blind-coder/pz-mapmap and put it here."

texturepacks/ApCom_old.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/ApCom_old.pack)"

texturepacks/ApCom.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/ApCom.pack)"

texturepacks/ApComUI.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/ApComUI.pack)"

texturepacks/Erosion.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/Erosion.pack)"

texturepacks/IconsMoveables.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/IconsMoveables.pack)"

texturepacks/JumboTrees1x.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/JumboTrees1x.pack)"

texturepacks/JumboTrees2x.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/JumboTrees2x.pack)"

texturepacks/Mechanics.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/Mechanics.pack)"

texturepacks/RadioIcons.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/RadioIcons.pack)"

texturepacks/Tiles1x.floor.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/Tiles1x.floor.pack)"

texturepacks/Tiles1x.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/Tiles1x.pack)"

texturepacks/Tiles2x.floor.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/Tiles2x.floor.pack)"

texturepacks/Tiles2x.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/Tiles2x.pack)"

texturepacks/UI2.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/UI2.pack)"

texturepacks/UI.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/UI.pack)"

texturepacks/WeatherFx.pack:
	@echo "Please copy all *.pack files from the Project Zomboid directory and put them into texturepacks/ (missing file: texturepacks/WeatherFx.pack)"
