local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local DyleMapEvent = {
	properties = {
		HasAnimatedTrain = true,
		DebugMode = false,
		AnimateLocally = true,
		ServerCreatesTrains = true,
		VerboseLogging = false
	},
	hasLocalEvents = true,
	loadDelay = 0.5,
	setupDelay = 0.1,
	doorOpened = false,
	doorConnection = nil
}

function DyleMapEvent.onRoomLoad(instance, _)
	print("[DyleMapEvent] Setting up trains for DyleMap")
	print("[DyleMapEvent] Room name:", instance.Name)
	print("[DyleMapEvent] Room parent:", not instance.Parent and "nil" or instance.Parent.Name or "nil")
	print("[DyleMapEvent] AnimateLocally:", DyleMapEvent.properties.AnimateLocally)
	print("[DyleMapEvent] ServerCreatesTrains:", DyleMapEvent.properties.ServerCreatesTrains)

	if not DyleMapEvent.properties.ServerCreatesTrains then
		print("[DyleMapEvent] Skipping train creation (ServerCreatesTrains = false)")
		return
	end

	print("[DyleMapEvent] Room contents:")

	for _, child in pairs(instance:GetChildren()) do
		print("  -", child.Name, "[", child.ClassName, "]")
	end

	local trainLocal = ServerStorage:FindFirstChild("TrainLocal") or ReplicatedStorage:FindFirstChild("TrainLocal")
	print("[DyleMapEvent] Storage train found:", trainLocal and trainLocal.Name or "none")

	for _, v in pairs({ "A", "B" }) do
		local child = instance:FindFirstChild("TrainPositions_" .. v)

		if not child then
			continue
		end

		print("[DyleMapEvent] Found TrainPositions_" .. v)
		local trainLocal2 = child:FindFirstChild("TrainLocal")

		if trainLocal2 then
			trainLocal2:SetAttribute("DyleMapTrain" .. v, true)
			trainLocal2:SetAttribute("TrainID", v)
			trainLocal2.Name = "TrainLocal_" .. v

			if not trainLocal2.PrimaryPart then
				if trainLocal2:FindFirstChild("RootPart") then
					trainLocal2.PrimaryPart = trainLocal2.RootPart
				elseif trainLocal2:FindFirstChild("Train_01_Base") then
					trainLocal2.PrimaryPart = trainLocal2.Train_01_Base
				end
			end

			print("[DyleMapEvent] Tagged existing train " .. v .. " at position:", trainLocal2:GetPivot().Position)
			print(
				"[DyleMapEvent] Train has AnimationController:",
				trainLocal2:FindFirstChild("AnimationController") and "Yes" or "No"
			)
		else
			warn("[DyleMapEvent] No TrainLocal found in TrainPositions_" .. v)
		end
	end

	DyleMapEvent.setupDoorOpeningSystem(instance)
end

