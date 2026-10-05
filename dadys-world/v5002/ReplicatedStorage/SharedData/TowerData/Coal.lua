local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local v = {
	Bandage = true,
	HealthKit = true
}
local Coal = {
	Name = "Coal",
	Icon = "rbxassetid://130568522739863",
	VoteIcon = "rbxassetid://74588053251952",
	Render = "rbxassetid://82868598587174",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 10,
	Stamina = 175,
	BoundarySize = 100,
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 4,
	StealthRank = 3,
	SkillCheckRank = 2,
	Ability1Name = "Scout",
	Ability1Type = "Active",
	Ability1Description = "This Toon can sniff out items across the map, causing items to be highlighted for all Toons for 10 seconds. Has a Cooldown of 30.",
	AbilityDuration = 10,
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://124720867458941",
	AbilityCooldown = 30,
	CustomAbilitySound = "",
	CameraMinZoomDistance = 5,
	HolidayToon = true,
	HolidayTower = true,
	Christmas = true,
	MasterySkin = "VintageCoal",
	Cost = 1500,
	Requirement1 = { "Christmas2025Ornaments", 1500 },
	Requirement2 = { "TrinketsOwned", 15 },
	MasteryRequirements = {
		{
			Name = "PickUpCapsule",
			Requirement = 85
		},
		{
			Name = "PickUpItem",
			Requirement = 120
		},
		{
			Name = "ActiveAbilityActivate",
			Requirement = 100
		},
		{
			Name = "SurviveFloorWithToon",
			Requirement = 5,
			Tower = "Pebble"
		},
		{
			Name = "UseItem",
			Requirement = 85
		},
		{
			Name = "TravelDistance",
			Requirement = 90000
		}
	},
	SpecialSetup = function(instance)
		task.spawn(function()
			local rootPart = instance:WaitForChild("RootPart", 5)
			local rootPartRoot = rootPart and rootPart:WaitForChild("root", 5)
			local tail = rootPartRoot and rootPartRoot:WaitForChild("tail", 5)

			if not tail then
				return
			end

			local attachment = Instance.new("Attachment")
			attachment.CFrame = CFrame.new(-1.8, -0.14, 2) * CFrame.Angles(
				-0.3490658503988659,
				0.6981317007977318,
				-1.9198621771937625
			) * CFrame.Angles(0, 3.141592653589793, 0)
			attachment.Name = "LatchedAttachment"
			attachment.Parent = tail
		end)
	end,
	UseActiveAbility = function(origin, instance, _)
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
		Audio:Play("Sounds.Toon.Coal.Ability.ScoutPing", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
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
		local children = model:WaitForChild("Items"):GetChildren()

		for _, v2 in pairs(children) do
			if not v2:GetChildren()[1] or v2:GetAttribute("GigiHoardProp") then
				continue
			end

			local v3, label

			if v2.Name == "Tape" then
				v3 = "Tape"
				label = "TAPES"
			elseif v2.Name == "ResearchCapsule" or v2.Name == "FakeCapsule" then
				v3 = "Research"
				label = "CAPSULE"
			else
				v3 = v[v2.Name] and "Healing" or "Item"
				label = "ITEM"
			end

			HighlightController:BroadcastHighlight(v2, v3, {
				FillColor = Color3.fromRGB(255, 255, 255),
				FillTransparency = 1,
				OutlineColor = Color3.fromRGB(255, 255, 255),
				OutlineTransparency = 0,
				Decay = 10,
				Billboard = {
					Label = label
				},
				Origin = origin
			})
			task.wait()
		end

		return {
			Outcome = true,
			Reason = "Successfully highlighted items"
		}
	end,
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		local blinkingParts = instance:FindFirstChild("BlinkingParts")
		local v2 = {}

		if blinkingParts and #blinkingParts:GetChildren() > 0 then
			for _, objectValue in ipairs(blinkingParts:GetChildren()) do
				if not objectValue:IsA("ObjectValue") then
					continue
				end

				local value = objectValue.Value

				if not value then
					continue
				end

				table.insert(v2, value)

				if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
					table.insert(v2, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
				end

				for _, part in ipairs(v2) do
					if part:IsA("BasePart") then
						part.TextureID = config.HurtTexture.Texture
					end
				end
			end
		else
			local v3 = {
				instance:FindFirstChild("UpperTorso"),
				instance:FindFirstChild("EyeL"),
				instance:FindFirstChild("EyeR")
			}

			for _, v4 in ipairs(v3) do
				if not v4 then
					continue
				end

				table.insert(v2, v4)
				v4.TextureID = config.HurtTexture.Texture
			end
		end

		task.wait(2)

		if instance.Parent ~= nil then
			for _, v3 in ipairs(v2) do
				v3.TextureID = config.NormalTexture.Texture
			end
		end
	end
}
local nows = {}
Coal.PlayFunctions = {
	RPAbility = {
		Cooldown = 20,
		DisplayName = Coal.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function dothing()
				if instance and instance.Parent ~= nil then
					Audio:Play(76703390580042, {
						Parent = instance:WaitForChild("HumanoidRootPart")
					})
				end
			end

			if nows[p] then
				if p2 < tick() - nows[p] then
					nows[p] = tick()
					dothing() -- equivalent call inferred; original call site unknown
				end
			else
				nows[p] = tick()
				dothing() -- equivalent call inferred; original call site unknown
			end
		end
	}
}
return Coal