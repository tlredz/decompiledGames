local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local peodizEvent = ReplicatedStorage.Chest.Remotes.Events:WaitForChild("PeodizEvent")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local _ = workspace.CurrentCamera
localPlayer:GetMouse()
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage2.Chest.Modules.PeodizService)
local dragon = ReplicatedStorage2.Chest.FruitEffect:WaitForChild("Dragon")
local fruitEffect = ReplicatedStorage2.Chest.FruitEffect
local PeoUtils = require(ReplicatedStorage2.Chest.Modules.PeoUtils)
local currentCamera = workspace.CurrentCamera
local CameraShaker = require(ReplicatedStorage2.Chest.Modules:WaitForChild("CameraShaker"))
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	currentCamera.CFrame *= p
end)
v:Start()

function _G.CamShake(p)
	v:Shake(CameraShaker.Presets[p])
end

function KaidoEffect(list)
	local v2, v3, v4 = unpack(list)
	PeodizService.new({
		Time = 15
	}, function()
		if not v2:IsDescendantOf(workspace.Effects) then
			return true
		end

		v2.CFrame = v3.CFrame * v4
	end)
end

function RandomBeamPos_New(parent)
	spawn(function()
		PeodizService.ForLoop({
			Step = 8,
			WaitTime = 0.05
		}, function(p)
			math.floor(p * 8)
			local attachment = Instance.new("Attachment", parent)
			attachment.Position = Vector3.new(0, 0, 0)
			local attachment2 = Instance.new("Attachment")
			attachment2.Name = "Attachment0"
			attachment2.Position = Vector3.new()
			attachment2.Parent = parent
			local clone = ReplicatedStorage2.Chest.FruitEffect.Flame.FlameBeam:Clone()
			clone.Parent = parent
			clone.Attachment0 = attachment
			clone.Width0 = math.random(30, 60)
			clone.Attachment1 = parent.Attachment0
			local cframe = CFrame.new(0, 0, -math.random(40, 70))
			TweenService:Create(attachment, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				WorldPosition = parent.CFrame * CFrame.Angles(
					math.rad((math.random(1, 360))),
					math.rad((math.random(1, 360))),
					(math.rad((math.random(1, 360))))
				) * CFrame.new(0, 0, -100) * cframe.p
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Width0 = 0
			}):Play()
			_G.PU:Dust(attachment, 1)
			_G.PU:Dust(clone, 1)
		end)
	end)
end

function RandomBeamPos_Brachio(parent)
	spawn(function()
		PeodizService.ForLoop({
			Step = 8,
			WaitTime = 0.05
		}, function(_)
			local attachment = Instance.new("Attachment", parent)
			attachment.Position = Vector3.new(0, 0, 0)
			local attachment2 = Instance.new("Attachment")
			attachment2.Name = "Attachment0"
			attachment2.Position = Vector3.new()
			attachment2.Parent = parent
			local clone = ReplicatedStorage2.Chest.FruitEffect.Flame.FlameBeam:Clone()
			clone.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			clone.Parent = parent
			clone.Attachment0 = attachment
			clone.Width0 = math.random(30, 60)
			clone.Attachment1 = parent.Attachment0
			local cframe = CFrame.new(0, 0, -math.random(40, 70))
			TweenService:Create(attachment, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				WorldPosition = parent.CFrame * CFrame.Angles(
					math.rad((math.random(1, 360))),
					math.rad((math.random(1, 360))),
					(math.rad((math.random(1, 360))))
				) * CFrame.new(0, 0, -100) * cframe.p
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Width0 = 0
			}):Play()
			_G.PU:Dust(attachment, 1)
			_G.PU:Dust(clone, 1)
		end)
	end)
end

function RandomBeamPos(parent)
	for _ = 1, 5 do
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		attachment.Parent = parent
		attachment2.Parent = parent
		attachment.Position = Vector3.new()
		attachment2.Position = Vector3.new()
		local clone = dragon.Beam:Clone()
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		clone.Width0 = 0
		clone.Width1 = 0
		local v2 = {
			Position = Vector3.new(math.random(-100, 100), math.random(40, 120), math.random(-100, 100))
		}
		local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
		local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0)
		local tween = TweenService:Create(clone, tweenInfo, {
			Width0 = 6,
			Width1 = 16
		})
		TweenService:Create(attachment2, tweenInfo2, v2):Play()
		tween:Play()
		clone.Parent = attachment
	end
end

function Explosion1(list)
	local cFrame = unpack(list)
	local clone = dragon.ExpPart:Clone()
	clone.Size = Vector3.new()
	clone.CFrame = cFrame
	clone.Boom:Play()
	clone.Explosion2:Play()
	clone.fire:Play()
	clone.Explosion:Play()
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 2)
	spawn(function()
		for _ = 1, math.random(6, 9) do
			local part = Instance.new("Part")
			part.Anchored = false
			part.CanCollide = false
			part.Size = Vector3.new(6, 6, 6)
			part.CFrame = cFrame * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
			part.Material = "Neon"
			local v3 = math.random(1, 3)
			local brickColor = v3 == 1 and clone.BrickColor or v3 == 2 and BrickColor.new("New Yeller")

			if not brickColor then
				if v3 == 3 then
					brickColor = BrickColor.new("CGA brown")
				else
					brickColor = false
				end
			end

			part.BrickColor = brickColor
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new(math.random(-100, 100), math.random(25, 105), math.random(-100, 100))
			bodyVelocity.MaxForce = Vector3.new(100000000, 100000000, 100000000)
			bodyVelocity.Parent = part
			_G.PU:Dust(bodyVelocity, 0.2)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
		end
	end)
	local getfenv_2 = getfenv(RandomBeamPos)
	getfenv_2.Num = 7
	RandomBeamPos(clone)
	TweenService:Create(clone, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true), {
		Size = Vector3.new(110, 110, 110)
	}):Play()

	if not (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	if (cFrame.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 250 then
		v:Shake(CameraShaker.Presets.Bump)
	end
end

function Gura1(list)
	local cframe, v2, v3, v4 = unpack(list)

	if (cframe.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude > 500 then
		v3.Transparency = 1
		v3.Part.Transparency = 1
	else
		local v5 = (cframe.p - v2.p).Magnitude / 20
		local clone = ReplicatedStorage2.Chest.FruitEffect.Gura.Crack:Clone()
		clone.CFrame = cframe * CFrame.Angles(0, 0, math.random() * math.pi * 2)
		clone.Size = Vector3.new()
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(17, 17, 0.05)
		}):Play()

		if (localPlayer.Character.HumanoidRootPart.Position - cframe.p).Magnitude < 70 then
			v:Shake(CameraShaker.Presets.Gura1)
		end

		coroutine.wrap(function()
			wait(1)
			TweenService:Create(
				clone.SurfaceGui2.ImageLabel,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					ImageTransparency = 1
				}
			):Play()
			TweenService:Create(
				clone.SurfaceGui1.ImageLabel,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					ImageTransparency = 1
				}
			):Play()
		end)()
		_G.PU:Dust(clone, 1.6)
		spawn(function()
			local v6 = cframe * CFrame.new(0, 0, 9.5)
			PeodizService.ForLoop({
				Step = 6,
				WaitTime = 0.05
			}, function(p)
				local v7 = math.floor(p * 6)
				coroutine.wrap(function()
					local v8 = v6 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))
					PeodizService.ForLoop({
						Step = 5,
						WaitTime = 0.025
					}, function(p2)
						local v9 = math.floor(p2 * 5)
						local part = Instance.new("Part")
						part.BrickColor = math.random(1, 2) == 1 and BrickColor.new("Pastel Blue") or BrickColor.new("Medium blue")
						part.Anchored = true
						part.CanCollide = false
						part.Material = Enum.Material.Neon
						part.Size = Vector3.new(v7 / 8 + 1 - v9 / 2.2, v7 / 8 + 1 - v9 / 2.2, v7 * 1.5 + 16)
						part.CFrame = v8 * CFrame.Angles(
							math.random() * 7,
							math.random() * math.pi * 2,
							math.random() * 7
						) * CFrame.new(0, 0, -part.Size.z / 2)
						part.Parent = workspace.Effects
						v8 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
						_G.PU:Dust(part, 0.1)
					end)
				end)()
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://5342403214"
				sound.Volume = 0.35
				sound.PlaybackSpeed = math.random(90, 120) / 100
				sound.MaxDistance = 500
				sound.Parent = clone
				sound:Play()
			end)
		end)
		PeodizService.ForLoop({
			Step = 20
		}, function(p)
			local v6 = math.floor(p * 20)
			v3.CFrame = cframe * CFrame.new(0, 0, -math.sin(v6 / 20 * math.pi / 2) * v4)

			if v6 % 2 == 0 then
				local clone2 = ReplicatedStorage2.Chest.FruitEffect.Gura.Ring:Clone()
				clone2.Size = Vector3.new(1, 1, 1)
				clone2.CFrame = v3.CFrame * CFrame.Angles(math.rad(90), 0, 0)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.5), {
					Transparency = 1,
					Size = Vector3.new(65 - v6 * 2.25, 1, 65 - v6 * 2.25)
				}):Play()
				_G.PU:Dust(clone2, 0.5)
				local part = Instance.new("Part")
				part.BrickColor = BrickColor.new("Dark stone grey")
				part.Anchored = true
				part.CanCollide = false
				part.Material = Enum.Material.Slate
				local v7 = 13 - v6 / 4
				part.Size = Vector3.new(v7, v7, v7)
				part.Parent = workspace.Effects
				local clone3 = part:Clone()
				clone3.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				_G.PU:Dust(clone3, 2)
				local cframe2 = CFrame.new(22 - v6 / 1.75, 0, -v6 * v5 - v7 / 3.5)
				local cframe3 = CFrame.new(v6 / 1.75 + -22, 0, -v6 * v5 - v7 / 3.5)
				local ray = Ray.new(cframe * cframe2.p, (Vector3.new(0, -19, 0)))
				local ray2 = Ray.new(cframe * cframe3.p, (Vector3.new(0, -19, 0)))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local raycastResult2 = workspace:Raycast(ray2.Origin, ray2.Direction, raycastParams)
				local instance2

				if raycastResult2 then
					instance2 = raycastResult2.Instance or nil
				end

				local position2 = raycastResult2 and raycastResult2.Position or ray2.Origin + ray2.Direction
				part.CFrame = CFrame.new(cframe.X, position2.Y, cframe.Z) * CFrame.Angles(cframe:ToOrientation()) * CFrame.new(
					0,
					0,
					-v6 * v5 - v7 / 3.5
				)
				clone3.CFrame = CFrame.new(cframe.X, position2.Y, cframe.Z) * CFrame.Angles(cframe:ToOrientation()) * CFrame.new(
					0,
					0,
					-v6 * v5 - v7 / 3.5
				)

				if instance then
					TweenService:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							math.random() * 2,
							math.random() * 2,
							math.random() * 2
						)
					}):Play()
					part.Material = instance.Material
					part.BrickColor = instance.BrickColor
					local clone4 = game.ReplicatedStorage.Chest.FruitEffect.Gura.Smoke:Clone()
					clone4.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, v7 / 1.05),
						NumberSequenceKeypoint.new(1, v7 * 1.85)
					})
					clone4.Color = ColorSequence.new(Color3.new(
						instance.Color.r,
						instance.Color.g,
						instance.Color.b - 0.075
					))
					clone4.Parent = part
					clone4:Emit(3)
				else
					part:Destroy()
				end

				if instance2 then
					TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(position2) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							math.random() * 2,
							math.random() * 2,
							math.random() * 2
						)
					}):Play()
					clone3.Material = instance2.Material
					clone3.BrickColor = instance2.BrickColor
					local clone4 = game.ReplicatedStorage.Chest.FruitEffect.Gura.Smoke:Clone()
					clone4.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, v7 / 1.05),
						NumberSequenceKeypoint.new(1, v7 * 1.85)
					})
					clone4.Color = ColorSequence.new(Color3.new(
						instance2.Color.r,
						instance2.Color.g,
						instance2.Color.b - 0.075
					))
					clone4.Parent = clone3
					clone4:Emit(3)
				else
					clone3:Destroy()
				end
			end
		end)
		TweenService:Create(v3, TweenInfo.new(0.35), {
			Size = Vector3.new(69.28, 69.28, 69.28),
			Transparency = 1
		}):Play()

		if v3:FindFirstChild("Part") then
			TweenService:Create(v3.Part, TweenInfo.new(0.35), {
				Size = Vector3.new(61.424, 61.424, 61.424),
				Transparency = 1
			}):Play()
		end
	end
