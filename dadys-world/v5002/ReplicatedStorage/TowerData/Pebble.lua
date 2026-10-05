local createVector = vector.create
local Pebble = {}
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
Pebble.Name = "Pebble"
Pebble.Cost = 100
Pebble.Icon = "rbxassetid://16882259119"
Pebble.VoteIcon = "rbxassetid://16846452241"
Pebble.Health = 2
Pebble.MainCharacter = true
Pebble.WalkSpeed = 20
Pebble.RunSpeed = 30
Pebble.DecodeSpeed = 0.75
Pebble.SkillCheckChance = 25
Pebble.SkillCheckValue = 2
Pebble.Stealth = 10
Pebble.Stamina = 175
Pebble.BoundarySize = 150
Pebble.DecodeRank = 1
Pebble.SpeedRank = 5
Pebble.StaminaRank = 4
Pebble.StealthRank = 3
Pebble.SkillCheckRank = 3
Pebble.Ability1Name = "Speak!"
Pebble.Ability1Type = "Active"
Pebble.Ability1Description = "This Toon can bark loudly, drastically decreasing Stealth and alerting any Twisteds nearby to his location. Has a Cooldown of 60."
Pebble.Ability2Name = "Fetch!"
Pebble.Ability2Type = "Passive"
Pebble.Ability2Description = "This Toon can sniff out items, causing them to be highlighted when in the Toon's vicinity."
Pebble.ActiveAbility = true
Pebble.AbilityIcon = "rbxassetid://18817555699"
Pebble.AbilityCooldown = 60
Pebble.CustomAbilitySound = script.Sound
Pebble.AbilityDuration = 10

function Pebble.ClientAbility(_, instance)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if model then
		local items = model:FindFirstChild("Items")

		if not items then
			return
		end

		local children = items:GetChildren()
		Instance.new("Part")
		local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

		for _, parent in pairs(children) do
			if not parent:GetChildren()[1] or not instance.PrimaryPart or not parent.PrimaryPart or parent:GetAttribute("GigiHoardProp") then
				continue
			end

			if not ((instance.PrimaryPart.Position - parent.PrimaryPart.Position).Magnitude <= 125) then
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
			TweenService:Create(highlight, tweenInfo, {
				OutlineTransparency = 1
			}):Play()
			Debris:AddItem(highlight, 4)
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
				TweenService:Create(clone.Frame.ImageLabel, tweenInfo, {
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone.Frame.TextLabel, tweenInfo, {
					TextTransparency = 1
				}):Play()
				TweenService:Create(clone.Frame.TextLabel.UIStroke, tweenInfo, {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 4)
			end

			CreatePopUp()
			task.wait()
		end
	end
end

function Pebble.UseActiveAbility(_, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Stealth")
	stats:WaitForChild("StealthModifier")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if not (workspace.CurrentRoom:FindFirstChildOfClass("Model") and workspace.Info.FloorActive.Value == true) then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	local _ = {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
	currentCooldown.Value = cooldown.Value
	local v = { instance, Pebble.AbilityDuration }
	local pebbleRage = ReplicatedStorage.Parts.RenderModules.PebbleRage
	ReplicatedStorage.Events.RenderObject:FireAllClients(pebbleRage, v)

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = script.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			Debris:AddItem(clone, Pebble.AbilityDuration + 1)
			Debris:AddItem(attachment, Pebble.AbilityDuration + 1)
			task.delay(Pebble.AbilityDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
				end
			end)
		end)
	end

	ReplicatedStorage.Events.MachineEvent:Fire(instance)
	local v3 = StatModifierManager.ApplyAdditiveStealthModifier(instance, -50, "PebbleSpeak")
	task.delay(Pebble.AbilityDuration, function()
		if instance and instance.Parent ~= nil then
			StatModifierManager.RemoveAdditiveStealthModifier(instance, v3)
		end
	end)
	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v5 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v5)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

function Pebble.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	instance.MainBody.TextureID = config.HurtTexture.Texture

	if instance.MainBody:FindFirstChild("MainBody") then
		instance.MainBody.MainBody.TextureID = config.HurtTexture.Texture
	end

	task.wait(2)

	if instance.Parent ~= nil then
		instance.MainBody.TextureID = config.NormalTexture.Texture

		if instance.MainBody:FindFirstChild("MainBody") then
			instance.MainBody.MainBody.TextureID = config.NormalTexture.Texture
		end
	end
end

return Pebble