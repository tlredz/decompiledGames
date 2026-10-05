local TweenService = game:GetService("TweenService")
local PoisonClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
local v = true
Client.Events.PoisonBorderFlash:Connect(function()
	if not v then
		return
	end

	v = false
	local clone = Client.Interface.PoisonBorder:Clone()
	clone.ImageTransparency = 1
	clone.Visible = true
	clone.Name = "PoisonBorderTemp"
	clone.Parent = localPlayer.PlayerGui.Interface
	TweenService:Create(clone, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		ImageTransparency = 0
	}):Play()
	wait(0.35)

	if clone then
		TweenService:Create(clone, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageTransparency = 1
		}):Play()
	end

	task.spawn(function()
		wait(0.141)
		v = true

		if clone then
			clone:Destroy()
		end
	end)
end)

function PoisonClient.Init() end

return PoisonClient