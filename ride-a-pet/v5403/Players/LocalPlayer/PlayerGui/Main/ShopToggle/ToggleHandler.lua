local parent = script.Parent
local products = parent.Parent:WaitForChild("Products")
game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
local notif = parent:WaitForChild("Notif")

local function ToggleMenu()
	notif.Visible = false
	UIController.toggle(products)
end

parent.Activated:Connect(ToggleMenu)