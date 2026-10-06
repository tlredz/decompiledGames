local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
return function(p)
	local group = p.Group
	local color = p.Color

	if not (group and color) then
		return
	end

	for _, part in pairs(group:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Color = color
			}):Play()
		end
	end
end