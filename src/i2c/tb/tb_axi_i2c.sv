`timescale 1ns / 1ps

module tb_axi_i2c;

    // Test Select
    // 0 : ALL
    // 1 : WRITE
    // 2 : READ
    // 3 : Interrupt Disable
    // 4 : NACK
    // 5 : Multi Write
    // 6 : Write + Read Sequence
    integer TEST_SEL = 6;

    // Register Address
    localparam [3:0] ADDR_SR   = 4'h0;
    localparam [3:0] ADDR_TXDR = 4'h4;
    localparam [3:0] ADDR_RXDR = 4'h8;
    localparam [3:0] ADDR_CR   = 4'hC;

    // CR Command
    localparam [31:0] CMD_START = 32'h0000_0001;
    localparam [31:0] CMD_WRITE = 32'h0000_0002;
    localparam [31:0] CMD_READ = 32'h0000_0004;
    localparam [31:0] CMD_STOP = 32'h0000_0008;

    localparam [31:0] ACK_IN = 32'h0000_0010;
    localparam [31:0] INTR_EN = 32'h0000_0020;

    // clk_div = 2
    localparam [31:0] CLK_DIV_2 = 32'h0000_0200;

    // Default CR Value
    localparam [31:0] CR_BASE = CLK_DIV_2 | INTR_EN;

    // Timeout (100 MHz system clock)
    localparam integer AXI_TIMEOUT_CYCLES = 1000;
    localparam integer CMD_TIMEOUT_CYCLES = 10000;

    reg            s00_axi_aclk;
    reg            s00_axi_aresetn;

    // AXI Write Address Channel
    reg     [ 3:0] s00_axi_awaddr;
    reg     [ 2:0] s00_axi_awprot;
    reg            s00_axi_awvalid;
    wire           s00_axi_awready;

    // AXI Write Data Channel
    reg     [31:0] s00_axi_wdata;
    reg     [ 3:0] s00_axi_wstrb;
    reg            s00_axi_wvalid;
    wire           s00_axi_wready;

    // AXI Write Response Channel
    wire    [ 1:0] s00_axi_bresp;
    wire           s00_axi_bvalid;
    reg            s00_axi_bready;

    // AXI Read Address Channel
    reg     [ 3:0] s00_axi_araddr;
    reg     [ 2:0] s00_axi_arprot;
    reg            s00_axi_arvalid;
    wire           s00_axi_arready;

    // AXI Read Response Channel
    wire    [31:0] s00_axi_rdata;
    wire    [ 1:0] s00_axi_rresp;
    wire           s00_axi_rvalid;
    reg            s00_axi_rready;

    wire           scl;
    tri1           sda;
    wire           i2c_intr;

    // I2C Slave Signal
    wire           slave_done;
    wire    [ 7:0] slave_rx_data;

    reg     [31:0] read_data;

    integer        test_error_count;
    integer        total_test_fail;

    // AXI I2C Master Peripheral
    axi_i2c_v1_0 dut (
        .scl     (scl),
        .sda     (sda),
        .i2c_intr(i2c_intr),

        .s00_axi_aclk   (s00_axi_aclk),
        .s00_axi_aresetn(s00_axi_aresetn),

        .s00_axi_awaddr (s00_axi_awaddr),
        .s00_axi_awprot (s00_axi_awprot),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_awready(s00_axi_awready),

        .s00_axi_wdata (s00_axi_wdata),
        .s00_axi_wstrb (s00_axi_wstrb),
        .s00_axi_wvalid(s00_axi_wvalid),
        .s00_axi_wready(s00_axi_wready),

        .s00_axi_bresp (s00_axi_bresp),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_bready(s00_axi_bready),

        .s00_axi_araddr (s00_axi_araddr),
        .s00_axi_arprot (s00_axi_arprot),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_arready(s00_axi_arready),

        .s00_axi_rdata (s00_axi_rdata),
        .s00_axi_rresp (s00_axi_rresp),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_rready(s00_axi_rready)
    );

    // I2C Slave, Slave Address = 7'h12
    I2C_Slave u_i2c_slave (
        .clk(s00_axi_aclk),
        .rst(~s00_axi_aresetn),

        .done   (slave_done),
        .rx_data(slave_rx_data),

        .scl(scl),
        .sda(sda)
    );

    // 100 MHz Clock
    initial begin
        s00_axi_aclk = 1'b0;
        forever #5 s00_axi_aclk = ~s00_axi_aclk;
    end

    // Reset Task
    task reset_dut;
        begin
            s00_axi_aresetn = 1'b0;

            s00_axi_awaddr  = 0;
            s00_axi_awprot  = 0;
            s00_axi_awvalid = 0;

            s00_axi_wdata   = 0;
            s00_axi_wstrb   = 0;
            s00_axi_wvalid  = 0;

            s00_axi_bready  = 1'b1;

            s00_axi_araddr  = 0;
            s00_axi_arprot  = 0;
            s00_axi_arvalid = 0;

            s00_axi_rready  = 1'b1;

            repeat (5) @(posedge s00_axi_aclk);
            s00_axi_aresetn = 1'b1;
            repeat (5) @(posedge s00_axi_aclk);
        end
    endtask

    // AXI Write Task
    task axi_write;
        input [3:0] addr;
        input [31:0] data;
        integer wait_count;

        begin
            @(posedge s00_axi_aclk);

            s00_axi_awaddr  <= addr;
            s00_axi_awvalid <= 1'b1;

            s00_axi_wdata   <= data;
            s00_axi_wstrb   <= 4'b1111;
            s00_axi_wvalid  <= 1'b1;

            // AW / W Handshake
            wait_count = 0;
            while (!(s00_axi_awready && s00_axi_wready)) begin
                @(posedge s00_axi_aclk);
                wait_count = wait_count + 1;

                if (wait_count >= AXI_TIMEOUT_CYCLES) begin
                    $display("[%0t] FATAL : AXI Write Handshake Timeout", $time);
                    $finish;
                end
            end

            s00_axi_awvalid <= 1'b0;
            s00_axi_wvalid  <= 1'b0;

            // Write Response
            wait_count = 0;
            while (!s00_axi_bvalid) begin
                @(posedge s00_axi_aclk);
                wait_count = wait_count + 1;

                if (wait_count >= AXI_TIMEOUT_CYCLES) begin
                    $display("[%0t] FATAL : AXI Write Response Timeout", $time);
                    $finish;
                end
            end

            // BRESP Check
            if (s00_axi_bresp !== 2'b00) begin
                $display("[%0t] ERROR : AXI BRESP = %b", $time, s00_axi_bresp);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            $display("[%0t] AXI WRITE : ADDR = 0x%h, DATA = 0x%h", $time, addr,
                     data);
        end
    endtask

    // AXI Read Task
    task axi_read;
        input [3:0] addr;
        output [31:0] data;
        integer wait_count;

        begin
            @(posedge s00_axi_aclk);

            s00_axi_araddr  <= addr;
            s00_axi_arvalid <= 1'b1;

            // AR Handshake
            wait_count = 0;
            while (!s00_axi_arready) begin
                @(posedge s00_axi_aclk);
                wait_count = wait_count + 1;

                if (wait_count >= AXI_TIMEOUT_CYCLES) begin
                    $display("[%0t] FATAL : AXI Read Address Timeout", $time);
                    $finish;
                end
            end

            s00_axi_arvalid <= 1'b0;

            // Read Response
            wait_count = 0;
            while (!s00_axi_rvalid) begin
                @(posedge s00_axi_aclk);
                wait_count = wait_count + 1;

                if (wait_count >= AXI_TIMEOUT_CYCLES) begin
                    $display("[%0t] FATAL : AXI Read Response Timeout", $time);
                    $finish;
                end
            end

            data = s00_axi_rdata;

            // RRESP Check
            if (s00_axi_rresp !== 2'b00) begin
                $display("[%0t] ERROR : AXI RRESP = %b", $time, s00_axi_rresp);
                test_error_count = test_error_count + 1;
            end

            $display("[%0t] AXI READ  : ADDR = 0x%h, DATA = 0x%h", $time, addr,
                     data);

            @(posedge s00_axi_aclk);
        end
    endtask

    // SR Check Task
    task check_sr;
        input expected_busy;
        input expected_ack;

        reg [31:0] sr_data;

        begin
            axi_read(ADDR_SR, sr_data);

            // SR[0] = BUSY
            if (sr_data[0] !== expected_busy) begin
                $display("[%0t] ERROR : BUSY = %b, Expected = %b", $time,
                         sr_data[0], expected_busy);
                test_error_count = test_error_count + 1;
            end

            // SR[1] = ACK_OUT
            if (sr_data[1] !== expected_ack) begin
                $display("[%0t] ERROR : ACK_OUT = %b, Expected = %b", $time,
                         sr_data[1], expected_ack);
                test_error_count = test_error_count + 1;
            end
        end
    endtask

    // CR Read-Modify-Write Task
    // Mirrors the software pattern: CR |= command / control bit
    task i2c_cr_or;
        input [31:0] mask;
        reg [31:0] cr_data;
        begin
            axi_read(ADDR_CR, cr_data);
            axi_write(ADDR_CR, cr_data | mask);
        end
    endtask

    // Wait for I2C interrupt with timeout
    task wait_i2c_intr;
        integer wait_count;
        begin
            wait_count = 0;

            while ((i2c_intr !== 1'b1) &&
                   (wait_count < CMD_TIMEOUT_CYCLES)) begin
                @(posedge s00_axi_aclk);
                wait_count = wait_count + 1;
            end

            if (i2c_intr !== 1'b1) begin
                $display("[%0t] FATAL : I2C Interrupt Timeout", $time);
                $finish;
            end
        end
    endtask

    // Used only when interrupt is disabled
    task wait_i2c_done;
        integer wait_count;
        begin
            wait_count = 0;

            while ((dut.done !== 1'b1) &&
                   (wait_count < CMD_TIMEOUT_CYCLES)) begin
                @(posedge s00_axi_aclk);
                wait_count = wait_count + 1;
            end

            if (dut.done !== 1'b1) begin
                $display("[%0t] FATAL : I2C Done Timeout", $time);
                $finish;
            end
        end
    endtask

    // I2C Write Test
    task test_write;
        begin
            test_error_count = 0;

            $display("\n===== WRITE TEST =====");

            // Initial Setting
            axi_write(ADDR_CR, CR_BASE);

            // 1. START
            i2c_cr_or(CMD_START);

            wait_i2c_intr();
            $display("[%0t] START DONE", $time);

            @(posedge s00_axi_aclk);

            // 2. Write (Slave Address + WRITE)
            // Write Data = {7'h12, 1'b0} = 8'h24
            axi_write(ADDR_TXDR, 32'h0000_0024);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] ADDRESS WRITE DONE, ACK_OUT = %b", $time,
                     dut.ack_out);

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Slave Address NACK", $time);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 3. Actual Data Write
            // Write Data = 8'h55
            axi_write(ADDR_TXDR, 32'h0000_0055);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] DATA WRITE DONE, ACK_OUT = %b, SLAVE RX = 0x%h",
                     $time, dut.ack_out, slave_rx_data);

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Data NACK", $time);
                test_error_count = test_error_count + 1;
            end

            if (slave_rx_data !== 8'h55) begin
                $display("[%0t] ERROR : Slave RX = 0x%h, Expected = 0x55",
                         $time, slave_rx_data);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 4. SR Read
            // Before STOP : BUSY = 1, ACK_OUT = 0
            check_sr(1'b1, 1'b0);

            // 5. STOP
            i2c_cr_or(CMD_STOP);

            wait_i2c_intr();
            $display("[%0t] STOP DONE", $time);

            repeat (5) @(posedge s00_axi_aclk);

            // 6. SR Read
            // After STOP : BUSY = 0, ACK_OUT = 0
            check_sr(1'b0, 1'b0);

            // Write Test Result
            if (test_error_count == 0) $display("PASS : WRITE TEST");
            else begin
                $display("FAIL : WRITE TEST, ERROR COUNT = %0d",
                         test_error_count);
                total_test_fail = total_test_fail + 1;
            end
        end
    endtask

    // I2C Read Test
    task test_read;
        begin
            test_error_count = 0;

            $display("\n===== READ TEST =====");

            // Initial Setting
            axi_write(ADDR_CR, CR_BASE);

            // 1. START
            i2c_cr_or(CMD_START);

            wait_i2c_intr();
            $display("[%0t] START DONE", $time);

            @(posedge s00_axi_aclk);

            // 2. Write (Slave Address + READ)
            // Write Data = {7'h12, 1'b1} = 8'h25
            axi_write(ADDR_TXDR, 32'h0000_0025);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] ADDRESS READ DONE, ACK_OUT = %b", $time,
                     dut.ack_out);

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Slave Address NACK", $time);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 3. Data Read
            // CR[4] = ack_in = 1, Last Byte NACK
            i2c_cr_or(ACK_IN);
            i2c_cr_or(CMD_READ);

            wait_i2c_intr();
            $display("[%0t] DATA READ DONE", $time);

            @(posedge s00_axi_aclk);

            // 4. RXDR Read
            axi_read(ADDR_RXDR, read_data);

            // Slave Reset Value = 8'h77
            if (read_data[7:0] !== 8'h77) begin
                $display("[%0t] ERROR : Master RX = 0x%h, Expected = 0x77",
                         $time, read_data[7:0]);
                test_error_count = test_error_count + 1;
            end

            // 5. SR Read
            // Before STOP : BUSY = 1, ACK_OUT = 0
            check_sr(1'b1, 1'b0);

            // 6. STOP
            i2c_cr_or(CMD_STOP);

            wait_i2c_intr();
            $display("[%0t] STOP DONE", $time);

            repeat (5) @(posedge s00_axi_aclk);

            // 7. SR Read
            // After STOP : BUSY = 0, ACK_OUT = 0
            check_sr(1'b0, 1'b0);

            // Read Test Result
            if (test_error_count == 0) $display("PASS : READ TEST");
            else begin
                $display("FAIL : READ TEST, ERROR COUNT = %0d",
                         test_error_count);
                total_test_fail = total_test_fail + 1;
            end
        end
    endtask

    // Interrupt Disable Test
    task test_intr_disable;

        reg [31:0] cr_no_intr;

        begin
            test_error_count = 0;

            $display("\n===== INTERRUPT DISABLE TEST =====");

            // CR[23:8] = clk_div = 2
            // CR[5]    = intr_en = 0
            cr_no_intr = CLK_DIV_2;

            // Initial Setting (Interrupt Disable)
            axi_write(ADDR_CR, cr_no_intr);

            // 1. START
            i2c_cr_or(CMD_START);

            wait_i2c_done();

            #1;

            if (i2c_intr !== 1'b0) begin
                $display("[%0t] ERROR : START Interrupt Asserted", $time);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 2. Write (Slave Address + WRITE)
            // Write Data = {7'h12, 1'b0} = 8'h24
            axi_write(ADDR_TXDR, 32'h0000_0024);

            i2c_cr_or(CMD_WRITE);

            wait_i2c_done();

            #1;

            if (i2c_intr !== 1'b0) begin
                $display("[%0t] ERROR : ADDRESS Interrupt Asserted", $time);
                test_error_count = test_error_count + 1;
            end

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Slave Address NACK", $time);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 3. Actual Data Write
            // Write Data = 8'h55
            axi_write(ADDR_TXDR, 32'h0000_0055);

            i2c_cr_or(CMD_WRITE);

            wait_i2c_done();

            #1;

            if (i2c_intr !== 1'b0) begin
                $display("[%0t] ERROR : DATA Interrupt Asserted", $time);
                test_error_count = test_error_count + 1;
            end

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Data NACK", $time);
                test_error_count = test_error_count + 1;
            end

            if (slave_rx_data !== 8'h55) begin
                $display("[%0t] ERROR : Slave RX = 0x%h, Expected = 0x55",
                         $time, slave_rx_data);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 4. SR Read
            // Before STOP : BUSY = 1, ACK_OUT = 0
            check_sr(1'b1, 1'b0);

            // 5. STOP
            i2c_cr_or(CMD_STOP);

            wait_i2c_done();

            #1;

            if (i2c_intr !== 1'b0) begin
                $display("[%0t] ERROR : STOP Interrupt Asserted", $time);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 6. SR Read
            // After STOP : BUSY = 0, ACK_OUT = 0
            check_sr(1'b0, 1'b0);

            // Interrupt Disable Test Result
            if (test_error_count == 0)
                $display("PASS : INTERRUPT DISABLE TEST");
            else begin
                $display("FAIL : INTERRUPT DISABLE TEST, ERROR COUNT = %0d",
                         test_error_count);
                total_test_fail = total_test_fail + 1;
            end
        end

    endtask

    // NACK Test
    task test_nack;
        begin
            test_error_count = 0;

            $display("\n===== NACK TEST =====");

            // Initial Setting
            axi_write(ADDR_CR, CR_BASE);

            // 1. START
            i2c_cr_or(CMD_START);

            wait_i2c_intr();
            $display("[%0t] START DONE", $time);

            @(posedge s00_axi_aclk);

            // 2. Invalid Slave Address + WRITE
            // Slave Address = 7'h13
            // Write Data = {7'h13, 1'b0} = 8'h26
            axi_write(ADDR_TXDR, 32'h0000_0026);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] ADDRESS WRITE DONE, ACK_OUT = %b", $time,
                     dut.ack_out);

            // NACK Check
            if (dut.ack_out !== 1'b1) begin
                $display("[%0t] ERROR : ACK_OUT = %b, Expected NACK", $time,
                         dut.ack_out);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 3. SR Read
            // Before STOP : BUSY = 1, ACK_OUT = 1
            check_sr(1'b1, 1'b1);

            // 4. STOP
            i2c_cr_or(CMD_STOP);

            wait_i2c_intr();
            $display("[%0t] STOP DONE", $time);

            repeat (5) @(posedge s00_axi_aclk);

            // 5. SR Read
            // After STOP : BUSY = 0, ACK_OUT = 1
            check_sr(1'b0, 1'b1);

            // NACK Test Result
            if (test_error_count == 0) $display("PASS : NACK TEST");
            else begin
                $display("FAIL : NACK TEST, ERROR COUNT = %0d",
                         test_error_count);
                total_test_fail = total_test_fail + 1;
            end
        end
    endtask

    // Multi Write Test
    task test_multi_write;
        begin
            test_error_count = 0;

            $display("\n===== MULTI WRITE TEST =====");

            // Initial Setting
            axi_write(ADDR_CR, CR_BASE);

            // 1. START
            i2c_cr_or(CMD_START);

            wait_i2c_intr();
            $display("[%0t] START DONE", $time);

            @(posedge s00_axi_aclk);

            // 2. Write (Slave Address + WRITE)
            // Write Data = {7'h12, 1'b0} = 8'h24
            axi_write(ADDR_TXDR, 32'h0000_0024);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] ADDRESS WRITE DONE, ACK_OUT = %b", $time,
                     dut.ack_out);

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Slave Address NACK", $time);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 3. Data Write #1
            // Write Data = 8'h11
            axi_write(ADDR_TXDR, 32'h0000_0011);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] DATA #1 DONE, ACK_OUT = %b, SLAVE RX = 0x%h",
                     $time, dut.ack_out, slave_rx_data);

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Data #1 NACK", $time);
                test_error_count = test_error_count + 1;
            end

            if (slave_rx_data !== 8'h11) begin
                $display("[%0t] ERROR : Data #1 RX = 0x%h, Expected = 0x11",
                         $time, slave_rx_data);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 4. Data Write #2
            // Write Data = 8'h22
            axi_write(ADDR_TXDR, 32'h0000_0022);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] DATA #2 DONE, ACK_OUT = %b, SLAVE RX = 0x%h",
                     $time, dut.ack_out, slave_rx_data);

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Data #2 NACK", $time);
                test_error_count = test_error_count + 1;
            end

            if (slave_rx_data !== 8'h22) begin
                $display("[%0t] ERROR : Data #2 RX = 0x%h, Expected = 0x22",
                         $time, slave_rx_data);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 5. Data Write #3
            // Write Data = 8'h33
            axi_write(ADDR_TXDR, 32'h0000_0033);
            i2c_cr_or(CMD_WRITE);

            wait_i2c_intr();

            $display("[%0t] DATA #3 DONE, ACK_OUT = %b, SLAVE RX = 0x%h",
                     $time, dut.ack_out, slave_rx_data);

            if (dut.ack_out !== 1'b0) begin
                $display("[%0t] ERROR : Data #3 NACK", $time);
                test_error_count = test_error_count + 1;
            end

            if (slave_rx_data !== 8'h33) begin
                $display("[%0t] ERROR : Data #3 RX = 0x%h, Expected = 0x33",
                         $time, slave_rx_data);
                test_error_count = test_error_count + 1;
            end

            @(posedge s00_axi_aclk);

            // 6. SR Read
            // Before STOP : BUSY = 1, ACK_OUT = 0
            check_sr(1'b1, 1'b0);

            // 7. STOP
            i2c_cr_or(CMD_STOP);

            wait_i2c_intr();
            $display("[%0t] STOP DONE", $time);

            repeat (5) @(posedge s00_axi_aclk);

            // 8. SR Read
            // After STOP : BUSY = 0, ACK_OUT = 0
            check_sr(1'b0, 1'b0);

            // Multi Write Test Result
            if (test_error_count == 0) $display("PASS : MULTI WRITE TEST");
            else begin
                $display("FAIL : MULTI WRITE TEST, ERROR COUNT = %0d",
                         test_error_count);
                total_test_fail = total_test_fail + 1;
            end
        end
    endtask


    // Write + Read Sequence Test
    task test_write_read;
        reg [31:0] sr_data;
        begin
            test_error_count = 0;

            $display("\n===== WRITE + READ TEST =====");

            // Initial Setting
            axi_write(ADDR_CR, CR_BASE);


            // =========================
            // WRITE
            // =========================

            // START
            i2c_cr_or(CMD_START);
            wait_i2c_intr();
            @(posedge s00_axi_aclk);

            // Slave Address + WRITE
            axi_write(ADDR_TXDR, 32'h0000_0024);
            i2c_cr_or(CMD_WRITE);
            wait_i2c_intr();
            @(posedge s00_axi_aclk);

            // ACK Check
            axi_read(ADDR_SR, sr_data);

            if (sr_data[1] !== 1'b0) begin
                $display("[%0t] ERROR : Write Address NACK", $time);
                test_error_count = test_error_count + 1;
            end

            // Data Write
            axi_write(ADDR_TXDR, 32'h0000_0055);
            i2c_cr_or(CMD_WRITE);
            wait_i2c_intr();
            @(posedge s00_axi_aclk);

            // STOP
            i2c_cr_or(CMD_STOP);
            wait_i2c_intr();

            repeat (5) @(posedge s00_axi_aclk);


            // =========================
            // READ
            // =========================

            // START
            i2c_cr_or(CMD_START);
            wait_i2c_intr();
            @(posedge s00_axi_aclk);

            // Slave Address + READ
            axi_write(ADDR_TXDR, 32'h0000_0025);
            i2c_cr_or(CMD_WRITE);
            wait_i2c_intr();
            @(posedge s00_axi_aclk);

            // ACK Check
            axi_read(ADDR_SR, sr_data);

            if (sr_data[1] !== 1'b0) begin
                $display("[%0t] ERROR : Read Address NACK", $time);
                test_error_count = test_error_count + 1;
            end

            // Last Byte NACK
            i2c_cr_or(ACK_IN);

            // Data Read
            i2c_cr_or(CMD_READ);
            wait_i2c_intr();
            @(posedge s00_axi_aclk);

            // RXDR Read
            axi_read(ADDR_RXDR, read_data);

            if (read_data[7:0] !== 8'h55) begin
                $display("[%0t] ERROR : Master RX = 0x%h, Expected = 0x55",
                         $time, read_data[7:0]);
                test_error_count = test_error_count + 1;
            end

            // STOP
            i2c_cr_or(CMD_STOP);
            wait_i2c_intr();


            // Test Result
            if (test_error_count == 0) $display("PASS : WRITE + READ TEST");
            else begin
                $display("FAIL : WRITE + READ TEST, ERROR COUNT = %0d",
                         test_error_count);
                total_test_fail = total_test_fail + 1;
            end
        end
    endtask

    initial begin
        total_test_fail = 0;

        case (TEST_SEL)

            // ALL Test
            0: begin
                reset_dut();
                test_write();

                reset_dut();
                test_read();

                reset_dut();
                test_intr_disable();

                reset_dut();
                test_nack();

                reset_dut();
                test_multi_write();

                reset_dut();
                test_write_read();
            end

            // Write Test
            1: begin
                reset_dut();
                test_write();
            end

            // Read Test
            2: begin
                reset_dut();
                test_read();
            end

            // Interrupt Disable Test
            3: begin
                reset_dut();
                test_intr_disable();
            end

            // NACK Test
            4: begin
                reset_dut();
                test_nack();
            end

            // Multi Write Test
            5: begin
                reset_dut();
                test_multi_write();
            end

            // Write + Read Sequence Test
            6: begin
                reset_dut();
                test_write_read();
            end

            default: begin
                $display("ERROR : Invalid TEST_SEL = %0d", TEST_SEL);
                total_test_fail = total_test_fail + 1;
            end
        endcase

        repeat (10) @(posedge s00_axi_aclk);

        if (TEST_SEL == 0) begin
            $display("\n===== ALL TEST RESULT =====");

            if (total_test_fail == 0) $display("PASS : ALL TEST");
            else
                $display(
                    "FAIL : ALL TEST, FAILED TEST COUNT = %0d", total_test_fail
                );
        end

        $finish;
    end

endmodule
