/*
 *
 *	This boot code is for mips I
 *	Plasma Project
 *
 */

.section .text
.align 2
.global _reset
.ent	_reset
.org 0x0
   
_reset:
   .set noreorder

   #These four instructions should be the first instructions.
   la    $gp, _gp             #initialize global pointer
   la    $5, __bss_start      #$5 = .sbss_start
   la    $4, __bss_end             #$2 = .bss_end
   la    $sp, __stack_pointer  #initialize stack pointer

$BSS_CLEAR:
   sw    $0, 0($5)
   slt   $3, $5, $4
   bnez  $3, $BSS_CLEAR
   addiu $5, $5, 4

   jal   main
   nop
$L1:
   j $L1

.end _reset

