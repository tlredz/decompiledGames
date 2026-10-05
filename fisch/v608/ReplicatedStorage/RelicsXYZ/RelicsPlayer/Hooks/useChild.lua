local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)
local parent = script.Parent
local useSignal = require(parent.useSignal)

local function useChild(instance, childName: string)
	local state, setState = React.useState(function()
		return instance and instance:FindFirstChild(childName)
	end)
	local state2, setState2 = React.useState(instance)

	if state2 ~= instance then
		setState(instance and instance:FindFirstChild(childName))
		setState2(instance)
	end

	useSignal(state2 and state2.ChildAdded, function(p)
		if p.Name == childName then
			setState(p)
		end
	end, { state2 })
	return state
end

return useChild