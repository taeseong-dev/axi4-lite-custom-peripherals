`timescale 1ns / 1ps

module top_i2c_slave (
    input  logic       clk,
    input  logic       rst,

    output logic [3:0] fnd_digit,
    output logic [7:0] fnd_data,

    input  logic       s_scl,
    inout  wire        s_sda
);

    logic [7:0]  rx_data;
    logic        done;
    logic [15:0] fnd_data_reg;

    // I2C Slave logic is defined in ../../rtl/i2c_slave.sv
    I2C_Slave u_i2c_slave (
        .clk    (clk),
        .rst    (rst),
        .done   (done),
        .rx_data(rx_data),
        .scl    (s_scl),
        .sda    (s_sda)
    );

    fnd_controller u_fnd_controller (
        .clk        (clk),
        .rst        (rst),
        .i_fnd_data (fnd_data_reg),
        .o_fnd_digit(fnd_digit),
        .o_fnd_data (fnd_data)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fnd_data_reg <= 16'd0;
        end else if (done) begin
            fnd_data_reg <= {8'd0, rx_data};
        end
    end

endmodule
