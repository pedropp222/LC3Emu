package memory

import "../inst"

Memory :: struct
{
    layout : [dynamic]Location
}

Location :: struct
{
    value : [16]u8,
    instruction : inst.InstructionType
}

appendValue :: proc(memory: ^Memory, value:[16]u8)
{
    append(&memory.layout,Location{
        value=value,
        instruction=inst.readInstruction(value)})
}


getAtLocation :: proc(memory:^Memory, loc:uint) -> ^Location
{
    if loc >= len(memory.layout)
    {
        return nil
    }

    return &memory.layout[loc]
}