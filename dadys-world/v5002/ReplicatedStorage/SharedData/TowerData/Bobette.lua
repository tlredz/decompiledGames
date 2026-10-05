local createVector = vector.create
local Bobette = {}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
Bobette.Name = "Bobette"
Bobette.Icon = "rbxassetid://79977174778992"
Bobette.VoteIcon = "rbxassetid://107871901378296"
Bobette.Render = "rbxassetid://109086274152484"
Bobette.Health = 2
Bobette.MainCharacter = true
Bobette.WalkSpeed = 15
Bobette.RunSpeed = 25
Bobette.DecodeSpeed = 0.85
Bobette.SkillCheckChance = 25
Bobette.SkillCheckValue = 2.5
Bobette.Stealth = 5
Bobette.Stamina = 200
Bobette.BoundarySize = 200
Bobette.DecodeRank = 2
Bobette.SpeedRank = 3
Bobette.StaminaRank = 5
Bobette.StealthRank = 2
Bobette.SkillCheckRank = 4
Bobette.Ability1Name = "Precious Packaging"
Bobette.Ability1Type = "Active"
Bobette.Ability1Description = "This Toon can duck and cover herself into a gift box for 8 seconds, during this time she is invincible yet unable to move."
Bobette.Ability2Name = "Festive Aura"
Bobette.Ability2Type = "Passive"
Bobette.Ability2Description = "The festive aura of this Toon passively gives those around her 50% faster stamina regeneration and a 25% speed boost that lasts for 5 seconds."
Bobette.HolidayToon = true
Bobette.HolidayTower = true
Bobette.Christmas = true
Bobette.Cost = 3000
Bobette.Requirement1 = { "Christmas2025Ornaments", 3000 }
Bobette.Requirement2 = { "Coin", 2500 }
Bobette.Requirement3 = { "Research", 100, "BobetteMonster" }
Bobette.MasterySkin = "VintageBobette"
Bobette.MasteryRequirements = {
	{
		Name = "ActiveAbilityActivate",
		Requirement = 100
	},
	{
		Name = "CompleteGenerator",
		Requirement = 120
	},
	{
		Name = "SurviveFloor",
		Requirement = 60
	},
	{
		Name = "ReachFloor",
		Requirement = 1,
		Number = 20
	},
	{
		Name = "UseItem",
		Requirement = 125
	},
	{
		Name = "TravelDistance",
		Requirement = 150000
	}
}
Bobette.ActiveAbility = true
Bobette.AbilityIcon = "rbxassetid://132987565484011"
Bobette.AbilityCooldown = 90
Bobette.AbilityDuration = 8
Bobette.AbilityRange = 0
Bobette.CustomAbilitySound = "rbxassetid://123603789166527"
Bobette.PassiveAbility = true
Bobette.PassiveSpeedBoost = 2
Bobette.RingAbility = true
Bobette.RightHandBone = "R_hand"
local v = nil