end

function EarthQuake(p)
	local dist = p.Dist
	local startCF = p.StartCF

	if not (startCF and dist) or (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 750 then
		return
	end

	local v2 = math.random(14, 22)
	local v3 = 360 / v2

	if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 50 + dist then
		v:Shake(CameraShaker.Presets.Gura1)
	end

	local clone = ReplicatedStorage2.Chest.FruitEffect.Gura.Crack:Clone()
	clone.CFrame = startCF * CFrame.new(0, -3, -2) * CFrame.Angles(math.pi / 2, 0, math.random() * math.pi * 2)
	clone.Size = Vector3.new()
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true), {
		Size = Vector3.new(5 * dist / 10, 5 * dist / 10, 0.05)
	}):Play()
	_G.PU:Dust(clone, 1.25)

	for i = 0, v2 do
		local ray = Ray.new(
			(startCF * CFrame.Angles(0, math.rad(i * v3), 0) * CFrame.new(0, 0, -dist)).p,
			(Vector3.new(0, -75, 0))
		)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if not instance then
			continue
		end

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.BrickColor = instance.BrickColor
		part.Material = instance.Material
		part.MaterialVariant = instance.MaterialVariant
		part.CFrame = CFrame.new(startCF.X, position.Y, startCF.Z) * CFrame.Angles(startCF:ToOrientation())
		part.Size = Vector3.new(1, 1, 1) * (dist / 3.85)
		TweenService:Create(part, TweenInfo.new(0.35), {
			CFrame = CFrame.new(position) * CFrame.Angles(math.random() * 2, math.random() * 2, math.random() * 2)
		}):Play()
		local v5 = position
		coroutine.wrap(function()
			wait(1.5)
			TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false), {
				Transparency = 1,
				CFrame = CFrame.new(v5) * CFrame.new(0, -part.Size.Y * 1.25, 0)
			}):Play()
		end)()
		_G.PU:Dust(part, 2.55)
		part.Parent = workspace.Effects
	end
end

function GuraC(p)
	local startCF = p.StartCF

	if not startCF or (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 800 then
		return
	end

	if p.EF == 0 then
		spawn(function()
			local v2 = startCF * CFrame.new(0, 0, 9.5)

			for i = 1, 3 do
				local v3 = i
				coroutine.wrap(function()
					local v4 = v2 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))

					for i2 = 1, 5 do
						local part = Instance.new("Part")
						part.BrickColor = math.random(1, 2) == 1 and BrickColor.new("Pastel Blue") or BrickColor.new("Medium blue")
						part.Anchored = true
						part.CanCollide = false
						part.Material = Enum.Material.Neon
						part.Size = Vector3.new(v3 / 8 + 1 - i2 / 2.2, v3 / 8 + 1 - i2 / 2.2, v3 * 1.5 + 16)
						part.CFrame = v4 * CFrame.Angles(
							math.random() * 7,
							math.random() * math.pi * 2,
							math.random() * 7
						) * CFrame.new(0, 0, -part.Size.z / 2)
						part.Parent = workspace.Effects
						v4 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
						_G.PU:Dust(part, 0.1)
						wait(0.025)
					end
				end)()
				local part = Instance.new("Part")
				part.Anchored = true
				part.Transparency = 1
				part.CanCollide = false
				part.Size = Vector3.new(1, 1, 1)
				part.CFrame = startCF
				part.Parent = workspace.Effects
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://5342403214"
				sound.Volume = 0.35
				sound.PlaybackSpeed = math.random(90, 120) / 100
				sound.MaxDistance = 500
				sound.Parent = part
				sound:Play()
				_G.PU:Dust(part, 1.5)
				wait(0.05)
			end
		end)
	end

	for i = 1, 7 do
		local ray = Ray.new((startCF * CFrame.new(0, 0, -i * 15)).p, (Vector3.new(0, -75, 0)))
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if instance and instance:IsA("BasePart") then
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.BrickColor = instance.BrickColor
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.CFrame = CFrame.new(position) - Vector3.new(0, 4.5, 0)
			part.Size = Vector3.new(1, math.random(1, 2) + math.random() / 5, 1) * (math.random(6, 9) + math.random())
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 5)
			TweenService:Create(part, TweenInfo.new(1.5), {
				CFrame = CFrame.new(position) * CFrame.Angles(math.random() * 2, math.random() * 2, math.random() * 2) - Vector3.new(
					0,
					0.5,
					0
				)
			}):Play()
			local v3 = position
			delay(3, function()
				TweenService:Create(part, TweenInfo.new(1), {
					Transparency = 1,
					CFrame = CFrame.new(v3) - Vector3.new(0, 6 + part.Size.Y / 2, 0)
				}):Play()
			end)
		end

		wait(0.32)
	end
end

function GuraCShake(p)
	local startCF = p.StartCF

	if not startCF then
		return
	end

	if (localPlayer.Character.HumanoidRootPart.Position - startCF).Magnitude < 85 then
		v:Shake(CameraShaker.Presets.Gura2)
		wait(0.02)
		v:Shake(CameraShaker.Presets.Earthquake)
	end
end

function GuraShake(p)
	local startCF = p.StartCF

	if not startCF then
		return
	end

	if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude < 300 then
		v:Shake(CameraShaker.Presets.GuraEarthquake)
	end
end

function Gura4(p)
	local startCF = p.StartCF

	for _ = 1, 3 do
		local clone = game.ReplicatedStorage.Chest.FruitEffect.Gura.Ring3:Clone()
		clone.CFrame = CFrame.new(startCF.p) * CFrame.Angles(math.pi, 0, math.pi)
		clone.BrickColor = BrickColor.new("Electric blue")
		clone.Transparency = 0.5
		TweenService:Create(clone, TweenInfo.new(1.5), {
			Transparency = 1,
			Size = Vector3.new(2400, 10, 2400)
		}):Play()
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 3)
		wait(1.6666666666666667)
	end
end

function GuraB(p)
	local startCF = p.StartCF

	if not startCF then
		return
	end

	if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude < 750 then
		local clone = ReplicatedStorage2.Chest.FruitEffect.Gura.CrackCorrection:Clone()
		clone.Enabled = true
		TweenService:Create(clone, TweenInfo.new(0.75), {
			Brightness = 0.05,
			Contrast = 1,
			Saturation = -1
		}):Play()
		clone.Parent = game.Lighting

		for _ = 1, 3 do
			local clone2 = ReplicatedStorage2.Chest.FruitEffect.Gura.CrackGui:Clone()
			clone2.Crack.Size = UDim2.new(1 + math.random(), 0, 1 + math.random(), 0)
			clone2.Parent = localPlayer.PlayerGui
			clone2.Crack.Rotation = math.random(0, 360)
			TweenService:Create(
				clone2.Crack,
				TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, math.random() / 5),
				{
					ImageTransparency = 0.95
				}
			):Play()
			_G.PU:Dust(clone2, 3)
			wait()
		end

		local v2 = 0
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://516789356",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = localPlayer.PlayerGui
		sound:Play()
		local v3 = math.random(100, 400) / 100
		PeodizService.new({
			Time = 3
		}, function()
			currentCamera.CFrame *= CFrame.Angles(0, 0, math.rad(-90) + math.pi / v3 * v2)
			v2 = math.clamp(v2 + 0.2, 0, 1)
		end)
		clone:Destroy()
	end
