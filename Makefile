# Build final cart by prepending PICO-8 header.
# No minifier for now.
game.p8: game.lua
	@echo 'pico-8 cartridge // http://www.pico-8.com' > game.p8
	@echo 'version 16' >> game.p8
	@echo '__lua__' >> game.p8
	@cat game.lua >> game.p8

# Transpile TypeScript to Lua.
game.lua: game.ts
	@./node_modules/.bin/tstl -p tsconfig.json

# Remove generated files.
clean:
	@rm game.p8
	@rm game.lua
.PHONY: clean
