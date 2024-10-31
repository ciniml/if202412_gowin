`default_nettype none
module simple_fifo #(
    parameter int WIDTH_BITS = 8,
    parameter int DEPTH_BITS = 10
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

typedef logic [WIDTH_BITS-1:0] data_t;      // データ型
typedef logic [DEPTH_BITS+1-1:0] index_t;   // インデックス型 (2^DEPTH_BITS * 2 - 1まで)

data_t mem [0:(1<<DEPTH_BITS)-1];           // メモリ本体
// インデックスの構造
// [DEPTH_BITS]      // 面を表すビット
// [DEPTH_BITS-1:0]  // メモリアドレス
index_t index_r = 0;    // 読み出しインデックス
index_t index_w = 0;    // 書き込みインデックス
logic is_empty;     // FIFOが空かどうか
logic is_full;      // FIFOが満杯かどうか
assign is_empty = index_r == index_w;   // FIFOが空 -> RとWが同一面 && 同じアドレス
                                        // FIFOが満杯 -> RとWが異なる面 && 同じアドレス
assign is_full = index_r[DEPTH_BITS] != index_w[DEPTH_BITS] 
    && index_r[DEPTH_BITS-1:0] == index_w[DEPTH_BITS-1:0];

assign input_ready = !is_full;  // FIFOが満杯でなければ入力を受け付ける

always @(posedge clock) begin
    if( reset ) begin
        index_r <= 0;       // インデックスを初期化
        index_w <= 0;       // 
        output_valid <= 0;  // 出力VALIDを初期化
    end
    else begin
        if( output_valid && output_ready ) begin    // 出力ハンドシェーク成立
            output_valid <= 0;                      // 出力VALIDをデアサート
        end
        if( input_valid && input_ready ) begin      // 入力ハンドシェーク成立
            mem[index_w[DEPTH_BITS-1:0]] <= input_data; // メモリにデータを書き込む
            index_w <= index_w + 1;                     // 書き込みインデックスを進める
        end
        if( !is_empty && (!output_valid || output_ready) ) begin    // FIFOが空でなく出力可能であれば
            output_valid <= 1;                           // 出力VALIDをアサート
            output_data <= mem[index_r[DEPTH_BITS-1:0]]; // メモリからデータを読み出す
            index_r <= index_r + 1;                      // 読み出しインデックスを進める
        end
    end
end

endmodule
`default_nettype wire