local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local masterClock = Util.MasterClock
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(script.Parent.Modules.RockRipple)
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("Gravity").M1

local function emitAll(folder)
	for i, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isUserBehind(p, position)
	local unit = (position - p.Position).Unit
	return p.LookVector:Dot(unit) < 0
end

local function fragment(instance, p, p2)
	local size = instance.Size
	local v = size.X / p
	local v2 = size.Y / p
	local Z = size.Z
	local v3 = -size.X / 2 + v / 2
	local v4 = -size.Y / 2 + v2 / 2
	local folder = Instance.new("Folder", workspace._WorldOrigin)
	Util.Debris:AddItem(folder, 4)

	for i = 0, p - 1 do
		for i2 = 0, p - 1 do
			local vector2 = Vector3.new(v3 + i2 * v, v4 + i * v2, 0)
			local cFrame = instance.CFrame * CFrame.new(vector2)
			local clone = instance:Clone()
			clone.Size = Vector3.new(v, v2, Z)
			clone.CFrame = cFrame
			clone.Anchored = false
			clone.CanCollide = true
			clone.Parent = folder
			task.delay(1.3 + math.random() * 0.2, function()
				local tween = TweenService:Create(clone, TweenInfo.new(0.3), {
					Size = createVector(0, 0, 0)
				})
				tween.Completed:Connect(function()
					clone:Destroy()
				end)
				tween:Play()
			end)
			rocks:ApplyCollision(clone, nil, true)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = -instance.CFrame.LookVector * (1 + math.random() * 0.5) * p2 + (clone.Position - instance.Position).Unit * p2
			bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
			bodyVelocity.P = 10000
			bodyVelocity.Parent = clone
			task.delay(0.2, function()
				bodyVelocity:Destroy()
			end)
		end
	end
end

local function lateralRocks(cFrame, p, Z, p2)
	local v = {
		workspace._WorldOrigin,
		workspace.Characters,
		workspace.Enemies,
		workspace.Boats
	}
	task.spawn(function()
		local count = 0

		for i = 1, Z, p2 do
			local v2 = p2 * (1 + 0.4 * math.random())

			for i2 = -1, 1, 2 do
				if (i <= v2 * 4 and 0.6 or Z - v2 * 4 <= i and 0.6 or 0.75) < math.random() then
					continue
				end

				local v4

				if math.random(1, 5) == 1 then
					v4 = 0.5 + math.random() * 0.25
				else
					v4 = false
				end

				if v4 then
					v2 *= v4
				end

				local ray, v5, v6 = Util.Ray(
					cFrame * Vector3.new(p / 2 * i2 * (1 + math.random() * 0.2) * (v4 or 1), 1, -i),
					Vector3.new(0, -p / 2 - 2, 0),
					v
				)

				if not (ray and ray.Anchored and ray.Transparency <= 0) then
					continue
				end

				local alignCFrame = Util.Misc.AlignCFrame(
					CFrame.lookAt(createVector(0, 0, 0), cFrame.LookVector) + v5,
					v6
				)
				local cFrame2 = alignCFrame * CFrame.new(0, -v2 * 0.5, 0)
				local cFrame3 = alignCFrame * CFrame.new(0, -v2 * 0.25, 0) * CFrame.Angles(
					0,
					0,
					i2 * math.rad((math.random(10, 30)))
				)
				local part = Instance.new("Part")
				part.Color = ray.Color
				part.TopSurface = 0
				part.BottomSurface = 0
				part.Material = ray.Material
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new(1 + math.random(), 1, 1 + math.random() * 1.5) * v2
				part.CFrame = cFrame2
				part.Parent = _WorldOrigin
				local tween = TweenService:Create(
					part,
					TweenInfo.new(0.1 + math.random() * 0.2, Enum.EasingStyle.Back),
					{
						CFrame = cFrame3
					}
				)
				tween.Completed:Connect(function()
					task.wait(1.8 + 0.2 * math.random())
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							CFrame = cFrame2 * CFrame.new(0, -v2 * 0.1, 0)
						}
					)
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end

			count += 1

			if count % 10 == 0 then
				task.wait(0.016666666666666666)
			end
		end
	end)
