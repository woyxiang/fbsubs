#include "fbsubs.bi"

namespace fbsubs

constructor SubtitleParser()
    
end constructor

destructor SubtitleParser()
    dim as string tempFile = dir(".fbsubstemp-*")
    while len(tempFile)<>0
        kill tempFile
        tempFile = dir()
    wend
end destructor

function SubtitleParser.addBomForUTF8 (byref fileName as string) as integer
    dim as string threeBytesFromFile = string(3, 0)
    dim as string BOM = chr(&HEF) & chr(&HBB) & chr(&HBF)
    open fileName for binary as #1
    get #1, 1, threeBytesFromFile

    if threeBytesFromFile <> BOM then
        fileName = ".fbsubstemp-" & fileName
        dim as ubyte originData(lof(1) - 1)
        dim as ubyte BOM(2) = {&HEF, &HBB, &HBF}
        get #1, 1, originData()
        open fileName for binary as #2
        put #2, 1, BOM()
        put #2, 4, originData()
        close #1:close #2
        return -1
    end if
    if err <> 0 then
        close #1
        return 1
    end if
    close #1
    return 0
end function    

function SubtitleParser.isDigits(number as string) as boolean
    if len(number) = 0 then return false
    dim as integer asciiCode
    for i as integer = 1 to len(number)
        asciiCode = asc(number,i)
        if asciiCode < 48 or asciiCode > 57 then
            return false
        end if
    next
    return true
end function

function SubtitleParser.isFormatedTime (timeline as string) as boolean
    '0 0 : 0 0 : 0 0 , 0  0  0 
    '1 2 3 4 5 6 7 8 9 10 11 12 
    if isDigits(left(timeline,2)) and mid(timeline,3,1) = ":" then
        if isDigits(mid(timeline,4,2)) and mid(timeline,6,1) = ":" then
            if isDigits(mid(timeline,7,2)) and mid(timeline,9,1) = "," then
                if isDigits(right(timeline,3)) then
                    return true
                end if
            end if
        end if
    end if
    return false
end function

function SubtitleParser.isID (oneLine as string) as boolean
    return isDigits(oneLine)
end function

function SubtitleParser.isTimeline (oneLine as string) as boolean
    if len(oneLine) = 0 then return false
    dim as integer asciiCode
    's  -  -  >  s   ("s" is a space)
    '13 14 15 16 17    
    if not isFormatedTime(left(oneLine, 12)) then return false
    if not isFormatedTime(right(oneLine, 12)) then return false
    if not mid(oneLine,13,5) = " --> " then return false
    return true

end function

function SubtitleParser.timeStrToMs (oneLine as string) as integer
    dim as integer hh, mm, ss, ms
    if not isFormatedTime(oneLine) then return 0
    hh = val(left(oneLine,2))
    mm = val(mid(oneLine,4,2))
    ss = val(mid(oneLine,7,2))
    ms = val(right(oneLine,3))
    return hh*3600*1000 + mm*60*1000 + ss*1000 + ms
end function

function SubtitleParser.fromSrt(subs() as subtitle, srtFileName as string) as integer
    addBomForUTF8 srtFileName
    redim subs(1 to 1)
    dim as wstring * 256 oneLine
    dim as integer id = 1 'index of the array
    open srtFileName for input encoding "utf8" as #1
    while not eof(1)
        line input #1, oneLine
        if isID(oneLine) then
            redim preserve subs(1 to id)
            subs(id).id = int(val(oneLine))
            line input #1, oneLine 'the next line must be the timeline
            if isTimeline(oneLine) then
                subs(id).startTime = timeStrToMs(left(oneLine,12))
                subs(id).endTime   = timeStrToMs(right(oneLine,12))
            else
                redim preserve subs(1 to id - 1)
                return -1
            end if   
            line input #1, oneLine 'the next line must be the text
            subs(id).text = oneLine
            id += 1          
        end if
    wend

    close #1
    return err
end function

function SubtitleParser.msToTimeStr(byval totalMs as integer) as string
    dim as integer hh, mm, ss, ms

    ' 计算各部分
    hh = totalMs \ 3600000
    totalMs = totalMs mod 3600000

    mm = totalMs \ 60000
    totalMs = totalMs mod 60000

    ss = totalMs \ 1000
    ms = totalMs mod 1000

    ' 格式化输出（确保补零）
    return right("0" & str(hh), 2) & ":" & _
           right("0" & str(mm), 2) & ":" & _
           right("0" & str(ss), 2) & "," & _
           right("00" & str(ms), 3)
end function

function SubtitleParser.toSrt(subs() as subtitle, outSrtName as string) as integer
    open outSrtName for output encoding "utf8" as #1
    
    for i as integer = 1 to ubound(subs)
        print #1, subs(i).id
        print #1, msToTimeStr(subs(i).startTime) & " --> " & msToTimeStr(subs(i).endTime)
        print #1, subs(i).text
        print #1,
    next

    close #1
    return err
end function
end namespace
