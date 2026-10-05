local Connie = {}
local Debris = game:GetService("Debris")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Connie.Name = "Connie"
Connie.Icon = "rbxassetid://133764935822586"
Connie.VoteIcon = "rbxassetid://97374367828472"
Connie.Render = "rbxassetid://81445707794889"
Connie.Health = 3
Connie.MainCharacter = false
Connie.WalkSpeed = 10
Connie.RunSpeed = 20
Connie.DecodeSpeed = 1.2
Connie.SkillCheckChance = 25
Connie.SkillCheckValue = 1.5
Connie.Stealth = 20
Connie.Stamina = 150
Connie.BoundarySize = 100
Connie.BoundarySize2 = 150
Connie.DecodeRank = 4
Connie.SpeedRank = 1
Connie.StaminaRank = 3
Connie.StealthRank = 5
Connie.SkillCheckRank = 2
Connie.LightToon = true
Connie.IchorLeakImmune = true
Connie.Ability1Name = "Haunting Escape"
Connie.Ability1Type = "Active"
Connie.Ability1Description = "This Toon uses her ability to become invisible for 5 seconds. Twisteds will not be able to notice her during this time, unless she is up against a Lethal Twisted which will still see her."
Connie.Cost = 2000
Connie.Requirement1 = { "Coin", 2000 }
Connie.Requirement2 = { "Research", 50, "ConnieMonster" }
Connie.MasterySkin = "VintageConnie"
Connie.MasteryRequirements = {
	{
		Name = "ActiveAbilityActivate",
		Requirement = 100
	},
	{
		Name = "TravelDistance",
		Requirement = 55000
	},
	{
		Name = "SurviveFloorWithParty",
		Requirement = 5,
		Number = 3
	},
	{
		Name = "UseItem",
		Requirement = 50
	},
	{
		Name = "CompleteGenerator",
		Requirement = 50
	},
	{
		Name = "SurviveFloor",
		Requirement = 50
	}
}
Connie.ActiveAbility = true
Connie.AbilityIcon = "rbxassetid://91241547745518"
Connie.AbilityCooldown = 50
Connie.AbilityDuration = 5
Connie.AbilityRange = 0
Connie.CustomAbilitySound = "rbxassetid://16976189"
Connie.RightHandBone = "R_hand"
Connie.TreadmillGeneratorOffset = {
	Y = 0,
	Z = 1
}

