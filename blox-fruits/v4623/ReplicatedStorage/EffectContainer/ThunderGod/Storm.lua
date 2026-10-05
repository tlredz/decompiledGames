local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local color = Color3.fromRGB(210, 220, 245)
local color2 = Color3.fromRGB(92, 98, 122)
local color3 = Color3.fromRGB(120, 128, 158)
local color4 = Color3.fromRGB(104, 110, 130)
local color5 = Color3.fromRGB(118, 124, 148)
return function(data)
	local root = data.Root

	if typeof(root) ~= "Instance" or not root:IsA("BasePart") then
		return
	end

	local duration = data.Duration or 4
	local range = data.Range or 220
	local v = os.clock() + duration
	local thunderGodStorm = Lighting:FindFirstChild("ThunderGodStorm")

	if thunderGodStorm then
		thunderGodStorm:SetAttribute("Until", v)
		thunderGodStorm:SetAttribute("Range", range)
	else
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "ThunderGodStorm"
		colorCorrectionEffect.Brightness = 0
		colorCorrectionEffect.Contrast = 0
		colorCorrectionEffect.Saturation = 0
		colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
		colorCorrectionEffect:SetAttribute("Until", v)
		colorCorrectionEffect:SetAttribute("Range", range)
		colorCorrectionEffect.Parent = Lighting
		local localPlayer = Players.LocalPlayer
		local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
		local v2 = {
			ClockTime = Lighting.ClockTime,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			FogColor = Lighting.FogColor,
			FogEnd = Lighting.FogEnd,
			Brightness = Lighting.Brightness,
			Cover = not clouds and 0 or clouds.Cover or 0,
			Density = not clouds and 0 or clouds.Density or 0,
			CloudColor = clouds and clouds.Color or Color3.new(1, 1, 1)
		}

		local function applySky(p: number)
			local clockTime = v2.ClockTime
			local v3 = 18.6 - clockTime

			if v3 > 12 then
				v3 -= 24
			elseif v3 < -12 then
				v3 += 24
			end

			Lighting.ClockTime = (clockTime + v3 * p) % 24
			Lighting.Ambient = v2.Ambient:Lerp(color2, p)
			Lighting.OutdoorAmbient = v2.OutdoorAmbient:Lerp(color3, p)
			Lighting.FogColor = v2.FogColor:Lerp(color5, p)
			Lighting.FogEnd = v2.FogEnd + (2600 - v2.FogEnd) * p
			Lighting.Brightness = v2.Brightness * (1 - p * 0.15000000000000002)

			if clouds then
				clouds.Cover = v2.Cover + (0.9 - v2.Cover) * p
				clouds.Density = v2.Density + (0.72 - v2.Density) * p
				clouds.Color = v2.CloudColor:Lerp(color4, p)
			end
		end

		local function nearby()
			local character = localPlayer and localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and root.Parent) then
				return false
			end

			local range2 = colorCorrectionEffect:GetAttribute("Range")
			local magnitude = (humanoidRootPart.Position - root.Position).Magnitude

			if typeof(range2) ~= "number" then
				range2 = range
			end

			return magnitude <= range2
		end

		task.spawn(function()
			local v3 = 0

			while colorCorrectionEffect.Parent do
				local now = os.clock()
				local attribute = colorCorrectionEffect:GetAttribute("Until")

				if typeof(attribute) ~= "number" or attribute <= now then
					break
				end

				v3 = math.clamp(v3 + math.sign((nearby() and 1 or 0) - v3) * 0.01388888888888889, 0, 1)
				applySky(v3)
				colorCorrectionEffect.Brightness = v3 * -0.04
				colorCorrectionEffect.Contrast = v3 * 0.05
				colorCorrectionEffect.Saturation = v3 * -0.16
				colorCorrectionEffect.TintColor = Color3.new(1, 1, 1):Lerp(color, v3)
				RunService.Heartbeat:Wait()
			end

			local function restoreSky()
				local lastTime = os.clock()

				while os.clock() - lastTime < 1.2 do
					applySky(1 - (os.clock() - lastTime) / 1.2)
					RunService.Heartbeat:Wait()
				end

				applySky(0)
			end

			if not colorCorrectionEffect.Parent then
				restoreSky()
				return
			end

			task.spawn(restoreSky)
			local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.2), {
				Brightness = 0,
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.new(1, 1, 1)
			})
			tween.Completed:Connect(function()
				colorCorrectionEffect:Destroy()
			end)
			tween:Play()
		end)
	end
end