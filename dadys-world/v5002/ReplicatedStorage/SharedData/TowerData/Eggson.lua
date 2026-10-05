local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animateTower = ReplicatedStorage:WaitForChild("Events").AnimateTower
local Players = game:GetService("Players")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local Eggson = {
	Name = "Eggson",
	VoteIcon = "rbxassetid://106130361196066",
	Icon = "rbxassetid://136905973436564",
	Render = "rbxassetid://97978380349051",
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
	Requirement1 = { "Baskets", 300 },
	MasterySkin = "VintageEggson",
	HolidayToon = true,
	HolidayTower = true,
	Easter = true,
	MasteryRequirements = {
		{
			Name = "CompleteGenerator",
			Requirement = 30
		},
		{
			Name = "PassiveAbilityActivate",
			Requirement = 80
		},
		{
			Name = "SurviveFloor",
			Requirement = 25
		},
		{
			Name = "PickUpItem",
			Requirement = 35
		},
		{
			Name = "PickUpCapsule",
			Requirement = 30
		},
		{
			Name = "TravelDistance",
			Requirement = 50000
		}
	},
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
	},
	RightHandBone = "R_hand",
	SpecialSetup = function(instance)
		local primaryPart = instance.PrimaryPart or instance:WaitForChild("HumanoidRootPart")
		local v = {
			Cane_Hit_1 = "Sounds.Toon.Eggson.Ability.CaneHit_1"
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onMarkerReached(name)
			local v2 = v[name]

			if v2 then
				Audio:Play(v2, {
					Name = name,
					Volume = 0.9,
					Parent = primaryPart
				})
			end
		end

		instance:WaitForChild("Humanoid"):WaitForChild("Animator").AnimationPlayed:Connect(function(object)
			local connections = {}
			connections[#connections + 1] = object:GetMarkerReachedSignal("Cane_Hit_1"):Connect(function(_)
				onMarkerReached("Cane_Hit_1") -- equivalent call inferred; original call site unknown
			end)
			connections[#connections + 1] = object.Ended:Connect(function()
				for _, connection in pairs(connections) do
					connection:Disconnect()
				end

				connections = nil
			end)
		end)
	end
}

function Eggson.GeneratorBeginAbility(p, instance, p2, p3)
	local v = "EggsonTapped_" .. tostring(p2.UserId)
	local v2 = "EggsonInteracting_" .. tostring(p2.UserId)
	instance:SetAttribute(v2, true)
	local v3 = p3 or instance:GetAttribute("MinigameType") == "MovementTreadmill"
	local changedConnection = nil

	if instance:GetAttribute(v) then
		print("Eggson Machine Tap - Already tapped by player:", p2.Name)
		animateTower:FireAllClients(p, "Decode")
	else
		instance:SetAttribute(v, true)
		print("Eggson Machine Tap - First tap detected for player:", p2.Name, "treadmill:", v3 and "yes" or "no")
		local animationStop = ReplicatedStorage.Events:FindFirstChild("AnimationStop")

		if v3 then
			animateTower:FireAllClients(
				p,
				"AbilityNoLegs",
				nil,
				nil,
				Enum.AnimationPriority.Action4,
				Eggson.CustomAnimations.EggsonTap_NoLegs.AnimationId
			)
			print("[Eggson] Playing AbilityNoLegs at Action4 on treadmill")
			task.spawn(function()
				task.wait(0.4)

				if p and p.Parent then
					Eggson.BlinkAnimation(p)
				end
			end)
		else
			if animationStop then
				animationStop:FireAllClients(p, "Decode")
				animationStop:FireAllClients(p, "Ability")
			end

			local v4 = true
			changedConnection = instance.Stats.CurrentAmount.Changed:Connect(function()
				if instance.Stats.CurrentAmount.Value >= instance.Stats.RequiredAmount.Value and v4 then
					v4 = false

					if animationStop then
						animationStop:FireAllClients(p, "Decode")
						animationStop:FireAllClients(p, "Ability")
					end

					if changedConnection then
						changedConnection:Disconnect()
						changedConnection = nil
					end
				end
			end)
			animateTower:FireAllClients(p, "Decode")
			animateTower:FireAllClients(
				p,
				"Ability",
				nil,
				nil,
				Enum.AnimationPriority.Action4,
				Eggson.CustomAnimations.EggsonTap.AnimationId
			)
			task.spawn(function()
				task.wait(0.4)

				if p and p.Parent and instance:GetAttribute(v2) and v4 then
					Eggson.BlinkAnimation(p)
				end

				if changedConnection then
					changedConnection:Disconnect()
					changedConnection = nil
				end

				v4 = false
			end)
		end

		local v4 = instance.Stats.RequiredAmount.Value * Eggson.MachineTapBoost
		instance.Stats.CurrentAmount.Value = instance.Stats.CurrentAmount.Value + v4
		local v5 = instance.PlayerCompletion:FindFirstChild(p2.Name)

		if not v5 then
			v5 = Instance.new("NumberValue")
			v5.Name = p2.Name
			v5.Value = 0
			v5.Parent = instance.PlayerCompletion
		end

		v5.Value += v4
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage2.SharedUtils.ActionEvent):Record(
			p2,
			"UsePassiveAbility",
			instance:GetAttribute("MinigameType")
		)
		task.spawn(function()
			local success, result = pcall(function()
				local editData = ReplicatedStorage:FindFirstChild("editData")

				if editData then
					editData:Invoke(p2, function(p4)
						if p4 then
							local v6 = false

							for _, v8 in pairs(p4.Data.Mastery) do
								if v8.Name ~= p.Config.ModuleName.Value then
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
	if child and instance2 then
		instance2:SetAttribute("EggsonInteracting_" .. tostring(child.UserId), false)
		local animationStop = ReplicatedStorage.Events:FindFirstChild("AnimationStop")

		if animationStop and instance then
			animationStop:FireAllClients(instance, "Decode")
			animationStop:FireAllClients(instance, "Ability")
			animationStop:FireAllClients(instance, "AbilityNoLegs")
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

Eggson.PlayFunctions = {}
return Eggson