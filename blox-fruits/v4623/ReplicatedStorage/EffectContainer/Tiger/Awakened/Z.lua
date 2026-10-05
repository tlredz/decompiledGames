local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tigerEffects = FX:WaitForChild("TigerEffects")
local Beziers = require(script.Parent.Parent.Modules.Beziers)
local TweenService = game:GetService("TweenService")

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
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

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function lateralRocks(startCFrame, p, magnitude, p2, p3)
	local v = {
		workspace._WorldOrigin,
		workspace.Characters,
		workspace.Enemies,
		workspace.Boats
	}
	task.spawn(function()
		local v2 = math.floor(magnitude / p2)

		for i = 1, v2 do
			local v3 = (1 - math.pow(1 - (i - 1) / v2, 2)) * magnitude
			local v4 = p2 * (1 + 0.4 * math.random())

			for i2 = -1, 1, 2 do
				if ((v3 <= p2 * 4 or magnitude - p2 * 4 <= v3) and 0.6 or 0.75) < math.random() then
					continue
				end

				local v5

				if math.random(1, 5) == 1 then
					v5 = 0.5 + math.random() * 0.25
				else
					v5 = false
				end

				if v5 then
					v4 *= v5
				end

				local v6 = p / 2 * i2 * (1 + math.random() * 0.2) * (v5 or 1)
				local v7 = startCFrame.Position + startCFrame.RightVector * v6 + startCFrame.LookVector * v3 + createVector(
					0,
					1,
					0
				)
				local vector2 = Vector3.new(0, -p, 0)
				local ray, v8, v9 = Util.Ray(v7, vector2, v)

				if not (ray and ray.Anchored and ray.Transparency <= 0) then
					continue
				end

				local alignCFrame = Util.Misc.AlignCFrame(
					CFrame.lookAt(createVector(0, 0, 0), startCFrame.LookVector) + v8,
					v9
				)
				local cFrame = alignCFrame * CFrame.new(0, -v4 * 0.5, 0)
				local cFrame2 = alignCFrame * CFrame.new(0, -v4 * 0.25, 0) * CFrame.Angles(
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
				part.Size = Vector3.new(1 + math.random(), 1, 1 + math.random() * 1.5) * v4
				part.CFrame = cFrame
				part.Parent = _WorldOrigin
				local tween = TweenService:Create(
					part,
					TweenInfo.new(0.1 + math.random() * 0.2, Enum.EasingStyle.Back),
					{
						CFrame = cFrame2
					}
				)
				tween.Completed:Connect(function()
					task.wait(1.8 + 0.2 * math.random())
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							CFrame = cFrame * CFrame.new(0, -v4 * 0.1, 0)
						}
					)
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end

			task.wait(p3 / v2)
		end
	end)
end

local function rockspawn(clone, p, duration, vector2, p2, p3)
	local part = Instance.new("Part")
	local ray = Util.Ray
	local v = clone.Position + createVector(0, 2, 0)
	local v2 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
	local v3, v4, _ = ray(v, createVector(-0, -20, -0), v2, false)

	if v3 ~= nil then
		task.spawn(function()
			local v5 = CFrame.new(v4) * clone.CFrame.Rotation
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Material = v3.Material
			part.Color = v3.Color
			part.CFrame = v5 * CFrame.new(0, -p, 0) * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-25, 25))),
				(math.rad((math.random(p2, p3))))
			)
			part.Parent = _WorldOrigin
			Util.Debris:AddItem(part, duration + 1)
			TweenService:Create(part, TweenInfo.new(0.1), {
				CFrame = part.CFrame * CFrame.new(0, p, 0),
				Size = vector2
			}):Play()
			task.wait(duration)
			TweenService:Create(part, TweenInfo.new(0.3), {
				CFrame = part.CFrame * CFrame.new(0, -p, 0),
				Size = createVector(0, 0, 0)
			}):Play()
		end)
	end
end

