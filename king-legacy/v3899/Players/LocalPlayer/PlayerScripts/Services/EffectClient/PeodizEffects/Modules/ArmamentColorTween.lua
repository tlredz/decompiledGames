local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
return function(p)
	local object = p.Object
	local color = p.Color

	if object and color then
		TweenService:Create(object, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Color = color
		}):Play()
	end
end