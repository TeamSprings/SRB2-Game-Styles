--[[

		Flicky Behavior

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

sfxinfo[freeslot("sfx_advaap")].caption = "Flicky Appears!"

---@diagnostic disable-next-line
states[S_SA2FLICKYBUBBLE] = {
	sprite = SPR_FLB9,
	frame = FF_ANIMATE|FF_ADD|FF_TRANS20|A,
	tics = 35,
	var1 = 34,
	var2 = 1,
	nextstate = S_SA2FLICKYBUBBLE,
}

local function bubbleflicky(a)
	local overlay = P_SpawnMobjFromMobj(a, 0,0,0, MT_ROTATEOVERLAY)
	overlay.state = S_SA2FLICKYBUBBLE
	overlay.target = a
	overlay.fuse = TICRATE*6
	overlay.bubble = true
	overlay.scale = FRACUNIT/3
	overlay.scaleup = FRACUNIT
	overlay.z = $ + 12*a.scale*P_MobjFlip(a)
	overlay.angle = P_RandomKey(360)*ANG1
	a.angle = P_RandomKey(360)*ANG1
	a.pickupinvulneribility = TICRATE/3
	--S_StartSound(a, sfx_advaap)
end

local Flickydata = {
	[MT_FLICKY_01] = 			{name = "Bluebird", 	type = "flight"},
	[MT_FLICKY_02] = 			{name = "Rabbit", 	 	type = "speed"},
	[MT_FLICKY_03] = 			{name = "Chicken",  	type = "flight"},
	[MT_FLICKY_04] = 			{name = "Seal", 	 	type = "power"},
	[MT_FLICKY_05] = 			{name = "Pig", 	 		type = "power"},
	[MT_FLICKY_06] = 			{name = "Chipmunk", 	type = "speed"},
	[MT_FLICKY_07] = 			{name = "Penguin",  	type = "speed"},
	[MT_FLICKY_08] = 			{name = "Fish",     	type = "speed"},
	[MT_FLICKY_09] = 			{name = "Ram", 	 		type = "power"},
	[MT_FLICKY_10] = 			{name = "Puffin", 		type = "flight"},
	[MT_FLICKY_11] = 			{name = "Cow", 	 		type = "power"},
	[MT_FLICKY_12] = 			{name = "Rat",  		type = "speed"},
	[MT_FLICKY_13] = 			{name = "Bear", 		type = "power"},
	[MT_FLICKY_14] = 			{name = "Dove", 	 	type = "flight"},
	[MT_FLICKY_15] = 	   		{name = "Cat", 			type = "speed"},
	[MT_FLICKY_16] = 	   		{name = "Canary",  		type = "flight"},
	[MT_SECRETFLICKY_01] = 		{name = "Spider",     	type = "speed"},
	[MT_SECRETFLICKY_02] = 		{name = "Bat", 	 		type = "flight"},
}

local list_flickies = {
	MT_FLICKY_01,
	MT_FLICKY_02,
	MT_FLICKY_03,
	MT_FLICKY_04,
	MT_FLICKY_05,
	MT_FLICKY_06,
	MT_FLICKY_07,
	MT_FLICKY_08,
	MT_FLICKY_09,
	MT_FLICKY_10,
	MT_FLICKY_11,
	MT_FLICKY_12,
	MT_FLICKY_13,
	MT_FLICKY_14,
	MT_FLICKY_15,
	MT_FLICKY_16,
	MT_SECRETFLICKY_01,
	MT_SECRETFLICKY_02,
}


local function touchflicky(a, t)
	if t.bot and not t.player then return true end

	if a.pickupinvulneribility then
		return true
	end


	local p = t.player

	if not p.flickies then
		p.flickies = {}
	end

	if #p.flickies > 8 then
		table.remove(p.flickies, 1)
	end

	table.insert(p.flickies, {mobjtype = a.type, data = Flickydata[a.type]})

	-- Horrible if-elseif ladder, it would have been easier to do it differently,
	-- Whatever... Time is resource and this is one-time event.
	if p.flickies.tics then
		if p.flickies.tics < TICRATE*3 - 15 and p.flickies.tics > 10 then
			p.flickies.tics = TICRATE*3 - 16
		elseif p.flickies.tics <= 10 and p.flickies.tics > 0 then
			p.flickies.tics = TICRATE*3 - p.flickies.tics
		elseif p.flickies.tics > TICRATE*3 - 15 then
			p.flickies.tics = p.flickies.tics
		else
			p.flickies.tics = TICRATE*3
		end
	else
		p.flickies.tics = TICRATE*3
	end
end

rawset(_G, "Styles_SAFlickyList", 	list_flickies)
rawset(_G, "Styles_SAFlickyData", 	Flickydata)
rawset(_G, "Styles_SAFlickyBubble", bubbleflicky)
rawset(_G, "Styles_SAFlickyTouch", 	touchflicky)

for _,v in ipairs(list_flickies) do

mobjinfo[v].flags = $|MF_SPECIAL &~ MF_NOCLIPTHING

addHook("MobjSpawn", bubbleflicky, v)

addHook("TouchSpecial", touchflicky, v)

end