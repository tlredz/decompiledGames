local function ErrorHandler(p)
	warn((`{tostring(p)}\nStack Begin\n{debug.traceback(nil, 3)}Stack End`))
end

local function WCall(callback, ...)
	return xpcall(callback, ErrorHandler, ...)
end

return WCall