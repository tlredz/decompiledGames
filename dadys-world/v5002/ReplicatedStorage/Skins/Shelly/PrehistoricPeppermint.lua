local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PrehistoricPeppermint = {}
PrehistoricPeppermint.Name = "Prehistoric Peppermint"
PrehistoricPeppermint.TowerName = "Shelly"
PrehistoricPeppermint.Description = "No description yet"
PrehistoricPeppermint.Mastery = false
PrehistoricPeppermint.Cost = 600
PrehistoricPeppermint.Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3
PrehistoricPeppermint.Christmas = true
PrehistoricPeppermint.HolidaySkin = true

function PrehistoricPeppermint.ApplySkin(instance)
	local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local config = instance:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://82042445122833"
	hurtTexture.Texture = "rbxassetid://88530054101306"
	normalTexture.Texture = "rbxassetid://126219870457245"
	instance.RootPart.root:Destroy()
	clone.RootPart.root.Parent = instance.RootPart
	local animations = instance:WaitForChild("Animations")

	for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
		local animation2 = animations:FindFirstChild(animation.Name)

		if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
			animation2.AnimationId = animation.AnimationId
		end
	end

	local v = {}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local weld = Instance.new("Weld")
		local child = instance:WaitForChild(v[part.Name] or part.Name)
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false
		child.Transparency = 1
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function PrehistoricPeppermint.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return PrehistoricPeppermint