end

function DoughEffect1(data)
	local startPos = data.StartPos
	local mouseHit = data.MouseHit
	local doughColor = data.DoughColor or BrickColor.new("Institutional white")

	if not (startPos and mouseHit) then
		return
	end

	local p = startPos.p
	local cframe = CFrame.new(p, mouseHit.p)
	local ray = Ray.new(cframe.p, CFrame.new(p, mouseHit.p).LookVector * 175)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Island }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
	local instance

	if raycastResult then
		instance = raycastResult.Instance or nil
	else
		instance = nil
	end

	local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
	local normal = raycastResult and raycastResult.Normal or nil
	local magnitude = (p - position).Magnitude
	local clone = ReplicatedStorage2.Chest.FruitEffect.Dough.DoughCircle:Clone()
	clone.CFrame = CFrame.new(p, mouseHit.p) * CFrame.Angles(0, math.pi / 2, 0)
	clone.Size = Vector3.new(0.1, 0.1, 0.1)
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new(6.1, 9.7, 10.4)
	}):Play()
	wait(0.35)
	local clone2 = ReplicatedStorage2.Chest.FruitEffect.Dough.DoughFist:Clone()
	clone2.CFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25)
	clone2.BrickColor = doughColor
	clone2.Parent = workspace.Effects
	local clone3 = ReplicatedStorage2.Chest.FruitEffect.Dough.Fist:Clone()
	clone3.BrickColor = doughColor
	clone3.CFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25) * CFrame.new(0, 0, -clone2.Size.Z / 2) * CFrame.Angles(
		math.pi / 2,
		0,
		0
	)
	clone3.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6113686682",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25) * CFrame.new(0, 0, -magnitude - 1) * CFrame.Angles(
			math.pi / 2,
			0,
			0
		)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25) * CFrame.new(0, 0, -magnitude / 2),
		Size = Vector3.new(4, 4, magnitude)
	}):Play()
	coroutine.wrap(function()
		local v2 = magnitude / 3

		for i = 1, 3 do
			local clone4 = game.ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			_G.PU:Dust(clone4, 0.55)
			clone4.CFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25) * CFrame.new(0, 0, -v2 * i) * CFrame.Angles(
				math.pi / 2,
				math.pi / 2,
				0
			)
			local v3 = 45 / (i * 1.25)
			clone4.Parent = workspace.Effects
			TweenService:Create(clone4, TweenInfo.new(0.5), {
				Transparency = 1,
				Size = Vector3.new(v3, 1, v3)
			}):Play()
		end
	end)()
	spawn(function()
		wait(0.1)

		if instance then
			local cFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25) * CFrame.new(0, 0, -magnitude - 1)

			for _ = 1, math.random(2, 4) do
				local part = Instance.new("Part")
				part.Anchored = false
				part.CanCollide = false
				part.BrickColor = instance.BrickColor
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Size = Vector3.new(0.5, 0.5, 0.5) * (math.random(200, 500) / 65)
				part.RotVelocity = Vector3.new(2, 2, 2) * (math.random(-100, 100) / 100)
				part.CFrame = cFrame
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * math.huge
				bodyVelocity.Velocity = Vector3.new(math.random(-40, 40), math.random(60, 120), math.random(-40, 40))
				bodyVelocity.Parent = part

				if math.random(1, 3) == 1 then
					local clone4 = ReplicatedStorage2.Chest.FruitEffect.Dough.DoughEmitter:Clone()
					clone4.Enabled = true
					clone4.Parent = part
				end

				part.Parent = workspace.Effects
				_G.PU:Dust(bodyVelocity, 0.1)
				_G.PU:Dust(part, 2)
			end

			if (localPlayer.Character.HumanoidRootPart.Position - position).Magnitude <= 65 then
				v:Shake(CameraShaker.Presets.BK2)
			end

			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.Size = Vector3.new(1, 1, 1)
			part.CFrame = CFrame.new(position)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 750,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://365002938",
				Volume = 1.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = part
			sound2:Play()
			local clone4 = ReplicatedStorage2.Chest.FruitEffect.Dough.SmokeParticle2:Clone()
			clone4.Color = ColorSequence.new(instance.Color)
			clone4.Parent = part
			clone4:Emit(50)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 8.5)
			local clone5 = ReplicatedStorage2.Chest.FruitEffect.Dough.Shockwave:Clone()
			clone5.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(math.pi / 2, 0, 0)
			clone5.BrickColor = instance.BrickColor
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
				Transparency = 1,
				Size = Vector3.new(55, 8.5, 55)
			}):Play()
			_G.PU:Dust(clone5, 0.5)
		end
	end)
	wait(0.5)
	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1,
		CFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25) * CFrame.Angles(math.pi / 2, 0, 0)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1,
		CFrame = CFrame.new(p, mouseHit.p) * CFrame.new(0, 0, -1.25) * CFrame.new(0, 0, -1),
		Size = Vector3.new(4, 4, 2)
	}):Play()
	wait(0.5)
	clone3:Destroy()
	clone2:Destroy()
	clone:Destroy()
end

function DoughEffect2(p)
	local startAt = p.StartAt
	local size = p.Size or 150

	if not startAt then
		return
	end

	for i = 1, 6 do
		local clone = ReplicatedStorage2.Chest.FruitEffect.Dough.Part:Clone()
		clone.CFrame = startAt

		if i == 1 then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6118184651",
				Volume = 1.25
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
		end

		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6117839163",
			Volume = 0.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			CFrame = startAt * CFrame.new(0, -1, 0),
			Size = Vector3.new(size, 2, size)
		}):Play()
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 3)
		delay(2, function()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 1,
				Size = Vector3.new(size, 0, size)
			}):Play()
		end)
		wait(0.35)
	end
end

function DoughCage(p)
	local target = p.Target

	if not target then
		return
	end

	local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	wait(0.15)
	local v2 = humanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)

	for i = 3, 1, -1 do
		local clone = ReplicatedStorage2.Chest.FruitEffect.Dough.DoughCage:Clone()
		clone.CFrame = v2 * CFrame.new(0, i * 1.2, 0)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), {
			Size = Vector3.new(math.sin(math.pi / 2 * i / 3) * 7.5, 3.2, math.sin(math.pi / 2 * i / 3) * 7.5)
		}):Play()
		spawn(function()
			wait(5.2)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 1,
				Size = clone.Size * 1.5
			}):Play()
		end)
		_G.PU:Dust(clone, 6)
	end
end

function Dough_Fist(p)
	local lookAt = p.LookAt

	if (localPlayer.Character.HumanoidRootPart.Position - lookAt.Position).Magnitude > 750 then
		return
	end

	local clone = fruitEffect.Dough.Doughnut:Clone()
	_G.PU:Dust(clone, 3)
	clone.CFrame = lookAt * CFrame.new(0, 0, -1.5) * CFrame.Angles(math.pi / 2, 0, 0)
	clone.Parent = workspace.Effects
	local clone2 = fruitEffect.Dough.DoughBlock:Clone()
	_G.PU:Dust(clone2, 3)
	clone2.CFrame = lookAt
	clone2.Parent = workspace.Effects
	local clone3 = fruitEffect.Dough.Fist:Clone()
	_G.PU:Dust(clone3, 3)
	clone3.CFrame = lookAt
	clone3.Parent = workspace.Effects
	local clone4 = fruitEffect.Dough.Shockwave:Clone()
	_G.PU:Dust(clone4, 3)
	clone4.CFrame = lookAt
	clone4.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6113686682",
		Volume = 0.7
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6313682232",
		Volume = 0.5,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone3
	sound2:Play()

	if p.Haki then
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://979751563",
			Volume = 1,
			PlaybackSpeed = 1.9
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = clone2
		sound3:Play()
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Color = Color3.fromRGB(0, 0, 0)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Color = Color3.fromRGB(0, 0, 0)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Color = Color3.fromRGB(0, 0, 0)
		}):Play()
	end

	local v2 = lookAt * CFrame.new(0, 0, -75)
	local v3 = (lookAt.p - v2.p).Magnitude / 20
	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = Vector3.new(11, 5, 11)
	}):Play()
	TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		Size = Vector3.new(20, 20, 60)
	}):Play()

	local function RockEF(p2, vector, vector2)
		local ray = Ray.new(p2, vector)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if instance then
			local part = Instance.new("Part")
			part.BrickColor = BrickColor.new("Dark stone grey")
			part.Anchored = true
			part.Size = vector2 / 8
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.BrickColor = instance.BrickColor
			part.RotVelocity = Vector3.new(math.pi * math.random(), math.pi * math.random(), math.pi * math.random())
			part.CFrame = CFrame.new(position) * CFrame.Angles(
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random()
			) - Vector3.new(0, 10, 0)
			part.CanCollide = false
			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Size = vector2,
				CFrame = CFrame.new(position) * CFrame.Angles(
					math.pi * 2 * math.random(),
					math.pi * 2 * math.random(),
					math.pi * 2 * math.random()
				)
			}):Play()
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 2)
		end
	end

	PeodizService.ForLoop({
		Step = 20
	}, function(p2)
		local v4 = math.floor(p2 * 20)
		local v5 = math.sin(math.pi / 2 * v4 / 20) * 75
		clone2.Size = Vector3.new(clone2.Size.X, clone2.Size.Y, v5)
		clone2.CFrame = lookAt * CFrame.new(0, 0, -v5 / 2)
		clone3.CFrame = lookAt * CFrame.new(0, 0, -v5 - clone3.Size.Z / 2) * CFrame.Angles(math.pi / 2, math.pi * 2, 0)
		clone4.CFrame = lookAt * CFrame.new(0, 0, -v5 + clone4.Size.Z / 2) * CFrame.Angles(0, math.pi, 0)
		clone4.CFrame *= CFrame.Angles(0, 0, math.pi / 2)

		if v4 % 3 == 1 then
			RockEF(
				(lookAt * CFrame.new(13.5 - v4 / 2, 0, -v3 * v4)).p,
				Vector3.new(0, -25, 0),
				Vector3.new(10 - v4 / 3, 10 - v4 / 3, 10 - v4 / 3)
			)
			RockEF(
				(lookAt * CFrame.new(v4 / 2 + -13.5, 0, -v3 * v4)).p,
				Vector3.new(0, -25, 0),
				Vector3.new(10 - v4 / 3, 10 - v4 / 3, 10 - v4 / 3)
			)
		end

		if v4 % 4 == 0 then
			local clone5 = game.ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			_G.PU:Dust(clone5, 1.5)
			clone5.CFrame = lookAt * CFrame.new(0, 0, -v3 * v4) * CFrame.Angles(math.pi / 2, math.pi / 2, 0)
			local v6 = 70 - v4 * 2.7
			clone5.Parent = workspace.Effects
			TweenService:Create(
				clone5,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Size = Vector3.new(v6, 1, v6)
			}):Play()
		end
	end)
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Size = Vector3.new(0, 5, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Size = Vector3.new(0, clone3.Size.Z, 0)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Size = Vector3.new(0, 0, clone2.Size.Z)
	}):Play()
