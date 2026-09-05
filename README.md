# Hand-Written UART on Cyclone III FPGA

A UART (Universal Asynchronous Receiver/Transmitter) built from scratch in Verilog and verified on a Cyclone III FPGA. This is a resume project: the protocol, baud-rate generation, transmit path, and receive path are written by hand rather than taken from a vendor IP core.

## Goal

Ship a working serial link that can send and receive 8N1 frames (8 data bits, no parity, 1 stop bit) at a configurable baud rate, then prove it on hardware.

## Target hardware

| Item | Choice |
| --- | --- |
| HDL | Verilog |
| FPGA family | Intel / Altera Cyclone III |
| Typical clock | 50 MHz (adjustable) |
| Default baud | 9600 |

Board-specific pin assignments and Quartus project files will live alongside the RTL as the design is brought up on the FPGA.

## Planned modules

- **Baud generator** — integer clock divider that produces a baud tick (and a higher-rate sample clock for the receiver)
- **TX** — start bit, 8 data bits LSB-first, stop bit
- **RX** — start-bit detect, mid-bit sampling, framing checks
- **Top wrapper** — FPGA I/O: clock, reset, UART TX/RX pins, optional loopback and status LEDs

## Status

Early RTL sketch in `UART.v`. Next steps: finish synthesizable TX/RX, add a testbench, then constrain and program a Cyclone III board.

## License

MIT. See `LICENSE`.
