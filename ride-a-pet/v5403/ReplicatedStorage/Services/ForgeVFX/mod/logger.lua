local function msg(...)
	return (`[Forge Emit API]: {table.concat({ ... }, " ")}`)
end

local Logger = {}

function Logger.error(...)
	error(msg(..., "\n"))
end

function Logger.warn(...)
	warn(msg(...))
	warn(msg(debug.traceback("stack trace:")))
end

function Logger.info(...)
	print(msg(...))
end

return Logger