end

function Dough_Arm(p)
	local target = p.Target

	if not target then
		return
	end

	local flag = true
	local clone = fruitEffect.Dough.Shockwave:Clone()
	clone.CFrame = target.CFrame * CFrame.Angles(0, math.pi, 0)
	clone.Material = "Neon"
	clone.Size = Vector3.new(12, 12, 27)
	clone.Transparency = 0.9
	clone.BrickColor = BrickColor.new("CGA brown")
	clone.Parent = workspace.Effects
	local total = 10
	PeodizService.new({
		Time = 15
	}, function()
		clone.CFrame = target.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(
			0,
			0,
			(math.rad(total))
		)

		if flag then
			flag = false
			local clone2 = fruitEffect.Dough.Ring:Clone()
			clone2.CFrame = target.CFrame * CFrame.Angles(math.pi / 2, 0, 0)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 1,
				Size = Vector3.new(30, 3, 30),
				CFrame = clone2.CFrame * CFrame.new(0, 7.5, 0)
			}):Play()
			spawn(function()
				wait(0.025)
				flag = true
			end)
		end

		if not target:IsDescendantOf(workspace.Effects) then
			return true
		end

		total += 7.5
	end)
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Transparency = 1
	}):Play()
	wait(0.5)
	clone:Destroy()
end

function SmallExplosion(p)
	local startPos = p.StartPos
	local clone = fruitEffect.Dough.Shockwave:Clone()
	clone.CFrame = CFrame.new(startPos) * CFrame.Angles(math.pi / 2, 0, 0) + Vector3.new(0, 2.25, 0)
	clone.Size = Vector3.new(1, 1, 1)
	clone.Material = "Neon"
	clone.Parent = workspace.Effects
	spawn(function()
		for _ = 1, math.random(7, 13) do
			local cFrame = CFrame.new(startPos) * CFrame.Angles(
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random()
			)
			local clone2 = fruitEffect.Dough.Spark:Clone()
			clone2.Size = Vector3.new(5, 5, 1)
			clone2.BrickColor = BrickColor.new("Institutional white")
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			local v3 = math.random(20, 50)
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0), {
				Size = Vector3.new(0, 0, v3),
				CFrame = cFrame * CFrame.new(0, 0, -40)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 1)
		end
	end)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6326691525",
		Volume = 0.5,
		PlaybackSpeed = 1.25
	})
	_G.PU:Dust(sound, 1)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6326692549",
		Volume = 0.5
	})
	_G.PU:Dust(sound2, 1)
	sound2.Parent = clone
	sound2:Play()
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = Vector3.new(130, 130, 30)
	}):Play()
	local clone2 = fruitEffect.Dough.Ring:Clone()
	clone2.Transparency = 0.5
	clone2.BrickColor = BrickColor.new("Institutional white")
	clone2.Size = Vector3.new(20, 5, 20)
	clone2.CFrame = CFrame.new(startPos)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.05), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Size = Vector3.new(70, 7, 70),
		CFrame = CFrame.new(startPos) + Vector3.new(0, 25, 0)
	}):Play()
	_G.PU:Dust(clone, 1)
	_G.PU:Dust(clone2, 1)
end

function BigExplosion(p)
	local startPos = p.StartPos

	if (localPlayer.Character.HumanoidRootPart.Position - startPos).Magnitude > 750 then
		return
	end

	if (localPlayer.Character.HumanoidRootPart.Position - startPos).Magnitude < 75 then
		v:Shake(CameraShaker.Presets.Mochi1)
	end

	local clone = fruitEffect.Dough.Fire:Clone()
	_G.PU:Dust(clone, 2.5)
	clone.CFrame = CFrame.new(startPos)
	clone.ForceField.CFrame = CFrame.new(startPos)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6314387066",
		Volume = 3,
		PlaybackSpeed = 0.85
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6314386356",
		Volume = 4,
		PlaybackSpeed = 0.85
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6314388751",
		Volume = 4,
		TimePosition = 0.3
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone
	sound3:Play()
	spawn(function()
		for _ = 1, math.random(10, 15) do
			local cFrame = CFrame.new(startPos) * CFrame.Angles(
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random()
			)
			local clone2 = fruitEffect.Dough.Spark:Clone()
			clone2.Size = Vector3.new(10, 10, 1)
			clone2.BrickColor = BrickColor.new("Bright orange")
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			local v3 = math.random(20, 50)
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0), {
				Size = Vector3.new(0, 0, v3),
				CFrame = cFrame * CFrame.new(0, 0, -(clone.ForceField.Size.Z * 4.5) / 1.5)
			}):Play()
			TweenService:Create(
				clone2,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.25),
				{
					Transparency = 1
				}
			):Play()
			_G.PU:Dust(clone2, 1.5)
		end
	end)
	clone.Burning.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, clone.Size.Z * 2),
		NumberSequenceKeypoint.new(1, clone.Size.Z * 5)
	})
	clone.Burning2.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 25), NumberSequenceKeypoint.new(1, 5) })
	clone.Attachment2.rocks:Emit(math.random(30, 70))
	clone.Burning2:Emit(math.random(30, 70))
	TweenService:Create(clone.ForceField, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Size = clone.ForceField.Size * 4.5
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Size = clone.Size * 4.5
	}):Play()
	TweenService:Create(
		clone.ForceField,
		TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.25),
		{
			Transparency = 1
		}
	):Play()
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.25), {
		Transparency = 1
	}):Play()
	spawn(function()
		wait(0.3)
		clone.Burning.Enabled = false
	end)
	spawn(function()
		wait(0.2)
		local clone2 = fruitEffect.Dough.Ring:Clone()
		clone2.Transparency = 0.5
		clone2.Size = Vector3.new(70, 5, 70)
		clone2.CFrame = CFrame.new(startPos)
		clone2.Parent = workspace.Effects
		TweenService:Create(
			clone2,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2),
			{
				Transparency = 1
			}
		):Play()
		TweenService:Create(clone2, TweenInfo.new(1.1935483870967742, Enum.EasingStyle.Sine), {
			Size = Vector3.new(120, 7, 120),
			CFrame = CFrame.new(startPos) + Vector3.new(0, 50, 0)
		}):Play()
		_G.PU:Dust(clone2, 1)
	end)
end

function Dough_Floor(p)
	local startCF = p.StartCF
	local clone = fruitEffect.Dough.Floor:Clone()
	clone.CFrame = startCF
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 5)
	TweenService:Create(clone, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = startCF * CFrame.Angles(0, math.pi * 2 * (math.random(-100, 100) / 100), 0),
		Size = Vector3.new(300, 5, 300)
	}):Play()
	local clone2 = fruitEffect.Dough.Ring:Clone()
	clone2.CFrame = startCF + Vector3.new(0, 3, 0)
	clone2.Material = "Glass"
	clone2.BrickColor = BrickColor.new("Institutional white")
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new(350, 5, 350)
	}):Play()
	wait(1.5)
	TweenService:Create(clone, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = startCF * CFrame.Angles(0, math.pi * 2 * (math.random(-100, 100) / 100), 0),
		Size = Vector3.new(0, 5, 0)
	}):Play()
end

