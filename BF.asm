.data  
fileBuffer: .space 1024
outputBuffer: .space 2048
fileName: .asciiz "test.bf"

.text

#open a file for reading
li   $v0, 13       # system call for open file
la   $a0, fileName      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s1, $v0      # save the file descriptor 
ble $s1 $zero Exit

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s1      # file descriptor 
la   $a1, fileBuffer   # address of buffer to which to read
li   $a2, 1024     # hardcoded buffer length
syscall            # read from file

# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s1      # file descriptor to close
syscall            # close file

# do the work
#t1 - first avail memory, t0 - currently processed address
la $t0 fileBuffer 
la $t1 outputBuffer

# phase 1: process all
loopPhase1: lb $a0 0($t0) # a0 - currently processed instruction 
  li $v0 11
  syscall
  li $a1 44 # ,
  beq $a0 $a1 prz
  li $a1 46 # .
  beq $a0 $a1 kr
  li $a1 60 # <
  beq $a0 $a1 lt
  li $a1 62 # >
  beq $a0 $a1 gt
  li $a1 91 # [
  beq $a0 $a1 op
  li $a1 93 # ]
  beq $a0 $a1 cl
  li $a1 43 # +
  beq $a0 $a1 pl
  li $a1 45 # -
  beq $a0 $a1 mi
  j endPhase1
contPhase1: addi $t0 $t0 1
  la $a1 fileBuffer
  addi $a1 $a1 1022
  beq $t0 $a0 endPhase1
  la $a1 outputBuffer
  addi $a1 $a1 2000
  bge $t0 $a1 endPhase1
  j loopPhase1

# during execution t0 shall hold pointer
gt:
  addi $a1 $zero 0x21080004 # addi $t0 $t0 4
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1
lt:
  addi $a1 $zero 0x2108fffc # addi $t0 $t0 -4
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1
pl:
  addi $a1 $zero 0x8d050000 # lw $a1 0($t0)
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20a50001 # addi $a1 $a1 1
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0xad050000 # sw $a1 0($t0) 
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1
mi:
  addi $a1 $zero 0x8d050000 # lw $a1 0($t0)
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20a5ffff # addi $a1 $a1 -1
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0xad050000 # sw $a1 0($t0) 
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1
kr:
  addi $a1 $zero 0x8d040000 # lw $a0 0($t0)
  sw $a1 0($t1)
  addi $t1 $t1 4
#  addi $a1 $zero 0x24020001 # li $v0 1
  addi $a1 $zero 0x2402000b # li $v0 11 
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x0000000c # syscall
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1
prz:
  addi $a1 $zero 0x24020005 # li $v0 5
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x0000000c # syscall
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0xad020000 # sw $v0 0($t0)
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1
op:
# find next matching bracket, undefined behaviour if there's none
# t2, t3 unused yet
  addi $t3 $zero 1
  move $t2 $t0  
loopOp: beq $t3 $zero doneOp
  addi $t2 $t2 1
  lb $a1 0($t2)
  addi $a1 $a1 -91
  beq $a1 $zero opOp
  addi $a1 $a1 -2
  beq $a1 $zero opCl
  j loopOp
opOp: addi $t3 $t3 1
  j loopOp
opCl: addi $t3 $t3 -1
  j loopOp
doneOp:
  addi $a1 $zero 0x8d040000 # lw $a0 0($t0)
  sw $a1 0($t1)
  addi $t1 $t1 4
  sub $a1 $t2 $t0
  sll $a1 $a1 2 # instructions are translated 1 - 4 (hopefully)
  addi $a1 $a1 -2 # as this is 2nd instruction of this cycle
#  srl $a1 $a1 2 # instructions are word aligned
  andi $a1 $a1 0x0000ffff # well.. technically it could be longer then that..
  ori $a1 $a1 0x10800000 # beq $a0 $zero ...
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1
cl:
# find prev matching bracket, undefined behaviour if there's none
  addi $t3 $zero -1
  move $t2 $t0
loopCl: beq $t3 $zero doneCl
  addi $t2 $t2 -1
  lb $a1 0($t2)
  addi $a1 $a1 -91
  beq $a1 $zero clOp
  addi $a1 $a1 -2
  beq $a1 $zero clCl
  j loopCl
clOp: addi $t3 $t3 1
  j loopCl
clCl: addi $t3 $t3 -1
  j loopCl
doneCl: addi $a1 $zero 0x8d040000 # lw $a0 0($t0)
  sw $a1 0($t1)
  addi $t1 $t1 4
  sub $a1 $t0 $t2
#  subi $a1 $a1 1 # experimental
  sll $a1 $a1 2 # 1 - 4 : BF - asm instructions
  subi $a1 $a1 1
#  srl $a1 $a1 2 # as instructions are on word aligned
  neg $a1 $a1
  addi $a1 $a1 1
  andi $a1 $a1 0x0000ffff # well.. technically it could be longer then that..
  ori $a1 $a1 0x14800000 # bne $a0 $zero ...
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  addi $a1 $zero 0x20000000 # addi $zero $zero 0
  sw $a1 0($t1)
  addi $t1 $t1 4
  j contPhase1

endPhase1:
  addi $a1 $zero 0x2402000a # li $v0 10 
  sw $a1 0($t1)
  addi $t1 $t1 4
  
  addi $a1 $zero 0x0000000c # syscall
  sw $a1 0($t1)
  addi $t1 $t1 4
  
  # zero memory given to prog
  la $a0 fileBuffer
  addi $a1 $a0 1000
loopEP1: sw $zero 0($a1)
  beq $a1 $a0 execute
  addi $a1 $a1 -4
  j loopEP1
execute: la $t0 fileBuffer
  la $a1 outputBuffer
  jr $a1
  

Exit: li $v0, 10
  syscall
