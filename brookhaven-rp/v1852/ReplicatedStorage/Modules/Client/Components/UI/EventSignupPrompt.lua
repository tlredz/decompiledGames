local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "EventSignupPrompt"
})
local SocialEventController = require(ReplicatedStorage.Modules.Client.SocialEvent.SocialEventController)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local EventSignupConfig = require(ReplicatedStorage.Modules.Shared.DB.EventSignup.EventSignupConfig)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:AddPromise(InteractionPrompt:WaitForInstance(self.Instance):andThen(function(interactionPrompt)
		self._interactionPrompt = interactionPrompt
		self._Janitor:Add(interactionPrompt.Interacted:Connect(function()
			local config = EventSignupConfig.GetConfig()
			SocialEventController.SignupForEvent(config.eventId)
		end))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v