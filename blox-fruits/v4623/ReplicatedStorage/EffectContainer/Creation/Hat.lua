local v = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local hat = nil
task.spawn(function()
	hat = FX:WaitForChild("Creation").Hat
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage2:WaitForChild("Util"))

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max)
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

return function(player)
	local fortBuilderActive = player.FortBuilderActive

	if not fortBuilderActive then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local creationTopHat = character:WaitForChild("CreationTopHat", 2)

	if not creationTopHat then
		return
	end

	local topHatDoubleOutline = creationTopHat:WaitForChild("Top Hat (Double Outline)", 2)

	if not topHatDoubleOutline then
		return
	end

	local topHat = creationTopHat:WaitForChild("TopHat", 2)

	if not topHat or v[character] then
		return
	end

	v[character] = true
	local v2 = 0

	if player.FortBuilderActive.Value then
		topHat.Transparency = 0
		topHatDoubleOutline.Transparency = 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function AllhatOff()
		topHat.Transparency = 1
		topHatDoubleOutline.Transparency = 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function TophatOff()
		topHat.Transparency = 0
		topHatDoubleOutline.Transparency = 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function TophatOn()
		topHat.Transparency = 1
		topHatDoubleOutline.Transparency = 0
	end

	local connections = {}
	tick()
	local v3 = nil

	local function HandleAnimationTrack(object)
		if v3 then
			Util.Sound:FadeOut(v3, 0.2)
			v3 = nil
		end

		local name = object.Animation.Name

		if name == "CreationFHold" or name == "CreationFTapHold" or name == "CreationFTap" then
			while object.Length <= 0 do
				task.wait()
			end

			if name == "CreationFHold" then
				task.delay(math.max(0.3 - object.TimePosition, 0), function()
					if object.IsPlaying and v2 < os.clock() then
						v2 = os.clock() + 0.2
						v3 = Util.Sound:Play(
							"CreationFruit_CreationToggleOn_01",
							character.HumanoidRootPart,
							nil,
							1.111111111111111,
							1,
							0.3
						)
					end
				end)
			end

			for _, connection in pairs(connections) do
				local connection2 = connection
				pcall(function()
					connection2:Disconnect()
				end)
			end

			topHatDoubleOutline.Transparency = 0
			object.Looped = false

			if object:GetTimeOfKeyframe("END") < object.TimePosition then
				TophatOff() -- equivalent call inferred; original call site unknown
			else
				local stoppedConnection = nil
				local signal = Util.Signal2.new()
				local connection = object:GetMarkerReachedSignal("END"):Once(function()
					stoppedConnection:Disconnect()
					TophatOff() -- equivalent call inferred; original call site unknown
					task.delay(0.5, function()
						signal:Fire()
					end)

					if name == "CreationFTap" and v2 < os.clock() then
						v2 = os.clock() + 0.2
						Util.Sound:Play("CreationFruit_F_BuildMode_Enter_01", character.HumanoidRootPart)
					end
				end)
				stoppedConnection = object.Stopped:Once(function()
					connection:Disconnect()
					AllhatOff() -- equivalent call inferred; original call site unknown
				end)
				local connection2 = signal:Once(function()
					if not fortBuilderActive.Value then
						AllhatOff() -- equivalent call inferred; original call site unknown
					end
				end)
				connections = { connection, stoppedConnection, connection2 }
			end
		elseif name == "CreationFDeactivate" then
			while object.Length <= 0 do
				task.wait()
			end

			local v4

			if v2 < os.clock() then
				v4 = true
				v2 = os.clock() + 0.2
				Util.Sound:Play("CreationFruit_CreationToggleOff_01", character.HumanoidRootPart)
			else
				v4 = false
			end

			for _, connection in pairs(connections) do
				local connection2 = connection
				pcall(function()
					connection2:Disconnect()
				end)
			end

			connections = {}
			TophatOff() -- equivalent call inferred; original call site unknown

			if object:GetTimeOfKeyframe("SWAP") < object.TimePosition then
				TophatOn() -- equivalent call inferred; original call site unknown
			else
				table.insert(connections, object:GetMarkerReachedSignal("SWAP"):Once(function()
					TophatOn() -- equivalent call inferred; original call site unknown
				end))
			end

			if v4 and hat then
				local clone = topHatDoubleOutline:Clone()
				clone.Parent = workspace._WorldOrigin
				clone.Transparency = 1
				clone.Anchored = true
				Util.Debris:AddItem(clone, 3)

				local function ThrownHatImpact()
					local position = clone.Position
					local clone2 = hat.EndImpact:Clone()
					clone2.Position = position
					clone2.Parent = workspace._WorldOrigin
					Util.Debris:AddItem(clone2, 15)

					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v5 = emitter
						task.spawn(function()
							if v5:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v5:GetAttribute("EmitDelay"))
							end

							v5:Emit(v5:GetAttribute("EmitCount"))
						end)
					end

					DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
				end

				local function THROWHAT(p: number)
					AllhatOff() -- equivalent call inferred; original call site unknown
					clone.Transparency = 0
					clone.CFrame = topHatDoubleOutline.CFrame
					local cFrame = character.HumanoidRootPart.CFrame * CFrame.new(
						8.63828,
						3.84709,
						7.17942,
						0.13951,
						-0.12462,
						-0.98235,
						0.10389,
						0.98842,
						-0.11064,
						0.98476,
						-0.08662,
						0.15084
					)
					local TweenService = game:GetService("TweenService")
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(math.max(0.32 - p, 0), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = cFrame
						}
					)
					tween.Completed:Once(function()
						ThrownHatImpact()
						clone:Destroy()
					end)
					tween:Play()
				end

				local timeOfKeyframe = object:GetTimeOfKeyframe("THROW")

				if timeOfKeyframe < object.TimePosition then
					THROWHAT(object.TimePosition - timeOfKeyframe)
				else
					table.insert(connections, object:GetMarkerReachedSignal("THROW"):Once(function()
						THROWHAT(object.TimePosition - timeOfKeyframe)
					end))
				end
			elseif object:GetTimeOfKeyframe("THROW") < object.TimePosition then
				AllhatOff() -- equivalent call inferred; original call site unknown
			else
				table.insert(connections, object:GetMarkerReachedSignal("THROW"):Once(function()
					AllhatOff() -- equivalent call inferred; original call site unknown
				end))
			end
		end
	end

	local animationPlayedConnection = animator.AnimationPlayed:Connect(HandleAnimationTrack)

	for _, v4 in pairs(animator:GetPlayingAnimationTracks()) do
		task.spawn(HandleAnimationTrack, v4)
	end

	local ancestryChangedConnection = nil
	ancestryChangedConnection = topHatDoubleOutline.AncestryChanged:Connect(function(_, parent)
		if parent then
			return
		end

		v[character] = nil
		animationPlayedConnection:Disconnect()
		ancestryChangedConnection:Disconnect()
	end)
end