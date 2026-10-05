local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local BoatTween = require(ReplicatedStorage.CAM.Client.Modules.Effects.BoatTween)
local faye = require(ReplicatedStorage.Packages.faye)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Camera_Traffic_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler)
local DartShootingUI = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Training.DartShootingUI)
local PlatformLeniency = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.PlatformLeniency)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local currentCamera = workspace.CurrentCamera
local TargetShooting = {}
local maid = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	local v = maid
	maid = nil
	RunService:UnbindFromRenderStep("targetshooting_cam")

	if Camera_Traffic_Handler.TargetShooting then
		Camera_Traffic_Handler.TargetShooting = false
	end

	if v then
		v:Destroy()
	end
end

local v = {
	x = { -15, 15 },
	y = { -7, 7 }
}
v.x[3] = v.x[2] - v.x[1]
v.y[3] = v.y[2] - v.y[1]
local v2 = {
	x = { -30, 30 },
	y = { -30, 30 }
}
v2.x[3] = v2.x[2] - v2.x[1]
v2.y[3] = v2.y[2] - v2.y[1]
local v3 = {
	FillColor = Color3.new(1, 1, 1),
	FillTransparency = 0.2,
	OutlineColor = Color3.new(1, 1, 1),
	OutlineTransparency = 0
}
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.fromRGB(255, 0, 0)
local random = Random.new()
local SoundService = game:GetService("SoundService")

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaySound(instance, p)
	if instance == nil then
		return
	end

	local clone = instance:Clone()
	clone.Parent = p or SoundService
	clone:Play()
	DebrisModule:AddItem(clone, (clone.TimeLength > 0 and clone.TimeLength or 3) + 0.2)
end

