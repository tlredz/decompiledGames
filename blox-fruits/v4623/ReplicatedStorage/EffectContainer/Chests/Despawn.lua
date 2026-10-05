local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris
return function(p)
	local cFrame = p.CFrame
	local adornee = p.Adornee
	local random = Random.new()

	if cFrame then
		Util.Sound:Play("ChestPoof1", cFrame.Position, nil, 1 + random:NextNumber(-1, 1) / 3, 0.25)
		local clone = script.Cube:Clone()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		clone.Smoke:Emit(math.random(12, 15))
		debris:AddItem(clone, 3)
	end

	if adornee and adornee:IsA("BasePart") then
		local part = Instance.new("Part")
		part.Size = adornee.Size
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		debris:AddItem(part, 2.5)
		local clone = script.Cube.Smoke:Clone()
		clone.Parent = part
		part.CFrame = CFrame.new(adornee.Position)
		part.Parent = _WorldOrigin
		clone:Emit(math.random(2, 3))
		Util.Sound:Play("ChestPoof1", part.Position, nil, 1 + random:NextNumber(-1, 1) / 3, 0.25)
	end
end