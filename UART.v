module uart(

	parameter clk_freq = 50000000
	parameter baud = 9600
);
	
	localparam integer Div = clk_freq / baud;
	
	reg baud_tick;
	wire reset;
	input clk;
	
	reg cnt;
	reg [7:0] bits;
	
	integer bit_position;
	
	always@(posedge clk or posedge reset) begin
		if(reset) begin
			cnt <= 0;
			baud_tick <= 0;
		end else if(cnt == Div - 1) begin
			cnt <= 0;
			baud_tick <= 1;
		end else begin
			cnt <= cnt + 1;
			baud_tick <= 0;
		end
	end
	
	always@(posedge baud_tick) begin
		bit_position <= bit_position + 1;
		
		if(bit_position == 8) begin
			bit_position <= 0;
		end
	end
	
		
endmodule

module read()
{
	input reg [7:0] bit_data,
};

	

endmodule

module rx()
{
	output reg [7:0] bitset_output
};

endmodule