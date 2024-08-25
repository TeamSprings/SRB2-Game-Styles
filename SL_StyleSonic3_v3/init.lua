local gameString = "S3K"
local packType = '[Sonic 3 Style]'
local libTBSReq = 1
local menuliReq = 1
local version = '2.2.12' -- Currently 2.2.10. UDMF support comes with 2.2.12


/*
	Sonic 3 Stylized Pack for SRB2
	@ Contributors: Ace Lite,
*/


assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 9), packType.."Mod requires features from "..version.."+")


-- Shut up and load it in.

// Oh yeah, it is quite pointless check in grand scheme of things.
// I just want to minimalize situation, where some genius decides
// to play this on older version of SRB2.

// Man idiot proofing is so so SOO teadious :earless:
if VERSION == 202 and SUBVERSION > 9 then
	print(packType.."As this is WIP version of "..gameString.." pack and UDMF update is not out yet. Game allows to load this pack in "..VERSIONSTRING)

	// Libary file check, whenever or not newer version isn't used anywhere else
	if not TBSlib or ((TBSlib.iteration < libTBSReq) or not TBSlib.iteration) then
		dofile("TBS_libary.lua")
	end

	// Game Assets
	dofile(gameString.."_sprite_models.lua")
	dofile(gameString.."_emerald.lua")
	dofile(gameString.."_capsule.lua")
	dofile(gameString.."_hud.lua")

	// Bonuses
	dofile(gameString.."_special_entrances.lua")
	dofile(gameString.."_gumball_bonus.lua")

	dofile(gameString.."_specialstage_data.lua")
	--dofile(gameString.."_specialstage_engine.lua")
	dofile("hexspecialstage.lua")
end


/*
local function exportstring(s)
   return string.format("%q", s)
end

   --// The Save Function
local function table_save(tbl,filename)
		local charS,charE = "   ","\n"
		local file,err = io.openlocal( filename, "wb" )
		if err then return err end

		-- initiate variables for save procedure
		local tables,lookup = { tbl },{ [tbl] = 1 }
		file:write( "{"..charE )

		for idx,t in ipairs( tables ) do
			file:write( "{" )
			local thandled = {}

			for i,v in ipairs( t ) do
				thandled[i] = true
				local stype = type( v )
				-- only handle value
				if stype == "table" then
				if not lookup[v] then
					table.insert( tables, v )
					lookup[v] = #tables
				end
				file:write( charS.."{"..lookup[v].."}," )
				elseif stype == "string" then
				file:write(  charS..exportstring( v ).."," )
				elseif stype == "number" then
				file:write(  charS..tostring( v ).."," )
				end
			end

			for i,v in pairs( t ) do
				-- escape handled values
				if (not thandled[i]) then

				local str = ""
				local stype = type( i )
				-- handle index
				if stype == "table" then
					if not lookup[i] then
						table.insert( tables,i )
						lookup[i] = #tables
					end
					str = charS.."[{"..lookup[i].."}]="
				elseif stype == "string" then
					str = charS.."["..exportstring( i ).."]="
				elseif stype == "number" then
					str = charS.."["..tostring( i ).."]="
				end

				if str ~= "" then
					stype = type( v )
					-- handle value
					if stype == "table" then
						if not lookup[v] then
							table.insert( tables,v )
							lookup[v] = #tables
						end
						file:write( str.."{"..lookup[v].."},"..charE )
					elseif stype == "string" then
						file:write( str..exportstring( v )..","..charE )
					elseif stype == "number" then
						file:write( str..tostring( v )..","..charE )
					end
				end
				end
			end
			file:write( "},"..charE )
		end
		file:write( "}" )
		file:close()
end

local rawmapdata = {}
local mapdata = {}

local function P_LoadS3KData(mapnum)
	local mapx = io.openlocal("tbs/S3K/"..mapnum..".dat", "rb")
	if mapx then
		local data = mapx:read('*all')
		for i = 1, 32 do
			rawmapdata[i] = {}
		end
		for bin = 0,1023 do
			local loc = (bin % 32)
			local y = (bin / 32)
			rawmapdata[y+1][loc+1] = string.byte(data, (bin), (bin))
			--print(""..mapdata[bin])
		end
			--S3KSS_Current = P_SplitArray(mapdata, 32)
		mapdata = rawmapdata
		mapdata.playerspawnx = (string.byte(data, 1026, 1026))+1
		mapdata.playerspawny = (string.byte(data, 1028, 1028))+1
		mapdata.playerspawna = (string.byte(data, 1024, 1024))*90
	end
	io.close(mapx)
end

for i = 1, 7 do
	mapdata = {}
	P_LoadS3KData(i)
	table_save(mapdata,	"tbs/S3K/"..i.."conv.dat")
end
*/