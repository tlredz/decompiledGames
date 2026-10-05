local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
return function(data)
	local folder = data.Folder
	local v = data.Number == nil and 0.025 or data.Number or 0.025
	local disableTween = data.DisableTween or false
	local tweeninfo = data.tweeninfo or TweenInfo.new(v, Enum.EasingStyle.Sine)
	local childrenByName = {}

	for _, child in pairs(folder:GetChildren()) do
		childrenByName[tonumber(child.Name)] = child
	end

	local blurEffect = Instance.new("BlurEffect", workspace.CurrentCamera)
	blurEffect.Size = data.Blur or 0

	local function excuteframes()
		for _, v2 in ipairs(childrenByName) do
			local currentCamera = workspace.CurrentCamera
			local clone = v2:Clone()
			clone.Parent = currentCamera

			if disableTween then
				task.wait(v)
				clone:Destroy()
			else
				game.TweenService:Create(blurEffect, tweeninfo, {
					Size = 0
				}):Play()
				local v3 = game.TweenService:Create(clone, tweeninfo, {
					Brightness = 0,
					Contrast = 0,
					Saturation = 0,
					TintColor = Color3.new(1, 1, 1)
				})
				v3:Play()
				v3.Completed:Wait()
				clone:Destroy()
			end
		end

		blurEffect:Destroy()
	end

	if data.yeild then
		excuteframes()
	else
		task.spawn(excuteframes)
	end
end