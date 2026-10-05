local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function resolveConfig(data)
	if type(data.Config) == "table" then
		return data.Config
	end

	local bonusMoments = ReplicatedStorage:FindFirstChild("BonusMoments")
	local templeIntel

	if bonusMoments then
		templeIntel = bonusMoments:FindFirstChild("Temple Intel")
	end

	local puzzleConfig

	if templeIntel then
		puzzleConfig = templeIntel:FindFirstChild("PuzzleConfig")
	end

	if not (puzzleConfig and puzzleConfig:IsA("ModuleScript")) then
		warn("[Temple Intel] PuzzleConfig not reachable from the client")
		return nil
	end

	local success, result = pcall(require, puzzleConfig)

	if success then
		return result
	end

	warn((`[Temple Intel] PuzzleConfig failed to load: {result}`))
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smootherstep(value: number)
	local v = math.clamp(value, 0, 1)
	return v * v * v * (v * (v * 6 - 15) + 10)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flatten(vector2: Vector3)
	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector3.Magnitude > 0.001 then
		return vector3.Unit
	end

	return createVector(0, 0, 1)
end

return function(data)
	if not data then
		return
	end

	local templeIntelFinaleCamera = Lighting:FindFirstChild("TempleIntelFinaleCamera")

	if data.Remove == true then
		if templeIntelFinaleCamera then
			templeIntelFinaleCamera:Destroy()
		end
	else
		if templeIntelFinaleCamera then
			return
		end

		local relic = data.Relic

		if typeof(relic) ~= "Instance" or not relic:IsA("BasePart") then
			return
		end

		local config = resolveConfig(data)
		local camera

		if config then
			camera = config.Camera
		else
			camera = nil
		end

		if not (camera and camera.Enabled) then
			return
		end

		local relicFinale = config.RelicFinale or {}
		local localPlayer = Players.LocalPlayer
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local centre

		if typeof(data.Centre) == "Vector3" then
			centre = data.Centre
		else
			centre = relic.Position
		end

		local startedAt

		if typeof(data.StartedAt) == "number" then
			startedAt = data.StartedAt
		else
			startedAt = os.clock()
		end

		local v = (relicFinale.ShakeTime or 0) + (relicFinale.RiseTime or 0)
		local v2 = v + (relicFinale.OrbitTime or 0)
		local v3 = v2 + (relicFinale.BurstTime or 0)
		local v4 = v3 + (relicFinale.ApproachTime or 0)
		local v5 = v4 + (relicFinale.HoverTime or 0) + (relicFinale.AlignTime or 0)
		local v6 = v5 + (relicFinale.DropTime or 0) + (relicFinale.BounceTime or 0)
		local v7 = v5 - (camera.SnapLead or 0.5)
		local v8 = v6 + (camera.HoldTime or 1.2)
		local folder = Instance.new("Folder")
		folder.Name = "TempleIntelFinaleCamera"
		folder.Parent = Lighting
		local v9 = nil
		local v10 = nil
		local walkSpeed = nil
		local jumpPower = nil
		local jumpHeight = nil
		local autoRotate = nil

		local function lockCharacter()
			if not camera.LockCharacter then
				return
			end

			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				return
			end

			v9 = humanoid
			walkSpeed = humanoid.WalkSpeed
			jumpPower = humanoid.JumpPower
			jumpHeight = humanoid.JumpHeight
			autoRotate = humanoid.AutoRotate
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
			humanoid.AutoRotate = false
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				v10 = humanoidRootPart
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				humanoidRootPart.Anchored = true
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function unlockCharacter()
			local v11 = v10
			v10 = nil

			if v11 and v11.Parent then
				v11.Anchored = false
				v11.AssemblyLinearVelocity = createVector(0, 0, 0)
				v11.AssemblyAngularVelocity = createVector(0, 0, 0)
			end

			if v9 and v9.Parent then
				v9.WalkSpeed = walkSpeed or 16
				v9.JumpPower = jumpPower or 50
				v9.JumpHeight = jumpHeight or 7.2
				v9.AutoRotate = autoRotate ~= false
			end

			v9 = nil
		end

		local function characterRoot()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart
			end

			return nil
		end

		local cameraType = currentCamera.CameraType

		if cameraType ~= Enum.CameraType.Custom and cameraType ~= Enum.CameraType.Follow and cameraType ~= Enum.CameraType.Attach and cameraType ~= Enum.CameraType.Track then
			cameraType = Enum.CameraType.Custom
		end

		local cameraSubject = currentCamera.CameraSubject
		local v11 = nil
		local lookVector = nil
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		if humanoidRootPart then
			v11 = currentCamera.CFrame.Position - humanoidRootPart.Position
			lookVector = currentCamera.CFrame.LookVector
		end

		local v13 = flatten(currentCamera.CFrame.Position - relic.Position) -- equivalent call inferred; original call site unknown
		local v14 = nil
		local v15 = nil
		local cFrame = nil
		local cFrame2 = nil
		local flag = false
		local cFrame3 = nil
		local v16 = nil
		local position = relic.Position
		local v17 = createVector(0, 0, 0)
		local renderSteppedConnection = nil
		local characterAddedConnection = nil

		local function release()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			if characterAddedConnection then
				characterAddedConnection:Disconnect()
				characterAddedConnection = nil
			end

			unlockCharacter() -- equivalent call inferred; original call site unknown
			local character2 = localPlayer.Character
			local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")
			currentCamera.CameraSubject = humanoid or cameraSubject
			currentCamera.CameraType = cameraType

			if folder.Parent then
				folder:Destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeShot()
			local v18 = relic.Position + v13 * (camera.CloseDistance or 7) + Vector3.new(
				0,
				camera.CloseHeight or 2.5,
				0
			)
			return CFrame.lookAt(v18, relic.Position)
		end

		local function followShot(vector2: Vector3)
			local v18 = relic.Position - centre

			if Vector3.new(v18.X, 0, v18.Z).Magnitude > (camera.FollowMinRadius or 3) then
				v14 = flatten(v18)
			end

			local v19 = v14 or v13
			local v20

			if vector2.Magnitude > 0.5 then
				v20 = flatten(vector2)
			else
				v20 = v19
			end

			local v21 = relic.Position + v19 * (camera.FollowOut or 4) + Vector3.new(0, camera.FollowUp or 2.5, 0) - v20 * (camera.FollowBack or 5)
			return CFrame.lookAt(v21, relic.Position)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function burstShot()
			local v18 = relic.Position + v13 * (camera.BurstDistance or 22) + Vector3.new(0, camera.BurstHeight or 8, 0)
			return CFrame.lookAt(v18, relic.Position)
		end

		local function chaseShot(vector2: Vector3)
			if Vector3.new(vector2.X, 0, vector2.Z).Magnitude > (camera.ChaseMinSpeed or 6) then
				v15 = flatten(vector2)
			end

			local v18 = v15 or v13
			local v19 = relic.Position - v18 * (camera.ChaseBack or 14) + Vector3.new(0, camera.ChaseUp or 5, 0)
			return CFrame.lookAt(v19, relic.Position)
		end

		local function overheadShot()
			if not cFrame then
				local character2 = localPlayer.Character
				local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
					humanoidRootPart2 = nil
				end

				if not humanoidRootPart2 then
					return nil
				end

				cFrame = humanoidRootPart2.CFrame
			end

			local v18 = cFrame
			local v19 = v18.Position + v18.LookVector * (camera.OverheadDistance or 12) + v18.RightVector * (camera.OverheadSide or 3) + Vector3.new(
				0,
				camera.OverheadHeight or 6,
				0
			)
			local v20 = v18.Position + Vector3.new(0, camera.SnapLookHeight or 2.5, 0)
			return CFrame.lookAt(v19, v20:Lerp(relic.Position, camera.OverheadBias or 0.55))
		end

		local function snapShot()
			if not cFrame2 then
				local character2 = localPlayer.Character
				local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
					humanoidRootPart2 = nil
				end

				if not humanoidRootPart2 then
					return nil
				end

				cFrame2 = humanoidRootPart2.CFrame
			end

			local v18 = cFrame2
			local v19 = v18.Position + v18.LookVector * (camera.SnapDistance or 9) + v18.RightVector * (camera.SnapSide or -4) + Vector3.new(
				0,
				camera.SnapHeight or 4,
				0
			)
			local v20 = v18.Position + Vector3.new(0, camera.SnapLookHeight or 2.5, 0)
			return CFrame.lookAt(v19, v20:Lerp(relic.Position, camera.SnapRelicBias or 0.35))
		end

		lockCharacter()
		currentCamera.CameraType = Enum.CameraType.Scriptable
		characterAddedConnection = localPlayer.CharacterAdded:Connect(release)
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			if not (folder.Parent and relic.Parent) then
				release()
				return
			end

			local v18 = os.clock() - startedAt
			local v19 = (relic.Position - position) / math.max(dt, 0.004166666666666667)
			position = relic.Position
			v17 = v17:Lerp(v19, 1 - math.exp(-(camera.VelocitySmoothing or 8) * dt))

			if v8 <= v18 then
				local character2 = localPlayer.Character
				local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
					humanoidRootPart2 = nil
				end

				if not (humanoidRootPart2 and v11 and lookVector) then
					release()
					return
				end

				if not v16 then
					v16 = v18
					cFrame3 = currentCamera.CFrame
				end

				local v20 = (v18 - v16) / math.max(camera.RestoreTime or 0.8, 0.001)
				local v21 = humanoidRootPart2.Position + v11
				local cframe = CFrame.lookAt(v21, v21 + lookVector)

				if v20 >= 1 then
					currentCamera.CFrame = cframe
					release()
				else
					currentCamera.CFrame = cFrame3:Lerp(cframe, smootherstep(v20))
				end
			elseif v7 <= v18 then
				local cFrame4 = snapShot()

				if cFrame4 then
					if flag then
						currentCamera.CFrame = currentCamera.CFrame:Lerp(
							cFrame4,
							1 - math.exp(-(camera.Smoothing or 4.5) * dt)
						)
					else
						flag = true
						currentCamera.CFrame = cFrame4
					end
				end
			else
				local smoothing = camera.Smoothing or 4.5
				local v20

				if v18 < v then
					v20 = closeShot()
				elseif v18 < v2 then
					v20 = followShot(v17)
					smoothing = camera.OrbitSmoothing or 14
				elseif v18 < v3 then
					v20 = burstShot()
				elseif v18 < v4 then
					v20 = chaseShot(v17)
				else
					v20 = overheadShot() or chaseShot(v17)
				end

				currentCamera.CFrame = currentCamera.CFrame:Lerp(v20, 1 - math.exp(-smoothing * dt))
			end
		end)
	end
end