/* RXPORTIO.CMD */
/* Sample REXX Program to access I/O ports using TESTCFG.SYS */

/*
 To run this program, the file RXPORTIO.DLL must be in
 the same directory as this file or in a directory
 listed in your LIBPATH.

Prerequisites for RXPORTIO to work properly:

The following statements must be in your CONFIG.SYS

IOPL=YES,FXPRINT  (or just IOPL=YES)
DEVICE=D:\OS2\BOOT\TESTCFG.SYS

These statements are added by default by Warp 3 and Warp 4.

Note: If the port_Address is not returned as the same value, then there was an error in reading or writing to the port.
      The data_value will return the error code from the DosOpen or DosDevIOCtl call.

      The port_Address can have the following values in an error condition:

      port_Address = 10 if DOSOpen during init was unsuccessful.
                     11 if I/O read unsuccessful.
                     12 if I/O write unsuccessful.

      In an error condition, data will return the return code (rc) of the DOSDevIOCtl or DosOpen commands.
      See the IBM VisualAge C/C++ documantation on Control Program or rxPortIO.INF for error code explanation.
  
*/


/* Load RXPORTIO.DLL    */

CALL RXFuncAdd 'PIOLoadFuncs', 'RXPORTIO', 'PIOLoadFuncs'
CALL PIOLoadFuncs

SAY ''
SAY '--- Sample REXX Program to access I/O ports using TESTCFG.SYS.---'
SAY ''

SAY 'CAUTION: This program is capable of writing to I/O directly.'
SAY '         Make sure the port_Address is set to a value'
SAY '         that will not cause harm to your system.'
SAY '         Port_Address is set to 768 (300hex) by default.'
SAY ''

port_Address = X2D('300')                         /* Port_address is converted from hex to decimal */
data_value = 0                                    /* initialize I/O data_value to zero */
SAY 'Address is set to ' || port_Address || ' decimal.'

keyhit = ""
DO FOREVER
   SAY ""
   SAY "Press w to write 0x55, r to Read; d for 0.5 sec delay;"
   SAY "b for bit manipulation; x for eXit..."
   SAY ""
   PARSE PULL keyhit
   SELECT
      when keyhit = "r" | keyhit = "R" then    /* read */
        do
         return_data = PIORead( port_Address )
         SAY 'Read returned ' || return_data
         PARSE VAR return_data . ': ' port1 . ': ' data1

         IF port1 <> port_Address then
           SAY 'error reading port: ' || port_Address || '  rc = ' || data1
         ELSE
           SAY "READ. Address: " || D2X(port1) || "h   Data: " || D2X(data1) || "h = " || X2B(D2X(data1)) || " bin"

         keyhit = ""
        end
      
      when keyhit = "w" | keyhit = "W" then    /* write  */
        do
          data_value = X2D('55')  /* data to write */
          return_data = PIOWrite( port_Address, data_value )
          SAY 'Write returned ' || return_data
          PARSE VAR return_data . ': ' port1 . ': ' data1
          SAY "WRITE. Address: " || D2X(port1) || "h   Data: " || D2X(data1) || "h = " || X2B(D2X(data1)) || " bin"
          keyhit = ""
        end

      when keyhit = "d" | keyhit = "D" then    /* delay  */
        do
          delay_value = 500                                    /* delay 1 to 1000 msec max. */
          SAY 'Start delay of ' || delay_value || ' msec...'
          delay = TIME('R')                                    /* delay verification only */
          return_data = PIODelay( delay_value )
          delay = TIME('E')
          SAY "... End Delay (0 = successfull, 322 = error).  rc = " || return_data
          SAY 'elapsed time = ' || delay
          keyhit = ""
        end

      when keyhit = "b" | keyhit = "B" then    /* bit manipulations */
        do
          value = X2D('FF')  /* init value to 255 (FFhex) */
          SAY 'BitPick. Bit 0 of ' || value || ' is ' || PIOBitPick(value, '0')
          SAY 'BitClear. Bit 1 cleared of ' || value || ' is ' || PIOBitClear(value, '1')
          SAY 'BitClear. Bit 8 cleared of 257 is ' || PIOBitClear('257', '8')
          SAY 'BitSet. Bit 15 set of 0 is ' || PIOBitSet('0', '15')
          keyhit = ""
        end

   otherwise
     DO
       IF keyhit = "x" | keyhit = "X" THEN
         DO
            CALL PIODropFuncs
            SAY 'RXPORTIO dropped.'
            EXIT
         END
       ELSE
         SAY "Invalid Input"
     END
   end  /* select */
end /* do */

EXIT

