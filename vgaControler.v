module vgaController(
  input clk,
  input rst,
  inout PS2_DATA,
  inout PS2_CLK,
  output [3:0] vgaRed,
  output [3:0] vgaGreen,
  output [3:0] vgaBlue,
  output hsync,
  output vsync,
  output wire [15:0] led
);


wire clk_25MHz;
wire valid;
wire [9:0] h_cnt; //640
wire [9:0] v_cnt;  //480
wire [511:0] key_down;
wire [8:0] last_change;
wire key_valid;

//assign led[3:0] = curKey[3:0];
assign led[15:7] = last_change[8:0];
assign led[5] = key_valid;

clock_divisor clk_wiz_0_inst(
  .clk(clk),
  .clk1(clk_25MHz)
);

pixel_gen pixel_gen_inst(
  .h_cnt(h_cnt),
  .valid(valid),
  .vgaRed(vgaRed),
  .vgaGreen(vgaGreen),
  .vgaBlue(vgaBlue)
);

vga_controller   vga_inst(
  .pclk(clk_25MHz),
  .reset(rst),
  .hsync(hsync),
  .vsync(vsync),
  .valid(valid),
  .h_cnt(h_cnt),
  .v_cnt(v_cnt)
);
      
KeyboardDecoder KEYBOARDDECODER(
.key_down(key_down),
.last_change(last_change),
.key_valid(key_valid),
.PS2_DATA(PS2_DATA),
.PS2_CLK(PS2_CLK),
.rst(rst),
.clk(clk)
);

endmodule
