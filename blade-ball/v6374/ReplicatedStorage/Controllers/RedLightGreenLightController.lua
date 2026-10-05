local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local redLightGreenLight = ReplicatedStorage2.Analyzers.RedLightGreenLight
local localPlayer = Players.LocalPlayer
local redLightGreenLight2 = localPlayer.PlayerGui.RedLightGreenLight
local background = redLightGreenLight2.Background
local banner = redLightGreenLight2.Banner
local status = banner.Status
local v = require3(ReplicatedStorage2.Shared.FastUtils)
local remoteEvent = require3(ReplicatedStorage2.Packages.Net):RemoteEvent("RedLightGreenLight/KillByVoiceDetector")
return {
	currentConnection = nil,
	Start = function(p)
		local function checkAnalyzer()
			if p.currentConnection then
				p.currentConnection:Disconnect()
				p.currentConnection = nil
			end

			local child = redLightGreenLight:FindFirstChild((tostring(localPlayer.UserId)))

			if not child then
				return
			end

			local total = 0
			p.currentConnection = RunService.RenderStepped:Connect(function(dt: number)
				if total <= 1.5 then
					total += dt
					return
				end

				total = 0

				if math.floor(child.PeakLevel * 100) >= 20 then
					remoteEvent:FireServer()
				end
			end)
		end

		checkAnalyzer()
		redLightGreenLight.ChildAdded:Connect(checkAnalyzer)
		redLightGreenLight.ChildRemoved:Connect(checkAnalyzer)
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		ReplicatedStorage2.Remotes.RedLightGreenLightText.OnClientEvent:Connect(function(flag: boolean)
			v.fastTween(status, tweenInfo, {
				TextTransparency = 1
			})
			v.fastTween(banner, tweenInfo, {
				BackgroundTransparency = 1
			})
			background.ImageTransparency = 1

			if flag == nil then
				return
			end

			status.UIScale.Scale = 0
			task.wait(tweenInfo.Time)
			v.fastTween(banner, tweenInfo, {
				BackgroundTransparency = 0
			})
			background.ImageTransparency = 1
			v.fastTween(background, TweenInfo.new(0.175, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				ImageTransparency = 0.35
			})
			task.delay(0.175, function()
				v.fastTween(background, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					ImageTransparency = 1
				})
			end)
			v.fastTween(status, tweenInfo, {
				TextTransparency = 0
			})

			if flag then
				background.ImageColor3 = Color3.fromRGB(255, 0, 34)
				v.fastTween(status.UIScale, tweenInfo2, {
					Scale = 1.25
				})
				status.Text = "Red Light"
				status.UIGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 0, 0))
				})
			else
				background.ImageColor3 = Color3.fromRGB(35, 255, 10)
				v.fastTween(status.UIScale, tweenInfo2, {
					Scale = 1
				})
				status.Text = "Green Light"
				status.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 255, 0))
			end
		end)
	end
}