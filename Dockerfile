# This Dockerfile simply produces an image containing Klipper.

# Build Klipper
FROM debian:10-slim as build

RUN apt update && apt install -y \
	# Runtime deps
	python \
	python-serial \
	python-greenlet \
	python-jinja2 \
	python-cffi \
	libusb-0.1-4 \
	# Build deps
	git \
	gcc \
	libusb-dev \
	&& \
	rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/KevinOConnor/klipper /klipper && \
	rm -rf /klipper/.git
RUN cd /klipper && \
	python2 scripts/make_version.py ZHAOFENG > klippy/.version && \
	python2 -m compileall klippy && \
	python2 klippy/chelper/__init__.py

# Emit image
FROM debian:10-slim

RUN apt update && apt install -y \
	# Runtime deps
	python \
	python-serial \
	python-greenlet \
	python-jinja2 \
	python-cffi \
	libusb-0.1-4 \
	&& \
	rm -rf /var/lib/apt/lists/*

COPY --from=build /klipper /klipper

ENTRYPOINT ["/usr/bin/python2", "/klipper/klippy/klippy.py"]

# Example only. Supply your own parameters.
CMD ["/klipper.cfg"]
