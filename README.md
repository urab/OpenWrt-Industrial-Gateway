# OpenWrt Industrial Gateway — Nexx WT3020 16M

This branch contains work to run OpenWrt on a **Nexx WT3020 upgraded to 16 MB SPI flash**, with the goal of using the device as a small industrial Ethernet/Wi-Fi/serial gateway.

## Tested hardware

- Nexx WT3020 / MT7620N
- 16 MB SPI flash modification
- 64 MB RAM
- Ethernet LAN/WAN
- 2.4 GHz Wi-Fi
- Breed bootloader (already installed on the test unit)
- USB-to-serial adapter testing is the next stage

## Current status

The custom OpenWrt image boots successfully and LuCI is working. LAN is operational and the MT7620 Wi-Fi radio has been tested with a WPA2 client connection.

The working build produces:

- `openwrt-ramips-mt7620-nexx_wt3020-16m-initramfs-kernel.bin`
- `openwrt-ramips-mt7620-nexx_wt3020-16m-squashfs-factory.bin`
- `openwrt-ramips-mt7620-nexx_wt3020-16m-squashfs-sysupgrade.bin`

GitHub Actions builds these images from this branch.

## Breed installation / recovery notes

**Important:** the test router already had the **Breed bootloader** installed before this OpenWrt build was tested. The original method used to install Breed is no longer known. It may have involved an external SPI flash programmer, but this is not confirmed.

Do **not** overwrite the bootloader unless you have a verified backup and a reliable hardware recovery method.

On the tested router, Breed Web was available at `192.168.1.1` and was used to install/recover the OpenWrt firmware.

For this Breed installation, the OpenWrt image that was accepted as firmware was:

`openwrt-ramips-mt7620-nexx_wt3020-16m-squashfs-sysupgrade.bin`

The generated `factory.bin` contains a Nexx/Poray factory wrapper and this particular Breed version did not recognize it as a firmware image.

## Wi-Fi Factory / EEPROM recovery

During testing the MTD `factory` partition was found erased (`FF FF FF ...`). The driver then failed with:

```
rt2800_init_eeprom: Error - Invalid RF chipset 0xffff detected
```

The router therefore had no usable Wi-Fi radio even though the correct rt2800/rt2x00 drivers were present.

The original 64 KiB `mtdblock2.bin` backup was restored using **Breed Web → EEPROM**. After reboot, the MT7620 radio was detected correctly and Wi-Fi operated normally.

### Warning about Factory/EEPROM images

The Factory/EEPROM partition can contain device-specific calibration and MAC-address data. **Always back up the original Factory/EEPROM partition before modifying it.** Do not assume an EEPROM dump from another router is universally interchangeable.

A recovery EEPROM image should only be published after its device-specific data has been reviewed.

## Build

The WT3020 16M firmware is built automatically by the GitHub Actions workflow in `.github/workflows/build-wt3020-16m.yml`.

Manual OpenWrt build basics:

```
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make -j$(nproc)
```

## Next stage — industrial serial gateway

The next development stage is USB serial support. The target is to connect a USB-to-COM/serial converter to the WT3020 and verify the serial device under OpenWrt before adding industrial communication software and forwarding/monitoring functions.

## License

OpenWrt is licensed under GPL-2.0. Device-support changes in this repository follow the applicable OpenWrt licensing terms.
