   .data 

dat: .asciiz "omgomgomgomgomg"

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

# Trap handler in the standard MIPS32 kernel text segment

   .ktext 0x80000180

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
   ori  $k0 $k0 0x0000d821 # move $k1 $zero
   mtc0 $2 $ra 
   la $k1 special_instruction1
   sw $k0 0($k1)
   special_instruction1: add $zero $zero $zero
   mfc0 $ra $2 
   andi $k0 $k1 0x000000ff
   sb $k0 0($8)
   andi $k0 $k1 0x0000ff00
   srl $k0 $k0 8
   sb $k0 1($8)
   andi $k0 $k1 0x00ff0000
   srl $k0 $k0 16
   sb $k0 2($8)
   andi $k0 $k1 0xff000000
   srl $k0 $k0 24
   sb $k0 3($8)
   j eHdone
Load: 
   lb $k1 0($8)
   lb $k0 1($8)
   sll $k0 $k0 8
   or $k1 $k0 $k1
   lb $k0 2($8)
   sll $k0 $k0 16
   or $k1 $k0 $k1
   lb $k0 3($8)
   sll $k0 $k0 24
   or $k1 $k0 $k1 # k1 now holds value read from mem
   mfc0 $k0 $14
   lw $k0 0($k0)
   andi $k0 $k0 0x001f0000 # dest address from load
   srl $k0 $k0 5
   ori $k0 $k0  0x001b0021 # move $zero $k1
   mtc0 $8 $ra
   la $ra special_instruction2
   sw $k0 0($ra)
   special_instruction2: add $zero $zero $zero
   mfc0 $ra $8
eHdone:   mfc0 $k0,$14   # Coprocessor 0 register $14 has address of trapping instruction
   addi $k0,$k0,4 # Add 4 to point to next instruction
   mtc0 $k0,$14   # Store new address back into $14
   eret           # Error return; set PC to value in $14
   
   

   .kdata	
msg:   
   .asciiz "Trap generated"