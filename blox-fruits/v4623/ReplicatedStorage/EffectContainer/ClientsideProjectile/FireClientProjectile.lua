local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("DestroyAfter"))
return function(p)
	local serverPart = p.serverPart
	local clientPart = serverPart:WaitForChild("clientPart", 0.5)

	if not clientPart then
		warn("clientPart not found! FireClientProjectile")
		return
	end

	local bodyVelocity = clientPart:FindFirstChildOfClass("BodyVelocity")

	if bodyVelocity then
		bodyVelocity:Destroy()
	end

	local clone = serverPart:FindFirstChildOfClass("BodyVelocity"):Clone()
	clone.Parent = clientPart
	clientPart.Anchored = false
	clientPart:SetAttribute("Fired", true)
end