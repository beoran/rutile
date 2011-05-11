#
# Mos 6507 CPU target.

class Target::M6507 < Target
  operation 0xa8, 1, :TAY, '2', 'Transfer Accumulator to Y Y=A' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xaa, 1, :TAX, '2', 'Transfer Accumulator to X X=A' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xba, 1, :TSX, '2', 'Transfer Stack pointer to X X=S' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x98, 1, :TYA, '2', 'Transfer Y to Accumulator A=Y' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x8a, 1, :TXA, '2', 'Transfer X to Accumulator A=X' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x9a, 1, :TXS, '2', 'Transfer X to Stack pointer S=X' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xa9, 2, :LDA_IMM, '2', 'Load A with Immediate A=nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xa5, 2, :LDA_ZP, '3', 'Load A with Zero Page A=[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xb5, 2, :LDA_ZP_X, '4', 'Load A with Zero Page,X A=[nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xad, 3, :LDA_ABS, '4', 'Load A with Absolute A=[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xbd, 3, :LDA_ABS_X, '4*', 'Load A with Absolute,X A=[nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xb9, 3, :LDA_ABS_Y, '4*', 'Load A with Absolute,Y A=[nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xa1, 2, :LDA_IND_X, '6', 'Load A with (Indirect,X) A=[WORD[nn+X]]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xb1, 2, :LDA_IND_Y, '5*', 'Load A with (Indirect),Y A=[WORD[nn]+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xa2, 2, :LDX_IMM, '2', 'Load X with Immediate X=nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xa6, 2, :LDX_ZP, '3', 'Load X with Zero Page X=[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xb6, 2, :LDX_ZP_Y, '4', 'Load X with Zero Page,Y X=[nn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xae, 3, :LDX_ABS, '4', 'Load X with Absolute X=[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xbe, 3, :LDX_ABS_Y, '4*', 'Load X with Absolute,Y X=[nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xa0, 2, :LDY_IMM, '2', 'Load Y with Immediate Y=nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xa4, 2, :LDY_ZP, '3', 'Load Y with Zero Page Y=[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xb4, 2, :LDY_ZP_X, '4', 'Load Y with Zero Page,X Y=[nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xac, 3, :LDY_ABS, '4', 'Load Y with Absolute Y=[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xbc, 3, :LDY_ABS_X, '4*', 'Load Y with Absolute,X Y=[nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x85, 2, :STA_ZP, '3', 'Store A in Zero Page [nn]=A' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x95, 2, :STA_ZP_X, '4', 'Store A in Zero Page,X [nn+X]=A' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x8d, 3, :STA_ABS, '4', 'Store A in Absolute [nnnn]=A' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x9d, 3, :STA_ABS_X, '5', 'Store A in Absolute,X [nnnn+X]=A' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x99, 3, :STA_ABS_Y, '5', 'Store A in Absolute,Y [nnnn+Y]=A' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x81, 2, :STA_IND_X, '6', 'Store A in (Indirect,X) [[nn+x]]=A' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x91, 2, :STA_IND_Y, '6', 'Store A in (Indirect),Y [[nn]+y]=A' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x86, 2, :STX_ZP, '3', 'Store X in Zero Page [nn]=X' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x96, 2, :STX_ZP_Y, '4', 'Store X in Zero Page,Y [nn+Y]=X' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x8e, 3, :STX_ABS, '4', 'Store X in Absolute [nnnn]=X' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x84, 2, :STY_ZP, '3', 'Store Y in Zero Page [nn]=Y' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x94, 2, :STY_ZP_X, '4', 'Store Y in Zero Page,X [nn+X]=Y' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x8c, 3, :STY_ABS, '4', 'Store Y in Absolute [nnnn]=Y' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x48, 1, :PHA, '3', 'Push accumulator on stack [S]=A' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x8, 1, :PHP, '3', 'Push processor status on stack [S]=P' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x68, 1, :PLA, '4', 'Pull accumulator from stack A=[S]' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x28, 1, :PLP, '4', 'Pull processor status from stack P=[S]' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x69, 2, :ADC_IMM, '2', 'Add Immediate A=A+C+nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x65, 2, :ADC_ZP, '3', 'Add Zero Page A=A+C+[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x75, 2, :ADC_ZP_X, '4', 'Add Zero Page,X A=A+C+[nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x6d, 3, :ADC_ABS, '4', 'Add Absolute A=A+C+[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x7d, 3, :ADC_ABS_X, '4*', 'Add Absolute,X A=A+C+[nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x79, 3, :ADC_ABS_Y, '4*', 'Add Absolute,Y A=A+C+[nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x61, 2, :ADC_IND_X, '6', 'Add (Indirect,X) A=A+C+[[nn+X]]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x71, 2, :ADC_IND_Y, '5*', 'Add (Indirect),Y A=A+C+[[nn]+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xe9, 2, :SBC_IMM, '2', 'Subtract Immediate A=A+C-1-nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xe5, 2, :SBC_ZP, '3', 'Subtract Zero Page A=A+C-1-[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xf5, 2, :SBC_ZP_X, '4', 'Subtract Zero Page,X A=A+C-1-[nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xed, 3, :SBC_ABS, '4', 'Subtract Absolute A=A+C-1-[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xfd, 3, :SBC_ABS_X, '4*', 'Subtract Absolute,X A=A+C-1-[nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xf9, 3, :SBC_ABS_Y, '4*', 'Subtract Absolute,Y A=A+C-1-[nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xe1, 2, :SBC_IND_X, '6', 'Subtract (Indirect,X) A=A+C-1-[[nn+X]]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xf1, 2, :SBC_IND_Y, '5*', 'Subtract (Indirect),Y A=A+C-1-[[nn]+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x29, 2, :AND_IMM, '2', 'AND Immediate A=A AND nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x25, 2, :AND_ZP, '3', 'AND Zero Page A=A AND [nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x35, 2, :AND_ZP_X, '4', 'AND Zero Page,X A=A AND [nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x2d, 3, :AND_ABS, '4', 'AND Absolute A=A AND [nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x3d, 3, :AND_ABS_X, '4*', 'AND Absolute,X A=A AND [nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x39, 3, :AND_ABS_Y, '4*', 'AND Absolute,Y A=A AND [nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x21, 2, :AND_IND_X, '6', 'AND (Indirect,X) A=A AND [[nn+X]]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x31, 2, :AND_IND_Y, '5*', 'AND (Indirect),Y A=A AND [[nn]+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x49, 2, :EOR_IMM, '2', 'XOR Immediate A=A XOR nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x45, 2, :EOR_ZP, '3', 'XOR Zero Page A=A XOR [nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x55, 2, :EOR_ZP_X, '4', 'XOR Zero Page,X A=A XOR [nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x4d, 3, :EOR_ABS, '4', 'XOR Absolute A=A XOR [nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x5d, 3, :EOR_ABS_X, '4*', 'XOR Absolute,X A=A XOR [nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x59, 3, :EOR_ABS_Y, '4*', 'XOR Absolute,Y A=A XOR [nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x41, 2, :EOR_IND_X, '6', 'XOR (Indirect,X) A=A XOR [[nn+X]]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x51, 2, :EOR_IND_Y, '5*', 'XOR (Indirect),Y A=A XOR [[nn]+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x9, 2, :ORA_IMM, '2', 'OR Immediate A=A OR nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x5, 2, :ORA_ZP, '3', 'OR Zero Page A=A OR [nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x15, 2, :ORA_ZP_X, '4', 'OR Zero Page,X A=A OR [nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xd, 3, :ORA_ABS, '4', 'OR Absolute A=A OR [nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x1d, 3, :ORA_ABS_X, '4*', 'OR Absolute,X A=A OR [nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x19, 3, :ORA_ABS_Y, '4*', 'OR Absolute,Y A=A OR [nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x1, 2, :ORA_IND_X, '6', 'OR (Indirect,X) A=A OR [[nn+X]]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x11, 2, :ORA_IND_Y, '5*', 'OR (Indirect),Y A=A OR [[nn]+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xc9, 2, :CMP_IMM, '2', 'Compare A with Immediate A-nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xc5, 2, :CMP_ZP, '3', 'Compare A with Zero Page A-[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xd5, 2, :CMP_ZP_X, '4', 'Compare A with Zero Page,X A-[nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xcd, 3, :CMP_ABS, '4', 'Compare A with Absolute A-[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xdd, 3, :CMP_ABS_X, '4*', 'Compare A with Absolute,X A-[nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xd9, 3, :CMP_ABS_Y, '4*', 'Compare A with Absolute,Y A-[nnnn+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xc1, 2, :CMP_IND_X, '6', 'Compare A with (Indirect,X) A-[[nn+X]]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xd1, 2, :CMP_IND_Y, '5*', 'Compare A with (Indirect),Y A-[[nn]+Y]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xe0, 2, :CPX_IMM, '2', 'Compare X with Immediate X-nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xe4, 2, :CPX_ZP, '3', 'Compare X with Zero Page X-[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xec, 3, :CPX_ABS, '4', 'Compare X with Absolute X-[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xc0, 2, :CPY_IMM, '2', 'Compare Y with Immediate Y-nn' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xc4, 2, :CPY_ZP, '3', 'Compare Y with Zero Page Y-[nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xcc, 3, :CPY_ABS, '4', 'Compare Y with Absolute Y-[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x24, 2, :BIT_ZP, '3', 'Bit Test A AND [nn], N=[nn].7, V=[nn].6' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x2c, 3, :BIT_ABS, '4', 'Bit Test A AND [..], N=[..].7, V=[..].6' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xe6, 2, :INC_ZP, '5', 'Increment Zero Page [nn]=[nn]+1' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xf6, 2, :INC_ZP_X, '6', 'Increment Zero Page,X [nn+X]=[nn+X]+1' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xee, 3, :INC_ABS, '6', 'Increment Absolute [nnnn]=[nnnn]+1' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xfe, 3, :INC_ABS_X, '7', 'Increment Absolute,X [nnnn+X]=[nnnn+X]+1' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xe8, 1, :INX, '2', 'Increment X X=X+1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xc8, 1, :INY, '2', 'Increment Y Y=Y+1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xc6, 2, :DEC_ZP, '5', 'Decrement Zero Page [nn]=[nn]-1' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xd6, 2, :DEC_ZP_X, '6', 'Decrement Zero Page,X [nn+X]=[nn+X]-1' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xce, 3, :DEC_ABS, '6', 'Decrement Absolute [nnnn]=[nnnn]-1' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xde, 3, :DEC_ABS_X, '7', 'Decrement Absolute,X [nnnn+X]=[nnnn+X]-1' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0xca, 1, :DEX, '2', 'Decrement X X=X-1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x88, 1, :DEY, '2', 'Decrement Y Y=Y-1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xa, 1, :ASL, '2', 'Shift Left Accumulator SHL A' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x6, 2, :ASL_ZP, '5', 'Shift Left Zero Page SHL [nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x16, 2, :ASL_ZP_X, '6', 'Shift Left Zero Page,X SHL [nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xe, 3, :ASL_ABS, '6', 'Shift Left Absolute SHL [nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x1e, 3, :ASL_ABS_X, '7', 'Shift Left Absolute,X SHL [nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x4a, 1, :LSR, '2', 'Shift Right Accumulator SHR A' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x46, 2, :LSR_ZP, '5', 'Shift Right Zero Page SHR [nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x56, 2, :LSR_ZP_X, '6', 'Shift Right Zero Page,X SHR [nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x4e, 3, :LSR_ABS, '6', 'Shift Right Absolute SHR [nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x5e, 3, :LSR_ABS_X, '7', 'Shift Right Absolute,X SHR [nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x2a, 1, :ROL, '2', 'Rotate Left Accumulator RCL A' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x26, 2, :ROL_ZP, '5', 'Rotate Left Zero Page RCL [nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x36, 2, :ROL_ZP_X, '6', 'Rotate Left Zero Page,X RCL [nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x2e, 3, :ROL_ABS, '6', 'Rotate Left Absolute RCL [nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x3e, 3, :ROL_ABS_X, '7', 'Rotate Left Absolute,X RCL [nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x6a, 1, :ROR, '2', 'Rotate Right Accumulator RCR A' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x66, 2, :ROR_ZP, '5', 'Rotate Right Zero Page RCR [nn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x76, 2, :ROR_ZP_X, '6', 'Rotate Right Zero Page,X RCR [nn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x6e, 3, :ROR_ABS, '6', 'Rotate Right Absolute RCR [nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x7e, 3, :ROR_ABS_X, '7', 'Rotate Right Absolute,X RCR [nnnn+X]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x4c, 3, :JMP_ABS, '3', 'Jump Absolute PC=nnnn' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x6c, 3, :JMP_IND, '5', 'Jump Indirect PC=WORD[nnnn]' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x20, 3, :JSR_ABS, '6', 'Jump and Save Return Addr. [S]=PC+2,PC=nnnn' do | asm, op, arg |
    asm.byte(op.code)
    asm.short(arg[0])
  end

  operation 0x40, 1, :RTI, '6', 'Return from BRK/IRQ/NMI P=[S], PC=[S]' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x60, 1, :RTS, '6', 'Return from Subroutine PC=[S]+1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x10, 2, :BPL_DISP, '2**', 'Branch On Plus ;N=0 (plus/positive)' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x30, 2, :BMI_DISP, '2**', 'Branch on Minus ;N=1 (minus/signed)' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x50, 2, :BVC_DISP, '2**', 'Branch on oVerflow Clear ;V=0 (no overflow)' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x70, 2, :BVS_DISP, '2**', 'Branch on oVerflow Set ;V=1' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x90, 2, :BCC_DISP, '2**', 'Branch on Carry Clear ;C=0' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xb0, 2, :BCS_DISP, '2**', 'Branch on Carry Set ;C=1' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xd0, 2, :BNE_DISP, '2**', 'Branch on Not Equal ;Z=0' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0xf0, 2, :BEQ_DISP, '2**', 'Branch on Equal ;Z=1 (zero/equal)' do | asm, op, arg |
    asm.byte(op.code)
    asm.byte(arg[0])
  end

  operation 0x0, 1, :BRK, '7', 'Force Break B=1 [S]=PC+1,[S]=P,I=1,PC=[FFFE]' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x18, 1, :CLC, '2', 'Clear carry flag C=0' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x58, 1, :CLI, '2', 'Clear interrupt disable bit I=0' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xd8, 1, :CLD, '2', 'Clear decimal mode D=0' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xb8, 1, :CLV, '2', 'Clear overflow flag V=0' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x38, 1, :SEC, '2', 'Set carry flag C=1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0x78, 1, :SEI, '2', 'Set interrupt disable bit I=1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xf8, 1, :SED, '2', 'Set decimal mode D=1' do | asm, op, arg |
    asm.byte(op.code)
  end

  operation 0xea, 1, :NOP, '2', 'No operation No operation' do | asm, op, arg |
    asm.byte(op.code)
  end

end

