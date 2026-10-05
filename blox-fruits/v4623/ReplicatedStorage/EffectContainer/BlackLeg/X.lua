local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local _ = coroutine.resume
local _ = coroutine.create
local X = game.ReplicatedStorage.EffectContainer.BlackLeg.X

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function beamProjectile(vector2, p, data, p2)
	local v = 0.5 * vector2 * p2 * p2 + p * p2 + data
	local v2 = v - (vector2 * p2 * p2 + p * p2) / 3
	local v3 = (0.125 * vector2 * p2 * p2 + 0.5 * p * p2 + data - 0.125 * (data + v)) / 0.375 - v2
	local magnitude = (v3 - data).magnitude
	local magnitude2 = (v2 - v).magnitude
	local unit = (data - v).unit
	local unit2 = (v3 - data).unit
	local unit3 = unit2:Cross(unit).unit
	local unit4 = (v2 - v).unit
	local unit5 = unit4:Cross(unit).unit
	local unit6 = unit3:Cross(unit2).unit
	local cframe = CFrame.new(
		data.x,
		data.y,
		data.z,
		unit2.x,
		unit3.x,
		unit6.x,
		unit2.y,
		unit3.y,
		unit6.y,
		unit2.z,
		unit3.z,
		unit6.z
	)
	local cframe2 = CFrame.new(
		v.x,
		v.y,
		v.z,
		unit4.x,
		unit5.x,
		unit6.x,
		unit4.y,
		unit5.y,
		unit6.y,
		unit4.z,
		unit5.z,
		unit6.z
	)
	return magnitude, -magnitude2, cframe, cframe2, v3, v2, v
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDir(p)
	if p then
		return script.Diable
	end

	return script
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attachTrail(p, character, devil, p2)
	local dir = getDir(p2) -- equivalent call inferred; original call site unknown
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		if p then
			local clone = dir.trailbody:Clone()
			clone.Name = "blegtrailbody"
			debris:AddItem(clone, devil)
			clone.CFrame = humanoidRootPart.CFrame
			clone.Orientation += createVector(0, 90, 0)
			clone.Parent = humanoidRootPart
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Name = "blegtrailbodyweld11"
			weldConstraint.Part0 = humanoidRootPart
			weldConstraint.Part1 = clone
			weldConstraint.Parent = humanoidRootPart
		else
			if humanoidRootPart:FindFirstChild("blegtrailbody") then
				for _, emitter in pairs(humanoidRootPart.blegtrailbody:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.delay(0.7, function()
					if humanoidRootPart:FindFirstChild("blegtrailbody") then
						humanoidRootPart.blegtrailbody:Destroy()
					end
				end)
			end

			task.delay(0.7, function()
				if humanoidRootPart:FindFirstChild("blegtrailbodyweld11") then
					humanoidRootPart.blegtrailbodyweld11:Destroy()
				end
			end)
		end
	end
end

local function landEffect(character, humanoidRootPart, devil)
	local dir = getDir(devil) -- equivalent call inferred; original call site unknown
	local stringValue = Instance.new("StringValue")
	debris:AddItem(stringValue, 3)
	stringValue.Name = "BlackLegZReleaser2"
	stringValue.Parent = character
	local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
	local tweenInfo2 = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
	TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	local position = humanoidRootPart.CFrame.Position
	local ray, v, v2 = Util.Ray(
		position,
		CFrame.new(position).UpVector.Unit * -16,
		{ workspace.Characters, workspace.Enemies },
		false
	)

	if ray then
		local clone = dir.Smoke_tang_ting_kaboom:Clone()
		debris:AddItem(clone, 4)
		clone.CFrame = CFrame.new(v)
		clone.Parent = _WorldOrigin

		if devil then
			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		else
			clone.Grass2.Color = ColorSequence.new(ray.Color)
			clone.Smoke.Color = ColorSequence.new(ray.Color)
			clone.Grass2:Emit(20)
			clone.Smoke:Emit(20)
			sound:Play("BlackLegGround", clone.Position, nil, 1, 1)
		end

		sound:Play("BlackLegGroundHit", clone.Position, nil, 1, 1)
		local clone2 = devil and dir.BurntFloor:Clone() or dir.GroundCrack:Clone()
		debris:AddItem(clone2, 4)
		clone2.CFrame = CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone2.Parent = _WorldOrigin
		TweenService:Create(clone2, tweenInfo2, {
			Size = createVector(40.666, 0.166, 42.023)
		}):Play()
		task.delay(1.5, function()
			if devil then
				TweenService:Create(clone2.Decal1, tweenInfo, {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2.Decal2, tweenInfo, {
					Transparency = 1
				}):Play()
			else
				TweenService:Create(clone2.D1, tweenInfo, {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2.D2, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end)

		for _, emitter in pairs(clone.Attachment:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local ground = Util.RocksModule.Ground
		local v3 = { workspace.Map }
		ground(v, 15, createVector(1.5, 2.1, 1.5), v3, 10, false, 2)
		local character2 = game.Players.LocalPlayer.Character

		if character2 ~= nil then
			local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and (humanoidRootPart2.Position - v).magnitude <= 125 then
				Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion)
			end
		end

		coroutine.wrap(function()
			for _ = 1, 3 do
				local clone3 = dir.Lower:Clone()
				clone3.CFrame = CFrame.new(v) * CFrame.new(0, 0, 0)
				clone3.Orientation += createVector(0, 180, 180)
				clone3.Parent = _WorldOrigin
				TweenService:Create(clone3, TweenInfo.new(0.5), {
					Position = clone3.Position + createVector(0, 0, 0),
					Size = createVector(41.176, 5.76, 42.855),
					Transparency = 1
				}):Play()
				debris:AddItem(clone3, 0.6)
				task.wait(0.2)
			end
		end)()
		coroutine.wrap(function()
			for _ = 1, 3 do
				local clone3 = dir.Shockwave1:Clone()
				clone3.CFrame = CFrame.new(v) * CFrame.new(0, 0, 0)
				clone3.Orientation += createVector(0, -90, 90)
				clone3.Parent = _WorldOrigin
				TweenService:Create(clone3, tweenInfo2, {
					Size = createVector(5.454, 54.841, 55.035),
					Transparency = 1
				}):Play()
				debris:AddItem(clone3, 0.9)
				task.wait(0.2)
			end
		end)()
	end
end

local function clampMouse(p, position, p2)
	if p2 < (p.Position - position).Magnitude then
		position = (CFrame.new(p.Position, position) * CFrame.new(0, 0, -p2)).Position
	end

	return position
end

return function(player)
	local subEffect = player.SubEffect or 1

	if subEffect == 1 then
		local character = player.Character
		local holdValue = player.HoldValue
		local humanoid = player.Humanoid
		local maxRange = player.MaxRange
		local humanoidRootPart = humanoid and holdValue and character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local diedConnection = nil

			if humanoid then
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
			end

			local function running()
				return diedConnection and holdValue and holdValue.Value == true
			end

			local clone = X.water_fall_basin_stuff.Part.water_fall_basin_at1:Clone()
			clone.Parent = humanoidRootPart
			local clone2 = X.water_fall_basin_stuff.Part.water_fall_basin_at2:Clone()
			clone2.Parent = humanoidRootPart
			local clone3 = X.water_fall_basin_stuff.Part.Beam:Clone()
			clone3.Parent = humanoidRootPart
			clone3.Attachment0 = clone
			clone3.Attachment1 = clone2
			local clone4 = X.water_fall_basin_stuff.water_fall_basin_3123:Clone()
			clone4.Parent = humanoidRootPart
			clone4.BillboardGui.Enabled = true
			debris:AddItem(clone, 6)
			debris:AddItem(clone2, 6)
			debris:AddItem(clone3, 6)
			debris:AddItem(clone4, 6)

			while clone ~= nil and clone2 ~= nil and clone.Parent ~= nil and clone2.Parent ~= nil and clone4 ~= nil and clone4.Parent ~= nil and humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil and clone3 ~= nil and clone3.Parent ~= nil and diedConnection and holdValue and holdValue.Value == true and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil do
				local vector2 = Vector3.new(0, -workspace.Gravity, 0)
				local v = humanoidRootPart.CFrame * createVector(0, 2, -2)
				local p = Mouse.Hit.p

				if maxRange < (humanoidRootPart.Position - p).Magnitude then
					p = (CFrame.new(humanoidRootPart.Position, p) * CFrame.new(0, 0, -maxRange)).Position
				end

				local curveSize, curveSize2, v5, cFrame = beamProjectile(
					vector2,
					(p - v - vector2 * 0.5 * 0.95 * 0.95) / 0.95,
					v,
					0.95
				)
				clone3.CurveSize0 = curveSize
				clone3.CurveSize1 = curveSize2
				clone4.CFrame = cFrame
				clone.CFrame = clone.Parent.CFrame:inverse() * v5
				clone2.CFrame = clone2.Parent.CFrame:inverse() * cFrame
				RunService.RenderStepped:Wait()
			end

			for _, v in pairs({
				clone,
				clone2,
				clone3,
				clone4
			}) do
				if v ~= nil then
					v:Destroy()
				end
			end

			if diedConnection then
				diedConnection:Disconnect()
			end

			if humanoidRootPart:FindFirstChild("water_fall_basin_at1") ~= nil then
				humanoidRootPart.water_fall_basin_at1:Destroy()
			end

			if humanoidRootPart:FindFirstChild("water_fall_basin_at2") ~= nil then
				humanoidRootPart.water_fall_basin_at2:Destroy()
			end

			if humanoidRootPart:FindFirstChild("water_fall_basin_3123") ~= nil then
				humanoidRootPart.water_fall_basin_3123:Destroy()
			end
		end
	elseif subEffect == 2 then
		local character = player.Character
		local mousePos = player.MousePos
		local _ = player.EndLag
		local timestamp = player.Timestamp
		local devil = player.Devil

		if character then
			local _ = Util.MasterClock:GetTime() - timestamp
			local v = game.Players.LocalPlayer and game.Players.LocalPlayer.Character and character == game.Players.LocalPlayer.Character and true or false
			local humanoid = character:FindFirstChild("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart ~= nil then
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 600 then
					return
				end

				local stringValue = Instance.new("StringValue")
				debris:AddItem(stringValue, 3)
				stringValue.Name = "BlackLegZReleaser"
				stringValue.Parent = character

				if character:FindFirstChild("UpperTorso") ~= nil then
					attachTrail(true, character, 10, devil) -- equivalent call inferred; original call site unknown
				end

				sound:Play("SpikeBallDespawn2", humanoidRootPart)
				local v2 = Util.BodyMover.new(character):Create("BodyGyro", {
					CFrame = CFrame.new(
						humanoidRootPart.Position * createVector(1, 0, 1),
						mousePos * createVector(1, 0, 1)
					)
				})
				local v3 = Util.BodyMover.new(character):Create("BodyVelocity", {
					Velocity = Vector3.new(),
					MaxForce = createVector(40000, 40000, 40000)
				})
				local v4 = Util.BodyMover.new(character):Create("BodyPosition", {
					Position = humanoidRootPart.Position,
					MaxForce = createVector(40000, 40000, 40000),
					P = 6000
				})

				local function cancelForces()
					for _, v6 in pairs({ v4, v2, v3 }) do
						if v6 then
							v6:Destroy()
						end
					end
				end

				local v5 = false
				local childAddedConnection = character.ChildAdded:Connect(function(stringValue2)
					if stringValue2:IsA("StringValue") and stringValue2.Name == "BlackLegZReleaser2" then
						v5 = true
						cancelForces()
					end
				end)

				if v3 ~= nil then
					local vector2 = Vector3.new(0, -game.Workspace.Gravity, 0)
					local v6 = humanoidRootPart.CFrame * createVector(0, 2, -2)
					local _, _, _, _, _, v8, _ = beamProjectile(
						vector2,
						(mousePos - v6 - vector2 * 0.5 * 1.25 * 1.25) / 1.25,
						v6,
						1.25
					)
					local position = humanoidRootPart.Position
					local ray, v9, _ = Util.Ray(
						mousePos,
						CFrame.new(mousePos, mousePos + createVector(0, -40, 0)).LookVector.Unit * 40,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray == nil then
						v9 = mousePos
					end

					if v3 ~= nil then
						v3:Destroy()
					end

					local blackLegConcSpin = Util.Anims:Get(character, "BlackLegConcSpin")
					blackLegConcSpin:Play(nil, nil, 1.5)
					local lastTime = tick()

					while tick() - lastTime < 0.666 and not v5 do
						local v10 = (tick() - lastTime) / 0.666
						local v11 = position + (v8 - position) * v10
						v4:Set(v11 + (v8 + (v9 - v8) * v10 - v11) * v10)
						task.wait()
					end

					if childAddedConnection then
						childAddedConnection:Disconnect()
					end

					attachTrail(false, character, devil)

					if blackLegConcSpin then
						blackLegConcSpin:Stop()
					end

					if v then
						local ray2, _, _ = Util.Ray(
							humanoidRootPart.Position,
							CFrame.new(humanoidRootPart.Position).UpVector.Unit * -15,
							{ workspace.Characters, workspace.Enemies },
							false
						)

						if ray2 then
							landEffect(character, humanoidRootPart, devil)
						end
					end

					cancelForces()

					if humanoid ~= nil then
						humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
						humanoid.AutoRotate = true
					end
				end
			end
		end
	elseif subEffect == 3 then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local devil = player.Devil

		if character and humanoidRootPart then
			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 600 then
				return
			else
				landEffect(character, humanoidRootPart, devil)
			end
		end
	end
end