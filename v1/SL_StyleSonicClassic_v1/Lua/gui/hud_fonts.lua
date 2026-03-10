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
	menuyellow = "HUS2",
	menuwhite = "HUW2",
	menunum = "LIFE",
	livesfnt = "HUS2",
	livesnum = "LIFE",
}

fonts.prefixes_index 		= {"S1", "S2", "CD", "S3", "3B", "MA", "XT", "KC", "SC", "MS", "ST"}
fonts.padding_index 		= {0, 0, 0, 0, -1, -1, 0, 0, 0, -1, 0, 0, 0}
fonts.debugfnt_index 		= {"S1", "S1", "S1", "S3", "S3", "S3", "S3", "SC", "SC", "S3", "S1", "S1"}
fonts.yelmenusmfnt_index	= {"HUS2", "HUS2", "HUS2", "HUS3", "HUS2", "HUS2", "HUS2", "HUS2", "HUS2", "HUS2", "HUS2"}
fonts.whimenusmfnt_index	= {"HUW2", "HUW2", "HUW2", "HUW2", "HUW2", "HUW2", "HUW2", "HUW2", "HUW2", "HUW2", "HUW2"}
fonts.menunum_index			= {"LIFE", "LIFE", "LIFE", "LIF3", "LIFE", "LIFE", "LIFE", "LIFE", "LIFE", "LIFE", "LIFE"}
fonts.livesfnt_index		= {"HUS2", "HUS2", "HUS2", "HUS3", "HUS2", "HUS2", "HUS2", "HUS2", "HUS2", "HUS2", "HUS2"}
fonts.livesnum_index		= {"LIFE", "LIFE", "LIFE", "LIF3", "LIFE", "LIFE", "LIFE", "LIFE", "LIFE", "LIFE", "LIFE"}

fonts.opt = Options:new("hudfont", "gui/cvars/hudfont", function(var)
	fonts.font = fonts.prefixes_index[var.value]
	fonts.padding = fonts.padding_index[var.value]
	fonts.debugfont = fonts.debugfnt_index[var.value]
	fonts.menuyellow = fonts.yelmenusmfnt_index[var.value]
	fonts.menuwhite = fonts.whimenusmfnt_index[var.value]
	fonts.menunum = fonts.menunum_index[var.value]
	fonts.livesfnt = fonts.livesfnt_index[var.value]
	fonts.livesnum = fonts.livesnum_index[var.value]
end, 0, 6)

return fonts