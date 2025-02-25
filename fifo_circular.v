module circular_fifo(reset,clk,read_en,write_en,data_in,empty,full,data_out);
input reset,clk;
input[3:0]data_in;
input read_en,write_en;
output full,empty;
output reg[3:0]data_out;

integer count;
reg[3:0]rd_ptr,wr_ptr;
reg[3:0]mem[0:7];

always@(posedge clk, negedge reset)
begin:write_block
if(!reset)
wr_ptr<=0;
else if(!full&&write_en)
begin
wr_ptr<=(wr_ptr+1)%8;
mem[wr_ptr]<=data_in;
end
end
always@(posedge clk,negedge reset)
begin:read_block
if(!reset)
rd_ptr<=0;
else if(!empty&&read_en)
begin
rd_ptr<=(rd_ptr+1)%8;
data_out<=mem[rd_ptr];
end
end
always@(posedge clk,negedge reset)
begin
if(!reset)
count<=0;
else if(read_en==0 && write_en==1 && full==0)
count<=count+1;
else if(read_en==1 && write_en==0 && empty==0)
count<=count-1;
end
assign full=(count==8)?1:0;
assign empty=(count==0)?1:0;
endmodule

module circular_fifo_tb;
reg reset,clk = 0;
reg read_en,write_en;  
reg[3:0]data_in;
wire full,empty;
wire[3:0]data_out;
integer count;
reg[3:0]rd_ptr,wr_ptr;
reg[3:0]mem[0:7];

circular_fifo s1(reset,clk,read_en,write_en,data_in,empty,full,data_out);

initial forever #5 clk=~clk;

initial 
begin
    reset = 0;
   #3 reset = 1;
   write_en = 1; read_en = 0; count=0;rd_ptr=1;wr_ptr=0;
   #37 write_en = 0; read_en = 1;count=1;rd_ptr=0;wr_ptr=1;
   #40 write_en=1; read_en=0;count=0;rd_ptr=1;wr_ptr=0;
end


initial
begin
     data_in = 8;
    #12data_in = 12;
    #10data_in = 4;
    #10data_in = 7;
    #50data_in = 13;
    #10data_in = 9;
    #10data_in = 11;
    #10data_in = 5;
    #10data_in = 15; 
    #10data_in = 6;
    #10data_in = 1;
    #10data_in = 2;
    #10data_in = 3;
    #10data_in = 8;
    #10data_in =10;

end
endmodule
