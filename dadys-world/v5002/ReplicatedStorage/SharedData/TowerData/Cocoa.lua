local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BonBonLimit = require(ReplicatedStorage2.SharedUtils.BonBonLimit)
local Cocoa = {}
Cocoa.Name = "Cocoa"
Cocoa.Icon = "rbxassetid://96689448192352"
Cocoa.VoteIcon = "rbxassetid://129611138175536"
Cocoa.Render = "rbxassetid://139608428078235"
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
Cocoa.Requirement1 = { "Baskets", 1500 }
Cocoa.Requirement2 = { "MultiResearch", 100, 5 }
Cocoa.MasterySkin = "VintageCocoa"
Cocoa.HolidayToon = true
Cocoa.HolidayTower = true
Cocoa.Easter = true
Cocoa.MasteryRequirements = {
	{
		Name = "SurviveFloorWithToon",
		Requirement = 20,
		Tower = "Yatta"
	},
	{
		Name = "CompleteGenerator",
		Requirement = 65
	},
	{
		Name = "UseItemSpecific",
		Requirement = 35,
		Item = "BonBon"
	},
	{
		Name = "PickUpItem",
		Requirement = 135
	},
	{
		Name = "UseItem",
		Requirement = 120
	},
	{
		Name = "TravelDistance",
		Requirement = 90000
	}
}
Cocoa.ActiveAbility = true
Cocoa.AbilityIcon = "rbxassetid://72532445175661"
Cocoa.AbilityCooldown = 40
Cocoa.AbilityItem = "BonBon"
Cocoa.CustomAbilitySound = "rbxassetid://5115308750"
Cocoa.BonBonExtractionBoost = 0.5
Cocoa.BonBonSpeedBoost = 0.25
Cocoa.BonBonDuration = 10
Cocoa.RightHandBone = "R_hand"

function Cocoa.UseActiveAbility(player, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	instance:WaitForChild("Stats")
	local decoding = instance:WaitForChild("Decoding")
	local humanoid = instance:WaitForChild("Humanoid")
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")

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
	task.spawn(function()
		task.wait(0.3)
		local userId = player.UserId

		if not userId then
			return
		end

		local model = workspace:WaitForChild("CurrentRoom"):FindFirstChildOfClass("Model")

		if not model then
			return
		end

		local clone = ReplicatedStorage3:WaitForChild("Items"):WaitForChild("BonBon"):Clone()

		if not clone then
			return
		end

		local clone_2 = ReplicatedStorage3:WaitForChild("Scripts"):WaitForChild("ItemScript"):Clone()
		clone_2.Parent = clone
		clone:SetAttribute("PlacedBy", userId)
		BonBonLimit.MakeRoom()
		clone.Parent = model:WaitForChild("Items")
		BonBonLimit.Register(clone)
		local humanoid2 = instance:WaitForChild("Humanoid")
		local v = -(instance.PrimaryPart.Size.Y / 2 + humanoid2.HipHeight)
		local v2 = clone.PrimaryPart.Size.Y / 2
		local cFrame = instance.HumanoidRootPart.CFrame * CFrame.new(0, v + v2, -2)
		local clone2 = ReplicatedStorage3.Parts.ItemDrop:Clone()
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
		Audio:Play("Sounds.Toon.Cocoa.Ability.Hit", {
			Volume = 0.3,
			Parent = clone.PrimaryPart
		})
		local v4 = "Bonbon created! (" .. #BonBonLimit.GetPlaced() .. "/" .. BonBonLimit.MAX .. ")"
		local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
		local displayMessage = ReplicatedStorage4:FindFirstChild("Events") and ReplicatedStorage4.Events:FindFirstChild("DisplayMessage")

		if displayMessage then
			displayMessage:FireClient(player, v4, Color3.fromRGB(200, 235, 255))
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
Cocoa.PlayFunctions = {}
return Cocoa