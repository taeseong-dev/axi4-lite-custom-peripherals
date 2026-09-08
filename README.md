# AXI4-Lite Custom Peripheral Design

Vivado의 AXI4-Lite Slave Interface에 I2C / SPI Master IP를 연결하고, <br>
Vitis에서 작성한 C 코드로 MicroBlaze에서 각 IP를 제어한 프로젝트입니다.

---

## Overview

| 항목 | 내용 |
|:---|:---|
| Language | Verilog, C |
| CPU | MicroBlaze |
| Bus | AMBA AXI4-Lite |
| Peripheral | I2C Master, SPI Master |
| Interface | I2C, SPI |
| Development Environment | Vivado, Vitis |
| FPGA Board | Basys3 |

---

## Contents

- [System Architecture](#system-architecture)
- [AXI4-Lite Interface](#axi4-lite-interface)
  - [AXI4-Lite Protocol](#axi4-lite-protocol)
  - [Write / Read Transaction](#write--read-transaction)
- [I2C Master](#i2c-master)
  - [I2C Architecture](#i2c-architecture)
  - [I2C Register Map](#i2c-register-map)
  - [I2C Master FSM](#i2c-master-fsm)
  - [I2C Software Driver](#i2c-software-driver)
  - [I2C FPGA Test](#i2c-fpga-test)
- [SPI Master](#spi-master)
  - [SPI Architecture](#spi-architecture)
  - [SPI Register Map](#spi-register-map)
  - [SPI Master FSM](#spi-master-fsm)
  - [SPI Software Driver](#spi-software-driver)
  - [SPI FPGA Test](#spi-fpga-test)

---

## System Architecture

<img src="images/axi_architecture.png" width="700">

- MicroBlaze 기반 시스템에서 AXI4-Lite를 통해 Memory-Mapped Peripheral의 Register에 접근
- MicroBlaze와 GPIO, Timer, I2C Master, AXI Interrupt Controller는 AXI Interconnect를 통해 연결
- GPIO를 통해 Switch / Button 입력을 읽고 FND 출력 제어
- Timer와 I2C Master에서 발생한 IRQ를 AXI Interrupt Controller에 연결
- Vivado의 AXI Interrupt Controller IP를 통해 Peripheral Interrupt를 MicroBlaze에서 처리
- I2C Master의 `SCL`, `SDA`를 통해 외부 I2C Slave와 통신

## AXI4-Lite Interface

### AXI4-Lite Protocol

AXI4-Lite는 Memory-Mapped Peripheral의 Register 접근에 사용되는 Interface입니다.

본 프로젝트에서는 Vivado에서 생성한 AXI4-Lite Slave Interface를 사용하여 Register와 I2C Master IP를 연결하였습니다.

<img src="images/axi_interface.png" width="700">

| Channel | 주요 신호 | 설명 |
|:---|:---|:---|
| Write Address | `AWADDR`, `AWVALID`, `AWREADY` | Write Address 전달 |
| Write Data | `WDATA`, `WVALID`, `WREADY` | Write Data 전달 |
| Write Response | `BRESP`, `BVALID`, `BREADY` | Write Response 전달 |
| Read Address | `ARADDR`, `ARVALID`, `ARREADY` | Read Address 전달 |
| Read Data | `RDATA`, `RRESP`, `RVALID`, `RREADY` | Read Data / Response 전달 |

- 각 Channel은 `VALID` / `READY` Handshake를 통해 Transfer 수행
- AXI4-Lite는 Burst Transfer를 지원하지 않으며 Single Transfer 방식으로 동작

### Write Transfer

<img src="images/axi_write_svg.svg" width="700">

- `AWVALID` / `AWREADY` Handshake를 통해 Write Address 전달
- `WVALID` / `WREADY` Handshake를 통해 Write Data 전달
- Address와 Data가 수신되면 `slv_reg_wren`이 활성화되어 Register Write 수행
- `BVALID` / `BREADY` Handshake를 통해 Write Response 전달

> `slv_reg_wren`은 Vivado AXI4-Lite Slave Interface 내부에서 Register Write 시 사용되는 신호입니다.

### Read Transfer

<img src="images/axi_read_svg.svg" width="700">

- `ARVALID` / `ARREADY` Handshake를 통해 Read Address 전달
- Address가 수신되면 `slv_reg_rden`이 활성화되어 해당 Register Data 선택
- `RVALID` / `RREADY` Handshake를 통해 Read Data와 Response 전달

> `slv_reg_rden`은 Vivado AXI4-Lite Slave Interface 내부에서 Register Read 시 사용되는 신호입니다.