function TargetShooting.Do(p, _, _, p2)
	teardown() -- equivalent call inferred; original call site unknown

	if p2 == nil then
		SignalEvent.ToServer("training_signaler", "Stop", false)
		return
	end

	maid = faye.new()
	local v4 = maid
	local parent = p2.Parent.Parent
	local cFrame = parent.Center.CFrame
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still"))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay"))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR"))
	local folder = Instance.new("Folder")
	folder.Name = "TargetShootingDarts"
	folder.Parent = workspace.Debree
	maid:Add(folder)
	local camera = parent:FindFirstChild("Camera")

	if camera then
		Camera_Traffic_Handler.TargetShooting = true
		local total = 0
		local total2 = 0
		RunService:BindToRenderStep("targetshooting_cam", Enum.RenderPriority.Camera.Value, function()
			if Camera_Traffic_Handler.Equipped_Hirearchy ~= "TargetShooting" then
				return
			end

			local viewportSize = currentCamera.ViewportSize
			local mouseLocation = UserInputService:GetMouseLocation()
			local v5 = math.clamp((mouseLocation.X - viewportSize.X / 2) / (viewportSize.X / 2), -1, 1)
			local v6 = math.clamp((mouseLocation.Y - viewportSize.Y / 2) / (viewportSize.Y / 2), -1, 1)
			total += (v5 - total) * 0.1
			total2 += (v6 - total2) * 0.1
			currentCamera.CFrame = camera.CFrame * CFrame.new(total * 0.4, -total2 * 0.4, 0) * CFrame.Angles(
				-total2 * 0.08726646259971647,
				-total * 0.08726646259971647,
				0
			)
		end)
	end

	local misc = p.PlayerGui:WaitForChild("Misc")
	local flag = false
	local v5 = false
	local platformLeniency = PlatformLeniency()
	local v7 = 3 * platformLeniency
	local v8 = 0.8 * platformLeniency
	local dartShootingUI = DartShootingUI(misc, {
		Thread = maid,
		Stop = function(flag2: boolean)
			if flag then
				return
			end

			flag = true
			v5 = true
			SignalEvent.ToServer("training_signaler", "Stop", flag2 == true)
		end
	})
	task.spawn(function()
		while v4.IsActive and not v5 do
			local v10 = cFrame * CFrame.new(
				random:NextNumber() * v.x[3] + v.x[1],
				random:NextNumber() * v.y[3] + v.y[1],
				0
			)
			local clone = script.DarBoard:Clone()
			clone.Parent = folder
			local cloneRoot = clone:FindFirstChild("Root") or clone.PrimaryPart
			local clickDetector = Instance.new("ClickDetector", cloneRoot)
			clickDetector.MaxActivationDistance = 200
			local highlight = nil
			clickDetector.MouseHoverEnter:Connect(function()
				if highlight ~= nil then
					highlight:Destroy()
					highlight = nil
				end

				highlight = Instance.new("Highlight", clone)

				for k, v12 in v3 do
					highlight[k] = v12
				end
			end)
			clickDetector.MouseHoverLeave:Connect(function()
				if highlight ~= nil then
					highlight:Destroy()
					highlight = nil
				end
			end)
			local flag2 = false
			local v12 = false
			local v14 = clone

			local function Delete()
				if flag2 then
					return
				end

				flag2 = true
				local v15 = cloneRoot

				for i, part in v14:GetChildren() do
					if not (part ~= v14.PrimaryPart and part:IsA("BasePart")) then
						continue
					end

					part.CanCollide = false
					part.Anchored = false
					part.AssemblyLinearVelocity = v15.CFrame:VectorToWorldSpace((Vector3.new(
						random:NextNumber() * v2.x[3] + v2.x[1],
						random:NextNumber() * v2.y[3] + v2.y[1],
						0
					)))
				end

				DebrisModule:AddItem(v14, 3)
			end

			local v15 = clone

			local function FadeOutHighlight(flag3: boolean)
				if highlight == nil then
					highlight = Instance.new("Highlight", v15)

					for k, v16 in v3 do
						highlight[k] = v16
					end
				end

				local v16 = highlight
				highlight = nil
				local v17 = flag3 and color or color2
				v16.FillColor = v17
				v16.OutlineColor = v17
				local v18 = BoatTween:Create(v16, {
					Time = 0.3,
					Goal = {
						FillTransparency = 1,
						OutlineTransparency = 1
					},
					EasingStyle = "Quad",
					EasingDirection = "Out"
				})
				v18:Play()
				task.defer(function()
					v18.Completed:Wait()
					v18:Destroy()

					if v16 then
						v16:Destroy()
					end
				end)
			end

			local v16 = cloneRoot

			local function FireDart(callback)
				local clone2 = script.Dart:Clone()
				local root = clone2.Root
				local dart = clone2.Dart
				root.Anchored = true
				clone2.Parent = folder
				PlaySound(script.PS2trainingDARTSthrow) -- equivalent call inferred; original call site unknown
				local v17 = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 4
				local cframe = CFrame.lookAt(v17, v16.Position)
				root.CFrame = cframe
				local cFrame2 = cframe.Rotation + v16.Position
				local tween = TweenService:Create(
					root,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						CFrame = cFrame2
					}
				)
				tween:Play()
				task.defer(function()
					tween.Completed:Wait()
					callback()
					task.wait(0.25)

					if dart.Parent == nil then
						return
					end

					local tween2 = TweenService:Create(
						dart,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					clone2:Destroy()
				end)
			end

			local FireDart2 = FireDart
			local v17 = cloneRoot
			local FadeOutHighlight2 = FadeOutHighlight
			local Delete2 = Delete
			clickDetector.MouseClick:Connect(function()
				if flag2 or v12 or v5 then
					return
				end

				v12 = true

				if clickDetector ~= nil then
					clickDetector:Destroy()
					clickDetector = nil
				end

				FireDart2(function()
					PlaySound(script.PS2trainingDARTSsmash, v17) -- equivalent call inferred; original call site unknown
					FadeOutHighlight2(true)
					dartShootingUI.Hit()
					Delete2()
				end)
			end)
			clone:PivotTo(v10)
			clone:ScaleTo(0.05)
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0.05
			local v18 = clone
			local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				if flag2 or v18.Parent == nil then
					return
				end

				v18:ScaleTo(numberValue.Value)
			end)
			local v20 = BoatTween:Create(numberValue, {
				Time = 0.4,
				Goal = {
					Value = 1
				},
				EasingStyle = "Bounce",
				EasingDirection = "Out"
			})
			v20:Play()
			local connection = valueChangedConnection
			local v22 = numberValue
			task.defer(function()
				v20.Completed:Wait()
				v20:Destroy()
				connection:Disconnect()
				v22:Destroy()
			end)
			local v23 = clone
			task.spawn(function()
				local total = 0

				while not flag2 and not v12 and v23.Parent ~= nil do
					total += RunService.Heartbeat:Wait()
					local v25 = v7 - total

					if v25 > 0.75 then
						continue
					end

					local v26 = math.clamp((0.75 - v25) / 0.75, 0, 1)
					local v27 = total * 25
					local v28 = math.noise(v27, 0, 0) * 0.6 * v26
					local v29 = math.noise(0, v27, 7.3) * 0.6 * v26

					if flag2 or v12 then
						break
					else
						v23:PivotTo(v10 * CFrame.new(v28, v29, 0))
					end
				end
			end)
			local v25 = cloneRoot
			local FadeOutHighlight3 = FadeOutHighlight
			local Delete3 = Delete
			task.delay(v7, function()
				if flag2 or v12 or v5 then
					return
				end

				if clickDetector ~= nil then
					clickDetector:Destroy()
					clickDetector = nil
				end

				PlaySound(script.PS2trainingDARTSsmash, v25) -- equivalent call inferred; original call site unknown
				FadeOutHighlight3(false)
				dartShootingUI.Miss()
				Delete3()
			end)
			task.wait(v8)
		end
	end)
end

function TargetShooting.Stop(_, _, _)
	teardown() -- equivalent call inferred; original call site unknown
end

return TargetShooting