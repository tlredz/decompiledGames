local PerkService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
game:GetService("ContextActionService")
local _ = { Enum.KeyCode.Q, Enum.KeyCode.ButtonR1 }
PerkService.PerkIsActive = false
PerkService.PerkActivated = script:WaitForChild("PerkActivated")
PerkService.PerkButton = nil

function PerkService.GetEquippedPerk(_)
	return game.Players.LocalPlayer:GetAttribute("EquippedPerk") or "Footsteps"
end

function PerkService.ActivatePerk(_)
	PerkService.PerkActivated:Fire()
end

local function GeneratePerkInfo(p: string)
	local perk = Sync.Perks[p]
	return {
		DisplayName = perk.Name,
		Image = perk.Image,
		Passive = not perk.Active,
		Cooldown = perk.Cooldown,
		ActiveTime = perk.ActiveTime,
		Charges = perk.Charges
	}
end

function PerkService.GetPerkInfo(_, p: string)
	local perk = Sync.Perks[p]
	return {
		DisplayName = perk.Name,
		Image = perk.Image,
		Passive = not perk.Active,
		Cooldown = perk.Cooldown,
		ActiveTime = perk.ActiveTime,
		Charges = perk.Charges
	}
end

return PerkService