local ReplicatedFirst = game:GetService("ReplicatedFirst")
local useTime = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("Animation"):WaitForChild("useTime"))
return function(flag: boolean, p: number, flag2: boolean, value: number?)
	local v = math.sin(6.283185307179586 * ((useTime(flag) + (value or 0)) % p / p))

	if flag2 then
		return v
	end

	return 0
end