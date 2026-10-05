local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
require(shared.Signal)

local function useChanged(p, object)
	local state, setState = React.useState(p)

	local function setChanged(p2)
		if state ~= p2 then
			setState(p2)
			object:FireDeferred(p2)
		end
	end

	return state, setChanged
end

return useChanged