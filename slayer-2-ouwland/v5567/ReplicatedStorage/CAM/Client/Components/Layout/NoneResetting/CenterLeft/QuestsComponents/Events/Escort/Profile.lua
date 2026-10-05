local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Types)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
return function(object, p, _: number)
	local v = object:Create("Frame")
	local v2 = {
		Name = "ATitleHolder",
		Size = UDim2.fromScale(1, 0.4),
		BackgroundTransparency = 1
	}
	local v3 = object:Create("UIListLayout")({
		Name = "List",
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left
	})
	local v4

	if p.Icon then
		v4 = object:Create("Frame")({
			Name = "AAImageHolder",
			Size = UDim2.fromScale(1, 1),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundTransparency = 1,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("ImageLabel")({
				Name = "Img",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Image = p.Icon
			}),
			object:Create("UIShadow")({
				BlurRadius = UDim.new(0.5),
				Spread = UDim2.fromScale(-0.3, -0.3),
				Color = Color3.new(0.1, 0.1, 0.1),
				Transparency = 0.5
			})
		})
	end

	do local _values = table.pack(v3, v4, object:Create("TextLabel")({
	Size = UDim2.fromScale(2, 0.9),
	BackgroundTransparency = 1,
	RichText = true,
	TextScaled = true,
	Text = `Escort and protect <b><font {gameSettings.RichTextPopularConfigs.SoroundColorRBX} >{p.Title}!</font></b>`,
	TextColor3 = Color3.new(1, 1, 1),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.SourceSansSemibold
})); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end