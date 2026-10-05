local ElementalClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function UpdateSpeed()
	local biome = workspace:GetAttribute("Biome")
	local v

	if biome == nil then
		v = false
	else
		v = Client.BiomesClient.GetCurrentBiome() == biome
	end

	if localPlayer:GetAttribute("Class") == "Elemental" then
		if not ((localPlayer:GetAttribute("ClassLevel") or 1) >= 3) then
			v = false
		end
	else
		v = false
	end

	if not v then
		Client.WalkspeedController.RemoveSpeedChange("ElementalBiomeSpeed")
		return
	end

	Client.WalkspeedController.AddSpeedChange("ElementalBiomeSpeed", "Class", 3)
	Client.WalkspeedController.AddSpeedChange("ElementalBiomeSpeed", "Class", 3, {
		Mode = "Walk"
	})
end

function ElementalClass.Init()
	Client.Events.BiomeEntered:Connect(UpdateSpeed)
	workspace:GetAttributeChangedSignal("Biome"):Connect(UpdateSpeed)
	localPlayer:GetAttributeChangedSignal("Class"):Connect(UpdateSpeed)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(UpdateSpeed)
	UpdateSpeed()
end

return ElementalClass