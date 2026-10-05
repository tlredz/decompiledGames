local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local v = { TweenInfo.new(0.2, Enum.EasingStyle.Linear) }

local function InRange(p, p2)
	if (p - workspace.CurrentCamera.CFrame.Position).Magnitude < p2 then
		return true
	end
end

return function(p)
	if typeof(p.HRP) ~= "Instance" then
		return
	end

	local iceBlock = p.IceBlock
	local total = 0

	while not iceBlock.Value do
		total += task.wait(0.1)

		if total > 5 then
			return
		end
	end

	local value = iceBlock.Value

	if (value.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 100 then
		Util.Sound:Play("Ice_freeze", value.Position)
	end

	local changedConnection = nil
	changedConnection = iceBlock.Changed:Connect(function()
		if value.Parent then
			Util.Sound:Play("Ice_unfreeze", value.Position)
			value.Mist.Enabled = false
			value.Trail.Enabled = false
			TweenService:Create(value, v[1], {
				Transparency = 1,
				Size = value.Size * 1.25
			}):Play()
		end

		changedConnection:Disconnect()
		task.delay(1, function()
			value:Destroy()
		end)
	end)
end