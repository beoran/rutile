
=begin
CPU Memory and Register Transfers

Register to Register Transfer

  A8        nz----  2   TAY         Transfer Accumulator to Y    Y=A
  AA        nz----  2   TAX         Transfer Accumulator to X    X=A
  BA        nz----  2   TSX         Transfer Stack pointer to X  X=S
  98        nz----  2   TYA         Transfer Y to Accumulator    A=Y
  8A        nz----  2   TXA         Transfer X to Accumulator    A=X
  9A        ------  2   TXS         Transfer X to Stack pointer  S=X

Nocash syntax: MOV dest,source (eg. MOV Y,A = TAY).

Load Register from Memory

  A9 nn     nz----  2   LDA #nn     Load A with Immediate     A=nn
  A5 nn     nz----  3   LDA nn      Load A with Zero Page     A=[nn]
  B5 nn     nz----  4   LDA nn,X    Load A with Zero Page,X   A=[nn+X]
  AD nn nn  nz----  4   LDA nnnn    Load A with Absolute      A=[nnnn]
  BD nn nn  nz----  4*  LDA nnnn,X  Load A with Absolute,X    A=[nnnn+X]
  B9 nn nn  nz----  4*  LDA nnnn,Y  Load A with Absolute,Y    A=[nnnn+Y]
  A1 nn     nz----  6   LDA (nn,X)  Load A with (Indirect,X)  A=[WORD[nn+X]]
  B1 nn     nz----  5*  LDA (nn),Y  Load A with (Indirect),Y  A=[WORD[nn]+Y]
  A2 nn     nz----  2   LDX #nn     Load X with Immediate     X=nn
  A6 nn     nz----  3   LDX nn      Load X with Zero Page     X=[nn]
  B6 nn     nz----  4   LDX nn,Y    Load X with Zero Page,Y   X=[nn+Y]
  AE nn nn  nz----  4   LDX nnnn    Load X with Absolute      X=[nnnn]
  BE nn nn  nz----  4*  LDX nnnn,Y  Load X with Absolute,Y    X=[nnnn+Y]
  A0 nn     nz----  2   LDY #nn     Load Y with Immediate     Y=nn
  A4 nn     nz----  3   LDY nn      Load Y with Zero Page     Y=[nn]
  B4 nn     nz----  4   LDY nn,X    Load Y with Zero Page,X   Y=[nn+X]
  AC nn nn  nz----  4   LDY nnnn    Load Y with Absolute      Y=[nnnn]
  BC nn nn  nz----  4*  LDY nnnn,X  Load Y with Absolute,X    Y=[nnnn+X]

* Add one cycle if indexing crosses a page boundary.
Nocash syntax: MOV reg,op (MOV Y,12h; MOV X,[12h+Y]; MOV A,[[NN]+Y]; etc.)

Store Register in Memory

  85 nn     ------  3   STA nn      Store A in Zero Page     [nn]=A
  95 nn     ------  4   STA nn,X    Store A in Zero Page,X   [nn+X]=A
  8D nn nn  ------  4   STA nnnn    Store A in Absolute      [nnnn]=A
  9D nn nn  ------  5   STA nnnn,X  Store A in Absolute,X    [nnnn+X]=A
  99 nn nn  ------  5   STA nnnn,Y  Store A in Absolute,Y    [nnnn+Y]=A
  81 nn     ------  6   STA (nn,X)  Store A in (Indirect,X)  [[nn+x]]=A
  91 nn     ------  6   STA (nn),Y  Store A in (Indirect),Y  [[nn]+y]=A
  86 nn     ------  3   STX nn      Store X in Zero Page     [nn]=X
  96 nn     ------  4   STX nn,Y    Store X in Zero Page,Y   [nn+Y]=X
  8E nn nn  ------  4   STX nnnn    Store X in Absolute      [nnnn]=X
  84 nn     ------  3   STY nn      Store Y in Zero Page     [nn]=Y
  94 nn     ------  4   STY nn,X    Store Y in Zero Page,X   [nn+X]=Y
  8C nn nn  ------  4   STY nnnn    Store Y in Absolute      [nnnn]=Y

Nocash syntax: MOV op,reg (MOV [12h],A; MOV [12h+Y],X; MOV [[NN]+Y],A; etc.)

