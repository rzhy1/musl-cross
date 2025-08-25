# musl-cross

This is a simple, lightweight project for making cross-compilation toolchain with musl libc.

## Supported targets

| Target                         | Kernel  | Binutils | GCC    | Musl   |
|--------------------------------|---------|----------|--------|--------|
| x86_64-w64-mingw32             | 5.4.293 | 2.45     | 15.2.0 | 1.2.5  |

## How to use

Download the tarball from the [release page](https://github.com/cross-tools/musl-cross/releases) and extract it to `/opt/x-tools`:

```sh
sudo mkdir -p /opt/x-tools
sudo tar -xf ${target}.tar.xz -C /opt/x-tools
```

## How to build

Fork this project and create a new release, or build manually:

```sh
./scripts/make ${target}
```

## License

MIT

## Acknowledgements

We would like to express our gratitude to the following individuals and projects:

- [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng)
- [musl-libc](https://musl.libc.org)
