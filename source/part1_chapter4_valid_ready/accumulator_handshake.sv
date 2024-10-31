`default_nettype none
module accumulator(
    input  wire  clock, // クロック
    input  wire  reset, // リセット (正論理)
    input  wire        input_valid, // 入力VALID
    output logic       input_ready, // 入力READY
    input  wire  [7:0] input_data,  // 入力データ

    output logic        output_valid, // 出力VALID
    input  wire         output_ready, // 出力READY
    output logic [15:0] output_data   // 出力データ
);

// まだデータを出力していない or 出力READYがアサートされているなら、次の入力を受け付けられる
assign input_ready = !output_valid || output_ready;

always @(posedge clock) begin
    if( reset ) begin
        output_valid <= 1'b0;   // 出力を初期化
        output_data <= 16'd0;   //
    end
    else begin
        if( output_valid && output_ready ) begin    // 出力側ハンドシェーク成立
            output_valid <= 1'b0; // 出力validをデアサート
        end
        if( input_valid && input_ready ) begin
            output_data <= 16'(output_data + 16'(input_data)); // データを積算する
            output_valid <= 1'b1;  // 出力validをアサート
        end
    end
end

endmodule
`default_nettype wire