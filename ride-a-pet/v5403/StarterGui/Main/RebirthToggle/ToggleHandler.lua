local parent = script.Parent
local rebirth = parent.Parent:WaitForChild("Rebirth")
game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
local rebirthHintSeen = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("RebirthHintSeen")
local notif = parent:WaitForChild("Notif")

local function ToggleMenu()
	notif.Visible = false

	if UIController.toggle(rebirth) then
		rebirthHintSeen:FireServer()
	end
end

parent.Activated:Connect(ToggleMenu)