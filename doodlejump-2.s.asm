.data
     displayAddress:    .word    0x10008000
     platformColour:     .word     0x53c653
     bodyColour:     .word     0xc6ff1a
     blackColour:     .word     0x000000
     backgroundColour:     .word     0xffffef
     darkBlue:     .word     0x56c4fc
     lightBlue:     .word     0x98d7f8
     isLeft:     .word 1
     pitchC: .byte 60
     sharpC: .byte 61
     pitchD: .byte 62
     sharpD: .byte 63
     pitchE: .byte 64
     pitchF: .byte 65
     pitchG: .byte 67
     pitchA: .byte 69
     pitchB: .byte 71
     instrument: .byte 24
     volume: .byte 127
     duration: .byte 100
     score:     .word 0
.text
     main:
     lw $t0, displayAddress
     paintOverStart:
          beq $t0, 0x10009000, Over    # branch if adress is 0x10009000
          lw $t4, backgroundColour
          sw $t4, ($t0)    # paint the current unit using background colour
          addi $t0, $t0, 4    # update current unit to next
          j paintOverStart
               Over:
               jal gameStartDisplay
     
     check:
     # check if there's keyboard input
               lw $t5, 0xffff0000
               bne $t5, 1, check
               
               isHasS:
               
                    # check the input value
                    lw $t5, 0xffff0004
                    bne $t5, 0x53, notHasS
                    
                    j sGame
                    
               notHasS:
               j main
     
     
     sGame:
          lw $t5, score
          li $t6, 0
          sw $t6, score
          
          lw $t0, displayAddress    # $t0 stores the base address for display
      
          paintBackground:
               beq $t0, 0x10009000, out    # branch if adress is 0x10009000
               lw $t4, backgroundColour
               sw $t4, ($t0)    # paint the current unit using background colour
               addi $t0, $t0, 4    # update current unit to next
               j paintBackground
      
          out: 
               # default setup before game starts
               lw $t0, displayAddress
               
               # generate bottom platform
               jal drawBottomPlatform
               add $t1, $zero, $v0
               
               # generate middle platform
               jal drawMiddlePlatform
               add $t2, $zero, $v0
               
               # generate top platform
               jal drawTopPlatform
               add $t3, $zero, $v0
               
               # generate default doodle position
               addi, $t5, $t1, -512
               add $t7, $zero, $t5     # store doodle position
               addi $t7, $t7, 4
               addi $a1, $t5, 4
               jal drawDoodle
               
               # display score
               jal displayScore
               
                    
               startGame:
               
               # check if there's keyboard input
               lw $t5, 0xffff0000
               bne $t5, 1, again
               
               isS:
               
                    # check the input value
                    lw $t5, 0xffff0004
                    bne $t5, 0x73, notS
                    
                    respondToS:
                    
                         # jump 15 units up
                         jumpLeftFirst:
                         add $t0, $zero, $zero
                         upJumpLeft:
                              
                              li $v0, 32
                              li $a0, 70
                              syscall
                              
                              
                              # check  input
                              lw $t5, 0xffff0000
                              bne $t5, 1, continueUpLeft
                              
                              checkS:
                              lw $t5, 0xffff0004
                              beq $t5, 0x73, Exit
                              
                              lw $t5, 0xffff0004
                              bne $t5, 0x6a, notJ
                              
                              isJ:
                              lw $t5, isLeft
                              li $t6, 1
                              sw $t6, isLeft
                              jal jumpToLeft
                              
                              notJ:
                              lw $t5, 0xffff0004
                              bne $t5, 0x6b, continueUpLeft
                              
                              isK:
                              lw $t5, isLeft
                              li $t6, 0
                              sw $t6, isLeft
                              jal jumpToRight
  
                              continueUpLeft:
                                   beq $t0, 15, stopUpLeft
                                   jal jumpOneUnitUpLeft
                                   add $a1, $zero, $t2
                                   jal paintPlatform
                                   add $a1, $zero, $t3
                                   jal paintPlatform
                                   addi $t0, $t0, 1
                                   j upJumpLeft
                              
                         stopUpLeft:
                         add $t0, $zero, $zero
                         
                         downFallLeft:
                         
                              li $v0, 32
                              li $a0, 70
                              syscall
                              
                              
                              # check  input
                              lw $t5, 0xffff0000
                              bne $t5, 1, continueDownLeft
                              
                              checkSDown:
                              lw $t5, 0xffff0004
                              beq $t5, 0x73, Exit
                              
                              lw $t5, 0xffff0004
                              bne $t5, 0x6a, notJDown
                              
                              isJDown:
                              lw $t5, isLeft
                              li $t6, 1
                              sw $t6, isLeft
                              jal jumpToLeft
                              
                              notJDown:
                              lw $t5, 0xffff0004
                              bne $t5, 0x6b, continueDownLeft
                              
                              isKDown:
                              lw $t5, isLeft
                              li $t6, 0
                              sw $t6, isLeft
                              jal jumpToRight
  
                              continueDownLeft:
                              
                              beq $t0, 32, stopDownLeft
                              jal fallOneUnitDownLeft
                              
                              # check if game over
                              add $t5, $zero, $t7
                              addi $t6, $zero, 0x10009000
                              slt $t6, $t6, $t5
                              beq $t6, 1, gameOver
                                       
                              notTopLeft:                     
                              # check if falls on middle platform
                              addi $t5, $t7, 520
                              slt $t6, $t5, $t2
                              beq $t6, 1, notMiddleLeft
                              addi $t5, $t7, 516
                              add $t6, $t2, 32
                              slt $t6, $t6, $t5
                              beq $t6, 1, notMiddleLeft
                              isMiddle:
                                   lw $t5, score
                                   addi $t5, $t5, 1
                                   sw $t5, score
                                   jal jumpSound
                                   jal displayScore
                                   lw $t5, score
                                   addi $t6, $zero, 15
                                   div $t5, $t6
                                   mfhi $t6
                                   bne $t6, 0, notDivisible15
                                        jal drawPoggers
                                        lw $t0, displayAddress
                                        paintOverPoggers:
                                             beq $t0, 0x10009000, PoggersOver    # branch if adress is 0x10009000
                                             lw $t4, backgroundColour
                                             sw $t4, ($t0)    # paint the current unit using background colour
                                             addi $t0, $t0, 4    # update current unit to next
                                             j paintOverPoggers
                                        PoggersOver:
                                             add $a1, $zero, $t1
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t2
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t3
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t7
                                             jal drawDoodle
                                             
                                             j stopMeme
                                   notDivisible15:
                                   lw $t5, score
                                   addi $t6, $zero, 10
                                   div $t5, $t6
                                   mfhi $t6
                                   bne $t6, 0, notDivisible10
                                        jal drawAwesome
                                        lw $t0, displayAddress
                                        paintOverAwesome:
                                             beq $t0, 0x10009000, AwesomeOver    # branch if adress is 0x10009000
                                             lw $t4, backgroundColour
                                             sw $t4, ($t0)    # paint the current unit using background colour
                                             addi $t0, $t0, 4    # update current unit to next
                                             j paintOverAwesome
                                        AwesomeOver:
                                             add $a1, $zero, $t1
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t2
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t3
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t7
                                             jal drawDoodle
                                             
                                             j stopMeme
                                   notDivisible10:
                                   lw $t5, score
                                   addi $t6, $zero, 5
                                   div $t5, $t6
                                   mfhi $t6
                                   bne $t6, 0, notDivisible5
                                   jal drawWow
                                        lw $t0, displayAddress
                                        paintOverWow:
                                             beq $t0, 0x10009000, WowOver    # branch if adress is 0x10009000
                                             lw $t4, backgroundColour
                                             sw $t4, ($t0)    # paint the current unit using background colour
                                             addi $t0, $t0, 4    # update current unit to next
                                             j paintOverWow
                                        WowOver:
                                             add $a1, $zero, $t1
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t2
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t3
                                             jal paintPlatform
                                             
                                             add $a1, $zero, $t7
                                             jal drawDoodle
                                             
                                             j stopMeme
                                             
                                   notDivisible5:
                                   
                                   stopMeme:
                                   j jumpLeftSecond
                                        
                                   
                              notMiddleLeft:
                                   # check if falls on bottom platform
                                   addi $t5, $t7, 520
                                   slt $t6, $t5, $t1
                                   beq $t6, 1, notBottom
                                   addi $t5, $t7, 512
                                   add $t6, $t1, 32
                                   slt $t6, $t6, $t5
                                   beq $t6, 1, notBottom
                              isBottomLeft:
                                   jal jumpSound
                                   j jumpLeftFirst
                              
                              notBottom:
                                   add $a1, $zero, $t2
                                   jal paintPlatform
                                   add $a1, $zero, $t1
                                   jal paintPlatform
                                   add $a1, $zero, $t3
                                   jal paintPlatform
                                   addi $t0, $t0, 1
                                   j downFallLeft
                         
                         stopDownLeft:
                         
                    notS:
                         
               again:
                    
                    
               j startGame
               
               gameOver:
                    
                    jal gameOverSound
                    
                    lw $t0, displayAddress
                    paintOverBack:
                         beq $t0, 0x10009000, writeOver    # branch if adress is 0x10009000
                         lw $t4, backgroundColour
                         sw $t4, ($t0)    # paint the current unit using background colour
                         addi $t0, $t0, 4    # update current unit to next
                         j paintOverBack
                    writeOver:
                    jal gameOverDisplay
                    
                    checkRinput:
                    # check if there's keyboard input
                    lw $t5, 0xffff0000
                    bne $t5, 1, checkRinput
               
                    isR:
               
                    # check the input value
                    lw $t5, 0xffff0004
                    beq $t5, 0x73, Exit
                    
                    beq $t5, 0x72, sGame
                    j checkRinput
               
               
               jumpLeftSecond:
               add $t0, $zero, $zero
        
                         upJumpLeftTogether:
                         
                              li $v0, 32
                              li $a0, 70
                              syscall
                              
                              
                              # check  input
                              lw $t5, 0xffff0000
                              bne $t5, 1, continueUpLeftTogether
                              
                              checkS2:
                              lw $t5, 0xffff0004
                              beq $t5, 0x73, Exit
                              
                              lw $t5, 0xffff0004
                              bne $t5, 0x6a, notJ2
                              
                              isJ2:
                              lw $t5, isLeft
                              li $t6, 1
                              sw $t6, isLeft
                              jal jumpToLeft
                              
                              notJ2:
                              lw $t5, 0xffff0004
                              bne $t5, 0x6b, continueUpLeftTogether
                              
                              isK2:
                              lw $t5, isLeft
                              li $t6, 0
                              sw $t6, isLeft
                              jal jumpToRight
  
                              continueUpLeftTogether:
                                   # 3 together up move
                                   beq $t0, 2, stopUpLeftTogether
                                   jal jumpOneUnitUpLeftTogether
                                   jal displayScore
                                   addi $t0, $t0, 1
                                   j upJumpLeftTogether
                              
                         stopUpLeftTogether:
                        
                              lw $t4, backgroundColour
                              sw $t4, 0($t1)
                              sw $t4, 4($t1)
                              sw $t4, 8($t1)
                              sw $t4, 12($t1)
                              sw $t4, 16($t1)
                              sw $t4, 20($t1)
                              sw $t4, 24($t1)
                              sw $t4, 28($t1)
                              # update platform location
                              add $t1, $zero, $t2
                              add $t2, $zero, $t3

                              # generate top platform
                              jal drawNewPlatform
                              add $t3, $zero, $v0
                              
                              add $t0, $zero, $zero
                              
                              upJumpLeftAllTogether:
                              
                              li $v0, 32
                              li $a0, 70
                              syscall
                              
                              
                              # check  input
                              lw $t5, 0xffff0000
                              bne $t5, 1, continueUpLeftAllTogether
                              
                              checkS1:
                              lw $t5, 0xffff0004
                              beq $t5, 0x73, Exit
                              
                              lw $t5, 0xffff0004
                              bne $t5, 0x6a, notJ1
                              
                              isJ1:
                              lw $t5, isLeft
                              li $t6, 1
                              sw $t6, isLeft
                              jal jumpToLeft
                              
                              notJ1:
                              lw $t5, 0xffff0004
                              bne $t5, 0x6b, continueUpLeftAllTogether
                              
                              isK1:
                              lw $t5, isLeft
                              li $t6, 0
                              sw $t6, isLeft
                              jal jumpToRight
  
                              continueUpLeftAllTogether:
                                   # 7 together up move
                                   beq $t0, 3, stopUpLeftAllTogether
                                   jal jumpOneUnitUpLeftAllTogether
                                   jal displayScore
                                   addi $t0, $t0, 1
                                   j upJumpLeftAllTogether
                              
                         stopUpLeftAllTogether:
                         
                              
                         add $t0, $zero, $zero
                         
                         j downFallLeft
                    
      
      
          Exit:
               li $v0, 10    #terminate the program gracefully
               syscall
               
     paintPlatform:
          addi $sp, $sp, -4
          sw $ra, 0($sp)
          
          add $t5, $zero, $a1
          add $t6, $zero, $zero
          paintLine:
               beq $t6, 8, endPaintLine
               lw $t4, platformColour
               sw $t4, 0($t5)
               addi $t5, $t5, 4
               addi $t6, $t6, 1
               j paintLine
          endPaintLine:
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
               
     drawNewPlatform:
          lw $t6, displayAddress
          addi $sp, $sp, -8
          sw $ra, 4($sp)
           
          addi $a1, $zero, 23    # generate new platform on top
          addi $v0, $zero, 42
          syscall
          add $t5, $zero, $a0
          sll $t5, $t5, 2
          addi $a1, $t5, 0
          add $a1, $a1, $t6
           
          jal paintPlatform
           
          lw $ra, 4($sp)
          add $t5, $t5, -32
          add $v0, $zero, $t5
          addi $sp, $sp, 4
          jr $ra
      
     drawBottomPlatform:
          addi $sp, $sp, -8
          sw $ra, 4($sp)
           
          addi $a1, $zero, 23    # generate bottom platform
          addi $v0, $zero, 42
          syscall
          add $t5, $zero, $a0
          sll $t5, $t5, 2
          addi $a1, $t5, 3968
          add $a1, $a1, $t0
           
          jal paintPlatform
           
          lw $ra, 4($sp)
          add $t5, $t5, -32
          add $v0, $zero, $t5
          addi $sp, $sp, 4
          jr $ra
           
     drawMiddlePlatform:
          addi $sp, $sp, -8
          sw $ra, 4($sp)
           
          addi $a1, $zero, 23    # generate middle platform
          addi $v0, $zero, 42
          syscall
          add $t5, $zero, $a0
          sll $t5, $t5, 2
          addi $a1, $t5, 2432
          add $a1, $a1, $t0
           
          jal paintPlatform
           
          lw $ra, 4($sp)
          add $t5, $t5, -32
          add $v0, $zero, $t5
          addi $sp, $sp, 4
          jr $ra
          
     drawTopPlatform:
          addi $sp, $sp, -8
          sw $ra, 4($sp)
           
          addi $a1, $zero, 23    # generate top platform
          addi $v0, $zero, 42
          syscall
          add $t5, $zero, $a0
          sll $t5, $t5, 2
          addi $a1, $t5, 896
          add $a1, $a1, $t0
           
          jal paintPlatform
           
          lw $ra, 4($sp)
          add $t5, $t5, -32
          add $v0, $zero, $t5
          addi $sp, $sp, 4
          jr $ra
          
     drawDoodle:
          addi $sp, $sp, -4
          sw $ra, 0($sp)
          
          lw $t5, isLeft
          beq $t5, 0, drawRightDoodle
          
          add $t5, $zero, $a1
          add $t6, $zero, $zero
          paintHead:
               lw $t4, bodyColour
               beq $t6, 3, outHead
               sw $t4, 0($t5)
               addi $t5, $t5, 4
               addi $t6, $t6, 1
               j paintHead
          outHead:
               add $t5, $zero, $a1
               addi $t5, $t5, 124
               add $t6, $zero, $zero
          paintMouth:
               beq $t6, 4, outMouth
               sw $t4, 0($t5)
               addi $t5, $t5, 4
               addi $t6, $t6, 1
               j paintMouth
          outMouth:
               add $t5, $zero, $a1
               addi $t5, $t5, 256
               add $t6, $zero, $zero
          paintStomach:
               lw $t4, platformColour
               beq $t6, 3, outStomach
               sw $t4, 0($t5)
               addi $t5, $t5, 4
               addi $t6, $t6, 1
               j paintStomach
          outStomach:
               add $t5, $zero, $a1
               addi $t5, $t5, 384
               lw $t4, blackColour
               sw $t4, 0($t5)
               sw $t4, 8($t5)
               j terminateDraw
               
     drawRightDoodle:
          addi $sp, $sp, -4
          sw $ra, 0($sp)
          
          add $t5, $zero, $a1
          add $t6, $zero, $zero
          paintRightHead:
               lw $t4, bodyColour
               beq $t6, 3, outRightHead
               sw $t4, 0($t5)
               addi $t5, $t5, 4
               addi $t6, $t6, 1
               j paintRightHead
          outRightHead:
               add $t5, $zero, $a1
               addi $t5, $t5, 128
               add $t6, $zero, $zero
          paintRightMouth:
               beq $t6, 4, outRightMouth
               sw $t4, 0($t5)
               addi $t5, $t5, 4
               addi $t6, $t6, 1
               j paintRightMouth
          outRightMouth:
               add $t5, $zero, $a1
               addi $t5, $t5, 256
               add $t6, $zero, $zero
          paintRightStomach:
               lw $t4, platformColour
               beq $t6, 3, outRightStomach
               sw $t4, 0($t5)
               addi $t5, $t5, 4
               addi $t6, $t6, 1
               j paintRightStomach
          outRightStomach:
               add $t5, $zero, $a1
               addi $t5, $t5, 384
               lw $t4, blackColour
               sw $t4, 0($t5)
               sw $t4, 8($t5)
               
          terminateDraw:
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
               
     jumpOneUnitUpLeft:
          addi $sp, $sp, -8
          sw $ra, 0($sp)
          
          add $t5, $zero, $zero     # iterator i
          addi $t6, $t7, -4     # store top left position
          eraseUpLeft:
               lw $t4, backgroundColour
               sw $t4, 128($t6)
               sw $t4, 144($t6)
               sw $t4, 136($t6)
               sw $t4, 260($t6)
               sw $t4, 264($t6)
               sw $t4, 268($t6)
               sw $t4, 388($t6)
               sw $t4, 396($t6)
          stopUpLeftErase:
               add $t7, $t7, -128
               add $a1, $zero, $t7
               jal drawDoodle
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
               
     fallOneUnitDownLeft:
          addi $sp, $sp, -8
          sw $ra, 0($sp)
          
          add $t5, $zero, $zero     # iterator i
          addi $t6, $t7, -4     # store top left position
          eraseDown:
               lw $t4, backgroundColour
               sw $t4, 128($t6)
               sw $t4, 144($t6)
               sw $t4, 4($t6)
               sw $t4, 8($t6)
               sw $t4, 12($t6)
               sw $t4, 132($t6)
               sw $t4, 136($t6)
               sw $t4, 140($t6)
          stopDownErase:
               add $t7, $t7, 128
               add $a1, $zero, $t7
               jal drawDoodle
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
     jumpToLeft:
          addi $sp, $sp, -8
          sw $ra, 0($sp)
          
          add $t5, $zero, $zero     # iterator i
          add $t6, $t7, $zero     # store top left position
          eraseLeft:
               lw $t4, backgroundColour
               sw $t4, 8($t6)
               sw $t4, 136($t6)
               sw $t4, 140($t6)
               sw $t4, 264($t6)
               sw $t4, 392($t6)
               sw $t4, 384($t6)
          stopLeftErase:
               add $t7, $t7, -4
               add $a1, $zero, $t7
               jal drawDoodle
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
               
     jumpOneUnitUpLeftTogether:
          addi $sp, $sp, -8
          sw $ra, 0($sp)
          
          add $t5, $zero, $zero     # iterator i
          addi $t6, $t7, -4     # store top left position
          eraseUpLeftTogether:
          
               # erase doodle
               lw $t4, backgroundColour
               sw $t4, 128($t6)
               sw $t4, 136($t6)
               sw $t4, 144($t6)
               sw $t4, 260($t6)
               sw $t4, 264($t6)
               sw $t4, 268($t6)
               sw $t4, 388($t6)
               sw $t4, 396($t6)
               
               # erase platforms
               sw $t4, 0($t1)
               sw $t4, 4($t1)
               sw $t4, 8($t1)
               sw $t4, 12($t1)
               sw $t4, 16($t1)
               sw $t4, 20($t1)
               sw $t4, 24($t1)
               sw $t4, 28($t1)
               
               sw $t4, 0($t2)
               sw $t4, 4($t2)
               sw $t4, 8($t2)
               sw $t4, 12($t2)
               sw $t4, 16($t2)
               sw $t4, 20($t2)
               sw $t4, 24($t2)
               sw $t4, 28($t2)
               
               sw $t4, 0($t3)
               sw $t4, 4($t3)
               sw $t4, 8($t3)
               sw $t4, 12($t3)
               sw $t4, 16($t3)
               sw $t4, 20($t3)
               sw $t4, 24($t3)
               sw $t4, 28($t3)

          stopUpLeftEraseTogether:
               lw $t4, platformColour
               add $t2, $t2, 256
               sw $t4, 0($t2)
               sw $t4, 4($t2)
               sw $t4, 8($t2)
               sw $t4, 12($t2)
               sw $t4, 16($t2)
               sw $t4, 20($t2)
               sw $t4, 24($t2)
               sw $t4, 28($t2)
               add $t3, $t3, 256
               sw $t4, 0($t3)
               sw $t4, 4($t3)
               sw $t4, 8($t3)
               sw $t4, 12($t3)
               sw $t4, 16($t3)
               sw $t4, 20($t3)
               sw $t4, 24($t3)
               sw $t4, 28($t3)
               add $t1, $t1, 256
               sw $t4, 0($t1)
               sw $t4, 4($t1)
               sw $t4, 8($t1)
               sw $t4, 12($t1)
               sw $t4, 16($t1)
               sw $t4, 20($t1)
               sw $t4, 24($t1)
               sw $t4, 28($t1)
               add $t7, $t7, -128
               add $a1, $zero, $t7
               jal drawDoodle
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
               
     jumpOneUnitUpLeftAllTogether:
          addi $sp, $sp, -8
          sw $ra, 0($sp)
          
          add $t5, $zero, $zero     # iterator i
          addi $t6, $t7, -4     # store top left position
          eraseUpLeftAllTogether:
          
               # erase doodle
               lw $t4, backgroundColour
               sw $t4, 128($t6)
               sw $t4, 136($t6)
               sw $t4, 144($t6)
               sw $t4, 260($t6)
               sw $t4, 264($t6)
               sw $t4, 268($t6)
               sw $t4, 388($t6)
               sw $t4, 396($t6)
               
               # erase platforms
               sw $t4, 0($t1)
               sw $t4, 4($t1)
               sw $t4, 8($t1)
               sw $t4, 12($t1)
               sw $t4, 16($t1)
               sw $t4, 20($t1)
               sw $t4, 24($t1)
               sw $t4, 28($t1)
               
               sw $t4, 0($t2)
               sw $t4, 4($t2)
               sw $t4, 8($t2)
               sw $t4, 12($t2)
               sw $t4, 16($t2)
               sw $t4, 20($t2)
               sw $t4, 24($t2)
               sw $t4, 28($t2)
               
               sw $t4, 0($t3)
               sw $t4, 4($t3)
               sw $t4, 8($t3)
               sw $t4, 12($t3)
               sw $t4, 16($t3)
               sw $t4, 20($t3)
               sw $t4, 24($t3)
               sw $t4, 28($t3)

          stopUpLeftEraseAllTogether:
               lw $t4, platformColour
               add $t1, $t1, 256
               sw $t4, 0($t1)
               sw $t4, 4($t1)
               sw $t4, 8($t1)
               sw $t4, 12($t1)
               sw $t4, 16($t1)
               sw $t4, 20($t1)
               sw $t4, 24($t1)
               sw $t4, 28($t1)
               add $t2, $t2, 256
               sw $t4, 0($t2)
               sw $t4, 4($t2)
               sw $t4, 8($t2)
               sw $t4, 12($t2)
               sw $t4, 16($t2)
               sw $t4, 20($t2)
               sw $t4, 24($t2)
               sw $t4, 28($t2)
               add $t3, $t3, 256
               sw $t4, 0($t3)
               sw $t4, 4($t3)
               sw $t4, 8($t3)
               sw $t4, 12($t3)
               sw $t4, 16($t3)
               sw $t4, 20($t3)
               sw $t4, 24($t3)
               sw $t4, 28($t3)
               add $t7, $t7, -128
               add $a1, $zero, $t7
               jal drawDoodle
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
               
     jumpToRight:
          addi $sp, $sp, -8
          sw $ra, 0($sp)
          
          add $t5, $zero, $zero     # iterator i
          add $t6, $t7, $zero     # store top left position
          eraseRight:
               lw $t4, backgroundColour
               sw $t4, 0($t6)
               sw $t4, 124($t6)
               sw $t4, 256($t6)
               sw $t4, 384($t6)
               sw $t4, 392($t6)
          stopRightErase:
               add $t7, $t7, 4
               add $a1, $zero, $t7
               jal drawDoodle
               lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra

     gameOverDisplay:
          addi $sp, $sp, -4
          sw $ra, 0($sp)
          
          # draw game over display
               lw $t0, displayAddress
               
               # black
               lw $t4, blackColour
               
               # 1st line
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               
               # 2nd line
               addi $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 28($t0)
               sw $t4, 44($t0)
               sw $t4, 52($t0)
               sw $t4, 64($t0)
               sw $t4, 68($t0)
               sw $t4, 72($t0)
               sw $t4, 92($t0)
               sw $t4, 124($t0)
               
               # 3rd line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 88($t0)
               
               # 4th line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 68($t0)
               sw $t4, 84($t0)
               
               # 5th line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 12($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 28($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 80($t0)
               
               # 6th line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 104($t0)
               
               # 7th line
               addi $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 68($t0)
               sw $t4, 72($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 104($t0)
               
               # 8th line
               addi $t0, $t0, 128
               sw $t4, 80($t0)
               
               # 9th line
               addi $t0, $t0, 128
               sw $t4, 64($t0)
               sw $t4, 68($t0)
               sw $t4, 72($t0)
               sw $t4, 76($t0)
               sw $t4, 80($t0)
               
               # 10th line
               addi $t0, $t0, 128
               sw $t4, 60($t0)
               
               # 11th line
               addi $t0, $t0, 128
               sw $t4, 64($t0)
               sw $t4, 68($t0)
               sw $t4, 72($t0)
               sw $t4, 76($t0)
               sw $t4, 80($t0)
               
               # 12th line
               addi $t0, $t0, 128
               sw $t4, 80($t0)
               
               # 13th line
               addi $t0, $t0, 128
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 14th line
               addi $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 24($t0)
               sw $t4, 36($t0)
               sw $t4, 44($t0)
               sw $t4, 48($t0)
               sw $t4, 52($t0)
               sw $t4, 60($t0)
               sw $t4, 64($t0)
               sw $t4, 80($t0)
               
               # 15th line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 36($t0)
               sw $t4, 44($t0)
               sw $t4, 60($t0)
               sw $t4, 68($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 16th line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 36($t0)
               sw $t4, 44($t0)
               sw $t4, 48($t0)
               sw $t4, 60($t0)
               sw $t4, 64($t0)
               sw $t4, 80($t0)
               
               # 17th line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 36($t0)
               sw $t4, 44($t0)
               sw $t4, 60($t0)
               sw $t4, 68($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 18th line
               addi $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 44($t0)
               sw $t4, 60($t0)
               sw $t4, 68($t0)
               sw $t4, 80($t0)
               
               # 19th line
               addi $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 28($t0)
               sw $t4, 44($t0)
               sw $t4, 48($t0)
               sw $t4, 52($t0)
               sw $t4, 60($t0)
               sw $t4, 68($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 20th line
               addi $t0, $t0, 128
               sw $t4, 92($t0)
               sw $t4, 104($t0)
               sw $t4, 116($t0)
               
               # 21st line
               addi $t0, $t0, 128
               sw $t4, 92($t0)
               sw $t4, 104($t0)
               sw $t4, 116($t0)
               
               # 22nd line
               addi $t0, $t0, 128
               sw $t4, 92($t0)
               sw $t4, 104($t0)
               sw $t4, 116($t0)
               
               # 23rd line
               addi $t0, $t0, 128
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 124($t0)
               
               # dark green
               lw $t0, displayAddress
               lw $t4, platformColour
               
               # 14th line
               addi $t0, $t0, 1664
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 18th line
               addi $t0, $t0, 512
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # light green
               lw $t0, displayAddress
               lw $t4, bodyColour
               
               # 2nd line
               addi $t0, $t0, 128
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               
               # 3rd line
               addi $t0, $t0, 128
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 4th line
               addi $t0, $t0, 128
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 5th line
               addi $t0, $t0, 128
               sw $t4, 84($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 6th line
               addi $t0, $t0, 128
               sw $t4, 84($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 7th line
               addi $t0, $t0, 128
               sw $t4, 84($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 8th line
               addi $t0, $t0, 128
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 9th line
               addi $t0, $t0, 128
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 10th line
               addi $t0, $t0, 128
               sw $t4, 64($t0)
               sw $t4, 68($t0)
               sw $t4, 72($t0)
               sw $t4, 76($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 11th line
               addi $t0, $t0, 128
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 12th line
               addi $t0, $t0, 128
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 16th line
               addi $t0, $t0, 512
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # draw game over display
               lw $t0, displayAddress
               
               # dark blue
               lw $t4, darkBlue
               
               # 8th line
               addi $t0, $t0, 896
               sw $t4, 84($t0)
               sw $t4, 108($t0)
               
               add $t5, $zero, $zero
               tearVerticalLoop:
               beq $t5, 25, stopTears
               addi $t0, $t0, 128
               sw $t4, 84($t0)
               sw $t4, 108($t0)
               addi $t5, $t5, 1
               j tearVerticalLoop
               
               stopTears:
               add $t5, $zero, $zero
               addi $t0, $t0, -468
               tearHorizontalLoop:
               beq $t5, 96, stopHorizontal
               sw $t4, 84($t0)
               sw $t4, 108($t0)
               addi $t0, $t0, 4
               addi $t5, $t5, 1
               j tearHorizontalLoop
               
               stopHorizontal:
               
               # light blue
               lw $t0, displayAddress
               lw $t4, lightBlue
               
               # 29th line
               addi $t0, $t0, 3584
               sw $t4, 0($t0)
               sw $t4, 4($t0)
               sw $t4, 8($t0)
               sw $t4, 32($t0)
               sw $t4, 36($t0)
               sw $t4, 80($t0)
               sw $t4, 112($t0)
               
               # 30th line
               addi $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 36($t0)
               sw $t4, 72($t0)
               sw $t4, 76($t0)
               sw $t4, 80($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
          
          lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra
               
gameStartDisplay:
          addi $sp, $sp, -4
          sw $ra, 0($sp)
          
          # draw game start display
               lw $t0, displayAddress
               
               # black
               lw $t4, blackColour
               
               # 4th line
               add $t0, $t0, 384
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 28($t0)
               sw $t4, 40($t0)
               sw $t4, 44($t0)
               sw $t4, 56($t0)
               sw $t4, 60($t0)
               sw $t4, 72($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               
               # 5th line
               add $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 72($t0)
               sw $t4, 88($t0)
               
               # 6th line
               add $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 72($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               
               # 7th line
               add $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 16($t0)
               sw $t4, 24($t0)
               sw $t4, 32($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 72($t0)
               sw $t4, 88($t0)
               
               # 8th line
               add $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 28($t0)
               sw $t4, 40($t0)
               sw $t4, 44($t0)
               sw $t4, 56($t0)
               sw $t4, 60($t0)
               sw $t4, 72($t0)
               sw $t4, 76($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               
               # 12th line
               add $t0, $t0, 512
               sw $t4, 32($t0)
               sw $t4, 36($t0)
               sw $t4, 40($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 68($t0)
               sw $t4, 76($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               
               # 13th line
               add $t0, $t0, 128
               sw $t4, 36($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 72($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 96($t0)
               
               # 14th line
               add $t0, $t0, 128
               sw $t4, 36($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 72($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               
               # 15th line
               add $t0, $t0, 128
               sw $t4, 36($t0)
               sw $t4, 48($t0)
               sw $t4, 56($t0)
               sw $t4, 64($t0)
               sw $t4, 72($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               
               # 16th line
               add $t0, $t0, 128
               sw $t4, 32($t0)
               sw $t4, 52($t0)
               sw $t4, 64($t0)
               sw $t4, 72($t0)
               sw $t4, 80($t0)
               sw $t4, 88($t0)
               
               # 23rd line
               add $t0, $t0, 896
               sw $t4, 36($t0)
               sw $t4, 40($t0)
               sw $t4, 44($t0)
               sw $t4, 48($t0)
               sw $t4, 52($t0)
               sw $t4, 56($t0)
               sw $t4, 60($t0)
               sw $t4, 64($t0)
               sw $t4, 68($t0)
               sw $t4, 72($t0)
               sw $t4, 76($t0)
               sw $t4, 80($t0)
               sw $t4, 84($t0)
               sw $t4, 88($t0)
               
               # 24th line
               add $t0, $t0, 128
               sw $t4, 28($t0)
               sw $t4, 32($t0)
               sw $t4, 36($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               
               # 25th line
               add $t0, $t0, 128
               sw $t4, 20($t0)
               sw $t4, 24($t0)
               sw $t4, 28($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               
               # 26th line
               add $t0, $t0, 128
               sw $t4, 16($t0)
               sw $t4, 20($t0)
               sw $t4, 104($t0)
               sw $t4, 108($t0)
               
               # 27th line
               add $t0, $t0, 128
               sw $t4, 12($t0)
               sw $t4, 16($t0)
               sw $t4, 108($t0)
               sw $t4, 112($t0)
               
               # 28th line
               add $t0, $t0, 128
               sw $t4, 12($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               
               # 29th line
               add $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               
               # 30th line
               add $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 120($t0)
               
               # 31st line
               add $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 8($t0)
               sw $t4, 120($t0)
               sw $t4, 124($t0)
               
               # 32nd line
               add $t0, $t0, 128
               sw $t4, 4($t0)
               sw $t4, 124($t0)
               
               # light green
               lw $t0, displayAddress
               lw $t4, bodyColour
               
               # middle box
               addi $t0, $t0, 2984
               add $t5, $zero, $zero
               
               outer1:
               
               beq $t5, 9, stopBox1
                    add $t6, $zero, $zero
                    inner1:
                    beq $t6, 12, stopLine1
                         sw $t4, 0($t0)
                         addi $t0, $t0, 4
                         addi $t6, $t6, 1
                         j inner1
                    stopLine1:
                         addi $t0, $t0, 80
                         addi $t5, $t5, 1
                         j outer1
               stopBox1:
               
               # left box
               lw $t0, displayAddress
               addi, $t0, $t0, 3472
               add $t5, $zero, $zero
               
               outer2:
               
               beq $t5, 5, stopBox2
                    add $t6, $zero, $zero
                    inner2:
                    beq $t6, 6, stopLine2
                         sw $t4, 0($t0)
                         addi $t0, $t0, 4
                         addi $t6, $t6, 1
                         j inner2
                    stopLine2:
                         addi $t0, $t0, 104
                         addi $t5, $t5, 1
                         j outer2
               stopBox2:
               
               # right box
               lw $t0, displayAddress
               addi, $t0, $t0, 3544
               add $t5, $zero, $zero
               
               outer3:
               
               beq $t5, 5, stopBox3
                    add $t6, $zero, $zero
                    inner3:
                    beq $t6, 6, stopLine3
                         sw $t4, 0($t0)
                         addi $t0, $t0, 4
                         addi $t6, $t6, 1
                         j inner3
                    stopLine3:
                         addi $t0, $t0, 104
                         addi, $t5, $t5, 1
                         j outer3
               stopBox3:
               
               # add more details
               lw $t0, displayAddress
               lw $t4, bodyColour
               addi $t0, $t0, 3072
               sw $t4, 32($t0)
               sw $t4, 36($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               
               addi $t0, $t0, 128
               sw $t4, 24($t0)
               sw $t4, 28($t0)
               sw $t4, 32($t0)
               sw $t4, 36($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               
               addi $t0, $t0, 128
               sw $t4, 20($t0)
               sw $t4, 24($t0)
               sw $t4, 28($t0)
               sw $t4, 32($t0)
               sw $t4, 36($t0)
               sw $t4, 88($t0)
               sw $t4, 92($t0)
               sw $t4, 96($t0)
               sw $t4, 100($t0)
               sw $t4, 104($t0)
               
               addi $t0, $t0, 256
               sw $t4, 112($t0)
               
               addi $t0, $t0, 128
               sw $t4, 12($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               
               addi $t0, $t0, 128
               sw $t4, 12($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               
               addi $t0, $t0, 128
               sw $t4, 8($t0)
               sw $t4, 12($t0)
               sw $t4, 112($t0)
               sw $t4, 116($t0)
               sw $t4, 120($t0)
               
               lw $t0, displayAddress
               lw $t4, blackColour
               
               addi $t0, $t0, 3328
               sw $t4, 36($t0)
               sw $t4, 64($t0)
               
               addi $t0, $t0, 128
               sw $t4, 36($t0)
               sw $t4, 64($t0)
          
          lw $ra, 0($sp)
               addi $sp, $sp, 4
               jr $ra

jumpSound:
     addi $sp, $sp, -4
     sw $ra, 0($sp)
          
     li $v0, 31
     lb $a0, pitchE
     lb $a1, duration
     lb $a2, instrument
     lb $a3, volume
     syscall

     li $v0, 32
     li $a0, 150
     syscall

     li $v0, 31
     lb $a0, pitchB
     lb $a1, duration
     lb $a2, instrument
     lb $a3, volume
     syscall
        
     li $v0, 32
     li $a0, 150
     syscall
          
     lw $ra, 0($sp)
     addi $sp, $sp, 4
     jr $ra
               
gameOverSound:
     addi $sp, $sp, -4
     sw $ra, 0($sp)
     
     li $v0, 31
        lb $a0, pitchE
        lb $a1, duration
        lb $a2, instrument
        lb $a3, volume
        syscall

        li $v0, 32
        li $a0, 20
        syscall

        li $v0, 31
        lb $a0, sharpD
        lb $a1, duration
        lb $a2, instrument
        lb $a3, volume
        syscall
        
        li $v0, 32
        li $a0, 20
        syscall
        
        li $v0, 31
        lb $a0, pitchD
        lb $a1, duration
        lb $a2, instrument
        lb $a3, volume
        syscall
        
        li $v0, 32
        li $a0, 20
        syscall
        
        li $v0, 31
        lb $a0, sharpC
        lb $a1, duration
        lb $a2, instrument
        lb $a3, volume
        syscall
        
        li $v0, 32
        li $a0, 20
        syscall
        
        li $v0, 31
        lb $a0, pitchC
        lb $a1, duration
        lb $a2, instrument
        lb $a3, volume
        syscall
     
     
     lw $ra, 0($sp)
     addi $sp, $sp, 4
     jr $ra
     
     
displayScore:
     
     addi $sp, $sp, -16
     sw $ra, 0($sp)
     
     lw $t5, displayAddress
     addi $t5, $t5, 132
     
     add $t6, $zero, $zero
     lw, $t4, backgroundColour
     clearLoop:
          beq $t6, 5 stopClearLoop
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 12($t5)
          sw $t4, 16($t5)
          sw $t4, 20($t5)
          sw $t4, 24($t5)
          sw $t4, 28($t5)
          sw $t4, 32($t5)
          sw $t4, 36($t5)
          sw $t4, 40($t5)
          
          addi $t5, $t5, 128
          addi $t6, $t6, 1
          j clearLoop
       
     stopClearLoop: 
     add $s3, $zero, 1000  
     lw $t6, score
     div $t6, $s3
     mfhi $s1
     
     add $s3, $zero, 100
     div $s1, $s3
     mflo $s0
     mfhi $s1
     
     lw $t5, displayAddress
     addi $t5, $t5, 132
     add $a1, $zero, $t5
     add $a2, $zero, $s0
     jal displayDigit
     
     add $s3, $zero, 10
     div $s1, $s3
     mflo $s0
     mfhi $s1
     
     lw $t5, displayAddress
     addi $t5, $t5, 148
     add $a1, $zero, $t5   
     add $a2, $zero, $s0
     jal displayDigit
     
     lw $t5, displayAddress
     addi $t5, $t5, 164
     add $a1, $zero, $t5
     add $a2, $zero, $s1
     jal displayDigit
     
     lw $ra, 0($sp)
     addi $sp, $sp, 4
     jr $ra
     
displayDigit:
     addi $sp, $sp, -4
     sw $ra, 0($sp)
     
     add $t5, $zero, $a1
     lw $t4, blackColour
     
     beq $a2, 0, equals0
     beq $a2, 1, equals1
     beq $a2, 2, equals2
     beq $a2, 3, equals3
     beq $a2, 4, equals4
     beq $a2, 5, equals5
     beq $a2, 6, equals6
     beq $a2, 7, equals7
     beq $a2, 8, equals8
     beq $a2, 9, equals9
     
     equals0:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 128($t5)
          sw $t4, 136($t5)
          sw $t4, 256($t5)
          sw $t4, 264($t5)
          sw $t4, 384($t5)
          sw $t4, 392($t5)
          sw $t4, 512($t5)
          sw $t4, 516($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
     
     equals1:
          sw $t4, 8($t5)
          sw $t4, 136($t5)
          sw $t4, 264($t5)
          sw $t4, 392($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
          
     equals2:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 136($t5)
          sw $t4, 256($t5)
          sw $t4, 260($t5)
          sw $t4, 264($t5)
          sw $t4, 384($t5)
          sw $t4, 512($t5)
          sw $t4, 516($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
          
     equals3:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 136($t5)
          sw $t4, 256($t5)
          sw $t4, 260($t5)
          sw $t4, 264($t5)
          sw $t4, 392($t5)
          sw $t4, 512($t5)
          sw $t4, 516($t5)
          sw $t4, 520($t5)
          j outDisplayDigit   
          
     equals4:
          sw $t4, 0($t5)
          sw $t4, 8($t5)
          sw $t4, 128($t5)
          sw $t4, 136($t5)
          sw $t4, 256($t5)
          sw $t4, 260($t5)
          sw $t4, 264($t5)
          sw $t4, 392($t5)
          sw $t4, 520($t5)
          j outDisplayDigit  
          
     equals5:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 128($t5)
          sw $t4, 256($t5)
          sw $t4, 260($t5)
          sw $t4, 264($t5)
          sw $t4, 392($t5)
          sw $t4, 512($t5)
          sw $t4, 516($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
          
     equals6:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 128($t5)
          sw $t4, 256($t5)
          sw $t4, 260($t5)
          sw $t4, 264($t5)
          sw $t4, 384($t5)
          sw $t4, 392($t5)
          sw $t4, 512($t5)
          sw $t4, 516($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
          
     equals7:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 136($t5)
          sw $t4, 264($t5)
          sw $t4, 392($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
          
     equals8:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 128($t5)
          sw $t4, 136($t5)
          sw $t4, 256($t5)
          sw $t4, 260($t5)
          sw $t4, 264($t5)
          sw $t4, 384($t5)
          sw $t4, 392($t5)
          sw $t4, 512($t5)
          sw $t4, 516($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
          
     equals9:
          sw $t4, 0($t5)
          sw $t4, 4($t5)
          sw $t4, 8($t5)
          sw $t4, 128($t5)
          sw $t4, 136($t5)
          sw $t4, 256($t5)
          sw $t4, 260($t5)
          sw $t4, 264($t5)
          sw $t4, 392($t5)
          sw $t4, 512($t5)
          sw $t4, 516($t5)
          sw $t4, 520($t5)
          j outDisplayDigit
          
     outDisplayDigit:
          lw $ra, 0($sp)
          addi $sp, $sp, 4
          jr $ra
          
          
drawAwesome:

     addi $sp, $sp, -4
     sw $ra, 0($sp)


          # awesome
          lw $t0, displayAddress
          lw $t4, blackColour
          
          # 6th line
          addi $t0, $t0, 1280
          sw $t4, 8($t0)
          sw $t4, 20($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 48($t0)
          sw $t4, 52($t0)
          sw $t4, 64($t0)
          sw $t4, 80($t0)
          sw $t4, 96($t0)
          sw $t4, 104($t0)
          sw $t4, 116($t0)
          sw $t4, 120($t0)
          
          # 7th line
          addi $t0, $t0, 128
          sw $t4, 4($t0)
          sw $t4, 12($t0)
          sw $t4, 20($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 60($t0)
          sw $t4, 68($t0)
          sw $t4, 76($t0)
          sw $t4, 84($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          sw $t4, 116($t0)
          
          # 8th line
          addi $t0, $t0, 128
          sw $t4, 4($t0)
          sw $t4, 12($t0)
          sw $t4, 20($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 48($t0)
          sw $t4, 60($t0)
          sw $t4, 76($t0)
          sw $t4, 84($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          sw $t4, 116($t0)
          sw $t4, 120($t0)
          
          # 9th line
          addi $t0, $t0, 128
          sw $t4, 4($t0)
          sw $t4, 8($t0)
          sw $t4, 12($t0)
          sw $t4, 20($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 64($t0)
          sw $t4, 76($t0)
          sw $t4, 84($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          sw $t4, 116($t0)
          
          # 10th line
          addi $t0, $t0, 128
          sw $t4, 4($t0)
          sw $t4, 12($t0)
          sw $t4, 20($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 60($t0)
          sw $t4, 68($t0)
          sw $t4, 76($t0)
          sw $t4, 84($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          sw $t4, 116($t0)
          
          # 11th line
          addi $t0, $t0, 128
          sw $t4, 4($t0)
          sw $t4, 12($t0)
          sw $t4, 24($t0)
          sw $t4, 32($t0)
          sw $t4, 44($t0)
          sw $t4, 48($t0)
          sw $t4, 52($t0)
          sw $t4, 64($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          sw $t4, 116($t0)
          sw $t4, 120($t0)
          
          # 16th line
          addi $t0, $t0, 640
          sw $t4, 16($t0)
          sw $t4, 40($t0)
          sw $t4, 52($t0)
          sw $t4, 72($t0)
          sw $t4, 84($t0)
          
          # 17th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 20($t0)
          sw $t4, 36($t0)
          sw $t4, 88($t0)
          sw $t4, 100($t0)
          
          # 18th line
          addi $t0, $t0, 128
          sw $t4, 16($t0)
          sw $t4, 24($t0)
          sw $t4, 36($t0)
          sw $t4, 56($t0)
          sw $t4, 60($t0)
          sw $t4, 64($t0)
          sw $t4, 68($t0)
          sw $t4, 88($t0)
          sw $t4, 96($t0)
          sw $t4, 104($t0)
          
          # 19th line
          addi $t0, $t0, 128
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 56($t0)
          sw $t4, 68($t0)
          sw $t4, 88($t0)
          sw $t4, 100($t0)
          sw $t4, 104($t0)
          
          # 20th line
          addi $t0, $t0, 128
          sw $t4, 40($t0)
          sw $t4, 60($t0)
          sw $t4, 64($t0)
          sw $t4, 84($t0)
          sw $t4, 104($t0)
          
          # 21st line
          addi $t0, $t0, 128
          sw $t4, 100($t0)
          
          li $v0, 32
          li $a0, 1000
          syscall
          
          lw $ra, 0($sp)
          addi $sp, $sp, 4
          jr $ra
          
drawWow:

     addi $sp, $sp, -4
     sw $ra, 0($sp)

          # wow
          lw $t0, displayAddress
          lw $t4, blackColour
          
          # 11th line
          addi $t0, $t0, 1280
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 44($t0)
          sw $t4, 60($t0)
          sw $t4, 64($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          
          # 12th line
          addi $t0, $t0, 128
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 44($t0)
          sw $t4, 56($t0)
          sw $t4, 68($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          
          # 13th line
          addi $t0, $t0, 128
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 44($t0)
          sw $t4, 56($t0)
          sw $t4, 68($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          
          # 14th line
          addi $t0, $t0, 128
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 44($t0)
          sw $t4, 56($t0)
          sw $t4, 68($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          
          # 15th line
          addi $t0, $t0, 128
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 44($t0)
          sw $t4, 56($t0)
          sw $t4, 68($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          
          # 16th line
          addi $t0, $t0, 128
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 44($t0)
          sw $t4, 56($t0)
          sw $t4, 68($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          
          # 17th line
          addi $t0, $t0, 128
          sw $t4, 24($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 40($t0)
          sw $t4, 60($t0)
          sw $t4, 64($t0)
          sw $t4, 84($t0)
          sw $t4, 88($t0)
          sw $t4, 96($t0)
          sw $t4, 100($t0)
          
          # 23rd line
          addi $t0, $t0, 768
          sw $t4, 16($t0)
          sw $t4, 36($t0)
          sw $t4, 100($t0)
          sw $t4, 120($t0)
          
          # 24th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 32($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          sw $t4, 116($t0)
          sw $t4, 120($t0)
          
          # 25th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 32($t0)
          sw $t4, 48($t0)
          sw $t4, 60($t0)
          sw $t4, 68($t0)
          sw $t4, 76($t0)
          sw $t4, 88($t0)
          sw $t4, 104($t0)
          sw $t4, 116($t0)
          
          # 26th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 28($t0)
          sw $t4, 32($t0)
          sw $t4, 52($t0)
          sw $t4, 60($t0)
          sw $t4, 68($t0)
          sw $t4, 76($t0)
          sw $t4, 84($t0)
          sw $t4, 104($t0)
          sw $t4, 112($t0)
          sw $t4, 116($t0)
          
          # 27th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 28($t0)
          sw $t4, 48($t0)
          sw $t4, 64($t0)
          sw $t4, 72($t0)
          sw $t4, 88($t0)
          sw $t4, 104($t0)
          sw $t4, 112($t0)
          
          # 28th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 28($t0)
          sw $t4, 44($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          sw $t4, 112($t0)
          
          # 29th line
          addi $t0, $t0, 128
          sw $t4, 16($t0)
          sw $t4, 24($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          
          
          li $v0, 32
          li $a0, 1000
          syscall
          
          lw $ra, 0($sp)
          addi $sp, $sp, 4
          jr $ra
          
drawPoggers:

     addi $sp, $sp, -4
     sw $ra, 0($sp)
     
     # poggers
          lw $t0, displayAddress
          lw $t4, blackColour
          
          # 11th line
          addi $t0, $t0, 1280
          sw $t4, 12($t0)
          sw $t4, 16($t0)
          sw $t4, 32($t0)
          sw $t4, 48($t0)
          sw $t4, 64($t0)
          sw $t4, 76($t0)
          sw $t4, 80($t0)
          sw $t4, 84($t0)
          sw $t4, 92($t0)
          sw $t4, 96($t0)
          sw $t4, 112($t0)
          
          # 12th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 20($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 52($t0)
          sw $t4, 60($t0)
          sw $t4, 68($t0)
          sw $t4, 76($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          sw $t4, 116($t0)
          
          # 13th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 20($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 60($t0)
          sw $t4, 76($t0)
          sw $t4, 80($t0)
          sw $t4, 92($t0)
          sw $t4, 96($t0)
          sw $t4, 108($t0)
          
          # 14th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 16($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 48($t0)
          sw $t4, 52($t0)
          sw $t4, 60($t0)
          sw $t4, 64($t0)
          sw $t4, 68($t0)
          sw $t4, 76($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 112($t0)
          
          # 15th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 28($t0)
          sw $t4, 36($t0)
          sw $t4, 44($t0)
          sw $t4, 52($t0)
          sw $t4, 60($t0)
          sw $t4, 68($t0)
          sw $t4, 76($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 108($t0)
          sw $t4, 116($t0)
          
          # 16th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 32($t0)
          sw $t4, 48($t0)
          sw $t4, 64($t0)
          sw $t4, 76($t0)
          sw $t4, 80($t0)
          sw $t4, 84($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 112($t0)
          
          # 23rd line
          addi $t0, $t0, 768
          sw $t4, 8($t0)
          sw $t4, 12($t0)
          sw $t4, 16($t0)
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 48($t0)
          sw $t4, 72($t0)
          sw $t4, 92($t0)
          sw $t4, 100($t0)
          sw $t4, 120($t0)
          
          # 24th line
          addi $t0, $t0, 128
          sw $t4, 8($t0)
          sw $t4, 28($t0)
          sw $t4, 44($t0)
          sw $t4, 76($t0)
          sw $t4, 88($t0)
          sw $t4, 92($t0)
          sw $t4, 104($t0)
          sw $t4, 116($t0)
          sw $t4, 120($t0)
          
          # 25th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 28($t0)
          sw $t4, 56($t0)
          sw $t4, 60($t0)
          sw $t4, 64($t0)
          sw $t4, 88($t0)
          sw $t4, 104($t0)
          sw $t4, 116($t0)
          
          # 26th line
          addi $t0, $t0, 128
          sw $t4, 16($t0)
          sw $t4, 28($t0)
          sw $t4, 56($t0)
          sw $t4, 64($t0)
          sw $t4, 84($t0)
          sw $t4, 88($t0)
          sw $t4, 104($t0)
          sw $t4, 112($t0)
          sw $t4, 116($t0)
          
          # 27th line
          addi $t0, $t0, 128
          sw $t4, 12($t0)
          sw $t4, 28($t0)
          sw $t4, 56($t0)
          sw $t4, 64($t0)
          sw $t4, 80($t0)
          sw $t4, 84($t0)
          sw $t4, 104($t0)
          sw $t4, 112($t0)
          
          # 28th line
          addi $t0, $t0, 128
          sw $t4, 8($t0)
          sw $t4, 28($t0)
          sw $t4, 48($t0)
          sw $t4, 52($t0)
          sw $t4, 56($t0)
          sw $t4, 60($t0)
          sw $t4, 64($t0)
          sw $t4, 68($t0)
          sw $t4, 80($t0)
          sw $t4, 104($t0)
          sw $t4, 112($t0)
          
          # 29th line
          addi $t0, $t0, 128
          sw $t4, 8($t0)
          sw $t4, 12($t0)
          sw $t4, 16($t0)
          sw $t4, 20($t0)
          sw $t4, 32($t0)
          sw $t4, 48($t0)
          sw $t4, 68($t0)
          sw $t4, 100($t0)
          
          
          li $v0, 32
          li $a0, 1000
          syscall
          
          lw $ra, 0($sp)
          addi $sp, $sp, 4
          jr $ra
