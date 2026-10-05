local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DestroyAfter = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("DestroyAfter"))
return function(data)
	local serverPart = data.serverPart
	local startingCFrame = data.startingCFrame
	local destroyAfter = data.destroyAfter
	local clone = serverPart:Clone()
	clone.CanTouch = false
	clone.Name = "clientPart"
	clone.CFrame = startingCFrame
	clone.Parent = serverPart
	DestroyAfter(clone, destroyAfter)
end