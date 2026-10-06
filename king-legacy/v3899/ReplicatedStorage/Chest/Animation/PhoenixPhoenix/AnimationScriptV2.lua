local createVector = vector.create
wait()
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local humanoid = character.Humanoid
local humanoidRootPart = character.HumanoidRootPart
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local track = _G.PU.GetAnimator(humanoid):LoadAnimation(ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.Fly)
local track2 = _G.PU.GetAnimator(humanoid):LoadAnimation(ReplicatedStorage.Chest.Animation.PhoenixPhoenix.V2.Idle)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local track3 = _G.PU.GetAnimator(humanoid):LoadAnimation(game.ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixGlide)
track3.Priority = Enum.AnimationPriority.Action3
local keyframeReachedConnection = nil
local keyframeReachedConnection2 = nil

function DisconnectAnim()
	if keyframeReachedConnection and keyframeReachedConnection.Connected then
		keyframeReachedConnection:Disconnect()
	end

	if keyframeReachedConnection2 and keyframeReachedConnection2.Connected then
		keyframeReachedConnection2:Disconnect()
	end
end

function CreateWingWhooshSound()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://73563380040785",
		Volume = 1.35
	})
	_G.PU:Dust(sound, 2)
	sound.Parent = humanoidRootPart
	sound:Play()
end

function StartConnection(p)
	if not p then
		return
	end

	DisconnectAnim()

	if p == "IdleAnim" then
		keyframeReachedConnection = track2.KeyframeReached:Connect(function(p2)
			if p2 == "PlaySound" and not track3.IsPlaying then
				CreateWingWhooshSound()
			end
		end)
		return
	end

	if p ~= "FlyAnim" then
		return
	end

	keyframeReachedConnection2 = track.KeyframeReached:Connect(function(p2)
		if p2 == "PlaySound" and not track3.IsPlaying then
			CreateWingWhooshSound()
		end
	end)
end

track2:Play()
StartConnection("IdleAnim")
local currentCamera = workspace.CurrentCamera
local v = 0
local v2 = 0
local lastTime = nil
RunService.Heartbeat:Connect(function(dt)
	if character:FindFirstChild("Doing") then
		if track.IsPlaying then
			track:Stop()
		end

		if not track2.IsPlaying then
			track2:Play()
			StartConnection("IdleAnim")
		end
	else
		local v3 = math.acos((currentCamera.CFrame.LookVector:Dot(createVector(0, 1, 0))))
		local dot = (currentCamera.CFrame.LookVector * createVector(1, 0, 1)):Dot(humanoid.MoveDirection * createVector(
			1,
			0,
			1
		))
		local dot2 = (currentCamera.CFrame.RightVector * createVector(1, 0, 1)):Dot(humanoid.MoveDirection * createVector(
			1,
			0,
			1
		))

		if v3 >= 1.6580627893946132 and humanoid.MoveDirection.Magnitude > 0 and humanoidRootPart.AssemblyLinearVelocity.Y <= -(humanoid.WalkSpeed / 2) and dot > 0 and math.abs(dot2) <= 0.5 and not _G.CheckDoingClient(localPlayer) then
			v = math.min(v + dt, 1)

			if v >= 1 then
				v2 = math.min(v2 + dt * 70, 120)

				if not track3.IsPlaying then
					track3:Play(0.4)
					ReplicatedStorage.Chest.Remotes.Events.ClientRemote:FireServer({
						Type = "Phoenix V2 Glide"
					})
					ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
						Mode = "Start",
						Time = 10,
						Color = Color3.fromRGB(0, 255, 255)
					})
				end
			end
		elseif _G.CheckDoingClient(localPlayer) then
			v = 0
			v2 = 0

			if track3.IsPlaying then
				track3:Stop(0.4)
				ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
					Mode = "Stop"
				})
			end
		else
			v = math.max(v - dt, 0)
			v2 = math.max(v2 - dt * 27.5, 0)

			if track3.IsPlaying and v <= 0 and v2 <= 0 then
				track3:Stop(0.4)
				ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
					Mode = "Stop"
				})
			end
		end

		if v2 > 0 then
			if not lastTime then
				lastTime = tick()
			end

			if tick() - lastTime > 10 then
				v = 0
				v2 = 0

				if track3.IsPlaying then
					track3:Stop(0.4)
					ReplicatedStorage.Chest.Remotes.Bindables.FlyTime:Fire({
						Mode = "Stop"
					})
				end
			elseif character:GetAttribute("FlyBoost") ~= v2 then
				character:SetAttribute("FlyBoost", v2)
			end
		else
			lastTime = nil

			if character:GetAttribute("FlyBoost") then
				character:SetAttribute("FlyBoost", nil)
			end
		end

		local v4 = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed

		if v4 > 0 then
			if track2.IsPlaying then
				track2:Stop(0.4)
				DisconnectAnim()
			end

			if not track.IsPlaying then
				track:Play(0.4)
				StartConnection("FlyAnim")
			end
		elseif v4 <= 0 then
			if track.IsPlaying then
				track:Stop(0.4)
				DisconnectAnim()
			end

			if not track2.IsPlaying then
				track2:Play(0.4)
				StartConnection("IdleAnim")
			end

			v = 0
			v2 = 0
		end
	end
end)