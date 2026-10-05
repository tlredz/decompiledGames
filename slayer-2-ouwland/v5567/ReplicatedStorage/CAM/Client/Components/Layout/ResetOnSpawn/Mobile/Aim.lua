local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local info = faye.Info(0.15)
return function(object)
	local v = nil
	local value = object:Value(false)
	local position = object:Value(UDim2.new())
	object:Connect(RunService.RenderStepped, function()
		local v2 = v
		local aimActive = Platform_Handler.AimActive()
		value:Set(aimActive)

		if not aimActive or v2 == nil then
			return
		end

		local v3 = Platform_Handler.AimPoint() - v2.AbsolutePosition
		position:Set(UDim2.fromOffset(v3.X, v3.Y))
	end)
	return object:Create("Frame")({
		Name = "Aim",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Active = false,
		function(p)
			v = p
		end,
		object:State(function(callback, object2)
			if callback(value) == true then
				return object2:Create("CanvasGroup")({
					Name = "Dot",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = position,
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					GroupTransparency = object2:Animation(0.25, info, {
						From = 1
					}),
					OnClean = {
						GroupTransparency = object2:Animation(1, info)
					},
					Active = false,
					object2:Create("Frame")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(12, 12),
						BackgroundColor3 = Color3.new(1, 1, 1),
						object2:Create("UICorner")({
							CornerRadius = UDim.new(1, 0)
						}),
						object2:Create("UIStroke")({
							Thickness = 1,
							Color = Color3.new(),
							Transparency = 0.5
						})
					})
				})
			end

			return nil
		end)
	})
end