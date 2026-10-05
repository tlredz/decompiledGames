local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Network = require(ReplicatedStorage.Modules.Network)
local eggs = ReplicatedStorage.Assets.Models.Eggs
local _ = {
	CandyScaleMultiplier = 0.5,
	CandyMinCount = 3,
	CandyMaxCount = 8,
	CandyLifeSpan = 3
}
Network:listen("EggBasket", function(cFrame: CFrame)
	local v = math.random(3, 8)
	local children = eggs:GetChildren()

	for _ = 1, v do
		local clone = children[math.random(1, #children)]:Clone()
		clone.Anchored = false
		clone.CanCollide = true
		clone.Size *= 0.5
		clone.CFrame = cFrame
		clone.Velocity = Vector3.new(math.random(-10, 10), 10, math.random(-10, 10))
		clone.Parent = workspace
		Debris:AddItem(clone, 3)
	end
end)