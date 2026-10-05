local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://5115308750"
sound.Volume = 0.8
sound.Parent = script
local CollectionService = game:GetService("CollectionService")
local Cocoa = {}
Cocoa.Name = "Cocoa"
Cocoa.VoteIcon = "rbxassetid://129611138175536"
Cocoa.Icon = "rbxassetid://96689448192352"
Cocoa.Health = 3
Cocoa.WalkSpeed = 17.5
Cocoa.RunSpeed = 27.5
Cocoa.DecodeSpeed = 0.85
Cocoa.SkillCheckChance = 25
Cocoa.SkillCheckValue = 2
Cocoa.Stealth = 15
Cocoa.Stamina = 125
Cocoa.BoundarySize = 150
Cocoa.MainCharacter = false
Cocoa.DecodeRank = 2
Cocoa.SpeedRank = 4
Cocoa.StaminaRank = 2
Cocoa.StealthRank = 4
Cocoa.SkillCheckRank = 3
Cocoa.Ability1Name = "Bonbon"
Cocoa.Ability1Type = "Active"
Cocoa.Ability1Description = "This Toon places a Bonbon candy item that can be picked up and used by anyone. When used, the Bonbon boosts extraction speed (+50%) and movement speed (+25%) for 10 seconds. Has a cooldown of 40."
Cocoa.Cost = 1500
Cocoa.Requirement1 = { "HolidayPoints", 1500 }
Cocoa.Requirement2 = {
	"Research",
	100,
	"Any",
	5
}
Cocoa.MasterySkin = "VintageCocoa"
Cocoa.HolidayToon = true
Cocoa.HolidayTower = true
Cocoa.Easter = true
Cocoa.ActiveAbility = true
Cocoa.AbilityIcon = "rbxassetid://72532445175661"
Cocoa.AbilityCooldown = 40
Cocoa.AbilityItem = "BonBon"
Cocoa.CustomAbilitySound = sound
Cocoa.BonBonExtractionBoost = 0.5
Cocoa.BonBonSpeedBoost = 0.25
Cocoa.BonBonDuration = 10

function Cocoa.UseActiveAbility(player, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	instance:WaitForChild("Stats")
	local decoding = instance:WaitForChild("Decoding")
	local humanoid = instance:WaitForChild("Humanoid")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

	if instance:WaitForChild("Stats"):WaitForChild("InElevator").Value == true then
		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	end

	local function checkPlayerInElevator(instance2, elevatorHitBox)
		local partsInPart = workspace:GetPartsInPart(elevatorHitBox)

		for _, v in ipairs(partsInPart) do
			if v.Name == "HumanoidRootPart" and v.Parent:FindFirstChild("Humanoid") and v.Parent == instance2 then
				return true
			end
		end

		return false
	end

	if checkPlayerInElevator(
		instance,
		workspace:WaitForChild("Elevators"):WaitForChild("Elevator"):WaitForChild("ElevatorHitBox")
	) then
		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	end

	currentCooldown.Value = cooldown.Value
	humanoid:WaitForChild("Animator"):LoadAnimation((instance:WaitForChild("Animations"):WaitForChild("PlaceChocolate"))):Play()

	local function countAndManageUserBonbons(userId)
		local v = "CocoaBonbon_" .. userId
		local tagged = CollectionService:GetTagged(v)

		if not (#tagged >= 10) then
			return #tagged
		end

		local v2 = 1e999
		local v3 = nil

		for _, v4 in ipairs(tagged) do
			local placedTimestamp = v4:GetAttribute("PlacedTimestamp") or 0

			if not (placedTimestamp < v2) then
				continue
			end

			v3 = v4
			v2 = placedTimestamp
		end

		if not v3 then
			return #tagged
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function createRemovalEffect(cFrame)
			local _, _ = pcall(function()
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				local clone = ReplicatedStorage2.Parts.ItemDrop:Clone()
				clone.CFrame = cFrame
				clone.Anchored = true
				clone.Size *= 0.7
				local model = workspace:FindFirstChild("CurrentRoom"):FindFirstChildOfClass("Model")

				if model then
					clone.Parent = model

					for _, emitter in ipairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(20)
						end
					end

					local Debris = game:GetService("Debris")
					Debris:AddItem(clone, 2)
				end
			end)
		end

		local cFrame = v3.PrimaryPart and v3.PrimaryPart.CFrame
		CollectionService:RemoveTag(v3, v)
		v3:Destroy()

		if cFrame then
			createRemovalEffect(cFrame) -- equivalent call inferred; original call site unknown
		end

		return #tagged
	end

	task.spawn(function()
		task.wait(0.3)
		local userId = player and player.UserId or instance and instance.Name

		if not userId then
			return
		end

		countAndManageUserBonbons(userId)
		local model = workspace:WaitForChild("CurrentRoom"):FindFirstChildOfClass("Model")

		if not model then
			return
		end

		local clone = ReplicatedStorage:WaitForChild("Items"):WaitForChild("BonBon"):Clone()

		if not clone then
			return
		end

		local clone_2 = ReplicatedStorage:WaitForChild("Scripts"):WaitForChild("ItemScript"):Clone()
		clone_2.Parent = clone
		CollectionService:AddTag(clone, "CocoaBonbon_" .. userId)
		clone:SetAttribute("PlacedTimestamp", os.time())
		clone:SetAttribute("PlacedBy", userId)
		clone.Parent = model:WaitForChild("Items")
		local humanoid2 = instance:WaitForChild("Humanoid")
		local v2 = -(instance.PrimaryPart.Size.Y / 2 + humanoid2.HipHeight)
		local v3 = clone.PrimaryPart.Size.Y / 2
		local cFrame = instance.HumanoidRootPart.CFrame * CFrame.new(0, v2 + v3, -2)
		local clone2 = ReplicatedStorage.Parts.ItemDrop:Clone()
		clone2.CFrame = cFrame
		clone2.Anchored = true
		clone2.Parent = model

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(50)
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone2, 3)
		clone:SetPrimaryPartCFrame(cFrame)
		local sound2 = Instance.new("Sound")
		sound2.SoundId = "rbxassetid://134780340043151"
		sound2.Volume = 0.3
		sound2.Parent = clone.PrimaryPart
		sound2:Play()
		local SoundUtils = require(ReplicatedStorage.Modules.Audio.SoundUtils)
		SoundUtils.SafeCleanup(sound2)
		local v5 = "Bonbon created! (" .. #CollectionService:GetTagged("CocoaBonbon_" .. userId) .. "/" .. 10 .. ")"
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local displayMessage = ReplicatedStorage2:FindFirstChild("Events") and ReplicatedStorage2.Events:FindFirstChild("DisplayMessage")

		if displayMessage then
			displayMessage:FireClient(player, v5, Color3.fromRGB(200, 235, 255))
		end
	end)
	task.spawn(function()
		while instance and instance.Parent do
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
		Outcome = true
	}
end

function Cocoa.HurtAnimation(instance)
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

Cocoa.SkillCheckStats = {
	Chance = 0.25,
	Decrease = 2,
	Size = 150
}
return Cocoa