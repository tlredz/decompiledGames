local function ErrorHandler(p)
	warn((`{tostring(p)}\nStack Begin\n{debug.traceback(nil, 3)}Stack End`))
end

local function Handle(callback, flag: boolean, ...)
	xpcall(callback, ErrorHandler)

	if not flag then
		error((select(1, ...)))
	end

	return ...
end

local function Finally(callback, callback2, ...)
	return Handle(callback2, xpcall(callback, ErrorHandler, ...))
end

return Finally