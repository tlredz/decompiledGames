local RunService = game:GetService("RunService")
local useGlobalState = require(game.ReplicatedStorage.React.Hooks.useGlobalState)
return function(p: string, p2)
	local v, v2 = useGlobalState("MOCK_" .. p, p2)

	if RunService:IsRunning() then
		return nil
	end

	return {
		get = function(_)
			return v
		end,
		set = function(_, p3)
			v2(p3)
		end
	}
end