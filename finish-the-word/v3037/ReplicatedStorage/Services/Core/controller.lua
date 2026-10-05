local import = _G.import("event")
local UserInputService = game:GetService("UserInputService")
local v = {}

local function inputHappened(p, p2)
	local v2 = v[p.UserInputType]

	if not v2 then
		return
	end

	local v3 = v2[p.UserInputState]

	if not v3 then
		return
	end

	local v4 = { v3(p, p2) }

	if v4[1] == nil then
		return
	end

	import.fire(unpack(v4))
end

UserInputService.InputBegan:connect(inputHappened)
UserInputService.InputEnded:connect(inputHappened)
return {
	defineInput = function(p, p2, p3)
		local v2 = Enum.UserInputType[p]
		local v3 = Enum.UserInputState[p2]
		v[v2] = v[v2] or {}
		v[v2][v3] = p3
	end
}