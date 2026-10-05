local Icon = require(game.ReplicatedStorage.Modules:WaitForChild("Icon"))
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local prompts = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompts")
local Network = require(ReplicatedStorage.Modules.Network)
local v = Network:invoke("FetchSettings")
local v2 = Icon.new():setImage("rbxassetid://15604215436", "deselected"):setImage(
	"rbxassetid://15604215554",
	"selected"
):autoDeselect(false):bindEvent(
	"selected",
	function()
		Network:fire("ChangeSetting", "MuteMusic", true)
	end
):bindEvent(
	"deselected",
	function()
		Network:fire("ChangeSetting", "MuteMusic", false)
	end
)

if v.MuteMusic then
	v2:select(nil, true)
end

Icon.new():setImage("rbxassetid://15604228334"):oneClick():bindEvent("deselected", function()
	_G.ShowEmotesMenu(true)
end)
local v3 = Icon.new()
v3:oneClick(true)
v3:setImage(97651580914952)
v3:align("Right")
v3:setOrder(1)
v3:setImageScale(0.4)
v3.selected:Connect(function()
	prompts.GameEvents.Visible = not prompts.GameEvents.Visible
end)
task.spawn(function()
	local gameEvents = prompts:WaitForChild("GameEvents")

	if not gameEvents:GetAttribute("UnseenCount") then
		gameEvents:GetAttributeChangedSignal("UnseenCount"):Wait()
	end

	local unseenCount = gameEvents:GetAttribute("UnseenCount")

	if unseenCount > 0 then
		for _ = 1, unseenCount do
			v3:notify()
		end
	end
end)
local v4 = Icon.new()
v4:oneClick(true)
v4:setImage(129604787551062)
v4:align("Right")
v4:setOrder(3)
v4.selected:Connect(function()
	prompts.MatchHistory.Visible = not prompts.MatchHistory.Visible
end)