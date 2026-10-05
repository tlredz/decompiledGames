local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
local parent = script.Parent
local centerIcon = parent:WaitForChild("CenterIcon")

local function onEventStart()
	local mainEvent = EventInfoService:GetMainEvent()

	if not (mainEvent.EventStartInfo.UI and mainEvent.EventStartInfo.UI.ShopButton) then
		return
	end

	parent.Visible = true
	centerIcon.Image = mainEvent.EventStartInfo.UI.ShopButton
	centerIcon.Visible = true

	if mainEvent.EventStartInfo.UI.PrimaryColor then
		local background = parent:WaitForChild("Background")
		background.BackgroundColor3 = mainEvent.EventStartInfo.UI.PrimaryColor
	else
		local background_2 = parent:WaitForChild("Background")
		background_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		local background_3 = parent:WaitForChild("Background")
		background_3.Transparency = 0.6
	end

	parent.Activated:Connect(function()
		WindowService:ToggleFrame("CurrentEvent")
	end)
end

parent.Visible = false
EventInfoService:OnMainEventStarted(onEventStart)
EventInfoService:OnEventEnded(function(p)
	if p.Priority ~= "Main" then
		return
	end

	local eventStartInfo = p.EventStartInfo

	if not (eventStartInfo and eventStartInfo.UI and eventStartInfo.UI.ShopButton) then
		parent.Visible = false
	end
end)