module simple_fifo(reset,clock,read_en,write_en,data_in,empty,full,data_out);
input reset,clock;
input read_en,write_en;
input [3:0]data_in;
output full,empty;
output reg [3:0] data_out;
reg [3:0]rd_ptr,wr_ptr;
reg [3:0]mem[0:7];

always @(posedge clock,negedge reset)
begin : write_block
if(!reset)
wr_ptr<=0;
else if (!full&&write_en)
begin
wr_ptr<=wr_ptr+1;
mem[wr_ptr]<=data_in;
end
end
always @(posedge clock,negedge reset)
begin : read_block
if(!reset)
rd_ptr<=0;
else if (!empty&& read_en)
begin
rd_ptr <= rd_ptr+1;
data_out<=mem[rd_ptr];
end
end
assign full = (wr_ptr >7)?1:0;
assign empty = (rd_ptr == wr_ptr)?1:0;
endmodule

module simple_fifo_tb;
reg reset,clock=0;
reg read_en,write_en;
reg [3:0] data_in;
wire full,empty;
wire [3:0] data_out;
simple_fifo s1(reset,clock,read_en,write_en,data_in,empty,full,data_out);
initial forever #5 clock = ~clock;
initial begin
reset=0;
#3 reset =1;
write_en =1; read_en=0;
#37 write_en =0; read_en=1;
end
initial begin
data_in=8;
#12 data_in=12;
#10 data_in=4;
#10 data_in=7;
#10 data_in=13;
#10 data_in=9;
#10 data_in=11;
#10 data_in=5;
#10 data_in=15;
#10 data_in=6;
end
endmodule
