`timescale 1ns/1ps

module tb_uart;
    // DivTX = 16000/100 = 160 clk cycles per bit.
    // DivRX = 16000/(100*16) = 10 clk cycles per sub-tick (16 sub-ticks per bit).
    localparam CLK_FREQ = 16000;
    localparam BAUD     = 100;

    reg clk   = 0;
    reg reset = 1;
    reg [10:0] bit_sequence;
    reg [8:0] data_byte;

    wire tx_pin;
    wire rx_pin;

    // tie TX straight into RX
    assign rx_pin = tx_pin;

    always #5 clk = ~clk;

    UART #(
        .clk_freq (CLK_FREQ),
        .baud     (BAUD)
    ) dut (
        .clk          (clk),
        .reset        (reset),
        .bit_sequence (bit_sequence),
        .rx_pin       (rx_pin),
        .tx_pin       (tx_pin)
    );

    initial begin
        data_byte = 8'h55; // 01010101

        bit_sequence[0]   = 1'b0;      // start
        bit_sequence[8:1] = data_byte; // data, LSB first
        bit_sequence[9]   = 1'b0;      // placeholder parity
        bit_sequence[10]   = 1'b1;      // stop

        $display("Sending data byte: %h (%b)", data_byte, data_byte);
        $display("\n");

        reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;

        // 10 bits * DivTX(160) clk cycles = 1600 clk cycles, *10ns period = 16000ns + 4000 just in case
        #20000;

        $display("\n");
        $display("Simulation done.");
        $finish;
    end

endmodule
