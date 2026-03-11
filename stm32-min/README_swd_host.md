# STM32F401RE Host-Side SWD Flasher Framework

## Protection strategy

This SWD flasher is added incrementally.
It does not modify or replace the existing minimal blink project or the
previously added custom BootLoader files.

Existing projects kept untouched:

- `Makefile.stm32f401` and the direct-flash blink app
- `Makefile.bootloader` and the custom Flash BootLoader app

## What this adds

This is a host-side SWD flashing stack split into layers:

- `host_swd/swd_transport.h`: transport abstraction
- `host_swd/swd_transport_stub.c`: placeholder backend
- `host_swd/adiv5.c`: DP/AP and MEM-AP access
- `host_swd/cortexm.c`: halt, run, reset
- `host_swd/stm32f4_flash.c`: STM32F4 flash unlock, erase, program, verify
- `host_swd/swd_tool_main.c`: CLI front-end

The transport-independent logic is implemented.
The physical adapter backend is intentionally left as a stub so the design
stays independent from ST-Link protocol details.

## Important boundary

Right now the tool is a framework, not a finished hardware flasher.

What already works in code:

- SWD request encoding
- ADIv5 DP/AP flow
- MEM-AP memory reads and writes
- Cortex-M halt/reset sequence
- STM32F401 sector erase/program/verify logic
- CLI command structure

What is still missing:

- a real backend that toggles SWDIO/SWCLK or speaks to a probe
- examples:
  - ST-Link USB protocol backend
  - CMSIS-DAP backend
  - FTDI/bit-bang backend

## Build

With a POSIX-like shell:

```bash
make -f Makefile.swd_host
```

On Windows with MinGW GCC:

```bat
build_swd_host.bat
```

Generated output:

- `build_swd_host/swd_host_tool`
- on Windows: `build_swd_host\swd_host_tool.exe`

## CLI shape

The tool already exposes the intended commands:

```bash
swd_host_tool probe
swd_host_tool erase 0x08000000 16384
swd_host_tool write app.bin 0x08000000
swd_host_tool verify app.bin 0x08000000
swd_host_tool reset
```

You can also select a backend name:

```bash
swd_host_tool --backend stub probe
```

## Where to extend next

To make it talk to real hardware, add a new file such as:

- `host_swd/swd_transport_stlink.c`
- `host_swd/swd_transport_cmsisdap.c`

Then change `swd_transport_open()` in `host_swd/swd_transport_stub.c` to
dispatch to the new backend instead of always binding the stub implementation.
