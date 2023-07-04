##
## DIAGORA, 2023
## Mobile
## File description:
## Makefile
##

run:
	flutter run

build:
	flutter build ios --release

build-apk:
	flutter build apk --split-per-abi

build-bundle:
	flutter build appbundle

build-prod:
	flutter build ios --release

build-prod-apk:
	flutter build apk

build-prod-bundle:
	flutter build appbundle

install:
	flutter install --release

clean:
	$(RM) -rf build
	flutter clean

.PHONY: run run-prod build build-apk build-prod build-prod-apk install clean
