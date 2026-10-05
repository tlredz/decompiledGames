local parent = script.Parent
local index = parent.Parent:WaitForChild("Index")
game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
local notif = parent:WaitForChild("Notif")

local function ToggleMenu()
	notif.Visible = false
	UIController.toggle(index)
end

parent.Activated:Connect(ToggleMenu)