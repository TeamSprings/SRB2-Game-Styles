local lib = {
	data = {}
}

	local function hash(str)
		local hash = 5381

		for i = 1, #str do
			local char = string.byte(str, i)

			hash = ((hash * 33) + char) % INT32_MAX
		end

		return hash
	end

	function lib:assest()
		local mapheader_t = mapheaderinfo[gamemap]

		local name 			=	mapheader_t.lvlttl
		local subttl		=	mapheader_t.subttl
		local musname		=	mapheader_t.musname
		local keys			=	mapheader_t.keywords
		local nextlevel		=	mapheader_t.nextlevel
		local typeoflevel	=	mapheader_t.typeoflevel

		local lvlhash = hash(string.format(
			"%s|%s|%s|%s|%d|%d|%d|%d|%d|%d|%d|%d|%d",

		name,
		subttl,
		musname,
		keys,
		nextlevel,
		typeoflevel,
		#mapthings,
		#vertexes,
		#lines,
		#sides,
		#subsectors,
		#sectors,
		#polyobjects))

		return {
			-- Header metadata level grounding

			name 		=	mapheader_t.lvlttl,
			subttl		=	mapheader_t.subttl,
			musname		=	mapheader_t.musname,
			keys		=	mapheader_t.keywords,
			nextlevel	=	mapheader_t.nextlevel,
			typeoflevel	=	mapheader_t.typeoflevel,

			hash = lvlhash,
		}
	end

	COM_AddCommand("styles_getlvlhash", function()
		local table = lib:assest()

		print("[Game Styles] Level Hash: "..table.hash)
	end)

	function lib:summarize()
		if not self.data[gamemap] then
			self.data[gamemap] = lib:assest()
		end

		return self.data[gamemap]
	end

return lib