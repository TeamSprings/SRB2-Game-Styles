local Options = tbsrequire '@Options'
local ModIO = tbsrequire '@IO'
local Bool = styleslocal("helpers/macro/combool")
local Menu = styleslocal("backend/menu/menu_vars")

--
--	COM
--

COM_AddCommand(Menu.com, function(p, var1)
	if consoleplayer ~= p then return end

	if ModIO.embedded then
		---@diagnostic disable-next-line
		Menu.toggle = nil

		return
	end

	local var = Bool[var1]

	if var == nil then
		if Menu.toggle == nil then
			Menu.toggle = true
		else
			Menu.toggle = not (Menu.toggle)
		end
	else
		if var == false and Menu.toggle == true then
			Menu.toggle = false
		elseif var == true then
			Menu.toggle = true
		end
	end
end, COM_LOCAL)

local function MENU_ENABLE()
	COM_BufInsertText(consoleplayer, Menu.com.." true")
end

local function MENU_DISABLE()
	COM_BufInsertText(consoleplayer, Menu.com.." false")
end

addHook("ThinkFrame", function()
	if menuactive or gamestate ~= GS_LEVEL then
		MENU_DISABLE()
	end
end)

-- Fix return
addHook("PlayerThink", function(p)
	if Menu.toggle then
		p.pflags = $|PF_FORCESTRAFE|PF_JUMPDOWN|PF_USEDOWN

		if p == consoleplayer and Menu.xoff > (Menu.easemax/2) then
			local current = S_MusicName(p)

			if current ~= nil and current ~= Menu.music then
				Menu.musicprev = current
				Menu.musicprev_pos = S_GetMusicPosition()
				Menu.musicprev_looppoint = S_GetMusicLoopPoint(p)
				S_ChangeMusic(Menu.music, true, p)
			end
		end
	elseif Menu.toggle == false then
		p.pflags = $ &~ PF_FORCESTRAFE|PF_JUMPDOWN|PF_USEDOWN

		if p == consoleplayer then
			Menu.toggle = nil
			
			if Menu.musicprev then
				S_ChangeMusic(Menu.musicprev, Menu.musicprev_looppoint ~= nil, p, nil, Menu.musicprev_pos, MUSICRATE/4)
				Menu.musicprev = nil
				Menu.musicprev_pos = nil
				Menu.musicprev_looppoint = nil
			end
		end
	end
end)

addHook("KeyDown", function(key_event)
	if Menu.toggle and key_event.name == "escape" then
		MENU_DISABLE()
		return true
	end
end)

addHook("PlayerCmd", function(p, cmd)
	if Menu.toggle then

		local menuitems = Menu.items[Menu.menuselect]

		if cmd and not Menu.pressdelay then
			if cmd.forwardmove < -25 then
				Menu.prevselect = Menu.select
				Menu.select = (Menu.select % #menuitems) + 1
				if type(menuitems[Menu.select]) ~= "table" then
					Menu.select = $ + 1
				end
				Menu.pressdelay = 8
				Menu.yoff = $-Menu.constyease

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.forwardmove > 25 then
				Menu.prevselect = Menu.select
				Menu.select = Menu.select - 1
				if type(menuitems[Menu.select]) ~= "table" then
					Menu.select = $ - 1
				end
				if Menu.select < 1 then
					Menu.select = #menuitems
				end
				Menu.pressdelay = 8
				Menu.yoff = $+Menu.constyease

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove < -25 and (menuitems[Menu.select].cv or menuitems[Menu.select].opt) then
				local cv = menuitems[Menu.select].cv
				local ming = menuitems[Menu.select].minv
				local maxg = menuitems[Menu.select].maxv

				if menuitems[Menu.select].opt then
					local opt = Options:getCV(menuitems[Menu.select].opt)

					if Options:available(opt) then
						S_StartSound(nil, sfx_menu1, p)
						Menu.pressdelay = 8
						return
					end

					cv = opt[1]
					ming = opt[2]
					maxg = opt[3]
				end

				local value = cv.value-1
				if value < ming then
					value = maxg
				end

				CV_Set(cv, value)
				Menu.pressdelay = 8

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove > 25 and (menuitems[Menu.select].cv or menuitems[Menu.select].opt) then
				local cv = menuitems[Menu.select].cv
				local ming = menuitems[Menu.select].minv
				local maxg = menuitems[Menu.select].maxv

				if menuitems[Menu.select].opt then
					local opt = Options:getCV(menuitems[Menu.select].opt)

					if Options:available(opt) then
						S_StartSound(nil, sfx_menu1, p)
						Menu.pressdelay = 8
						return
					end

					cv = opt[1]
					ming = opt[2]
					maxg = opt[3]
				end

				local value = cv.value+1
				if value > maxg then
					value = ming
				end

				CV_Set(cv, value)
				Menu.pressdelay = 8

				S_StartSound(nil, sfx_menu1, p)
			end

			if menuitems[Menu.select].com and cmd.buttons & BT_JUMP then
				COM_BufInsertText(p, menuitems[Menu.select].com)

				Menu.pressdelay = 8
				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.buttons & BT_SPIN then
				MENU_DISABLE()
			end

			if cmd.buttons & BT_CUSTOM1 then
				Menu.menuselect = $ - 1
				Menu.select = 1

				if Menu.menuselect < 1 then
					Menu.menuselect = #Menu.items
				end

				Menu.pressdelay = 8
			end

			if cmd.buttons & BT_CUSTOM3 then
				Menu.menuselect = $ + 1
				Menu.select = 1

				if Menu.menuselect > #Menu.items then
					Menu.menuselect = 1
				end

				Menu.pressdelay = 8
			end
		end

		cmd.sidemove = 0
		cmd.forwardmove = 0
		cmd.buttons = 0
	elseif Menu.scorehold then
		if not ModIO.embedded and cmd and cmd.buttons & BT_TOSSFLAG then
			Menu.scoreholdtics = $ + 1

			if Menu.scoreholdtics == TICRATE then
				Menu.scorehold = nil
				Menu.scoreholdtics = 1

				MENU_ENABLE()
				Menu.pressdelay = 16
			end

			cmd.sidemove = 0
			cmd.forwardmove = 0
			cmd.buttons = 0
		else
			Menu.scoreholdtics = 1
		end

		Menu.scorehold = nil
	end
end)

rawset(_G, "Styles_IsMenuActive", function()
	return Menu.toggle
end)