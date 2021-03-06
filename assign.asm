.data
what: .asciiz "Type 1 for sorting intregers"
number: .asciiz "Enter the number of elements in the array"
el: .asciiz "Enter the element of the array"
array: .word 0:1000
print: .asciiz "The elements in ascending order are:"
token: .asciiz ", "
.text

main:
la $a1, array #store array in a1
#determine which types of data to sort
li $v0, 4
la $a0, what
syscall

li $v0, 5
syscall

move $s2, $v0 #s2 1 - integers, 0 - strings
#end

#number of element in the array
li $v0, 4
la $a0, number
syscall

li $v0, 5
syscall

move $s1, $v0 #s1 numder of elements in the array
#end

#start reading the elements of the array
li $t1, 0 #i = 0
move $t2, $s1 #n= s1 (number of elements of the array
add $t3, $zero, $a1 
Loop:
bge $t1, $t2, exit #i != n
#ask for the element
li $v0, 4
la $a0, el
syscall
#end
#t4 = &a1[i]
#sll $t3, $t1, 2
#add $t4, $a1, $t3 #t3 = &a1[i]
#read an element and store it to the array
li $v0, 5
syscall
sw $v0, 0($t3)
addi $t3, $t3,4
#end
addi $t1, $t1, 1
j Loop
exit:

#exit:
#addi $t1, $t1, -1
#addi $a1, $a1, -4

#end


#la $a2, ($s1) #a2 = number of elements
#lw $a2, 0($a2)#get the last value in array right
#add $a2, $a2, -1 #last element in array
subi $t3, $s1, 1
add $a2, $zero, $t3 #right 
move $a3, $zero#left
jal quicksort

###############
##printing the sorted array
li $v0, 4
la $a0, print
syscall
add $t4, $s1, $zero
add $t5, $a1, $zero #array
print_array:
beq $t4, $zero, print_end
lw $t6, 0($t5)
add $a0, $t6, $zero
li $v0, 1
syscall
beq $t4, 1, no_token
li $v0, 4
la $a0, token
syscall
no_token:
addi $t5, $t5, 4
subi $t4, $t4, 1
j print_array
print_end:
li $v0, 10
syscall

#la $t0, array #copy of array in $t0
#la $t1, $s1
#lw $t1, 0($t1)
#sll $t1, $t1, 2 
###############

quicksort:#int A[]($a1), int left(0=$a3), int right($s1=$a2)
addi $sp, $sp, -12
sw $s2, 12($sp)
sw $a3, 8($sp)#right
sw $a2, 4($sp)#left
sw $ra, 0($sp)

jal partition
addi $s0, $v0, 0#index
subi $t0, $s0, 1
add $t7, $a2, $zero
j if_2 # to delete
if_1:
slt $t1, $a3, $t0 #t1 = 1 if left < index - 1
beq $t1, $zero, _qsrt_end_2#if_2######################
sub $sp, $sp, 20
sw $a3, 16($sp)
sw $a2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)
move $a2, $a2
addi $a2, $s0, -1 #right = index - 1
move $a3, $a3
jal quicksort
################sw $zero, 0
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $a2, 12($sp)
lw $a3, 16($sp)
add $sp, $sp, 20
j _qsrt_end_2 # to delete

if_2:
slt $t2, $s0, $t7
beq $t2, $zero, quicksort_end
sub $sp, $sp, 20
sw $a3, 16($sp)
sw $a2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)
#move $a2, $a2
add $a3, $s0, $zero
move $a2, $a2
#add $a2, $t7, $zero
jal quicksort
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $a2, 12($sp)
lw $a3, 16($sp)
add $sp, $sp, 20
quicksort_end:
j if_1 # to delete
_qsrt_end_2:
lw $ra, 0($sp)
lw $a3, 4($sp)
lw $a2, 8($sp)
addi $sp, $sp, 12
jr $ra


partition:
addi $sp, $sp, -16
sw $s0, 12($sp)
sw $s1, 8($sp)
sw $s2, 4($sp)
sw $s3, 0($sp)

add $s0, $zero, $a3#left
add $s1, $zero, $a2#right
add $t0, $a2, $a3
srl $t0, $t0, 1
sll $t0, $t0, 2
add $t0, $a1, $t0
lw $t0, 0($t0)
add $s3, $t0, $zero#s3
while_out:
slt $t0, $s1, $s0 #if a2= 7 < a3 =0 then 1 out
bne $t0, $zero, out_end
while_in_1:

add $t1, $zero, $s0
sll $t1, $t1, 2
add $t1, $a1, $t1
lw $t1, 0($t1)#array[i](array[left])
slt $t2, $t1, $s3 #if array[i] <pivot t2 = 1
beq $t2, $zero, while_in_2
addi $s0, $s0, 1
j while_in_1

while_in_2:
add $t3, $zero, $s1 #right
sll $t3, $t3, 2
add $t3, $a1, $t3 #t3 = &array[j](right)
lw $t3, 0($t3) #t3 =array[j]
slt $t4, $s3, $t3
beq $t4, $zero, out_if
subi $s1, $s1, 1
j while_in_2

out_if:
slt $t2, $s1, $s0 #t2 = 1 if s1(j) < s0(i)
bne $t2, $zero, out_ret
add $t1, $zero, $s0
sll $t1, $t1, 2
add $t1, $a1, $t1#&array[i]
lw $t8, 0($t1)
add $t4, $zero, $s1
sll $t4, $t4, 2
add $t4, $a1, $t4#array[j]
lw $t5, 0($t4)
add $s2, $zero, $t8 #tmp = array[i]
sw $t5, 0($t1)#array[i] = array[j] saves contents of t5 into effective memory address
sw $s2, 0($t4) 
addi $s0, $s0, 1
subi $s1, $s1, 1
out_ret: 
j while_out
out_end:
addi $v0, $s0, 0
lw $s0, 12($sp)
lw $s1, 8($sp)
lw $s2, 4($sp)
lw $s3, 0($sp)
addi $sp, $sp, 16
jr $ra
    
     
      
       
        
         
          
           
            
 #addi $t0, $a2, 1 #right
 #add $t1, $a3, $zero#rigth
 
 #if (left>right) return;
 #sub $t2, $a3, $a2#first-left
 #slti $t3, $t2, 0 #if first-left<0 t3 = 1, else 0
 #beq $t3, $zero, loop_1#if first-left>
 #jr $ra
 #endif
 
 #loop_1:
 #sll $t2
 
 
 


#bne $s2, 1, strings









strings:


