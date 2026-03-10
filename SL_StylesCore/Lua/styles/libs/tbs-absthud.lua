if not customhud then return end

local module = {}

module.elements = {}
module.templates = {}

function module:addHUD(huditem, template)
    module.elements[huditem] = {
        conditions = {
            ["_default"] = template.base,
        },
        attributes = template.attrbiutes,

        -- Meta info
        priority = template.priority,
        source = template.source,
        layer = template.drawlayer,
        hook = template.hook
    }

    local element = module.elements[huditem]

    local function closure_hudrender(v, ...)
        for condition, draw in pairs(element.conditions) do
            if condition == "_default" then continue end

            if condition() then
                draw(v, element.attributes, ...)
                return
            end
        end

        element.conditions["_default"](v, element.attributes, ...)
    end

    customhud.SetupItem(huditem, template.source, closure_hudrender, template.hook, template.drawlayer, template.priority)
    module.templates[huditem] = template
end

return module