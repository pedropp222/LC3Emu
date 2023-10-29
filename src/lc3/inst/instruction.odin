package instruction

import "../util"

Instruction :: struct
{
    type : InstructionType
}

InstructionType :: enum {
    NONE,
    ADD,
    AND,
    LD,
    BR,
    TRAP
}

readInstruction :: proc(inst:[16]u8) -> InstructionType
{
    inst := inst;

    if util.arrayEquals(inst[0:4],{0,0,0,1})
    {
        return InstructionType.ADD;
    }
    else if util.arrayEquals(inst[0:4],{0,1,0,1})
    {
        return InstructionType.AND
    }
    else if util.arrayEquals(inst[0:4],{0,0,1,0})
    {
        return InstructionType.LD
    }
    else if util.arrayEquals(inst[0:4],{0,0,0,0})
    {
        return InstructionType.BR
    }
    else if util.arrayEquals(inst[0:4],{1,1,1,1})
    {
        return InstructionType.TRAP
    }

    return InstructionType.NONE;
}