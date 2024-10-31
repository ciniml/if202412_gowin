`default_nettype none
module register_slice #(
    parameter int WIDTH_BITS = 8
)(
    input  wire  clock, // クロック
    input  wire  reset, // リセット (正論理)
    input  wire                   input_valid, // 入力VALID
    output logic                  input_ready, // 入力READY
    input  wire  [WIDTH_BITS-1:0] input_data,  // 入力データ

    output logic                  output_valid, // 出力VALID
    input  wire                   output_ready, // 出力READY
    output logic [WIDTH_BITS-1:0] output_data   // 出力データ
);

logic                  data_valid;
logic [WIDTH_BITS-1:0] data;

// バッファがに空きがあるならREADYをアサート
// input_readyはoutput_readyに依存しない
assign input_ready = !data_valid || !output_valid;

always @(posedge clock) begin
    if( reset ) begin
        data_valid <= 0;
        data       <= 0;
        output_valid <= 0;
        output_data  <= 0;
    end
    else begin
        if( output_valid && output_ready ) begin    // 出力ハンドシェーク成立
            output_valid <= 0;                      // 出力VALIDをデアサート
        end
        if( input_valid && input_ready ) begin      // 入力ハンドシェーク成立
            data <= input_data;
            data_valid <= 1;
        end
        if( !output_valid || output_ready ) begin
            if( !data_valid && input_valid ) begin
                output_valid <= 1;
                output_data <= input_data;
            end
            if( data_valid ) begin
                output_valid <= 1;
                output_data <= data;
            end
            data_valid <= 0;
        end
        
    end
end

endmodule
`default_nettype wire