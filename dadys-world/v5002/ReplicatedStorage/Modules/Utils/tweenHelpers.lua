local TweenService = game:GetService("TweenService")
local TweenHelpers = {}

function TweenHelpers.playTween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	return tween
end

function TweenHelpers.saveInitials(instance)
	instance:SetAttribute("start_Position", instance.Position)
	instance:SetAttribute("start_Size", instance.Size)
	instance:SetAttribute("start_Rotation", instance.Rotation)
end

return TweenHelpers