return function(data)
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage
	local _ = data.RigModel
	local root = data.Root
	local rig = data.Rig or root.Parent.TigerRig:FindFirstChild("TigerRig")

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder", _WorldOrigin)
		local clone = tigerEffects.PART_TEMPLATE:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")

		repeat
			task.wait()
			clone.CFrame = root.CFrame
		until not (holding.Value and holding)

		task.delay(1, function()
			folder:Destroy()
		end)
	elseif stage == 2 then
		if root.Parent == game.Players.LocalPlayer.Character then
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(6, 9, 0.05, 1, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					Util.SetParentOverrideWithColor(
						colorCorrectionEffect,
						game.Lighting,
						player,
						"LeopardFruitVFXColor"
					)
					Util.Debris:AddItem(colorCorrectionEffect, 0.3)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(197, 65, 255),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = -1,
							Saturation = -1,
							Contrast = 8
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 166, 93),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0.4,
							Saturation = 0,
							Contrast = 1
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0,
							Saturation = 0,
							Contrast = 0
						}
					):Play()
				end
			end)
			task.spawn(function()
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()

				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(
						7,
						7,
						0.05,
						0.6,
						createVector(1.4, 1.6, 1.6),
						createVector(0.9, 0.9, 0.9)
					)
				end

				task.wait(0.15)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		local clone = tigerEffects.Z_Awak.DashStart:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 2.5)
		emitAll(clone)
		local _ = data.timeUntilReachedEndPoint
		local _ = data.endPoint
		local startCFrame = data.StartCFrame
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 20)
		local clone2 = tigerEffects.PART_TEMPLATE:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
		task.spawn(function()
			for _ = 1, 12 do
				local clone3 = tigerEffects.Z_Awak.Floor:Clone()
				local ray = Util.Ray
				local v = root.Position + createVector(0, 2, 0)
				local v2 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
				local v3, v4, _ = ray(v, createVector(-0, -25, -0), v2, false)

				if v3 ~= nil then
					local v5 = v4
					local v6 = clone3
					task.spawn(function()
						v6.CFrame = CFrame.new(v5)
						Util.SetParentOverrideWithColor(v6, _WorldOrigin, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(v6, 2.8)
						emitAll(v6)
					end)
				end

				task.wait(0.015)
			end
		end)
		local clone3 = tigerEffects.Z_Awak.DashLoop:Clone()
		clone3.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
		task.spawn(function()
			for _ = 1, 9 do
				task.spawn(function()
					for _ = 1, 2 do
						local clone4 = tigerEffects.Z_Awak.partfly:Clone()
						clone4.CFrame = root.CFrame * CFrame.new(
							math.random(-15, 15),
							math.random(-1.5, 15),
							math.random(-15, 15)
						)
						Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(clone4, 2)
						local v = math.random(11, 16) / 100
						Beziers.Interpolate(
							"Cubic",
							v,
							100,
							v,
							nil,
							clone4.CFrame,
							clone4.CFrame * CFrame.new(math.random(-45, 45), math.random(-1, 15), math.random(-45, 45)),
							clone4.CFrame * CFrame.new(math.random(-45, 45), math.random(-1, 15), math.random(-45, 45)),
							root.CFrame,
							clone4,
							"CFrame"
						)
					end
				end)
				task.wait(0.0075)
			end
		end)
		task.spawn(function()
			clone3.AttachmentX.WindBack.Enabled = true
			clone3.strike.Enabled = true
			clone3.strike2.Enabled = true
			clone3.strike3.Enabled = true
			task.wait(0.2)
			clone3.AttachmentX.WindBack.Enabled = false
			clone3.strike.Enabled = false
			clone3.strike2.Enabled = false
			clone3.strike3.Enabled = false
		end)
		task.spawn(function()
			for _ = 1, 5 do
				emitAll(clone3.dashloop)
				task.wait(0.0125)
			end
		end)
		local endPoint = data.endPoint
		local timeUntilReachedEndPoint = data.timeUntilReachedEndPoint or 0.2
		local magnitude = (startCFrame.Position - endPoint).Magnitude
		lateralRocks(startCFrame, 12, magnitude, 4, timeUntilReachedEndPoint / 4)
		task.spawn(function()
			root.Anchored = true
			local cFrame = CFrame.new(data.endPoint, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local lastTime = os.clock()

			while os.clock() - lastTime < timeUntilReachedEndPoint do
				local v2 = (os.clock() - lastTime) / timeUntilReachedEndPoint
				root.CFrame = cFrame * CFrame.new(0, 0, magnitude * (1 - v2 ^ 0.5))
				clone3.CFrame = root.CFrame
				RunService.PreSimulation:Wait()
			end

			root.CFrame = cFrame
			root.Anchored = false
		end)

		if data.Player then
			local player2 = data.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				return
			end
		end
	elseif stage == 3 then
		local startCFrame = data.StartCFrame
		local _ = data.GrabDur
		local _ = data.WindUp
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 10)
		local clone = tigerEffects.PART_TEMPLATE:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		local clone2 = tigerEffects.Z_Awak.WeldRoot:Clone()
		clone2.CFrame = root.CFrame * CFrame.new(0, 4, 0)
		Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
		local weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = clone2
		weld.C0 = weld.Part1.CFrame:inverse()
		weld.C1 = weld.Part1.CFrame:inverse()
		Util.SetParentOverrideWithColor(weld, clone2, player, "LeopardFruitVFXColor")
		task.spawn(function()
			task.wait(1)
			enableAll(clone2, false)
		end)

		for i = 1, 20 do
			if root.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(1.8, 3, 0.05, 0.7, createVector(0.6, 0.6, 0.6), createVector(1, 1, 1))
			end

			local clone3 = tigerEffects.Z_Awak.Punch:Clone()
			local v = i % 2 == 0 and 3 or -3
			clone3.CFrame = root.CFrame * CFrame.new(v, 0, -3.5)
			Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
			emitAll(clone3)
			task.wait(0.05)
		end

		local clone3 = tigerEffects.Z_Awak.ChargeHandL:Clone()
		Util.SetParentOverrideWithColor(clone3, rig.VFX.XGround, player, "LeopardFruitVFXColor")
		clone3.RigidConstraint.Attachment0 = clone3.Attachment
		clone3.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.L"]["HandIK.L"]["Hand.L"]["Middle.L"]
		local clone4 = tigerEffects.Z_Awak.ChargeHandR:Clone()
		Util.SetParentOverrideWithColor(clone4, rig.VFX.XGround, player, "LeopardFruitVFXColor")
		clone4.RigidConstraint.Attachment0 = clone4.Attachment
		clone4.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]["Middle.R"]
		emitAll(clone4.Charge)
		emitAll(clone3.Charge)

		if root.Parent == game.Players.LocalPlayer.Character then
			TweenService:Create(workspace.Camera, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				FieldOfView = 40
			}):Play()
		end

		task.wait(0.1)
		local clone5 = tigerEffects.Z_Awak.PunchImpact:Clone()
		clone5.CFrame = root.CFrame * CFrame.new(0, 0, -6)
		Util.SetParentOverrideWithColor(clone5, folder, player, "LeopardFruitVFXColor")
		emitAll(clone5)
		Util.Debris:AddItem(clone5, 3)
		task.spawn(function()
			local function lerp(p, p2, p3)
				return p + (p2 - p) * p3
			end

			local lookVector = root.CFrame.LookVector
			local position = root.Position
			local magnitude = (position - (position + lookVector * 40)).Magnitude
			local ray, _, _ = Util.Ray(
				position,
				lookVector * (magnitude + 8),
				{ workspace.Characters, workspace.Enemies }
			)
			local back = Util.Tween.ease.inout.back

			for i = 1, 7 do
				local v = i
				task.spawn(function()
					local v3 = v % 2 == 0
					local clone6

					if v3 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone6 = FX2:WaitForChild("TigerEffects").X_Awak.SwirlCrescent:Clone()
					elseif v % 3 == 0 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone6 = FX2:WaitForChild("TigerEffects").X_Awak.WindV2:Clone()
					else
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone6 = FX2:WaitForChild("TigerEffects").X_Awak.WindFragments:Clone()
					end

					Util.Debris:AddItem(clone6, 2)
					local part = clone6.Part
					part.Transparency = 1
					local v4 = false
					local v5 = v / 7
					local v6

					if v5 < 0.75 then
						v6 = math.min(1, (v5 / 0.75) ^ 0.8 + 0.2)
					else
						v6 = 1 - (v5 - 0.75) / 0.25
						v4 = true
					end

					local v7 = back(v6, 0.01, 0.79, 1, 11)
					clone6:ScaleTo((math.max(v7, v4 and 2.5 or 0.1)))
					task.spawn(function()
						local v9 = {
							"beam1",
							"beam2",
							"beam3",
							"beam4",
							"beam5",
							"beam6"
						}

						for k, v10 in pairs(v9) do
							TweenService:Create(
								part[v10].Beam,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = (v10 == "beam3" or v10 == "beam6") and math.random(20, 30) * v7 or 17.6 * v7,
									Width1 = v10 ~= "beam3" and v10 ~= "beam6" and 0 or 6 * v7 or 0
								}
							):Play()
						end

						task.wait(0.05)

						for k, v10 in pairs(v9) do
							TweenService:Create(
								part[v10].Beam,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
						end
					end)
					task.spawn(function()
						emitAll(clone6)
						task.wait(0.2)

						for i2, emitter in pairs(clone6:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = false
							end
						end
					end)
					local v9 = CFrame.new(position) * CFrame.lookAt(position, position + lookVector)
					local v10 = lookVector * (v * 3)
					part.CFrame = v9 * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
					part.Position = position + v10
					local v11 = ({ -1, 1 })[math.random(1, 2)] * 179
					local tween = TweenService:Create(
						part,
						TweenInfo.new(v3 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(5, v3 and 1 or 3, 5),
							Position = part.Position + lookVector * 4,
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(v3 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1),
						{
							Orientation = part.Orientation + Vector3.new(0, v11, 0)
						}
					)
					tween2.Completed:Connect(function()
						if part then
							tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Orientation = part.Orientation + Vector3.new(0, v11, 0)
								}
							)
							tween2:Play()
						end
					end)
					tween.Completed:Connect(function()
						if not ray then
							task.spawn(function()
								for i2, beam in pairs(clone6:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone6:Destroy()
							end)
							return
						end

						local tween3 = TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								CFrame = part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
									math.rad((math.random(-5, 5))),
									v11,
									(math.rad((math.random(-5, 5))))
								)
							}
						)
						tween3.Completed:Connect(function()
							task.spawn(function()
								for i2, beam in pairs(clone6:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone6:Destroy()
							end)
						end)
						tween3:Play()
					end)
					Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "LeopardFruitVFXColor")
					tween:Play()
					tween2:Play()
				end)
				wait(0.025)
			end
		end)
	elseif stage == 4 then
		if not rig then
			return
		end

		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 10)
		Util.Sound:Play("BF_TigerFt_AWK_Z_ClapOfFire_0" .. tostring(math.random(1, 2)), root)
		local tigerAwakenedZLaunch = Util.Anims:Get(rig, "TigerAwakened_ZLaunch")
		tigerAwakenedZLaunch.Priority = Enum.AnimationPriority.Action2
		tigerAwakenedZLaunch.Looped = false
		tigerAwakenedZLaunch:Play()
		local clone = tigerEffects.Z_Awak.ChargeHandL:Clone()
		Util.SetParentOverrideWithColor(clone, rig.VFX.XGround, player, "LeopardFruitVFXColor")
		clone.RigidConstraint.Attachment0 = clone.Attachment
		clone.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.L"]["HandIK.L"]["Hand.L"]["Middle.L"]
		local clone2 = tigerEffects.Z_Awak.ChargeHandR:Clone()
		Util.SetParentOverrideWithColor(clone2, rig.VFX.XGround, player, "LeopardFruitVFXColor")
		clone2.RigidConstraint.Attachment0 = clone2.Attachment
		clone2.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]["Middle.R"]
		emitAll(clone2.Charge)
		emitAll(clone.Charge)
		task.wait(0.15)
		local clone3 = tigerEffects.Z_Awak.PunchImpact:Clone()
		clone3.CFrame = root.CFrame * CFrame.new(0, 0, -6)
		Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
		emitAll(clone3)
		Util.Debris:AddItem(clone3, 3)
		local ray, v, v2 = Util.Ray(
			root.Position,
			createVector(-0, -1, -0) * (root.Size.Y * 0.5 + root.Parent.Humanoid.HipHeight + 3),
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			local random = Random.new()
			local clone4 = tigerEffects.Z_Awak.RockMover:Clone()
			clone4.CFrame = root.CFrame * CFrame.new(-13, -2, -8)
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone4, 1.5)
			local clone5 = tigerEffects.Z_Awak.RockMover:Clone()
			clone5.CFrame = root.CFrame * CFrame.new(13, -2, -7)
			Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone4, 1.5)
			TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				CFrame = root.CFrame * CFrame.new(-34, 0, -79)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				CFrame = root.CFrame * CFrame.new(34, 0, -79)
			}):Play()
			task.spawn(function()
				for _ = 1, 12 do
					rockspawn(
						clone4,
						2,
						1.3,
						Vector3.new(random:NextNumber(7, 9.75), random:NextNumber(4.8, 5.6), random:NextNumber(7, 9)),
						22,
						28
					)
					rockspawn(
						clone5,
						2,
						1.3,
						Vector3.new(random:NextNumber(7, 9.75), random:NextNumber(4.8, 5.6), random:NextNumber(7, 9)),
						22,
						28
					)
					task.wait(0.0125)
				end
			end)

			for i = 1, 12 do
				local cFrame = clone3.CFrame
				local rock = Util.Rock2.new({
					FadeIn = { 0, 0.1 },
					Lifetime = math.random(10, 15) / 10,
					FadeOut = { 0.4, 0.5 },
					Size = Vector3.new(math.random(3, 6) * 0.7, 1.4, math.random(3, 6) * 0.7),
					Scale = { 1, 2 }
				})
				rock:Spawn(CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(i * 30),
					0
				))
				rock.Type = "Flying"
				rock:Eject({
					Velocity = (cFrame.LookVector * (workspace.Gravity / 2 + math.random(-20, 40)) + rock.Part.CFrame.lookVector * math.random(
						30,
						50
					)) * 0.7 * 1.5 + createVector(0, 90, 0),
					RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
				})
				local _ = rock.Part
			end
		end

		task.spawn(function()
			if root.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(12, 13, 0.05, 0.9, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
				task.spawn(function()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							FieldOfView = 86
						}
					):Play()
					task.wait(0.1)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
				end)
				task.spawn(function()
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					Util.SetParentOverrideWithColor(
						colorCorrectionEffect,
						game.Lighting,
						player,
						"LeopardFruitVFXColor"
					)
					Util.Debris:AddItem(colorCorrectionEffect, 1.4)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(169, 70, 202),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = -1,
							Saturation = -0.5,
							Contrast = 3
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 182, 123),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0.4,
							Saturation = 0.3,
							Contrast = 1
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0,
							Saturation = 0,
							Contrast = 0
						}
					):Play()
				end)
			end
		end)
		task.spawn(function()
			local function lerp(p, p2, p3)
				return p + (p2 - p) * p3
			end

			local lookVector = root.CFrame.LookVector
			local position = root.Position
			local magnitude = (position - (position + lookVector * 40 * 1.4)).Magnitude
			local ray2, _, _ = Util.Ray(
				position,
				lookVector * (magnitude + 8),
				{ workspace.Characters, workspace.Enemies }
			)
			local back = Util.Tween.ease.inout.back

			for i = 1, 7 do
				local v3 = i
				task.spawn(function()
					local v5 = v3 % 2 == 0
					local clone4

					if v5 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX2:WaitForChild("TigerEffects").X_Awak.SwirlCrescent:Clone()
					elseif v3 % 3 == 0 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX2:WaitForChild("TigerEffects").X_Awak.WindV2:Clone()
					else
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX2:WaitForChild("TigerEffects").X_Awak.WindFragments:Clone()
					end

					Util.Debris:AddItem(clone4, 2)
					local part = clone4.Part
					part.Transparency = 1
					local v6 = false
					local v7 = v3 / 7
					local v8

					if v7 < 0.75 then
						v8 = math.min(1, (v7 / 0.75) ^ 0.8 + 0.2)
					else
						v8 = 1 - (v7 - 0.75) / 0.25
						v6 = true
					end

					local v9 = back(v8, 0.01, 0.79, 1, 11)
					clone4:ScaleTo((math.max(v9, v6 and 2.5 or 0.1)))
					task.spawn(function()
						local v11 = {
							"beam1",
							"beam2",
							"beam3",
							"beam4",
							"beam5",
							"beam6"
						}

						for k, v12 in pairs(v11) do
							TweenService:Create(
								part[v12].Beam,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = (v12 == "beam3" or v12 == "beam6") and math.random(20, 30) * v9 or 17.6 * v9,
									Width1 = v12 ~= "beam3" and v12 ~= "beam6" and 0 or 6 * v9 or 0
								}
							):Play()
						end

						task.wait(0.05)

						for k, v12 in pairs(v11) do
							TweenService:Create(
								part[v12].Beam,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
						end
					end)
					task.spawn(function()
						emitAll(clone4)
						task.wait(0.2)

						for i2, emitter in pairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = false
							end
						end
					end)
					local v11 = CFrame.new(position) * CFrame.lookAt(position, position + lookVector)
					local v12 = lookVector * (v3 * 3)
					part.CFrame = v11 * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
					part.Position = position + v12
					local v13 = ({ -1, 1 })[math.random(1, 2)] * 179
					local tween = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(5, v5 and 1 or 3, 5),
							Position = part.Position + lookVector * 4,
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1),
						{
							Orientation = part.Orientation + Vector3.new(0, v13, 0)
						}
					)
					tween2.Completed:Connect(function()
						if part then
							tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Orientation = part.Orientation + Vector3.new(0, v13, 0)
								}
							)
							tween2:Play()
						end
					end)
					tween.Completed:Connect(function()
						if not ray2 then
							task.spawn(function()
								for i2, beam in pairs(clone4:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone4:Destroy()
							end)
							return
						end

						local tween3 = TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								CFrame = part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
									math.rad((math.random(-5, 5))),
									v13,
									(math.rad((math.random(-5, 5))))
								)
							}
						)
						tween3.Completed:Connect(function()
							task.spawn(function()
								for i2, beam in pairs(clone4:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone4:Destroy()
							end)
						end)
						tween3:Play()
					end)
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "LeopardFruitVFXColor")
					tween:Play()
					tween2:Play()
				end)
				wait(0.025)
			end
		end)
	end
end