
#
# Continuous integration.
#

# Build final cart.
carts/badminton.p8: badminton/badminton.lua carts/badminton-data.p8
	@mkdir -p carts/
	@echo 'pico-8 cartridge // http://www.pico-8.com' > carts/badminton.p8
	@echo 'version 16' >> carts/badminton.p8
	@echo '__lua__' >> carts/badminton.p8
	@cat badminton/badminton.lua >> carts/badminton.p8
	@tail -n +5 carts/badminton-data.p8 >> carts/badminton.p8

# Transpile TypeScript to Lua.
badminton/badminton.lua: lint
	@./node_modules/.bin/tstl -p tsconfig.json

# Lint TypeScript.
lint: badminton/badminton.ts
	@./node_modules/.bin/tslint -c tslint.json badminton/badminton.ts
.PHONY: lint

# Run generated cart.
run: carts/badminton.p8
	@open -na PICO-8 --args \
		-gif_scale 10 \
		-home $(shell pwd) \
		-run $(shell pwd)/carts/badminton.p8
.PHONY: run

# Generate data cart.
carts/badminton-data.p8: carts/badminton-writer.p8
	@open -na PICO-8 --args \
		-gif_scale 10 \
		-home $(shell pwd) \
		-run $(shell pwd)/carts/badminton-writer.p8

#
# Continuous delivery.
#

# Build HTML export.
badminton.html: carts/build.p8
	@open -na PICO-8 --args \
		-gif_scale 10 \
		-home $(shell pwd) \
		-run $(shell pwd)/carts/build.p8

# Build builder cart.
carts/build.p8: badminton/badminton.lua
	@mkdir -p carts/
	@echo 'pico-8 cartridge // http://www.pico-8.com' > carts/build.p8
	@echo 'version 16' >> carts/build.p8
	@echo '__lua__' >> carts/build.p8
	@echo 'export("badminton.html")' >> carts/build.p8
	@cat badminton/badminton.lua >> carts/build.p8

#
# Continuous deployment.
#
# No make targets yet!
#

#
# Everything else.
#

# Remove generated files.
clean:
	@rm -f carts/badminton.p8
	@rm -f badminton/badminton.lua
	@rm -f carts/badminton.js
	@rm -f carts/badminton.html
	@rm -f carts/build.p8
.PHONY: clean
