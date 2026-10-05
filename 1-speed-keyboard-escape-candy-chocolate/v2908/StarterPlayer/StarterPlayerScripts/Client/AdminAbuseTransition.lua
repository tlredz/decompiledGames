local createVector = vector.create
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminAbuseDoorConfig = require(ReplicatedStorage.Shared:WaitForChild("AdminAbuseDoorConfig"))
local Config = require(ReplicatedStorage.Config)
local v = nil
local count = 0
local v2 = false
local AdminAbuseTransition = {
	isActive = function()
		return v2
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInOutSine(value: number)
	local v3 = math.clamp(value, 0, 1)
	return -(math.cos(3.141592653589793 * v3) - 1) / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyActiveScreen()
	if v and v.Parent then
		v:Destroy()
	end

	v = nil
end

function AdminAbuseTransition.cancel()
	count += 1
	destroyActiveScreen() -- equivalent call inferred; original call site unknown
end

local function findLobbyDoorFolder()
	local adminAbuse = workspace:FindFirstChild("AdminAbuse")

	if not (adminAbuse and adminAbuse:IsA("Folder")) then
		warn("[LobbyDoorServer] workspace.AdminAbuse manquant")
		return nil
	end

	local scriptables = adminAbuse:FindFirstChild("Scriptables")

	if scriptables and scriptables:IsA("Folder") then
		return (scriptables:FindFirstChild("AdminAbuseDoors"))
	end

	warn("[LobbyDoorServer] workspace.AdminAbuse.Scriptables manquant")
	return nil
end

local function waitLobbyDoor(p: number)
	local v3 = os.clock() + p
	local v4

	while true do
		v4 = findLobbyDoorFolder()
		print("ayalalalalla this returned:", v4)

		if v4 then
			break
		end

		task.wait(0.05)

		if v3 <= os.clock() then
			return nil
		end
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraYawRadians()
	if Config.GALAXY_INDEX == 2 then
		return (math.rad(AdminAbuseDoorConfig.Galaxy2CameraYawDegrees))
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraPositionOffset()
	if Config.GALAXY_INDEX == 2 then
		return (Vector3.new(0, -AdminAbuseDoorConfig.Galaxy2CameraDownStuds, 0))
	end

	return createVector(0, 0, 0)
end

local function offsetCameraPair(cframe: CFrame, cframe2: CFrame)
	local v3 = cameraPositionOffset() -- equivalent call inferred; original call site unknown
	return cframe + v3, cframe2 + v3
end

local function buildFarNearOffsetsFromPivot(p)
	local v3 = p.CFrame * CFrame.Angles(0, cameraYawRadians(), 0)
	return offsetCameraPair(
		v3 * AdminAbuseDoorConfig.DoorCameraFarOffset,
		v3 * AdminAbuseDoorConfig.DoorCameraNearOffset
	)
end

local function buildFarNearFromModelExtents(instance)
	local v3 = instance:GetPivot() * CFrame.Angles(0, cameraYawRadians(), 0)
	local extentsSize = instance:GetExtentsSize()
	local v4 = math.max(extentsSize.X, extentsSize.Z) * 0.62 + 5.25
	local v5 = v4 * 2.05 + 5
	local v6 = extentsSize.Y * 0.3
	local v7 = extentsSize.Y * 0.36
	local v8 = v3.Position + Vector3.new(0, extentsSize.Y * 0.27, 0)
	local lookVector = v3.LookVector
	local v9 = v3.Position - lookVector * v4 + Vector3.new(0, v6, 0)
	local v10 = v3.Position - lookVector * v5 + Vector3.new(0, v7, 0)
	return offsetCameraPair(CFrame.lookAt(v10, v8), CFrame.lookAt(v9, v8))
end

local function computeCameraFrames(instance)
	local leftWall = instance:FindFirstChild("LeftWall")
	local rightWall = instance:FindFirstChild("RightWall")

	if not (leftWall and leftWall:IsA("Model") and rightWall and rightWall:IsA("Model")) then
		return nil, nil
	end

	local pivot = leftWall:GetPivot()
	local pivot2 = rightWall:GetPivot()
	local midpoint = (pivot.Position + pivot2.Position) / 2
	local v4 = CFrame.new(midpoint) * CFrame.Angles(pivot:ToOrientation()) * CFrame.Angles(0, cameraYawRadians(), 0)
	local extentsSize = leftWall:GetExtentsSize()
	local extentsSize2 = rightWall:GetExtentsSize()
	local v5 = math.max(extentsSize.Y, extentsSize2.Y)
	local vector2 = Vector3.new(
		extentsSize.X + extentsSize2.X + (pivot.Position - pivot2.Position).Magnitude,
		v5,
		(math.max(extentsSize.Z, extentsSize2.Z))
	)
	local v6 = v4.Position + Vector3.new(0, vector2.Y * 0.27, 0)
	local startTransitionCamera = instance:FindFirstChild("StartTransitionCamera")

	if startTransitionCamera and startTransitionCamera:IsA("BasePart") then
		local v7 = startTransitionCamera.CFrame * CFrame.Angles(0, cameraYawRadians(), 0)
		return offsetCameraPair(v7, v7 * CFrame.new(0, 0, -25))
	end

	local v7 = math.max(vector2.X, vector2.Z) * 0.62 + 5.25
	local v8 = v7 * 2.05 + 5
	local v9 = vector2.Y * 0.3
	local v10 = vector2.Y * 0.36
	local lookVector = v4.LookVector
	local v11 = v4.Position - lookVector * v7 + Vector3.new(0, v9, 0)
	local v12 = v4.Position - lookVector * v8 + Vector3.new(0, v10, 0)
	return offsetCameraPair(CFrame.lookAt(v12, v6), CFrame.lookAt(v11, v6))
end

local function ensureOverlay(playerGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AdminAbuseTransition"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1000000
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	v = screenGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	return frame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deferOnBlack(p: number, callback)
	if p ~= count or not callback then
		return
	end

	task.defer(function()
		if p ~= count then
			return
		end

		local success, result = pcall(callback)

		if not success then
			warn("[AdminAbuse Transition] onBlack: ", result)
		end
	end)
end

function AdminAbuseTransition.play(callback, p)
	local v3 = (p and p.skip) == true
	count += 1
	local v4 = count
	v2 = true
	task.spawn(function()
		if v3 then
			deferOnBlack(v4, callback) -- equivalent call inferred; original call site unknown
			v2 = false
		else
			local currentCamera = Workspace.CurrentCamera

			if currentCamera then
				local localPlayer = Players.LocalPlayer

				if localPlayer then
					local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild(
						"PlayerGui",
						5
					)

					if playerGui then
						local transitionBlackIn = AdminAbuseDoorConfig.TransitionBlackIn
						local transitionBlackHold = AdminAbuseDoorConfig.TransitionBlackHold
						local transitionBlackOut = AdminAbuseDoorConfig.TransitionBlackOut
						local transitionApproachSeconds = AdminAbuseDoorConfig.TransitionApproachSeconds
						local transitionShakeTail = AdminAbuseDoorConfig.TransitionShakeTail
						local v5 = transitionBlackIn + transitionBlackHold
						local v6 = v5 + transitionBlackOut
						local v7 = v5 + transitionApproachSeconds
						local doorOpenDuration = AdminAbuseDoorConfig.DoorOpenDuration
						local cameraType = currentCamera.CameraType
						local cameraSubject = currentCamera.CameraSubject
						local overlay = ensureOverlay(playerGui)
						local v8

						if not (p and p.skipDoor) then
							v8 = waitLobbyDoor(6) or nil
						end

						local v9, v10

						if v8 then
							v9, v10 = computeCameraFrames(v8)
						else
							v9 = nil
							v10 = nil
						end

						local v11

						if v9 == nil then
							v11 = false
						else
							v11 = v10 ~= nil
						end

						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://104296862300351"
						sound.Looped = true
						sound.Volume = 1.8
						sound.Parent = workspace.CurrentCamera or localPlayer:WaitForChild("PlayerGui")
						local random = Random.new()
						local total = 0
						local v12 = false
						local v13 = false
						local v14 = false
						local total2 = 0
						local v15 = "AdminAbuseTransition_" .. tostring(v4)

						local function teardown()
							v2 = false
							RunService:UnbindFromRenderStep(v15)
							destroyActiveScreen() -- equivalent call inferred; original call site unknown

							if v11 then
								currentCamera.CameraType = Enum.CameraType.Custom
								local character = localPlayer.Character
								local humanoid = character and character:FindFirstChildOfClass("Humanoid")

								if humanoid then
									currentCamera.CameraSubject = humanoid
								end
							end

							if not sound.Playing then
								sound:Destroy()
								return
							end

							sound:Stop()
							local sound2 = Instance.new("Sound")
							sound2.SoundId = "rbxassetid://126580113174759"
							sound2.Volume = 2
							sound2.Parent = localPlayer:WaitForChild("PlayerGui")
							sound2:Play()
							task.delay(5, function()
								sound2:Destroy()
								sound:Destroy()
							end)
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function finalize()
							if v4 ~= count then
								return
							end

							teardown()
						end

						local cFrame = nil
						RunService:BindToRenderStep(v15, Enum.RenderPriority.Camera.Value + 1, function(p2: number)
							if v4 == count then
								if v11 and currentCamera.CameraType ~= Enum.CameraType.Scriptable then
									currentCamera.CameraType = Enum.CameraType.Scriptable
									currentCamera.CameraSubject = nil

									if cFrame then
										currentCamera.CFrame = cFrame
									end
								end

								total += p2

								if total < transitionBlackIn then
									overlay.BackgroundTransparency = 1 - easeInOutSine(total / transitionBlackIn)
								elseif total < v5 then
									overlay.BackgroundTransparency = 0
								elseif total < v6 then
									overlay.BackgroundTransparency = easeInOutSine((total - v5) / transitionBlackOut)
								else
									overlay.BackgroundTransparency = 1
								end

								if v11 then
									local cFrame2 = v9
									local cFrame3 = v10

									if total < transitionBlackIn then
										return
									end

									if total < v5 then
										currentCamera.CameraType = Enum.CameraType.Scriptable
										currentCamera.CameraSubject = nil
										currentCamera.CFrame = cFrame2
										currentCamera.Focus = CFrame.new(cFrame2.Position + cFrame2.LookVector)
									elseif total < v7 then
										currentCamera.CameraType = Enum.CameraType.Scriptable
										currentCamera.CameraSubject = nil
										local lerped = cFrame2:Lerp(
											cFrame3,
											easeInOutSine((total - v5) / transitionApproachSeconds)
										)
										currentCamera.CFrame = lerped
										currentCamera.Focus = CFrame.new(lerped.Position + lerped.LookVector)
									else
										currentCamera.CameraType = Enum.CameraType.Scriptable
										currentCamera.CameraSubject = nil

										if not v12 then
											v12 = true
											sound:Play()

											if callback then
												local success, result = pcall(callback)

												if not success then
													warn("[AdminAbuse Transition] onBlack: ", result)
												end
											end
										end

										total2 += p2
										local v18 = math.clamp(total2 / doorOpenDuration, 0, 1)
										local v19 = (1 - math.clamp(
											(total2 - doorOpenDuration * 0.08) / (doorOpenDuration * 0.92 + transitionShakeTail),
											0,
											1
										)) * 0.36 * (math.sin(v18 * 3.141592653589793) * 0.6 + 0.4)
										local cframe = CFrame.Angles(
											random:NextNumber(-0.024, 0.024) * v19 * 3.5,
											random:NextNumber(-0.028, 0.028) * v19 * 3.5,
											random:NextNumber(-0.016, 0.016) * v19 * 3.5
										)
										local cFrame4 = cFrame3 * CFrame.new(
											random:NextNumber(-1, 1) * v19 * 0.44,
											random:NextNumber(-1, 1) * v19 * 0.36,
											random:NextNumber(-1, 1) * v19 * 0.44
										) * cframe
										currentCamera.CFrame = cFrame4
										currentCamera.Focus = CFrame.new(cFrame4.Position + cFrame4.LookVector)
										local v21 = total2

										if doorOpenDuration + transitionShakeTail + 1 <= v21 then
											finalize() -- equivalent call inferred; original call site unknown
										else
											local v22 = total2

											if doorOpenDuration + transitionShakeTail <= v22 then
												currentCamera.CFrame = cFrame3
												currentCamera.Focus = CFrame.new(cFrame3.Position + cFrame3.LookVector)

												if sound.Playing then
													sound:Stop()
												end
											end
										end
									end
								else
									if transitionBlackIn <= total and not v13 then
										v13 = true

										if callback then
											local success, result = pcall(callback)

											if not success then
												warn("[AdminAbuse Transition] onBlack: ", result)
											end
										end
									end

									if v6 <= total and not v14 then
										v14 = true
										finalize() -- equivalent call inferred; original call site unknown
									end
								end

								cFrame = currentCamera.CFrame
							else
								currentCamera.CameraType = cameraType
								currentCamera.CameraSubject = cameraSubject
								RunService:UnbindFromRenderStep(v15)

								if sound then
									sound:Destroy()
								end
							end
						end)
						return
					end
				end

				local v5 = v4
				local v6 = callback

				if v5 == count then
					if not v6 then
						return
					end

					task.defer(function()
						if v5 ~= count then
							return
						end

						local success, result = pcall(v6)

						if not success then
							warn("[AdminAbuse Transition] onBlack: ", result)
						end
					end)
				end
			else
				local v5 = v4
				local v6 = callback

				if v5 == count then
					if not v6 then
						return
					end

					task.defer(function()
						if v5 ~= count then
							return
						end

						local success, result = pcall(v6)

						if not success then
							warn("[AdminAbuse Transition] onBlack: ", result)
						end
					end)
				end
			end
		end
	end)
end

return AdminAbuseTransition