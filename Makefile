build:
	bazel build //:test

build-debug:
	bazel build //:test-debug

build-text:
	bazel build //:test_text

build-js:
	bazel build //:test_js

run:
	wasmtime bazel-bin/test.wasm