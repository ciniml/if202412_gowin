`default_nettype none
module top (
    input  wire clock,
    output logic dout_check
);

logic reset;
logic [31:0] dout /* synthesis syn_keep=true */;
logic        oce  /* synthesis syn_keep=true */;
logic        ce   /* synthesis syn_keep=true */;
logic        wre  /* synthesis syn_keep=true */;
logic [13:0] ad   /* synthesis syn_keep=true */;
logic [31:0] di   /* synthesis syn_keep=true */;

// SPが参照するGSRのインスタンスを作成
GSR GSR(
    .GSRI(!reset)   // GSRにはリセット信号(アクティブ・ロー)をつないでおく
);

SP #(
    .READ_MODE(1'b0),       // 読み込みモード (0: バイパス, 1: パイプライン)
    .WRITE_MODE(2'b00),     // 書き込みモード (00: 通常, 01: ライトスルー, 10: 書き込み前リード)
    .BIT_WIDTH(8),          // ビット幅 (1, 2, 4, 8, 16, 32)
    .BLK_SEL(3'b000),       // ブロック選択
    .RESET_MODE("SYNC"),    // リセットモード (SYNC, ASYNC)
    .INIT_RAM_00(256'hffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff)    // コンフィグレーション後RAM初期値
) sp_inst (
    .DO    (dout),      // 読み出しデータ出力
    .CLK   (clock),     // クロック
    .OCE   (oce),       // 出力レジスタのクロック・イネーブル (READ_MODEがパイプラインの時のみ有効)
    .CE    (ce),        // チップ・イネーブル
    .RESET (reset),     // リセット (正論理)
    .WRE   (wre),       // 書き込みイネーブル
    .BLKSEL(3'b000),    // ブロック選択 (BLK_SEL==BLKSELのときに有効)
    .AD    (ad),        // アドレス入力(ビット単位)
    .DI    (di)         // 書き込みデータ出力
);

// リセット信号生成
logic [7:0] reset_reg = '1;
assign reset = reset_reg[0];

always @(posedge clock) begin
    reset_reg <= {1'b0, reset_reg[7:1]};
end 

initial begin
    dout_check = 0;
end

// テスト用のステートマシン
logic       is_read_state = 0;  // 読み出しフェーズ？
logic       check_enable = 0;   // 比較処理有効？
logic [7:0] expected_data;      // 期待値

// アドレスに対するテストデータ生成
function logic [7:0] address_to_data(input logic [10:0] byte_address);
begin
    return byte_address[7:0] ^ {byte_address[9:8], byte_address[10:8], byte_address[10:8]};    // アドレスに対するテストデータ生成
end
endfunction

assign di = {24'h0, address_to_data(ad[3 +: 8])}; // 書き込みデータ -> アドレスに対応するテストデータ
assign ce = !reset;                               // チップイネーブル -> リセット解除後から有効

always_ff @(posedge clock) begin
    if( reset ) begin
        ad <= 14'h000;
        oce <= 1'b0;
        wre <= 1'b1;
        is_read_state <= 0;
        check_enable <= 0;
        expected_data <= 8'h00;
        dout_check <= 0;
    end
    else begin
        ad <= ad + 14'd8;   // アドレスを1バイト分すすめる
        
        if( is_read_state ) begin   // 読み出し・比較フェーズ
            check_enable <= 1;  // 比較処理有効
            expected_data <= address_to_data(ad[3 +: 8]); // 期待値を設定
        end
        else begin
            check_enable <= 0;  // 比較処理無効
            dout_check <= 0;    // 比較結果リセット
        end

        if( ad == 14'(16384 - 8)) begin // 最後のアドレス？
            wre <= !wre;                     // WREを反転
            is_read_state <= !is_read_state; // フェーズ切り替え
        end

        if( check_enable ) begin    // 比較処理
            if( dout != expected_data ) begin
                dout_check <= 1;    // 比較一致エラー
            end
        end
    end
end

endmodule
`default_nettype wire