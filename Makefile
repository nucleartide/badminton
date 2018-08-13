# Build final cart by prepending PICO-8 header.
# No minifier for now.
game.p8: game.lua
	@echo 'pico-8 cartridge // http://www.pico-8.com' > game.p8
	@echo 'version 16' >> game.p8
	@echo '__lua__' >> game.p8
	@cat game.lua | tail -n +3 >> game.p8

# Transpile TypeScript to Lua.
game.lua: game.ts
	@./node_modules/.bin/tstl -p tsconfig.json

# Make TypeScript prettier.
prettier:
	@prettier --write --print-width 60 --no-semi game.ts
.PHONY: prettier

# Remove generated files.
clean:
	@rm game.p8
	@rm game.lua
	@rm build.p8
.PHONY: clean

# Run generated cart.
run: game.p8
	@open -a PICO-8 --args -gif_scale 10 -home $(shell pwd) $(shell pwd)/game.p8
.PHONY: run

# Generate build script.
build.p8: game.p8
	@echo 'pico-8 cartridge // http://www.pico-8.com' > build.p8
	@echo 'version 16' >> build.p8
	@echo '__lua__' >> build.p8
	@echo 'load("$(shell pwd)/game.p8")' >> build.p8
	@echo 'export("game.html")' >> build.p8

# Build HTML export.
html: build.p8
	@open -a PICO-8 --args -x $(shell pwd)/build.p8 -home $(shell pwd)
.PHONY: html
