package lc3

import "mem"
import "inst"
import "util"
import "core:fmt"

LC3 :: struct {
    memory : mem.Memory,
    registers : [8]Register,
    pc : uint,
    haltFinished : bool,
    flags : Flag
}

Register :: struct
{
    value : int
}

Flag :: struct
{
    zero : bool,
    pos : bool,
    neg : bool
}

setRegisterValue :: proc (comp : ^LC3, index,value:int) -> bool
{
    if index < 0 || index >= len(comp.registers)
    {
        return false;
    }

    comp.registers[index].value = value;
    return true;
}

getRegisterValue :: proc (comp : ^LC3, index:int) -> int
{
    if index < 0 || index >= len(comp.registers)
    {
        return -1;
    }

    return comp.registers[index].value;
}

setConditionCode :: proc (comp : ^LC3, val: int) 
{
    if val == 0
    {
        comp.flags.neg = false
        comp.flags.pos = false
        comp.flags.zero = true
    }
    else if val > 0
    {
        comp.flags.neg = false
        comp.flags.pos = true
        comp.flags.zero = false
    }
    else
    {
        comp.flags.neg = true
        comp.flags.pos = false
        comp.flags.zero = false
    }
}

dumpMemory :: proc(m: ^LC3)
{
    for arr,ind in m.memory.layout {
         fmt.printf("%04x\t",ind)
         for i in 0..<4 {
            fmt.printf(" %d%d%d%d",
            arr.value[i*4+0],
            arr.value[i*4+1],
            arr.value[i*4+2],
            arr.value[i*4+3])
         }
         if (ind == cast(int)m.pc)
         {
            fmt.print(" <-- PC")
         }
         fmt.print("\n")
    }
}

isFinished :: proc(m: ^LC3) -> bool
{
    return mem.getAtLocation(&m.memory,m.pc) == nil || m.haltFinished
}

printRegisters :: proc(m: ^LC3)
{
    for reg, ind in m.registers
    {
        fmt.printf("R%d: %d  ",ind,reg.value)
    }

    fmt.print("| neg:",m.flags.neg,"zero:",m.flags.zero,"pos:",m.flags.pos)

    fmt.print("\n")
}

processInstruction :: proc (computer:^LC3)
{
    loc := mem.getAtLocation(&computer.memory,computer.pc)

    if loc == nil 
    {
        fmt.println("no further instructions to read")
        return
    }

    currentpc := computer.pc

    computer.pc += 1

    switch loc.instruction
    {
        case inst.InstructionType.NONE:
            fmt.printf("ERROR: Unexpected instruction type at %04x\n",currentpc)
            return
        case inst.InstructionType.ADD:
            destRegister := util.binaryToDecimal(loc.value[4:7])
            
            srcRegister1 := util.binaryToDecimal(loc.value[7:10])

            value2 := 0

            if loc.value[10] == 0
            {
                value2 = util.binaryToDecimal(loc.value[13:16])
                fmt.println("ADD R",destRegister," R",srcRegister1,",R",value2,sep="")
                setRegisterValue(computer,destRegister,getRegisterValue(computer,srcRegister1)+getRegisterValue(computer,value2))
            }
            else
            {
                value2 = util.binaryToDecimal2c(loc.value[11:16])
                fmt.println("ADD R",destRegister," R",srcRegister1,",",value2,sep="")
                setRegisterValue(computer,destRegister,getRegisterValue(computer,srcRegister1)+value2)
            }  

            setConditionCode(computer, getRegisterValue(computer,destRegister))

        case inst.InstructionType.AND:
            destRegister := util.binaryToDecimal(loc.value[4:7])
            srcRegister1 := util.binaryToDecimal(loc.value[7:10])

            srcValue := loc.value[11:16]

            fmt.println("AND R",destRegister, " R",srcRegister1,",",util.binaryToDecimal(srcValue),sep="")

            setRegisterValue(computer,destRegister,getRegisterValue(computer,srcRegister1) & util.binaryToDecimal(srcValue))
            setConditionCode(computer, getRegisterValue(computer,destRegister))
        
        case inst.InstructionType.LD:
            destRegister := util.binaryToDecimal(loc.value[4:7])
            value := util.binaryToDecimal2c(loc.value[7:16])

            location := cast(int)computer.pc+value;

            fmt.println("LD R",destRegister," ",value,sep="")

            if location < 0 || location >= len(computer.memory.layout)
            {
                fmt.println("ERROR: offset points to outside of memory range")
                return
            }

            setRegisterValue(computer,destRegister,util.binaryToDecimal2c(mem.getAtLocation(&computer.memory,cast(uint)location).value[0:16]))
        
        case inst.InstructionType.BR:    
            condition := loc.value[4:7]
            value := util.binaryToDecimal2c(loc.value[7:16])

            location := cast(int)computer.pc+value;

            fmt.println("BR ",condition[0],condition[1],condition[2]," ",value,sep="")

            if location < 0 || location >= len(computer.memory.layout)
            {
                fmt.println("ERROR: offset points to outside of memory range")
                return
            }

            if condition[0] == 1 && computer.flags.neg || 
            condition[1] == 1 && computer.flags.zero || 
            condition[2] == 1 && computer.flags.pos
            {
                computer.pc = cast(uint)location
            }

        case inst.InstructionType.TRAP:
            value := util.binaryToDecimal(loc.value[8:16])

            fmt.println("TRAP",value)

            if (value == 37)
            {
                fmt.println("End of Program")
                computer.haltFinished = true
            }
            else
            {
                fmt.println("ERROR: unexpected trap vector")
            }
    }
}