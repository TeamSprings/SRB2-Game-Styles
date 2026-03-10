local function typeof(check)
    local _type = type(check)

    if _type == "userdata" then
        _type = userdataType(check)
    end

    return _type
end

return function(def)
    local msg = nil

    for item, expected in pairs(def) do
        local _exp = typeof(expected)

        if _exp == "table" then
            local _nam = tostring(expected[1])
            local _typ = typeof(expected[2])
            local _ite = item

            if _typ == "table" then
                local unexpected = true

                for _, _ty in ipairs(expected[2]) do
                    if _ite == _ty then
                        unexpected = false
                        break
                    end
                end

                if unexpected then
                    msg = _nam.." is of unexpected datatype (expected (\""..table.concat(expected[2], ",").."\") got \"".._ite.."\")"
                    break
                end
            elseif _typ == "string" then
                if _ite == expected[2] then
                    continue
                end

                msg = _nam.." is of unexpected datatype (expected \""..expected[2].."\" got \"".._ite.."\")"
                break
            end

            msg = "invalid table"
            break
        end

        msg = "invalid table"
        break
    end

    return msg
end