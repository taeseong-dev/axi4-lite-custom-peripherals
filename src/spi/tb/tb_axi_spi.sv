`timescale 1ns / 1ps

module tb_axi_spi;

    // Register Address
    localparam [3:0] ADDR_SR   = 4'h0;
    localparam [3:0] ADDR_TXDR = 4'h4;
    localparam [3:0] ADDR_RXDR = 4'h8;
    localparam [3:0] ADDR_CR   = 4'hC;

    // CR
    localparam [31:0] CMD_START = 32'h0000_0001;
    localparam [31:0] INTR_EN   = 32'h0000_0008;

    // CLK_DIV = 4
    localparam [31:0] CLK_DIV_4 = 32'h0000_0400;

    // Mode 0 : CPOL = 0, CPHA = 0
    localparam [31:0] CR_BASE = CLK_DIV_4 | INTR_EN;

    reg s00_axi_aclk;
    reg s00_axi_aresetn;

    // AXI Write Address
    reg  [3:0] s00_axi_awaddr;
    reg  [2:0] s00_axi_awprot;
    reg        s00_axi_awvalid;
    wire       s00_axi_awready;

    // AXI Write Data
    reg  [31:0] s00_axi_wdata;
    reg  [3:0]  s00_axi_wstrb;
    reg         s00_axi_wvalid;
    wire        s00_axi_wready;

    // AXI Write Response
    wire [1:0] s00_axi_bresp;
    wire       s00_axi_bvalid;
    reg        s00_axi_bready;

    // AXI Read Address
    reg  [3:0] s00_axi_araddr;
    reg  [2:0] s00_axi_arprot;
    reg        s00_axi_arvalid;
    wire       s00_axi_arready;

    // AXI Read Data
    wire [31:0] s00_axi_rdata;
    wire [1:0]  s00_axi_rresp;
    wire        s00_axi_rvalid;
    reg         s00_axi_rready;

    // SPI
    wire sclk;
    wire mosi;
    wire miso;
    wire cs_n;
    wire spi_intr;

    // SPI Slave
    wire       slave_busy;
    wire       slave_done;
    wire [7:0] slave_rx_data;

    reg [31:0] read_data;
    integer test_error_count;

    // DUT : AXI SPI Master Peripheral
    axi_spi_v1_0 dut (
        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .cs_n    (cs_n),
        .spi_intr(spi_intr),

        .s00_axi_aclk   (s00_axi_aclk),
        .s00_axi_aresetn(s00_axi_aresetn),

        .s00_axi_awaddr (s00_axi_awaddr),
        .s00_axi_awprot (s00_axi_awprot),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_awready(s00_axi_awready),

        .s00_axi_wdata  (s00_axi_wdata),
        .s00_axi_wstrb  (s00_axi_wstrb),
        .s00_axi_wvalid (s00_axi_wvalid),
        .s00_axi_wready (s00_axi_wready),

        .s00_axi_bresp  (s00_axi_bresp),
        .s00_axi_bvalid (s00_axi_bvalid),
        .s00_axi_bready (s00_axi_bready),

        .s00_axi_araddr (s00_axi_araddr),
        .s00_axi_arprot (s00_axi_arprot),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_arready(s00_axi_arready),

        .s00_axi_rdata  (s00_axi_rdata),
        .s00_axi_rresp  (s00_axi_rresp),
        .s00_axi_rvalid (s00_axi_rvalid),
        .s00_axi_rready (s00_axi_rready)
    );

    // SPI Slave
    spi_slave u_spi_slave (
        .clk    (s00_axi_aclk),
        .rst    (~s00_axi_aresetn),
        .sclk   (sclk),
        .cs     (cs_n),
        .mosi   (mosi),
        .miso   (miso),
        .busy   (slave_busy),
        .done   (slave_done),
        .rx_data(slave_rx_data)
    );

    // 100 MHz Clock
    always #5 s00_axi_aclk = ~s00_axi_aclk;

    task axi_write;
        input [3:0]  addr;
        input [31:0] data;
        begin
            @(posedge s00_axi_aclk);
            s00_axi_awaddr  <= addr;
            s00_axi_awvalid <= 1'b1;
            s00_axi_wdata   <= data;
            s00_axi_wstrb   <= 4'hF;
            s00_axi_wvalid  <= 1'b1;

            wait (s00_axi_awready && s00_axi_wready);
            @(posedge s00_axi_aclk);
            s00_axi_awvalid <= 1'b0;
            s00_axi_wvalid  <= 1'b0;

            s00_axi_bready <= 1'b1;
            wait (s00_axi_bvalid);
            @(posedge s00_axi_aclk);
            s00_axi_bready <= 1'b0;

            $display("[%0t] AXI WRITE : ADDR = 0x%h, DATA = 0x%h", $time, addr, data);
        end
    endtask

    task axi_read;
        input  [3:0]  addr;
        output [31:0] data;
        begin
            @(posedge s00_axi_aclk);
            s00_axi_araddr  <= addr;
            s00_axi_arvalid <= 1'b1;
            s00_axi_rready  <= 1'b1;

            wait (s00_axi_arready);
            @(posedge s00_axi_aclk);
            s00_axi_arvalid <= 1'b0;

            wait (s00_axi_rvalid);
            data = s00_axi_rdata;
            @(posedge s00_axi_aclk);
            s00_axi_rready <= 1'b0;

            $display("[%0t] AXI READ  : ADDR = 0x%h, DATA = 0x%h", $time, addr, data);
        end
    endtask

    initial begin
        s00_axi_aclk    = 0;
        s00_axi_aresetn = 0;
        s00_axi_awaddr  = 0;
        s00_axi_awprot  = 0;
        s00_axi_awvalid = 0;
        s00_axi_wdata   = 0;
        s00_axi_wstrb   = 0;
        s00_axi_wvalid  = 0;
        s00_axi_bready  = 0;
        s00_axi_araddr  = 0;
        s00_axi_arprot  = 0;
        s00_axi_arvalid = 0;
        s00_axi_rready  = 0;
        read_data = 0;
        test_error_count = 0;

        // Reset
        repeat (10) @(posedge s00_axi_aclk);
        s00_axi_aresetn = 1;
        repeat (5) @(posedge s00_axi_aclk);

        // SPI Configuration: Mode 0, CLK_DIV = 4, Interrupt Enable
        axi_write(ADDR_CR, CR_BASE);

        // First Transfer: Master TX A5 / Master RX 00 / Slave RX A5
        axi_write(ADDR_TXDR, 32'h0000_00A5);
        axi_read(ADDR_CR, read_data);
        axi_write(ADDR_CR, read_data | CMD_START);

        wait (spi_intr == 1'b1);
        $display("[%0t] SPI TRANSFER #1 DONE", $time);
        wait (slave_done == 1'b1);

        if (slave_rx_data !== 8'hA5) begin
            $display("ERROR : Slave RX = 0x%h, Expected = 0xA5", slave_rx_data);
            test_error_count = test_error_count + 1;
        end

        axi_read(ADDR_RXDR, read_data);
        if (read_data[7:0] !== 8'h00) begin
            $display("ERROR : Master RX = 0x%h, Expected = 0x00", read_data[7:0]);
            test_error_count = test_error_count + 1;
        end

        repeat (5) @(posedge s00_axi_aclk);

        // Second Transfer: Master TX 3C / Master RX A5 / Slave RX 3C
        axi_write(ADDR_TXDR, 32'h0000_003C);
        axi_read(ADDR_CR, read_data);
        axi_write(ADDR_CR, read_data | CMD_START);

        wait (spi_intr == 1'b1);
        $display("[%0t] SPI TRANSFER #2 DONE", $time);
        wait (slave_done == 1'b1);

        if (slave_rx_data !== 8'h3C) begin
            $display("ERROR : Slave RX = 0x%h, Expected = 0x3C", slave_rx_data);
            test_error_count = test_error_count + 1;
        end

        axi_read(ADDR_RXDR, read_data);
        if (read_data[7:0] !== 8'hA5) begin
            $display("ERROR : Master RX = 0x%h, Expected = 0xA5", read_data[7:0]);
            test_error_count = test_error_count + 1;
        end

        repeat (10) @(posedge s00_axi_aclk);

        if (test_error_count == 0) begin
            $display("============================");
            $display("        SPI TEST PASS");
            $display("============================");
        end else begin
            $display("============================");
            $display(" SPI TEST FAIL : ERROR = %0d", test_error_count);
            $display("============================");
        end

        $finish;
    end

endmodule
