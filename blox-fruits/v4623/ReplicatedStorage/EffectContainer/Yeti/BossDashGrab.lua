local TweenService = game:GetService("TweenService")
return function(data)
	local root = data.Root
	local cFrame = data.CFrame
	local duration = data.Duration

	if typeof(root) ~= "Instance" or not root:IsA("BasePart") then
		return
	end

	if typeof(cFrame) ~= "CFrame" or typeof(duration) ~= "number" or duration <= 0 then
		return
	end

	TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = cFrame
	}):Play()
end