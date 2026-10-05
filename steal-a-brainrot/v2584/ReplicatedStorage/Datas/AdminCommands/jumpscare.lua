local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage.Packages.Trove)
return {
	name = "jumpscare",
	icon = "rbxassetid://70977280827000",
	cooldown = 60,
	description = "BOO!",
	effects = {
		Victim = function()
			local localPlayer = Players.LocalPlayer
			local currentCamera = workspace.CurrentCamera
			local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
			local model = BrainrotAssets.getModel("Tim Cheese")
			local timCheese = ReplicatedStorage.Sounds.Animals["Tim Cheese"]
			local idle = ReplicatedStorage.Animations.Animals["Tim Cheese"].Idle

			if not (localPlayer and currentCamera and model and timCheese and idle) then
				return
			end

			local maid = Trove.new()
			local v = maid:Add(model:Clone())

			if not v.PrimaryPart then
				maid:Destroy()
				return
			end

			local v2 = maid:Add(timCheese:Clone())
			v2.Volume = 10
			v2.Parent = v.PrimaryPart
			local v3 = maid:Add(Instance.new("ColorCorrectionEffect"))
			v3.Saturation = -0.1
			v3.Brightness = -0.1
			v3.Contrast = 0
			v3.Parent = currentCamera
			local v4 = maid:Add(Instance.new("DepthOfFieldEffect"))
			v4.Enabled = true
			v4.Parent = currentCamera
			v4.FocusDistance = 8
			v4.FarIntensity = 1
			v4.NearIntensity = 0
			v4.InFocusRadius = 2
			local screenGui = Instance.new("ScreenGui")
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = 1
			frame.Parent = screenGui
			v.Parent = currentCamera
			local cframe = CFrame.Angles(0, 3.141592653589793, 0)
			local v5 = CFrame.new(0, -20, -15) * cframe
			local v6 = CFrame.new(0, -6, -8) * cframe
			TweenService:Create(
				v4,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 4.3),
				{
					FarIntensity = 0,
					NearIntensity = 0,
					InFocusRadius = 0
				}
			):Play()
			local animationController = v:FindFirstChildOfClass("AnimationController")

			if animationController then
				local v7 = maid:Add(animationController:LoadAnimation(idle))
				v7.Looped = true
				v7:Play()
			end

			TweenService:Create(v3, TweenInfo.new(0.3), {
				Contrast = 0.2
			}):Play()
			TweenService:Create(frame, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			task.delay(0.1, function()
				TweenService:Create(frame, TweenInfo.new(0.4), {
					BackgroundTransparency = 1
				}):Play()
			end)
			v2:Play()
			local lastTime = os.clock()
			maid:Add((RunService.RenderStepped:Connect(function()
				debug.profilebegin("Jumpscare:Update")
				local v7 = os.clock() - lastTime
				local v8

				if v7 < 0.3 then
					local v9 = v7 / 0.3
					v8 = v5:Lerp(v6, v9 * v9 * v9)
				elseif v7 < 4.3 then
					v8 = v6 * CFrame.new(math.random(-5, 5) / 100, math.random(-5, 5) / 100, math.random(-5, 5) / 100)
				elseif v7 < 4.8 then
					v8 = v6:Lerp(v5, (math.sin((v7 - 0.3 - 4) / 0.5 * 1.5707963267948966)))
				else
					maid:Destroy()
					debug.profileend()
					return
				end

				v:PivotTo(currentCamera.CFrame * v8)
				debug.profileend()
			end)))
		end
	}
}