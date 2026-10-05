local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage2:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local coverPhoto = script.Parent:WaitForChild("CoverPhoto")
local eventPhoto = script.Parent:WaitForChild("EventPhoto")
local basePhoto = script.Parent:WaitForChild("BasePhoto")
local activatedConnection = nil

local function onInitialize()
	local mainEvent = EventInfoService:GetMainEvent()

	if mainEvent and mainEvent.EventStartInfo and mainEvent.EventStartInfo.UI and mainEvent.EventStartInfo.UI.ShopCover then
		eventPhoto.Image = mainEvent.EventStartInfo.UI.ShopCover
		eventPhoto.Visible = true
		basePhoto.Visible = false
		coverPhoto.Visible = false

		if activatedConnection then
			activatedConnection:Disconnect()
		end

		activatedConnection = eventPhoto:WaitForChild("BuyItem").Activated:Connect(function()
			WindowService:ToggleFrame("CurrentEvent")
		end)
	elseif coverPhoto.Visible then
		eventPhoto.Visible = false
		basePhoto.Visible = false
		coverPhoto:WaitForChild("BuyItem").Activated:Connect(function()
			WindowService:ToggleFrame(nil)
		end)
	else
		if activatedConnection then
			activatedConnection:Disconnect()
			activatedConnection = nil
		end

		eventPhoto.Visible = false
		coverPhoto.Visible = false
		basePhoto.Visible = true
	end
end

EventInfoService:OnEventStarted(onInitialize)
EventInfoService:OnEventEnded(onInitialize)
onInitialize()