function DyleMapEvent.setupBehaviors(instance, _)
	print("[DyleMapEvent] setupBehaviors called")
	print("[DyleMapEvent] AnimateLocally:", DyleMapEvent.properties.AnimateLocally)

	if DyleMapEvent.properties.AnimateLocally then
		print("[DyleMapEvent] Trains will be animated locally on clients")
		return
	end

	local v = {}

	for _, v2 in pairs({ "A", "B" }) do
		local folder = nil

		for _, child in pairs(instance:GetChildren()) do
			if not child:GetAttribute("DyleMapTrain" .. v2) then
				continue
			end

			folder = child
			break
		end

		if not (folder and folder.Parent) then
			continue
		end

		local child = instance:FindFirstChild("TrainPositions_" .. v2)

		if not child then
			continue
		end

		local start = child:FindFirstChild("Start")
		child:FindFirstChild("Stop")
		local firstChild = child:FindFirstChild("End")

		if start and firstChild then
			local animationController = folder:FindFirstChild("AnimationController")
			local v4 = {}

			if animationController then
				local parent = folder:FindFirstChild("Animations")

				if not parent then
					parent = Instance.new("Folder")
					parent.Name = "Animations"
					parent.Parent = folder
				end

				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://115687479612520"
				animation.Name = "OpenCloseDoorsAnimation"
				animation.Parent = parent
				local animation2 = Instance.new("Animation")
				animation2.AnimationId = "rbxassetid://72522567109257"
				animation2.Name = "WheelRotationAnimation"
				animation2.Parent = parent
				v4.openCloseDoors = animationController:LoadAnimation(animation)
				v4.wheelRotation = animationController:LoadAnimation(animation2)
				v4.openCloseDoors.Looped = false
				v4.wheelRotation.Looped = true
			end

			local v5 = true
			local v6 = false

			local function setWheelRotationSpeed(p)
				if v4.wheelRotation then
					if p > 0 and not v4.wheelRotation.IsPlaying then
						v4.wheelRotation:Play()
					elseif p == 0 and v4.wheelRotation.IsPlaying then
						v4.wheelRotation:Stop()
					else
						v4.wheelRotation:AdjustSpeed(p)
					end
				end
			end

			local function adjustAudio(playbackSpeed, volume, duration)
				local trainMove = (folder:FindFirstChild("Train_01_Base") or folder):FindFirstChild("TrainMove")

				if trainMove then
					TweenService:Create(
						trainMove,
						TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							PlaybackSpeed = playbackSpeed,
							Volume = volume
						}
					):Play()
				end
			end

			local function toggleEmitters(enabled)
				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = enabled
					end
				end
			end

			local function maybePlayHorn()
				if math.random(1, 4) == 1 and not v6 then
					v6 = true
					local trainHorn = (folder:FindFirstChild("Train_01_Base") or folder):FindFirstChild("TrainHorn")

					if trainHorn then
						trainHorn:Play()
					end
				else
					v6 = false
				end
			end

			local function ensureAudioPlaying()
				local train_01_Base = folder:FindFirstChild("Train_01_Base") or folder
				local trainMove = train_01_Base:FindFirstChild("TrainMove")
				local trainMoveOld = train_01_Base:FindFirstChild("TrainMoveOld")

				if trainMove and not trainMove.Playing then
					trainMove:Play()
				end

				if trainMoveOld and not trainMoveOld.Playing then
					trainMoveOld:Play()
				end
			end

			local v8 = v2
			local v9 = start
			local adjustAudio2 = adjustAudio
			local ensureAudioPlaying2 = ensureAudioPlaying
			local v10 = v4
			local v11 = firstChild
			local maybePlayHorn2 = maybePlayHorn
			task.spawn(function()
				if v8 == "B" then
					task.wait(math.random(5, 10))
				end

				while v5 and folder.Parent do
					folder:PivotTo(v9.CFrame)
					adjustAudio2(0.8, 0.75, 0.75)
					ensureAudioPlaying2()

					if v10.wheelRotation then
						if v10.wheelRotation.IsPlaying then
							v10.wheelRotation:AdjustSpeed(0.5)
						else
							v10.wheelRotation:Play()
						end
					end

					TweenService:Create(
						folder.PrimaryPart,
						TweenInfo.new(12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = v11.CFrame
						}
					):Play()
					task.spawn(function()
						task.wait(0.5)

						if v10.wheelRotation then
							if v10.wheelRotation.IsPlaying then
								v10.wheelRotation:AdjustSpeed(1)
							else
								v10.wheelRotation:Play()
							end
						end
					end)
					maybePlayHorn2()
					task.wait(13)

					if v10.wheelRotation then
						if v10.wheelRotation.IsPlaying then
							v10.wheelRotation:Stop()
						else
							v10.wheelRotation:AdjustSpeed(0)
						end
					end

					adjustAudio2(0.8, 0.01, 2)
					task.wait(math.random(10, 12))
				end
			end)
			local v12 = v4
			table.insert(v, function()
				v5 = false

				if v12.wheelRotation and v12.wheelRotation.IsPlaying then
					v12.wheelRotation:Stop()
				end

				for i, sound in pairs(folder:GetDescendants()) do
					if sound:IsA("Sound") then
						sound:Stop()
					end
				end

				for i, descendant in pairs(folder:GetDescendants()) do
					if not (descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("ParticleEmitter")) then
						continue
					end

					descendant:Destroy()
				end
			end)
		else
			warn("[DyleMapEvent] Missing Start or End positions for train " .. v2)
		end
	end

	table.insert(v, function()
		if DyleMapEvent.doorConnection then
			DyleMapEvent.doorConnection:Disconnect()
			DyleMapEvent.doorConnection = nil
			print("[DyleMapEvent] Door connection cleaned up")
		end

		DyleMapEvent.doorOpened = false
	end)
	return function()
		for _, v2 in ipairs(v) do
			v2()
		end
	end
