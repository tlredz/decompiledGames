local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
return function(flag: boolean?)
	local state, setState = React.useState(tick())
	local v = useDrawContext()
	local v2

	if flag == false then
		v2 = false
	else
		v2 = v ~= "Offscreen"
	end

	React.useEffect(function()
		if not v2 then
			return function() end
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			setState(tick())
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { v2 })
	return state
end