Push/Pull

  48        ------  3   PHA         Push accumulator on stack        [S]=A
  08        ------  3   PHP         Push processor status on stack   [S]=P
  68        nz----  4   PLA         Pull accumulator from stack      A=[S]
  28        nzcidv  4   PLP         Pull processor status from stack P=[S]

Notes: PLA sets Z and N according to content of A. The B-flag and unused flags cannot be changed by PLP, these flags are always written as "1" by PHP.
Nocash syntax: PUSH A; PUSH P; POP A; POP P.


 CPU Arithmetic/Logical Operations

Add memory to accumulator with carry

  69 nn     nzc--v  2   ADC #nn     Add Immediate           A=A+C+nn
  65 nn     nzc--v  3   ADC nn      Add Zero Page           A=A+C+[nn]
  75 nn     nzc--v  4   ADC nn,X    Add Zero Page,X         A=A+C+[nn+X]
  6D nn nn  nzc--v  4   ADC nnnn    Add Absolute            A=A+C+[nnnn]
  7D nn nn  nzc--v  4*  ADC nnnn,X  Add Absolute,X          A=A+C+[nnnn+X]
  79 nn nn  nzc--v  4*  ADC nnnn,Y  Add Absolute,Y          A=A+C+[nnnn+Y]
  61 nn     nzc--v  6   ADC (nn,X)  Add (Indirect,X)        A=A+C+[[nn+X]]
  71 nn     nzc--v  5*  ADC (nn),Y  Add (Indirect),Y        A=A+C+[[nn]+Y]

* Add one cycle if indexing crosses a page boundary.
Nocash syntax: ADC A,op (ADC A,12h; ADC A,[12h+X]; ADC A,[[NN]+Y]; etc.)

Subtract memory from accumulator with borrow

  E9 nn     nzc--v  2   SBC #nn     Subtract Immediate      A=A+C-1-nn
  E5 nn     nzc--v  3   SBC nn      Subtract Zero Page      A=A+C-1-[nn]
  F5 nn     nzc--v  4   SBC nn,X    Subtract Zero Page,X    A=A+C-1-[nn+X]
  ED nn nn  nzc--v  4   SBC nnnn    Subtract Absolute       A=A+C-1-[nnnn]
  FD nn nn  nzc--v  4*  SBC nnnn,X  Subtract Absolute,X     A=A+C-1-[nnnn+X]
  F9 nn nn  nzc--v  4*  SBC nnnn,Y  Subtract Absolute,Y     A=A+C-1-[nnnn+Y]
  E1 nn     nzc--v  6   SBC (nn,X)  Subtract (Indirect,X)   A=A+C-1-[[nn+X]]
  F1 nn     nzc--v  5*  SBC (nn),Y  Subtract (Indirect),Y   A=A+C-1-[[nn]+Y]

* Add one cycle if indexing crosses a page boundary.
Nocash syntax: SBC A,op (SBC A,12h; SBC A,[12h+X]; SBC A,[[NN]+Y]; etc.)
Note: Compared with normal 80x86 and Z80 CPUs, incoming and resulting Carry Flag are reversed.

Logical AND memory with accumulator

  29 nn     nz----  2   AND #nn     AND Immediate      A=A AND nn
  25 nn     nz----  3   AND nn      AND Zero Page      A=A AND [nn]
  35 nn     nz----  4   AND nn,X    AND Zero Page,X    A=A AND [nn+X]
  2D nn nn  nz----  4   AND nnnn    AND Absolute       A=A AND [nnnn]
  3D nn nn  nz----  4*  AND nnnn,X  AND Absolute,X     A=A AND [nnnn+X]
  39 nn nn  nz----  4*  AND nnnn,Y  AND Absolute,Y     A=A AND [nnnn+Y]
  21 nn     nz----  6   AND (nn,X)  AND (Indirect,X)   A=A AND [[nn+X]]
  31 nn     nz----  5*  AND (nn),Y  AND (Indirect),Y   A=A AND [[nn]+Y]

Nocash syntax: AND A,op (AND A,12h; AND A,[12h+X]; AND A,[[NN]+Y]; etc.)
* Add one cycle if indexing crosses a page boundary.

