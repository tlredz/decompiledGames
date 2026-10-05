local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassIcon = require(ReplicatedStorage.Modules.Client.Item.GamepassIcon)
local ProfileFlagController = require(ReplicatedStorage.Modules.Client.PlayerData.ProfileFlagController)
local ProfileFlags = require(ReplicatedStorage.Modules.Shared.PlayerData.ProfileFlags)
local v = Component.new({
	Tag = "VehicleFacesUnlockedPanel"
})

local function onClose()
	ProfileFlagController.Complete(ProfileFlags.FACES_UNLOCKED_COMPENSATION_03102026)
end

function v:Construct()
	self._janitor = Janitor.new()
end

function v:Start()
	local outerBox = self.Instance:WaitForChild("OuterBox")
	self._janitor:Add(outerBox.Close.Activated:Connect(onClose))
	task.spawn(function()
		local iconImage = outerBox:WaitForChild("IconContainer"):WaitForChild("IconImage")
		iconImage.Image = GamepassIcon.GetSmallIcon(Gamepasses.FACES_UNLOCKED)
	end)
end

function v:Stop()
	self._janitor:Destroy()
end

return v