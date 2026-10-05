local v = {
	Critial = Color3.fromRGB(255, 3, 3),
	Warning = Color3.fromRGB(255, 187, 52),
	Success = Color3.fromRGB(77, 255, 0)
}
local v2 = {
	[v.Critial] = warn,
	[v.Warning] = warn,
	[v.Success] = print
}
local v3 = {
	[v.Critial] = function(p)
		return "<Error: " .. p .. ">"
	end,
	[v.Warning] = function(p)
		return "<Warning: " .. p .. ">"
	end,
	[v.Success] = function(p)
		return "<Success: " .. p .. ">"
	end
}
local Logger = {}
Logger.Messages = {
	DefaultError = {
		Color = v.Critial,
		Message = "<Error>"
	},
	DefaultSuccess = {
		Color = v.Success,
		Message = "<Success>"
	},
	DefaultWarning = {
		Color = v.Warning,
		Message = "<Warning>"
	}
}

function Logger.debug(...)
	print("LOGGER:", ...)
end

function Logger.new(p, p2)
	assert(p)
	local message

	if p2 then
		message = v3[p.Color](p2)
	else
		message = p.Message
	end

	return {
		Color = p.Color,
		Message = message,
		Context = nil
	}
end

return Logger