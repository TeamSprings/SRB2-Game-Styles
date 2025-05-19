--[[
		Team Blue Spring's Series of Libaries.
		General Library - lib_debug.lua

		Description: Series of debugging macros
		Useful more so as means to measure performance

		How to get to functions? Use loadfile command

Contributors: Skydusk
@Team Blue Spring 2024
]]

local Debuglib = {iteration = 0, string = "0.1"}
local toggle = false
local formatting = false

COM_AddCommand("debuglib", function(p, arg1)
	toggle = (not toggle)
	if arg1 then
		formatting = true
	else
		formatting = false
	end
end)

-- Stack
local current_scroll = 1
local trace_count = 0
local stack = {}

-- Optimalization measures
local getMicros = getTimeMicros
local print = print
local micros = 0

-- Text allocation
local check_text  = "Current micro second difference: "

-- Debuglib.startProfile()
-- Starts profiling procedure
function Debuglib.startProfile()
	micros = getMicros()
end

-- Debuglib.traceProfile()
-- Checks profiling procedure
function Debuglib.traceProfile()
	print(check_text..(getMicros() - micros))
end

-- Debuglib.clearProfile()
-- Clears profiling procedure
function Debuglib.clearProfile()
	print(check_text..(getMicros() - micros))
	micros = 0
end

--
--	TRACING VALUES OF FUNCTION
--

local easymath = 0
local call = false

addHook("KeyDown", function(keyevent)
	if not toggle then return end

	if input.gameControlToKeyNum(GC_LOOKUP) == keyevent.num then
		current_scroll = current_scroll-1
		return true
	end

	if input.gameControlToKeyNum(GC_LOOKDOWN) == keyevent.num then
		current_scroll = current_scroll+1
		return true
	end

	call = false
	easymath = 0

	if keyevent.num == 61 then -- '+'
		easymath = 1
		return true
	end

	if keyevent.name == 'enter' then
		call = true
		return true
	end

	if keyevent.num == 45 then -- '-'
		easymath = -1
		return true
	end
end)


local function recurse_table_search(depth, array)
	local indent = string.rep('   ', depth)
	local tables = {}
	local functions = {}

	for name, value in pairs(array) do
		local current = #stack+1
		if type(value) == 'table' then
			if formatting then
				table.insert(tables, {value = value, name = name})
			else
				table.insert(stack, indent..' - \132table \128'..name)
				recurse_table_search(depth+1, value)
			end
		elseif type(value) == 'function' then
			if formatting then
				table.insert(functions, {func = value, name = name})
			else
				if current_scroll == current then
					if call then
						pcall(v)
						call = false
					end

					table.insert(stack, indent..' -\130 function '..name..'()')
				else
					table.insert(stack, indent..' -\132 function '..name..'()')
				end
			end
		elseif type(value) ~= 'userdata' then
			local key_item = indent..' - \140'..type(value)..' \128'..name..' = '
			local item = tostring(value)
			if string.len(key_item)+string.len(item) <= 52 then
				table.insert(stack, key_item..item)
			else
				table.insert(stack, key_item)
				table.insert(stack, indent..item)
			end
			--print(name..' = '..value)
		end
	end

	if functions then
		table.insert(stack, '\0')
		for i = 1, #functions do
			local current = #stack+1
			local afunction = functions[i]
			if current_scroll == current then
				if call then
					pcall(afunction.func)
					call = false
				end

				table.insert(stack, indent..' -\130 function '..(afunction.name)..'()')
			else
				table.insert(stack, indent..' -\132 function '..(afunction.name)..'()')
			end
		end
	end

	if tables then
		table.insert(stack, '\0')
		for i = 1, #tables do
			local atable = tables[i]
			table.insert(stack, indent..' - \132table \128'..(atable.name))
			table.insert(stack, '\0')

			recurse_table_search(depth+1, atable.value)

			table.insert(stack, '\0')
		end
	end

end

local function surface_userdata_search(array)
	for name, value in pairs(array) do
		if type(value) ~= 'table'
		and type(value) ~= 'userdata'
		and  type(value) ~= 'function' then
			local key_item = '    - \140'..type(value)..' \128'..name..' = '
			local item = tostring(value)
			if string.len(key_item)+string.len(item) <= 52 then
				table.insert(stack, key_item..item)
			else
				table.insert(stack, key_item)
				table.insert(stack, '   '..item)
			end
			--print(name..' = '..value)
		end
	end
end