end

return function(player)
	local origin = player.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage
	local player2 = player.Player
	local root = player.Root or player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		local clone = M1.HOLDEFFECTS.Hold:Clone()
		Util.SetParentOverrideWithColor(clone, root.Parent.RightHand, player2, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone, 10)
		folder.Destroying:Connect(function()
			clone:Destroy()
		end)
		emitAll(clone.Emit)
		local lastTime = tick()
		local startPos = player.StartPos
		local v = root.Size.Y * 0.5 + root.Parent.Humanoid.HipHeight
		local v2 = Util.Sound:Play("GravFruit_M1_Hold_01", root)
		local v3 = 90
		local v4 = 90
		local v5 = 1
		local clone2 = nil
		local clone3 = nil
		local v6 = true
		local flag = false
		local attachment = nil
		local v7 = false
		local v8 = nil

		while player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace) do
			local v9 = tick() - lastTime

			if player.Client then
				v7 = false
				local unit = (startPos - origin).Unit
				local v10

				if v3 < (startPos - origin).Magnitude then
					v10 = origin + unit * v3
				else
					v10 = startPos
				end

				local p = player.Mouse.Hit.p
				local unit2 = (p - origin).Unit
				local v11

				if v3 < (p - origin).Magnitude then
					v11 = origin + unit2 * v3
				else
					v11 = p
				end

				local unit3 = (p - v10).Unit

				if v4 < (p - v10).Magnitude then
					p = v10 + unit3 * v4
				end

				if (v11 - origin).Magnitude < (p - origin).Magnitude then
					p = v11
				end

				local position = v10 + Vector3.new(0, v, 0)
				local position2 = p + Vector3.new(0, v, 0)

				if not clone2 then
					clone2 = M1.SWIPESIGNAL1.Part:Clone()
					clone2.Position = position
					Util.SetParentOverrideWithColor(clone2, folder, player2, "GravityFruitVFXColor")
					attachment = Instance.new("Attachment")
					attachment.Parent = clone2
					v8 = Util.Sound:Play("GravFruit_M1_HoldIndicator_01", clone2)
				end

				if not clone3 then
					local clone4 = M1.SWIPESIGNAL1.BeamIndicator:Clone()
					local clone5 = M1.SWIPESIGNAL1.BeamIndicator2:Clone()
					clone3 = M1.SWIPESIGNAL1.Part2:Clone()
					clone3.Position = position2
					Util.SetParentOverrideWithColor(clone3, folder, player2, "GravityFruitVFXColor")
					local attachment2 = Instance.new("Attachment")
					attachment2.Parent = clone3
					clone4.Attachment0 = attachment
					clone4.Attachment1 = attachment2
					Util.SetParentOverrideWithColor(clone4, clone2, player2, "GravityFruitVFXColor")
					clone5.Attachment0 = attachment
					clone5.Attachment1 = attachment2
					Util.SetParentOverrideWithColor(clone5, clone2, player2, "GravityFruitVFXColor")
				end

				local v14

				if (position - position2).Magnitude <= 10 then
					local ray, v15, v16 = Util.Ray(
						Vector3.new(position.X, origin.Y, position.Z),
						createVector(0, 1, 0) * -v4,
						{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
					)
					v14 = true

					if ray or v15.Y < -4 then
						local ray2, v17, v18 = Util.Ray(
							v15,
							createVector(0, 1, 0) * v4,
							{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
						)
					else
						v7 = true
					end
				else
					v14 = false
				end

				if CFrame.lookAt(position, position2).LookVector.Y < -0.1 and not v14 then
					local ray = Util.Ray
					local v15 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
					local v16, v17 = ray(position, createVector(-0, -10, -0), v15)
					v7 = not (v16 or v17.Y < -4) or v7
				end

				if v7 then
					local cframe = CFrame.lookAt(position - unit * 0.01, player.Mouse.Hit.p)
					unit = cframe.LookVector
					local v15
					v15, position2 = Util.Ray(
						cframe.Position,
						cframe.LookVector * v4,
						{ workspace.Characters, workspace.Enemies }
					)
					_ = v15
				end

				clone2.Position = position
				clone3.Position = position2

				if v7 then
					clone2.CFrame = CFrame.lookAt(clone2.Position, position2 + unit * 0.012345)
					v6 = v6 and false

					if not flag then
						for i, effect in pairs(clone2.METEOR:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
								effect.Enabled = true
							end
						end

						flag = true
					end
				else
					if flag then
						for i, effect in pairs(clone2.METEOR:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								effect.Enabled = false
								effect:Clear()
							elseif effect:IsA("Beam") then
								effect.Enabled = false
							end
						end

						flag = false
					end

					if not v6 then
						v6 = true
					end
				end
			end

			local v10 = player.HiddenFolder:FindFirstChild("KineticAmplifier1") and 2 or 1
			local v11 = player.HiddenFolder:FindFirstChild("KineticAmplifier2") and player.HiddenFolder:FindFirstChild("KineticAmplifier1") and 3 or v10

			if v5 == 1 and v9 > 0.6666666666666666 and v11 >= 2 then
				v5 = 2
				v3 = 99
				v4 = 117
				clone:Destroy()
				clone = M1.HOLDEFFECTS.Hold2:Clone()
				Util.Debris:AddItem(clone, 10)
				folder.Destroying:Connect(function()
					clone:Destroy()
				end)
				Util.SetParentOverrideWithColor(clone, root.Parent.RightHand, player2, "GravityFruitVFXColor")
				emitAll(clone.Emit)
				Util.Sound:Play("GravFruit_M1_HoldPower_Increase_Indicator_01", root.Parent.RightHand.Position)

				if clone2 and clone3 then
					Util.ResizeModel(clone2, 1.7)
					Util.ResizeModel(clone3, 1.7)
				end
			elseif v5 == 2 and v9 > 2 and v11 >= 3 then
				v5 = 3
				v3 = 135
				v4 = 180
				clone:Destroy()
				clone = M1.HOLDEFFECTS.Hold3:Clone()
				Util.Debris:AddItem(clone, 10)
				folder.Destroying:Connect(function()
					clone:Destroy()
				end)
				Util.SetParentOverrideWithColor(clone, root.Parent.RightHand, player2, "GravityFruitVFXColor")
				emitAll(clone.Emit)
				Util.Sound:Play("GravFruit_M1_HoldPower_Increase_IndicatorLevel2_01_V2", root.Parent.RightHand.Position)

				if clone2 and clone3 then
					Util.ResizeModel(clone2, 1.7)
					Util.ResizeModel(clone3, 1.7)
				end
			end

			task.wait()
		end

		if player.Client and v7 then
			Util.Sound:Play("GravFruit_M1_SkyMeteor_Release_0" .. tostring(math.random(1, 4)) .. "_V2", clone2.Position)
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		if v8 then
			Util.Sound:FadeOut(v8, 0.2)
		end

		task.spawn(function()
			emitAll(clone.Emit)
			task.wait(0.15)
			clone:Destroy()
		end)

		if clone2 then
			clone2:Destroy()
			clone3:Destroy()
		end

		task.wait(2)
		folder:Destroy()
	elseif stage == 3 then
		local powerLevel = player.PowerLevel
		local v = player.Thickness * 0.625
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local part = Instance.new("Part")
		part.Size = Vector3.new(v, v, player.Length)
		part.CanCollide = false
		part.Anchored = true
		part.Transparency = 1
		part.CFrame = player.MidCFrame
		part.Parent = folder
		local clone = M1["Stage" .. powerLevel]:Clone()
		clone.Size = Vector3.new(v, v, 1)
		clone.CanCollide = false
		clone.Anchored = true
		clone.Transparency = 1
		clone.CFrame = player.MidCFrame * CFrame.new(0, 0, player.Length / 2)
		Util.SetParentOverrideWithColor(clone, folder, player2, "GravityFruitVFXColor")
		emitAll(clone)
		local v2 = player.Neutral and "GravFruit_M1_DownSmash_" .. tostring(powerLevel) or "GravFruit_M1_GroundSwipe_" .. tostring(powerLevel)
		local clone2 = M1.JaggedCylinder:Clone()
		clone2.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Size = Vector3.new(v * 1.1, 5, v * 1.1)
		clone2.Transparency = 6
		Util.SetParentOverrideWithColor(clone2, folder, player2, "GravityFruitVFXColor")

		if player.Neutral then
			local v3 = player.MidCFrame * CFrame.new(0, 0, -player.Length / 2)
			local v4 = Util.Sound:Play(v2, v3.Position)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v4, TweenInfo.new(v4.TimeLength * 0.12), {
				Volume = 1.25
			}):Play()
		else
			local v3 = player.MidCFrame * CFrame.new(0, 0, -player.Length / 2)
			local v4 = Util.Sound:Play(v2, clone.Position)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v4.Parent, TweenInfo.new(v4.TimeLength * 0.66), {
				Position = v3.Position
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(v4, TweenInfo.new(v4.TimeLength * 0.1), {
				Volume = 1.45
			}):Play()
		end

		Util.HighlightGroup.new(clone2.Highlight, workspace._WorldOrigin, "GravityDistortionBubble"):Insert(
			clone2,
			nil,
			folder
		)
		local tween = TweenService:Create(clone2, TweenInfo.new(0.13, Enum.EasingStyle.Sine), {
			Transparency = 1,
			Size = Vector3.new(v * 1.1, player.Length * 2.5, v * 1.1),
			CFrame = part.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		})
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()

		if player.TimeForWall and not player.Neutral and powerLevel >= 2 then
			local v3 = powerLevel == 3 and 2 or powerLevel == 2 and 1.4 or 1
			task.spawn(function()
				local v4 = player.MidCFrame * CFrame.new(0, 0, -player.Length / 2)
				local ray, v5, v6 = Util.Ray(
					v4.Position,
					createVector(0, 1, 0) * -v,
					{ workspace.Characters, workspace.Enemies }
				)
				local ray2 = Util.Ray(
					player.MidCFrame * Vector3.new(0, 0, player.Length / 2),
					player.MidCFrame.LookVector * (player.Length + 5),
					{ workspace.Characters, workspace.Enemies }
				)

				if ray and not ray2 then
					local v7 = Util.Misc.AlignCFrame(
						CFrame.lookAt(createVector(0, 0, 0), player.MidCFrame.LookVector) + v5,
						v6
					) + v6 * 0.01
					local clone3 = M1.CrackedWall:Clone()
					clone3:ScaleTo(v3)
					local v8 = v7 * CFrame.new(0, -clone3:GetModelSize().Y / 2, -clone3:GetModelSize().Y) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					) * CFrame.Angles(0, 3.141592653589793, 0)
					local v9 = v7 * CFrame.new(0, clone3:GetModelSize().Y / 2, 0) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					)

					for i, child in pairs(clone3:GetChildren()) do
						if child.Name ~= "Front" then
							continue
						end

						child.Material = ray.Material
						child.Color = ray.Color
					end

					clone3:PivotTo(v8)
					clone3.Parent = workspace._WorldOrigin
					local clone4 = M1.WallSpawn:Clone()
					clone4.Transparency = 1
					clone4.CFrame = v9 * CFrame.Angles(-1.0471975511965976, 3.141592653589793, 0) * CFrame.new(
						0,
						0,
						v3 * 5
					)
					Util.SetParentOverrideWithColor(clone4, folder, player2, "GravityFruitVFXColor")
					clone4.Impact.Smoke.Color = ColorSequence.new(ray.Color)
					clone4.Impact.Smoke2.Color = ColorSequence.new(ray.Color)
					Util.Debris:AddItem(clone4, 3.5)
					emitAll(clone4)
					Util.Sound:Play("GravFruit_M1_GroundSwipe_ImpactWall_03", clone4.Position)
					local lastTime = tick()
					local v10 = math.min(player.TimeForWall, 0.15)

					while tick() - lastTime < v10 do
						clone3:PivotTo(v8:Lerp(v9, ((tick() - lastTime) / v10) ^ 0.2))
						RunService.RenderStepped:Wait()
					end

					clone3:PivotTo(v9)
					local lastTime2 = tick()
					local flag = false

					while tick() - lastTime2 < 0.3 do
						local v11 = (tick() - lastTime2) / 0.3

						for k, v13 in pairs(player.CaughtForWall) do
							if not isUserBehind(v9 * CFrame.new(0, 0, -30), v13.Position) then
								continue
							end

							flag = true
							break
						end

						if flag then
							break
						else
							RunService.RenderStepped:Wait()
						end
					end

					local clone5 = M1.Wall:Clone()
					clone5.Transparency = 1

					if powerLevel == 3 then
						Util.ResizeModel(clone5, v3)
					end

					clone5.CFrame = v9 * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, v3 * 5)
					Util.SetParentOverrideWithColor(clone5, folder, player2, "GravityFruitVFXColor")
					clone5.Impact.Smoke.Color = ColorSequence.new(ray.Color)
					clone5.Impact.Smoke2.Color = ColorSequence.new(ray.Color)
					Util.Debris:AddItem(clone5, 3.5)
					emitAll(clone5.Impact)

					for i, child in pairs(clone3:GetChildren()) do
						child.Anchored = false
						child.CanCollide = true
						rocks:ApplyCollision(child, nil, true)

						if child.Name ~= "Back" then
							continue
						end

						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(100000000, 100000000, 100000000)
						bodyVelocity.Velocity = -player.MidCFrame.LookVector * (1 + math.random() * 0.5) * 150 + (child.Position - clone3:GetPivot().Position).Unit * 100 + createVector(
							0,
							30,
							0
						)
						bodyVelocity.Parent = child
						local v12 = child
						task.delay(0.05, function()
							bodyVelocity:Destroy()
							v12.RotVelocity += v12.Velocity * 0.01
						end)
					end

					task.wait(2)

					for i, child in pairs(clone3:GetChildren()) do
						child.CanCollide = false
					end

					task.delay(1, function()
						clone3:Destroy()
					end)
				end
			end)
		end

		local ray, v3, v4 = Util.Ray(
			player.MidCFrame.Position,
			createVector(0, 1, 0) * -v,
			{ workspace.Characters, workspace.Enemies }
		)

		if ray then
			local v5 = Util.Misc.AlignCFrame(CFrame.lookAt(createVector(0, 0, 0), player.MidCFrame.LookVector) + v3, v4) + v4 * 0.01
			local vector2 = Vector3.new(v * 1.3, 1, player.Length * 1.4)
			local cFrame = v5 * CFrame.Angles(0.001, 0, 0)
			local clone3 = M1.Scar:Clone()
			clone3.Size = vector2 * createVector(1, 1, 0)
			clone3.CanCollide = false
			clone3.Anchored = true
			clone3.Transparency = 1
			clone3.CFrame = cFrame * CFrame.new(0, 0, player.Length / 2)
			Util.SetParentOverrideWithColor(clone3, folder, player2, "GravityFruitVFXColor")
			TweenService:Create(clone3, TweenInfo.new(0.11, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = vector2
			}):Play()
			TweenService:Create(clone3.Purple, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3.Black, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3.Black2, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			local clone4 = M1.Stage1Swipe:Clone()
			clone4.CanCollide = false
			clone4.Anchored = true
			clone4.Transparency = 1
			clone4.CFrame = player.MidCFrame * CFrame.new(0, 0, player.Length / 2)
			Util.SetParentOverrideWithColor(clone4, folder, player2, "GravityFruitVFXColor")
			emitAll(clone4)
			clone4.SmokeStart.Smoke.Color = ColorSequence.new(ray.Color)
			clone4.SmokeStart.Smoke2.Color = ColorSequence.new(ray.Color)

			if not player.Neutral then
				lateralRocks(clone4.CFrame, part.Size.X * 1.25, part.Size.Z, 4 * (1 + 0.5 * (powerLevel - 1)))
			end
		end

		task.wait(0.016666666666666666)

		if player.EndPosition.Y < -4 then
			Effect.new("Water.Splash"):play({
				CFrame = CFrame.new(player.EndPosition.X, -4, player.EndPosition.Z),
				Scale = 10 + powerLevel * 4,
				Duration = 1 + powerLevel * 0.33
			})
		end

		CFrame.lookAt(player.StartPosition, player.EndPosition)
		local crater = player.Crater

		if crater then
			local clone3 = M1["StageFloor" .. powerLevel]:Clone()
			clone3.Transparency = 1
			clone3.CFrame = CFrame.new(crater.Position, crater.Position + crater.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0.001,
				0.001
			)
			Util.SetParentOverrideWithColor(clone3, folder, player2, "GravityFruitVFXColor")
			Util.Debris:AddItem(clone3, 3.5)
			clone3.vfx.Smoke.Color = ColorSequence.new(crater.Instance.Color)
			clone3.vfx.Smoke2.Color = ColorSequence.new(crater.Instance.Color)
			emitAll(clone3)
			local play = Util.Sound:Play("GravFruit_GenericDebrisLayer_Large_02", clone3.Position)
			play.RollOffMinDistance = powerLevel == 3 and 35 or powerLevel == 2 and 25 or 18
			task.spawn(function()
				for i = 1, 3 do
					task.spawn(function()
						local clone4 = M1.SPINWIND:Clone()
						clone4.Transparency = 1
						clone4.CFrame = clone3.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
						Util.SetParentOverrideWithColor(clone4, folder, player2, "GravityFruitVFXColor")
						Util.Debris:AddItem(clone4, 0.5)
						TweenService:Create(
							clone4,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CFrame = clone4.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
							}
						):Play()
						TweenService:Create(
							clone4.Mesh,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Scale = createVector(44.852, 34.222, 44.037)
							}
						):Play()
						TweenService:Create(
							clone4.Decal,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end)
					task.wait(0.015)
				end
			end)
			task.spawn(function()
				local v5 = 28 * (1 + 0.5 * (powerLevel - 1))
				local v6 = 18 * (1 + 0.25 * (powerLevel - 1))
				local v7 = crater.Position + createVector(0, 1, 0)

				for i = 1, v6 do
					local v8 = 360 / v6 * i
					local v9 = CFrame.new(v7, v7 + crater.Normal * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						math.rad(v8),
						0
					) * CFrame.new(0, 0, -v5)
					local ray2, v10, v11 = Util.Ray(
						v9.Position,
						v9.upVector.Unit * -30,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if not ray2 then
						continue
					end

					local v12 = Rock2.new({
						FadeIn = { 0.1, 0.3 },
						Lifetime = math.random(25, 30) / 10,
						FadeOut = { 0.4, 0.5 },
						Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)) * (1 + 0.1 * (powerLevel - 1)),
						Scale = { 1.2, 3 }
					})
					v12:Spawn(CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						0,
						0
					))

					if not (math.random(1, 100) <= 25) then
						continue
					end

					v12.Type = "Flying"
					v12:Eject({
						Velocity = (v9.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v12.Part.CFrame.lookVector * math.random(
							10,
							20
						)) * (1 + 0.5 * (powerLevel - 1)),
						RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
					})
				end
			end)
		end
	elseif stage == 4 then
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, player.Lifetime + 5)
		local cframe = CFrame.lookAt(player.StartPosition, player.EndPosition)
		local clone = M1.METEORBAMP:Clone()
		clone.Size = createVector(25, 25, 25) * (player.Raw and 1 or 0.45)
		clone.Transparency = 1
		clone.Shape = Enum.PartType.Ball
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = cframe

		if not player.Raw then
			Util.ResizeModel(clone, 0.45, clone.Position)
		end

		Util.SetParentOverrideWithColor(clone, folder, player2, "GravityFruitVFXColor")
		Util.Sound:Play("GravFruit_M1_SkyMeteor_Release_0" .. tostring(math.random(1, 4)) .. "_V2", clone.Position)
		Util.Sound:Play("GravFruit_SmallMeteorLoop", clone)
		emitAll(clone.BAMPLASH)
		local lastTime = os.clock()
		local v = false
		local endPosition = player.EndPosition
		local ray, v2, v3 = Util.Ray(
			endPosition - cframe.LookVector * 0.1,
			cframe.LookVector * 10,
			{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		)

		if ray then
			local clone2 = M1.MeteorIndicator:Clone()
			clone2.CFrame = CFrame.new(v2, v2 + v3) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
			Util.SetParentOverrideWithColor(clone2, folder, player2, "GravityFruitVFXColor")
			emitAll(clone2)
			task.delay(1.5, function()
				clone2:Destroy()
			end)
		end

		local heartbeatConnection = nil
		local RunService2 = game:GetService("RunService")
		heartbeatConnection = RunService2.Heartbeat:Connect(function(dt)
			if os.clock() - lastTime >= player.Lifetime or player.Proxy:GetAttribute("Exploding") then
				heartbeatConnection:Disconnect()

				if player.Proxy:GetAttribute("Exploding") then
					endPosition = player.Proxy:GetAttribute("Exploding")
				end

				if ray == nil or player.Proxy:GetAttribute("Exploding") then
					local position = endPosition
					local clone2 = M1.MeteorExplodeAir:Clone()

					if player.Raw then
						Util.ResizeModel(clone2, 1.3)
					end

					clone2.Position = position
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "GravityFruitVFXColor")
					Util.Debris:AddItem(clone2, 5)
					emitAll(clone2)
					Util.Sound:Play("GravFruit_M1_MeteorFall_Explode_0" .. tostring(math.random(1, 3)), clone2.Position)
					clone.Meteor:Destroy()

					for i, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Beam") then
							effect.Enabled = false
						end
					end

					task.delay(1, function()
						clone:Destroy()
					end)
				else
					local cFrame = CFrame.new(v2, v2 + v3) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
					local clone2 = M1.MeteorExplodeFloor:Clone()

					if player.Raw then
						Util.ResizeModel(clone2, 1.3)
					end

					clone2.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone2, folder, player2, "GravityFruitVFXColor")
					Util.Debris:AddItem(clone2, 5)
					emitAll(clone2)
					Util.Sound:Play("GravFruit_M1_MeteorFall_Explode_0" .. tostring(math.random(1, 3)), clone2.Position)
					Util.Sound:Play("GravFruit_GenericDebrisLayer_Medium_05", clone2.Position)
					clone.Meteor:Destroy()

					for i, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Beam") then
							effect.Enabled = false
						end
					end

					task.delay(1, function()
						clone:Destroy()
					end)
					task.spawn(function()
						local v5 = 28 * (player.Raw and 1.75 or 1)
						local v6 = 18 + (player.Raw and 4 or 0)
						local v7 = clone2.Position + createVector(0, 2, 0)

						for i = 1, v6 do
							local v8 = 360 / v6 * i
							local v9 = CFrame.new(v7, v7 + v3 * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
								0,
								math.rad(v8),
								0
							) * CFrame.new(0, 0, -v5)
							local ray2, v10, v11 = Util.Ray(
								v9.Position,
								v9.upVector.Unit * -30,
								{ workspace.Characters, workspace.Enemies },
								false
							)

							if not ray2 then
								continue
							end

							local v12 = Rock2.new({
								FadeIn = { 0.1, 0.3 },
								Lifetime = math.random(25, 30) / 10,
								FadeOut = { 0.4, 0.5 },
								Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)) * (player.Raw and 1.33 or 1),
								Scale = { 1.2, 3 }
							})
							v12:Spawn(CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
								0,
								0,
								0
							))

							if not (math.random(1, 100) <= 25) then
								continue
							end

							v12.Type = "Flying"
							v12:Eject({
								Velocity = v9.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v12.Part.CFrame.lookVector * math.random(
									10,
									20
								),
								RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
							})
						end
					end)
				end
			else
				clone.CFrame *= CFrame.new(0, 0, -player.Speed * dt)

				if v == false and clone.Position.Y < -4 then
					v = true
					Effect.new("Water.Splash"):play({
						CFrame = CFrame.new(clone.Position.X, -4, clone.Position.Z),
						Scale = clone.Size.Y * 1.5,
						Duration = 1.5 * clone.Size.Y / 20
					})
					Util.Sound:Play(
						"GravFruit_M1_Meteor_Splashdown_0" .. tostring(math.random(1, 3)),
						(Vector3.new(clone.Position.X, -4, clone.Position.Z))
					)
				end
			end
		end)
	end
end