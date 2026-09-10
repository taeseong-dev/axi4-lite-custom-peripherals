`timescale 1ns / 1ps

module top_spi_slave(
    input logic clk,
    input logic rst,
    input logic s_sclk,
    input logic s_cs_n,
    input logic s_mosi,

    output logic s_miso,
    output logic [03:00] fnd_digit,
    output logic [07:00] fnd_data
    );

    logic [07:00] rx_data;
    logic done;
    logic [15:00] fnd_data_reg;

    spi_slave dut_slave(
        .clk(clk),
        .rst(rst),
        .sclk(s_sclk),
        .cs(s_cs_n),
        .mosi(s_mosi),
        .miso(s_miso),
        .busy(),
        .done(done),
        .rx_data(rx_data)
    );

    fnd_controller dut_fnd_cntl(
        .clk(clk),
        .rst(rst),
        .i_fnd_data(fnd_data_reg),
        .o_fnd_digit(fnd_digit),
        .o_fnd_data(fnd_data)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            fnd_data_reg <= 0;
        end
        else if(done) begin
            fnd_data_reg <= {8'b0, rx_data};
        end
    end

endmodule
