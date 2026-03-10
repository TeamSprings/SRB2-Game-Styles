local log = {
    warnCount = 0,
    erroCount = 0,

    actual_log = {},
}

log.coreBracket = "[STYLES CORE]"
log.noteBracket = "[NOTE] "
log.warnBracket = "[WARNING] "
log.erroBracket = "[ERROR] "

log.noteTemplate = "\x83"..log.noteBracket.."\x80"
log.warnTemplate = "\x82"..log.warnBracket.."\x80"
log.erroTemplate = "\x85"..log.erroBracket.."\x80"

function log.getString()
    return table.concat(log.actual_log, "\n")
end

function log.print(text)
	print(log.coreBracket .. " " .. text)

    table.insert(log.actual_log, text)
end

function log.printNote(text)
	print(log.coreBracket .. log.noteTemplate .. text)

    table.insert(log.actual_log, log.noteBracket .. text)
end

function log.printWarn(text)
	print(log.coreBracket .. log.warnTemplate .. text)

    table.insert(log.actual_log, log.warnBracket .. text)
    log.warnCount = $ + 1
end

function log.printErr(text)
	print(log.coreBracket .. log.erroTemplate .. text)

    table.insert(log.actual_log, log.erroBracket .. text)
    log.erroCount = $ + 1
end

return log