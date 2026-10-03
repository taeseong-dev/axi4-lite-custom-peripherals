`timescale 1ns / 1ps

module spi_slave(

        input logic clk,
        input logic rst,

        input logic sclk,
        input logic cs,
        input logic mosi,

        output logic miso,
        output logic busy,
        output logic done,
        output logic [07:00] rx_data
    );

    logic [07:00] rx_reg;
    logic [07:00] tx_reg;

	logic cs_dly0;
	logic cs_dly1;
	logic sclk_dly0;
	logic sclk_dly1;

    logic mosi_dly0;

    assign miso = ~cs_dly1 ? tx_reg[7] : 1'b0;

    assign cs_f = (~cs_dly0) &&   cs_dly1;
    assign cs_r = ( cs_dly0) &&  ~cs_dly1;

    assign sclk_r =  sclk_dly0   && (~sclk_dly1);
    assign sclk_f =  ~sclk_dly0   && (sclk_dly1);


	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			cs_dly0 <= 1'b0;
			cs_dly1 <= 1'b0;
			sclk_dly0 <= 1'b0;
			sclk_dly1 <= 1'b0;
            mosi_dly0 <= 1'b0;
		end
		else begin
			cs_dly0 <= cs;
			cs_dly1 <= cs_dly0;
			sclk_dly0 <= sclk;
			sclk_dly1 <= sclk_dly0;
            mosi_dly0 <= mosi;
		end
	end

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            tx_reg <= 8'd0;
        end
        else if(cs_f) begin
            tx_reg <= rx_data;
        end
        else if(~cs_dly1 && sclk_f) begin
            tx_reg <= {tx_reg[6:0], 1'b0};
        end
        else begin
            tx_reg <= tx_reg;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            rx_reg <= 8'd0;
        end
        else if(~cs_dly1 && sclk_r) begin
            rx_reg <= {rx_reg[6:0], mosi_dly0};
        end
        else begin
            rx_reg <= rx_reg;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            rx_data <= 0;
        end
        else if(cs_r) begin
            rx_data <= rx_reg;
        end
        else begin
            rx_data <= rx_data;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            busy <= 1'b0;
        end
        else if(cs_f) begin
            busy <= 1'b1;
        end
        else if(cs_r) begin
            busy <= 1'b0;
        end
        else begin
            busy <= busy;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            done <= 1'b0;
        end
        else if(cs_r) begin
            done <= 1'b1;
        end
        else begin
            done <= 1'b0;
        end

    end

endmodule
