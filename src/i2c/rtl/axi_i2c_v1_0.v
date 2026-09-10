
`timescale 1 ns / 1 ps

module axi_i2c_v1_0 #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
) (
    // Users to add ports here
    output wire scl,
    inout  wire sda,

    output wire i2c_intr,

    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire s00_axi_awvalid,
    output wire s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire s00_axi_wvalid,
    output wire s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire s00_axi_bvalid,
    input wire s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire s00_axi_arvalid,
    output wire s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire s00_axi_rvalid,
    input wire s00_axi_rready
);

    wire        cmd_start;
    wire        cmd_write;
    wire        cmd_read;
    wire        cmd_stop;

    wire [ 7:0] tx_data;
    wire        ack_in;
    wire [15:0] clk_div;

    wire [ 7:0] rx_data;
    wire        done;
    wire        ack_out;
    wire        busy;

    wire        intr_en;


    assign i2c_intr = done && intr_en;


    // Instantiation of Axi Bus Interface S00_AXI
    axi_i2c_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) axi_i2c_v1_0_S00_AXI_inst (
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .ack_in(ack_in),
        .clk_div(clk_div),
        .rx_data(rx_data),
        .ack_out(ack_out),
        .busy(busy),

        .intr_en(intr_en),

        .S_AXI_ACLK(s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR(s00_axi_awaddr),
        .S_AXI_AWPROT(s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA(s00_axi_wdata),
        .S_AXI_WSTRB(s00_axi_wstrb),
        .S_AXI_WVALID(s00_axi_wvalid),
        .S_AXI_WREADY(s00_axi_wready),
        .S_AXI_BRESP(s00_axi_bresp),
        .S_AXI_BVALID(s00_axi_bvalid),
        .S_AXI_BREADY(s00_axi_bready),
        .S_AXI_ARADDR(s00_axi_araddr),
        .S_AXI_ARPROT(s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA(s00_axi_rdata),
        .S_AXI_RRESP(s00_axi_rresp),
        .S_AXI_RVALID(s00_axi_rvalid),
        .S_AXI_RREADY(s00_axi_rready)
    );

    // Add user logic here

    I2C_Master u_i2c (
        .clk (s00_axi_aclk),
        .rstn(s00_axi_aresetn),

        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .ack_in(ack_in),
        .clk_div(clk_div),

        .rx_data(rx_data),
        .done(done),
        .ack_out(ack_out),
        .busy(busy),

        .scl(scl),
        .sda(sda)
    );
    // User logic ends

endmodule

module I2C_Master (
    input wire clk,
    input wire rstn,

    //command port
    input wire         cmd_start,
    input wire         cmd_write,
    input wire         cmd_read,
    input wire         cmd_stop,
    input wire [07:00] tx_data,
    input wire         ack_in,
    input wire [15:00] clk_div,

    //internal output
    output wire [07:00] rx_data,
    output wire         done,
    output wire         ack_out,
    output wire         busy,

    //external i2c port
    output wire scl,
    inout  wire sda
);

    wire sda_o, sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_master u_i2c_master (

        .clk (clk),
        .rstn(rstn),

        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .ack_in(ack_in),
        .clk_div(clk_div),

        .rx_data(rx_data),
        .done(done),
        .ack_out(ack_out),
        .busy(busy),

        .scl  (scl),
        .sda_o(sda_o),
        .sda_i(sda_i)
    );

endmodule



module i2c_master (
    input wire clk,
    input wire rstn,

    //command port
    input wire         cmd_start,
    input wire         cmd_write,
    input wire         cmd_read,
    input wire         cmd_stop,
    input wire [07:00] tx_data,
    input wire         ack_in,
    input wire [15:00] clk_div,

    //internal output
    output reg  [07:00] rx_data,
    output reg          done,
    output reg          ack_out,
    output wire         busy,

    //external i2c port
    output wire scl,
    output wire sda_o,
    input  wire sda_i
);

    parameter IDLE = 3'd0, START = 3'd1, WAIT_CMD = 3'd2, DATA = 3'd3, DATA_ACK = 3'd4, STOP = 3'd5;

    reg [02:00] state;

    reg [15:00] div_cnt;
    reg         qtr_tick;
    reg scl_r, sda_r;
    reg [01:00] step;
    reg [07:00] tx_shift_reg;
    reg [07:00] rx_shift_reg;
    reg [02:00] bit_cnt;
    reg         is_read;
    reg         ack_in_r;


    assign scl   = scl_r;
    assign sda_o = sda_r;
    assign busy  = (state != IDLE);


    always @(posedge clk) begin
        if (!rstn) begin
            div_cnt  <= 0;
            qtr_tick <= 1'b0;
        end else begin
            if (state == IDLE) begin
                div_cnt <= 0;
                qtr_tick <= 1'b0;
            end
            else if (div_cnt == (clk_div - 1)) begin  //scl : 100Khz
                div_cnt  <= 0;
                qtr_tick <= 1'b1;
            end 
            else begin
                div_cnt  <= div_cnt + 1'b1;
                qtr_tick <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            state <= IDLE;
            scl_r <= 1'b1;
            sda_r <= 1'b1;
            step <= 0;
            done <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            is_read <= 1'b0;
            bit_cnt <= 0;
            ack_in_r <= 1'b1;
            rx_data <= 0;
            ack_out <= 0;

        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    scl_r <= 1'b1;
                    sda_r <= 1'b1;
                    //busy <= 1'b0;
                    if (cmd_start) begin
                        state <= START;
                        step  <= 0;
                        //busy <= 1'b1;
                    end
                end

                START: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                sda_r <= 1'b1;
                                scl_r <= 1'b1;
                                step  <= 2'd1;
                            end
                            2'd1: begin
                                sda_r <= 1'b0;
                                step  <= 2'd2;
                            end
                            2'd2: begin
                                step <= 2'd3;
                            end
                            2'd3: begin
                                scl_r <= 1'b0;
                                step  <= 2'd0;
                                done  <= 1'b1;
                                state <= WAIT_CMD;
                            end
                        endcase
                    end
                end

                WAIT_CMD: begin
                    step <= 0;
                    if (cmd_write) begin
                        tx_shift_reg <= tx_data;
                        bit_cnt <= 0;
                        is_read <= 1'b0;
                        state <= DATA;
                    end else if (cmd_read) begin
                        rx_shift_reg <= 0;
                        bit_cnt <= 0;
                        is_read <= 1'b1;
                        ack_in_r <= ack_in;
                        state <= DATA;
                    end else if (cmd_stop) begin
                        state <= STOP;
                    end else if (cmd_start) begin
                        state <= START;
                    end
                end

                DATA: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl_r <= 1'b0;
                                sda_r <= is_read ? 1'b1 : tx_shift_reg[7];
                                step  <= 2'd1;
                            end
                            2'd1: begin
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end
                            2'd2: begin
                                scl_r <= 1'b1;
                                if (is_read) begin
                                    rx_shift_reg <= {rx_shift_reg[6:0], sda_i};
                                end
                                step <= 2'd3;
                            end
                            2'd3: begin
                                scl_r <= 1'b0;
                                if (!is_read) begin
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end
                                step <= 2'd0;

                                if (bit_cnt == 7) begin
                                    state <= DATA_ACK;
                                end else begin
                                    bit_cnt <= bit_cnt + 1'b1;
                                end
                            end
                        endcase
                    end
                end

                DATA_ACK: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl_r <= 1'b0;
                                if (is_read) begin
                                    sda_r <= ack_in_r;
                                end else begin
                                    sda_r <= 1'b1;  // sda input setting
                                end
                                step <= 2'd1;
                            end
                            2'd1: begin
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end
                            2'd2: begin
                                scl_r <= 1'b1;
                                if (!is_read) begin
                                    ack_out <= sda_i;
                                end
                                if (is_read) begin
                                    rx_data <= rx_shift_reg;
                                end
                                step <= 2'd3;
                            end
                            2'd3: begin
                                scl_r <= 1'b0;
                                done  <= 1'b1;
                                step  <= 2'd0;
                                state <= WAIT_CMD;
                            end
                        endcase
                    end
                end


                STOP: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                sda_r <= 1'b0;
                                scl_r <= 1'b0;
                                step  <= 2'd1;
                            end
                            2'd1: begin
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end
                            2'd2: begin
                                sda_r <= 1'b1;
                                step  <= 2'd3;
                            end
                            2'd3: begin
                                step  <= 2'd0;
                                done  <= 1'b1;
                                state <= IDLE;
                            end
                        endcase
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end




endmodule

