local ReplicatedStorage = game:GetService("ReplicatedStorage")
local machine = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Core"):WaitForChild("machine"))
local req = machine.req(ReplicatedStorage, "Services", "Core", "romodel")
local req2 = machine.req(ReplicatedStorage, "Data", "Core", "viewImports", "basic")
return {
	props = function(options)
		local v = options or {}
		return {
			Background = v.Background or {
				BackgroundTransparency = 1
			},
			Background2 = v.Background2 or {
				Image = req.make(req2.ImageLabel, {
					Size = UDim2.new(1, 0, 1, 0),
					NoAspectRatio = true,
					Image = v.BackgroundImage or "rbxassetid://119320488755115",
					ScaleType = Enum.ScaleType.Crop,
					ImageTransparency = 0,
					ZIndex = 0
				}),
				BlackOverlay = req.make(req2.Element, {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = v.OverlayTransparency or 0.18,
					BorderSizePixel = 0,
					ZIndex = 1
				})
			}
		}
	end
}