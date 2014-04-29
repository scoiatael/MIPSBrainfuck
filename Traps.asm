   .data 

dat: .asciiz "123456789101112131415"

   .text
main:
   la $t0 dat
   lw $t1 1($t0)
   lw $t1 2($t0)
   lw $t1 3($t0)
   sw $t1 1($t0)
   sw $t1 2($t0)
   sw $t1 3($t0)
   
   li   $v0, 10   # After return from exception handler, specify exit service
   syscall        # terminate normally


.kdata

dataMK: .word 0 0x03e00008

# Trap handler in the standard MIPS32 kernel text segment

   .ktext 0x80000180

   subi $sp $sp 16
   sw $k0 0($sp)
   sw $k1 4($sp)
   sw $ra 8($sp)
   sw $t9 12($sp)

   mfc0 $k1 $14
   lw $k1 0($k1)
   andi $k1 $k1 0xfc000000
   subi $k1 $k1 0x8c000000 
   beq $k1 $zero Load
   subi $k1 $k1 0x20000000
   beq $k1 $zero Store
   j eHdone
Store:
   mfc0 $k0 $14
   lw $k0 0($k0)
   andi $k0 $k0 0x001f0000 # dest address from load
   ori $k0 $k0 0x0000d821
   la $t9 dataMK
   sw $k0 0($t9)
   la $ra sBack
   jr $t9
sBack:
   mfc0 $ra $8
   andi $k0 $k1 0x000000ff
   sb $k0 0($ra)
   andi $k0 $k1 0x0000ff00
   srl $k0 $k0 8
   sb $k0 1($ra)
   andi $k0 $k1 0x00ff0000
   srl $k0 $k0 16
   sb $k0 2($ra)
   andi $k0 $k1 0xff000000
   srl $k0 $k0 24
   sb $k0 3($ra)
   j eHdone
Load: 
   mfc0 $ra $8
   lb $k1 0($ra)
   lb $k0 1($ra)
   sll $k0 $k0 8
   or $k1 $k0 $k1
   lb $k0 2($ra)
   sll $k0 $k0 16
   or $k1 $k0 $k1
   lb $k0 3($ra)
   sll $k0 $k0 24
   or $k1 $k0 $k1 # k1 now holds value read from mem
   mfc0 $k0 $14
   lw $k0 0($k0)
   andi $k0 $k0 0x001f0000 # dest address from load
   srl $k0 $k0 5
   ori $k0 $k0 0x001b0021   
   la $t9 dataMK
   sw $k0 0($t9)
   la $ra lBack
   jr $t9
lBack:


   #
eHdone:   mfc0 $k0,$14   # Coprocessor 0 register $14 has address of trapping instruction
   addi $k0,$k0,4 # Add 4 to point to next instruction
   mtc0 $k0,$14   # Store new address back into $14

   lw $k0 0($sp)
   lw $k1 4($sp)
   lw $ra 8($sp)
   lw $t9 12($sp)
   addi $sp $sp 16
   eret           # Error return; set PC to value in $14

