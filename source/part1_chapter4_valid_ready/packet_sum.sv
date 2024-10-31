`default_nettype none
module packet_sum(
    input  wire  clock, // クロック
    input  wire  reset, // リセット (正論理)
    input  wire        input_valid, // 入力VALID
    output logic       input_ready, // 入力READY
    input  wire  [7:0] input_data,  // 入力データ
    input  wire        input_last,  // 入力LAST

    output logic        output_valid, // 出力VALID
    input  wire         output_ready, // 出力READY
    output logic [15:0] output_data   // 出力データ
);

// パケットの最終データでなければ出力に関係なくデータを受け入れられる
// パケットの最終データの場合、まだデータを出力していない or 出力READYがアサートされているなら、次の入力を受け付けられる
assign input_ready = !input_last || !output_valid || output_ready;

logic [15:0] sum = 0;   // パケットの値の合計

always @(posedge clock) begin
    if( reset ) begin
        output_valid <= 1'b0;   // 出力を初期化
        output_data <= 16'd0;   //
        sum <= 16'd0;           // 合計値を初期化
    end
    else begin
        if( output_valid && output_ready ) begin    // 出力側ハンドシェーク成立
            output_valid <= 1'b0; // 出力validをデアサート
        end
        if( input_valid && input_ready ) begin
            sum <= sum + 16'(input_data); // 合計値を更新
            if( input_last ) begin                       // パケットの最後のデータ?
                output_valid <= 1'b1;                    // 出力validをアサート
                output_data <= sum + 16'(input_data);    // 合計値を出力
                sum <= 0;                                // 合計値を初期化
            end
        end
    end
end

endmodule
`default_nettype wire