-- Debuglib.insertFunction(func, name)
-- Clears profiling procedure
function Debuglib.insertFunction(func, name)
	if not toggle then return end
	local info = debug.getinfo(func, "nS")
	local source_file = ''
	for str in string.gmatch(info.short_src, "[^/]+") do
		source_file = str
	end

	table.insert(stack, "\134>>>\130"..source_file..' -> '..(name or 'function')..'()')
	table.insert(stack, '\0')
	--print("\130"..info.short_src)

	table.insert(stack, '\134 Function located at the line: \128'..(info.linedefined))

	table.insert(stack, '\0')

	local tables = {}
	local functions = {}

	local i = 1
	repeat
		local name, value = debug.getupvalue(func, i)
		local current = #stack+1

		if name then
			if type(value) == 'table' then
				if formatting then
					table.insert(tables, {value = value, name = name})
				else
					table.insert(stack, ' - \132table \128'..name)
					table.insert(stack, '\0')

					recurse_table_search(1, value)

					table.insert(stack, '\0')
				end
			elseif type(value) == 'userdata' then
				table.insert(stack, ' - \132userdata '..userdataType(value)..'\128 '..name)
				surface_userdata_search(array)

				table.insert(stack, '\0')
			elseif type(value) == 'function' then
				if formatting then
					table.insert(functions, {func = value, name = name})
				else
					if current_scroll == current then
						if call then
							pcall(v)
							call = false
						end

						table.insert(stack, ' -\130 function '..name..'()')
					else
						table.insert(stack, ' -\132 function '..name..'()')
					end
				end
			else
				local key_item = ' - \140'..type(value)..' \128'..name..' = '
				local item = tostring(value)
				if string.len(key_item)+string.len(item) <= 52 then
					table.insert(stack, key_item..item)
				else
					table.insert(stack, key_item)
					table.insert(stack, item)
				end
				--print(name..' = '..value)
			end
			i = $+1
		end
	until not name

	if functions then
		table.insert(stack, '\0')
		for i = 1, #functions do
			local current = #stack+1
			local afunction = functions[i]
			if current_scroll == current then
				if call then
					pcall(afunction.func)
					call = false
				end

				table.insert(stack, ' -\130 function '..(afunction.name)..'()')
			else
				table.insert(stack, ' -\132 function '..(afunction.name)..'()')
			end
		end
	end

	if tables then
		table.insert(stack, '\0')

		for i = 1, #tables do
			local atable = tables[i]
			table.insert(stack, ' - \132table \128'..(atable.name))
			table.insert(stack, '\0')

			recurse_table_search(1, atable.value)

			table.insert(stack, '\0')
		end
	end

	table.insert(stack, '\0')
	table.insert(stack, '\0')

	trace_count = $+1
end

function Debuglib.insertEditableNumber(number, name, display_scale, increments, max_val, min_val)
	if not toggle then return number end
	if type(tonumber(number)) ~= "number" then return number end
	display_scale = display_scale or 1
	max_val = max_val or INT32_MAX
	min_val = min_val or INT32_MIN
	increments = increments or 1
	local current = #stack+1

	local num = number

	if current_scroll == current then
		if easymath then
			num = min(max(num+(increments*easymath), min_val), max_val)
			easymath = 0
		end

		table.insert(stack, ' - \130'..name..'\132 = '..(num/display_scale)..'\130 +/-')
	else
		table.insert(stack, ' - \132'..name..'\128 = '..(num/display_scale)..'\132 +/-')
	end

	return tonumber(num)
end

function Debuglib.insertEditableBool(bool, name)
	if not toggle then return bool end
	if type(bool) ~= "boolean" then return bool end
	local boolean = bool
	local current = #stack+1


	if current_scroll == current then
		if easymath then
			boolean = (not boolean)
			easymath = 0
		end

		table.insert(stack, ' - \130'..name..'\132 = '..tostring(boolean))
	else
		table.insert(stack, ' - \132'..name..'\128 = '..tostring(boolean))
	end

	return boolean
end


local LINES = 48
local MID_LINES = LINES/2
local END_LINE_Y = 56+8*(LINES+1)

local function fixedMulInt(int, fixedmultiplier)
	return FixedInt(FixedMul(int * FRACUNIT, fixedmultiplier))
end

local function fixedDivInt(int, fixedmultiplier)
	return FixedInt(FixedDiv(int * FRACUNIT, fixedmultiplier))
end


addHook("HUD", function(v)
	if not (stack and toggle) then return end
	v.drawFill(0, 0, 148, 500, 159|V_SNAPTOTOP|V_SNAPTOLEFT|V_50TRANS)

	current_scroll = max(min(current_scroll, #stack), 1)

	local scroll_view = min(max(current_scroll-MID_LINES, 1), #stack)
	local current_max = min(scroll_view+LINES-1, #stack)
	local scale = v.dupx()
	local scale_height = (scale / 3) + 1

	v.drawString(0, 0, '\135>>>>> Debug Panel by \128@SkyDusk', V_SNAPTOTOP|V_SNAPTOLEFT|V_SMALLSCALEPATCH)
	v.drawString(0, 8, '\135>>>>> Function Traces: \128'..trace_count, V_SNAPTOTOP|V_SNAPTOLEFT|V_SMALLSCALEPATCH)
	v.drawString(0, 16, '\135>>>>> In Stack: \128'..(#stack), V_SNAPTOTOP|V_SNAPTOLEFT|V_SMALLSCALEPATCH)
	v.drawString(0, 24, '\135>>>>> Scroll: \128'..current_scroll, V_SNAPTOTOP|V_SNAPTOLEFT|V_SMALLSCALEPATCH)

	v.drawString(0, 56, '\135>>>>>>>>>>>>>>>>>>>>>', V_SNAPTOTOP|V_SNAPTOLEFT|V_SMALLSCALEPATCH)

	-- Selector
	v.drawFill(0, (8*min(current_scroll, MID_LINES+1)+56)*scale_height, 148*scale, 8*scale_height, 72|V_SNAPTOTOP|V_SNAPTOLEFT|V_NOSCALESTART|V_50TRANS)

	for i = scroll_view, current_max do
		local item = stack[i]
		if not item then continue end
		v.drawString(0, 8*(i-scroll_view)+64, item, V_SNAPTOTOP|V_SNAPTOLEFT|V_SMALLSCALEPATCH)
		--print(item)
	end

	v.drawString(0, END_LINE_Y, '\135>>>>>>>>>>>>>>>>>>>>>', V_SNAPTOTOP|V_SNAPTOLEFT|V_SMALLSCALEPATCH)


	-- Clear stacks after job is done
	stack = {}
	trace_count = 0
end, "game")

rawset(_G, 'Debuglib', Debuglib)