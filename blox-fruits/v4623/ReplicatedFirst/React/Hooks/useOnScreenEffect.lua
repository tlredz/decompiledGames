local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local useDrawContext = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("useDrawContext"))
return function(callback, p)
	local v = useDrawContext()
	React.useEffect(function()
		if v == "Offscreen" then
			return function() end
		end

		return callback()
	end, v == "Offscreen" and {} or p)
end