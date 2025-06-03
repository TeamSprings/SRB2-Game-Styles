--[[

	Disable Types

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Options = tbsrequire 'helpers/create_cvar' ---@type CvarModule

local sets = {
    {nil, "false", "No"},
    {nil, "true", "Yes"},
}

local level = Options:new("disablelevel", sets, nil, CV_NETVAR, 32)

local cutscenes = Options:new("disablecutscenes", sets, nil, CV_NETVAR, 32)

local assets = Options:new("disableassets", sets, nil, CV_NETVAR, 32)

local gui = Options:new("disablegui", sets, function(cv)
    if cv.value > 1 then
        for _,hook in pairs(customhud.hookTypes) do
            for _,item in pairs(customhud.hudItems[hook]) do
                if (item.type == "classichud" and item.isDefaultItem == true) then
                    customhud.SwapItem(item.name, "vanilla");
                    customhud.UpdateHudItemStatus(item);
                end
            end
        end
    else
        for _,hook in pairs(customhud.hookTypes) do
            for _,item in pairs(customhud.hudItems[hook]) do
                if (item.type == "vanilla" and item.funcs["classichud"] and item.isDefaultItem == true) then
                    customhud.SwapItem(item.name, "classichud");
                    customhud.UpdateHudItemStatus(item);
                end
            end
        end
    end
end, 0, 32)