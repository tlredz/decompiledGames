local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.Spring
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService2 = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function flatten(p)
	return p * createVector(1, 0, 1)
end

local function parabolic(p, p2, p3, p4)
	return p + p2 * p3 + 0.5 * p4 * p3 * p3
end

local function reflect(vector2, p)
	return vector2 - 2 * vector2:Dot(p) * p
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

return function(instance)
	local timestamp = instance.Timestamp
	local effect = instance.Effect
	local v = Util.MasterClock:GetTime() - timestamp

	if effect == "Nausea" then
		local duration = instance.Duration
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
			Util.Debris:AddItem(colorCorrectionEffect, duration + 2)
			local tween = TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					TintColor = Color3.fromRGB(218, 181, 255),
					Contrast = 1
				}
			)
			local tween2 = TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					TintColor = Color3.fromRGB(255, 255, 255),
					Contrast = 0
				}
			)
			tween2.Completed:Connect(function()
				colorCorrectionEffect:Destroy()
			end)
			colorCorrectionEffect.Parent = game:GetService("Lighting")
			tween:Play()

			if not instance.RefreshingDrink then
				local v2 = 1
				RunService:BindToRenderStep("nauseaCam", Enum.RenderPriority.Camera.Value + 1, function()
					v2 += 1
					local v3 = { currentCamera.CFrame:GetComponents() }
					v3[10] = v3[10] - 0.02 + math.cos(v2 / 15) * 0.04
					v3[11] = v3[11] - 0.02 + math.cos(v2 / 20) * 0.04
					currentCamera.CFrame = CFrame.new(table.unpack(v3))
				end)
				task.delay(duration, function()
					RunService:UnbindFromRenderStep("nauseaCam")
				end)
			end

			task.wait(duration)
			tween2:Play()
		end
	elseif effect == "CloudDamage" then
		local cFrame = instance.CFrame
		local color = instance.Color

		if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 800 then
			return
		end

		local part = Instance.new("Part")
		part.CanCollide = false
		part.Anchored = true
		part.Size = createVector(1, 1, 2)
		part.Color = color
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Parent = part
		part.CFrame = cFrame
		part.Parent = _WorldOrigin
	elseif effect == "TrailDrop" then
		local startPos = instance.StartPos
		local goalPos = instance.GoalPos

		if (goalPos - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		local lifetime = instance.Lifetime
		local timestamp2 = instance.Timestamp
		local color = instance.Color
		local v2 = Util.MasterClock:GetTime() - timestamp2
		spawn(function()
			local clone = FX:WaitForChild("VenomEffects").DebrisGlob:Clone()
			Util.Debris:AddItem(clone, 12)
			clone.AcidTrail.Color = ColorSequence.new(color)
			clone.Color = color
			clone.Parent = _WorldOrigin
			local magnitude = (startPos - goalPos).Magnitude
			local v3 = {
				startPos,
				startPos:Lerp(Vector3.new(goalPos.X, startPos.Y + magnitude / 1.2, goalPos.Z), 0.25),
				startPos:Lerp(Vector3.new(goalPos.X, goalPos.Y + magnitude / 1.2, goalPos.Z), 0.75),
				goalPos
			}
			local v4 = tick() + v2

			while tick() - v4 <= lifetime do
				local v5 = tick() - v4
				clone.Position = cubicBezier(v5 / lifetime, unpack(v3))
				RunService2.RenderStepped:Wait()
			end

			clone.Transparency = 1
			wait(5)
			clone:Destroy()
		end)
	elseif effect == "Puddle" then
		local cFrame = instance.CFrame
		local color = instance.Color
		local size = instance.Size
		local lifetime = instance.Lifetime

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		Util.Sound:Play("AcidFizzle", cFrame.p, nil, 0.8 + math.random(-10, 10) / 100, 2)
		spawn(function()
			local part = Instance.new("Part")
			Util.Debris:AddItem(part, lifetime + 5)
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(0.1, 0.1, 0.1)
			part.CFrame = cFrame
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = Enum.MeshType.Sphere
			specialMesh.Parent = part
			part.Color = color
			part.Material = Enum.Material.Glass
			part.Parent = _WorldOrigin
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = size
				}
			)
			local tween2 = TweenService:Create(
				part,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = Vector3.new(0, part.Size.Y, 0),
					Transparency = 1
				}
			)
			tween2.Completed:Connect(function()
				part:Destroy()
			end)
			tween.Completed:Connect(function()
				wait(instance.Lifetime - v)
				tween2:Play()
			end)
			tween:Play()
		end)
	elseif effect == "Landing" then
		local cFrame = instance.CFrame
		local color1 = instance.Color1
		local color2 = instance.Color2

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		local p = cFrame.p
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 50 then
				Util.CameraShaker:ShakeOnce(10, 25, 0.3, 0.8)
			end
		end

		local clone = FX:WaitForChild("VenomEffects").HydraLandBlast:Clone()
		Util.Debris:AddItem(clone, 5)
		local meshInner = clone.MeshInner
		local meshOuter = clone.MeshOuter
		local root = clone.Root
		local centerAt = root.CenterAt
		meshInner.Color = color1
		meshOuter.Color = color2

		for _, child in pairs(centerAt:GetChildren()) do
			child:Emit(10)
		end

		clone:SetPrimaryPartCFrame(cFrame)
		clone.Parent = _WorldOrigin
		Util.Sound:Play("VenomSplat", cFrame.p, nil, 0.5 + math.random(-10, 10) / 100, 3)
		Util.Sound:Play("VenomBlast", cFrame.p, nil, 0.8 + math.random(-10, 10) / 100, 2)
		local tween = TweenService:Create(
			meshInner,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
			{
				Size = createVector(25.18, 26.911, 25.18),
				Position = root.Position + createVector(0, 13.712, 0),
				CFrame = meshInner.CFrame * CFrame.Angles(0, 100, 0)
			}
		)
		local tween2 = TweenService:Create(
			meshOuter,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
			{
				Size = createVector(25.18, 25.269, 25.18),
				Position = root.Position + createVector(0, 12.892, 0),
				CFrame = meshOuter.CFrame * CFrame.Angles(0, 100, 0)
			}
		)
		tween.Completed:Connect(function()
			local tween3 = TweenService:Create(
				meshInner,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
				{
					Size = createVector(65.18, 2.911, 65.18),
					Position = root.Position,
					CFrame = meshInner.CFrame * CFrame.Angles(0, 100, 0)
				}
			)
			local tween4 = TweenService:Create(
				meshOuter,
				TweenInfo.new(0.17, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(65.18, 1.269, 65.18),
					Position = root.Position,
					CFrame = meshOuter.CFrame * CFrame.Angles(0, 100, 0)
				}
			)
			tween3.Completed:Connect(function()
				local tween5 = TweenService:Create(
					meshInner,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
					{
						Size = createVector(0.05, 0.05, 0.05),
						CFrame = meshInner.CFrame * CFrame.Angles(0, 100, 0)
					}
				)
				local tween6 = TweenService:Create(
					meshOuter,
					TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
					{
						Size = createVector(0.05, 0.05, 0.05),
						CFrame = meshOuter.CFrame * CFrame.Angles(0, 100, 0)
					}
				)
				tween5.Completed:Connect(function()
					meshOuter:Destroy()
					meshInner:Destroy()
				end)
				tween5:Play()
				tween6:Play()
			end)
			tween3:Play()
			tween4:Play()
		end)
		tween:Play()
		tween2:Play()
	end
end