Exclusive-OR memory with accumulator

  49 nn     nz----  2   EOR #nn     XOR Immediate      A=A XOR nn
  45 nn     nz----  3   EOR nn      XOR Zero Page      A=A XOR [nn]
  55 nn     nz----  4   EOR nn,X    XOR Zero Page,X    A=A XOR [nn+X]
  4D nn nn  nz----  4   EOR nnnn    XOR Absolute       A=A XOR [nnnn]
  5D nn nn  nz----  4*  EOR nnnn,X  XOR Absolute,X     A=A XOR [nnnn+X]
  59 nn nn  nz----  4*  EOR nnnn,Y  XOR Absolute,Y     A=A XOR [nnnn+Y]
  41 nn     nz----  6   EOR (nn,X)  XOR (Indirect,X)   A=A XOR [[nn+X]]
  51 nn     nz----  5*  EOR (nn),Y  XOR (Indirect),Y   A=A XOR [[nn]+Y]

Nocash syntax: XOR A,op (XOR A,12h; XOR A,[12h+X]; XOR A,[[NN]+Y]; etc.)
* Add one cycle if indexing crosses a page boundary.

Logical OR memory with accumulator

  09 nn     nz----  2   ORA #nn     OR Immediate       A=A OR nn
  05 nn     nz----  3   ORA nn      OR Zero Page       A=A OR [nn]
  15 nn     nz----  4   ORA nn,X    OR Zero Page,X     A=A OR [nn+X]
  0D nn nn  nz----  4   ORA nnnn    OR Absolute        A=A OR [nnnn]
  1D nn nn  nz----  4*  ORA nnnn,X  OR Absolute,X      A=A OR [nnnn+X]
  19 nn nn  nz----  4*  ORA nnnn,Y  OR Absolute,Y      A=A OR [nnnn+Y]
  01 nn     nz----  6   ORA (nn,X)  OR (Indirect,X)    A=A OR [[nn+X]]
  11 nn     nz----  5*  ORA (nn),Y  OR (Indirect),Y    A=A OR [[nn]+Y]

Nocash syntax: OR A,op (OR A,12h; OR A,[12h+X]; OR A,[[NN]+Y]; etc.)
* Add one cycle if indexing crosses a page boundary.

Compare

  C9 nn     nzc---  2   CMP #nn     Compare A with Immediate     A-nn
  C5 nn     nzc---  3   CMP nn      Compare A with Zero Page     A-[nn]
  D5 nn     nzc---  4   CMP nn,X    Compare A with Zero Page,X   A-[nn+X]
  CD nn nn  nzc---  4   CMP nnnn    Compare A with Absolute      A-[nnnn]
  DD nn nn  nzc---  4*  CMP nnnn,X  Compare A with Absolute,X    A-[nnnn+X]
  D9 nn nn  nzc---  4*  CMP nnnn,Y  Compare A with Absolute,Y    A-[nnnn+Y]
  C1 nn     nzc---  6   CMP (nn,X)  Compare A with (Indirect,X)  A-[[nn+X]]
  D1 nn     nzc---  5*  CMP (nn),Y  Compare A with (Indirect),Y  A-[[nn]+Y]
  E0 nn     nzc---  2   CPX #nn     Compare X with Immediate     X-nn
  E4 nn     nzc---  3   CPX nn      Compare X with Zero Page     X-[nn]
  EC nn nn  nzc---  4   CPX nnnn    Compare X with Absolute      X-[nnnn]
  C0 nn     nzc---  2   CPY #nn     Compare Y with Immediate     Y-nn
  C4 nn     nzc---  3   CPY nn      Compare Y with Zero Page     Y-[nn]
  CC nn nn  nzc---  4   CPY nnnn    Compare Y with Absolute      Y-[nnnn]

* Add one cycle if indexing crosses a page boundary.
Nocash syntax: CMP reg,op (CMP X,12h; CMP A,[12h+X]; CMP A,[[NN]+Y]; etc.)
Note: Compared with normal 80x86 and Z80 CPUs, resulting Carry Flag is reversed.

Bit Test

  24 nn     xz---x  3   BIT nn      Bit Test   A AND [nn], N=[nn].7, V=[nn].6
  2C nn nn  xz---x  4   BIT nnnn    Bit Test   A AND [..], N=[..].7, V=[..].6

Nocash syntax: TEST A,op (TEST A,[12h]; TEST A,[1234h]; etc.)

