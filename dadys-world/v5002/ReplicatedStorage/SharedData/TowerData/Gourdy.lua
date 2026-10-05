local Gourdy = {}
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
Gourdy.Name = "Gourdy"
Gourdy.Icon = "rbxassetid://99809413682710"
Gourdy.VoteIcon = "rbxassetid://87726355307272"
Gourdy.Render = "rbxassetid://128938603363322"
Gourdy.Health = 2
Gourdy.MainCharacter = true
Gourdy.WalkSpeed = 17.5
Gourdy.RunSpeed = 27.5
Gourdy.DecodeSpeed = 1.5
Gourdy.SkillCheckChance = 25
Gourdy.Stealth = 0
Gourdy.Stamina = 100
Gourdy.BoundarySize = 250
Gourdy.BoundarySize2 = 125
Gourdy.DecodeRank = 5
Gourdy.SpeedRank = 4
Gourdy.StaminaRank = 1
Gourdy.StealthRank = 1
Gourdy.SkillCheckRank = 5
Gourdy.SkillCheckValue = 3
Gourdy.MainCharacter = true
Gourdy.HolidayTower = true
Gourdy.Halloween = true
Gourdy.Ability1Name = "Trick or Treat"
Gourdy.Ability1Type = "Active"
Gourdy.Ability1Description = "This Toon applies a random 20% boost for 15 seconds to all Toons within range. Has a cooldown of 35."
Gourdy.Ability1Cooldown = 35
Gourdy.ActiveAbility = true
Gourdy.AbilityIcon = "rbxassetid://112961056954481"
Gourdy.AbilityCooldown = 35
Gourdy.AbilityDuration = 15
Gourdy.AbilityRange = 15
Gourdy.CustomAbilitySound = "rbxassetid://99406077964419"
Gourdy.AbilityAnimationId = "rbxassetid://117040006124925"
Gourdy.Ability2Name = "Sugar Rush"
Gourdy.Ability2Type = "Passive"
Gourdy.Ability2Description = "Provides a 20% speed boost to all Players for 5 seconds when the Elevator opens and when Panic Mode begins."
Gourdy.PassiveAbilityModule = "Gourdy"
Gourdy.Cost = 3000
Gourdy.Requirement1 = { "Pumpkins", 3000 }
Gourdy.Requirement2 = { "Coin", 2500 }
Gourdy.Requirement3 = { "Research", 100, "GourdyMonster" }
Gourdy.MasterySkin = "VintageGourdy"
Gourdy.MasteryRequirements = {
	{
		Name = "CompleteGenerator",
		Requirement = 175
	},
	{
		Name = "PickUpItem",
		Requirement = 100
	},
	{
		Name = "SurviveFloor",
		Requirement = 70
	},
	{
		Name = "TravelDistance",
		Requirement = 150000
	},
	{
		Name = "ActiveAbilityActivate",
		Requirement = 120
	},
	{
		Name = "SurviveFloorWithToon",
		Requirement = 30,
		Tower = "Main"
	}
}
Gourdy.RightHandBone = "R_palm"
Gourdy.LatchedBoneOffset = CFrame.new(0, 0.3, 0) * CFrame.Angles(1.5707963267948966, 0, 0)

function Gourdy.ClientAbility(_, _) end

