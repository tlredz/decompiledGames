local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
return {
	point = function(parent, color: Color3?, value: number?, value2: number?, p: number?, value3: number?)
		local v = value or 1
		local pointLight = Instance.new("PointLight")
		pointLight.Enabled = true
		pointLight.Color = color or Color3.fromRGB(105, 195, 255)
		pointLight.Range = value2 or 10
		pointLight.Brightness = value3 or 2
		pointLight.Parent = parent
		TweenService:Create(pointLight, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Brightness = 0,
			Range = p or (value2 or 10) * 1.5
		}):Play()
		Debris:AddItem(pointLight, v)
		return pointLight
	end
}