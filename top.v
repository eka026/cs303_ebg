// DO NOT CHANGE THE NAME OR THE SIGNALS OF THIS MODULE

module top (
  input        clk    ,
  input  [3:0] sw     ,
  input  [3:0] btn    ,
  output [7:0] led    ,
  output [7:0] seven  ,
  output [3:0] segment
);

/* Your module instantiations go to here. */

// For SSDs
wire [7:0] disp0, disp1, disp2, disp3;

// Wire for divided clock signal
wire div_clk;

wire rst_debouncer = 1'b0;

// Wires for clean button signals
wire btn0_clean_signal, btn1_clean_signal, btn2_clean_signal, btn3_clean_signal;

// Clock divider instantiation
clk_divider clk_div (
  .clk_in(clk),
  .divided_clk(div_clk)
);

// Debouncer instantiation for BTN3
debouncer db3 (
  .clk(div_clk),
  .rst(rst_debouncer),
  .noisy_in(btn[3]),
  .clean_out(btn3_clean_signal)
);

// Debouncer instantiation for BTN2
debouncer db2 (
  .clk(div_clk),
  .rst(rst_debouncer),
  .noisy_in(btn[2]),
  .clean_out(btn2_clean_signal)
);

// Debouncer instantiation for BTN1
debouncer db1 (
  .clk(div_clk),
  .rst(rst_debouncer),
  .noisy_in(btn[1]),
  .clean_out(btn1_clean_signal)
);

// Debouncer instantiation for BTN0
debouncer db0 (
  .clk(div_clk),
  .rst(rst_debouncer),
  .noisy_in(btn[0]),
  .clean_out(btn0_clean_signal)
);

// Battleship instantiation
battleship bs (
  .clk(div_clk),
  .rst(btn2_clean_signal),
  .start(btn1_clean_signal),
  .X(sw[3:2]), 
  .Y(sw[1:0]), 
  .pAb(btn3_clean_signal),
  .pBb(btn0_clean_signal),
  .disp0(disp0),
  .disp1(disp1),
  .disp2(disp2),
  .disp3(disp3),
  .led(led)
);

// SSD instantiation
ssd display (
    .clk(clk),              
    .disp0(disp0),
    .disp1(disp1), 
    .disp2(disp2),
    .disp3(disp3),
    .seven(seven),
    .segment(segment)
);


endmodule