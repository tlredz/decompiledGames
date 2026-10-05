local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local FX = require(game.ReplicatedStorage.FX)
local skypiean = FX:WaitForChild("RaceAwakenings").Skypiean

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function viewerIsClose(position, p, fn, fn2)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		if (humanoidRootPart.Position - position).magnitude <= p then
			fn((position - humanoidRootPart.Position).magnitude)
		else
			fn2((position - humanoidRootPart.Position).magnitude)
		end
	end
end

local function getAnimation(parent)
	local upperTorso = parent:FindFirstChild("UpperTorso")

	if upperTorso then
		for _, child in pairs(workspace._WorldOrigin.PlayerAccessoriesProxy:GetChildren()) do
			local rootPart = child:FindFirstChild("RootPart")

			if not rootPart then
				continue
			end

			local motor6D = rootPart:FindFirstChild("Motor6D")

			if not (motor6D and motor6D.Part0 == upperTorso and child:FindFirstChild("AnimationController") and child.AnimationController:FindFirstChild("Animator")) then
				continue
			end

			local animator = child.AnimationController.Animator

			for _, v in pairs(animator:GetPlayingAnimationTracks()) do
				return v
			end
		end
	end
end

return function(player)
	local index = player.Index or 1

	if index == 1 then
		if player.Ended then
			local child = _WorldOrigin:FindFirstChild("KneelFX" .. player.ID)

			if child then
				child:SetAttribute("Disabled", true)
			end
		else
			local root = player.Root
			local humanoid = player.Humanoid

			if not (root and humanoid) then
				return
			end

			Util.Sound:Play("PortalOpen", root, nil, 0.8, 5)
			local v = Util.Sound:Play("AuraLoop", root, nil, 1.2, 0.3)
			local v2 = {
				Radius = player.Radius,
				Life = player.Duration,
				MaxShake = player.MaxShake,
				MinShake = player.MinShake,
				KneelRadius = player.KneelRange
			}
			local timestamp = player.Timestamp
			local hipHeight = humanoid.HipHeight
			local _ = masterClock:GetTime() - timestamp
			local v3 = false
			os.clock()

			local function canRun()
				local humanoid2 = humanoid

				if humanoid2 then
					if humanoid.Parent == nil or not (humanoid.Health > 0) then
						return false
					else
						return root and root:IsDescendantOf(workspace) and not v3
					end
				end

				return humanoid2
			end

			local clone = skypiean.KneelAura:Clone()
			local maid = Util.Maid.new()
			maid:GiveTask(clone:GetAttributeChangedSignal("Disabled"):Connect(function()
				if clone:GetAttribute("Disabled") then
					maid:DoCleaning()
				end
			end))
			maid:GiveTask(player.Root:GetPropertyChangedSignal("Parent"):Connect(function()
				if not player.Root.Parent then
					maid:DoCleaning()
				end
			end))
			maid:GiveTask(function()
				v3 = true
				Util.Debris:AddItem(clone, 1)
			end)
			clone.Lines.ShapePartial = v2.KneelRadius * 2
			local attachment = clone.Attachment
			clone.Position = root.Position - Vector3.new(0, hipHeight, 0)
			attachment.Disc.Size = NumberSequence.new(0, v2.Radius)
			attachment.Waves.Size = NumberSequence.new(0, v2.KneelRadius)
			clone.Parent = _WorldOrigin
			clone.Name = "KneelFX" .. player.ID
			clone.Lines.Enabled = true
			local v4 = 0
			local total = 0
			local kneelRadius = v2.KneelRadius
			local clone2 = skypiean.TrailPart:Clone()
			maid:GiveTask(function()
				Util.Debris:AddItem(clone2, 1)
			end)
			clone2.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(v4), 0) * CFrame.new(
				0,
				total,
				kneelRadius
			)
			clone2.Trail.Enabled = true
			clone2.Parent = _WorldOrigin
			local lastTime = os.clock()
			local lastTime2 = os.clock()
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
			local v5 = 0.016666666666666666

			while true do
				local v6

				if humanoid then
					if humanoid.Parent == nil or not (humanoid.Health > 0) then
						v6 = false
					else
						v6 = root and root:IsDescendantOf(workspace) and not v3
					end
				else
					v6 = humanoid
				end

				if v6 then
					local magnitude = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude
					local _ = root.Velocity.Magnitude

					if magnitude > 2000 then
						v5 = 0.06666666666666667
					elseif magnitude < 1200 then
						v5 = 0.03333333333333333
					else
						local _ = magnitude < 800
					end

					local v7 = v5 * 60
					local v8 = Util.Ray(
						root.Position,
						CFrame.new(root.Position).UpVector.Unit * -(humanoid.HipHeight + 5),
						{ workspace.Characters, workspace.Enemies }
					) and true or false

					if clone2 then
						local v9 = v4 + v7 * 3
						total += (math.cos(v9 / 12) * 10 + 0 - total) * 0.1
						kneelRadius += (v2.KneelRadius - 5 + math.cos(v9 / 20) * 15 - kneelRadius) * 0.1
						v4 = v9 > 360 and 0 or v9
						clone2.CFrame = clone2.CFrame:Lerp(
							CFrame.new(root.Position) * CFrame.Angles(0, math.rad(v4), 0) * CFrame.new(
								0,
								total * v7,
								kneelRadius * v7
							),
							0.2
						)
					end

					if clone then
						clone.Position = root.Position - Vector3.new(0, hipHeight, 0)

						if v8 then
							if os.clock() - lastTime > 0.2 then
								clone.Lines.Enabled = true
								attachment.Disc:Emit(1)
								attachment.Waves:Emit(1)
								lastTime = os.clock()
							end
						else
							clone.Lines.Enabled = false
						end
					end

					if os.clock() - lastTime2 > 0.1 and game.Players.LocalPlayer.Character ~= root.Parent then
						viewerIsClose(root.Position, v2.Radius * 0.8, function(p)
							local cameraShaker = Util.CameraShaker
							local maxShake = v2.MaxShake
							local minShake = v2.MinShake
							local v9 = math.max(0, p / (v2.Radius * 0.8))
							cameraShaker:ShakeOnce(maxShake + (minShake - maxShake) * v9, 20, 0.2, 0.2)
							TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
								Saturation = (1 - p / (v2.Radius * 0.8)) * -2
							}):Play()
						end, function()
							if colorCorrectionEffect.Saturation < 0 then
								TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
									Saturation = 0
								}):Play()
							end
						end)
						lastTime2 = os.clock()
					end

					v5 = RunService.RenderStepped:Wait()
				else
					TweenService:Create(colorCorrectionEffect, TweenInfo.new(1), {
						Saturation = 0
					}):Play()
					task.delay(1, function()
						if colorCorrectionEffect then
							colorCorrectionEffect:Destroy()
						end

						if clone then
							clone:Destroy()
						end

						if clone2 then
							clone2:Destroy()
						end
					end)
					pcall(function()
						clone.Lines.Enabled = false
					end)
					pcall(function()
						clone2.Trail.Enabled = false
					end)

					if v then
						Util.Sound:FadeOut(v, 0.5)
					end

					return
				end
			end
		end
	elseif index == 2 then
		local character = player.Character
		local kneelTime = player.KneelTime
		local timestamp = player.Timestamp

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
					return
				end

				if not character:GetAttribute("KneelAnimation") then
					local parent = Util.Sound:Play(
						"GroundSmash",
						humanoidRootPart,
						nil,
						math.random(120, 130) / 100,
						0.9
					)
					local chorusSoundEffect = Instance.new("ChorusSoundEffect")
					chorusSoundEffect.Depth = 0.61
					chorusSoundEffect.Mix = 0.77
					chorusSoundEffect.Rate = 1.8
					chorusSoundEffect.Parent = parent
				end

				local duration = math.clamp(kneelTime - (masterClock:GetTime() - timestamp) + 0.05, 0.1, kneelTime)
				local hipHeight = humanoid.HipHeight
				local clone = skypiean.KneelImpact:Clone()
				Util.Debris:AddItem(clone, duration + 1)
				clone.Position = humanoidRootPart.Position + createVector(0, 3, 0)
				clone.Parent = _WorldOrigin
				local floor = clone.Floor
				floor.WorldPosition = humanoidRootPart.Position - Vector3.new(0, hipHeight, 0)

				for _, child in pairs(floor:GetChildren()) do
					if child.Name ~= "Dust" then
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end

				if Util.Ray(
					humanoidRootPart.Position,
					CFrame.new(humanoidRootPart.Position).UpVector.Unit * -(hipHeight + 5),
					{ workspace.Characters, workspace.Enemies }
				) then
					local downLines = clone.DownLines
					downLines.Enabled = true
					task.delay(duration, function()
						if downLines then
							downLines.Enabled = false
						end
					end)
					floor.Dust:Emit(floor.Dust:GetAttribute("EmitCount"))
					humanoidRootPart:SetAttribute("KneelOrigin", humanoidRootPart.Position)
					local skyAuraKneel

					if (character == game.Players.LocalPlayer.Character or player.Npc) and duration > 0 and not character:GetAttribute("KneelAnimation") then
						if not player.Npc then
							Util.BodyMover.new(character):Create("BodyPosition", {
								Duration = duration,
								Priority = -10000,
								Position = humanoidRootPart.Position
							})
						end

						skyAuraKneel = Util.Anims:Get(character, "SkyAuraKneel")
						skyAuraKneel:Play()
						skyAuraKneel:AdjustSpeed(1)
						task.delay(0.2, function()
							if skyAuraKneel then
								skyAuraKneel.TimePosition = 0.3
								skyAuraKneel:AdjustSpeed(0)
							end
						end)
					else
						skyAuraKneel = nil
					end

					if not character:GetAttribute("KneelAnimation") then
						task.delay(duration, function()
							local floor2 = clone.Floor
							local vector2 = Vector3.new(0, hipHeight, 0)

							repeat
								wait()
								clone.Position = humanoidRootPart.Position + createVector(0, 3, 0)
								floor2.WorldPosition = humanoidRootPart.Position - vector2
							until (humanoidRootPart:GetAttribute("KneelOrigin") - humanoidRootPart.Position).Magnitude > 2 or not humanoidRootPart:IsDescendantOf(workspace)

							character:SetAttribute("KneelAnimation", false)

							if skyAuraKneel then
								skyAuraKneel:Stop()
							end
						end)
					end

					character:SetAttribute("KneelAnimation", true)
				else
					if character == game.Players.LocalPlayer.Character then
						Util.BodyMover.new(character):Create("BodyVelocity", {
							Duration = 0.4,
							Priority = -9000,
							Velocity = CFrame.new(humanoidRootPart.Position).upVector * -120
						})
					end

					local clone2 = skypiean.Shockwave:Clone()
					Util.Debris:AddItem(clone2, 1)
					clone2.Size = createVector(25, 1, 25)
					clone2.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
						0,
						math.rad((math.random(0, 360))),
						0
					)
					clone2.Parent = _WorldOrigin
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0),
						{
							Size = createVector(1, 25, 1),
							Transparency = 1,
							CFrame = clone2.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 1.0471975511965976, 0)
						}
					)
					tween.Completed:Connect(function()
						if clone2 then
							clone2:Destroy()
						end
					end)
					tween:Play()
				end
			end
		end
	elseif index == 3 then
		local root = player.Root
		local operation = player.Operation

		if root then
			if operation == 1 then
				local maxGlideSpeed = player.MaxGlideSpeed
				local currentCamera = workspace.CurrentCamera
				local v = Util.Sound:Play("WindBlowing", root, nil, 1, 0)
				v.Looped = true
				v.RollOffMaxDistance = 10000

				if maxGlideSpeed == nil then
					v.Volume = 1
				end

				local animation = getAnimation(player.Root.Parent)
				local clone = skypiean.FlightRoot.GlideFeathers:Clone()
				debris:AddItem(clone, 200)
				local clone2 = skypiean.FlightRoot.GlideWinds:Clone()
				debris:AddItem(clone2, 200)
				local clone3 = skypiean.FlightRoot.Smoke:Clone()
				debris:AddItem(clone3, 200)

				if maxGlideSpeed == nil then
					clone.Speed = NumberRange.new(5, 15)
					clone.SpreadAngle = Vector2.new(20, 20)
					clone.EmissionDirection = "Bottom"
				end

				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "RA_SkypieanGliding"
				boolValue.Value = true
				boolValue.Parent = root
				local changedConnection = nil
				changedConnection = boolValue.Changed:Connect(function()
					if boolValue == nil or boolValue.Parent == nil then
						for _, v3 in pairs({ clone, clone2, clone3 }) do
							if v3 then
								v3:Destroy()
							end
						end

						if changedConnection then
							changedConnection:Disconnect()
						end
					end
				end)
				clone.Parent = root
				clone2.Parent = root
				clone3.Parent = root
				clone.Enabled = true

				local function canRun()
					return root and root:IsDescendantOf(workspace) and boolValue and boolValue:IsDescendantOf(workspace)
				end

				local lastTime = os.clock()
				local lastTime2 = os.clock()
				local v2 = 0.016666666666666666

				while root and root:IsDescendantOf(workspace) and boolValue and boolValue:IsDescendantOf(workspace) do
					if currentCamera then
						local magnitude = (currentCamera.CFrame.Position - root.Position).Magnitude
						local magnitude2 = root.Velocity.Magnitude

						if magnitude > 2000 then
							v2 = 0.06666666666666667
						elseif magnitude < 1200 then
							v2 = 0.03333333333333333
						elseif magnitude < 800 then
							v2 = 0.016666666666666666
						else
							v2 = v2
						end

						if magnitude2 > 130 and os.clock() - lastTime > 0.1 then
							if clone2 and clone2.Parent ~= nil then
								clone2:Emit(1)
							end

							lastTime = os.clock()
						end

						if magnitude2 > 230 and os.clock() - lastTime2 > 0.02 then
							if clone3 and clone3.Parent ~= nil then
								clone3:Emit(1)
							end

							lastTime2 = os.clock()
						end

						if v and maxGlideSpeed then
							v.PlaybackSpeed = 1 + 1.5 * (magnitude2 / maxGlideSpeed)
							v.Volume = 0 + 10 * (magnitude2 / maxGlideSpeed)
						end

						if animation then
							if maxGlideSpeed then
								if root.Velocity.Y < 0 then
									local v3 = math.max((5 + root.Velocity.Y) / 5, 0)
									animation:AdjustSpeed(math.pow(
										math.abs((math.abs(animation.TimePosition - 2.2))),
										0.6
									) + v3)
								else
									animation:AdjustSpeed((math.max((root.Velocity.Y - 10) / 10, 0)))
								end
							elseif magnitude2 > 2 then
								animation:AdjustSpeed(5)
							else
								animation:AdjustSpeed(1)
							end
						end
					end

					task.wait(v2)
				end

				if animation then
					animation:AdjustSpeed(1)
				end

				if clone then
					clone.Enabled = false
				end

				task.delay(1.5, function()
					for _, v4 in pairs({ clone, clone2, clone3 }) do
						if v4 then
							v4:Destroy()
						end
					end
				end)

				if changedConnection then
					changedConnection:Disconnect()
				end

				if boolValue then
					boolValue:Destroy()
				end

				if v then
					v:Destroy()
				end
			elseif operation == 0 then
				for _, child in pairs(root:GetChildren()) do
					if child.Name == "RA_SkypieanGliding" then
						child:Destroy()
					end
				end
			end
		end
	end
end