Increment by one

  E6 nn     nz----  5   INC nn      Increment Zero Page    [nn]=[nn]+1
  F6 nn     nz----  6   INC nn,X    Increment Zero Page,X  [nn+X]=[nn+X]+1
  EE nn nn  nz----  6   INC nnnn    Increment Absolute     [nnnn]=[nnnn]+1
  FE nn nn  nz----  7   INC nnnn,X  Increment Absolute,X   [nnnn+X]=[nnnn+X]+1
  E8        nz----  2   INX         Increment X            X=X+1
  C8        nz----  2   INY         Increment Y            Y=Y+1

Nocash syntax: INC op/reg (INC [12h]; INC [1234h+X]; INC Y; etc.)

Decrement by one

  C6 nn     nz----  5   DEC nn      Decrement Zero Page    [nn]=[nn]-1
  D6 nn     nz----  6   DEC nn,X    Decrement Zero Page,X  [nn+X]=[nn+X]-1
  CE nn nn  nz----  6   DEC nnnn    Decrement Absolute     [nnnn]=[nnnn]-1
  DE nn nn  nz----  7   DEC nnnn,X  Decrement Absolute,X   [nnnn+X]=[nnnn+X]-1
  CA        nz----  2   DEX         Decrement X            X=X-1
  88        nz----  2   DEY         Decrement Y            Y=Y-1

Nocash syntax: DEC op/reg (DEC [12h]; DEC [1234h+X]; DEC Y; etc.)


 CPU Rotate and Shift Instructions

Shift Left

  0A        nzc---  2   ASL A       Shift Left Accumulator   SHL A
  06 nn     nzc---  5   ASL nn      Shift Left Zero Page     SHL [nn]
  16 nn     nzc---  6   ASL nn,X    Shift Left Zero Page,X   SHL [nn+X]
  0E nn nn  nzc---  6   ASL nnnn    Shift Left Absolute      SHL [nnnn]
  1E nn nn  nzc---  7   ASL nnnn,X  Shift Left Absolute,X    SHL [nnnn+X]

Nocash syntax: SHL op/reg (SHL A; SHL [12h]; SHL [1234h+X]; etc.)

Shift Right

  4A        0zc---  2   LSR A       Shift Right Accumulator  SHR A
  46 nn     0zc---  5   LSR nn      Shift Right Zero Page    SHR [nn]
  56 nn     0zc---  6   LSR nn,X    Shift Right Zero Page,X  SHR [nn+X]
  4E nn nn  0zc---  6   LSR nnnn    Shift Right Absolute     SHR [nnnn]
  5E nn nn  0zc---  7   LSR nnnn,X  Shift Right Absolute,X   SHR [nnnn+X]

Nocash syntax: SHR op/reg (SHR A; SHR [12h]; SHR [1234h+X]; etc.)

Rotate Left through Carry

  2A        nzc---  2   ROL A       Rotate Left Accumulator  RCL A
  26 nn     nzc---  5   ROL nn      Rotate Left Zero Page    RCL [nn]
  36 nn     nzc---  6   ROL nn,X    Rotate Left Zero Page,X  RCL [nn+X]
  2E nn nn  nzc---  6   ROL nnnn    Rotate Left Absolute     RCL [nnnn]
  3E nn nn  nzc---  7   ROL nnnn,X  Rotate Left Absolute,X   RCL [nnnn+X]

Nocash syntax: RCL op/reg (RCL A; RCL [12h]; RCL [1234h+X]; etc.)

Rotate Right through Carry

  6A        nzc---  2   ROR A       Rotate Right Accumulator RCR A
  66 nn     nzc---  5   ROR nn      Rotate Right Zero Page   RCR [nn]
  76 nn     nzc---  6   ROR nn,X    Rotate Right Zero Page,X RCR [nn+X]
  6E nn nn  nzc---  6   ROR nnnn    Rotate Right Absolute    RCR [nnnn]
  7E nn nn  nzc---  7   ROR nnnn,X  Rotate Right Absolute,X  RCR [nnnn+X]

Nocash syntax: RCR op/reg (RCR A; RCR [12h]; RCR [1234h+X]; etc.)

Notes:
ROR instruction is available on MCS650X microprocessors after June, 1976.
ROL and ROL rotate an 8bit value through carry (rotates 9bits in total).


 CPU Jump and Control Instructions

