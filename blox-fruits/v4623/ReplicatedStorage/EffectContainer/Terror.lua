local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Util").BoatTween.Lerps)
local boatTween = Util.BoatTween
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
local _ = Util.Spring

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local clone = nil
local count = 0
return function(player)
	local character = player.Character
	local caster = player.Caster
	local player2 = player.Player

	if not player2 then
		return
	end

	if character and character.Parent ~= nil and caster and caster.Parent ~= nil then
		local head = character:FindFirstChild("Head")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if head and humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 2000 then
				return
			end

			local v = game.Players.LocalPlayer.Character and character == game.Players.LocalPlayer.Character and true or false
			local clone2 = script.TerrorAura:Clone()
			clone2.CFrame = humanoidRootPart.CFrame
			local motor6D = Instance.new("Motor6D")
			motor6D.Parent = clone2
			motor6D.Part0 = humanoidRootPart
			motor6D.Part1 = clone2
			clone2.Parent = _WorldOrigin
			local headAttach = clone2.HeadAttach
			headAttach.Parent = head

			for _, child in pairs(headAttach:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			local v2 = true
			Util.Sound:Play("TerrorHeartbeat", humanoidRootPart, nil, 1, 0.7)

			if v then
				count += 1
				Effect.new("ColorCorrection"):replicate({
					TintColor = Color3.fromRGB(255, 255, 255),
					Saturation = -1,
					Brightness = 0,
					Contrast = 0,
					FadeIn = 0.25,
					FadeOut = 0.25,
					Lifetime = 0.5
				})
				local playerGui = (clone == nil or clone.Parent == nil) and game.Players.LocalPlayer.PlayerGui

				if playerGui then
					clone = script.TerrorGui:Clone()
					clone.Parent = playerGui
				end

				local currentCamera = workspace.CurrentCamera
				tick()
				local v3 = 200
				local v4 = 0.016666666666666666
				local v5 = "terrorCam" .. math.random(1, 1000000)
				RunService:BindToRenderStep(v5, Enum.RenderPriority.Camera.Value + 1, function()
					v3 = math.max(0, v3 - 10)
					local currentCamera2 = currentCamera
					local fieldOfView = currentCamera.FieldOfView
					local v7 = 70 - v3 / 6 * 1.15 * math.cos(v3 / 6)
					local v8 = v4 * 60 * 0.1
					currentCamera2.FieldOfView = fieldOfView + (v7 - fieldOfView) * v8
					v4 = RunService.RenderStepped:Wait()
				end)
				task.delay(0.5, function()
					RunService:UnbindFromRenderStep(v5)

					if currentCamera then
						currentCamera.FieldOfView = 70
					end
				end)
				task.spawn(function()
					while task.wait() and v2 do
						workspace.Gravity = 261.5999346
					end

					workspace.Gravity = 196.2
				end)
			end

			local v3 = count

			repeat
				task.wait(0.5)
			until caster.Parent == nil or player2:GetAttribute("TerrorEffect") == nil

			v2 = false

			if clone2 then
				for _, emitter in pairs(clone2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			if clone and v and count == v3 then
				local v4 = boatTween:Create(clone.TerrorOverlay:FindFirstChild("ImageLabel"), {
					Time = 1,
					EasingStyle = "Sine",
					DelayTime = 0,
					RepeatCount = 0,
					Reverses = false,
					EasingDirection = "Out",
					Goal = {
						ImageTransparency = 1
					},
					StepType = "RenderStepped"
				})
				v4.Completed:Connect(function()
					if clone then
						clone:Destroy()
					end

					clone = nil
					v4:Destroy()
				end)
				v4:Play()
			end
		end
	end
end