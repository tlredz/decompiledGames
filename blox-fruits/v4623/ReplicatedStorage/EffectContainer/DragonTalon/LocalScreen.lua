game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
workspace:WaitForChild("_WorldOrigin")
local X = FX:WaitForChild("DragonTalon").X
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local origin = p.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if p.Stage == 1 then
		if game.Lighting:FindFirstChild("ScreenColorDTLocalScreen") then
			game.Lighting.ScreenColorDTLocalScreen:Destroy()
		end

		local clone = X.ScreenColorDT:Clone()
		clone.Name ..= "LocalScreen"
		clone.Parent = game.Lighting
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Brightness = 0,
			Contrast = 0.1,
			Saturation = 0.1,
			TintColor = Color3.fromRGB(231, 191, 170)
		}):Play()
	elseif p.Stage == 2 then
		local screenColorDTLocalScreen = game.Lighting:FindFirstChild("ScreenColorDTLocalScreen")

		if not screenColorDTLocalScreen then
			return
		end

		TweenService:Create(
			screenColorDTLocalScreen,
			TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Contrast = 0.1,
				Saturation = 0.1,
				TintColor = Color3.fromRGB(231, 164, 116)
			}
		):Play()
	elseif p.Stage == 3 then
		local screenColorDTLocalScreen = game.Lighting:FindFirstChild("ScreenColorDTLocalScreen")

		if not screenColorDTLocalScreen then
			return
		end

		TweenService:Create(
			screenColorDTLocalScreen,
			TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}
		):Play()
		task.wait(1)

		if screenColorDTLocalScreen then
			screenColorDTLocalScreen:Destroy()
		end
	end
end