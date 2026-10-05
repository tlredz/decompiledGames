game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ReplicatedStorage:WaitForChild("ModuleScript")
local topbar = ReplicatedStorage:WaitForChild("OtherEvent"):WaitForChild("GuiEvents"):WaitForChild("Topbar")
local icon = ReplicatedStorage.Modules:WaitForChild("Icon")
local module = require(icon)
playerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
local v = module.new():setName("Update Log"):setImage(6022668882):setCaption("Update Logs"):bindEvent(
	"selected",
	function()
		topbar:Fire("UpdateLog", "Enable")
	end
):bindEvent(
	"deselected",
	function()
		topbar:Fire("UpdateLog", "Disable")
	end
)
topbar.Event:Connect(function(p, p2)
	if p == "UpdateLog_Set" and p2 == "Disable" then
		v:deselect()
	end
end)