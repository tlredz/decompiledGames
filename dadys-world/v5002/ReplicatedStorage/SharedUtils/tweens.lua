local TweenService = game:GetService("TweenService")
local Tweens = {}

function Tweens.playTween(_, p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	return tween
end

function Tweens.infiniteRotate(_, p, p2)
	task.spawn(function()
		local v = nil

		local function rotationLoop()
			p.Rotation = -180
			v = TweenService:Create(p, p2, {
				Rotation = 180
			})
			v:Play()
			task.wait(p2.Time)
			v:Destroy()
		end

		while p.Parent ~= nil do
			rotationLoop()
		end
	end)
end

return Tweens