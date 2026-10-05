local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local coin = ReplicatedStorage.Assets.Tools["Pot'O'Gold"].Coin
local Network = require(ReplicatedStorage.Modules.Network)
Network:listen("Tool/PlayCoinEffect", function(p, p2)
	for _ = 1, p2.CoinCount do
		local clone = coin:Clone()
		clone.CFrame = p.HumanoidRootPart.CFrame
		clone.CollisionGroup = "RagdollCollider"
		clone.Parent = workspace
		clone.AssemblyLinearVelocity = Vector3.new(math.random(-10, 10), 40, math.random(-10, 10))
		Debris:AddItem(clone, p2.CoinLifetime)
	end
end)