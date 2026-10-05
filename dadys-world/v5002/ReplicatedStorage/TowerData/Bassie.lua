local _ = game.ReplicatedStorage.Modules.Zones.BasketDropModeEffects
local Bassie = {}
Bassie.Name = "Bassie"
Bassie.VoteIcon = "rbxassetid://97115131249732"
Bassie.Icon = "rbxassetid://96195017694730"
Bassie.Health = 2
Bassie.MainCharacter = true
Bassie.WalkSpeed = 20
Bassie.RunSpeed = 30
Bassie.DecodeSpeed = 0.85
Bassie.SkillCheckChance = 25
Bassie.SkillCheckValue = 1
Bassie.Stealth = 15
Bassie.Stamina = 175
Bassie.BoundarySize = 50
Bassie.DecodeRank = 2
Bassie.SpeedRank = 5
Bassie.StaminaRank = 4
Bassie.StealthRank = 4
Bassie.SkillCheckRank = 1
Bassie.Ability2Name = "Easter Basket"
Bassie.Ability2Type = "Passive"
Bassie.Ability2Description = "This Toon's basket provides 1 extra inventory slots for carrying more items during gameplay."
Bassie.Ability1Name = "Springful Sharing"
Bassie.Ability1Type = "Active"
Bassie.Ability1Description = "Activate item dropping mode. When active, press item slots to drop items to the ground."
Bassie.Cost = 3500
Bassie.Requirement1 = { "HolidayPoints", 30 }
Bassie.MasterySkin = "VintageBassie"
Bassie.HolidayToon = true
Bassie.HolidayTower = true
Bassie.Easter = true
Bassie.Slot4 = true
Bassie.ActiveAbility = true
Bassie.AbilityIcon = "rbxassetid://73440422545973"
Bassie.AbilityCooldown = 0
Bassie.AbilityDuration = 100
Bassie.CustomAbilitySound = "rbxassetid://99406077964419"
Bassie.ClientOnlySound = true
Bassie.PassiveAbility = true
Bassie.PassiveInventorySlots = 2

function Bassie.SpecialSetupClient(character)
	if not game.Players:GetPlayerFromCharacter(character) then
		print("DEBUG: Failed to get player from character in SpecialSetupClient")
		return
	end

	local success, result = pcall(function()
		return require(game.ReplicatedStorage.Modules.Zones.BasketDropModeEffects)
	end)

	if success then
		result.Init(character)
	else
		print("DEBUG: Failed to require BasketDropModeEffects module:", result)
	end
end

function Bassie.UseActiveAbility(instance, instance2, _, _)
	instance2:WaitForChild("Config")
	local ability1 = instance2:WaitForChild("Abilities"):WaitForChild("Ability1")
	ability1:WaitForChild("Cooldown")
	ability1:WaitForChild("CurrentCooldown")

	if instance2:WaitForChild("Decoding").Value ~= nil then
		return {
			Outcome = false,
			Reason = "Can't use that Ability while extracting!"
		}
	end

	local v2

	if workspace.Info.FloorActive.Value == true then
		local function checkPlayerInElevator(instance3, elevatorHitBox)
			local partsInPart = workspace:GetPartsInPart(elevatorHitBox)

			for _, v3 in ipairs(partsInPart) do
				if v3.Name == "HumanoidRootPart" and v3.Parent:FindFirstChild("Humanoid") and v3.Parent == instance3 then
					return true
				end
			end

			return false
		end

		v2 = checkPlayerInElevator(
			instance2,
			workspace:WaitForChild("Elevators"):WaitForChild("Elevator"):WaitForChild("ElevatorHitBox")
		) and true or false
	else
		v2 = true
	end

	if v2 then
		if instance:GetAttribute("DropMode") then
			instance:SetAttribute("DropMode", false)
			instance2:SetAttribute("DropMode", false)
		end

		return {
			Outcome = false,
			Reason = "You can't use that Ability in the Elevator!"
		}
	else
		local v3 = not instance:GetAttribute("DropMode")
		instance:SetAttribute("DropMode", v3)
		instance2:SetAttribute("DropMode", v3)
		return {
			Outcome = true,
			Reason = v3 and "Item dropping mode activated! Press the item slot you want to drop." or "Item dropping mode deactivated!"
		}
	end
end

function Bassie.HurtAnimation(instance)
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

return Bassie