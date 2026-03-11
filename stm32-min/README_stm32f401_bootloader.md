# STM32F401RE Minimal Flash BootLoader

## Protection strategy

This bootloader implementation is added alongside the existing blink project.
No pre-existing file content is deleted or replaced.

Files kept untouched:

- `README.md`
- `Makefile`
- `startup.s`
- `stm32f401.ld`
- `main.s`

Previously added standalone blink files are also kept in place.

## What this bootloader does

- BootLoader lives at `0x08000000` and uses the first 32 KB of Flash.
- Application slot starts at `0x08008000` and uses 96 KB.
- Staging slot starts at `0x08020000`.
- On reset, the BootLoader checks whether a staged update image exists.
- If a valid staged image exists, it erases the application slot and copies
  the new image into internal Flash.
- After that, it validates the application vector table and jumps to the app.
- If no valid app is present, the BootLoader blinks PA5 forever.

This is a custom Flash BootLoader.
It is not the STM32 ROM bootloader in System Memory.

## Flash layout

- `0x08000000 - 0x08007FFF`: BootLoader
- `0x08008000 - 0x0801FFFF`: Application slot
- `0x08020000 - 0x0807FFFF`: Staging slot

The current application example is still the minimal PA5 blink app.

## Added files

- `boot_image_format.h`: shared image header and slot definitions.
- `stm32f401_boot_min.h`: bootloader-side register definitions.
- `startup_boot_stm32f401.s`: bootloader startup and vector table.
- `startup_app_stm32f401.s`: application startup and vector table.
- `linker_stm32f401_boot.ld`: bootloader linker script.
- `linker_stm32f401_app.ld`: application linker script for `0x08008000`.
- `bootloader_flash_main.c`: flash update, validation, and app jump logic.
- `app_blink_pa5.c`: example application linked into the app slot.
- `stage_image_tool.c`: host utility that wraps `app.bin` with a boot header.
- `Makefile.bootloader`: standalone build for bootloader, app, and staged image.
- `README_stm32f401_bootloader.md`: this document.

## Build

Inside the Docker environment:

```bash
make -f Makefile.bootloader
```

Generated outputs:

- `build_stm32f401_bootloader/stm32f401_flash_bootloader.elf`
- `build_stm32f401_bootloader/stm32f401_flash_bootloader.bin`
- `build_stm32f401_bootloader/stm32f401_flash_bootloader.hex`
- `build_stm32f401_bootloader/stm32f401_flash_app.elf`
- `build_stm32f401_bootloader/stm32f401_flash_app.bin`
- `build_stm32f401_bootloader/stm32f401_flash_app.hex`
- `build_stm32f401_bootloader/stm32f401_flash_app.stage.bin`

Clean only removes this bootloader build directory:

```bash
make -f Makefile.bootloader clean
```

## Flashing flow

1. Flash the bootloader to `0x08000000`.
2. Flash the staged application image to `0x08020000`.
3. Reset the MCU.
4. BootLoader copies the staged image into the application slot at `0x08008000`.
5. BootLoader invalidates the stage header and jumps to the app.

Example with OpenOCD:

```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "program build_stm32f401_bootloader/stm32f401_flash_bootloader.elf verify reset exit"
```

```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "init" \
  -c "reset init" \
  -c "flash write_image erase build_stm32f401_bootloader/stm32f401_flash_app.stage.bin 0x08020000" \
  -c "reset run" \
  -c "exit"
```

You can also flash `stm32f401_flash_app.elf` directly to `0x08008000` during
bring-up if you want to test app jumping before testing staged updates.
