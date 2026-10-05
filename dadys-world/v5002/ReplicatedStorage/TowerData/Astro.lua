local Astro = {
	Name = "Astro",
	Icon = "rbxassetid://17476673323",
	VoteIcon = "rbxassetid://17476673553",
	Health = 2,
	MainCharacter = true,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 20,
	Stamina = 150,
	BoundarySize = 100,
	LightToon = true,
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 5,
	SkillCheckRank = 2,
	Ability1Name = "Nap Time",
	Ability1Type = "Active",
	Ability1Description = "This Toon can create a pulse that fully restores Stamina of the Toons around him. Has a cooldown of 60.",
	Ability2Name = "Well Rested",
	Ability2Type = "Passive",
	Ability2Description = "This Toon regenerates Stamina 50% faster, and can see Toons that are below 50% Stamina around the map."
}
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")

function Astro.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	instance.Head.TextureID = config.HurtTexture.Texture

	if instance.Head:FindFirstChild("Head") then
		instance.Head.Head.TextureID = config.HurtTexture.Texture
	end

	task.wait(2)

	if instance.Parent ~= nil then
		instance.Head.TextureID = config.NormalTexture.Texture

		if instance.Head:FindFirstChild("Head") then
			instance.Head.Head.TextureID = config.NormalTexture.Texture
		end
	end
end

Astro.ActiveAbility = true
Astro.AbilityIcon = "rbxassetid://17701285095"
Astro.AbilityCooldown = 60
Astro.AbilityRange = 45
Astro.CustomAbilitySound = script.Sound
Astro.PassiveAbilityModule = "Astro"

function Astro.ClientAbility(_, instance)
	if not (instance and instance:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local inGamePlayers = workspace.InGamePlayers

	if inGamePlayers then
		local children = inGamePlayers:GetChildren()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

		for _, v in pairs(children) do
			if not (v:GetChildren()[1] and v ~= instance) then
				continue
			end

			local v2 = v

			local function CreatePopUp()
				if not v2:FindFirstChild("Humanoid") then
					return
				end

				local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
				local humanoidRootPart2 = v2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart and humanoidRootPart2) then
					return
				end

				local stats = v2:FindFirstChild("Stats")

				if not stats then
					return
				end

				local currentStamina = stats:FindFirstChild("CurrentStamina")
				local stamina = stats:FindFirstChild("Stamina")

				if not currentStamina or not stamina or stamina.Value == 0 then
					return
				end

				local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
				local v3 = math.clamp(currentStamina.Value / stamina.Value, 0, 1)

				if v3 <= 0.5 then
					local clone = script.HeartIcon:Clone()
					clone.Size = UDim2.new(math.clamp(magnitude / 10, 2, 15), 0, math.clamp(magnitude / 10, 2, 15), 0)
					clone.Frame.Heart1.Visible = true
					clone.TextLabel.Text = string.format("%d%%", v3 * 100)
					clone.Parent = humanoidRootPart2
					TweenService:Create(clone.Frame.Heart1, tweenInfo, {
						ImageTransparency = 0.5
					}):Play()
					Debris:AddItem(clone, 0.5)
				end
			end

			CreatePopUp()
			task.wait()
		end
	end
end

function Astro.UseActiveAbility(_, instance, p)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	instance:WaitForChild("Humanoid")
	instance:WaitForChild("HumanoidRootPart")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if workspace.Info.FloorActive.Value ~= true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

		if instance and instance.Parent ~= nil then
			local astroPoof = ReplicatedStorage.Parts.RenderModules.AstroPoof
			ReplicatedStorage.Events.RenderObject:FireAllClients(astroPoof, { instance })
		end
	end)

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		local v2 = child
		local success, result = pcall(function()
			if v2 ~= instance then
				local humanoidRootPart = v2:WaitForChild("HumanoidRootPart")
				local stats2 = v2:WaitForChild("Stats")
				local stamina = stats2:WaitForChild("Stamina")
				local currentStamina = stats2:WaitForChild("CurrentStamina")

				if (p.Position - humanoidRootPart.Position).Magnitude <= Astro.AbilityRange then
					if currentStamina.Value < stamina.Value then
						currentStamina.Value += stamina.Value * 1
					end

					if currentStamina.Value >= stamina.Value then
						currentStamina.Value = stamina.Value
					end

					local attachment = Instance.new("Attachment")
					attachment.Name = "BuffParticle"
					attachment.Parent = humanoidRootPart
					local clone = game.ReplicatedStorage.Parts.BuffParticles.Stamina.BuffParticle:Clone()
					clone.Parent = attachment
					clone.Enabled = true
					local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Stamina.Glow:Clone()
					clone2.Parent = attachment
					clone2.Enabled = true
					Debris:AddItem(clone, 2)
					Debris:AddItem(clone2, 2)
					Debris:AddItem(attachment, 2)
					task.delay(1, function()
						if instance and instance.Parent ~= nil and attachment then
							clone.Enabled = false
							clone2.Enabled = false
						end
					end)
				end
			end
		end)

		if not success then
			warn(result)
		end
	end

	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v3 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v3)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Astro