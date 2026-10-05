local CollectionService = game:GetService("CollectionService")
game:GetService("MarketplaceService")
game:GetService("Debris")
local gameServices = game.ReplicatedStorage:WaitForChild("GameServices")
local services = game.ReplicatedStorage:WaitForChild("Services")
require(gameServices:WaitForChild("General"))
require(services:WaitForChild("Audio"))
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
game.SoundService:WaitForChild("SFX")
local gameData = game.ReplicatedStorage:WaitForChild("GameData")
require(gameData:WaitForChild("Monetization"))
local localPlayer = game.Players.LocalPlayer
localPlayer.PlayerGui:WaitForChild("Main")
PromptFuncData = {
	Hatch = function(_, instance)
		local parent = instance.Parent
		local parent2 = parent and parent.Parent

		if not parent2 or parent2:HasTag("Hatching") or os.clock() < (parent2:GetAttribute("HatchRequestUntil") or 0) then
			return
		end

		local eggKey = parent2:GetAttribute("EggKey")

		if not eggKey then
			return
		end

		parent2:SetAttribute("HatchRequestUntil", os.clock() + 5)
		instance:SetAttribute("HatchPromptAvailable", false)
		game2.Hatch:FireServer({
			EggKey = eggKey
		})
	end
}

function Initialize(p)
	p.Triggered:Connect(function(player)
		if player ~= localPlayer then
			return
		end

		local v = PromptFuncData[p.Name]

		if v then
			v(player, p)
		end
	end)
end

for _, v in CollectionService:GetTagged("ClientPrompt") do
	Initialize(v)
end

CollectionService:GetInstanceAddedSignal("ClientPrompt"):Connect(function(p)
	Initialize(p)
end)