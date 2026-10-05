local v = nil
local IntroCameraMediator = {}

function IntroCameraMediator.setSkipIntroHandler(callback)
	v = callback
end

function IntroCameraMediator.getSkipIntroHandler()
	return v
end

return IntroCameraMediator