function DoughC(data)
	local startCF = data.StartCF
	local endCF = data.EndCF
	local size = data.Size or 80
	local v2 = (startCF.p - endCF.p).Magnitude / 15
	local v3 = math.random(-12, 12)
	PeodizService.ForceForLoop({
		Step = 15
	}, function(p)
		local v4 = math.floor(p * 15)
		local clone = fruitEffect.Dough.DoughPart:Clone()

		if v4 % 3 == 0 then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://6320422577"
			sound.Volume = 0.4
			sound.RollOffMaxDistance = 750
			sound.PlaybackSpeed = math.random(100, 110) / 100
			sound.Parent = clone
			sound:Play()
			_G.PU:Dust(sound, 2)
		end

		local v5 = startCF * CFrame.new(math.sin(math.pi * v4 / 15) * v3, math.sin(math.pi * v4 / 15) * 30, -v2 * v4)
		local v6 = startCF * CFrame.new(
			math.sin(math.pi * (v4 + 1) / 15) * v3,
			math.sin(math.pi * (v4 + 1) / 15) * 30,
			-v2 * (v4 + 1)
		)
		local magnitude = (v5.p - v6.p).Magnitude
		local v7 = math.max(math.sin(math.pi * v4 / 15) * 10, 1.5)
		clone.Size = Vector3.new(magnitude, v7, v7)
		clone.CFrame = CFrame.new(v5.p, v6.p) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, math.pi / 2, 0)
		clone.Part.Size = Vector3.new(magnitude, v7, v7) * 1.075
		clone.Part.CFrame = CFrame.new(v5.p, v6.p) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, math.pi / 2, 0)
		clone.Parent = workspace.Effects
		TweenService:Create(
			clone.Part,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.25),
			{
				Transparency = 1,
				Size = Vector3.new(magnitude, 0, 0)
			}
		):Play()
		TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.25),
			{
				Transparency = 1,
				Size = Vector3.new(magnitude, 0, 0)
			}
		):Play()
		_G.PU:Dust(clone, 1.85)
	end)
	spawn(function()
		for _ = 1, math.random(7, 13) do
			local cFrame = CFrame.new(endCF.p) * CFrame.Angles(
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random()
			)
			local clone = fruitEffect.Dough.Spark:Clone()
			clone.Size = Vector3.new(5, 5, 1)
			clone.BrickColor = BrickColor.new("Institutional white")
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local v5 = math.random(20, 50)
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0), {
				Size = Vector3.new(0, 0, v5),
				CFrame = cFrame * CFrame.new(0, 0, -40)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1.5)
		end
	end)
	local clone = fruitEffect.Dough.Shockwave:Clone()
	clone.CFrame = CFrame.new(endCF.p) * CFrame.Angles(math.pi / 2, 0, 0) + Vector3.new(0, 2.25, 0)
	clone.Size = Vector3.new(1, 1, 1)
	clone.Material = "Neon"
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = Vector3.new(130, 130, 30)
	}):Play()
	local clone2 = fruitEffect.Dough.Ring:Clone()
	clone2.Transparency = 0.5
	clone2.BrickColor = BrickColor.new("Institutional white")
	clone2.Size = Vector3.new(20, 5, 20)
	clone2.CFrame = CFrame.new(endCF.p)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
		Size = Vector3.new(70, 7, 70),
		CFrame = CFrame.new(endCF.p) + Vector3.new(0, 25, 0)
	}):Play()
	_G.PU:Dust(clone, 1.5)
	_G.PU:Dust(clone2, 1.5)
	local clone3 = fruitEffect.Dough.Floor:Clone()
	clone3.CFrame = CFrame.new(endCF.p) * CFrame.Angles(0, math.pi * math.random(), 0) - Vector3.new(0, 1.3, 0)
	clone3.Size = Vector3.new(1, 1, 1)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 5)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6320420838",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	TweenService:Create(clone3, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = Vector3.new(size, 8.5, size)
	}):Play()
	spawn(function()
		wait(2)
		TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Transparency = 1,
			Size = Vector3.new(0, 5, 0)
		}):Play()
	end)
end

local v2 = {}

function Fist(data)
	local v3 = CFrame.new(data.Root.Position, data.Mouse.Value) * CFrame.new(
		math.random(-40, 40),
		math.random(3, 20),
		math.random(-3, 3)
	)
	local cframe = CFrame.new(v3.Position, data.Mouse.Value)
	local clone = fruitEffect.Dough.Doughnut:Clone()
	clone.CFrame = cframe * CFrame.new(0, 0, -1.5) * CFrame.Angles(math.pi / 2, 0, 0)
	clone.Parent = workspace.Effects
	local clone2 = fruitEffect.Dough.DoughBlock:Clone()
	clone2.CFrame = cframe
	clone2.Parent = workspace.Effects
	local clone3 = fruitEffect.Dough.Fist:Clone()
	clone3.CFrame = cframe
	clone3.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6113686682",
		Volume = 0.7
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6313682232",
		Volume = 0.5,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone3
	sound2:Play()

	if data.Haki then
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://979751563",
			Volume = 1,
			PlaybackSpeed = 1.9
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = clone2
		sound3:Play()
		TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Color = Color3.fromRGB(0, 0, 0)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Color = Color3.fromRGB(0, 0, 0)
		}):Play()
	end

	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Size = Vector3.new(11, 5, 11)
	}):Play()
	_G.PU:Dust(clone2, 0.8)
	_G.PU:Dust(clone3, 0.8)
	_G.PU:Dust(clone, 0.8)
	local magnitude = (data.Mouse.Value - data.Root.Position).Magnitude
	PeodizService.ForLoop({
		Step = 15
	}, function(p)
		local v5 = math.floor(p * 15)
		local v6 = math.sin(math.pi / 2 * v5 / 15) * magnitude
		clone2.Size = Vector3.new(clone2.Size.X, clone2.Size.Y, v6)
		clone2.CFrame = cframe * CFrame.new(0, 0, -v6 / 2)
		clone3.CFrame = cframe * CFrame.new(0, 0, -v6 - clone3.Size.Z / 2) * CFrame.Angles(math.pi / 2, math.pi * 2, 0)

		if v5 % 6 == 0 then
			local clone4 = game.ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone4.CFrame = cframe * CFrame.new(0, 0, -(magnitude / 15) * v5) * CFrame.Angles(
				math.pi / 2,
				math.pi / 2,
				0
			)
			local v7 = 50 - v5 * 2.7
			clone4.Parent = workspace.Effects
			TweenService:Create(
				clone4,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Size = Vector3.new(v7, 1, v7)
			}):Play()
			_G.PU:Dust(clone4, 0.5)
		end
	end)

	if clone3:FindFirstChild("Dough") then
		clone3.Dough:Stop()
	end

	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Size = Vector3.new(0, 5, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Size = Vector3.new(0, clone3.Size.Z, 0)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.35), {
		Size = Vector3.new(0, 0, clone2.Size.Z)
	}):Play()
end

function DoughV(data)
	if data.Type == true then
		if not v2[data.Root] and data.Mouse then
			local _ = data.Mouse
			v2[data.Root] = true

			while data.Root and data.Root:IsDescendantOf(workspace) and v2[data.Root] do
				spawn(function()
					Fist(data)
				end)
				wait(0.15)
			end

			v2[data.Root] = nil
		end
	else
		v2[data.Root] = nil
	end
end

function Doughnut(p)
	local target = p.Target
	PeodizService.HeartbeatWait({
		Time = 10,
		WaitTime = 0.1
	}, function()
		local ray = Ray.new(target.Position, (Vector3.new(0, -7.5, 0)))
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		if not (raycastResult and raycastResult.Position) then
			local _ = ray.Origin + ray.Direction
		end

		if instance and target:IsDescendantOf(workspace.Effects) then
			target.Attachment.ParticleEmitter.Color = ColorSequence.new(instance.Color)
			target.Attachment.ParticleEmitter.Enabled = true
		elseif not instance and target:IsDescendantOf(workspace.Effects) then
			target.Attachment.ParticleEmitter.Enabled = false
		end

		if target and target.Parent then
			return
		else
			return true
		end
	end)
end

function DoughB(p)
	local startCF = p.StartCF

	if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 750 then
		return
	end

	if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 90 then
		spawn(function()
			TweenService:Create(
				game.Lighting.Blur,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = 8
				}
			):Play()
			wait(0.5)
			TweenService:Create(
				game.Lighting.Blur,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = 0
				}
			):Play()
		end)
		v:Shake(CameraShaker.Presets.Mochi1)
	end

	spawn(function()
		for _ = 1, math.random(10, 15) do
			local cFrame = startCF * CFrame.Angles(
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random()
			)
			local clone = fruitEffect.Dough.Spark:Clone()
			clone.Size = Vector3.new(15, 15, 1)
			clone.BrickColor = BrickColor.new("Institutional white")
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local v4 = math.random(20, 70)
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0), {
				Size = Vector3.new(0, 0, v4),
				CFrame = cFrame * CFrame.new(0, 0, -100)
			}):Play()
			TweenService:Create(
				clone,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.25),
				{
					Transparency = 1
				}
			):Play()
			_G.PU:Dust(clone, 1)
		end
	end)
	local clone = fruitEffect.Dough.Shockwave3:Clone()
	clone.CFrame = startCF - Vector3.new(0, 1.5, 0)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6326691525",
		Volume = 0.5,
		PlaybackSpeed = 1.25
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6326692549",
		Volume = 0.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	spawn(function()
		for _ = 1, 4 do
			local clone2 = fruitEffect.Dough.Wind:Clone()
			clone2.CFrame = startCF * CFrame.Angles(
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random()
			)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(200, 2, 200)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 1)
			wait()
		end
	end)
	spawn(function()
		for _ = 1, 12 do
			local clone2 = fruitEffect.Dough.Shockwave4:Clone()
			clone2.CFrame = startCF * CFrame.Angles(
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random(),
				math.pi * 2 * math.random()
			)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = Vector3.new(200, 2, 200)
			}):Play()
			_G.PU:Dust(clone2, 1)
		end
	end)
	_G.PU:Dust(clone, 1)
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
		CFrame = startCF - Vector3.new(0, 1.5, 0) + Vector3.new(0, 50, 0),
		Size = Vector3.new(2, 100, 2)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.1), {
		Transparency = 1
	}):Play()
	local flag = true

	for i = 1, 15 do
		local ray = Ray.new(
			(startCF * CFrame.Angles(0, math.pi * 2 * i / 15, 0) * CFrame.new(0, 0, -50)).Position,
			(Vector3.new(0, -30, 0))
		)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if not instance then
			continue
		end

		if flag then
			clone.Attachment2.rocks:Emit(30)
			flag = false
		end

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(0, 0, 0)
		part.CFrame = CFrame.new(startCF.X, position.Y, startCF.Z)
		part.Material = instance.Material
		part.MaterialVariant = instance.MaterialVariant
		part.BrickColor = instance.BrickColor
		part.Size = Vector3.new(13, 13, 13)
		part.Parent = workspace.Effects
		TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			CFrame = CFrame.new(position) * CFrame.Angles(
				math.pi * math.random(),
				math.pi * math.random(),
				math.pi * math.random()
			)
		}):Play()
		_G.PU:Dust(part, 3)
	end
