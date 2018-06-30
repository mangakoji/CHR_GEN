// TEST_PATTERN.v
//      TEST_PATTERN()
//
//180630s       :mod too simple ver
//180630s       :add V reset
//180222r       :refix new coding rule
//151230th      :524line
//              :fix H post amble 50->60
//151222tu      :mod to 720x480p
//               add BLANK
//               add CKE
//151020tu      :    1st. mod coding rule
//              base  form http://sa89a.net/mp.cgi/ele/fpga_hdmi.htm


module TEST_PATTERN
(
      input                 CK_i
    , input                 XAR_i
    , input                 CK_EE_i
    , input tri1            XVRST_i
    , output [ 7 :0]        QQs_R_o
    , output [ 7 :0]        QQs_G_o
    , output [ 7 :0]        QQs_B_o
    , output [15 :0]        HCTRs_o
    , output [15 :0]        VCTRs_o
    , output [ 7 :0]        FCTRs_o
) ;

    reg     [15 :0] HCTRs   ;
    reg     [15 :0] VCTRs   ;
    reg     [ 7 :0] FCTRs   ;
    reg     [ 7 :0] QQs_R    ;
    reg     [ 7 :0] QQs_G    ;
    reg     [ 7 :0] QQs_B    ;

    // main part
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            QQs_R <= 'd0 ;
            QQs_G <= 'd0 ;
            QQs_B <= 'd0 ;
        end else if( CK_EE_i )
        begin
            QQs_R <= HCTRs  ;
            QQs_G <= VCTRs + FCTRs + HCTRs ;
            QQs_B <= VCTRs ;
        end
    assign QQs_R_o = QQs_R ;
    assign QQs_G_o = QQs_G ;
    assign QQs_B_o = QQs_B ;

    // ctl ctr
    reg XVRST_D ;
    wire VRST_xdiv ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i)
            XVRST_D <= 1 ;
        else if( CK_EE_i )
            XVRST_D <= XVRST_i ;
    assign VRST_xdiv = XVRST_D & ( ~ XVRST_i ) ;

    wire            H_cy    ;
    wire            V_cy    ;
    assign H_cy = &( (0+HCTRs) |(~(910  -1))) ;
    assign V_cy = &( (0+VCTRs) |(~(525/2-1))) ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i ) 
        begin
            HCTRs <= 'd0 ;
            VCTRs <= 'd0 ;
            FCTRs <= 'd0 ;
        end else if( CK_EE_i ) 
        begin
            if( VRST_xdiv)
            begin
                HCTRs <= 'd0 ;
                VCTRs <= 'd0 ;
            end else if( ~ H_cy ) 
            begin
                HCTRs <= HCTRs + 1'b1 ;
            end else 
            begin
                HCTRs <= 16'd0 ;
                if( ~ V_cy )
                    VCTRs <= VCTRs + 1'b1 ;
                else 
                begin
                    VCTRs <= 16'd0 ;
                    FCTRs <= FCTRs + 1'b1 ;
                end
            end
        end
    assign HCTRs_o = HCTRs       ;
    assign VCTRs_o = VCTRs       ;
    assign FCTRs_o = FCTRs       ;
endmodule
