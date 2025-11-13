namespace fbsubs
    type Subtitle
        id as uinteger
        startTime as uinteger
        endTime as uinteger
        text as wstring * 256
    end type

    type SubtitleParser
        private:
            as byte foo 'remove this we'll get an error 256
            declare function addBomForUTF8 (byref fileName as string) as integer
            declare function isDigits(number as string) as boolean
            declare function isFormatedTime (timeline as string) as boolean
            declare function isID (oneLine as string) as boolean
            declare function isTimeline (oneLine as string) as boolean
            declare function timeStrToMs (oneLine as string) as integer
            declare function msToTimeStr(byval totalMs as integer) as string
        public:
            declare constructor()
            declare destructor()
            declare function fromSrt(subs() as subtitle,srtFileName as string) as integer
            declare function toSrt(subs() as subtitle, outSrtName as string) as integer
    end type    
end namespace