end

function GumZ(p)
	local v3 = p.StartCF * CFrame.new(1.5, 0.5, 0)
	PeodizService.ForLoop({
		Step = 5
	}, function(p2)
		local v4 = math.floor(p2 * 5)
		local v5 = v3 * CFrame.new(0, 0, v4 * -8)
		coroutine.wrap(function()
			for _ = 0, math.random(3, 5) do
				local part = Instance.new("Part")
				part.Anchored = true
				part.Transparency = 0.15
				part.Material = Enum.Material.SmoothPlastic
				part.BrickColor = BrickColor.new("Really black")
				part.CanCollide = false
				part.Size = Vector3.new(0.125, 0.125, 6)
				part.CFrame = v5 * CFrame.new(
					math.random(-100, 100) / 100 * 1.25,
					math.random(-100, 100) / 100 * 1.25,
					math.random(-100, 100) / 100 * 1.5
				)
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
					CFrame = part.CFrame * CFrame.new(0, 0, -5)
				}):Play()
				TweenService:Create(
					part,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0.1, false),
					{
						Transparency = 1
					}
				):Play()
				_G.PU:Dust(part, 1)
			end
		end)()
	end)
end

function GumX(p)
	local startCF = p.StartCF
	v:Shake(CameraShaker.Presets.Bump)

	for i = 1, 2 do
		local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.BazookaRing:Clone()
		clone.CFrame = startCF * CFrame.new(0, 0, -(i == 1 and 3 or i * 6)) * CFrame.Angles(math.pi / 2, 0, 0)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
			Size = Vector3.new(15 + (i == 1 and 0 or i * 6.5), 1, 15 + (i == 1 and 0 or i * 6.5)),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1.5)
	end

	coroutine.wrap(function()
		for _ = 1, math.random(3, 5) do
			local cFrame = startCF * CFrame.new(0, 0, -5) * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-60, 60))),
				0
			)
			local clone = fruitEffect.Dough.Spark:Clone()
			clone.Size = Vector3.new(1.25, 1.25, 1)
			clone.BrickColor = BrickColor.new("Institutional white")
			clone.CFrame = cFrame
			clone.Transparency = 0.1
			clone.Parent = workspace.Effects
			local v4 = math.random(7.5, 15)
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0), {
				Size = Vector3.new(0, 0, v4),
				CFrame = cFrame * CFrame.new(0, 0, 20)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1)
		end
	end)()
	coroutine.wrap(function()
		PeodizService.ForLoop({
			Step = 5
		}, function(p2)
			local v3 = math.floor(p2 * 5)
			local v4 = startCF * CFrame.new(0, 0, v3 * -2)
			coroutine.wrap(function()
				for _ = 0, math.random(1, 4) do
					local part = Instance.new("Part")
					part.Anchored = true
					part.Transparency = 0.3
					part.Material = Enum.Material.SmoothPlastic
					part.BrickColor = BrickColor.new("Institutional white")
					part.CanCollide = false
					part.Size = Vector3.new(0.15, 0.15, 6)
					part.CFrame = v4 * CFrame.new(
						math.random(-100, 100) / 100 * 6,
						math.random(-100, 100) / 100 * 6,
						math.random(-100, 100) / 100 * 2.5
					)
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
						CFrame = part.CFrame * CFrame.new(0, 0, -5)
					}):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0.1, false),
						{
							Transparency = 1
						}
					):Play()
					_G.PU:Dust(part, 1)
				end
			end)()
		end)
	end)()
end

function GumZ2(data)
	local size = data.Size or 3
	wait(0.1)
	PeodizService.ForLoop({
		Step = 5
	}, function(p)
		local v3 = math.floor(p * 5)
		local v4 = data.Target.CFrame * (data.CF or CFrame.new()) * CFrame.new(0, 0, v3 * 5)
		coroutine.wrap(function()
			for _ = 0, math.random(1, 4) do
				local part = Instance.new("Part")
				part.Anchored = true
				part.Transparency = 0.15
				part.Material = Enum.Material.SmoothPlastic
				part.BrickColor = BrickColor.new("Really black")
				part.CanCollide = false
				part.Size = Vector3.new(0.125, 0.125, 6)
				part.CFrame = v4 * CFrame.new(
					math.random(-100, 100) / 100 * size,
					math.random(-100, 100) / 100 * size,
					math.random(-100, 100) / 100 * 1.5
				)
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
					CFrame = part.CFrame * CFrame.new(0, 0, -5)
				}):Play()
				TweenService:Create(
					part,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0.1, false),
					{
						Transparency = 1
					}
				):Play()
				_G.PU:Dust(part, 1)
			end
		end)()
	end)
end

function GumC(p)
	local cFrame = p.StartCF * CFrame.new(1.5, 0.5, 0)
	local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.Shockwave:Clone()
	clone.CFrame = cFrame
	clone.Size = Vector3.new(10, 10, 10)
	clone.Transparency = 0.25
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		Size = Vector3.new(40, 40, 30)
	}):Play()
	_G.PU:Dust(clone, 2)
	PeodizService.ForLoop({
		Step = 30
	}, function(p2)
		local v4 = math.floor(p2 * 30)
		clone.CFrame = cFrame * CFrame.new(0, 0, -math.sin(math.pi / 2 * v4 / 30) * 40) * CFrame.Angles(0, math.pi, 0)
		clone.CFrame *= CFrame.Angles(0, 0, math.pi * 4 * v4 / 30)

		if v4 % 3 == 1 and v4 <= 17 then
			local clone2 = ReplicatedStorage2.Chest.FruitEffect.NewGum.Wind2:Clone()
			clone2.CFrame = cFrame * CFrame.new(0, 0, -math.sin(math.pi / 2 * v4 / 30) * 40) * CFrame.Angles(
				math.pi / 2,
				0,
				0
			)
			clone2.Transparency = 0.65
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
				Size = Vector3.new(35, 1, 35),
				Transparency = 1
			}):Play()
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
		end
	end)
end

function GumZ_Second(data)
	local startCF = data.StartCF
	local dist = data.Dist
	local _ = data.Target
	v:Shake(CameraShaker.Presets.Bump)
	local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.Pistol:Clone()
	clone.Size = Vector3.new(0, 0, 0)
	clone.CFrame = startCF
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		Size = Vector3.new(1.25, 1.25, dist),
		CFrame = startCF * CFrame.new(0, 0, -dist / 2)
	}):Play()
	coroutine.wrap(function()
		wait(0.15)
		TweenService:Create(clone, TweenInfo.new(0.096, Enum.EasingStyle.Sine), {
			Size = Vector3.new(0, 0, dist),
			Transparency = 1
		}):Play()
	end)()
	local clone2 = ReplicatedStorage2.Chest.FruitEffect.NewGum.PistolWave:Clone()
	clone2.CFrame = startCF * CFrame.new(0, 0, -1.5) * CFrame.Angles(math.pi / 2, 0, 0)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = Vector3.new(7, 0.3, 7),
		CFrame = clone2.CFrame * CFrame.Angles(0, math.pi, 0)
	}):Play()
	coroutine.wrap(function()
		wait(0.09999999999999999)
		TweenService:Create(clone2, TweenInfo.new(0.16, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)()
	local clone3 = ReplicatedStorage2.Chest.FruitEffect.NewGum.PistolWind:Clone()
	clone3.CFrame = startCF * CFrame.new(0, 0, -5) * CFrame.Angles(math.pi / 2, 0, 0)
	clone3.Parent = workspace.Effects
	TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {
		Size = Vector3.new(13, 0.65, 13),
		CFrame = clone3.CFrame * CFrame.Angles(0, -math.pi, 0)
	}):Play()
	coroutine.wrap(function()
		wait(0.16666666666666666)
		TweenService:Create(clone3, TweenInfo.new(0.16, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)()
	local clone4 = ReplicatedStorage2.Chest.FruitEffect.NewGum.PistolShockwave:Clone()
	clone4.CFrame = startCF * CFrame.new(0, 0, -5) * CFrame.Angles(0, math.pi, 0)
	clone4.Parent = workspace.Effects
	TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		Size = Vector3.new(4, 4, dist),
		CFrame = startCF * CFrame.new(0, 0, -10 - dist / 2) * CFrame.Angles(0, math.pi, 0)
	}):Play()
	TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone4, 1.5)
	_G.PU:Dust(clone3, 1.5)
	_G.PU:Dust(clone2, 1.5)
	_G.PU:Dust(clone, 1.5)
