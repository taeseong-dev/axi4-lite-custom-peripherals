# SPI Master FPGA Hardware

The SPI Master FPGA system was built in Vivado and exported as `axi_spi.xsa` for use in Vitis. The original Vivado Block Design source (`design_1.bd`) was not included in the archived SPI project used for this repository, so the board constraints are provided here instead of the Block Design source.

- `basys3_spi_master.xdc` : Basys3 I/O constraints used for the SPI Master FPGA test
- SPI pins : `SCLK`, `MOSI`, `MISO`, `CS_n`
