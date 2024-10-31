`default_nettype none
module register_slice_half #(
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

// バッファがに空きがあるならREADYをアサート
// input_readyはoutput_readyに依存しない
assign input_ready = !output_valid;

always @(posedge clock) begin
    if( reset ) begin
        output_valid <= 0;
        output_data  <= 0;
    end
    else begin
        if( output_valid && output_ready ) begin    // 出力ハンドシェーク成立
            output_valid <= 0;                      // 出力VALIDをデアサート
        end
        // input_valid && input_ready && (!output_valid || output_ready)
        if( input_valid && !output_valid ) begin
            output_valid <= 1;
            output_data <= input_data;
        end
    end
end

endmodule
`default_nettype wire