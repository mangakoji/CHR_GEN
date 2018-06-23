/*
 *  atoi.c
 *2017-10-12r   :mod error code
 * 2013-01-21W1 : ctoi.c independ from ALC00.c
 * 2013-01-17W4 : new ALC00.c from reg_test.c
 * 2013-01-10W4 : DEBUG REG_IF
 * 2013-01-08W3 : 1st.
 * 
 */

// #define REGIF_DEBUG

//#include "system.h"
//#include "sys/alt_stdio.h"
//#include "sys/alt_irq.h"
////#include "alt_types"
//#include "altera_avalon_pio_regs.h"
//#include "HAL/inc/priv/alt_legacy_irq.h"
//#include "io.h"
//#include "port.h"
//#define C_LINE_LEN 10
//#define LINE_C( x ) (line[(((x) + C_LINE_LEN) % C_LINE_LEN)])
//#define HEX_CHR( c ) (((c)<10) ? (c)+0x30 : (c)+0x41-10)

//#include "ctoi.h"
const int C_CHR2INT_RNG_ERR = -1 ;
int ctoi(char const c)
{
        if (c < 0x30)
                return C_CHR2INT_RNG_ERR ;
        else if (c <= 0x39)
                return c - 0x30 ;
        else if (c < 0x41)
                return C_CHR2INT_RNG_ERR ;
        else if (c <= 0x46)
                return c - 0x41 + 10 ;
        else if (c < 0x61)
                return C_CHR2INT_RNG_ERR ;
        else if (c <= 0x66)
                return c - 0x61 + 10 ;
        else
                return C_CHR2INT_RNG_ERR ;
}
