module binary_to_gray_con(g,b);
input [3:0]b;
output [3:0]g;
assign g={b[3],b[3:1]^b[2:0]};
endmodule

module gray_to_binary_converter(b,g);
input [3:0]g;
output [3:0]b;
assign b={g[3], g[2]^g[3], g[1]^g[2]^g[3],g[0]^g[1]^g[2]^g[3]};
endmodule

module dff_sync2(
input clk,
input[3:0]d,
output reg[3:0]q_synced);
reg[3:0]sync_flop1;

always @(posedge clk)
begin
sync_flop1 <=d;
q_synced <= sync_flop1;
end
endmodule 

module fifo_asynch(data_in, wr_rst,rd_rst, rd_clk, wr_clk, wr_en, rd_en, data_out, full, empty);
input[3:0]data_in;
input wr_rst, wr_clk, rd_rst, rd_clk;
input wr_en, rd_en;
output reg[3:0]data_out;
output full, empty;
`define MAX 8
reg[3:0]mem[0:7];
reg[3:0]wr_ptr, rd_ptr;
reg[2:0]wr_add, rd_add;
wire[3:0] syn_gray_rd_ptr, syn_gray_wr_ptr;
wire[3:0]gray_rd_ptr, gray_wr_ptr;
wire[3:0]syn_rd_ptr, syn_wr_ptr;

assign full = ({~wr_ptr[3],wr_ptr[2:0]}== syn_rd_ptr)?1:0;
assign empty = (syn_wr_ptr==rd_ptr)?1:0;

binary_to_gray_con bg1(gray_rd_ptr, rd_ptr);
binary_to_gray_con bg2(gray_wr_ptr, wr_ptr);
dff_sync2 ds1(wr_clk, gray_rd_ptr, syn_gray_rd_ptr);
dff_sync2 ds2(rd_clk, gray_wr_ptr, syn_gray_wr_ptr);
gray_to_binary_converter gb1(syn_rd_ptr, syn_gray_rd_ptr);
gray_to_binary_converter gb2(syn_wr_ptr, syn_gray_wr_ptr);

always @(posedge wr_clk or negedge wr_rst)
begin
if(!wr_rst)begin
wr_add<=0;
wr_ptr<=0;
end
else if(wr_en && full ==0)
begin
mem[wr_add]<=data_in;
wr_add<=(wr_add+1)%`MAX;
wr_ptr<=(wr_ptr+1)%(2*`MAX);
end
end

always @(posedge rd_clk or negedge rd_rst)
begin
if(!rd_rst)begin
rd_add<=0;
rd_ptr<=0;
end
else if (rd_en && empty ==0)
begin
data_out<=mem[rd_add];
rd_add<=(rd_add+1)%`MAX;
rd_ptr <=(rd_ptr+1)%(2*`MAX);
end
end
endmodule

module asynchfifo_tb;
reg[3:0] data_in;
reg wr_rst,wr_clk=0,rd_rst,rd_clk=0;
wire[3:0]data_out;
reg wr_en,rd_en;
wire full,empty;
fifo_asynch fasyn(data_in, wr_rst,rd_rst, rd_clk, wr_clk, wr_en, rd_en, data_out, full, empty);
initial
forever #2 rd_clk=~rd_clk;
initial
forever #5 wr_clk=~wr_clk;
initial
begin
wr_en=1;
rd_en=0;
#20 rd_en=1;
#20 rd_en=0;wr_en=1;
#20 rd_en=1;wr_en=1;
#18 wr_en=1;rd_en=0;
end
initial
begin
wr_rst=0;rd_rst=0;
#1 wr_rst=1;rd_rst=1;
end
initial
begin
#21 data_in=0;
#10 data_in=11;
#11 data_in=6;
#10 data_in=5;
#10 data_in=9;
#10 data_in=7;
#11 data_in=5;
#10 data_in=11;
#10 data_in=11;
#10 data_in=8;
#11 data_in=2;
#10 data_in=3;
#10 data_in=13;
#500 $finish();
end
endmodule