#cmdline "../fbsubs.bas"
#include "../fbsubs.bi"
' Create parser instance
dim as fbsubs.SubtitleParser parser

' Load subtitles
dim as fbsubs.subtitle subs()
parser.fromSrt(subs(), "zh.srt")

' Modify subtitles (example: shift all times by 1000ms)
for i as integer = 1 to ubound(subs)
    subs(i).startTime += 1000
    subs(i).endTime += 1000
next

' Save subtitles
parser.toSrt(subs(), "out.srt")