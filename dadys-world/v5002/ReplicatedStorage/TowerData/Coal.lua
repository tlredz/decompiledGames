local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Coal = {}
Coal.Name = "Coal"
Coal.Icon = "rbxassetid://130568522739863"
Coal.VoteIcon = "rbxassetid://74588053251952"
Coal.Health = 3
Coal.MainCharacter = false
Coal.WalkSpeed = 17.5
Coal.RunSpeed = 27.5
Coal.DecodeSpeed = 0.85
Coal.SkillCheckChance = 25
Coal.SkillCheckValue = 1.5
Coal.Stealth = 10
Coal.Stamina = 175
Coal.BoundarySize = 100
Coal.DecodeRank = 2
Coal.SpeedRank = 4
Coal.StaminaRank = 4
Coal.StealthRank = 3
Coal.SkillCheckRank = 2
Coal.Ability1Name = "Scout"
Coal.Ability1Type = "Active"
Coal.Ability1Description = "This Toon can sniff out items across the map, causing items to be highlighted for all Toons for 10 seconds. Has a Cooldown of 30."
Coal.AbilityDuration = 10
Coal.ActiveAbility = true
Coal.AbilityIcon = "rbxassetid://124720867458941"
Coal.AbilityCooldown = 30
Coal.CustomAbilitySound = ""
Coal.CameraMinZoomDistance = 5

function Coal.UseActiveAbility(_, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if not (model and workspace.Info.FloorActive.Value == true) then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	currentCooldown.Value = cooldown.Value
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://76703390580042"
	sound.Parent = instance:WaitForChild("HumanoidRootPart")
	sound:Play()
	Debris:AddItem(sound, 10)
	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v2 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v2)
			end
		end
	end)
	local children = model:WaitForChild("Items"):GetChildren()

	for _, parent in pairs(children) do
		if not parent:GetChildren()[1] or parent:GetAttribute("GigiHoardProp") then
			continue
		end

		local color, text

		if parent.Name == "Tape" then
			color = Color3.fromRGB(255, 255, 255)
			text = "TAPES"
		elseif parent.Name == "ResearchCapsule" or parent.Name == "FakeCapsule" then
			color = Color3.fromRGB(255, 255, 255)
			text = "CAPSULE"
		else
			color = Color3.fromRGB(255, 255, 255)
			text = "ITEM"
		end

		local highlight = Instance.new("Highlight")
		highlight.Parent = parent
		highlight.FillTransparency = 1
		highlight.FillColor = color
		highlight.OutlineColor = color
		local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(highlight, tweenInfo, {
			OutlineTransparency = 1
		}):Play()
		Debris:AddItem(highlight, 10)
		local model2 = parent

		local function CreatePopUp()
			local clone = ReplicatedStorage.GUI.WarningIcon:Clone()

			if model2:IsA("Model") then
				clone.StudsOffset = createVector(0, 5, 0)
			end

			clone.Size = UDim2.new(12, 0, 12, 0)
			clone.Frame.TextLabel.Text = text
			clone.Frame.TextLabel.TextColor3 = color
			clone.Frame.ImageLabel.ImageColor3 = color
			clone.Parent = model2
			local tween = TweenService:Create(clone.Frame.ImageLabel, tweenInfo, {
				ImageTransparency = 1
			})
			local tween2 = TweenService:Create(clone.Frame.TextLabel, tweenInfo, {
				TextTransparency = 1
			})
			local tween3 = TweenService:Create(clone.Frame.TextLabel.UIStroke, tweenInfo, {
				Transparency = 1
			})
			tween:Play()
			tween2:Play()
			tween3:Play()
			Debris:AddItem(clone, 10)
		end

		CreatePopUp()
		task.wait()
	end

	return {
		Outcome = true,
		Reason = "Successfully highlighted items"
	}
end

Coal.HolidayToon = true
Coal.HolidayTower = true
Coal.MasterySkin = "VintageCoal"
Coal.Cost = 1500
Coal.Requirement1 = { "HolidayPoints", 1500 }
Coal.Requirement2 = { "TrinketsOwned", 15 }

function Coal.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local v = {}

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local value = objectValue.Value

			if not value then
				continue
			end

			table.insert(v, value)

			if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
				table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
			end

			for _, part in ipairs(v) do
				if part:IsA("BasePart") then
					part.TextureID = config.HurtTexture.Texture
				end
			end
		end
	else
		local v2 = {
			instance:FindFirstChild("UpperTorso"),
			instance:FindFirstChild("EyeL"),
			instance:FindFirstChild("EyeR")
		}

		for _, v3 in ipairs(v2) do
			if not v3 then
				continue
			end

			table.insert(v, v3)
			v3.TextureID = config.HurtTexture.Texture
		end
	end

	task.wait(2)

	if instance.Parent ~= nil then
		for _, v2 in ipairs(v) do
			v2.TextureID = config.NormalTexture.Texture
		end
	end
end

return Coal