Normal Jumps

  4C nn nn  ------  3   JMP nnnn    Jump Absolute              PC=nnnn
  6C nn nn  ------  5   JMP (nnnn)  Jump Indirect              PC=WORD[nnnn]
  20 nn nn  ------  6   JSR nnnn    Jump and Save Return Addr. [S]=PC+2,PC=nnnn
  40        nzcidv  6   RTI         Return from BRK/IRQ/NMI    P=[S], PC=[S]
  60        ------  6   RTS         Return from Subroutine     PC=[S]+1

Nocash syntax: JMP nnnn; JMP [nnnn]; CALL nnnn (=JSR); RETI; RET (=RTS).
Note: RTI cannot modify the B-Flag or the unused flag.
Glitch: For JMP [nnnn] the operand word cannot cross page boundaries, ie. JMP [03FFh] would fetch the MSB from [0300h] instead of [0400h]. Very simple workaround would be to place a ALIGN 2 before the data word.

Conditional Branches (Branch on condition, to PC=PC+/-nn)

  10 dd     ------  2** BPL/JNS disp          ;N=0 (plus/positive)
  30 dd     ------  2** BMI/JS  disp          ;N=1 (minus/negative/signed)
  50 dd     ------  2** BVC/JNO disp          ;V=0 (no overflow)
  70 dd     ------  2** BVS/JO  disp          ;V=1 (overflow)
  90 dd     ------  2** BCC/BLT/JNC/JB  disp  ;C=0 (less/below/no carry)
  B0 dd     ------  2** BCS/BGE/JC/JAE  disp  ;C=1 (above/greater/equal/carry)
  D0 dd     ------  2** BNE/BZC/JNZ/JNE disp  ;Z=0 (not zero/not equal)
  F0 dd     ------  2** BEQ/BZS/JZ/JE   disp  ;Z=1 (zero/equal)

Nocash syntax: Jxx nnnn; Native syntax: Bxx nnnn.
** The execution time is 2 cycles if the condition is false (no branch executed). Otherwise, 3 cycles if the destination is in the same memory page, or 4 cycles if it crosses a page boundary (see below for exact info).
Note: After subtractions (SBC or CMP) carry=set indicates above-or-equal, unlike as for 80x86 and Z80 CPUs.

Interrupts, Exceptions, Breakpoints

  00        ---1--  7   BRK   Force Break B=1 [S]=PC+1,[S]=P,I=1,PC=[FFFE]
  --        ---1--  ??  /IRQ  Interrupt   B=0 [S]=PC,[S]=P,I=1,PC=[FFFE]
  --        ---1--  ??  /NMI  NMI         B=0 [S]=PC,[S]=P,I=1,PC=[FFFA]
  --        ---1--  T+6 /RESET Reset      PC=[FFFC],I=1

Notes: IRQs can be disabled by setting the I-flag, a BRK command, a NMI, and a /RESET signal cannot be masked by setting I.
BRK/IRQ/NMI first change the B-flag, then write P to stack, and then set the I-flag, the D-flag is NOT changed and should be cleared by software.
The same vector is shared for BRK and IRQ, software can separate between BRK and IRQ by examining the pushed B-flag only.
The RTI opcode can be used to return from BRK/IRQ/NMI, note that using the return address from BRK skips one dummy/parameter byte following after the BRK opcode.
Software or hardware must take care to acknowledge or reset /IRQ or /NMI signals after processing it.

  IRQs are executed whenever "/IRQ=LOW AND I=0".
  NMIs are executed whenever "/NMI changes from HIGH to LOW".

If /IRQ is kept LOW then same (old) interrupt is executed again as soon as setting I=0. If /NMI is kept LOW then no further NMIs can be executed.

CPU Control

  18        --0---  2   CLC         Clear carry flag            C=0
  58        ---0--  2   CLI         Clear interrupt disable bit I=0
  D8        ----0-  2   CLD         Clear decimal mode          D=0
  B8        -----0  2   CLV         Clear overflow flag         V=0
  38        --1---  2   SEC         Set carry flag              C=1
  78        ---1--  2   SEI         Set interrupt disable bit   I=1
  F8        ----1-  2   SED         Set decimal mode            D=1

Nocash Syntax: CLC; EI (=CLI); CLD, CLV; STC; DI (=STI); STD.

No Operation

  EA        ------  2   NOP         No operation                No operation
=end
