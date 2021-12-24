module store_size (
    
    input  wire  [1:0] command,
    input  wire [31:0] mdr,
    input  wire [31:0] b,
    output reg  [31:0] data_out

);

always @ (*) begin
        if (command == 2'b01) begin //byte
            data_out = {mdr[31:8], b[7:0]};
        end
        else if(command == 2'b10) begin //halfword
            data_out = {mdr[31:16], b[15:0]};
        end
        else begin
            data_out = b;
        end
    end

endmodule