function Connie.UseActiveAbility(p, folder, _)
	folder:WaitForChild("Config")
	local ability1 = folder:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	folder:WaitForChild("Stats")
	folder:WaitForChild("Humanoid")
	local decoding = folder:WaitForChild("Decoding")
	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart")
	game:GetService("TweenService")

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

	if decoding.Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		local removeCharacterAntiExploitModule = game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule")
		removeCharacterAntiExploitModule:Fire(p, true)

		if folder and folder.Parent ~= nil then
			if folder:FindFirstChild("NoTarget") then
				folder:WaitForChild("NoTarget"):Destroy()
			end

			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "NoTarget"
			boolValue.Parent = folder
			Debris:AddItem(boolValue, Connie.AbilityDuration)
			local v = {}
			local v2 = {}
			local v3 = {}
			local folder2 = Instance.new("Folder")
			folder2.Name = "HauntingEscapeAppearances"

			local function isGhostPart(part)
				local isA = part:IsA("BasePart")

				if isA then
					if part.Transparency < 1 and part.Name ~= "HumanoidRootPart" and part.Name ~= "RootPart" and part.Name ~= "SmokeParticle" then
						isA = part.Name ~= "KillBox"
					else
						isA = false
					end
				end

				return isA
			end

			local function activateSmoke(humanoidRootPart2)
				local clone = game.ReplicatedStorage.Parts.SmokeParticle:Clone()

				if folder and folder:GetAttribute("AlternateColor") then
					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Color = folder:GetAttribute("AlternateColor")
						end
					end
				end

				clone.CFrame = CFrame.new(humanoidRootPart2.Position)
				clone.Anchored = true
				clone.Parent = workspace

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(20)
					end
				end

				task.delay(3, function()
					clone:Destroy()
				end)

				for _, part in ipairs(folder:GetDescendants()) do
					local isA = part:IsA("BasePart")

					if isA then
						if part.Transparency < 1 and part.Name ~= "HumanoidRootPart" and part.Name ~= "RootPart" and part.Name ~= "SmokeParticle" then
							isA = part.Name ~= "KillBox"
						else
							isA = false
						end
					end

					if not isA then
						continue
					end

					table.insert(v, { part, part.Transparency, part.Material })
					part.Transparency = 0.5
					part.Material = Enum.Material.ForceField

					for _, child in ipairs(part:GetChildren()) do
						if child:IsA("SurfaceAppearance") then
							table.insert(v2, { child, part })
							child.Parent = folder2
						elseif child:IsA("Decal") and child.Transparency < 1 then
							table.insert(v3, { child, child.Transparency })
							child.Transparency = 1
						end
					end
				end

				folder2.Parent = folder
			end

			activateSmoke(humanoidRootPart)
			task.wait(Connie.AbilityDuration)

			for _, v4 in ipairs(v) do
				local v5 = v4[1]
				local transparency = v4[2]
				local material = v4[3]

				if not v5.Parent then
					continue
				end

				v5.Transparency = transparency
				v5.Material = material
			end

			for _, v4 in ipairs(v2) do
				local v5 = v4[1]
				local parent = v4[2]

				if parent.Parent and v5.Parent == folder2 then
					v5.Parent = parent
				end
			end

			for _, v4 in ipairs(v3) do
				local v5 = v4[1]
				local transparency = v4[2]

				if v5.Parent then
					v5.Transparency = transparency
				end
			end

			folder2:Destroy()
			removeCharacterAntiExploitModule:Fire(p, false)
		end
	end)
	task.spawn(function()
		while folder do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				task.wait(0.1)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Spook Bomb activated!"
	}
end

function Connie.HurtAnimation(instance)
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

			for _, v2 in ipairs(v) do
				if v2:FindFirstChild("SurfaceAppearance") then
					v2.SurfaceAppearance.TextureId = config.HurtTexture.Texture
				else
					v2.TextureID = config.HurtTexture.Texture
				end
			end
		end
	else
		instance.Head.TextureID = config.HurtTexture.Texture

		if instance.Head:FindFirstChild("Head") then
			instance.Head.Head.TextureID = config.HurtTexture.Texture
		end
	end

	task.wait(2)
	instance.Head.TextureID = config.NormalTexture.Texture

	if instance.Head:FindFirstChild("Head") then
		instance.Head.Head.TextureID = config.NormalTexture.Texture
	end

	if blinkingParts then
		for _, v2 in ipairs(v) do
			if v2:FindFirstChild("SurfaceAppearance") then
				v2.SurfaceAppearance.TextureId = config.NormalTexture.Texture
			else
				v2.TextureID = config.NormalTexture.Texture
			end
		end
	end
end

function Connie.SpecialSetup(instance)
	instance:SetAttribute("IchorPuddleImmune", true)
end

local nows = {}
local v = false
Connie.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Connie.Ability1Name .. " (%d sec)",
		Action = function(p, instance, duration)
			if not p or not instance or v then
				return
			end

			v = true
			local humanoid = instance:WaitForChild("Humanoid")

			local function dothing()
				for _, v2 in pairs(humanoid:GetPlayingAnimationTracks()) do
					if v2.Name ~= "Ability" then
						continue
					end

					v2:Stop()
					v2:Destroy()
				end

				if instance and instance.Parent ~= nil then
					local v2 = { instance, Connie.AbilityDuration }
					local smokeBomb = ReplicatedStorage.Parts.RenderModules.SmokeBomb
					ReplicatedStorage.Events.RenderObject:FireAllClients(smokeBomb, v2)
				end
			end

			if nows[p] then
				if tick() - nows[p] > 15 then
					nows[p] = tick()
					dothing()
				end
			else
				nows[p] = tick()
				dothing()
			end

			task.wait(duration)
			v = false
		end
	}
}
return Connie