function Bobette.UseActiveAbility(instance, folder, _)
	if not v then
		local BobetteTimerController = require(game.ReplicatedStorage.Modules.ClientUI.BobetteTimerController)
		v = BobetteTimerController
	end

	folder:WaitForChild("Config")
	local ability1 = folder:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = folder:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	folder:WaitForChild("Humanoid")
	local decoding = folder:WaitForChild("Decoding")

	if folder:FindFirstChild("BoxAbilityActive") then
		return {
			Outcome = false,
			Reason = "Ability is already active!"
		}
	end

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

	local inElevator = folder:WaitForChild("Stats"):WaitForChild("InElevator")

	if inElevator.Value == true then
		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	end

	local function checkPlayerInElevator(folder2, elevatorHitBox)
		local partsInPart = workspace:GetPartsInPart(elevatorHitBox)

		for _, v2 in ipairs(partsInPart) do
			if v2.Name == "HumanoidRootPart" and v2.Parent:FindFirstChild("Humanoid") and v2.Parent == folder2 then
				return true
			end
		end

		return false
	end

	if checkPlayerInElevator(
		folder,
		workspace:WaitForChild("Elevators"):WaitForChild("Elevator"):WaitForChild("ElevatorHitBox")
	) then
		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	end

	local anchoredsByPart = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			anchoredsByPart[part] = part.Anchored
		end
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name == "BobetteActiveDurationDisplay" or descendant.Name == "BobetteCooldownDisplay" then
			descendant:Destroy()
		end
	end

	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "BoxAbilityActive"
	boolValue.Parent = folder

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disableSprint(player)
		local stats2 = player and player.Character and (player.Character or player.CharacterAdded:Wait()):FindFirstChild("Stats")

		if stats2 then
			stats2.HoldingSprint.Value = false
		end
	end

	task.spawn(function()
		disableSprint(instance) -- equivalent call inferred; original call site unknown
	end)
	local v2 = {
		HumanoidRootPart = true,
		RootPart = true,
		KillBox = true,
		ParticlePart = true
	}

	local function cleanupBoxAbility()
		if folder and folder.Parent then
			local currentSkin = folder:GetAttribute("CurrentSkin") or "Default"

			for _, part in ipairs(folder:GetDescendants()) do
				if not part:IsA("BasePart") or (part:HasTag("StayTransparent") or v2[part.Name]) then
					continue
				end

				if not (not part:HasTag("SkinPart") or currentSkin == "Default" or currentSkin == "VintageBobette") then
					continue
				end

				part.Transparency = 0
			end

			local present = folder:FindFirstChild("Present")

			if present then
				for _, part in ipairs(present:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 1
					end
				end
			end

			for k, anchored in pairs(anchoredsByPart) do
				if k and k.Parent then
					k.Anchored = anchored
				end
			end

			local humanoid = folder:FindFirstChild("Humanoid")

			if humanoid then
				humanoid.PlatformStand = false
			end

			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(1.5, 0.3, 0.5, 1, 1)
			end

			if boolValue and boolValue.Parent then
				boolValue:Destroy()
			end

			CollectionService:RemoveTag(instance, "NoGenerator")

			local function tryGetComponent(instance2, childName, p)
				local child = instance2:WaitForChild(childName, p)

				if not child then
					warn(string.format("Missing %s for Bobette's passive ability", childName))
				end

				return child
			end

			local quickLinks = folder:WaitForChild("QuickLinks", 5)

			if not quickLinks then
				warn(string.format("Missing %s for Bobette's passive ability", "QuickLinks"))
			end

			if quickLinks then
				quickLinks = quickLinks:WaitForChild("RingRangerModel", 5)

				if not quickLinks then
					warn(string.format("Missing %s for Bobette's passive ability", "RingRangerModel"))
				end
			end

			local value = quickLinks and quickLinks.Value
			task.spawn(function()
				if value:FindFirstChild("WeldConstraint") then
					value.WeldConstraint.Enabled = false
					value:SetNetworkOwner(Players:GetPlayerFromCharacter(folder))
				end
			end)
			game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(
				instance,
				false
			)
		end
	end

	local changedConnection = nil
	changedConnection = inElevator.Changed:Connect(function()
		if inElevator.Value == true and folder:FindFirstChild("BoxAbilityActive") then
			cleanupBoxAbility()

			if changedConnection then
				changedConnection:Disconnect()
			end
		end
	end)
	task.spawn(function()
		task.wait(Bobette.AbilityDuration)

		if changedConnection then
			changedConnection:Disconnect()
		end
	end)
	currentCooldown.Value = cooldown.Value
	CollectionService:AddTag(instance, "NoGenerator")
	local boolValue2 = Instance.new("BoolValue")
	boolValue2.Name = "Invincible"
	boolValue2.Value = true
	boolValue2.Parent = folder
	local attachment = Instance.new("Attachment")
	attachment.Name = "InvincibleParticle"
	attachment.Parent = folder:WaitForChild("HumanoidRootPart")
	local clone = game.ReplicatedStorage.Parts.RenderModules.SavoryCharm.BuffParticle:Clone()
	clone.Parent = attachment
	clone.Enabled = true
	Debris:AddItem(boolValue2, Bobette.AbilityDuration)
	Debris:AddItem(clone, Bobette.AbilityDuration)
	Debris:AddItem(attachment, Bobette.AbilityDuration)
	task.spawn(function()
		game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(
			instance,
			true,
			nil,
			9
		)

		if folder and folder.Parent ~= nil then
			if folder:FindFirstChild("NoTarget") then
				folder:WaitForChild("NoTarget"):Destroy()
			end

			local boolValue3 = Instance.new("BoolValue")
			boolValue3.Name = "NoTarget"
			boolValue3.Parent = folder
			Debris:AddItem(boolValue3, Bobette.AbilityDuration)

			if folder:FindFirstChild("NoDandy") then
				folder:WaitForChild("NoDandy"):Destroy()
			end

			local boolValue4 = Instance.new("BoolValue")
			boolValue4.Name = "NoDandy"
			boolValue4.Parent = folder
			Debris:AddItem(boolValue4, Bobette.AbilityDuration)
			local cardModifiers = workspace.Info:FindFirstChild("CardModifiers")
			local v3 = cardModifiers and cardModifiers:FindFirstChild("IceSkatingEnabled") and cardModifiers.IceSkatingEnabled.Value == true
			local iceSkatingMode = folder:GetAttribute("IceSkatingMode") == true
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
			local v4 = not humanoidRootPart and createVector(0, 0, 0) or humanoidRootPart.AssemblyLinearVelocity or createVector(
				0,
				0,
				0
			)
			local v5 = v3 or iceSkatingMode

			for _, part in ipairs(folder:GetDescendants()) do
				if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "RootPart" and part.Name ~= "KillBox") then
					continue
				end

				part.Transparency = 1

				if not v5 then
					part.Anchored = true
				end
			end

			if v5 and humanoidRootPart then
				local humanoid = folder:FindFirstChild("Humanoid")

				if humanoid then
					humanoid.PlatformStand = true
				end

				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "IceSlideAlignAttachment"
				attachment2.Parent = humanoidRootPart
				local alignOrientation = Instance.new("AlignOrientation")
				alignOrientation.Name = "IceSlideAlignOrientation"
				alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
				alignOrientation.Attachment0 = attachment2
				alignOrientation.CFrame = CFrame.new()
				alignOrientation.MaxTorque = 100000
				alignOrientation.Responsiveness = 50
				alignOrientation.Parent = humanoidRootPart
				Debris:AddItem(attachment2, Bobette.AbilityDuration)
				Debris:AddItem(alignOrientation, Bobette.AbilityDuration)
				local vector2 = Vector3.new(v4.X, 0, v4.Z)

				if vector2.Magnitude > 1 then
					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
						vector2.X * 1.3,
						humanoidRootPart.AssemblyLinearVelocity.Y,
						vector2.Z * 1.3
					)
				end
			end

			local present = folder:WaitForChild("Present")

			if present then
				present.Parent = folder

				for _, part in ipairs(present:GetDescendants()) do
					if not part:IsA("BasePart") or CollectionService:HasTag(part, "StayTransparent") then
						continue
					end

					part.Transparency = 0
				end
			end

			Bobette.EmitBoxParticles(folder)
			local box = present:WaitForChild("Box")
			Audio:Play("Sounds.Toon.Bobette.Ability.Rip", {
				Parent = box
			})
			local blinkController = box.BlinkParent:WaitForChild("BlinkController")
			blinkController.Enabled = false
			local v6 = v.create(present)

			if v6 then
				v.start(v6, Bobette.AbilityDuration)
			end

			local v7 = tick() + Bobette.AbilityDuration

			while tick() < v7 and folder and folder.Parent do
				task.wait(0.1)
			end

			if v6 then
				pcall(function()
					v.cancel(v6)
				end)
			end

			if folder:FindFirstChild("BoxAbilityActive") then
				Audio:Play("Sounds.Toon.Bobette.Ability.Rip", {
					Parent = box
				})
				Audio:Play("Sounds.Toon.Bobette.Ability.Ding", {
					Parent = box
				})
				Audio:Play("Sounds.Toon.Bobette.Ability.Chime", {
					Parent = box
				})
				cleanupBoxAbility()
			end
		end
	end)
	task.spawn(function()
		task.wait(Bobette.AbilityDuration)

		while folder and folder.Parent and currentCooldown.Value > 0 do
			currentCooldown.Value -= 0.1
			task.wait(0.1)
		end

		currentCooldown.Value = 0
	end)
	return {
		Outcome = true,
		Reason = "Box Disguise activated!"
	}
