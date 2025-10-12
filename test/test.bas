#cmdline "../fbsubs.bas"
#include "../fbsubs.bi"
using fbsubs
dim as SubtitleParser parser
dim as subtitle subs()
parser.fromSrt(subs(), "zh.srt")


for i as integer = 1 to ubound(subs)
    print subs(i).id & " " & subs(i).startTime & " " & subs(i).endTime & " " & subs(i).text
    sleep 100
next
