module MuxIJ_MultDiv (
   input wire seletor,
   input wire [31:0] hiMult,
   input wire [31:0] loMult,
   input wire [31:0] hiDiv,
   input wire [31:0] loDiv,
   output wire [31:0] hi,
   output wire [31:0] lo
);
   
 assign hi = (seletor==1'b1) ? hiMult : hiDiv;
 assign lo = (seletor==1'b1) ? loMult : loDiv;
endmodule