function Gourdy.UseActiveAbility(p, instance, p2, _)
	print("Gourdy Active: Ability triggered by", p.Name)
	local abilities = instance:FindFirstChild("Abilities")

	if not abilities then
		return {
			Outcome = false,
			Reason = "Abilities not found!"
		}
	end

	local ability1 = abilities:FindFirstChild("Ability1")

	if not ability1 then
		return {
			Outcome = false,
			Reason = "Ability not found!"
		}
	end

	local cooldown = ability1:FindFirstChild("Cooldown")
	local currentCooldown = ability1:FindFirstChild("CurrentCooldown")

	if not (cooldown and currentCooldown) then
		return {
			Outcome = false,
			Reason = "Cooldown values not found!"
		}
	end

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

	Audio:Play("Sounds.Toon.Gourdy.Ability", {
		Parent = instance.HumanoidRootPart
	})
	currentCooldown.Value = cooldown.Value
	local animateTower = ReplicatedStorage.Events:FindFirstChild("AnimateTower")

	if animateTower then
		animateTower:FireAllClients(instance, "Ability")
	end

	task.spawn(function()
		if instance and instance.Parent ~= nil then
			local gourdyAOE = ReplicatedStorage.Parts.RenderModules.GourdyAOE
			ReplicatedStorage.Events.RenderObject:FireAllClients(gourdyAOE, { instance })
		end
	end)
	local v = {
		{
			name = "Speed",
			modifiers = { "SpeedModifier", "RunSpeedModifier" },
			particle = "Speed"
		},
		{
			name = "SkillCheck",
			modifiers = { "SkillCheckChance", "BoundarySizeModifier" },
			particle = "SkillCheck"
		},
		{
			name = "StaminaRegen",
			modifiers = { "StaminaRegenModifier" },
			particle = "Stamina"
		},
		{
			name = "ExtractionSpeed",
			modifiers = { "DecodeSpeedModifier" },
			particle = "DecodeSpeed"
		}
	}
	local v2 = {}
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in pairs(inGamePlayers:GetChildren()) do
			local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")
			local humanoid = child:FindFirstChild("Humanoid")

			if not (humanoidRootPart and humanoid and humanoid.Health > 0 and child ~= instance) then
				continue
			end

			if not ((p2.Position - humanoidRootPart.Position).Magnitude <= Gourdy.AbilityRange) then
				continue
			end

			local stat = v[math.random(1, #v)]
			print("Gourdy Active: Applying", stat.name, "boost to", child.Name)

			if not child:FindFirstChild("Stats") then
				continue
			end

			local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
			local modifierIds = {}
			table.insert(v2, {
				character = child,
				stat = stat,
				player = game.Players:GetPlayerFromCharacter(child),
				modifierIds = modifierIds
			})
			local name = stat.name
			local v5

			if name == "ExtractionSpeed" then
				v5 = "Extraction Speed"
			elseif name == "SkillCheck" then
				v5 = "Skill Check"
			elseif name == "StaminaRegen" then
				v5 = "Stamina Regen"
			else
				v5 = name
			end

			local playerFromCharacter = game.Players:GetPlayerFromCharacter(child)
			local textEvent = playerFromCharacter and ReplicatedStorage.Events:FindFirstChild("TextEvent")

			if textEvent then
				textEvent:FireClient(playerFromCharacter, "Trick or Treat: " .. v5 .. " +20%!")
			end

			if stat.name == "Speed" then
				modifierIds.speed = StatModifierManager.ApplySpeedModifiers(child, 1.2, "GourdyTrickOrTreat", {
					category = "ability",
					antiCheat = true
				})
			elseif stat.name == "SkillCheck" then
				modifierIds.skillCheck = StatModifierManager.ApplyAdditiveSkillCheckChance(
					child,
					50,
					"GourdyTrickOrTreat"
				)
				modifierIds.boundary = StatModifierManager.ApplyModifier(
					child,
					"BoundarySizeModifier",
					1.2,
					"GourdyTrickOrTreat",
					{
						category = "ability"
					}
				)
			elseif stat.name == "StaminaRegen" then
				modifierIds.staminaRegen = StatModifierManager.ApplyStaminaRegenModifier(
					child,
					1.2,
					"GourdyTrickOrTreat",
					{
						category = "ability"
					}
				)
			elseif stat.name == "ExtractionSpeed" then
				modifierIds.decode = StatModifierManager.ApplyModifier(
					child,
					"DecodeSpeedModifier",
					1.2,
					"GourdyTrickOrTreat",
					{
						category = "ability"
					}
				)
			end

			local attachment = Instance.new("Attachment")
			attachment.Name = "GourdyBuffParticle"
			attachment.Parent = humanoidRootPart
			local buffParticles = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild("BuffParticles")
			local child2 = buffParticles and buffParticles:FindFirstChild(stat.particle)

			if child2 then
				local buffParticle = child2:FindFirstChild("BuffParticle")
				local glow = child2:FindFirstChild("Glow")

				if buffParticle then
					local clone = buffParticle:Clone()
					clone.Parent = attachment
					clone.Enabled = true
					Debris:AddItem(clone, Gourdy.AbilityDuration + 1)
				end

				if glow then
					local clone = glow:Clone()
					clone.Parent = attachment
					clone.Enabled = true
					Debris:AddItem(clone, Gourdy.AbilityDuration + 1)
				end
			end

			Debris:AddItem(attachment, Gourdy.AbilityDuration + 1)
		end
	end

	task.delay(Gourdy.AbilityDuration, function()
		local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)

		for _, v3 in pairs(v2) do
			if not (v3.character and v3.character.Parent and v3.character:FindFirstChild("Stats") and v3.modifierIds) then
				continue
			end

			if v3.stat.name == "Speed" and v3.modifierIds.speed then
				StatModifierManager.RemoveSpeedModifiers(v3.character, v3.modifierIds.speed)
			elseif v3.stat.name == "SkillCheck" then
				if v3.modifierIds.skillCheck then
					StatModifierManager.RemoveAdditiveSkillCheckChance(v3.character, v3.modifierIds.skillCheck)
				end

				if v3.modifierIds.boundary then
					StatModifierManager.RemoveModifier(v3.character, "BoundarySizeModifier", v3.modifierIds.boundary)
				end
			elseif v3.stat.name == "StaminaRegen" and v3.modifierIds.staminaRegen then
				StatModifierManager.RemoveStaminaRegenModifier(v3.character, v3.modifierIds.staminaRegen)
			elseif v3.stat.name == "ExtractionSpeed" and v3.modifierIds.decode then
				StatModifierManager.RemoveModifier(v3.character, "DecodeSpeedModifier", v3.modifierIds.decode)
			end

			print("Gourdy Active: Removed", v3.stat.name, "boost from", v3.character.Name)
		end
	end)
	task.spawn(function()
		local lastTime = os.clock()

		while instance and instance.Parent do
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
		Reason = "Harvest Boost activated!"
	}
end

function Gourdy.HurtAnimation(instance)
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

			if value:FindFirstChildWhichIsA("MeshPart") then
				table.insert(v, value:FindFirstChildWhichIsA("MeshPart"))
			end
		end

		for _, part in ipairs(v) do
			if part:IsA("BasePart") then
				part.TextureID = config.HurtTexture.Texture
			end
		end

		task.wait(2)

		if instance.Parent ~= nil then
			for _, part in ipairs(v) do
				if part:IsA("BasePart") then
					part.TextureID = config.NormalTexture.Texture
				end
			end
		end
	else
		local head = instance:FindFirstChild("Head")

		if head then
			head.TextureID = config.HurtTexture.Texture
			task.wait(2)

			if head.Parent ~= nil then
				head.TextureID = config.NormalTexture.Texture
			end
		end
	end
end

local nows = {}
Gourdy.PlayFunctions = {
	RPAbility = {
		Cooldown = 10,
		DisplayName = Gourdy.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			instance:WaitForChild("HumanoidRootPart")
			local track = humanoid:LoadAnimation((animations:WaitForChild("Ability")))

			local function dothing()
				for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
					if v.Name ~= "Ability" then
						continue
					end

					v:Stop()
					v:Destroy()
				end

				track:Play()

				if instance and instance.Parent ~= nil then
					local gourdyAOE = ReplicatedStorage.Parts.RenderModules.GourdyAOE
					ReplicatedStorage.Events.RenderObject:FireAllClients(gourdyAOE, { instance })
				end
			end

			if nows[p] then
				if p2 < tick() - nows[p] then
					nows[p] = tick()
					dothing()
				end
			else
				nows[p] = tick()
				dothing()
			end
		end
	}
}
return Gourdy