end

function Bump(p)
	local type2 = p.Type or "Bump"
	v:Shake(CameraShaker.Presets[type2])
end

function GumTrans(p)
	local startCF = p.StartCF

	for _ = 1, 15 do
		local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.Shockwave4:Clone()
		clone.CFrame = CFrame.new(startCF.Position) * CFrame.Angles(
			math.pi * 2 * math.random(),
			math.pi * 2 * math.random(),
			math.pi * 2 * math.random()
		)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = Vector3.new(40, 1, 40),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)
	end

	local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.SwirlShockwave:Clone()
	clone.CFrame = CFrame.new(startCF.Position) * CFrame.Angles(
		math.pi * 2 * math.random(),
		math.pi * 2 * math.random(),
		math.pi * 2 * math.random()
	)
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
		Size = Vector3.new(40, 40, 40),
		Transparency = 1,
		CFrame = CFrame.new(startCF.Position) * CFrame.Angles(
			math.pi * 2 * math.random(),
			math.pi * 2 * math.random(),
			math.pi * 2 * math.random()
		)
	}):Play()
	_G.PU:Dust(clone, 1)
	local clone2 = ReplicatedStorage2.Chest.FruitEffect.NewGum.Cylinder:Clone()
	clone2.CFrame = CFrame.new(startCF.Position) * CFrame.Angles(0, 0, math.pi / 2)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		Size = Vector3.new(50, 50, 50),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone2, 1)
end

function GumX_Second(p)
	local startCF = p.StartCF

	for i = 0, 1 do
		local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.BazookaWave:Clone()
		clone.CFrame = startCF * CFrame.new(0, 0, -i * 2.5) * CFrame.Angles(math.pi / 2, 0, 0) * CFrame.Angles(
			0,
			math.pi * 2 * math.random(),
			0
		)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), {
			Size = Vector3.new((i + 1) * 15, 1.25, (i + 1) * 15)
		}):Play()
		TweenService:Create(
			clone,
			TweenInfo.new((i + 1) * 0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0.1),
			{
				Transparency = 1
			}
		):Play()
		_G.PU:Dust(clone, 1)
	end

	for _ = 1, math.random(8, 16) do
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(0.05, 0.05, 1)
		part.CFrame = startCF * CFrame.new(math.random(-15, 15), math.random(-5, 5), math.random(1, 5))
		part.Material = "Neon"
		part.BrickColor = BrickColor.new("Institutional white")
		part.Parent = workspace.Effects
		TweenService:Create(part, TweenInfo.new(1.15, Enum.EasingStyle.Exponential), {
			Size = Vector3.new(0.1, 0.1, math.random(5, 15)),
			CFrame = part.CFrame * CFrame.new(0, 0, -25)
		}):Play()
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(part, 1)
	end

	local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.BazookaWind:Clone()
	clone.CFrame = startCF * CFrame.Angles(-math.pi / 2, 0, 0) * CFrame.Angles(0, math.pi * 2 * math.random(), 0)
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		Size = Vector3.new(35.333, 31.056, 35.082),
		CFrame = startCF * CFrame.new(0, 0, -12) * CFrame.Angles(-math.pi / 2, 0, 0)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.17, Enum.EasingStyle.Sine), {
		Transparency = 1
	}):Play()
	coroutine.wrap(function()
		local lastTime = tick()

		repeat
			wait()
			TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Sine), {
				CFrame = clone.CFrame * CFrame.Angles(0, math.pi / 2, 0)
			}):Play()
		until tick() - lastTime >= 0.5 or not clone:IsDescendantOf(workspace.Effects)
	end)()
	_G.PU:Dust(clone, 1)
end

function GumClone(p)
	local target = p.Target

	for _, part in pairs(target:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
			continue
		end

		local clone = part:Clone()
		clone.Anchored = true
		clone.CanCollide = false

		for _, child in pairs(clone:GetChildren()) do
			if not (child:IsA("Motor6D") or child:IsA("Weld") or child:IsA("Attachment") or child:IsA("ParticleEmitter")) then
				continue
			end

			child:Destroy()
		end

		clone.Transparency = 0
		clone.Parent = workspace.Effects
		TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.15),
			{
				Transparency = 1
			}
		):Play()
		_G.PU:Dust(clone, 1)
	end
end

local v3 = {}

function GumGatling(p)
	local target = p.Target
	local type2 = p.Type
	tick()

	if type2 then
		if not v3[target] then
			v3[target] = true
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.05
			}, function()
				if not (v3[target] and target and target:IsDescendantOf(workspace)) then
					return true
				end

				local cFrame = target.HumanoidRootPart.CFrame * CFrame.new(math.random(-4, 4), math.random(-2, 2), 0)
				local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.Gatling:Clone()
				clone.CFrame = cFrame
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
					Size = Vector3.new(0.4, 0.4, 25),
					CFrame = cFrame * CFrame.new(0, 0, -12.5)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
				coroutine.wrap(function()
					wait(0.05)
					local clone2 = ReplicatedStorage2.Chest.FruitEffect.NewGum.GatlingRing:Clone()
					clone2.CFrame = cFrame * CFrame.new(0, 0, -25) * CFrame.Angles(math.pi / 2, 0, 0)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
						Size = Vector3.new(15, 0.5, 15),
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone2, 0.5)
				end)()
				_G.PU:Dust(clone, 0.5)
			end)
			v3[target] = nil
		end
	else
		v3[target] = nil
	end
end

function GumSoru(data)
	local lastCF = data.LastCF
	local newCF = data.NewCF
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 250,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://303967360",
		Volume = 0.5,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = data.Target
	sound:Play()
	spawn(function()
		for i = 1, 2 do
			local cframe = CFrame.new(lastCF.p)

			if i == 2 then
				cframe = CFrame.new(newCF.p)
			end

			local clone = ReplicatedStorage2.Chest.FruitEffect.NewGum.SoruShockwave:Clone()
			clone.CFrame = cframe - Vector3.new(0, 2, 0)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(13.003, 1.802, 13.724),
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
			}):Play()
			local clone2 = ReplicatedStorage2.Chest.FruitEffect.NewGum.SoruWind:Clone()
			clone2.CFrame = cframe
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.125, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(11.6684, 12.9177, 10.96625),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
			}):Play()
			_G.PU:Dust(clone2, 1)
			_G.PU:Dust(clone, 1)
		end
	end)
end

local v4 = {}