end

function Bobette.EmitBoxParticles(instance)
	local boxParticles = instance:WaitForChild("QuickLinks"):WaitForChild("BoxParticles")

	for _, objectValue in ipairs(boxParticles:GetChildren()) do
		if not (objectValue:IsA("ObjectValue") and objectValue.Value) then
			continue
		end

		local value = objectValue.Value

		for _, emitter in ipairs(value:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(1)
			end
		end
	end
end

function Bobette.RPSpecialSetup(instance)
	local value = instance:WaitForChild("QuickLinks"):WaitForChild("RingRangerModel").Value
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	task.spawn(function()
		while task.wait(0.1) do
			if not value:CanSetNetworkOwnership() then
				continue
			end

			value:SetNetworkOwner(playerFromCharacter)
			break
		end
	end)
	value:SetAttribute("IsVisible", false)
	local weldConstraint = value:WaitForChild("WeldConstraint")
	weldConstraint.Enabled = false
end

function Bobette.cleanupRingRangerHighlight(folder)
	if not folder then
		return
	end

	local ringRangerModelHighlight = nil
	local quickLinks = folder:FindFirstChild("QuickLinks")

	if quickLinks then
		local ringRangerModel = quickLinks:FindFirstChild("RingRangerModel")

		if ringRangerModel and ringRangerModel.Value then
			ringRangerModelHighlight = ringRangerModel.Value:FindFirstChild("RingRangerModelHighlight")
		end
	end

	if not ringRangerModelHighlight then
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant.Name ~= "RingRangerModelHighlight" then
				continue
			end

			ringRangerModelHighlight = descendant
			break
		end
	end

	if ringRangerModelHighlight and ringRangerModelHighlight.Parent then
		pcall(function()
			ringRangerModelHighlight:Destroy()
		end)
	end
end

local v2 = nil

function Bobette.UpdatePassive(instance)
	local floorActive = workspace:WaitForChild("Info"):WaitForChild("FloorActive")
	local RunService = game:GetService("RunService")

	if not v2 then
		local BobbeteGlobalBoosts = require(game.ReplicatedStorage.Parts.BobbeteGlobalBoosts)
		v2 = BobbeteGlobalBoosts
	end

	local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)

	local function passiveLive()
		return TowerLUT:HasPassive(instance, "Bobette")
	end

	local function tryGetComponent(instance2, childName, p)
		local child = instance2:WaitForChild(childName, p)

		if not child then
			warn(string.format("Missing %s for Bobette's passive ability", childName))
		end

		return child
	end

	local ringRangerParent = instance:WaitForChild("RingRangerParent", 5)

	if not ringRangerParent then
		warn(string.format("Missing %s for Bobette's passive ability", "RingRangerParent"))
	end

	if ringRangerParent then
		ringRangerParent = ringRangerParent:WaitForChild("RingRanger", 5)

		if not ringRangerParent then
			warn(string.format("Missing %s for Bobette's passive ability", "RingRanger"))
		end
	end

	local quickLinks = instance:WaitForChild("QuickLinks", 5)

	if not quickLinks then
		warn(string.format("Missing %s for Bobette's passive ability", "QuickLinks"))
	end

	if quickLinks then
		quickLinks = quickLinks:WaitForChild("RingRangerModel", 5)

		if not quickLinks then
			warn(string.format("Missing %s for Bobette's passive ability", "RingRangerModel"))
		end
	end

	local value = quickLinks and quickLinks.Value
	local ringRangerModelHighlight

	if value then
		ringRangerModelHighlight = value:WaitForChild("RingRangerModelHighlight", 5)

		if not ringRangerModelHighlight then
			warn(string.format("Missing %s for Bobette's passive ability", "RingRangerModelHighlight"))
		end
	else
		ringRangerModelHighlight = value
	end

	local auraRadiusBoost = instance:GetAttribute("AuraRadiusBoost") or 1

	if auraRadiusBoost ~= 1 then
		if ringRangerParent and ringRangerParent:IsA("BasePart") then
			ringRangerParent.Size *= auraRadiusBoost
		end

		if value and value:IsA("BasePart") then
			value.Size *= auraRadiusBoost
		end
	end

	task.spawn(function()
		task.wait(1)

		if value:FindFirstChild("WeldConstraint") then
			value.WeldConstraint.Enabled = false
			value:SetNetworkOwner(Players:GetPlayerFromCharacter(instance))
		end
	end)

	local function updateRingVisibility()
		if not (value and ringRangerModelHighlight) then
			return
		end

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local v3 = not (floorActive.Value and TowerLUT:HasPassive(instance, "Bobette"))
		TweenService:Create(value, tweenInfo, {
			Transparency = v3 and 1 or 0
		}):Play()
		TweenService:Create(ringRangerModelHighlight, tweenInfo, {
			FillTransparency = v3 and 1 or 0.5,
			OutlineTransparency = v3 and 1 or 0.45
		}):Play()
	end

	local changedConnection = floorActive.Changed:Connect(updateRingVisibility)

	for _, v3 in ipairs({ "MaskToon", "MaskPassive", "MaskStatsOnly" }) do
		instance:GetAttributeChangedSignal(v3):Connect(updateRingVisibility)
	end

	updateRingVisibility()
	instance.AncestryChanged:Connect(function(_, parent)
		if not parent and changedConnection then
			changedConnection:Disconnect()
		end
	end)
	local v3 = {}
	local v4 = {}
	local v5 = 15 * (instance:GetAttribute("AuraRadiusBoost") or 1)
	local vector2 = Vector3.new(v5, v5, v5)

	local function isValidCharacter(instance2)
		local humanoid

		if instance2 then
			if instance2.Parent == workspace.InGamePlayers then
				humanoid = instance2:FindFirstChild("Humanoid")

				if humanoid then
					if instance2.Humanoid.Health > 0 then
						humanoid = instance2 ~= instance
					else
						humanoid = false
					end
				end
			else
				humanoid = false
			end
		else
			humanoid = instance2
		end

		return humanoid
	end

	local v6 = {
		activeBoosts = {},
		addBoost = function(self, p2)
			if v4[p2] then
				task.cancel(v4[p2])
				v4[p2] = nil
				self.activeBoosts[p2] = true
			elseif not self.activeBoosts[p2] then
				self.activeBoosts[p2] = true
				v2.AddBoost(p2)
			end
		end,
		removeBoost = function(self, p2, p3)
			if self.activeBoosts[p2] then
				self.activeBoosts[p2] = nil

				if p3 then
					v2.RemoveBoost(p2)

					if v4[p2] then
						task.cancel(v4[p2])
						v4[p2] = nil
					end
				else
					local thread = task.spawn(function()
						task.wait(5)
						v2.RemoveBoost(p2)
						v4[p2] = nil
					end)
					v4[p2] = thread
				end
			end
		end,
		cleanup = function(self)
			for k in pairs(self.activeBoosts) do
				self:removeBoost(k, true)
			end

			for k, v7 in pairs(v4) do
				task.cancel(v7)
				v2.RemoveBoost(k)
			end

			v4 = {}
			self.activeBoosts = {}
		end
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanupAllBoosts()
		v6:cleanup()
		v3 = {}
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if floorActive.Value and instance.Parent and TowerLUT:HasPassive(instance, "Bobette") then
			if ringRangerParent and ringRangerParent.Parent then
				local position = ringRangerParent.Position
				local partBoundsInBox = workspace:GetPartBoundsInBox(CFrame.new(position), vector2)
				local v7 = {}

				for _, v8 in ipairs(partBoundsInBox) do
					local model = v8:FindFirstAncestorWhichIsA("Model")

					if not model then
						continue
					end

					local humanoid

					if model then
						if model.Parent == workspace.InGamePlayers then
							humanoid = model:FindFirstChild("Humanoid")

							if humanoid then
								if model.Humanoid.Health > 0 then
									humanoid = model ~= instance
								else
									humanoid = false
								end
							end
						else
							humanoid = false
						end
					else
						humanoid = model
					end

					if not humanoid then
						continue
					end

					v7[model] = true

					if v3[model] then
						continue
					end

					v3[model] = true
					v6:addBoost(model)
				end

				for k in pairs(v3) do
					if v7[k] then
						continue
					end

					v3[k] = nil
					v6:removeBoost(k)
				end
			end
		else
			cleanupAllBoosts() -- equivalent call inferred; original call site unknown
		end
	end)

	local function handleElevatorState()
		cleanupAllBoosts() -- equivalent call inferred; original call site unknown
	end

	floorActive.Changed:Connect(handleElevatorState)
	local diedConnection = nil
	diedConnection = instance.Humanoid.Died:Connect(function()
		pcall(function()
			Bobette.cleanupRingRangerHighlight(instance)
		end)
		pcall(function()
			cleanupAllBoosts() -- equivalent call inferred; original call site unknown
		end)

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		if diedConnection then
			diedConnection:Disconnect()
		end

		if changedConnection then
			changedConnection:Disconnect()
		end
	end)
	local changedConnection2 = nil
	instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			pcall(function()
				Bobette.cleanupRingRangerHighlight(instance)
			end)
			pcall(function()
				cleanupAllBoosts() -- equivalent call inferred; original call site unknown
			end)

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end

			if diedConnection then
				diedConnection:Disconnect()
			end

			if changedConnection then
				changedConnection:Disconnect()
			end

			if changedConnection2 then
				changedConnection2:Disconnect()
			end
		end
	end)
	local decoding = instance:WaitForChild("Decoding")
	changedConnection2 = decoding.Changed:Connect(function()
		if not (value and ringRangerModelHighlight) then
			return
		end

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local v7 = decoding.Value ~= nil
		local v8 = v7 or not TowerLUT:HasPassive(instance, "Bobette")
		TweenService:Create(value, tweenInfo, {
			Transparency = v8 and 1 or 0
		}):Play()
		TweenService:Create(ringRangerModelHighlight, tweenInfo, {
			FillTransparency = v8 and 1 or 0.5,
			OutlineTransparency = v8 and 1 or 0.45
		}):Play()

		if v7 then
			value:SetNetworkOwner(nil)
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter then
			value:SetNetworkOwner(playerFromCharacter)
		end
	end)
	cleanupAllBoosts() -- equivalent call inferred; original call site unknown
