// hello_world_small.c
//
//171207w 009   :dbg ucom reg read out
//171207w 008   :ucom reg read out
//171206w 007   :md LOC SWEEP
//171205t 006_A :add LOC SWEEP
//171128t C     :append REG8-F
//171012r A     :mod coding rule(almost {} location)
//171011w A     :dbg VIRQ
//171010t C     :off sweep
//171010t B     :008 and sweep
/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "sys/alt_stdio.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "ctoi.h"
int main()
{ 
    int ctr = 0 ;
//    IOWR_ALTERA_AVALON_PIO_DATA(PIO_2_BASE, 0x29) ;
//    IOWR_ALTERA_AVALON_PIO_DATA(PIO_3_BASE, 0x36) ;
//    IOWR_ALTERA_AVALON_PIO_DATA(PIO_4_BASE, 0x8b) ;
//    IOWR_ALTERA_AVALON_PIO_DATA(PIO_5_BASE, 0x37) ;
//    IOWR_ALTERA_AVALON_PIO_DATA(PIO_7_BASE, 0xFFF) ;
      alt_putstr("Hello from Nios II!\n");
//      for(;;){
//        for(int iii=0;iii<10000;iii++) ;
//        IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, ctr++) ;
//        IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, ctr++) ;
//      }


    int c = 0xF0 ;
    char buf [256] ;
    int slen = 0 ;
    int loop_on = 0 ;
    int BUS_LOC = 0 ;
    int iii ;
    int jjj ;
    int read_num = -1 ;
//    IOWR_ALTERA_AVALON_PIO_DATA(PIO_6_BASE, 0x0003) ;
    /* Event loop never exits. */
    for(ctr=0;;ctr++)
    {
        do 
        {
            c = alt_getchar() ;
            alt_putchar( (unsigned char)c ) ;
            buf[slen++] = (unsigned char) c ;
        } while(c!=0x0A) ;
        if (slen <6) 
        {
            continue ;
        }
        c =
             4096 * ctoi(buf[slen-5])
            + 256 * ctoi(buf[slen-4])
            +  16 * ctoi(buf[slen-3])
            +       ctoi(buf[slen-2])
        ;
        switch ( buf[slen - 6] ) 
        {
                case '0' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, c) ;
                    break ;
                case '1' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, c) ;
                    break ;
                case '2' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_2_BASE, c) ;
                    BUS_LOC = c ;
                    break ;
                case '3' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_3_BASE, c) ;
                    break ;
                case '4' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_4_BASE, c) ;
                    break ;
                case '5' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_5_BASE, c) ;
                    break ;
                case '6' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_6_BASE, c) ;
                    break ;
                case '7' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_7_BASE, c) ;
                    break ;
                case '8' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_8_BASE, c) ;
                    break ;
                case '9' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_9_BASE, c) ;
                    break ;
                case 'A' :
                case 'a' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_A_BASE, c) ;
                    break ;
                case 'B' :
                case 'b' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_B_BASE, c) ;
                    break ;
                case 'C' :
                case 'c' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_C_BASE, c) ;
                    break ;
                case 'D' :
                case 'd' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_D_BASE, c) ;
                    break ;
                case 'E' :
                case 'e' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_E_BASE, c) ;
                    break ;
                case 'F' :
                case 'f' :
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_F_BASE, c) ;
                    break ;
                case 'L' :
                case 'l' : 
                {
                    loop_on = (loop_on != 0) ? 0 : -1 ;
                    alt_printf("%x" , loop_on) ;
                    alt_putchar( 0x0a ) ;
                    break ;
                }
                case 'R' :
                case 'r' :
                {
                    read_num  = ctoi(buf[slen-5]) ;
                    break ;
                }
                default :
                    break ;
        }
//        alt_printf("%x" , slen) ;
//        alt_putchar( 0x20 ) ;
        alt_printf
        (
              "%x" 
            , (unsigned char)(buf[slen - 6] - 0x30)
        ) ;
        alt_putchar( ':' ) ;
        alt_printf("%x" ,  c) ;
//        alt_putchar( ' ' ) ;
//        alt_printf
//        (
//            "%x" 
//            , (unsigned char)( IORD_ALTERA_AVALON_PIO_DATA( PIO_7_BASE ) )
//        ) ;
        alt_putchar( 0x0a ) ;
        slen = 0 ;


        if (loop_on != 0)
        {
            for(jjj=0 ; jjj<(2200*2) ; jjj++)
            {
                for(iii=0;iii<20000;iii++) 
                {
                    IOWR_ALTERA_AVALON_PIO_DATA(PIO_2_BASE , BUS_LOC + jjj );
                } ;
            }
        }
        loop_on = 0 ;


        if (read_num != -1) {
            alt_printf("%s" , "R:" ) ;
            alt_printf("%x" , read_num ) ;
            alt_printf("%s" , ":");
            switch (read_num)
            {
                case 0 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_0_BASE ) ) ;
                    break ;
                case 1 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_1_BASE ) ) ;
                    break ;
                case 2 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_2_BASE ) ) ;
                    break ;
                case 3 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_3_BASE ) ) ;
                    break ;
                case 4 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_4_BASE ) ) ;
                    break ;
                case 5 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_5_BASE ) ) ;
                    break ;
                case 6 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_6_BASE ) ) ;
                    break ;
                case 7 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_7_BASE ) ) ;
                    break ;
                case 8 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_8_BASE ) ) ;
                    break ;
                case 9 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_9_BASE ) ) ;
                    break ;
                case 10 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_A_BASE ) ) ;
                    break ;
                case 11 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_B_BASE ) ) ;
                    break ;
                case 12 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_C_BASE ) ) ;
                    break ;
                case 13 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_D_BASE ) ) ;
                    break ;
                case 14 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_E_BASE ) ) ;
                    break ;
                case 15 :
                    read_num = ( IORD_ALTERA_AVALON_PIO_DATA( PIO_F_BASE ) ) ;
                    break ;
                default :
                    read_num = -1 ;
            }
            alt_printf("%x" , read_num) ;
            alt_printf( "\n" );
        }
        read_num= -1 ;


    } ;
    return 1 ;
}
