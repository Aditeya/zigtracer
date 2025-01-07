run:
	zig build run
	magick image.ppm image.jpg
build:
    zig build
test:
	zig build test
fmt:
	zig fmt src/*
