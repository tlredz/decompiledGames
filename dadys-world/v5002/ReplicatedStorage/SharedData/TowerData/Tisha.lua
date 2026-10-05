local Tisha = {
	Name = "Tisha",
	Icon = "rbxassetid://137805772937013",
	VoteIcon = "rbxassetid://18151696174",
	Render = "rbxassetid://81140537322625",
	Health = 3,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 2.5,
	Stealth = 10,
	Stamina = 125,
	BoundarySize = 200,
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 2,
	StealthRank = 3,
	SkillCheckRank = 4,
	Ability1Name = "Tidy Up!",
	Ability1Type = "Active",
	Ability1Description = "This Toon can create a pulse that increases the movement speed of Toons around her by 25% for 5 seconds. This pulse also removes ichor puddles within its radius. Has a cooldown of 50.",
	Cost = 500,
	Requirement1 = { "Coin", 500 },
	MasterySkin = "VintageTisha",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 30
		},
		{
			Name = "TravelDistance",
			Requirement = 50000
		},
		{
			Name = "PickUpItem",
			Requirement = 30
		},
		{
			Name = "SurviveFloor",
			Requirement = 25
		},
		{
			Name = "SurviveFloorWithParty",
			Requirement = 5,
			Number = 4
		},
		{
			Name = "CompleteGenerator",
			Requirement = 30
		}
	},
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://18154848607",
	AbilityCooldown = 50,
	AbilityDuration = 5,
	AbilityRange = 36,
	CustomAbilitySound = {
		SoundId = "rbxassetid://9113595480",
		PlaybackSpeed = 2,
		Volume = 0.25
	}
}
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function cleanDebuffedMachines(position, abilityRange)
	local success, result = pcall(function()
		return require(ReplicatedStorage.Modules.Gameplay.MachineEffects)
	end)
	local count = 0

	for _, model in ipairs(CollectionService:GetTagged("TishaCleanable")) do
		if not (model:IsA("Model") and model:IsDescendantOf(workspace)) then
			continue
		end

		if not (((model.PrimaryPart and model.PrimaryPart.Position or model:GetPivot().Position) - position).Magnitude <= abilityRange and model:GetAttribute("BrushaDebuffed") ~= nil) then
			continue
		end

		if success and result then
			result.ClearArt(model)
		else
			model:SetAttribute("BrushaDebuffed", nil)
			CollectionService:RemoveTag(model, "TishaCleanable")
		end

		count += 1
	end

	return count
end

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
		if part:IsA("BasePart") then
			part.TextureID = texture
		end
	end
end

Tisha.RightHandBone = "head_jnt"
Tisha.LatchedBoneOffset = CFrame.new(1.5, 1.85, 0.8) * CFrame.Angles(1.5707963267948966, 0, 0)

function Tisha.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	setFaceTexture(instance, config.HurtTexture.Texture)
	task.wait(2)

	if instance.Parent ~= nil then
		setFaceTexture(instance, config.NormalTexture.Texture)
	end
end

function Tisha.ClientAbility(_, _) end

function Tisha.OnLoad(instance)
	task.spawn(function()
		local showDusterClient = instance:WaitForChild("ShowDusterClient", 60)

		if showDusterClient then
			showDusterClient.Enabled = true
		end
	end)
end

function Tisha.UseActiveAbility(p, instance, p2)
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")

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

	local decoding = instance:FindFirstChild("Decoding")

	if decoding and decoding.Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

		if instance and instance.Parent ~= nil then
			local tishaPoof = ReplicatedStorage.Parts.RenderModules.TishaPoof
			ReplicatedStorage.Events.RenderObject:FireAllClients(tishaPoof, { instance })
		end
	end)
	local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
	local count = 0

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		local v2 = child
		local success, result = pcall(function()
			if v2 ~= instance then
				local humanoidRootPart = v2:WaitForChild("HumanoidRootPart")

				if (p2.Position - humanoidRootPart.Position).Magnitude <= Tisha.AbilityRange then
					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					local StatModifierManager = require(ReplicatedStorage2.Modules.Data.StatModifierManager)
					local v3 = StatModifierManager.ApplySpeedModifiers(v2, 1.25, "TishaTidyUp", {
						category = "ability",
						antiCheat = true
					})
					task.delay(Tisha.AbilityDuration, function()
						if v3 then
							StatModifierManager.RemoveSpeedModifiers(v2, v3)
						end
					end)
					count += 1
					ActionEvent:Record(v2, "ReceiveActiveAbility", "Tisha", p and p.UserId)
					local attachment = Instance.new("Attachment")
					attachment.Name = "BuffParticle"
					attachment.Parent = humanoidRootPart
					local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
					clone.Parent = attachment
					clone.Enabled = true
					local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
					clone2.Parent = attachment
					clone2.Enabled = true
					Debris:AddItem(clone, Tisha.AbilityDuration + 1)
					Debris:AddItem(clone2, Tisha.AbilityDuration + 1)
					Debris:AddItem(attachment, Tisha.AbilityDuration + 1)
					task.delay(Tisha.AbilityDuration, function()
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
		local success, result = pcall(function()
			local IchorPuddleSpawner = require(ReplicatedStorage.Modules.Zones.IchorPuddleSpawner)
			local v2 = IchorPuddleSpawner.DespawnPuddlesInRadius(p2.Position, Tisha.AbilityRange, 0.1, 1) or 0

			if v2 > 0 or count > 0 then
				ActionEvent:Record(p, "UseActiveAbility", v2, count)
			end
		end)

		if not success then
			warn("Tisha Tidy Up! puddle cleanup failed:", result)
		end
	end)
	task.spawn(function()
		local success, result = pcall(function()
			cleanDebuffedMachines(p2.Position, Tisha.AbilityRange)
		end)

		if not success then
			warn("Tisha Tidy Up! machine cleanup failed:", result)
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

local nows = {}
Tisha.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Tisha.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
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
					local tishaPoof = ReplicatedStorage.Parts.RenderModules.TishaPoof
					ReplicatedStorage.Events.RenderObject:FireAllClients(tishaPoof, { instance })
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
return Tisha