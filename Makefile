build:
	swift build

update:
	swift package update

release:
	swift build -c release

run:
	swift run

clean:
	rm -rf .build