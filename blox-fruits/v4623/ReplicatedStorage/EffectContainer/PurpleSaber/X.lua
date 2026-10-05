local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
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

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		return
	end

	if stage == 2 then
		local distance = data.Distance
		local cFrame = data.CFrame
		Util.Sound:Play("KiDash", cFrame.p, nil, 4 + math.random(-15, 15) / 100, 0.5)
		local clone = FX:WaitForChild("Weapons").PurpleDash:Clone()
		Util.Debris:AddItem(clone, 5)
		local ring = clone.Ring
		local shockwave = clone.Shockwave
		local sphere = clone.Sphere
		local longSwirl = clone.LongSwirl
		clone:SetPrimaryPartCFrame(cFrame)
		shockwave.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		shockwave.Size = Vector3.new(shockwave.Size.X, 20, shockwave.Size.Z)
		local tween = TweenService:Create(
			shockwave,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(shockwave.Size.X * 4, 1, shockwave.Size.Z * 4),
				CFrame = shockwave.CFrame * CFrame.new(0, 20, 0),
				Transparency = 1
			}
		)
		tween.Completed:Connect(function()
			shockwave:Destroy()
		end)
		longSwirl.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		local tween2 = TweenService:Create(
			longSwirl,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(longSwirl.Size.X * 4, distance, longSwirl.Size.Z * 4),
				CFrame = shockwave.CFrame * CFrame.new(0, -distance / 2, 0) * CFrame.Angles(0, 3.12413936106985, 0),
				Transparency = 1
			}
		)
		tween2.Completed:Connect(function()
			longSwirl:Destroy()
		end)
		ring.CFrame = cFrame * CFrame.new(0, 0, -(distance / 2)) * CFrame.Angles(
			1.5707963267948966,
			math.rad((math.random(-180, 180))),
			0
		)
		local tween3 = TweenService:Create(
			ring,
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(shockwave.Size.X * 3, 0, shockwave.Size.X * 3),
				CFrame = ring.CFrame * CFrame.Angles(0, -3.5779249665883754, 0),
				Transparency = 1
			}
		)
		tween3.Completed:Connect(function()
			ring:Destroy()
		end)
		sphere.CFrame = cFrame
		sphere.Size = createVector(1, 1, 1)
		local tween4 = TweenService:Create(
			sphere,
			TweenInfo.new(distance * 0.001, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = cFrame * CFrame.new(0, 0, -distance / 2),
				Size = Vector3.new(2, 2, distance)
			}
		)
		tween4.Completed:Connect(function()
			local tween5 = TweenService:Create(
				sphere,
				TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 1,
					Size = Vector3.new(0, 0, sphere.Size.Z)
				}
			)
			tween5.Completed:Connect(function()
				sphere:Destroy()
			end)
			tween5:Play()
		end)
		clone.Parent = _WorldOrigin
		tween:Play()
		tween3:Play()
		tween4:Play()
		tween2:Play()
		local lastTime = tick()

		while tick() - lastTime < 0.2 do
			local v = math.min(1, (tick() - lastTime) / 0.2)
			local cFrame2 = cFrame * CFrame.new(0, 0, -distance * v)
			local part = Instance.new("Part")
			Util.Debris:AddItem(part, 3)
			part.Size = createVector(19, 19, 19)
			part.Anchored = true
			part.CanCollide = false
			part.Shape = Enum.PartType.Ball
			part.Transparency = 1
			local particleEmitter = Instance.new("ParticleEmitter")
			particleEmitter.Texture = "rbxassetid://1690541156"
			particleEmitter.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.15, Color3.fromRGB(135, 55, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 74, 255))
			})
			particleEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.054, 0.246),
				NumberSequenceKeypoint.new(0.23, 0.0273),
				NumberSequenceKeypoint.new(0.524, 0.0492),
				NumberSequenceKeypoint.new(1, 1)
			})
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 5.65),
				NumberSequenceKeypoint.new(0.0612, 1.45, 0.637),
				NumberSequenceKeypoint.new(0.179, 1.15, 0.6),
				NumberSequenceKeypoint.new(0.325, 0.75, 0.219),
				NumberSequenceKeypoint.new(1, 0)
			})
			particleEmitter.LightEmission = 1
			particleEmitter.Drag = 6
			particleEmitter.Acceleration = createVector(0, -45, 0)
			particleEmitter.Speed = NumberRange.new(50 - v * 30, 80 - v * 30)
			particleEmitter.Rate = 25
			particleEmitter.SpreadAngle = Vector2.new(-90, 90)
			particleEmitter.RotSpeed = NumberRange.new(-1000, 1000)
			particleEmitter.Lifetime = NumberRange.new(1.5, 3)
			particleEmitter.Enabled = false
			particleEmitter.Parent = part
			part.CFrame = cFrame2
			part.Parent = _WorldOrigin
			particleEmitter:Emit(7)
			wait()
		end
	elseif stage == 3 then
		local root = data.Root

		if root and typeof(root) == "Instance" then
			for _ = 1, 7 do
				local part = Instance.new("Part")
				Util.Debris:AddItem(part, 3)
				part.Color = Color3.fromRGB(109, 69, 190)
				part.Anchored = true
				part.CanCollide = false
				part.CastShadow = false
				part.Material = Enum.Material.Neon
				part.CFrame = CFrame.new(
					root.Position + Vector3.new(math.random(-10, 10), math.random(-2, 2), math.random(-10, 10)),
					root.Position
				)
				local specialMesh = Instance.new("SpecialMesh")
				specialMesh.MeshType = Enum.MeshType.Sphere
				specialMesh.Offset = createVector(0, 0, 40)
				specialMesh.Scale = createVector(0.1, 0.1, 1)
				specialMesh.Parent = part
				local tween = TweenService:Create(
					specialMesh,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
					{
						Offset = createVector(0, 0, 0),
						Scale = createVector(0.35, 0.35, 20)
					}
				)
				local tween2 = TweenService:Create(
					specialMesh,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Offset = createVector(0, 0, -40),
						Scale = createVector(0.1, 0.1, 1)
					}
				)
				tween2.Completed:Connect(function()
					part:Destroy()
				end)
				tween.Completed:Connect(function()
					tween2:Play()
				end)
				Util.Sound:Play("QuickSlice", root.Position, nil, 1.5 + math.random(-32, 32) / 100, 0.25)
				part.Parent = _WorldOrigin
				tween:Play()
				wait()
				wait()
			end
		end
	end
end