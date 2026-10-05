local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SocialService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "EventSignupBoard"
})
local EventSignupConfig = require(ReplicatedStorage.Modules.Shared.DB.EventSignup.EventSignupConfig)
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local SocialEventController = require(ReplicatedStorage.Modules.Client.SocialEvent.SocialEventController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:SetupEventSign()
	local config = EventSignupConfig.GetConfig()
	local timerLabel = self.Instance:WaitForChild("TimerFrame"):WaitForChild("TimerLabel")
	local eventIcon = self.Instance:WaitForChild("EventIcon")
	self.eventId = config.eventId
	eventIcon.Image = config.imageId
	timerLabel:SetAttribute("DayHourMinuteClockTargetTime", config.startUnixtimeStamp)
end

function v:ExecuteEventSignup()
	local config = EventSignupConfig.GetConfig()
	SocialEventController.SignupForEvent(config.eventId)
end

function v:Start()
	local signUpButton = self.Instance:WaitForChild("SignUpButton")
	local value = self.Instance:WaitForChild("ClickDetectorRef").Value

	if not value then
		warn("ClickDetector not found")
		return
	end

	self._Janitor:Add(signUpButton.Activated:Connect(function()
		self:ExecuteEventSignup()
	end))
	self._Janitor:Add(value.MouseClick:Connect(function()
		self:ExecuteEventSignup()
	end))
	self:SetupEventSign()
	self._Janitor:Add(DatabaseRemoteConfigController.OnLoaded:Connect(function()
		self:SetupEventSign()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v