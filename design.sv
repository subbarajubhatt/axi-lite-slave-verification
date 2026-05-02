module axi_lite_slave (
    input  logic        ACLK,
    input  logic        ARESETn,

    input  logic [7:0]  AWADDR,
    input  logic        AWVALID,
    output logic        AWREADY,

    input  logic [31:0] WDATA,
    input  logic        WVALID,
    output logic        WREADY,

    output logic [1:0]  BRESP,
    output logic        BVALID,
    input  logic        BREADY,

    input  logic [7:0]  ARADDR,
    input  logic        ARVALID,
    output logic        ARREADY,

    output logic [31:0] RDATA,
    output logic [1:0]  RRESP,
    output logic        RVALID,
    input  logic        RREADY
);

logic [31:0] mem [0:255];

always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        AWREADY <= 0;
        WREADY  <= 0;
        BVALID  <= 0;
        BRESP   <= 2'b00;
        ARREADY <= 0;
        RVALID  <= 0;
        RRESP   <= 2'b00;
        RDATA   <= 0;
    end else begin
        AWREADY <= 0;
        WREADY  <= 0;
        ARREADY <= 0;

        if (AWVALID && WVALID && !BVALID) begin
            AWREADY <= 1;
            WREADY  <= 1;
            mem[AWADDR] <= WDATA;
            BVALID <= 1;
            BRESP  <= 2'b00;
        end

        if (BVALID && BREADY) begin
            BVALID <= 0;
        end

        if (ARVALID && !RVALID) begin
            ARREADY <= 1;
            RDATA <= mem[ARADDR];
            RVALID <= 1;
            RRESP <= 2'b00;
        end

        if (RVALID && RREADY) begin
            RVALID <= 0;
        end
    end
end

endmodule
