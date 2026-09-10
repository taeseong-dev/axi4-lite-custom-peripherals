# SPI Master FPGA Hardware

The SPI Master system was exported as `axi_spi.xsa` from Vivado. The provided XSA contains the MicroBlaze hardware handoff for the AXI SPI system, but the original Vivado Block Design source (`design_1.bd`) was not included in the provided SPI files.

- `basys3_spi_master.xdc` : Basys3 I/O constraints used for the SPI Master FPGA test
- SPI pins : `SCLK`, `MOSI`, `MISO`, `CS_n`
