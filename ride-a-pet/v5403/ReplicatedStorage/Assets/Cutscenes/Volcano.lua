local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Volcano = {}
local v = nil

function Volcano.Stop()
	if v then
		v.Cancelled = true
	end
end

function Volcano:Play()
	assert(RunService:IsClient(), "Volcano.Play must run on the client")

	if v then
		return false, "Already playing"
	end

	local v2 = self or {}
	local SFX = v2.SFX or {
		Flight = "",
		Lair = "",
		WakeUp = "",
		Pullback = "",
		End = ""
	}
	local v3 = 0
	local v4 = v3 + 9.2 + 0.2 - 0.1
	local v5 = {
		Cancelled = false
	}
	v = v5
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character
	local currentCamera = workspace.CurrentCamera
	local fieldOfView = currentCamera and currentCamera.FieldOfView
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	local connections = {}
	local v6 = {}
	local clone = nil
	local track = nil
	local screenGui = nil
	local clone2 = nil
	local v7 = nil
	local v8 = nil
	local v9 = nil
	local v10 = false
	local music = SoundService:FindFirstChild("Music")
	local cutscenePaused = nil
	local v11 = false
	local isPlayingsBySound = {}

	local function PauseAmbient(sound)
		if not sound:IsA("Sound") or isPlayingsBySound[sound] ~= nil then
			return
		end

		local name = sound.Name:lower()

		if not (name:find("ambience", 1, true) or name:find("ambient", 1, true)) then
			return
		end

		isPlayingsBySound[sound] = sound.IsPlaying

		if sound.IsPlaying then
			sound:Pause()
		end

		table.insert(connections, sound:GetPropertyChangedSignal("Playing"):Connect(function()
			if sound.IsPlaying then
				sound:Pause()
			end
		end))
	end

	local streamingLease = nil
	local v12 = nil
	local enabledsByBlurEffect = {}

	local function SuppressBlur(blurEffect)
		if not blurEffect:IsA("BlurEffect") or enabledsByBlurEffect[blurEffect] ~= nil then
			return
		end

		enabledsByBlurEffect[blurEffect] = blurEffect.Enabled
		blurEffect.Enabled = false
		table.insert(connections, blurEffect:GetPropertyChangedSignal("Enabled"):Connect(function()
			if blurEffect.Enabled then
				blurEffect.Enabled = false
			end
		end))
	end

	local enabledsByScreenGui = {}

	local function HideGui(screenGui2)
		if not screenGui2:IsA("ScreenGui") or screenGui2 == screenGui or enabledsByScreenGui[screenGui2] ~= nil then
			return
		end

		enabledsByScreenGui[screenGui2] = screenGui2.Enabled
		screenGui2.Enabled = false
		table.insert(connections, screenGui2:GetPropertyChangedSignal("Enabled"):Connect(function()
			if screenGui2.Enabled then
				screenGui2.Enabled = false
			end
		end))
	end

	local v13 = false
	local flag = false

	local function Cue(p)
		local v14 = SFX[p]

		if not v14 or v14 == "" then
			return
		end

		local sound = Instance.new("Sound")
		sound.Name = "Volcano_" .. p
		sound.SoundId = tostring(v14):match("^%d+$") and "rbxassetid://" .. v14 or tostring(v14)
		sound.Volume = v2.SFXVolume or 0.7
		sound.Parent = SoundService
		table.insert(v6, sound)
		sound:Play()
		Debris:AddItem(sound, 30)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function RestoreCamera()
		if not v13 then
			return
		end

		RunService:UnbindFromRenderStep("VolcanoCutsceneCamera")
		v13 = false
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			currentCamera2.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") or cameraSubject
			currentCamera2.FieldOfView = fieldOfView or 70
			currentCamera2.CameraType = Enum.CameraType.Custom
		end
	end

	local function Cleanup()
		if streamingLease and v12 then
			task.spawn(function()
				pcall(streamingLease.InvokeServer, streamingLease, "Release", v12)
			end)
		end

		if v11 and music then
			music:SetAttribute("CutscenePaused", cutscenePaused)
		end

		RestoreCamera() -- equivalent call inferred; original call site unknown

		if flag then
			ContextActionService:UnbindAction("VolcanoCutsceneInput")
		end

		for _, connection in connections do
			connection:Disconnect()
		end

		for k, v14 in enabledsByBlurEffect do
			local v15 = k
			local enabled = v14
			pcall(function()
				v15.Enabled = enabled
			end)
		end

		for k, v14 in isPlayingsBySound do
			if v14 and k.Parent then
				k:Resume()
			end
		end

		for k, v14 in enabledsByScreenGui do
			local v15 = k
			local enabled = v14
			pcall(function()
				v15.Enabled = enabled
			end)
		end

		if v10 and v7 and v8 then
			local guardianState = v7:GetAttribute("GuardianState")

			if guardianState == "Chasing" or guardianState == "Returning" then
				pcall(v8.Fly, v7)
			elseif guardianState ~= "Waking" then
				pcall(v8.Sleep, v7)
			end
		end

		if track then
			track:Stop(0)
			track:Destroy()
		end

		if clone then
			clone:Destroy()
		end

		if screenGui then
			screenGui:Destroy()
		end

		for _, v14 in v6 do
			v14:Destroy()
		end

		v = nil
	end

	local v14, v15 = xpcall(function()
		local WAIT_INTERVAL = 0.1
		assert(currentCamera and character, "Character/camera not ready")
		local v16 = assert(character:FindFirstChildOfClass("Humanoid"), "Humanoid missing")
		assert(v16.Health > 0, "Character is dead")
		local serverData = ReplicatedStorage:FindFirstChild("ServerData")

		if serverData then
			table.insert(connections, serverData:GetAttributeChangedSignal("VolcanoRevealed"):Connect(function()
				if serverData:GetAttribute("VolcanoRevealed") ~= true then
					Volcano.Stop()
				end
			end))
		end

		table.insert(connections, SoundService.DescendantAdded:Connect(PauseAmbient))

		for _, descendant in SoundService:GetDescendants() do
			PauseAmbient(descendant)
		end

		streamingLease = script:WaitForChild("StreamingLease", 10)
		assert(streamingLease, "Volcano streaming service unavailable")
		local HttpService = game:GetService("HttpService")
		v12 = HttpService:GenerateGUID(false)
		local v17 = false
		local v18 = nil
		local v19 = nil
		task.spawn(function()
			local success, result = pcall(
				streamingLease.InvokeServer,
				streamingLease,
				v2.StudioPreview == true and RunService:IsStudio() and "AcquireStudio" or "Acquire",
				v12
			)

			if success and type(result) == "number" then
				v18 = result
			else
				v19 = result
			end

			v17 = true

			if v ~= v5 then
				pcall(streamingLease.InvokeServer, streamingLease, "Release", v12)
			end
		end)
		local v20 = os.clock() + 30

		while not v17 and os.clock() < v20 and not v5.Cancelled do
			task.wait(WAIT_INTERVAL)
		end

		local v21 = v17

		if v21 then
			if type(v18) == "number" then
				v21 = v18 > 0
			else
				v21 = false
			end
		end

		assert(v21, "Volcano loading request failed: " .. tostring(v19))

		while true do
			local volcano = workspace:FindFirstChild("Volcano")
			local volcanoIsland = volcano and volcano:FindFirstChild("VolcanoIsland")
			local count = 0

			if volcanoIsland then
				for _, part in volcanoIsland:GetDescendants() do
					if part:IsA("BasePart") then
						count += 1
					end
				end
			end

			if not (v18 <= count) then
				task.wait(WAIT_INTERVAL)

				if v20 <= os.clock() or v5.Cancelled then
					volcanoIsland = nil
				else
					continue
				end
			end

			assert(volcanoIsland, "VolcanoIsland did not finish streaming; cutscene cancelled")
			local v22

			if localPlayer.Character == character then
				v22 = v16.Health > 0
			else
				v22 = false
			end

			assert(v22, "Character changed while loading")
			local ContentProvider = game:GetService("ContentProvider")
			local v23 = {}
			local SFX2 = script:FindFirstChild("SFX")
			local sound = SFX2 and SFX2:FindFirstChild("Sound")

			if sound and sound:IsA("Sound") then
				clone2 = sound:Clone()
				clone2.Name = "Volcano_Opening"
				clone2.PlayOnRemove = false
				clone2.Looped = false
				clone2:Stop()
				clone2.TimePosition = 0
				table.insert(v6, clone2)
				table.insert(v23, clone2)
			end

			local speedWinds = { volcanoIsland, ReplicatedStorage.Assets.Pets.Griffin }
			table.insert(speedWinds, ReplicatedStorage.Assets.Effects.SpeedWind)

			for _, folder in speedWinds do
				for _, descendant in folder:GetDescendants() do
					if not (descendant:IsA("MeshPart") or descendant:IsA("SurfaceAppearance") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Animation") and (descendant.Name == "Fly" or descendant.Name == "Sleeping" or descendant.Name == "WakeUp" or descendant.Name == "Idle")) then
						continue
					end

					table.insert(v23, descendant)
				end
			end

			local v24 = false
			local v25 = nil
			task.spawn(function()
				local success, result = pcall(function()
					ContentProvider:PreloadAsync(v23, function(p, p2)
						if p2 ~= Enum.AssetFetchStatus.Success then
							v25 = tostring(p)
						end
					end)
				end)

				if not success then
					v25 = tostring(result)
				end

				v24 = true
			end)

			while not v24 and os.clock() < v20 and not v5.Cancelled do
				task.wait(WAIT_INTERVAL)
			end

			assert(v24 and not v25, "Volcano visual assets failed to load: " .. tostring(v25))

			if v5.Cancelled then
				break
			end

			v7 = assert(volcanoIsland:FindFirstChild("SleepingVolkaris"), "Sleeping Volkaris has not streamed in")
			local VolkarisLairAnimation = require(ReplicatedStorage.GameServices:WaitForChild("VolkarisLairAnimation"))
			v8 = VolkarisLairAnimation
			v9 = v8.Sleep(v7)
			local v28 = os.clock() + 10

			while (v9.Tracks.WakeUp.Length == 0 or v9.Tracks.Sleeping.Length == 0) and os.clock() < v28 and not v5.Cancelled do
				task.wait(0.05)
			end

			local v29

			if v9.Tracks.WakeUp.Length > 0 then
				v29 = v9.Tracks.Sleeping.Length > 0
			else
				v29 = false
			end

			assert(v29, "Volkaris animations failed to load; cutscene cancelled")

			if v5.Cancelled then
				break
			end

			v3 = v9.Tracks.WakeUp.Length + 0.1
			v4 = v3 + 9.2 + 0.2 - 0.1
			task.spawn(pcall, streamingLease.InvokeServer, streamingLease, "Extend", v12, v4 + 0.5)
			local functionals = workspace:FindFirstChild("Functionals")
			local volcanoCutscene = functionals and functionals:FindFirstChild("VolcanoCutscene")
			local v30 = {}
			local v31 = nil

			for _, childName in {
				"Cam1",
				"Cam2",
				"LairCam",
				"LairCamEnd",
				"GriffinStart",
				"GriffinEnd"
			} do
				local part = volcanoCutscene and volcanoCutscene:FindFirstChild(childName)

				if part and part:IsA("BasePart") then
					v30[childName] = part.CFrame
				else
					v31 = v31 or script:WaitForChild("Markers", 10)
					local child = v31 and v31:WaitForChild(childName, 10)
					assert(child, "Volcano cutscene marker missing: " .. childName)
					v30[childName] = child.Value
				end
			end

			if v5.Cancelled then
				break
			end

			if music then
				cutscenePaused = music:GetAttribute("CutscenePaused")
				v11 = true
				music:SetAttribute("CutscenePaused", true)
			end

			table.insert(connections, v16.Died:Connect(Volcano.Stop))
			table.insert(connections, localPlayer.CharacterRemoving:Connect(Volcano.Stop))
			table.insert(connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(Volcano.Stop))
			local Lighting = game:GetService("Lighting")
			table.insert(connections, Lighting.DescendantAdded:Connect(SuppressBlur))
			table.insert(connections, currentCamera.DescendantAdded:Connect(SuppressBlur))

			for _, descendant in Lighting:GetDescendants() do
				SuppressBlur(descendant)
			end

			for _, descendant in currentCamera:GetDescendants() do
				SuppressBlur(descendant)
			end

			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "VolcanoCutsceneOverlay"
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 10000
			screenGui.ResetOnSpawn = false
			local frame = Instance.new("Frame")
			frame.Name = "BlackFrame"
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundColor3 = Color3.new(1, 1, 1)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.Parent = screenGui
			local playerGui = localPlayer:WaitForChild("PlayerGui")
			screenGui.Parent = playerGui

			if clone2 then
				clone2.Parent = SoundService
				clone2:Play()
			end

			table.insert(connections, playerGui.DescendantAdded:Connect(HideGui))

			for _, descendant in playerGui:GetDescendants() do
				HideGui(descendant)
			end

			ContextActionService:BindActionAtPriority("VolcanoCutsceneInput", function()
				return Enum.ContextActionResult.Sink
			end, false, Enum.ContextActionPriority.High.Value + 1, unpack(Enum.PlayerActions:GetEnumItems()))
			flag = true
			v16:Move(createVector(0, 0, 0))
			RunService.RenderStepped:Wait()

			local function FlightPosition(p)
				local v33 = math.min(p, 1)
				local v34 = 1 - v33
				local v35 = createVector(-32, 0, 45) * v34 ^ 3 + createVector(-20, 2, -120) * (v34 ^ 2 * 3 * v33) + createVector(
					35,
					12,
					-180
				) * (v34 * 3 * v33 ^ 2) + createVector(45, 20, -240) * v33 ^ 3 + createVector(35, 12, -220) * math.max(
					p - 1,
					0
				)
				local v36 = math.clamp(p * 2.5 / 5, 0, 1)
				return v30.Cam1:Lerp(v30.Cam2, v36):PointToWorldSpace(v35)
			end

			local v33 = createVector(0, 0, 0)
			-- equivalent calls inferred from this helper; original call sites unknown
			local FlightPosition2 = FlightPosition

			local function FlightPose(p)
				local flightPosition2 = FlightPosition2(p)
				local flightPosition22 = FlightPosition2(p + 0.001)
				return CFrame.lookAt(flightPosition2, flightPosition22) * CFrame.new(-v33)
			end

			if workspace.StreamingEnabled then
				for _, v34 in {
					"Cam1",
					"Cam2",
					"LairCam",
					"LairCamEnd"
				} do
					local v35 = v30
					local v36 = v34
					task.spawn(function()
						pcall(localPlayer.RequestStreamAroundAsync, localPlayer, v35[v36].Position, 3)
					end)
				end

				local v34 = v30
				task.spawn(function()
					while v == v5 and not v5.Cancelled do
						pcall(
							localPlayer.RequestStreamAroundAsync,
							localPlayer,
							v34.LairCam.Position + v34.LairCam.LookVector * 50,
							1
						)
						task.wait(0.75)
					end
				end)
			end

			if v5.Cancelled then
				break
			end

			clone = ReplicatedStorage.Assets.Pets.Griffin:Clone()
			clone.Name = "VolcanoCutsceneGriffin"

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("LuaSourceContainer") or descendant:IsA("Trail") or descendant:IsA("ParticleEmitter") or descendant.Name == "InitialPoses" or descendant.Name == "AnimSaves" then
					descendant:Destroy()
				elseif descendant:IsA("BasePart") then
					descendant.CanCollide = false
					descendant.CanTouch = false
					descendant.CanQuery = false
					descendant.Anchored = true

					if descendant.Name == "Seat" or descendant.Name == "RootPart" then
						descendant.Transparency = 1
					end
				end
			end

			local griffin = clone:FindFirstChild("Griffin")

			if griffin and griffin:IsA("BasePart") then
				v33 = clone:GetPivot():PointToObjectSpace(griffin.Position)
			end

			if griffin and griffin:IsA("BasePart") then
				local clone3 = ReplicatedStorage.Assets.Effects.SpeedWind:Clone()
				clone3.Parent = clone
				clone3.Anchored = false
				clone3.Massless = true
				clone3.CanCollide = false
				clone3.CanTouch = false
				clone3.CanQuery = false
				local motor6D = assert(clone3:FindFirstChild("Connector"), "SpeedWind Connector missing")
				assert(motor6D:IsA("Motor6D"), "SpeedWind Connector must be a Motor6D")
				local part = assert(clone:FindFirstChild("RootPart"), "Griffin RootPart missing")
				local C0 = motor6D.C1 * motor6D.C0:Inverse()
				motor6D.Part0 = part
				motor6D.Part1 = clone3
				motor6D.C0 = C0
				motor6D.C1 = CFrame.identity
				motor6D.Transform = CFrame.identity
				motor6D.Enabled = true
				clone3.CFrame = part.CFrame * C0
			end

			local v34 = clone
			local v35 = createVector(-32, 0, 45) + createVector(0, 0, -0)
			local pointToWorldSpace = v30.Cam1:Lerp(v30.Cam2, 0):PointToWorldSpace(v35)
			local v36 = createVector(-31.963871, 0.00602399, 44.505318) + createVector(0, 0, -0)
			local pointToWorldSpace2 = v30.Cam1:Lerp(v30.Cam2, 0.0005):PointToWorldSpace(v36)
			v34:PivotTo(CFrame.lookAt(pointToWorldSpace, pointToWorldSpace2) * CFrame.new(-v33))
			clone.Parent = workspace
			local parent = clone:FindFirstChildOfClass("AnimationController")

			if not parent then
				parent = Instance.new("AnimationController")
				parent.Parent = clone
			end

			local v38 = parent:FindFirstChildOfClass("Animator")

			if not v38 then
				v38 = Instance.new("Animator")
				v38.Parent = parent
			end

			track = v38:LoadAnimation((assert(
				clone:FindFirstChild("Animations") and clone.Animations:FindFirstChild("Fly"),
				"Griffin Fly animation missing"
			)))
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Action
			track:Play(0)
			track:AdjustSpeed(1.6)

			if v5.Cancelled then
				break
			end

			track.TimePosition = 0
			local lastTime = os.clock()
			local v39 = false
			local v40 = false
			local v41 = false
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.FieldOfView = 70
			currentCamera.CFrame = v30.Cam1
			local v44 = v30

			local function Step()
				local v46 = math.min(os.clock() - lastTime, v4)
				currentCamera.CameraType = Enum.CameraType.Scriptable

				if v46 < 5 then
					if not v40 then
						v40 = true
						Cue("Flight")
					end

					frame.BackgroundColor3 = Color3.new(1, 1, 1)
					frame.BackgroundTransparency = math.clamp((v46 - 0.2) / 0.35, 0, 1)
					local v47 = math.clamp(v46 / 5, 0, 1)
					local lerped = v44.Cam1:Lerp(v44.Cam2, v47)
					local v48 = math.clamp((v46 - 0.14) / 0.6, 0, 1)
					local v49 = math.sin(3.141592653589793 * v48) ^ 2
					currentCamera.FieldOfView = 70 - v47 * 15
					currentCamera.CFrame = lerped * CFrame.new(
						math.sin(v46 * 75) * 0.16 * v49,
						math.sin(v46 * 91) * 0.1 * v49,
						0
					) * CFrame.Angles(0, 0, (math.rad(math.sin(v46 * 65) * 0.6 * v49)))
					clone:PivotTo(FlightPose(v46 / 2.5))
				elseif v46 < 5.2 then
					frame.BackgroundColor3 = Color3.new()
					frame.BackgroundTransparency = 0
					currentCamera.CFrame = v44.Cam2
					local v47 = clone
					local v48 = createVector(45, 20, -240) + createVector(35, 12, -220)
					local pointToWorldSpace3 = v44.Cam1:Lerp(v44.Cam2, 1):PointToWorldSpace(v48)
					local v49 = createVector(45, 20, -240) + createVector(35.035, 12.012001, -220.22002)
					local pointToWorldSpace4 = v44.Cam1:Lerp(v44.Cam2, 1):PointToWorldSpace(v49)
					v47:PivotTo(CFrame.lookAt(pointToWorldSpace3, pointToWorldSpace4) * CFrame.new(-v33))
				else
					local v47 = v46 - 5.2

					if v47 >= 4 and not v10 then
						v10 = true
						pcall(v8.Wake, v7)
						Cue("WakeUp")
					end

					frame.BackgroundColor3 = Color3.new()
					frame.BackgroundTransparency = math.clamp(v47 / 1, 0, 1)
					local v48 = math.clamp(v47 / 4, 0, 1)
					local v49 = math.clamp((v47 - 4 - v3) / 0.2, 0, 1)
					local v50 = v49 * v49 * (3 - v49 * 2)
					local v51 = v48 * (1 - v50)
					currentCamera.CFrame = v44.LairCam:Lerp(v44.LairCamEnd, v51)
					currentCamera.FieldOfView = v48 * -30 + 70 + v50 * 30

					if not v39 then
						v39 = true
						Cue("Lair")
					end

					if v49 > 0 and not v41 then
						v41 = true
						Cue("Pullback")
					end
				end

				if v4 - 0.1 <= v46 then
					frame.BackgroundColor3 = Color3.new()
					frame.BackgroundTransparency = 1 - math.clamp((v46 - (v4 - 0.1)) / 0.1, 0, 1)
				end
			end

			local Step2 = Step
			RunService:BindToRenderStep("VolcanoCutsceneCamera", Enum.RenderPriority.Camera.Value + 1, function()
				if v5.Cancelled then
					return
				end

				local success, result = pcall(Step2)

				if not success then
					warn("Volcano cutscene frame failed: " .. tostring(result))
					Volcano.Stop()
				end
			end)
			v13 = true

			while not v5.Cancelled and os.clock() - lastTime < v4 do
				task.wait()
			end

			if v5.Cancelled then
				break
			end

			frame.BackgroundColor3 = Color3.new()
			frame.BackgroundTransparency = 0
			RestoreCamera() -- equivalent call inferred; original call site unknown
			Cue("End")
			local lastTime2 = os.clock()

			repeat
				RunService.RenderStepped:Wait()
				frame.BackgroundTransparency = math.clamp((os.clock() - lastTime2) / 0.5, 0, 1)
			until v5.Cancelled or os.clock() - lastTime2 >= 0.5

			break
		end
	end, debug.traceback)
	local cancelled = v5.Cancelled
	Cleanup()

	if not v14 then
		warn("Volcano cutscene: " .. tostring(v15))
	end

	return v14 and not cancelled, v15
end

return Volcano