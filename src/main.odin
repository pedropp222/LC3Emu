package main

import "core:fmt"
import "core:os"
import "lc3/mem"
import "lc3"

main :: proc()
{

    data, res := os.read_entire_file_from_filename("./file.txt")

    if !res
    {
        fmt.println("file 'file.txt' required")
        os.exit(1)
    }

    computer := lc3.LC3{}

    //load 2 values to the first 2 positions in memory before loading the program
    mem.appendValue(&computer.memory,[16]u8{0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0})
    mem.appendValue(&computer.memory,[16]u8{0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0})

    if !setupComputerFromFile(&computer, data)
    {
        fmt.println("Could not setup computer, error when reading file")
        os.exit(1)
    }

    //set program counter to location 2
    computer.pc = 2

    for ; !lc3.isFinished(&computer) ; {
        lc3.printRegisters(&computer)
        lc3.dumpMemory(&computer)
        lc3.processInstruction(&computer)
    }
    lc3.printRegisters(&computer)

    os.exit(0)
}

setupComputerFromFile :: proc (comp: ^lc3.LC3, data: []byte) -> bool
{
    cursor: int = 0

    for cursor < len(data)-1
    {
        next_cursor := getNextChar(cursor,'\n',data)

        if next_cursor != -1
        {
            sl := data[cursor:next_cursor+1]

            if len(sl) < 16
            {
                fmt.println("cannot read line, expected at least size 16, got ",len(sl),sl)
                return false
            }

            //fmt.println("reading data: ",sl)

            //load values from line and convert '1' to 1
            mem.appendValue(&comp.memory,[16]u8{
                sl[0]-48,sl[1]-48,sl[2]-48,sl[3]-48,
                sl[4]-48, sl[5]-48,sl[6]-48,sl[7]-48,
                sl[8]-48,sl[9]-48,sl[10]-48,sl[11]-48,
                sl[12]-48,sl[13]-48,sl[14]-48,sl[15]-48})
        }
        else
        {
            fmt.println("did not find byte '\\n' in file")
            return false
        }

        cursor = next_cursor+1
    }

    return true
}

getNextChar :: proc (from: int, ch:byte, data:[]byte) -> int
{
    for char,ind in data[from:len(data)]
    {
        if char == ch || ind+from == len(data) - 1
        {
            return ind+from
        }
    }
    return -1;
}