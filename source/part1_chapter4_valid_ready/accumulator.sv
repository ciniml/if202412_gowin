`default_nettype none
module accumulator(
    input  wire  clock, // クロック
    input  wire  reset, // リセット (正論理)
    input  wire  valid, // VALID
    output logic ready, // READY
    input  wire  [7:0] data, // データ

    output logic [15:0] accumulated // 積算値
);

always @(posedge clock) begin
    if( reset ) begin
        ready <= 1'b0;          // 出力を初期化
        accumulated <= 16'd0;   //
    end
    else begin
        ready <= 0;     // なにもなければREADYをデアサート
        if( valid ) begin 
            ready <= 1'b1;              // READYをアサートする
        end
        if( valid && ready ) begin  // ハンドシェークが成立したらデータを処理する
            accumulated <= 16'(accumulated + 16'(data));  // データを積算する
        end
    end
end

endmodule
`default_nettype wire