local Options = tbsrequire 'helpers/create_cvar'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local excp = drawlib.exception
local mono = drawlib.monospace

excp("STTNUM", ":", "STTCOLON")
excp("STTNUM", ".", "STTPERIO")
excp("STTNUM", "-", "STTMINUS")
mono("STTNUM", 8)

local fonts = {
    font = "S1",
    debugfont = "S1",
    padding = 0,
}

fonts.opt = Options:new("hudfont", "gui/cvars/hudfont", function(var)
	local prefixes = {"S1", "S2", "CD", "S3", "3B", "MA", "XT", "KC", "SC", "MS", "ST"}
	fonts.font = prefixes[var.value]

	local paddingset = {0, 0, 0, 0, -1, -1, 0, 0, 0, -1, 0, 0, 0}
	fonts.padding = paddingset[var.value]

	local debugprefixes = {"S1", "S1", "S1", "S3", "S3", "S3", "S3", "SC", "SC", "S3", "S1", "S1"}
	fonts.debugfont = debugprefixes[var.value]
end, 0, 6)

return fonts