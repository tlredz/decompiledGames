local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function ToggleFireBorder(p)
	local fireOutline = Client.Interface.FireOutline

	if not p then
		TweenService:Create(fireOutline, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageTransparency = 1
		}):Play()
		return
	end

	Client.Sound.Play("OnFire", {
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.4
		}
	})
	fireOutline.ImageTransparency = 1
	fireOutline.Visible = true
	TweenService:Create(fireOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		ImageTransparency = 0
	}):Play()
end

Client.Events.ToggleFireBorder:Connect(function(p)
	ToggleFireBorder(p)
end)
return {}