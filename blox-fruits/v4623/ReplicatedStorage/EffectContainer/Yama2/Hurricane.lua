local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local yamaSkill2 = FX:WaitForChild("Yama").YamaSkill2
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	destroyAfter(instance, value or 60)
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function safeSetRootCFrame(instance, cFrame: CFrame, flag: boolean)
	local v = flag == nil or flag

	if instance == nil then
		return
	end

	local bodyPosition = instance:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 1000 or instance.Anchored == true then
		return
	end

	if not v then
		instance.CFrame = cFrame
		return
	end

	local raycastResult = Workspace:Raycast(instance.Position, cFrame.Position - instance.Position, raycastParams)

	if raycastResult then
		instance.CFrame = instance.CFrame.Rotation + raycastResult.Position - (cFrame.Position - instance.Position).Unit * 0.2
	else
		instance.CFrame = cFrame
	end
end

local function snapProjectileToFinalPos(folder, p)
	folder.CFrame = folder.CFrame.Rotation + p

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	folder.Transparency = 1
end

local function fireClientProjectile(p, p2, instance, callback, part)
	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p2, p2, p2) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002))
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p3)
		if instance:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(callback(p3), callback(p3 + 0.01))
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos"))
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1))
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local origin = data.origin
	local parent = _WorldOrigin

	if data.holdEffect then
		if player == localPlayer then
			Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
		end

		local clone = yamaSkill2.HoldStart:Clone()
		clone.CFrame = hrp.CFrame
		destroyAfter(clone, 3)
		clone.Parent = parent

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	else
		local cframe = CFrame.new(origin, data.fireDirValue.Value)
		local dashRange = data.dashRange
		TweenService:Create(hrp, TweenInfo.new(0.125), {
			CFrame = CFrame.new(data.fireDirValue.Value) * (cframe - cframe.p)
		}):Play()
		local clone = yamaSkill2.StartImpact:Clone()
		clone.CFrame = cframe
		clone.Parent = parent
		destroyAfter(clone, 2)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			coroutine.wrap(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)()
		end

		local _, v2 = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(
				cframe.Position,
				CFrame.new(cframe.Position, (cframe * CFrame.new(0, 0, -dashRange)).Position).LookVector * dashRange
			),
			raycastParams.FilterDescendantsInstances
		)
		local clone2 = yamaSkill2.Start:Clone()
		clone2.CFrame = cframe
		clone2.Massless = true
		clone2.Parent = parent
		clone2.Weld.Part0 = hrp

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		coroutine.wrap(function()
			local clone3 = yamaSkill2.Start2:Clone()
			clone3.CFrame = cframe * CFrame.new(0, 0, -dashRange / 3)
			clone3.Parent = parent

			for _, emitter in ipairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				coroutine.wrap(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount"))
				end)()
			end

			destroyAfter(clone3, 2)
		end)()
		coroutine.wrap(function()
			task.wait(0.15)
			clone2.Weld:Destroy()
			clone2.Anchored = true

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(clone2, 2)
		end)()
		coroutine.wrap(function()
			task.wait(0.05)
			local magnitude = (cframe.Position - v2).Magnitude
			local cFrame = CFrame.new(cframe.Position, v2) * CFrame.new(0, 0, -magnitude)
			local position = cFrame.Position
			local part, v4 = Workspace:FindPartOnRayWithIgnoreList(
				Ray.new(
					position + createVector(0, 0.5, 0),
					CFrame.new(position + createVector(0, 0.5, 0), position + createVector(0, -5, 0)).LookVector * 5
				),
				raycastParams.FilterDescendantsInstances
			)

			if part then
				for _ = 1, 2 do
					local clone3 = yamaSkill2.GroundSparks:Clone()
					clone3.CFrame = cFrame * CFrame.new(0, 0, 30) * CFrame.new(
						math.random(-10, 10),
						0,
						math.random(-30, 30)
					)
					clone3.Position = Vector3.new(clone3.Position.X, v4.Y, clone3.Position.Z)
					clone3.Parent = parent
					destroyAfter(clone3, 7)

					for _, emitter in ipairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					local folder = clone3
					coroutine.wrap(function()
						for i = 1, 10 do
							task.wait(0.075)
							folder.CFrame = cFrame * CFrame.new(0, 0, 30) * CFrame.new(
								math.random(-10, 10),
								0,
								math.random(-30, 30)
							)
						end

						for i, emitter in ipairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)()
				end
			end

			local clone3 = yamaSkill2.Tornado:Clone()
			local Z = clone3.Tornado2.Size.Z
			clone3.Tornado2.Size = Vector3.new(
				clone3.Tornado2.Size.X,
				clone3.Tornado2.Size.Y,
				(math.clamp(magnitude, 20, Z))
			)
			clone3.CFrame = cFrame
			clone3.Parent = parent
			destroyAfter(clone3, 7)
			clone3.Weld.C0 = clone3.Weld.Part0.CFrame:ToObjectSpace(clone3.Weld.Part1.CFrame) * CFrame.new(
				0,
				0.75,
				clone3.Tornado2.Size.Z / 40
			)

			for _, emitter in ipairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local clone4 = yamaSkill2.SpinMesh1:Clone()
			local Y = clone4.Size.Y
			clone4.Size = Vector3.new(
				math.clamp(magnitude, 25, 40),
				math.clamp(magnitude, 60, Y),
				(math.clamp(magnitude, 25, 40))
			)
			clone4.CFrame = cFrame * CFrame.new(0, 0, clone4.Size.Y / 2) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone4.Parent = parent
			local clone5 = yamaSkill2.SpinMesh2:Clone()
			clone5.Size = Vector3.new(
				math.clamp(magnitude, 25, 40),
				math.clamp(magnitude, 60, Y),
				(math.clamp(magnitude, 25, 40))
			)
			clone5.CFrame = cFrame * CFrame.new(0, 0, clone5.Size.Y / 2) * CFrame.Angles(1.5707963267948966, 0, 0)
			local tween = TweenService:Create(clone4, TweenInfo.new(0.1), {
				Size = clone4.Size
			})
			local tween2 = TweenService:Create(clone5, TweenInfo.new(0.1), {
				Size = clone5.Size
			})
			clone4.Size = Vector3.new(0, clone4.Size.Y, 0)
			clone5.Size = Vector3.new(0, clone5.Size.Y, 0)
			tween:Play()
			tween2:Play()
			coroutine.wrap(function()
				task.wait(0.1)
				local lastTime = os.clock()
				local v5 = time()

				for _ = 1, 600 do
					local v6 = math.random(13, 15) / 10
					local v7 = math.random(18, 20) / 10
					local v8 = math.random(10, 30) / 1000
					tween = TweenService:Create(
						clone4,
						TweenInfo.new(v8, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true),
						{
							Size = Vector3.new(clone4.Size.X * v6, clone4.Size.Y, clone4.Size.Z * v6)
						}
					)
					tween:Play()
					tween2 = TweenService:Create(
						clone5,
						TweenInfo.new(v8, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true),
						{
							Size = Vector3.new(clone5.Size.X * v7, clone5.Size.Y, clone5.Size.Z * v7),
							Color = Color3.fromRGB(0, 0, 0),
							Transparency = 1
						}
					)
					tween2:Play()
					task.wait(v8 + 0.05)

					if os.clock() - lastTime >= data.damageFor - 0.6 or time() - v5 > 10 then
						break
					end
				end

				task.wait(0.25)
				tween = TweenService:Create(clone4, TweenInfo.new(0.25), {
					Transparency = 0,
					Size = Vector3.new(0, clone4.Size.Y, 0)
				})
				tween:Play()
				tween2 = TweenService:Create(clone5, TweenInfo.new(0.15), {
					Transparency = 1,
					Size = Vector3.new(0, clone5.Size.Y, 0)
				})
				tween2:Play()
			end)()
			local lastTime = os.clock()
			local clonesByClone = {}

			for _ = 1, 4 do
				local clone6 = yamaSkill2.TornadoSlash:Clone()
				clone6:SetAttribute("Over", false)
				clonesByClone[clone6] = clone6
			end

			local v5 = Util.Sound:Play("WindFast", cFrame, 80, 1.4, 0.35)
			local lastTime2 = os.clock()
			local lastTime3 = tick()
			local v6 = time()
			local v7 = 0.016666666666666666

			for _ = 1, 600 do
				clone4.CFrame *= CFrame.Angles(0, v7 * -0.2181661564992912 * 60 * 1.3, 0)
				clone5.CFrame *= CFrame.Angles(0, v7 * -0.3490658503988659 * 60 * 1.3, 0)

				if tick() - lastTime3 > 0.08 then
					lastTime3 = tick()

					if part then
						Util.Sound:Play("QuickSlice", cFrame, 10, 1.25, 0.0666)
					end

					Util.Sound:Play("SpinWoosh", cFrame, 80, 1.5 + math.random(-42, 42) / 100, 0.275)
				end

				if os.clock() - lastTime2 >= 0.05 then
					for _, folder in pairs(clonesByClone) do
						if not (folder:GetAttribute("Over") == false and os.clock() - lastTime2 >= 0.05) then
							continue
						end

						folder:SetAttribute("Over", true)
						lastTime2 = os.clock()
						folder.CFrame = cFrame * CFrame.new(0, 0, (math.clamp(magnitude / 4, 5, 10))) * CFrame.new(
							0,
							0,
							math.random(-math.clamp(magnitude / 2, 15, 25), (math.clamp(magnitude / 2, 20, 50)))
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
						folder.Parent = parent
						local tween3 = TweenService:Create(
							folder,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = folder.CFrame * CFrame.new(0, -math.clamp(magnitude / 2, 5, 50), 0) * CFrame.Angles(
									0,
									-2.6179938779914944,
									0
								)
							}
						)
						tween3:Play()

						for _, descendant in ipairs(folder:GetDescendants()) do
							if descendant:IsA("Beam") then
								local tween4 = TweenService:Create(
									descendant,
									TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										CurveSize0 = descendant.CurveSize0 * 1.05,
										CurveSize1 = descendant.CurveSize1 * 1.05
									}
								)
								descendant.CurveSize0 /= 3
								descendant.CurveSize1 /= 3
								tween4:Play()
							elseif descendant:IsA("Attachment") then
								local tween4 = TweenService:Create(
									descendant,
									TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Position = Vector3.new(
											descendant.Position.X * 1.05,
											descendant.Position.Y * 1.05,
											descendant.Position.Z * 1.05
										)
									}
								)
								descendant.Position = Vector3.new(
									descendant.Position.X / 3,
									descendant.Position.Y / 3,
									descendant.Position.Z / 3
								)
								tween4:Play()
							end
						end

						local folder2 = folder
						local v9 = folder
						coroutine.wrap(function()
							tween3.Completed:Wait()

							for i, effect in ipairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or not effect:IsA("Beam") then
									continue
								end

								TweenService:Create(
									effect,
									TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true),
									{
										Width0 = 0,
										Width1 = 0
									}
								):Play()
							end

							folder2:SetAttribute("Over", false)
						end)()
					end
				end

				v7 = task.wait()

				if os.clock() - lastTime >= data.damageFor or time() - v6 > 10 then
					break
				end
			end

			for _, v8 in pairs(clonesByClone) do
				v8:Destroy()
			end

			destroyAfter(clone4, 2)
			destroyAfter(clone5, 2)
			Util.Sound:FadeOut(v5, 0.666)

			for _, effect in ipairs(clone3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = false
				end
			end
		end)()
	end
end