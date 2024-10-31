`default_nettype none
module counter_8bit(
    input  wire  clock, // クロック
    input  wire  reset, // リセット (正論理)
    output logic valid, // VALID
    input  wire  ready, // READY
    output logic [7:0] data // データ
);

logic [7:0] counter;    // 8bitカウンター

always @(posedge clock) begin
    if( reset ) begin
        valid <= 1'b0;      // 出力を初期化
        data  <= 8'd0;      //
        counter <= 8'd0;    // /
    end
    else begin
        if( valid && ready ) begin  // ハンドシェークが成立したらVALIDをデアサート
            valid <= 1'b0;
        end
        // VALIDをアサートしていないか、(VALIDをアサートしているかいないかに関わらず)　READYがアサートされているなら
        if( !valid || ready ) begin 
            valid <= 1'b1;              // VALIDをアサートする
            data <= counter;            // 次のデータを出力する
            counter <= counter + 8'd1;  // カウンタを進める
        end
    end
end

endmodule
`default_nettype wire