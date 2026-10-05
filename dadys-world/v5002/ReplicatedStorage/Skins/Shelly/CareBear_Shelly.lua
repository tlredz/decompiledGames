local CareBearShelly = {}
CareBearShelly.Name = "Cheer Bear"

function CareBearShelly.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://106193491655983"
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://138250515155630"
	local normalTexture = config:WaitForChild("NormalTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	normalTexture.Texture = "rbxassetid://106193491655983"
	blinkTexture.Texture = "rbxassetid://71985632980435"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local v = {
		Hat = "Head",
		Cap = "Head",
		Helmet = "Head",
		Hair = "Head",
		Crown = "Head",
		Headband = "Head",
		Headwear = "Head",
		Shell = "Head",
		LeftArmSleeve = "LeftArm",
		RightArmSleeve = "RightArm",
		LeftSleeve = "LeftArm",
		RightSleeve = "RightArm",
		LArmSleeve = "LeftArm",
		RArmSleeve = "RightArm",
		LeftLegSleeve = "LeftLeg",
		RightLegSleeve = "RightLeg",
		LeftPant = "LeftLeg",
		RightPant = "RightLeg",
		LLegSleeve = "LeftLeg",
		RLegSleeve = "RightLeg",
		TorsoArmor = "Torso",
		Chest = "Torso",
		ChestPiece = "Torso",
		Body = "Torso",
		Shirt = "Torso"
	}
	local v2 = {
		Hat = true,
		Cap = true,
		Helmet = true,
		Hair = true,
		Crown = true,
		Headband = true,
		Headwear = true,
		Shell = true
	}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local child = folder:WaitForChild(v[part.Name] or part.Name)
		local weld = Instance.new("Weld")
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false

		if not v2[part.Name] then
			child.Transparency = 1
		end
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function CareBearShelly.UseAbility(instance)
	local head = instance:WaitForChild("Head")
	local emittersByName = {}

	for _, emitter in pairs(head:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
			continue
		end

		emittersByName[emitter.Name] = emitter
	end

	if emittersByName.Icon then
		emittersByName.Icon:Emit(1)
	end

	if emittersByName.Stars then
		emittersByName.Stars:Emit(1)
	end

	if emittersByName.Sparkles then
		emittersByName.Sparkles:Emit(5)
	end
end

return CareBearShelly