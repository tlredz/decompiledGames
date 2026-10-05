local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
local parent = script.Parent

local function fadeEventIcon()
	parent.Main.Event.Background.Visible = false
	parent.Main.Event.ImageTransparency = 0.6
end

local function onEventStart(p)
	if p.Priority ~= "Main" then
		return
	end

	local mainEvent = EventInfoService:GetMainEvent()

	if not (mainEvent.EventStartInfo.UI and mainEvent.EventStartInfo.UI.ShopButton) then
		return
	end

	parent.Visible = true

	if mainEvent.EventStartInfo.UI.PrimaryColor then
		local background = parent:WaitForChild("Main"):WaitForChild("Event"):WaitForChild("Background")
		background.BackgroundColor3 = mainEvent.EventStartInfo.UI.PrimaryColor
	else
		local background_2 = parent:WaitForChild("Main"):WaitForChild("Event"):WaitForChild("Background")
		background_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		local background_3 = parent:WaitForChild("Main"):WaitForChild("Event"):WaitForChild("Background")
		background_3.Transparency = 0.6
	end

	local event = parent:WaitForChild("Main"):WaitForChild("Event")
	event.Image = mainEvent.EventStartInfo.UI.ShopButton
	parent.Main.Event.Activated:Connect(function()
		WindowService:ToggleFrame("CurrentEvent")
	end)
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	local remotes = ReplicatedStorage3:WaitForChild("Remotes")
	remotes:WaitForChild("Gameplay"):WaitForChild("ShowRoleSelectNew").OnClientEvent:Connect(fadeEventIcon)
	remotes:WaitForChild("Gameplay"):WaitForChild("ShowRoleSelect").OnClientEvent:Connect(fadeEventIcon)
	remotes:WaitForChild("Gameplay"):WaitForChild("RoleSelect").OnClientEvent:Connect(fadeEventIcon)
end

local function onEventEnd(p)
	if p.Priority ~= "Main" then
		return
	end

	local eventStartInfo = p.EventStartInfo

	if not (eventStartInfo and eventStartInfo.UI and eventStartInfo.UI.ShopButton) then
		parent.Visible = false
	end
end

parent.Visible = false
EventInfoService:OnEventStarted(onEventStart)
EventInfoService:OnEventEnded(onEventEnd)