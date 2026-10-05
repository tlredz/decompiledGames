local SnowHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local v = false

function PlaceFootprint(p, p2)
	local v2 = p.CFrame * CFrame.new(p2 and 0.5 or -0.5, 0, 0)
	Client.Events.PlaceSnowFootprint:FireAllClients(v2)
end

function CreateFootprint(cframe: CFrame)
	local groundPosition, v2 = Client.CollisionUtility.GetGroundPosition(cframe.Position)

	if groundPosition and v2 and v2.Material == Enum.Material.Snow and (v2.Instance.Name == "Grass" or v2.Instance.Name == "Snow") then
		local instance = v2.Instance
		local clone = game.ReplicatedStorage.Assets.Christmas.SnowFootprint:Clone()
		local ancestryChangedConnection = nil
		ancestryChangedConnection = instance.AncestryChanged:Connect(function()
			if clone.Parent then
				clone:Destroy()
			end

			ancestryChangedConnection:Disconnect()
		end)
		task.delay(30, function()
			local tweenInfo = TweenInfo.new(2)

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") and part.Transparency < 1 then
					TweenService:Create(part, tweenInfo, {
						Transparency = 1
					}):Play()
				end
			end

			task.wait(2.5)
			clone:Destroy()
			ancestryChangedConnection:Disconnect()
		end)
		local v3 = -clone.PrimaryPart.Size.Y / 2 + 0.05
		clone:PivotTo(cframe - cframe.Position + groundPosition + Vector3.new(0, v3, 0))
		clone.Parent = workspace.Particles
	end
end

Client.Events.PlaceSnowFootprint:Connect(function(_, cframe: CFrame)
	CreateFootprint(cframe)
end)

function StartMoving(instance, object)
	local _ = instance.Position
	local timePosition = 0
	local v2 = nil
	v = true
	PlaceFootprint(instance, true)

	while instance.Parent and object.Parent and object.MoveDirection.Magnitude > 0.1 and v and object.FloorMaterial == Enum.Material.Snow do
		if v2 and not v2.IsPlaying then
			v2 = nil
		end

		if v2 == nil then
			local playingAnimationTracks = object:GetPlayingAnimationTracks()

			for _, playingAnimationTrack in pairs(playingAnimationTracks) do
				if not (playingAnimationTrack.Animation.Name == "WalkAnim" and (v2 == nil or v2 ~= playingAnimationTrack)) then
					continue
				end

				timePosition = playingAnimationTrack.TimePosition
				v2 = playingAnimationTrack
				break
			end
		end

		if v2 then
			local timePosition2 = v2.TimePosition

			if object.FloorMaterial == Enum.Material.Snow and localPlayer:GetAttribute("Sledding") == nil then
				if timePosition < 0.2 and timePosition2 > 0.2 then
					PlaceFootprint(instance, true)
				elseif timePosition < 0.5 and timePosition2 > 0.5 then
					PlaceFootprint(instance, false)
				end
			end

			task.wait()
			timePosition = timePosition2
		else
			task.wait()
		end
	end

	v = false
end

function CharacterAdded(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local running = humanoidRootPart:WaitForChild("Running")
	v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		if humanoid.FloorMaterial == Enum.Material.Snow then
			humanoid.HipHeight = -0.4
			running.SoundId = "rbxassetid://117188087959039"
			running.Volume = 0.15
		else
			humanoid.HipHeight = 0
			running.SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
			running.Volume = 0.65
		end
	end

	humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		update() -- equivalent call inferred; original call site unknown

		if humanoid.MoveDirection.Magnitude > 0.1 and not v and humanoid.FloorMaterial == Enum.Material.Snow then
			StartMoving(humanoidRootPart, humanoid)
		end
	end)
	update() -- equivalent call inferred; original call site unknown
	humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if humanoid.MoveDirection.Magnitude > 0.1 and not v and humanoid.FloorMaterial == Enum.Material.Snow then
			StartMoving(humanoidRootPart, humanoid)
		end
	end)
end

function SnowHandler.Init()
	task.spawn(function()
		localPlayer.CharacterAdded:Connect(CharacterAdded)

		if localPlayer.Character then
			CharacterAdded(localPlayer.Character)
		end
	end)
end

return SnowHandler