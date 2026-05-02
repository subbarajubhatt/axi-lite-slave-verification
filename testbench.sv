module axi_lite_slave_tb;

logic        ACLK;
logic        ARESETn;

logic [7:0]  AWADDR;
logic        AWVALID;
logic        AWREADY;

logic [31:0] WDATA;
logic        WVALID;
logic        WREADY;

logic [1:0]  BRESP;
logic        BVALID;
logic        BREADY;

logic [7:0]  ARADDR;
logic        ARVALID;
logic        ARREADY;

logic [31:0] RDATA;
logic [1:0]  RRESP;
logic        RVALID;
logic        RREADY;

axi_lite_slave dut (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),
    .WDATA(WDATA),
    .WVALID(WVALID),
    .WREADY(WREADY),
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),
    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RVALID(RVALID),
    .RREADY(RREADY)
);

always #5 ACLK = ~ACLK;

task axi_write(input [7:0] addr, input [31:0] data);
begin
    @(posedge ACLK);
    AWADDR  = addr;
    WDATA   = data;
    AWVALID = 1;
    WVALID  = 1;
    BREADY  = 1;

    wait(AWREADY && WREADY);

    @(posedge ACLK);
    AWVALID = 0;
    WVALID  = 0;

    wait(BVALID);

    @(posedge ACLK);
    BREADY = 0;

    $display("WRITE: Address=%0d Data=%h", addr, data);
end
endtask

task axi_read(input [7:0] addr, input [31:0] expected);
begin
    @(posedge ACLK);
    ARADDR  = addr;
    ARVALID = 1;
    RREADY  = 1;

    wait(ARREADY);

    @(posedge ACLK);
    ARVALID = 0;

    wait(RVALID);

    @(posedge ACLK);
    if (RDATA == expected)
        $display("PASS READ: Address=%0d Data=%h", addr, RDATA);
    else
        $display("FAIL READ: Address=%0d Expected=%h Got=%h", addr, expected, RDATA);

    RREADY = 0;
end
endtask

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, axi_lite_slave_tb);

    ACLK = 0;
    ARESETn = 0;

    AWADDR = 0;
    AWVALID = 0;
    WDATA = 0;
    WVALID = 0;
    BREADY = 0;

    ARADDR = 0;
    ARVALID = 0;
    RREADY = 0;

    #20 ARESETn = 1;

    axi_write(8'h10, 32'hA5A5A5A5);
    axi_read (8'h10, 32'hA5A5A5A5);

    axi_write(8'h20, 32'h12345678);
    axi_read (8'h20, 32'h12345678);

    axi_write(8'h30, 32'hDEADBEEF);
    axi_read (8'h30, 32'hDEADBEEF);

    $display("AXI-Lite verification completed.");
    $finish;
end

endmodule