end

function Bobette.HurtAnimation(instance)
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

local v3 = false
local nows = {}
Bobette.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Bobette.Ability1Name .. " (%d sec)",
		Action = function(p, folder, duration)
			if p and folder and not v3 then
				v3 = true

				local function dothing()
					local v4 = folder:waitForChild("Present")

					for _, part in ipairs(folder:GetDescendants()) do
						if not part:IsA("BasePart") or CollectionService:HasTag(part, "StayTransparent") then
							continue
						end

						part.Transparency = 1
					end

					local box = v4:WaitForChild("Box")
					Audio:Play(139448788332736, {
						Parent = box
					})
					Audio:Play(101459781982359, {
						Parent = box
					})

					for _, child in pairs(v4:GetChildren()) do
						child.Transparency = 0
					end

					Bobette.EmitBoxParticles(folder)
					task.wait(Bobette.AbilityDuration)
					local v5 = {
						HumanoidRootPart = true,
						RootPart = true,
						KillBox = true,
						ParticlePart = true
					}

					if folder and folder.Parent ~= nil then
						local currentSkin = folder:GetAttribute("CurrentSkin") or "Default"

						for _, part in ipairs(folder:GetDescendants()) do
							if not part:IsA("BasePart") or (part:HasTag("StayTransparent") or v5[part.Name]) then
								continue
							end

							if not (not part:HasTag("SkinPart") or currentSkin == "Default" or currentSkin == "VintageBobette") then
								continue
							end

							if part:HasTag("RingRangerModel") then
								part.Transparency = part:GetAttribute("IsVisible") and 0 or 1
							else
								part.Transparency = 0
							end
						end

						for _, child in pairs(v4:GetChildren()) do
							child.Transparency = 1
						end
					end

					Audio:Play(139448788332736, {
						Parent = box
					})
					Audio:Play(101459781982359, {
						Parent = box
					})
				end

				if nows[p] then
					if duration < tick() - nows[p] then
						nows[p] = tick()
						dothing()
					end
				else
					nows[p] = tick()
					dothing()
				end

				task.wait(duration)
				v3 = false
			end
		end
	},
	RingVisibility = {
		DisplayName = "Toggle Ring Visibility",
		Action = function(_, instance, _)
			local function setRingRangerVisibility(folder, isVisible)
				if not folder then
					warn("Ring ranger model is nil")
					return
				end

				folder:SetAttribute("IsVisible", isVisible)
				folder.Transparency = isVisible and 0 or 1

				for _, descendant in ipairs(folder:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						descendant.Transparency = isVisible and 0 or 1
					end
				end
			end

			if not instance then
				warn("Character is nil in FunctionRingVisibility")
				return
			end

			local value = instance:WaitForChild("QuickLinks"):FindFirstChild("RingRangerModel").Value

			if not value then
				warn("RingRanger model not found in character")
				return
			end

			local isVisible = value:GetAttribute("IsVisible")

			if isVisible == nil then
				isVisible = false
			end

			setRingRangerVisibility(value, not isVisible)
		end
	}
}
return Bobette