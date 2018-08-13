# Build final cart by prepending PICO-8 header.
# No minifier for now.
game.p8: game.lua
	@echo 'pico-8 cartridge // http://www.pico-8.com' > game.p8
	@echo 'version 16' >> game.p8
	@echo '__lua__' >> game.p8
	@echo 'export("game.html")' >> game.p8
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
	@rm -f game.p8
	@rm -f game.lua
	@rm -f build.p8
	@rm -rf carts/
.PHONY: clean

# Run generated cart.
run: game.p8
	@open -a PICO-8 --args -gif_scale 10 -home $(shell pwd) -run $(shell pwd)/game.p8
.PHONY: run

# Build HTML export.
html: game.p8
	@open -a PICO-8 --args -home $(shell pwd) -run $(shell pwd)/game.p8
	@sleep 10
	@pkill pico8
.PHONY: html

# Spin up a PICO-8 instance.
pico:
	@open -a PICO-8 --args -home $(shell pwd)
.PHONY: pico