function GumFly(p)
	local target = p.Target

	if p.Type then
		if not v4[target] then
			v4[target] = true
			local humanoidRootPart = target.HumanoidRootPart
			local flag = true

			while wait() do
				if flag then
					flag = false
					local clone = game.ReplicatedStorage.Chest.FruitEffect.NewGum.FlyRing:Clone()
					clone.Parent = workspace.Effects
					clone.Size = Vector3.new()
					clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(math.rad(90), 0, 0)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(clone, TweenInfo.new(0.25), {
						Size = Vector3.new(15, 0.2, 15),
						Color = Color3.fromRGB(212, 208, 156),
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone, 0.25)
					delay(0.25, function()
						flag = true
					end)
				end

				if not (v4[target] and target and target:IsDescendantOf(workspace)) then
					break
				end
			end

			v4[target] = nil
		end
	else
		v4[target] = nil
	end
end

function StopAnimation(p)
	local character = localPlayer.Character

	if not (character and p) then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	_G.StopAnimationClient(humanoid, p)
end

ReplicatedStorage2.Chest.Remotes.Events.AttackMover.OnClientEvent:Connect(function(childName)
	if script.Mover:FindFirstChild(childName) then
		local module = require(script.Mover[childName])
		module()
	end
end)
peodizEvent.OnClientEvent:Connect(function(childName, options)
	local v5 = options or {}

	if type(v5) == "table" then
		local player = v5.Player

		if _G.ReturnEffects(localPlayer, player) then
			return
		end

		local success, result = pcall(function()
			local startCF = v5.StartCF or v5.EndCF

			if startCF then
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude > 2000 then
					return true
				end
			else
				local startPos = v5.StartPos or v5.EndPos or v5.Position

				if not startPos then
					return
				end

				if (localPlayer.Character.HumanoidRootPart.Position - startPos).Magnitude > 2000 then
					return true
				end
			end
		end)

		if success and result == true then
			return
		end
	end

	local child = script.Modules:FindFirstChild(childName)

	if child then
		local module = require(child)
		module(v5)
	else
		if childName == "GumFly" then
			GumFly(v5)
			return
		elseif childName == "GumSoru" then
			GumSoru(v5)
			return
		elseif childName == "GumGatling" then
			GumGatling(v5)
			return
		elseif childName == "GumClone" then
			GumClone(v5)
			return
		elseif childName == "GumX_Second" then
			GumX_Second(v5)
			return
		elseif childName == "GumTrans" then
			GumTrans(v5)
			return
		elseif childName == "Bump" then
			Bump(v5)
			return
		elseif childName == "GumC" then
			GumC(v5)
			return
		elseif childName == "GumZ" then
			GumZ(v5)
			return
		end

		if childName == "GumZ_Second" then
			GumZ_Second(v5)
		end

		if childName == "GumZ2" then
			GumZ2(v5)
			return
		elseif childName == "GumX" then
			GumX(v5)
			return
		elseif childName == "Kaido" then
			KaidoEffect(v5)
			return
		elseif childName == "Dough1" then
			DoughEffect1(v5)
			return
		elseif childName == "Dough2" then
			DoughEffect2(v5)
			return
		elseif childName == "BigExplosion" then
			BigExplosion(v5)
			return
		elseif childName == "DoughB" then
			DoughB(v5)
			return
		elseif childName == "SmallExplosion" then
			SmallExplosion(v5)
			return
		elseif childName == "DoughFist" then
			Dough_Fist(v5)
			return
		elseif childName == "DoughFloor" then
			Dough_Floor(v5)
			return
		elseif childName == "DoughC" then
			DoughC(v5)
			return
		elseif childName == "Explosion" then
			Explosion1(v5)
			return
		elseif childName == "StopAnimation" then
			StopAnimation(v5)
			return
		elseif childName == "DoughCage" then
			DoughCage(v5)
			return
		elseif childName == "DoughV" then
			DoughV(v5)
			return
		elseif childName == "DoughArm" then
			Dough_Arm(v5)
			return
		elseif childName == "Gura1" then
			Gura1(v5)
			return
		elseif childName == "Doughnut" then
			Doughnut(v5)
			return
		elseif childName == "Gura2" then
			return
		elseif childName == "EarthQuake" then
			EarthQuake(v5)
			return
		elseif childName == "180oGura" then
			GuraC(v5)
			return
		elseif childName == "180oGura2" then
			GuraCShake(v5)
			return
		elseif childName == "Gura4" then
			Gura4(v5)
			return
		elseif childName == "GuraShake" then
			GuraShake(v5)
			return
		end

		if childName ~= "GuraB" then
			return
		end

		GuraB(v5)
	end
end)
local UserInputService = game:GetService("UserInputService")
local yield = ReplicatedStorage2.Chest.Remotes.Functions:WaitForChild("Yield")

yield.OnClientInvoke = function()
	return true
end

local getMouse = ReplicatedStorage2.Chest.Remotes.Functions:WaitForChild("GetMouse")

getMouse.OnClientInvoke = function(value, p)
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local v5 = value or 100
	local ray = Ray.new(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * (v5 + (currentCamera.CFrame.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude)
	)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Effects, unpack(p or { nil }) }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
	local _ = raycastResult and raycastResult.Instance
	local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

	if UserInputService.TouchEnabled then
		local ray2 = Ray.new(
			localPlayer.Character.HumanoidRootPart.Position,
			CFrame.new(localPlayer.Character.HumanoidRootPart.Position, _G.MouseHit.p).LookVector * v5
		)
		local raycastResult2 = workspace:Raycast(ray2.Origin, ray2.Direction, raycastParams)
		local instance

		if raycastResult2 then
			instance = raycastResult2.Instance or nil
		end

		position = raycastResult2 and raycastResult2.Position or ray2.Origin + ray2.Direction
	end

	return {
		Hit = _G.MouseHit,
		Hit2 = position
	}
end

local getMouseMobile = ReplicatedStorage2.Chest.Remotes.Functions:WaitForChild("GetMouseMobile")

getMouseMobile.OnClientInvoke = function(_, _)
	_G.MouseHitMobileUpdate()
	return {
		Hit = game.Players.LocalPlayer:GetMouse().Hit,
		Hit2 = _G.MouseHitMobile.p
	}
end

local characterWorkshop = workspace:WaitForChild("CharacterWorkshop")

function ThrowHook(player)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Island }
	local hook = player.Hook
	local character = player.Character
	local fishingRod = player.FishingRod
	local lastTime = os.clock()

	while true do
		local v5 = task.wait()
		hook.AssemblyLinearVelocity -= Vector3.new(0, (player.DropSpeed or 100) * v5, 0)

		if not (character:IsDescendantOf(workspace.PlayerCharacters) and character:GetAttribute("Fishing") and fishingRod:IsDescendantOf(characterWorkshop)) then
			break
		end

		if os.clock() - lastTime > 10 then
			break
		end

		local raycastResult = workspace:Raycast(hook.Position, Vector3.new(0, -5, 0), raycastParams)

		if not (hook.Position.Y < -3.35) or raycastResult then
			continue
		end

		hook.LinearVelocity.Enabled = true
		hook.AssemblyAngularVelocity = Vector3.zero
		return true
	end
end

ReplicatedStorage2:WaitForChild("Chest"):WaitForChild("Modules")
local MaterialList = require(ReplicatedStorage2.Chest.Modules.MaterialList)

function Fishing(data)
	local fish = data.Fish
	local fishingRod = data.FishingRod
	local v5 = 0
	local flag = nil
	local lastTime = tick()
	local connections = {}
	table.insert(connections, UserInputService.InputBegan:Connect(function(input)
		local userInputType = input.UserInputType
		local keyCode = input.KeyCode

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch or keyCode == Enum.KeyCode.ButtonR2 then
			lastTime = tick()
			v5 = 0
			flag = true
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType
		local keyCode = input.KeyCode

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch or keyCode == Enum.KeyCode.ButtonR2 then
			lastTime = tick()
			v5 = 0
			flag = nil
		end
	end))
	local clone = ReplicatedStorage2.Chest.Etc.Fishing.FishingUI:Clone()
	local fishingBackground = clone:WaitForChild("FishingBackground")
	local fishLabel = fishingBackground:WaitForChild("FishLabel")
	local fishingBar = fishingBackground:WaitForChild("FishingBar")
	local progressBackground = fishingBar:WaitForChild("ProgressBackground")
	local v6 = 0
	local v7 = not MaterialList[fish] and "rbxassetid://72993449565996" or MaterialList[fish].Image or "rbxassetid://72993449565996"
	local _ = MaterialList[fish] and MaterialList[fish].Image
	local image = fish == "WhirlpoolBeast" and "rbxassetid://88523269369843" or v7
	fishLabel.Icon.IconColor.Image = image
	clone.Parent = game.Players.LocalPlayer.PlayerGui
	local lastTime2 = tick()
	local v9 = 0
	local progressBar = progressBackground:WaitForChild("ProgressBar")
	fishingBar.Size = UDim2.new(
		data.BarSize or 0.5,
		fishingBar.Size.X.Offset,
		fishingBar.Size.Y.Scale,
		fishingBar.Size.Y.Offset
	)

	local function UpdateProgressBar()
		local v10 = math.clamp(v9 / 100 - 0.5, -0.5, 0.5)
		progressBar.UIGradient.Offset = Vector2.new(v10, 0)
		local v11 = math.clamp(v9 / 100, 0, 1)
		progressBar.BackgroundColor3 = Color3.fromRGB(255 - math.floor(v11 * 255), math.floor(v11 * 255), 0)
	end

	local function IsFishInBar()
		if (fishLabel.AbsolutePosition - fishingBar.AbsolutePosition - fishingBar.AbsoluteSize / 2 + fishLabel.AbsoluteSize / 2):Abs().X < fishingBar.AbsoluteSize.X / 2 then
			return true
		end
	end

	local v10 = math.random(100, 200) / 100
	local lastTime3 = tick()
	UpdateProgressBar()

	while true do
		local v11 = RunService.Heartbeat:Wait()
		v5 = math.min(v5 + v11 / 1, 1)
		local v12 = fishingBackground.AbsoluteSize.X * 0.003
		local v13 = fishingBackground.AbsoluteSize.X / 2
		local v14 = fishingBackground.FishingBar.AbsoluteSize.X / 2

		if flag then
			v12 = -v12
			fishingBar.Right.Visible = true
			fishingBar.Left.Visible = nil
		else
			fishingBar.Right.Visible = nil
			fishingBar.Left.Visible = true
		end

		if v10 < tick() - lastTime3 then
			lastTime3 = tick()
			local v15 = fishingBackground.AbsoluteSize.X / 2
			local v16 = math.random(-v15 + fishLabel.AbsoluteSize.X / 2, v15 - fishLabel.AbsoluteSize.X / 2)
			TweenService:Create(fishLabel, TweenInfo.new(2), {
				Position = UDim2.new(0.5, v16, fishLabel.Position.Y.Scale, 0)
			}):Play()
		end

		local v16 = v12 * (1 * TweenService:GetValue(
			(tick() - lastTime) / 1,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		) * TweenService:GetValue(v5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
		v6 = math.clamp(v6 - v16 * (v11 * 225), -v13 + v14, v13 - v14)
		fishingBackground.FishingBar.Position = UDim2.new(0.5, v6, 0.5, 0)
		fishLabel.Icon.Rotation = math.sin(tick() / 0.075) * 25 + 40
		local v17 = -((data.RodPower or 10) * v11) * 2.5

		if IsFishInBar() then
			v17 = (data.RodPower or 10) * v11 * 2
		end

		v9 = math.clamp(v9 + v17, 0, 100)

		if tick() - lastTime2 > 2 and v9 <= 0 or v9 >= 100 or not fishingRod:IsDescendantOf(characterWorkshop) then
			clone:Destroy()

			for _, connection in pairs(connections) do
				connection:Disconnect()
			end

			if v9 >= 100 then
				return true
			else
				break
			end
		else
			UpdateProgressBar()
		end
	end
end

ReplicatedStorage2.Chest.Remotes.Functions.Response.OnClientInvoke = function(p, p2)
	if p == "ThrowHook" then
		return ThrowHook(p2)
	elseif p == "Fishing" then
		return Fishing(p2)
	end
end

local playerScripts = localPlayer:WaitForChild("PlayerScripts")
local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

function InvertControl(p)
	local time = p.Time or 10

	function controls.moveFunction(p2, p3, p4)
		localPlayer.Move(p2, -p3, p4)
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Parent = game.Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.5), {
		TintColor = Color3.fromRGB(255, 131, 131)
	}):Play()
	_G.PU:Dust(colorCorrectionEffect, time + 2)
	wait(time)
	controls.moveFunction = localPlayer.Move
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.5), {
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
end