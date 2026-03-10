local module = {}

module.hooks = {}

function module:addHook(hookitem, func, specifics)
    if not module.hooks[hookitem] then
        pcall(addHook, hookitem, function()
            for _,specifics in ipairs(self.hooks[hookitem]) do
                self.hooks[hookitem]
            end
        end, specifics)
    end
end

return module