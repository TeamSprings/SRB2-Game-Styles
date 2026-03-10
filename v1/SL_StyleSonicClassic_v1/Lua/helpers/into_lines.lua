return function(str, len)
    local lines = {}
    local index = 1
    local perline = 0

    for rword in string.gmatch(str, "%S+") do
        local word = lines[index] and " "..rword or rword

        perline = perline+string.len(word)

        if perline > len then
            word = rword
            perline = string.len(word)
            index = index+1
        end

        lines[index] = lines[index] and lines[index]..word or word
    end

    return lines, index, perline
end