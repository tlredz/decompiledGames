local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "EventSignupButton"
})
local v2 = false
local v3 = false

function v:Construct()
	self._Janitor = Janitor.new()
	local SocialEventController = require(ReplicatedStorage.Modules.Client.SocialEvent.SocialEventController)
	v2 = SocialEventController
	local EventSignupConfig = require(ReplicatedStorage.Modules.Shared.DB.EventSignup.EventSignupConfig)
	v3 = EventSignupConfig
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		local config = v3.GetConfig()
		v2.SignupForEvent(config.eventId)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v