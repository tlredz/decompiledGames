local PerkService = require(game.ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("PerkService"))
require(game.ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("DeviceService"))
local UserInputService = game:GetService("UserInputService")
local perk = script.Parent.Parent:WaitForChild("Game"):WaitForChild("Perk")

local function onPreferredInputChanged()
	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		perk.Visible = false
		return
	end

	PerkService.PerkButton = perk
	perk.Visible = PerkService.PerkIsActive
end

if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
	perk.Visible = false
else
	PerkService.PerkButton = perk
	perk.Visible = PerkService.PerkIsActive
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(onPreferredInputChanged)