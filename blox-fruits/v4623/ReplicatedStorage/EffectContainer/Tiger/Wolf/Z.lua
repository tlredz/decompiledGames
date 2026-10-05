local createVector = vector.create
local _ = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local awakenedWolf_Z = FX:WaitForChild("TigerEffects").AwakenedWolf_Z
local _WorldOrigin = workspace._WorldOrigin
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailCurve(clone, startCFrame, position, position2, cframe, cframe2, p)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + startCFrame.LookVector) * cframe.Position
	local v3 = CFrame.new(position4, position4 + startCFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v4 = magnitude / p / 60
	local _ = (magnitude / p + p) / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local function HeadTime(folder, cFrame, folder2, raycastParams, projectileCF, proxy, root)
	task.spawn(function()
		task.wait(0.005)

		if root.Parent == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(1, 1, 0.05, 0.15)
		end

		local clone = awakenedWolf_Z.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone, folder2, folder, "LeopardFruitVFXColor")
		Util.Sound:Play("Spectral_Wolf_Release_0" .. tostring(math.random(1, 3)), clone.Position)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	end)
	task.spawn(function()
		local clone = awakenedWolf_Z.Phase1.Head:Clone()
		clone:PivotTo(cFrame)
		Util.SetParentOverrideWithColor(clone, folder2, folder, "LeopardFruitVFXColor")
		local primaryPart = clone.PrimaryPart
		primaryPart.CFrame = projectileCF

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local cFrame2 = primaryPart.CFrame
		local lookVector = cFrame2.LookVector
		local v = 50
		local position = cFrame2.Position
		local v2 = lookVector * 350
		local v3 = tick() + 1.5
		local cframe = cFrame2 - cFrame2.Position
		local v4 = tick() + 0.25
		local targeting = cFrame * CFrame.new(0, 0, -100).Position
		local now = tick()
		local heartbeatConnection = nil
		local position2 = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local DISTANCE_THRESHOLD = 0.1

			if v3 - tick() <= 0 or not proxy:IsDescendantOf(workspace) or proxy:GetAttribute("Exploding") then
				heartbeatConnection:Disconnect()
				local clone2 = awakenedWolf_Z.Phase2.Explosion:Clone()
				clone2.CFrame = primaryPart.CFrame
				Util.SetParentOverrideWithColor(clone2, folder2, folder, "LeopardFruitVFXColor")
				Util.Sound:Play("Spectral_Wolf_Explosion_0" .. tostring(math.random(1, 3)), clone2.Position)
				DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						if v5:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v5:GetAttribute("EmitDelay"))
						end

						v5:Emit(v5:GetAttribute("EmitCount") / 2)
					end)
				end

				TweenService:Create(
					clone2.Light.PointLight,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Brightness = 0
					}
				):Play()
				clone:Destroy()
			else
				if proxy:GetAttribute("Targeting") then
					if typeof(proxy:GetAttribute("Targeting")) == "Vector3" then
						local v5 = math.min((tick() - 0) / 0.25, 1)
						targeting = proxy:GetAttribute("Targeting")
						local v6 = targeting - position
						local _ = v6.Magnitude
						local unit = v6.Unit
						local unit2 = v2.Unit
						local unit3 = unit2:Cross(createVector(0, 1, 0)).Unit
						local v7 = unit3 * unit:Dot(unit3)
						local unit4 = (unit2 * 0.7 + v7 * 2).Unit
						local v8 = v5 * v5
						v2 = v2:Lerp(unit4 * 350, v8 * dt * 3)

						if v2.Magnitude > DISTANCE_THRESHOLD then
							local cframe2 = CFrame.lookAt(createVector(0, 0, 0), v2.Unit)
							cframe = cframe:Lerp(cframe2, v8 * dt * 4)
						end
					elseif proxy:FindFirstChild("TargetObject") then
						local targetObject = proxy:FindFirstChild("TargetObject")

						if targetObject and targetObject.Value then
							local v5 = math.min((tick() - 0) / 0.25, 1)
							targeting = targetObject.Value.Position
							local v6 = targeting - position
							local _ = v6.Magnitude
							local unit = v6.Unit
							local unit2 = v2.Unit
							local unit3 = unit2:Cross(createVector(0, 1, 0)).Unit
							local v7 = unit3 * unit:Dot(unit3)
							local unit4 = (unit2 * 0.7 + v7 * 2).Unit
							local v8 = v5 * v5
							v2 = v2:Lerp(unit4 * 350, v8 * dt * 3)

							if v2.Magnitude > DISTANCE_THRESHOLD then
								local cframe2 = CFrame.lookAt(createVector(0, 0, 0), v2.Unit)
								cframe = cframe:Lerp(cframe2, v8 * dt * 4)
							end
						end
					end
				end

				v -= 1000 * dt
				local v5 = v2 * dt
				local vector2 = Vector3.new(0, v * dt, 0)
				local position3 = position + v5 + vector2
				primaryPart.CFrame = CFrame.new(position3) * cframe
				local v6 = position3 - position
				local unit, raycastResult

				if v6.Magnitude > 0 then
					unit = v6.Unit
					raycastResult = workspace:Raycast(position - unit * 0.01, v6 + unit * 0.02, raycastParams)
				end

				local flag = false

				if raycastResult then
					position3 = raycastResult.Position
					v2 = ((unit - 2 * unit:Dot(raycastResult.Normal) * raycastResult.Normal) * createVector(1, 0, 1)).Unit * v2.Magnitude

					if v2.Magnitude > DISTANCE_THRESHOLD then
						cframe = CFrame.lookAt(createVector(0, 0, 0), v2.Unit)
					end

					if position3.Y > position.Y then
						flag = true
					end
				end

				position = position3

				if raycastResult or v4 - tick() <= 0 then
					local _ = now - tick() > 0
					now = tick() + 0.15
					local Y = position.Y
					v4 = tick() + 0.5

					if raycastResult == nil then
						Y = position3.Y
					end

					local v7 = math.abs(v) * 0.5
					local v8 = v7 < 150 and 150 or v7
					local v9 = v8 > 200 and 200 or v8

					if flag then
						v9 *= -1
					end

					v = v9
					v2 *= 0.82
					position = Vector3.new(position3.X, Y, position3.Z)
					primaryPart.CFrame = CFrame.new(position) * cframe
					local clone2 = awakenedWolf_Z.Phase2.Splash:Clone()
					clone2.CFrame = CFrame.new(primaryPart.Position)
					Util.SetParentOverrideWithColor(clone2, folder2, folder, "LeopardFruitVFXColor")
					Util.Sound:Play("Spectral_Wolf_Bounce_0" .. tostring(math.random(1, 3)), clone2.Position)

					if position2 and (position2 - clone2.Position).Magnitude <= 1 then
						proxy:SetAttribute("Exploding", true)
						return
					end

					position2 = clone2.Position
					emitAll(clone.Aura.Eye)
					emitAll(clone.Aura.Eye2)
					DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v10 = emitter
						task.spawn(function()
							if v10:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v10:GetAttribute("EmitDelay"))
							end

							v10:Emit(v10:GetAttribute("EmitCount"))
						end)
					end
				end
			end
		end)
	end)
