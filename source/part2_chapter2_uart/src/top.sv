`default_nettype none
module top #(
    parameter bit USE_FIXED = 0,
    parameter int CLOCK_HZ = 50_000_000
) (
    input  wire clock,
    
    output logic tx,
    input  wire  rx
);

localparam int BAUD_DIVIDER = (CLOCK_HZ + 115200/2) / 115200;

logic reset;
logic [7:0] reset_reg = '1;
assign reset = reset_reg[0];

always @(posedge clock) begin
    reset_reg <= {1'b0, reset_reg[6:0]};
end 

generate if( USE_FIXED ) begin

uart_tx_fixed #(
    .BAUD_DIVIDER(BAUD_DIVIDER),
    .CHARACTER(8'h41)
) uart_tx_inst (
    .clock(clock),
    .reset(reset),
    .tx(tx)
);

end 
else begin

// internal loopback
logic       data_valid;
logic       data_ready;
logic [7:0] data_bits_received;
logic [7:0] data_bits_to_send;
assign data_bits_to_send = data_bits_received + 1;

uart_rx #(
    .BAUD_DIVIDER(BAUD_DIVIDER)
) uart_rx_inst (
    .data_bits(data_bits_received),
    .overrun(),
    .*
);

uart_tx #(
    .BAUD_DIVIDER(BAUD_DIVIDER)
) uart_tx_inst (
    .data_bits(data_bits_to_send),
    .*
);

end 
endgenerate

endmodule
`default_nettype wire