local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local SocialEventController = {}

function SocialEventController.SignupForEvent(eventId: string)
	if SocialService:GetEventRsvpStatusAsync(eventId) == Enum.RsvpStatus.Going then
		NotificationController.NotifyCenter("You are already subscribed to the event!")
		return false
	end

	local success, result = pcall(function()
		return (SocialService:PromptRsvpToEventAsync(eventId))
	end)

	if not success then
		NotificationController.NotifyCenter("Something went wrong, please try again later!")
		return false
	end

	if result == Enum.RsvpStatus.Going then
		NotificationController.NotifyCenter("You are now subscribed to the event!")
		TelemetryController.SendClientInteraction("eventSignup", {
			eventId = eventId
		})
		return true
	else
		if result == Enum.RsvpStatus.NotGoing then
			NotificationController.NotifyCenter("Signup so you don't miss out!")
			return false
		end

		if result ~= Enum.RsvpStatus.None then
			return false
		end

		NotificationController.NotifyCenter("Signup so you don't miss out!")
		return false
	end
end

function SocialEventController.FrameworkInit() end

function SocialEventController.FrameworkStart() end

return SocialEventController