end

return function(data)
	local folder = Instance.new("Folder")
	folder.Name = "FakePlayerForRecolor_" .. script.Name
	folder.Parent = workspace.CurrentCamera
	Util.DestroyAfter(folder, 10)
	local clone = script.VFXColor:Clone()
	clone.Name = "LeopardFruitVFXColor"
	clone.Parent = folder
	local stage = data.Stage

	if stage == 1 then
		local proxy = data.Proxy

		if not proxy then
			return
		end

		local folder2 = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder2, _WorldOrigin, folder, "LeopardFruitVFXColor")
		game.Debris:AddItem(folder2, 5)
		local root = data.Root
		local cFrame = root.CFrame
		local folder3 = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder3, _WorldOrigin, folder, "LeopardFruitVFXColor")
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		HeadTime(folder, cFrame, folder3, raycastParams, data.ProjectileCF, proxy, root)
	elseif stage == 2 then
		local folder2 = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder2, _WorldOrigin, folder, "LeopardFruitVFXColor")
		game.Debris:AddItem(folder2, 10)
		local root = data.Root
		local startCFrame = data.StartCFrame
		local clone2 = awakenedWolf_Z.Phase3.DelayStartImpact:Clone()
		clone2.CFrame = startCFrame * CFrame.new(0, 0, -4)
		Util.SetParentOverrideWithColor(clone2, folder2, folder, "LeopardFruitVFXColor")
		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			if data.Root.Parent == game.Players.LocalPlayer.Character then
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						FieldOfView = 50
					}
				):Play()
				task.wait(0.2)
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()
				task.wait(0.1)
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(0.54, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end
		end)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		local clone3 = awakenedWolf_Z.Phase3.Aura:Clone()
		clone3.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone3, folder2, folder, "LeopardFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone4 = awakenedWolf_Z.Phase3.Aura2:Clone()
		clone4.CFrame = startCFrame * CFrame.new(0, 1, 0)
		Util.SetParentOverrideWithColor(clone4, folder2, folder, "LeopardFruitVFXColor")

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v = tick() + 0.2
		local now = tick()

		while true do
			if now - tick() <= 0 then
				now = tick() + 0.12
				task.spawn(function()
					local clone5 = awakenedWolf_Z.Phase3.Trail:Clone()
					clone5.CFrame = startCFrame
					Util.SetParentOverrideWithColor(clone5, folder2, folder, "LeopardFruitVFXColor")
					clone5.CFrame = clone5.CFrame * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					) * CFrame.new(0, 0, math.random(40, 50) / 1.5)

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					TrailCurve(
						clone5,
						startCFrame,
						clone5.Position,
						startCFrame.Position,
						CFrame.new(math.random(-50, 50) / 2, math.random(-50, 50) / 2, math.random(-50, 50) / 2),
						CFrame.new(math.random(-50, 50) / 2, math.random(-50, 50) / 2, math.random(-50, 50) / 2),
						math.random(25, 30) / 7,
						true
					)

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end

			task.wait()

			if not (v - tick() <= 0) then
				continue
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				emitter:Destroy()
			end

			Util.Sound:Play("Spectral_Wolf_Release_04", root)
			local clone5 = awakenedWolf_Z.Phase4.StartImpact:Clone()
			clone5.CFrame = startCFrame
			Util.SetParentOverrideWithColor(clone5, folder2, folder, "LeopardFruitVFXColor")
			DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end

			local clone6 = awakenedWolf_Z.Phase4.Head:Clone()
			clone6:PivotTo(startCFrame)
			Util.SetParentOverrideWithColor(clone6, folder2, folder, "LeopardFruitVFXColor")
			local primaryPart = clone6.PrimaryPart

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local range = data.Range
			local dur = data.Dur
			local flag = false
			tick()
			local _ = range / dur
			local targetPosition = data.targetPosition
			local _ = startCFrame.Position
			local bouncePos = data.bouncePos
			local position = startCFrame.Position
			local magnitude = (bouncePos - position).Magnitude
			local magnitude2 = (targetPosition - bouncePos).Magnitude
			local v2 = dur * (magnitude / math.max(magnitude + magnitude2, 0.001))
			local v3 = dur - v2

			local function bez(p, p2, p3, p4)
				local v4 = 1 - p4
				return v4 * v4 * p + 2 * v4 * p4 * p2 + p4 * p4 * p3
			end

			-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
			local function dbez(p, p2, p3, p4)
				return 2 * (1 - p4) * (p2 - p) + 2 * p4 * (p3 - p2)
			end

			local v4 = math.clamp(magnitude * 0.4, 6, 60)
			local v5 = math.clamp(magnitude2 * 0.35, 6, 60)
			local v6 = position:Lerp(bouncePos, 0.5) + createVector(0, 1, 0) * v4
			local v7 = bouncePos:Lerp(targetPosition, 0.5) + createVector(0, 1, 0) * v5
			local now2 = tick()
			local lookVector = startCFrame.LookVector
			local heartbeatConnection = nil
			local v8 = false
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v19 = tick() - now2

				if dur <= v19 then
					heartbeatConnection:Disconnect()
					primaryPart.CFrame = CFrame.new(targetPosition)
					flag = true
				else
					local v20, v21

					if v19 < v2 then
						local v22 = v19 / v2
						local v26 = 1 - v22
						v20 = v26 * v26 * position + 2 * v26 * v22 * v6 + v22 * v22 * bouncePos
						v21 = dbez(position, v6, bouncePos, v22)
					else
						if not v8 then
							v8 = true
							local clone7 = awakenedWolf_Z.Phase2.Splash:Clone()
							Util.ResizeModel(clone7, 4.5)
							clone7.CFrame = CFrame.new(bouncePos)
							Util.SetParentOverrideWithColor(clone7, folder2, folder, "LeopardFruitVFXColor")
							Util.Sound:Play("Spectral_Wolf_Bounce_04", bouncePos)
							DeleteImpactAfterDuration(clone7) -- equivalent call inferred; original call site unknown

							for i, emitter in pairs(clone7:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v22 = emitter
								task.spawn(function()
									if v22:GetAttribute("EmitDelay") ~= 0 then
										task.wait(v22:GetAttribute("EmitDelay"))
									end

									v22:Emit(v22:GetAttribute("EmitCount"))
								end)
							end
						end

						local v22 = (v19 - v2) / v3
						local v26 = 1 - v22
						v20 = v26 * v26 * bouncePos + 2 * v26 * v22 * v7 + v22 * v22 * targetPosition
						v21 = dbez(bouncePos, v7, targetPosition, v22)
					end

					local unit = v21.Magnitude > 1e-6 and v21.Unit or lookVector
					lookVector = unit
					primaryPart.CFrame = CFrame.lookAt(v20, v20 + unit, createVector(0, 1, 0))
				end
			end)

			repeat
				task.wait()
			until flag

			local clone7 = awakenedWolf_Z.Phase4.Explosion:Clone()
			clone7.CFrame = primaryPart.CFrame * CFrame.new(0, 5, 0)
			Util.SetParentOverrideWithColor(clone7, folder2, folder, "LeopardFruitVFXColor")
			Util.Sound:Play("Spectral_Wolf_Explosion_04", clone7.Position)
			local ray = Util.Ray
			local v19 = clone7.Position + createVector(0, 2, 0)
			local v20 = { workspace.Characters, workspace.Enemies, folder2 }
			local v21, v22, _ = ray(v19, createVector(-0, -16, -0), v20, false)

			if v21 ~= nil then
				local cframe = CFrame.new(v22)
				local clone8 = awakenedWolf_Z.Phase4.ZFloor:Clone()
				clone8.CFrame = cframe
				Util.SetParentOverrideWithColor(clone8, folder2, folder, "LeopardFruitVFXColor")
				emitAll(clone8)
				Util.Debris:AddItem(clone8, 3.5)
				task.spawn(function()
					local ray2 = Util.Ray
					local v24 = clone8.Position + createVector(0, 2, 0)
					local v25 = { workspace.Characters, workspace.Enemies, folder2 }
					local v26, v27, v28 = ray2(v24, createVector(-0, -100, -0), v25, false)

					if v26 then
						local v29 = CFrame.new(v27, v27 + v28) * CFrame.Angles(-1.5707963267948966, 0, 0)
						local random = Random.new()

						for i = 1, 30 do
							local v30 = 6.283185307179586 * (i / 30)
							local v31 = Rock2.new({
								Type = "Ground",
								FadeOut = { 0.25, 0.5 },
								FadeIn = { 0.25, 0.5 },
								Lifetime = { 1, 2.5 },
								Size = Vector3.new(
									random:NextNumber(1, 2),
									random:NextNumber(1, 2),
									random:NextNumber(1, 2)
								),
								Scale = { 2.5, 5 }
							})

							if random:NextInteger(1, 8) % 4 == 0 then
								local unit = Vector3.new(
									math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
									random:NextNumber(0, 1) * 1.25,
									math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
								).Unit
								v31.Type = "Flying"
								v31:Spawn(v29 * CFrame.Angles(0, v30, 0) * CFrame.new(0, 0, -22.5))
								v31:Eject({
									Velocity = Util.Misc.Physics.Velocity(
										Vector3.new(),
										unit * random:NextNumber(20, 80),
										Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
										0.25 + random:NextNumber(0, 2)
									),
									AngularVelocity = Vector3.new(
										random:NextNumber(-1, 1),
										random:NextNumber(-1, 1),
										random:NextNumber(-1, 1)
									) * 2 * 3.141592653589793 * (1 / v31.Scale)
								})
							else
								v31:Spawn(v29 * CFrame.Angles(0, v30, 0) * CFrame.new(0, 0, -22.5))
								v31:TweenShift(
									(v29 * CFrame.Angles(0, v30, 0)).LookVector * 10 * random:NextNumber(1, 2),
									0.25
								)
							end
						end
					end
				end)
			end

			task.spawn(function()
				if data.Root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(3, 6, 0.05, 1, createVector(1, 1, 1), createVector(1, 1, 1))
					task.spawn(function()
						TweenService:Create(
							game.Workspace.Camera,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								FieldOfView = 85
							}
						):Play()
						task.wait(0.1)
						TweenService:Create(
							game.Workspace.Camera,
							TweenInfo.new(0.54, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								FieldOfView = 70
							}
						):Play()
					end)
					task.spawn(function()
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						Util.SetParentOverrideWithColor(
							colorCorrectionEffect,
							game.Lighting,
							folder,
							"LeopardFruitVFXColor"
						)
						Util.Debris:AddItem(colorCorrectionEffect, 0.3)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(103, 52, 255),
									folder,
									"LeopardFruitVFXColor"
								),
								Brightness = -3,
								Saturation = -1,
								Contrast = 8
							}
						):Play()
						task.wait(0.03)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(161, 124, 255),
									folder,
									"LeopardFruitVFXColor"
								),
								Brightness = 0.4,
								Saturation = 0,
								Contrast = 1
							}
						):Play()
						task.wait(0.03)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									folder,
									"LeopardFruitVFXColor"
								),
								Brightness = 0,
								Saturation = 0,
								Contrast = 0
							}
						):Play()
					end)
				end
			end)
			DeleteImpactAfterDuration(clone7) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone7:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v23 = emitter
				task.spawn(function()
					if v23:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v23:GetAttribute("EmitDelay"))
					end

					v23:Emit(v23:GetAttribute("EmitCount"))
				end)
			end

			for _, descendant in pairs(clone6:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
					descendant.Enabled = false
				elseif descendant:IsA("MeshPart") then
					descendant.Transparency = 1
				end
			end

			break
		end
	end
end