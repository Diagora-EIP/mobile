##
## DIAGORA, 2023
## Mobile
## File description:
## Makefile
##

MAPBOX_PUBLIC_TOKEN = "pk.eyJ1IjoiZGlhZ29yYSIsImEiOiJjbG9qNXBwMHcxbjdzMmtvMTkyeGIzYnFjIn0.YAW88p0zcUrGejfjnShxew"

run:
	flutter run \
	--dart-define MAPBOX_PUBLIC_TOKEN=$(MAPBOX_PUBLIC_TOKEN)

build:
	flutter build ios --release \
	--dart-define MAPBOX_PUBLIC_TOKEN=$(MAPBOX_PUBLIC_TOKEN)

build-apk:
	flutter build apk --split-per-abi \
	--dart-define MAPBOX_PUBLIC_TOKEN=$(MAPBOX_PUBLIC_TOKEN)

build-bundle:
	flutter build appbundle \
	--dart-define MAPBOX_PUBLIC_TOKEN=$(MAPBOX_PUBLIC_TOKEN)

build-prod:
	flutter build ios --release \
	--dart-define MAPBOX_PUBLIC_TOKEN=$(MAPBOX_PUBLIC_TOKEN)

build-prod-apk:
	flutter build apk \
	--dart-define MAPBOX_PUBLIC_TOKEN=$(MAPBOX_PUBLIC_TOKEN)

build-prod-bundle:
	flutter build appbundle \
	--dart-define MAPBOX_PUBLIC_TOKEN=$(MAPBOX_PUBLIC_TOKEN)

install:
	flutter install --release

test_fluter:
	flutter test test/main_test.dart --coverage
	genhtml -o coverage_report coverage/lcov.info
	open coverage_report/index.html

clean:
	$(RM) -rf build
	flutter clean

.PHONY: run run-prod build build-apk build-prod build-prod-apk install clean
