`timescale 1ns / 1ps

module I2C_Slave (
    input logic clk,
    input logic rst,

    output logic         done,
    output logic [07:00] rx_data,

    //external i2c port
    input logic scl,
    inout wire  sda
);

    logic sda_o, sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_slave u_i2c_slave (
        .clk(clk),
        .rst(rst),
        .scl(scl),

        .done(done),
        .rx_data(rx_data),

        .sda_o(sda_o),
        .sda_i(sda_i)
    );

endmodule

module i2c_slave (

    input logic clk,
    input logic rst,

    output logic         done,
    output logic [07:00] rx_data,

    input  logic scl,
    input  logic sda_i,
    output logic sda_o

    //external i2c port
);

    localparam SLV_ADDR = 7'b001_0010;

    logic scl_dly0;
    logic scl_dly1;
    logic sda_dly0;
    logic sda_dly1;

    logic [07:00] data;
    logic [03:00] data_cnt;

    logic [06:00] addr;

    logic read;

    logic scl_dly0_r;
    logic scl_dly0_f;
    logic sda_dly0_r;
    logic sda_dly0_f;

    assign scl_dly0_r = scl_dly0 && ~scl_dly1;
    assign scl_dly0_f = ~scl_dly0 && scl_dly1;

    assign sda_dly0_r = sda_dly0 && ~sda_dly1;
    assign sda_dly0_f = ~sda_dly0 && sda_dly1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scl_dly0 <= 1'b0;
            sda_dly0 <= 1'b0;
            scl_dly1 <= 1'b0;
            sda_dly1 <= 1'b0;
        end else begin
            scl_dly0 <= scl;
            sda_dly0 <= sda_i;
            scl_dly1 <= scl_dly0;
            sda_dly1 <= sda_dly0;
        end
    end

    typedef enum logic [02:00] {
        IDLE,
        ADDR,
        ADDR_RW,
        ADDR_ACK,
        DATA,
        DATA_ACK
    } i2c_state_e;

    i2c_state_e state;

    logic sda_out_reg;

    assign sda_o = sda_out_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            read        <= 1'b0;
            data        <= 8'h77;
            data_cnt    <= 3'd0;
            sda_out_reg <= 1'b1;
            done        <= 1'b0;
            addr        <= 0;
            rx_data     <= 8'h77;
        end else begin
            case (state)
                IDLE: begin
                    if (scl_dly0 && sda_dly0_f) begin
                        //if(scl && ~sda_i) begin
                        state <= ADDR;
                    end
                end

                ADDR: begin

                    if (data_cnt == 7 && scl_dly0_f) begin
                        data_cnt <= 0;
                        if (addr == SLV_ADDR) begin
                            state <= ADDR_RW;
                        end else begin
                            state <= IDLE;
                        end
                    end else if (scl_dly0_r) begin
                        addr     <= {addr[05:00], sda_dly0};
                        data_cnt <= data_cnt + 1'b1;
                    end
                end

                ADDR_RW: begin
                    if (scl_dly0_r) begin
                        read  <= sda_dly0;  //read 0 -> master write mode
                        state <= ADDR_ACK;
                    end
                end

                ADDR_ACK: begin
                    if (scl_dly0_f) begin
                        sda_out_reg <= 1'b0;
                    end

                    if (scl_dly0_r) begin
                        state <= DATA;
                    end

                end

                DATA: begin

                    if (scl_dly0 && sda_dly0_r) begin
                        data_cnt <= 0;
                        state <= IDLE;
                    end else if (scl_dly0 && sda_dly0_f) begin
                        state <= ADDR;
                    end else if (data_cnt == 8 && scl_dly0_f) begin
                        state <= DATA_ACK;
                        data_cnt <= 0;
                        if (read) begin
                            sda_out_reg <= 1'b1;
                        end else begin
                            sda_out_reg <= 1'b0;
                            done <= 1'b1;
                            rx_data <= data;
                        end
                    end else if (scl_dly0_r && ~read) begin
                        data     <= {data[6:0], sda_dly0};
                        data_cnt <= data_cnt + 1'b1;
                    end else if (scl_dly0_f && read) begin
                        //sda_out_reg <= data[7-data_cnt];
                        sda_out_reg <= rx_data[7-data_cnt];
                        data_cnt    <= data_cnt + 1'b1;
                    end else if (scl_dly0_f) begin
                        sda_out_reg <= 1'b1;
                    end
                end

                DATA_ACK: begin
                    done <= 1'b0;

                    if(scl_dly0_r && read && ~sda_dly0) begin             // read 0 : m -> s
                        state       <= DATA;
                        sda_out_reg <= rx_data[data_cnt];
                        data_cnt    <= data_cnt + 1'b1;
                    end else if (scl_dly0_r && read && sda_dly0) begin
                        state <= IDLE;
                    end else if (scl_dly0_f) begin
                        state <= DATA;
                        sda_out_reg <= 1'b1;
                    end

                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

