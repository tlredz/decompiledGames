local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local _ = {
	DURATION = 2.8,
	COSTUME_NAME = "ChickenCostume",
	SOUND_ID = "rbxassetid://4510529019",
	VOLUME = 0.2
}

local function restoreOriginalBody(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		local chickenOldTransparency = descendant:GetAttribute("ChickenOldTransparency")

		if chickenOldTransparency == nil then
			continue
		end

		descendant.Transparency = chickenOldTransparency
		descendant:SetAttribute("ChickenOldTransparency", nil)
	end
end

local function hideOriginalBody(folder, ancestor)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") or ancestor and part:IsDescendantOf(ancestor) then
			continue
		end

		if part:GetAttribute("ChickenOldTransparency") == nil then
			part:SetAttribute("ChickenOldTransparency", part.Transparency)
		end

		part.Transparency = 1
	end
end

local function attachCostume(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local chickenCostume = ReplicatedStorage:FindFirstChild("ChickenCostume")

	if not (chickenCostume and humanoidRootPart) then
		return nil
	end

	local clone = chickenCostume:Clone()
	clone.Name = "ChickenOutfit_Temp"
	clone.Parent = character
	local basePart = clone:FindFirstChildWhichIsA("BasePart")

	if not basePart then
		return nil
	end

	basePart.Anchored = false
	basePart.CanCollide = false
	basePart.Massless = true
	basePart.CFrame = humanoidRootPart.CFrame
	local weldConstraint = Instance.new("WeldConstraint", basePart)
	weldConstraint.Part0 = basePart
	weldConstraint.Part1 = humanoidRootPart
	return clone
end

return {
	Run = function(player)
		local character = player.Character

		if character and character:FindFirstChild("HumanoidRootPart") then
			task.spawn(function()
				local chickenOutfit_Temp = character:FindFirstChild("ChickenOutfit_Temp")

				if chickenOutfit_Temp then
					chickenOutfit_Temp:Destroy()
				end

				restoreOriginalBody(character)
				local v = attachCostume(character)

				if not v then
					return
				end

				hideOriginalBody(character, v)
				local sound = Instance.new("Sound", character.HumanoidRootPart)
				sound.SoundId = "rbxassetid://4510529019"
				sound.Volume = 0.2
				sound:Play()
				Debris:AddItem(sound, 3.8)
				task.wait(2.8)

				if character.Parent then
					if v then
						v:Destroy()
					end

					restoreOriginalBody(character)
				end
			end)
		end
	end
}