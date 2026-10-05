local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local v = {
	"aura",
	"aura2",
	"black",
	"zealbezier",
	"demon"
}
return function(player)
	local humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart", 1)

	if player.Stage == 0 and humanoidRootPart then
		for _, folder in pairs(humanoidRootPart:GetChildren()) do
			if folder.Name ~= "Purple_Aura_FX" then
				continue
			end

			Util.Debris:AddItem(folder, 2)

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	elseif player.Stage == 1 and humanoidRootPart then
		local clone = script.Assets.Torso:Clone()

		for _, effect in pairs(clone:GetDescendants()) do
			if table.find(v, effect.Name) or not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
				continue
			end

			effect:Destroy()
		end

		clone.Name = "Purple_Aura_FX"
		clone.Parent = humanoidRootPart
	end
end