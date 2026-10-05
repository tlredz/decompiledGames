local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local textSize = Platform_Handler.Platform.Value == "Mobile" and 20 or 16
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
local v2 = {
	Echo = Color3.new(0.55, 0.55, 0.55),
	Success = Color3.fromRGB(130, 255, 160),
	Denied = Color3.fromRGB(255, 130, 130),
	Note = Color3.new(0.9, 0.9, 0.9)
}
local info = faye.Info(0.2)
return function(object, layoutOrder: number, p2)
	return object:Create("TextLabel")({
		Name = string.format("%04d", layoutOrder),
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = p2.Text,
		TextColor3 = v2[p2.Kind] or v2.Note,
		TextTransparency = object:Animation(0, info, {
			From = 1
		}),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = rbxassetfontsfamiliesSourceSansProjson,
		TextSize = textSize
	})
end