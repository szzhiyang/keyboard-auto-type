RUN_CMAKE = cmake --build build -j4

all: configure cmake
	$(RUN_CMAKE)

configure:
	cmake -B build .

cmake:
	$(RUN_CMAKE)

rebuild: clean
	$(RUN_CMAKE)

clean:
	git clean -fxd build xcode

format:
	find keyboard-auto-type test example -name '*.cpp' -o -name '*.h' -o -name '*.mm' | \
		xargs clang-format -i --verbose

check: clang-tidy cppcheck

clang-tidy:
	cmake -B build \
		-D CMAKE_EXPORT_COMPILE_COMMANDS=1 \
		-D KEYBOARD_AUTO_TYPE_WITH_TESTS=1 \
		-D KEYBOARD_AUTO_TYPE_WITH_EXAMPLE=1 \
		.
	cmake --build build --target clang-tidy

cppcheck:
	cppcheck --enable=all --inline-suppr keyboard-auto-type test example

xcode-project:
	cmake \
		-G Xcode \
		-B xcode \
		-D CMAKE_C_COMPILER="$$(xcrun -find c++)" \
		-D CMAKE_CXX_COMPILER="$$(xcrun -find cc)" \
		-D KEYBOARD_AUTO_TYPE_WITH_TESTS=1 \
		-D KEYBOARD_AUTO_TYPE_WITH_EXAMPLE=1 \
		.

build-example:
	cmake -B build -D KEYBOARD_AUTO_TYPE_WITH_EXAMPLE=1 .
	$(RUN_CMAKE)

run-example: build-example
	build/output/example

tests: build-tests run-tests

build-tests:
	cmake -B build \
		-D KEYBOARD_AUTO_TYPE_WITH_TESTS=1 \
		-D KEYBOARD_AUTO_TYPE_USE_SANITIZERS=1 \
		.
	$(RUN_CMAKE)

run-tests:
	cmake --build build --target run-tests
