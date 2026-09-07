module UART #(

	parameter clk_freq = 50000000,
	parameter baud = 9600
) (
	input clk,
	input reset,
	input [10:0] bit_sequence,
	input wire rx_pin,
	output wire tx_pin
);
	
	localparam integer DivTX = clk_freq / baud;
	
	localparam integer DivRX = clk_freq / (baud * 16);
	
	reg baud_tick_tx;
	reg baud_tick_rx;
	
	wire [10:0] out;
	
	reg [31:0] cnt_tx;
	reg [31:0] cnt_rx;
	
	//Clock edge baud switch (TX is 1/16 of RX)
	
	always @(posedge clk or posedge reset) begin
		 if (reset) begin
			  cnt_tx <= 0;
			  baud_tick_tx <= 1'b0;
		 end else if (cnt_tx == DivTX - 1) begin
			  cnt_tx <= 0;
			  baud_tick_tx <= 1'b1;
		 end else begin
			  cnt_tx <= cnt_tx + 1;
			  baud_tick_tx <= 1'b0;
		 end
	end

	always @(posedge clk or posedge reset) begin
		 if (reset) begin
			  cnt_rx <= 0;
			  baud_tick_rx <= 1'b0;
		 end else if (cnt_rx == DivRX - 1) begin
			  cnt_rx <= 0;
			  baud_tick_rx <= 1'b1;
		 end else begin
			  cnt_rx <= cnt_rx + 1;
			  baud_tick_rx <= 1'b0;
		 end
	end
	
	send sender (
		.bit_input(bit_sequence),
		.baud_tick(baud_tick_tx),
		.clk(clk),
		.reset(reset),
		.tx(tx_pin)
	);
	
	read reader (
		.bit_output(out),
		.baud_tick(baud_tick_rx),
		.clk(clk),
		.reset(reset),
		.rx(rx_pin)
	);
	
endmodule

module send
(
	input [10:0] bit_input,
	input baud_tick,
	input clk,
	input reset,
	output reg tx
);
	integer bit_pos;
	integer i;
	integer num;
	
	reg sending;

	always@(posedge clk or posedge reset) begin
		if(reset) begin
			bit_pos <= 0;
			tx <= 1'b1;
			sending <= 0;
			num <= 0;
		end else if(baud_tick == 1'b1 && sending == 1'b1) begin
			if(bit_pos == 10) begin
				bit_pos <= 0;
				tx <= 1'b1;
				sending <= 1'b0;
				num <= 0;
			end else if(bit_pos == 9) begin
			
				for (i = 1; i < 9; i = i + 1) begin : parity_check
				  if (bit_input[i] == 1'b1)
						num = num + 1;
				end

				tx <= (num % 2 == 0) ? 1'b0 : 1'b1;
				bit_pos <= bit_pos + 1;
			end else begin
				tx <= bit_input[bit_pos];
				bit_pos <= bit_pos + 1;
				
			end
		end else if(sending == 1'b0 && bit_pos == 0 && bit_input[0] == 1'b0) begin
			sending <= 1'b1;
		end
	end

endmodule

module read
(
	output reg [10:0] bit_output,
	input baud_tick,
	input clk,
	input reset,
	input rx
);
	integer bit_pos;
	
	reg reading;
	
	reg [3:0] subtick;
	
	wire start_edge;
	
	falling_edge fe_check (
		.start_edge(start_edge),
		.clk(clk),
		.rx(rx)
	);

	always@(posedge clk or posedge reset) begin
		if(reset) begin
			subtick <= 0;
			bit_pos <= 0;
			reading <= 1'b0;
		end else if(baud_tick == 1'b1 && reading == 1'b1) begin
			 if(subtick == 7) begin
				  bit_output[bit_pos] <= rx;
			 end
			 if(subtick == 15) begin
				  subtick <= 0;
				  if(bit_pos == 10) begin
						reading <= 1'b0;
						$display("Start bit: %b", bit_output[0]);
						$display("Data output: %h (Hex)", bit_output[8:1]);
						$display("Parity: %b", bit_output[9]);
						$display("Stop bit: %b", bit_output[10]);
				  end else begin
						bit_pos <= bit_pos + 1;
				  end
			 end else begin
				  subtick <= subtick + 1;
			 end
		end else if(reading == 1'b0 && start_edge) begin
			reading <= 1'b1;
			subtick <= 0;
			bit_pos <= 0;
		end
	end

endmodule

module falling_edge(
	output wire start_edge,
	input clk,
	input rx
);

	reg rx_sync1, rx_sync2;

	always @(posedge clk) begin
		 rx_sync1 <= rx;
		 rx_sync2 <= rx_sync1; // prevents reading error from unstable pin.
	end

	// edge detect
	reg rx_prev;
	assign start_edge = (rx_prev == 1'b1) && (rx_sync2 == 1'b0);
	always @(posedge clk) rx_prev <= rx_sync2;

endmodule