end

function DyleMapEvent.localBehaviors(instance, _)
	print("[DyleMapEvent Client] Starting local train animations")
	print("[DyleMapEvent Client] Room name:", instance.Name)
	print("[DyleMapEvent Client] Room parent:", not instance.Parent and "nil" or instance.Parent.Name or "nil")
	print("[DyleMapEvent Client] AnimateLocally:", DyleMapEvent.properties.AnimateLocally)
	task.wait(2)
	print("[DyleMapEvent Client] Waiting for server handoff...")
	task.wait(1)
	print("[DyleMapEvent Client] Room children after wait:", #instance:GetChildren())
	local v = false

	for _, child in pairs(instance:GetChildren()) do
		if not child.Name:match("TrainPositions_") then
			continue
		end

		print("[DyleMapEvent Client] Found position folder:", child.Name)
		v = true

		for _, child2 in pairs(child:GetChildren()) do
			print("  - Contains:", child2.Name, "[", child2.ClassName, "]")
		end
	end

	if not v then
		warn("[DyleMapEvent Client] No TrainPositions folders found in room!")
	end

	for _, model in pairs(instance:GetChildren()) do
		if not (model:IsA("Model") and model.Name:match("Train")) then
			continue
		end

		print("[DyleMapEvent Client] Found train model:", model.Name)

		for k, v2 in pairs(model:GetAttributes()) do
			print("  - Attribute:", k, "=", v2)
		end
	end

	print("[DyleMapEvent Client] Checking ReplicatedStorage for train models...")

	for _, model in pairs(ReplicatedStorage:GetChildren()) do
		if model:IsA("Model") and model.Name:match("Train") then
			print("[DyleMapEvent Client] Found train in ReplicatedStorage:", model.Name)
		end
	end

	local v2 = {}

	for _, v3 in pairs({ "A", "B" }) do
		print("[DyleMapEvent Client] Looking for train with suffix:", v3)
		local child = instance:FindFirstChild("TrainPositions_" .. v3)

		if child then
			local child2 = child:FindFirstChild("TrainLocal_" .. v3)

			if child2 then
				print("[DyleMapEvent Client] Found existing train " .. v3 .. " in positions folder")
			else
				warn("[DyleMapEvent Client] No TrainLocal_" .. v3 .. " found in TrainPositions_" .. v3)
			end

			if child2 and child2.Parent then
				if not child2.PrimaryPart then
					if child2:FindFirstChild("RootPart") then
						child2.PrimaryPart = child2.RootPart
					else
						warn("[DyleMapEvent Client] Train " .. v3 .. " has no PrimaryPart")
						continue
					end
				end

				if not child2:FindFirstChild("AnimationController") then
					warn("[DyleMapEvent Client] Train " .. v3 .. " missing AnimationController")
				end

				local train_01_Base = child2:FindFirstChild("Train_01_Base") or child2

				if not (train_01_Base:FindFirstChild("TrainMove") or train_01_Base:FindFirstChild("TrainMoveOld")) then
					warn("[DyleMapEvent Client] Train " .. v3 .. " missing audio components")
				end

				local child3 = instance:FindFirstChild("TrainPositions_" .. v3)

				if child3 then
					local start = child3:FindFirstChild("Start")
					local stop = child3:FindFirstChild("Stop")
					local firstChild = child3:FindFirstChild("End")

					if start and firstChild then
						if start.CFrame == CFrame.new() then
							warn("[DyleMapEvent Client] Start position has invalid CFrame for train " .. v3)
						elseif firstChild.CFrame == CFrame.new() then
							warn("[DyleMapEvent Client] End position has invalid CFrame for train " .. v3)
						else
							print("[DyleMapEvent Client] All position parts found for train " .. v3)
							print("[DyleMapEvent Client] Validating train", v3, "is fully loaded...")
							local count = 0

							while count < 20 do
								local animationController = child2:FindFirstChild("AnimationController")
								local train_01_Base2 = child2:FindFirstChild("Train_01_Base")
								local trainMove = train_01_Base2 and (train_01_Base2:FindFirstChild("TrainMove") or train_01_Base2:FindFirstChild("TrainMoveOld"))

								if animationController and train_01_Base2 and trainMove then
									print("[DyleMapEvent Client] Train", v3, "fully loaded after", count, "attempts")
									break
								else
									count += 1
									task.wait(0.1)
								end
							end

							if count >= 20 then
								warn(
									"[DyleMapEvent Client] Train",
									v3,
									"failed to load completely after",
									20,
									"attempts"
								)
							end

							local animationController = child2:FindFirstChild("AnimationController")
							local v4 = {}

							if animationController then
								print("[DyleMapEvent Client] Found AnimationController for train", v3)
								local parent = child2:FindFirstChild("Animations")

								if not parent then
									parent = Instance.new("Folder")
									parent.Name = "Animations"
									parent.Parent = child2
								end

								local animation = Instance.new("Animation")
								animation.AnimationId = "rbxassetid://115687479612520"
								animation.Parent = parent
								local animation2 = Instance.new("Animation")
								animation2.AnimationId = "rbxassetid://72522567109257"
								animation2.Parent = parent
								local v6 = v4
								local animator = animationController
								local success, result = pcall(function()
									v6.openCloseDoors = animator:LoadAnimation(animation)
									v6.wheelRotation = animator:LoadAnimation(animation2)
								end)

								if success then
									print("[DyleMapEvent Client] Successfully loaded animations for train", v3)
									v4.openCloseDoors.Looped = false
									v4.wheelRotation.Looped = true
								else
									warn("[DyleMapEvent Client] Failed to load animations for train", v3, ":", result)
								end
							else
								warn("[DyleMapEvent Client] No AnimationController found for train", v3)
							end

							local v5 = true

							local function setWheelRotationSpeed(p)
								if v4.wheelRotation then
									if p > 0 and not v4.wheelRotation.IsPlaying then
										v4.wheelRotation:Play()
									elseif p == 0 and v4.wheelRotation.IsPlaying then
										v4.wheelRotation:Stop()
									else
										v4.wheelRotation:AdjustSpeed(p)
									end
								end
							end

							local parent2 = child2

							local function adjustAudio(playbackSpeed, volume, duration)
								local trainMove = (parent2:FindFirstChild("Train_01_Base") or parent2):FindFirstChild("TrainMove")

								if trainMove then
									if not trainMove.Playing then
										trainMove:Play()
									end

									TweenService:Create(
										trainMove,
										TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
										{
											PlaybackSpeed = playbackSpeed,
											Volume = volume
										}
									):Play()
								end
							end

							local folder = child2

							local function toggleEmitters(enabled)
								for i, emitter in pairs(folder:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = enabled
									end
								end
							end

							local parent3 = child2

							local function ensureAudioPlaying()
								local train_01_Base2 = parent3:FindFirstChild("Train_01_Base") or parent3
								local trainMove = train_01_Base2:FindFirstChild("TrainMove")
								local trainMoveOld = train_01_Base2:FindFirstChild("TrainMoveOld")

								if trainMove then
									if not trainMove.Playing then
										trainMove:Play()
									end

									if trainMove.Volume < 0.1 then
										trainMove.Volume = 0.75
									end
								end

								if trainMoveOld then
									if not trainMoveOld.Playing then
										trainMoveOld:Play()
									end

									if trainMoveOld.Volume < 0.1 then
										trainMoveOld.Volume = 0.75
									end
								end
							end

							local folder2 = child2

							local function setTrainTransparency(transparency)
								for i, part in pairs(folder2:GetDescendants()) do
									if part:IsA("BasePart") and part.Name ~= "RootPart" then
										part.Transparency = transparency
									end
								end
							end

							setTrainTransparency(1)
							local v9 = v3
							local parent4 = child2
							local v11 = start
							local setTrainTransparency2 = setTrainTransparency
							local ensureAudioPlaying2 = ensureAudioPlaying
							local adjustAudio2 = adjustAudio
							local v12 = v4
							local v13 = firstChild
							task.spawn(function()
								print("[DyleMapEvent Client] Starting animation loop for train", v9)

								if v9 == "B" then
									local v14 = math.random(5, 10)
									print("[DyleMapEvent Client] Train B waiting", v14, "seconds")
									task.wait(v14)
								end

								local count2 = 0

								while v5 and parent4.Parent do
									count2 += 1

									if DyleMapEvent.properties.VerboseLogging then
										print("[DyleMapEvent Client] Train", v9, "loop", count2, "starting")
									end

									if parent4.Parent then
										parent4:PivotTo(v11.CFrame)

										if count2 == 1 then
											setTrainTransparency2(0)

											if DyleMapEvent.properties.VerboseLogging then
												print(
													"[DyleMapEvent Client] Train",
													v9,
													"made visible at correct position and orientation"
												)
											end
										end

										if DyleMapEvent.properties.VerboseLogging then
											print(
												"[DyleMapEvent Client] Train",
												v9,
												"positioned at start:",
												parent4:GetPivot().Position
											)
										end

										ensureAudioPlaying2()
										adjustAudio2(0.8, 0.75, 0.75)

										if v12.wheelRotation then
											if v12.wheelRotation.IsPlaying then
												v12.wheelRotation:AdjustSpeed(1)
											else
												v12.wheelRotation:Play()
											end
										end

										TweenService:Create(
											parent4.PrimaryPart,
											TweenInfo.new(12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
											{
												CFrame = v13.CFrame
											}
										):Play()
										task.wait(13)

										if v12.wheelRotation then
											if v12.wheelRotation.IsPlaying then
												v12.wheelRotation:Stop()
											else
												v12.wheelRotation:AdjustSpeed(0)
											end
										end

										adjustAudio2(0.8, 0.01, 2)
										task.wait(math.random(10, 12))
									else
										if not DyleMapEvent.properties.VerboseLogging then
											break
										end

										print("[DyleMapEvent Client] Train", v9, "was destroyed, ending loop")
										break
									end
								end
							end)
							local v14 = v4
							local folder3 = child2
							local v15 = v3
							table.insert(v2, function()
								v5 = false

								if v14.wheelRotation then
									if v14.wheelRotation.IsPlaying then
										v14.wheelRotation:Stop()
									end

									v14.wheelRotation:Destroy()
									v14.wheelRotation = nil
								end

								if v14.openCloseDoors then
									if v14.openCloseDoors.IsPlaying then
										v14.openCloseDoors:Stop()
									end

									v14.openCloseDoors:Destroy()
									v14.openCloseDoors = nil
								end

								for i, sound in pairs(folder3:GetDescendants()) do
									if not sound:IsA("Sound") then
										continue
									end

									sound:Stop()
									sound:Destroy()
								end

								if folder3 and folder3.Parent then
									folder3:Destroy()
									print("[DyleMapEvent Client] Train", v15, "destroyed during cleanup")
								end
							end)
						end
					else
						warn("[DyleMapEvent Client] Missing position parts for train " .. v3)
						print("  - Start:", start and "Found" or "Missing")
						print("  - Stop:", stop and "Found" or "Missing")
						print("  - End:", firstChild and "Found" or "Missing")
					end
				else
					warn("[DyleMapEvent Client] No TrainPositions_" .. v3 .. " found")
				end
			else
				warn("[DyleMapEvent Client] No train found for suffix:", v3)
			end
		else
			warn("[DyleMapEvent Client] No TrainPositions_" .. v3 .. " found")
		end
	end

	return function()
		for _, v3 in ipairs(v2) do
			v3()
		end
	end
end

function DyleMapEvent.setupDoorOpeningSystem(instance)
	print("[DyleMapEvent] Setting up door opening system for panic mode")
	local specialDoor = instance:FindFirstChild("SpecialDoor")

	if not specialDoor then
		print("[DyleMapEvent] No SpecialDoor folder found in room")
		return
	end

	local specialDoor2 = specialDoor:FindFirstChild("SpecialDoor")

	if not specialDoor2 then
		print("[DyleMapEvent] No SpecialDoor model found in SpecialDoor folder")
		return
	end

	local doorMain = specialDoor2:FindFirstChild("DoorMain")
	local doorHandle = specialDoor2:FindFirstChild("DoorHandle")
	local noClip_Collider = specialDoor2:FindFirstChild("NoClip_Collider")

	if not (doorMain and doorHandle) then
		warn("[DyleMapEvent] Missing door components (DoorMain or DoorHandle)")
		return
	end

	local closed = doorMain:GetAttribute("Closed")
	local open = doorMain:GetAttribute("Open")
	local closed2 = doorHandle:GetAttribute("Closed")
	local opened = doorHandle:GetAttribute("Opened")

	if closed and open and closed2 and opened then
		print("[DyleMapEvent] Door components found, setting up panic mode listener")

		if DyleMapEvent.doorConnection then
			DyleMapEvent.doorConnection:Disconnect()
		end

		DyleMapEvent.doorConnection = workspace.Info.Panic.Changed:Connect(function()
			if workspace.Info.Panic.Value and not DyleMapEvent.doorOpened then
				print("[DyleMapEvent] Panic mode activated! Opening door...")
				DyleMapEvent.doorOpened = true
				Audio:Play("Sounds.ZoneEvents.MapEvents.DoorOpen", {
					Name = "DoorOpenSound",
					Volume = 0.5,
					PlaybackSpeed = 0.8,
					Parent = doorMain
				})
				local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
				local vector = Vector3.new(closed.X, closed.Y, closed.Z)
				local v = Vector3.new(open.X, open.Y, open.Z).Y - vector.Y
				local vector2 = Vector3.new(closed2.X, closed2.Y, closed2.Z)
				local v2 = Vector3.new(opened.X, opened.Y, opened.Z).Y - vector2.Y
				local tween = TweenService:Create(doorMain, tweenInfo, {
					CFrame = doorMain.CFrame + Vector3.new(0, v, 0)
				})
				local tween2 = TweenService:Create(doorHandle, tweenInfo, {
					CFrame = doorHandle.CFrame + Vector3.new(0, v2, 0)
				})
				tween:Play()
				tween2:Play()
				tween.Completed:Connect(function()
					if noClip_Collider then
						noClip_Collider.CanCollide = false
						print("[DyleMapEvent] Door opened! Players can now enter the lore room")
					end
				end)
			end
		end)
		print("[DyleMapEvent] Door opening system initialized")
	else
		warn("[DyleMapEvent] Missing door position attributes")
		warn("  - doorMainClosed:", closed)
		warn("  - doorMainOpened:", open)
		warn("  - doorHandleClosed:", closed2)
		warn("  - doorHandleOpened:", opened)
	end
end

return DyleMapEvent