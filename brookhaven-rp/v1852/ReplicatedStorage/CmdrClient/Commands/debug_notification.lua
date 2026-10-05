return {
	Name = "debug_notification",
	Aliases = {},
	Description = "Shows a notification of the given type. Types: notify, center, centerSmall, slide, alwaysVisible, editor",
	Group = "Debug",
	Args = {
		{
			Type = "notificationType",
			Name = "type",
			Description = "Notification type to show"
		},
		{
			Type = "string",
			Name = "text",
			Description = "Notification text (quote multi-word messages)",
			Default = "Test notification",
			Optional = true
		}
	},
	ClientRun = function(_, p: string, p2: string?)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
		local v = p2 == nil and "Test notification" or p2

		if p == "notify" then
			NotificationController.Notify(v)
		elseif p == "center" then
			NotificationController.NotifyCenter(v)
		elseif p == "centerSmall" then
			NotificationController.NotifyCenterSmall(v)
		elseif p == "slide" then
			NotificationController.SlideNotification(v)
		elseif p == "alwaysVisible" then
			NotificationController.NotifyCenterAlwaysVisible(v)
		elseif p == "editor" then
			NotificationController.NotifyEditor(v)
		else
			return (`Unknown notification type: {p}`)
		end

		return (`Showed {p} notification`)
	end
}