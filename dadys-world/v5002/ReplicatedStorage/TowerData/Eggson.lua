local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animateTower = ReplicatedStorage:WaitForChild("Events").AnimateTower
local Players = game:GetService("Players")
local Eggson = {
	Name = "Eggson",
	VoteIcon = "rbxassetid://106130361196066",
	Icon = "rbxassetid://136905973436564",
	Health = 3,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 10,
	Stamina = 150,
	BoundarySize = 150,
	MainCharacter = false,
	DecodeRank = 3,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 3,
	SkillCheckRank = 3,
	Ability1Name = "Fixer Upper",
	Ability1Type = "Passive",
	Ability1Description = "When Eggson first touches a machine, he hits the side of it with his cane, giving it 20% of total completion. This can only be used once per machine per player but works on multiple machines on the same floor.",
	Cost = 300,
	Requirement1 = { "HolidayPoints", 300 },
	MasterySkin = "VintageEggson",
	HolidayToon = true,
	HolidayTower = true,
	Easter = true,
	ActiveAbility = false,
	AbilityIcon = "rbxassetid://77285088150406",
	PassiveAbility = true,
	TrinketUnlocked = true,
	TrinketName = "Egg Radar",
	TrinketDescription = "Highlights Basket currency on the map, similar to other currency highlighting trinkets.",
	PassiveMachineTap = true,
	MachineTapBoost = 0.2,
	CustomAnimations = {
		EggsonTap = {
			AnimationId = "rbxassetid://136298900391209",
			Priority = Enum.AnimationPriority.Action3,
			Looped = false
		},
		EggsonTap_NoLegs = {
			AnimationId = "rbxassetid://124102827870999",
			Priority = Enum.AnimationPriority.Action4,
			Looped = false
		}
	}
}

function Eggson.GeneratorBeginAbility(instance, instance2, p, p2)
	local v = "EggsonTapped_" .. tostring(p.UserId)
	local v2 = "EggsonInteracting_" .. tostring(p.UserId)
	instance2:SetAttribute(v2, true)
	local v3 = p2 == true
	local changedConnection = nil

	if instance2:GetAttribute(v) then
		print("[Eggson] Machine already tapped by", p.Name, "machine:", instance2.Name)
		animateTower:FireAllClients(instance, "Decode")
	else
		instance2:SetAttribute(v, true)
		print(
			"[Eggson] Machine Tap - First tap by",
			p.Name,
			"machine:",
			instance2.Name,
			"required:",
			instance2.Stats.RequiredAmount.Value,
			"current:",
			instance2.Stats.CurrentAmount.Value,
			"boost:",
			Eggson.MachineTapBoost * 100 .. "%",
			"treadmill:",
			v3 and "yes" or "no",
			"MinigameType:",
			instance2:GetAttribute("MinigameType") or "nil"
		)
		local animationStop = ReplicatedStorage.Events:FindFirstChild("AnimationStop")

		if v3 then
			animateTower:FireAllClients(
				instance,
				"AbilityNoLegs",
				nil,
				nil,
				Enum.AnimationPriority.Action4,
				Eggson.CustomAnimations.EggsonTap_NoLegs.AnimationId
			)
			print("[Eggson] Playing treadmill no-legs ability animation at Action4 priority")
			task.spawn(function()
				task.wait(0.4)

				if instance and instance.Parent then
					Eggson.BlinkAnimation(instance)
				end
			end)
		else
			local animations = instance:FindFirstChild("Animations")

			if animations and not animations:FindFirstChild("Ability") then
				local animation = Instance.new("Animation")
				animation.Name = "Ability"
				animation.AnimationId = Eggson.CustomAnimations.EggsonTap.AnimationId
				animation.Parent = animations
			end

			if animationStop then
				animationStop:FireAllClients(instance, "Decode")
				animationStop:FireAllClients(instance, "Ability")
			end

			local v4 = true
			changedConnection = instance2.Stats.CurrentAmount.Changed:Connect(function()
				if instance2.Stats.CurrentAmount.Value >= instance2.Stats.RequiredAmount.Value and v4 then
					v4 = false

					if animationStop then
						animationStop:FireAllClients(instance, "Decode")
						animationStop:FireAllClients(instance, "Ability")
					end

					if changedConnection then
						changedConnection:Disconnect()
						changedConnection = nil
					end
				end
			end)
			animateTower:FireAllClients(instance, "Decode")
			animateTower:FireAllClients(
				instance,
				"Ability",
				nil,
				nil,
				Enum.AnimationPriority.Action4,
				Eggson.CustomAnimations.EggsonTap.AnimationId
			)
			task.spawn(function()
				task.wait(0.4)

				if instance and instance.Parent and instance2:GetAttribute(v2) and v4 then
					Eggson.BlinkAnimation(instance)
				end

				if changedConnection then
					changedConnection:Disconnect()
					changedConnection = nil
				end

				v4 = false
			end)
		end

		local v4 = instance2.Stats.RequiredAmount.Value * Eggson.MachineTapBoost
		instance2.Stats.CurrentAmount.Value = instance2.Stats.CurrentAmount.Value + v4
		local v5 = instance2.PlayerCompletion:FindFirstChild(p.Name)

		if not v5 then
			v5 = Instance.new("NumberValue")
			v5.Name = p.Name
			v5.Value = 0
			v5.Parent = instance2.PlayerCompletion
		end

		v5.Value += v4
		print(
			"[Eggson] Boost applied:",
			v4,
			"new current:",
			instance2.Stats.CurrentAmount.Value,
			"/",
			instance2.Stats.RequiredAmount.Value,
			"player completion:",
			v5 and v5.Value or "N/A"
		)
		task.spawn(function()
			local success, result = pcall(function()
				local editData = ReplicatedStorage:FindFirstChild("editData")

				if editData then
					editData:Invoke(p, function(p3)
						if p3 then
							local v6 = false

							for _, v8 in pairs(p3.Data.Mastery) do
								if v8.Name ~= instance.Config.ModuleName.Value then
									continue
								end

								v6 = v8
								break
							end

							if v6 then
								for _, v8 in pairs(v6.RequirementList) do
									if v8.Name == "PassiveAbilityActivate" then
										v8.Current = math.min(v8.Current + 1, v8.Amount)
									end
								end
							end
						end
					end)
				end
			end)

			if not success then
				warn("[Mastery] Error updating data:", result)
			end
		end)
	end
end

function Eggson.HurtAnimation(instance)
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

function Eggson.BlinkAnimation(_) end

function Eggson.GeneratorEndAbility(instance, instance2, child)
	print(
		"[Eggson] GeneratorEndAbility called for",
		not child and "?" or child.Name or "?",
		"machine:",
		not instance2 and "?" or instance2.Name or "?"
	)

	if child and instance2 then
		instance2:SetAttribute("EggsonInteracting_" .. tostring(child.UserId), false)
		local animationStop = ReplicatedStorage.Events:FindFirstChild("AnimationStop")

		if animationStop and instance then
			animationStop:FireAllClients(instance, "Decode")
			animationStop:FireAllClients(instance, "Ability")
		end

		if instance then
			if instance:FindFirstChild("Decoding") then
				instance.Decoding.Value = nil
			end

			if instance.PrimaryPart and instance.PrimaryPart.Anchored then
				if typeof(child) == "string" then
					child = Players:FindFirstChild(child)
				end

				instance.PrimaryPart.Anchored = false

				if child then
					instance.PrimaryPart:SetNetworkOwner(child)
				end
			end
		end
	end
end

return Eggson