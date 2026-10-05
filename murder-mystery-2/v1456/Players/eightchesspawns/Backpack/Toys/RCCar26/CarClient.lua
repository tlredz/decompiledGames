local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local parent = script.Parent
local carStateChanged = parent:WaitForChild("CarStateChanged")
local localPlayer = Players.LocalPlayer
local gravity = workspace.Gravity
local PlayerModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
local heartbeatConnection = nil

local function raycastSolid(p, p2, raycastParams, instances)
	for _ = 1, 8 do
		local raycastResult = workspace:Raycast(p, p2, raycastParams)
		local instance = raycastResult and raycastResult.Instance

		if instance and instance:IsA("BasePart") and not instance:IsA("Terrain") and instance.Transparency >= 1 and not instance.CanCollide then
			table.insert(instances, instance)
			raycastParams.ExcludeInstances = instances
		else
			return raycastResult
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopDriving()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function startDriving(instance)
	stopDriving() -- equivalent call inferred; original call site unknown
	local body = instance:WaitForChild("Body")
	local welds = {}

	for _, weld in body:GetChildren() do
		if weld:IsA("Weld") then
			table.insert(welds, weld)
		end
	end

	local boundingBox, v = instance:GetBoundingBox()
	local v2 = instance:GetPivot().Position.Y - (boundingBox.Position.Y - v.Y / 2)
	local v3 = v.Z / 2
	local v4 = v.X / 2
	local leftFrontWheel = instance:FindFirstChild("LeftFrontWheel")
	local v5 = not leftFrontWheel and 0.374 or leftFrontWheel.Size.Y / 2
	local lookVector = instance:GetPivot().LookVector
	local v6 = math.atan2(-lookVector.X, -lookVector.Z)
	local v7 = 0
	local total = 0
	local flag = false
	local v8 = 0
	local v9 = 0
	local total2 = 0
	local v10 = createVector(0, 1, 0)
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if instance.Parent then
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoidRootPart then
				local moveVector = controls:GetMoveVector()
				local v11 = -moveVector.Z
				local X = moveVector.X

				if v11 > 0.05 then
					if v7 < 0 then
						v7 = math.min(v7 + 60 * dt, 0)
					else
						v7 = math.min(v7 + 40 * v11 * dt, 24)
					end
				elseif v11 < -0.05 then
					if v7 > 0 then
						v7 = math.max(v7 - 60 * dt, 0)
					else
						v7 = math.max(v7 + 40 * v11 * dt, -12)
					end
				elseif v7 > 0 then
					v7 = math.max(v7 - 30 * dt, 0)
				else
					v7 = math.min(v7 + 30 * dt, 0)
				end

				if math.abs(X) > 0.05 and math.abs(v7) > 0.5 and not flag then
					local v12 = math.clamp(math.abs(v7) / 8.399999999999999, 0, 1)
					local v13 = v7 >= 0 and 1 or -1
					v6 -= X * 3.141592653589793 * v12 * v13 * dt
				end

				local position = instance:GetPivot().Position
				local vector2 = Vector3.new(-math.sin(v6), 0, -math.cos(v6))
				local raycastParams = RaycastParams.new()
				local excludeInstances = { instance }

				for _, v13 in Players:GetPlayers() do
					if v13.Character then
						table.insert(excludeInstances, v13.Character)
					end
				end

				local rCCars = workspace:FindFirstChild("RCCars")

				if rCCars then
					table.insert(excludeInstances, rCCars)
				end

				raycastParams.ExcludeInstances = excludeInstances

				if v7 ~= 0 then
					local unit

					if v7 >= 0 then
						unit = vector2
					else
						unit = -vector2
					end

					local v13 = unit - v10 * unit:Dot(v10)

					if v13.Magnitude > 0.01 then
						unit = v13.Unit
					end

					local cross = vector2:Cross(createVector(0, 1, 0))
					local v14 = v3 + 0.4 + math.abs(v7) * dt
					local v15 = position - v10 * (v2 - 1)
					local flag2 = false

					for _, v17 in { -v4 * 0.8, 0, v4 * 0.8 } do
						local v18 = cross * v17

						for _, v20 in { position + v18, v15 + v18 } do
							local v21 = raycastSolid(v20, unit * v14, raycastParams, excludeInstances)

							if not (v21 and v21.Normal.Y < 0.7) then
								continue
							end

							flag2 = true
							break
						end

						if flag2 then
							break
						end
					end

					if flag2 then
						v7 = 0
					end
				end

				local v13 = position + vector2 * v7 * dt

				if (v13 - humanoidRootPart.Position).Magnitude > 100 then
					v7 = 0
					v13 = position
				end

				local normal = createVector(0, 1, 0)
				local v14 = raycastSolid(
					v13 + createVector(0, 2, 0),
					createVector(0, -62, 0),
					raycastParams,
					excludeInstances
				)
				local v15

				if v14 then
					v15 = v14.Position.Y + v2
				end

				if flag then
					v8 -= gravity * dt
					local v16 = position.Y + v8 * dt

					if v15 and v8 <= 0 and v16 <= v15 then
						flag = false
						v8 = 0
						v9 = 0
						normal = v14.Normal
						v16 = v15
					end

					position = Vector3.new(v13.X, v16, v13.Z)
				elseif v15 then
					if position.Y - 1.5 <= v15 then
						local v16 = math.min(v15, position.Y + 40 * dt)
						v9 = (v16 - position.Y) / dt
						position = Vector3.new(v13.X, v16, v13.Z)
						normal = v14.Normal
					else
						flag = true
						v8 = math.max(v9, 0)
						position = Vector3.new(v13.X, position.Y + v8 * dt, v13.Z)
					end
				else
					v7 = 0
				end

				local v16

				if flag and math.abs(v7) > 0.5 then
					local v17 = v7 >= 0 and 1 or -1
					v16 = math.clamp(math.atan2(v8 * v17, (math.abs(v7))), -0.3490658503988659, 0.6981317007977318)
				else
					v16 = 0
				end

				total2 += (v16 - total2) * math.min(dt * 10, 1)
				local v17 = vector2 - normal * vector2:Dot(normal)

				if v17.Magnitude > 0.01 then
					vector2 = v17.Unit
				end

				instance:PivotTo(CFrame.lookAt(position, position + vector2, normal) * CFrame.Angles(total2, 0, 0))
				v10 = normal
				body.AssemblyLinearVelocity = createVector(0, 0, 0)
				body.AssemblyAngularVelocity = createVector(0, 0, 0)
				total += v7 / v5 * dt
				local cframe = CFrame.Angles(total, 0, 0)

				for _, v18 in welds do
					v18.C1 = cframe
				end

				return
			end
		end

		stopDriving() -- equivalent call inferred; original call site unknown
	end)
end

carStateChanged.OnClientEvent:Connect(function(p)
	if p then
		startDriving(p)
		return
	end

	stopDriving() -- equivalent call inferred; original call site unknown
end)
parent.Unequipped:Connect(stopDriving)