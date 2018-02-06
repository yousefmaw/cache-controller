module RAM4M (CE ,WE ,OE ,outdata, indata,A) ;

input  CE ,WE,OE; 
input [0:31]indata ;
input[0:19]A;
output reg [0:31]outdata ; //31:0 i made MSB has loacation zero
reg [0:31]mem[0:1048575];
/*here i made 1M rows , each row one word */
always @(CE or WE or A)
begin
if (~CE && ~WE)
    begin    mem[A]=indata;     end
else if((~CE) && (~OE)) 
    begin     outdata= mem[A]; end
else 
     begin   outdata=32'hzzzzzzzz;   end
end

endmodule

// till now i will consider cache has only outputs the hit and data 
// i don't know if i have to write on it or not
module cache4K (address,hit , indata,outdata ,ws,os ,cs);

//module RAM4M (CE ,WE ,OE ,outdata, indata,A) ;
wire [0:31]outo;
reg [0:31]ino;
reg [0:19]addresso;
reg ceo,weo,oeo;
RAM4M X(.CE(ceo) ,.WE(weo) ,.OE(oeo) ,.outdata(outo),.indata( ino),.A( addresso)) ;


output reg [0:31]outdata;
output  reg hit ; // as output for the RAM

input  [0:19]address;
input  cs ;  //chip select
input  ws ;  //write select
input  os ;  //out select
input  [0:31]indata;

reg [0:19]newaddress;

//cache formation
reg valid[0:1023];
reg [0:9]tag[0:1023];
reg [0:31]data[0:1023];


always @(address or cs )
begin

if(!cs && !os )
begin

if (valid[address[10:19]])
begin
// here valid is 1
   if (tag[address[10:19]]==address[0:9])
   // here tag is same (HIT)
   begin

   // here i choose which byte to out
        hit=1'b1;
         outdata=data[address[10:19]];
	
   end
   else
   begin 
   // here tag is not the same (NO HIT)
   
   
  
// HERE I'M NOT SURE THAT DATA CONVERSION BETWEEN RAM and CACHE IS RIGHT
   //here im preparing the newaddressto store back the wrong word
    hit=1'b0;
  newaddress[10:19]=address[10:19];   // storing wrong data 
   newaddress[0:9]=tag[address[10:19]];  
X.mem[newaddress]=data[address[10:19]];
/*#10 ceo=1'b0;
 weo=1'b0;
 oeo=1'b1;
 addresso=newaddress;
 ino=data[address[10:19]];
#10 
ceo=1'b0;
 weo=1'b1;
 oeo=1'b0;
 addresso=address[0:19];
 data[address[10:19]]=outo;*/
 // fixing the tag to the new one 
  tag[address[10:19]]=address[0:9];
  data[address[10:19]] =X.mem[address];

outdata =  data[address[10:19]];
   end// end of else when tag is not the same


end // end of valid is 1
else
// here valid is 0
begin
 assign hit = 1'b0;
   
   valid[address[10:19]]=1'b1;
/*  ceo=1'b0;
 weo=1'b1;
 oeo=1'b0;*/
 addresso=address[0:19];
// data[address[10:19]]=outo;
   tag[address[10:19]]=address[0:9]; 
// outdata=data[address[10:19]];

 data[address[10:19]] =X.mem[addresso];
outdata =  data[address[10:19]];
end //end of else of zero valid
end // end of condition output
else if(!cs && !ws)              // beginning of condition write
begin 



if (tag[address[10:19]]==address[0:9])
begin
hit = 1'b1;
data[address[10:19]]=indata;
valid[address[10:19]]=1'b1;
end // end of hit 1

else
begin 
hit = 1'd0;

   newaddress[10:19]=address[10:19];   // storing wrong data 
   newaddress[0:9]=tag[address[10:19]];
 
 ceo=1'b0;
 weo=1'b0;
 oeo=1'b1;
 addresso=newaddress;
 ino=data[address[10:19]];
 

 
   
   tag[address[10:19]]=address[0:9];// fixing the tag to the new one
   valid[address[10:19]]=1'b1;
  data[address[10:19]]=indata;

end // end of hit zero


end // end of condtion write
end //end of always

endmodule 

//module RAM4M (CE ,WE ,OE ,outdata, indata,A) ;
//module cache4K (address,hit , indata,outdata ,ws,os ,cs);
module tb_new();
reg [0:19]taddress;// var, for the 
reg [0:31]tindata;
reg wsc,csc,osc;
wire [0:31]outo;
wire thit;

cache4K my_cache(.address(taddress),.hit(thit) , .indata(tindata),.outdata(outo),.ws(wsc),.os(osc) ,.cs(csc));
initial
begin 
$monitor ("hit= %b , cache[0]= %d , out= %d , tag[0] %d  , valid %d ,  RAM[1024]= %d and  RAM[0] %d ",thit,my_cache.data[10'd0],outo,my_cache.tag[10'd0],my_cache.valid[10'd0] ,my_cache.X.mem[20'h0400] ,my_cache.X.mem[20'h0000]);

 
 #100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd0; 
tindata = 32'd 9999;
#100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd2; 
tindata = 32'd 9999;
 #100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd0; 
tindata = 32'd 7000;
#100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd5; 
tindata = 32'd 7000;
 #100
wsc=1'b1;
osc=1'b0;
csc=1'b0;
taddress=20'd0; 
tindata = 32'd 8000;
#100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd5; 
tindata = 32'd 7000;
#100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd0; 
tindata = 32'd 2222;
 #100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd1024; 
tindata = 32'd 1024;
 #100
wsc=1'b0;
osc=1'b1;
csc=1'b0;
taddress=20'd6; 
tindata = 32'd 8000; 
#100
wsc=1'b1;
osc=1'b0;
csc=1'b0;
taddress=20'd0; 
tindata = 32'd 8000;

#100
 my_cache.X.mem[10]=32'd1234;
#100
wsc=1'b1;
osc=1'b0;
csc=1'b0;
taddress=20'd10; 


end //end of initial



endmodule
