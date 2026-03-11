# STM32F401RE Minimal Bare-Metal PA5 Blink

## File protection strategy

This implementation does not overwrite or replace any existing file.
All new logic is isolated in independently named files so the current
directory content remains intact.

Existing files kept untouched:

- `README.md`
- `Makefile`
- `startup.s`
- `stm32f401.ld`
- `main.s`

New files added:

- `main.c`: minimal C entry symbol used by the startup code.
- `startup_stm32f401.s`: vector table, `_estack`, `Reset_Handler`,
  `Default_Handler`, `.data` copy, `.bss` zeroing.
- `linker_stm32f401.ld`: STM32F401RE flash and RAM layout, section
  placement, linker symbols.
- `stm32f401_min.h`: minimal register definitions used by the blink app.
- `main_blink_pa5.c`: contains the direct-register PA5 blink logic.
- `Makefile.stm32f401`: standalone Make build for this minimal project.
- `README_stm32f401_blink.md`: usage notes for the standalone project.

## Boot and startup model

- BOOT0 = 0 means the MCU boots from Main Flash.
- After reset, Cortex-M4 reads the first vector-table word as initial MSP.
- Then it reads the second vector-table word as `Reset_Handler`.
- `startup_stm32f401.s` performs runtime initialization, copies `.data`,
  clears `.bss`, then calls `main`.
- This project is not a user-defined bootloader.
- This project is not the ST ROM bootloader in System Memory.
- This project is only a minimal bare-metal application linked to
  `0x08000000`.

## Build inside the provided Docker environment

```bash
docker run -it --name stm32_build -v ${PWD}:/work -w /work stm32_build bash
make -f Makefile.stm32f401
make -f Makefile.stm32f401 clean
```

Generated artifacts:

- `build_stm32f401/stm32f401_blink_pa5.elf`: ELF with symbols and sections.
- `build_stm32f401/stm32f401_blink_pa5.bin`: raw binary for flashing.
- `build_stm32f401/stm32f401_blink_pa5.hex`: Intel HEX for flashing tools.
- `build_stm32f401/stm32f401_blink_pa5.map`: linker map for section review.

## Optional flashing example

If OpenOCD is available in the container, one possible command is:

```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "program build_stm32f401/stm32f401_blink_pa5.elf verify reset exit"
```
