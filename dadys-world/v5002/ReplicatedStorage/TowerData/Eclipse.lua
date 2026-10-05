local function setFaceTexture(instance, texture)
	instance:WaitForChild("Config")
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local v = {}

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			table.insert(v, objectValue.Value)

			if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
				table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
			end
		end
	else
		local head = instance:FindFirstChild("Head")

		if not head then
			warn("No Head found in character and no BlinkingParts folder.")
			return
		end

		table.insert(v, head)

		if head:FindFirstChild("Head") then
			table.insert(v, head.Head)
		end
	end

	for _, part in ipairs(v) do
		if part:IsA("MeshPart") then
			part.TextureID = texture
		end
	end
end

return {
	Name = "Eclipse",
	Icon = "rbxassetid://82081910592748",
	VoteIcon = "rbxassetid://90856175711906",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 5,
	Stamina = 150,
	BoundarySize = 150,
	LightToon = true,
	HolidayTower = true,
	Halloween = true,
	DecodeRank = 3,
	SpeedRank = 4,
	StaminaRank = 3,
	StealthRank = 2,
	SkillCheckRank = 3,
	Ability1Name = "Total Eclipse",
	Ability1Type = "Passive",
	Ability1Description = "This Toon transforms into a werewolf in blackouts, giving off a glow, gaining 2 Stamina Stars, a 20% Movement Speed boost, and briefly highlighting all Twisteds on the floor.",
	PassiveAbilityModule = "Eclipse",
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		local child = config:FindFirstChild((instance:GetAttribute("Transformed") == true and "Transform" or "") .. "HurtTexture")

		if child then
			setFaceTexture(instance, child.Texture)
		end

		task.wait(2)
		local child2 = instance.Parent ~= nil and config:FindFirstChild((instance:GetAttribute("Transformed") == true and "Transform" or "") .. "NormalTexture")

		if child2 then
			setFaceTexture(instance, child2.Texture)
		end
	end
}