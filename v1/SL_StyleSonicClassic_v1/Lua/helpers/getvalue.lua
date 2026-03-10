return function(val)
    if type(val) == "function" then
        return val()
    else
        return val
    end
end