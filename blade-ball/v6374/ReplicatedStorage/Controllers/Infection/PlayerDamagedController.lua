local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local hurtEffect = Players.LocalPlayer.PlayerGui:WaitForChild("HurtEffect")
local tweens = {}
local PlayerDamagedController = {}

function PlayerDamagedController.Start(_) end

function PlayerDamagedController.TakeDamage(_, p: number)
	local v = math.sqrt(p / 5)
	local tween = TweenService:Create(
		hurtEffect.Overlay,
		TweenInfo.new(v, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			ImageTransparency = 1
		}
	)
	table.insert(tweens, tween)
	hurtEffect.Overlay.ImageTransparency = 0
	hurtEffect.Enabled = true
	task.wait(v * 0.25)
	tween:Play()
	tween.Completed:Once(function()
		local index = table.find(tweens, tween)

		if index then
			table.remove(tweens, index)
		end

		hurtEffect.Enabled = false
	end)
	return tween.Completed
end

return PlayerDamagedController