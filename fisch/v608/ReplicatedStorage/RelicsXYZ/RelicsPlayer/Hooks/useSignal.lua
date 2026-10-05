local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
require(shared.Signal)

local function useSignal(p, callback, p2)
	React.useEffect(function()
		local connection = p and p:Connect(callback)
		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, p2)
end

return useSignal