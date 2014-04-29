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
   srl $k0 $k0 16
   j moveToK1 # moves value from register specified by number in k0 to k1
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
   srl $k0 $k0 16
   j moveToK0 # moves from k1 to index specified in k0

   #
eHdone:   mfc0 $k0,$14   # Coprocessor 0 register $14 has address of trapping instruction
   addi $k0,$k0,4 # Add 4 to point to next instruction
   mtc0 $k0,$14   # Store new address back into $14
   eret           # Error return; set PC to value in $14
   
moveToK0: # k0 may be from 27 to 2 -> 25 possibilities
   subi $k0 $k0 1
l2: subi $k0 $k0 1
bnez $k0 l3
move $v0 $k1
j eHdone
l3: subi $k0 $k0 1
bnez $k0 l4
move $v1 $k1
j eHdone
l4: subi $k0 $k0 1
bnez $k0 l5
move $a0 $k1
j eHdone
l5: subi $k0 $k0 1
bnez $k0 l6
move $a1 $k1
j eHdone
l6: subi $k0 $k0 1
bnez $k0 l7
move $a2 $k1
j eHdone
l7: subi $k0 $k0 1
bnez $k0 l8
move $a3 $k1
j eHdone
l8: subi $k0 $k0 1
bnez $k0 l9
move $t0 $k1
j eHdone
l9: subi $k0 $k0 1
bnez $k0 l10
move $t1 $k1
j eHdone
l10: subi $k0 $k0 1
bnez $k0 l11
move $t2 $k1
j eHdone
l11: subi $k0 $k0 1
bnez $k0 l12
move $t3 $k1
j eHdone
l12: subi $k0 $k0 1
bnez $k0 l13
move $t4 $k1
j eHdone
l13: subi $k0 $k0 1
bnez $k0 l14
move $t5 $k1
j eHdone
l14: subi $k0 $k0 1
bnez $k0 l15
move $t6 $k1
j eHdone
l15: subi $k0 $k0 1
bnez $k0 l16
move $t7 $k1
j eHdone
l16: subi $k0 $k0 1
bnez $k0 l17
move $s0 $k1
j eHdone
l17: subi $k0 $k0 1
bnez $k0 l18
move $s1 $k1
j eHdone
l18: subi $k0 $k0 1
bnez $k0 l19
move $s2 $k1
j eHdone
l19: subi $k0 $k0 1
bnez $k0 l20
move $s3 $k1
j eHdone
l20: subi $k0 $k0 1
bnez $k0 l21
move $s4 $k1
j eHdone
l21: subi $k0 $k0 1
bnez $k0 l22
move $s5 $k1
j eHdone
l22: subi $k0 $k0 1
bnez $k0 l23
move $s6 $k1
j eHdone
l23: subi $k0 $k0 1
move $s7 $k1
j eHdone

moveToK1: 
   subi $k0 $k0 1
ll2: subi $k0 $k0 1
bnez $k0 ll3
move $k1 $v0
j eHdone
ll3: subi $k0 $k0 1
bnez $k0 ll4
move $k1 $v1
j eHdone
ll4: subi $k0 $k0 1
bnez $k0 ll5
move $k1 $a0
j eHdone
ll5: subi $k0 $k0 1
bnez $k0 ll6
move $k1 $a1
j eHdone
ll6: subi $k0 $k0 1
bnez $k0 ll7
move $k1 $a2
j eHdone
ll7: subi $k0 $k0 1
bnez $k0 ll8
move $k1 $a3
j eHdone
ll8: subi $k0 $k0 1
bnez $k0 ll9
move $k1 $t0
j eHdone
ll9: subi $k0 $k0 1
bnez $k0 ll10
move $k1 $t1
j eHdone
ll10: subi $k0 $k0 1
bnez $k0 ll11
move $k1 $t2
j eHdone
ll11: subi $k0 $k0 1
bnez $k0 ll12
move $k1 $t3
j eHdone
ll12: subi $k0 $k0 1
bnez $k0 ll13
move $k1 $t4
j eHdone
ll13: subi $k0 $k0 1
bnez $k0 ll14
move $k1 $t5
j eHdone
ll14: subi $k0 $k0 1
bnez $k0 ll15
move $k1 $t6
j eHdone
ll15: subi $k0 $k0 1
bnez $k0 ll16
move $k1 $t7
j eHdone
ll16: subi $k0 $k0 1
bnez $k0 ll17
move $k1 $s0
j eHdone
ll17: subi $k0 $k0 1
bnez $k0 ll18
move $k1 $s1
j eHdone
ll18: subi $k0 $k0 1
bnez $k0 ll19
move $k1 $s2
j eHdone
ll19: subi $k0 $k0 1
bnez $k0 ll20
move $k1 $s3
j eHdone
ll20: subi $k0 $k0 1
bnez $k0 ll21
move $k1 $s4
j eHdone
ll21: subi $k0 $k0 1
bnez $k0 ll22
move $k1 $s5
j eHdone
ll22: subi $k0 $k0 1
bnez $k0 ll23
move $k1 $s6
j eHdone
ll23: subi $k0 $k0 1
move $k1 $s7
j eHdone