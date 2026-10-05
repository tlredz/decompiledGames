local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Globals.Constants)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
return {
	Start = function()
		Remotes.Broadcasts.RaiseNotice.OnClientEvent:Connect(function(text: string, seconds: number?)
			Toast.Show({
				Lane = "Banner",
				Text = text,
				Seconds = seconds,
				Color = Color3.new(1, 1, 1),
				ShowShadow = true
			})
		end)
	end
}