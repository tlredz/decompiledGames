local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local _ = {
	Blur = {
		Size = 5
	},
	ColorCorrection = {
		Brightness = 0.25,
		Contrast = -0.1,
		Saturation = -0.5
	}
}
return function(list)
	local _, v, _ = unpack(list)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", currentCamera)
	local blurEffect = Instance.new("BlurEffect", currentCamera)
	local Debris = game:GetService("Debris")
	Debris:AddItem(colorCorrectionEffect, v)
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(blurEffect, v)
	local lastTime = tick()

	while tick() - lastTime < v do
		RunService.RenderStepped:Wait()
	end
end