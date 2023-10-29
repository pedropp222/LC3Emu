package utils

import "core:math"

arrayEquals :: proc (scrArr,compArray:[]u8) -> bool
{
    if len(scrArr)!=len(compArray)
    {
        return false;
    }

    for i in 0..<len(scrArr) 
    {
        if(scrArr[i]!=compArray[i])
        {
            return false;
        }
    }

    return true;
}

binaryToDecimal :: proc(src:[]u8) -> int
{
    value : int = 0

    for i := 0 ; i < len(src) ;i+=1
    {
        value = value + cast(int)src[i] * cast(int)math.pow(2,cast(f32)(len(src)-1-i))
    }

    return value
}

binaryToDecimal2c :: proc(src:[]u8) -> int
{
    if src[0] == 0 {
        return binaryToDecimal(src)
    }

    return - (cast(int)math.pow(2,cast(f32)(len(src)-1)) - binaryToDecimal(src[1:len(src)]))
}

signExtend :: proc (src:[]u8) -> [16]u8
{
    arr : [16]u8
    firstBit := src[0]

    for i := 0 ; i < 16 ;i+=1
    {
        if 16-len(src) < 0
        {
            arr[i]=firstBit
        }
        else
        {
            arr[i] = src[16-i]
        }
    }

    return arr
}

and :: proc (src,mask:[]u8) -> [16]u8
{
    m : [16]u8

    if len(mask) != 16
    {
        m = signExtend(mask)
    }

    final : [16]u8

    for i := 0; i < len(src) ;i+=1
    {
        final[i] = src[i] & m[i]
    }

    return final
}