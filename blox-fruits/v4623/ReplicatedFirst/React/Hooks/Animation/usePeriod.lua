local ReplicatedFirst = game:GetService("ReplicatedFirst")
local useTime = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("Animation"):WaitForChild("useTime"))
return function(flag: boolean, p: number)
	return useTime(flag) % p / p
end