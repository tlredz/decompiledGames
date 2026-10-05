local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tushitaSkill1 = FX:WaitForChild("Tushita").TushitaSkill1
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

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 13, 0.2, 0.7)
	end

	local parent = _WorldOrigin
	local v2 = true
	coroutine.wrap(function()
		task.wait()
		local clone = tushitaSkill1.Barrage:Clone()
		clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -1.5)
		clone.Parent = parent
		destroyAfter(clone, 7)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, 0, -3)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone2 = tushitaSkill1.Impact:Clone()
		clone2.Parent = parent
		destroyAfter(clone2, 7)
		local clonesByClone = {}

		for _ = 1, 5 do
			local clone3 = tushitaSkill1.Sparks:Clone()
			clone3.Parent = parent
			clonesByClone[clone3] = clone3
		end

		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local lastTime3 = os.clock()
		local lastTime4 = os.clock()
		local lastTime5 = os.clock()
		local v3 = 0

		while true do
			if math.random(10, 20) / 1000 <= os.clock() - lastTime then
				lastTime = os.clock()
				clone2.CFrame = clone.CFrame * CFrame.new(0, 0, 7)

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v4 = emitter
					coroutine.wrap(function()
						task.wait(math.random(0, 30) / 200)

						if v2 == true then
							v4:Emit(v4:GetAttribute("EmitCount"))
						end
					end)()
				end
			end

			if os.clock() - lastTime2 >= 0.15 and v3 == 0 then
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(20, 20, 5)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(15, 15, 1.5)
				}):Play()
				clone2.Impact2.Size = createVector(20, 20, 25)
				clone2.Impact3.Size = createVector(20, 20, 60)
				local clone3 = tushitaSkill1.BarrageImpact1:Clone()
				clone3.CFrame = clone.CFrame * CFrame.new(0, 0, 4)
				clone3.Parent = parent
				destroyAfter(clone3, 3)
				v3 = 1

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			elseif os.clock() - lastTime2 >= 0.65 and v3 == 1 then
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(30, 30, 5)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(20, 20, 1.5)
				}):Play()
				clone2.Impact2.Size = createVector(30, 30, 25)
				clone2.Impact3.Size = createVector(30, 30, 60)
				local clone3 = tushitaSkill1.BarrageImpact2:Clone()
				clone3.CFrame = clone.CFrame * CFrame.new(0, 0, 4)
				clone3.Parent = parent
				destroyAfter(clone3, 3)
				v3 = 2

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for _, emitter in ipairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Destroy()
					end
				end

				for _, emitter in ipairs(clone2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:SetAttribute("EmitCount", 0)
					end
				end

				for _, child in ipairs(tushitaSkill1.BarrageStage2:GetChildren()) do
					local clone4 = child:Clone()
					clone4.Parent = clone
					clone4.Enabled = true
				end

				for _, child in ipairs(tushitaSkill1.ImpactStage2:GetChildren()) do
					local clone_2 = child:Clone()
					clone_2.Parent = clone2
				end
			elseif os.clock() - lastTime2 >= 1.25 and v3 == 2 then
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(40, 40, 5)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(30, 30, 1.5)
				}):Play()
				clone2.Impact2.Size = createVector(40, 40, 25)
				clone2.Impact3.Size = createVector(40, 40, 60)
				local clone3 = tushitaSkill1.BarrageImpact3:Clone()
				clone3.CFrame = clone.CFrame * CFrame.new(0, 0, 4)
				clone3.Parent = parent
				destroyAfter(clone3, 3)
				v3 = 3

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for _, emitter in ipairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Destroy()
					end
				end

				for _, emitter in ipairs(clone2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:SetAttribute("EmitCount", 0)
					end
				end

				for _, child in ipairs(tushitaSkill1.BarrageStage3:GetChildren()) do
					local clone4 = child:Clone()
					clone4.Parent = clone
					clone4.Enabled = true
				end

				for _, child in ipairs(tushitaSkill1.ImpactStage3:GetChildren()) do
					local clone_3 = child:Clone()
					clone_3.Parent = clone2
				end
			end

			if os.clock() - lastTime5 > 0.06666666666666667 then
				lastTime5 = os.clock()
				Util.Sound:Play("QuickSlice", clone2.CFrame)
			end

			if os.clock() - lastTime3 >= 0.075 then
				for _, folder in pairs(clonesByClone) do
					if folder:GetAttribute("Over") ~= false then
						continue
					end

					folder:SetAttribute("Over", true)
					lastTime3 = os.clock()
					local v4 = clone2.Size.X * 0.65
					local v5 = clone2.Size.Y * 0.5
					folder.CFrame = clone.CFrame * CFrame.new(math.random(-v4, v4), math.random(-v5, v5), 0)
					local raycastResult = Workspace:Raycast(
						folder.Position,
						folder.CFrame.LookVector * 70,
						raycastParams
					)

					if raycastResult then
						folder.Position = raycastResult.Position
						folder.CFrame *= CFrame.new(0, 0, 2.5)

						for _, emitter in ipairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						if os.clock() - lastTime4 >= 0.015 then
							lastTime4 = os.clock()
							local clone3 = tushitaSkill1.SparkCrack:Clone()
							clone3.CFrame = CFrame.new(
								raycastResult.Position,
								raycastResult.Position + raycastResult.Normal
							) * CFrame.new(0, 0, -0.1)
							clone3.Parent = parent
							destroyAfter(clone3, 3)

							for _, emitter in ipairs(clone3:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if emitter:GetAttribute("Color") then
									emitter.Color = ColorSequence.new(
										raycastResult.Instance.Color,
										raycastResult.Instance.Color
									)
								end

								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					else
						for _, emitter in ipairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					local folder2 = folder
					local v6 = folder
					coroutine.wrap(function()
						task.wait(0.075)

						for i, emitter in ipairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						task.wait()
						folder2:SetAttribute("Over", false)
					end)()
				end
			end

			RunService.Heartbeat:Wait()

			if v2 ~= false then
				continue
			end

			destroyAfter(clone2, 2)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(clone, 2)

			for _, v4 in pairs(clonesByClone) do
				destroyAfter(v4, 3)
			end

			break
		end
	end)()
	local bindableEvent = Instance.new("BindableEvent")
	local connection = nil
	connection = heartbeatLoopFor2(10, function()
		if data.skill1Held.Value ~= false then
			return
		end

		bindableEvent:Fire()
		connection:Disconnect()
		connection = nil
	end, function()
		bindableEvent:Fire()
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
	v2 = false

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
	end

	Util.Sound:Play("QuickSlice", hrp.CFrame)
	local clone = tushitaSkill1.RedSpike:Clone()
	clone:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(0, 0, 35) * CFrame.Angles(0, 3.141592653589793, 0))
	clone.Parent = parent
	destroyAfter(clone, 3)

	for _, child in ipairs(clone:GetChildren()) do
		local tween = TweenService:Create(child, TweenInfo.new(0.1), {
			CFrame = child.CFrame * CFrame.new(0, 0, 75),
			Size = Vector3.new(child.Size.X * 2, child.Size.Y * 2, child.Size.Z * 2)
		})
		tween:Play()
		local v3 = child
		coroutine.wrap(function()
			tween.Completed:Wait()
			tween = TweenService:Create(v3, TweenInfo.new(0.1), {
				CFrame = v3.CFrame * CFrame.new(0, 0, 70),
				Size = Vector3.new(0, 0, v3.Size.Z)
			})
			tween:Play()
			tween.Completed:Wait()
			tween = TweenService:Create(v3, TweenInfo.new(0.1), {
				CFrame = v3.CFrame * CFrame.new(0, 0, 10),
				Size = createVector(0, 0, 0)
			})
			tween:Play()
		end)()
	end

	local clone2 = tushitaSkill1.FinalImpactStart:Clone()
	clone2.CFrame = hrp.CFrame * CFrame.new(0, 0, -1)
	clone2.Parent = parent
	destroyAfter(clone2, 3)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local raycastResult = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 140, raycastParams)

	if raycastResult then
		local clone3 = tushitaSkill1.FinalSpark:Clone()
		clone3.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.new(
			0,
			0,
			-0.1
		)
		clone3.Parent = parent
		destroyAfter(clone3, 3)

		for _, emitter in ipairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("Color") then
				emitter.Color = ColorSequence.new(raycastResult.Instance.Color, raycastResult.Instance.Color)
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end