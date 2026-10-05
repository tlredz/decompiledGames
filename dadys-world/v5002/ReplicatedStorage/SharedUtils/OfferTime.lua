local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = nil
pcall(function()
	local SimulatedTime = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("SimulatedTime"))
	v = SimulatedTime
end)
return function()
	if v then
		local success, result = pcall(function()
			return v.now().UnixTimestamp
		end)

		if success and type(result) == "number" then
			return result
		end
	end

	return os.time()
end