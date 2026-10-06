game:GetService("ReplicatedStorage")
return function(data)
	local _ = data.cf
	local _ = data.plr
	local state = data.state
	local child = script:FindFirstChild(string.lower(state))

	if not script:FindFirstChild(string.lower(state)) then
		return
	end

	local module = require(child)
	module(data)
end