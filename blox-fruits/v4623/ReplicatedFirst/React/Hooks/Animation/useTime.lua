local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local useDrawContext = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("useDrawContext"))
return function(flag: boolean)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(0)

	if flag and not state then
		setState(tick())
	elseif not flag and state then
		setState(nil)
	end

	local v = useDrawContext()
	React.useEffect(function()
		if state and v ~= "Offscreen" then
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				setState2(tick() - state)
			end)
			return function()
				renderSteppedConnection:Disconnect()
			end
		end

		if state2 ~= 0 then
			setState2(0)
		end

		return function() end
	end, { state and v ~= "Offscreen" })
	return state2
end