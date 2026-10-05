local TweenService = game:GetService("TweenService")
local Tween = {}

function Tween.new(p, p2, p3)
	return TweenService:Create(p, p2, p3)
end

function Tween:Play(p, p2, p3, p4)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()

	if p4 then
		tween.Completed:Wait()
	end
end

function Tween.PlayTween(_, object, p)
	object:Play()

	if p then
		object.Completed:Wait()
	end
end

return Tween