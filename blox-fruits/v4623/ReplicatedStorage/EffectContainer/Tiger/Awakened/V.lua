local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tigerEffects = FX:WaitForChild("TigerEffects")
require(script.Parent.Parent.Modules.Beziers)
local RockRipple = require(script.Parent.Parent.Modules.RockRipple)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
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

function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local v2 = p or folder:GetPivot().Position
	local v3 = modelScale / v

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local v4 = part.CFrame - position
		local v5 = position - v2
		part.Size *= Vector3.new(v3, v3, v3)
		part.CFrame = v4 + v2 + v5 * v3
	end

	folder:SetAttribute("ModelScale", modelScale)
end

return function(data)
	if data.Preload then
		print("preload")
		return
	end

	local player = data.player
	local position = data.Root.Position

	if not data.Scene and (workspace.CurrentCamera.CFrame.p - position).Magnitude > 800 then
		return
	end

	local _ = data.Stage
	local root = data.Root
	local rig = data.Rig or root.Parent.TigerRig:WaitForChild("TigerRig")
	Util.Sound:Play("BF_TigerFt_AWK_V_Trnsfm_01", root)
	task.spawn(function()
		Util.Anims:Get(rig, data.wolf and "WerewolfAwakening" or "TigerAwakening"):Play()
		local awakenedEmit = rig.VFX.AwakenedEmit
		local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone = FX2:WaitForChild("TigerEffects").V_Awak.Emit.LHand:Clone()
		Util.SetParentOverrideWithColor(clone, awakenedEmit, player, "LeopardFruitVFXColor")
		clone.RigidConstraint.Attachment0 = clone.Attachment
		clone.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.L"]["HandIK.L"]["Hand.L"]
		local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone2 = FX3:WaitForChild("TigerEffects").V_Awak.Emit.RHand:Clone()
		Util.SetParentOverrideWithColor(clone2, awakenedEmit, player, "LeopardFruitVFXColor")
		clone2.RigidConstraint.Attachment0 = clone2.Attachment
		clone2.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]
		local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone3 = FX4:WaitForChild("TigerEffects").V_Awak.Emit.Mouth:Clone()
		Util.SetParentOverrideWithColor(clone3, awakenedEmit, player, "LeopardFruitVFXColor")
		clone3.RigidConstraint.Attachment0 = clone3.Attachment
		clone3.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head.Jaw
		task.spawn(function()
			task.wait(0.083)
			emitAll(clone3.Charge)
		end)
		task.spawn(function()
			task.wait(0.317)
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(
						12,
						13,
						0.05,
						1.3,
						createVector(1.4, 1.6, 1.6),
						createVector(0.9, 0.9, 0.9)
					)
					task.spawn(function()
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								FieldOfView = 107
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
								Brightness = -3,
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
							TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
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
			emitAll(clone3.BeamFire)
			local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone4 = FX5:WaitForChild("TigerEffects").V_Awak.Emit.spray:Clone()
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "LeopardFruitVFXColor")
			clone4.PrimaryPart.CFrame = root.CFrame
			emitAll(clone4)
			Util.Debris:AddItem(clone4, 3)
		end)
		task.spawn(function()
			task.wait(0.6)
			emitAll(clone2)
			emitAll(clone)
			task.wait(0.5)
			clone3:Destroy()
			clone:Destroy()
			clone2:Destroy()
		end)
		task.spawn(function()
			task.wait(1.2)
			local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone4 = FX5:WaitForChild("TigerEffects").V_Awak.Emit.Explode:Clone()
			clone4.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "LeopardFruitVFXColor")
			emitAll(clone4)
			Util.Debris:AddItem(clone4, 1.5)
			local FX6 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone5 = FX6:WaitForChild("TigerEffects").V_Awak.Emit.VExpand:Clone()
			clone5.PrimaryPart.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone5, 3)
			emitAll(clone5)
			local ray = Util.Ray
			local v = root.Position + createVector(0, 2, 0)
			local v2 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
			local v3, v4, v5 = ray(v, createVector(-0, -15, -0), v2, false)

			if v3 ~= nil then
				local cframe = CFrame.new(v4)
				local FX7 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone6 = FX7:WaitForChild("TigerEffects").V_Awak.Emit.VFloor:Clone()
				clone6.CFrame = cframe
				Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "LeopardFruitVFXColor")
				emitAll(clone6)
				Util.Debris:AddItem(clone6, 4.5)
				task.spawn(function()
					local part = Instance.new("Part")
					part.Name = "BAMPROCK"
					part.CanTouch = false
					part.CanQuery = false
					part.CanCollide = false
					part.Anchored = true
					RockRipple.createRippleEffect(part, v4, 12, 5, 4, 3)
				end)
				local v6 = CFrame.new(v4, v4 + v5) * CFrame.Angles(-1.5707963267948966, 0, 0)
				local random = Random.new()

				for i = 1, 45 do
					local v7 = 6.283185307179586 * (i / 45)
					local v8 = Rock2.new({
						Type = "Ground",
						FadeOut = { 0.25, 0.5 },
						FadeIn = { 0.25, 0.5 },
						Lifetime = { 1, 2.5 },
						Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
						Scale = { 3.75, 7.5 }
					})

					if random:NextInteger(1, 20) % 4 == 0 then
						local unit = Vector3.new(
							math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
							random:NextNumber(0, 1) * 1.25,
							math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
						).Unit
						v8.Type = "Flying"
						v8:Spawn(v6 * CFrame.Angles(0, v7, 0) * CFrame.new(0, 0, -34.199999999999996))
						v8:Eject({
							Velocity = Util.Misc.Physics.Velocity(
								Vector3.new(),
								unit * random:NextNumber(30, 120),
								Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
								0.25 + random:NextNumber(0, 2)
							),
							AngularVelocity = Vector3.new(
								random:NextNumber(-1, 1),
								random:NextNumber(-1, 1),
								random:NextNumber(-1, 1)
							) * 2 * 3.141592653589793 * (1 / v8.Scale)
						})
					else
						v8:Spawn(v6 * CFrame.Angles(0, v7, 0) * CFrame.new(0, 0, -34.199999999999996))
						v8:TweenShift((v6 * CFrame.Angles(0, v7, 0)).LookVector * 15 * random:NextNumber(1, 2), 0.25)
					end
				end

				local FX8 = require(ReplicatedStorage:WaitForChild("FX"))
				local groundSpike = FX8:WaitForChild("TigerEffects").C_Awak.GroundSpike

				for i = 0, 21 do
					local number = random:NextNumber(
						i * 2 * 3.141592653589793 / 22,
						(i + 1) * 2 * 3.141592653589793 / 22
					)
					local v7 = math.random()
					local v8 = 24 + 30 * v7
					local clone7 = groundSpike:Clone()
					local v9 = 1.6 + 1.6999999999999997 * v7
					ScaleModel(clone7, v9)
					local v10 = cframe * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v8) * CFrame.Angles(
						-math.rad(20 + 25 * v7),
						0,
						0
					) * CFrame.new(0, -27 * v9, 0)
					clone7:PivotTo(v10)
					Util.SetParentOverrideWithColor(clone7, _WorldOrigin, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone7, 5)
					task.spawn(function()
						TweenService:Create(
							clone7.lavaGradient.Spike,
							TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Color = Util.WrapColor3Constructor(
									Color3.fromRGB(202, 87, 42),
									player,
									"LeopardFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.5)
						TweenService:Create(
							clone7.lavaGradient.Spike,
							TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Color = Util.WrapColor3Constructor(
									Color3.fromRGB(35, 15, 7),
									player,
									"LeopardFruitVFXColor"
								)
							}
						):Play()
					end)
					local v12 = clone7
					task.delay(random:NextNumber(0, 0.03), function()
						heartbeatLoopFor2(0.2, function(p, p2, p3)
							v12:PivotTo(v10 * CFrame.new(0, 27 * v9 * p3, 0))
						end)
					end)
					local v15 = clone7
					task.spawn(function()
						task.wait(2.3)
						task.delay(random:NextNumber(0.4, 0.8), function()
							TweenService:Create(
								v15.PrimaryPart,
								TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
								{
									CFrame = v15.PrimaryPart.CFrame * CFrame.new(0, -42, 0)
								}
							):Play()
						end)
					end)
				end
			end

			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(
						12,
						13,
						0.05,
						1,
						createVector(1.4, 1.6, 1.6),
						createVector(0.9, 0.9, 0.9)
					)
					task.spawn(function()
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								FieldOfView = 107
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
								Brightness = -3,
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
		end)
		task.spawn(function()
			task.wait(0.32)

			local function lerp(p, p2, p3)
				return p + (p2 - p) * p3
			end

			local position2 = root.Position
			local v = root.Position + createVector(0, 40, 0)
			local magnitude = (position2 - v).magnitude
			local ray, v2, _ = Util.Ray(
				position2,
				CFrame.new(position2, v).LookVector.Unit * (magnitude + 8),
				{ workspace.Characters, workspace.Enemies }
			)
			local back = Util.Tween.ease.inout.back

			for i = 1, 24 do
				local v3 = i
				task.spawn(function()
					if 20 % v3 ~= 0 then
						local v4 = CFrame.new(position2, v2) * CFrame.new(
							0,
							0,
							-math.random(5, (math.max(14, magnitude)))
						) * CFrame.Angles(1.5707963267948966, 0, 0)
					end

					local v5 = v3 % 2 == 0
					local clone4

					if v5 then
						local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX5:WaitForChild("TigerEffects").V_Awak.Emit.SwirlCrescent:Clone()
					elseif v3 % 3 == 0 then
						local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX5:WaitForChild("TigerEffects").V_Awak.Emit.WindV2:Clone()
					else
						local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX5:WaitForChild("TigerEffects").V_Awak.Emit.WindFragments:Clone()
					end

					Util.Debris:AddItem(clone4, 2)
					local part = clone4.Part
					part.Transparency = 1
					local v6 = false
					local v7 = v3 / 24
					local v8

					if v7 < 0.75 then
						v8 = math.min(1, (v7 / 0.75) ^ 0.8 + 0.2)
					else
						v8 = 1 - (v7 - 0.75) / 0.25
						v6 = true
					end

					local v9 = back(v8, 0.01, 0.89, 1, 11)
					clone4:ScaleTo((math.max(v9, v6 and 2.5 or 0.1)))
					task.spawn(function()
						local beam = part.beam1.Beam
						local beam2 = part.beam2.Beam
						local beam3 = part.beam3.Beam
						local beam4 = part.beam4.Beam
						local beam5 = part.beam5.Beam
						local beam6 = part.beam6.Beam
						TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 17.6 * v9,
							Width1 = 0
						}):Play()
						TweenService:Create(
							beam2,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam3,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v9,
								Width1 = 6 * v9
							}
						):Play()
						TweenService:Create(
							beam4,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam5,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam6,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v9,
								Width1 = 6 * v9
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam4, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam6, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
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
					local cframe = CFrame.Angles(
						math.rad((math.random(-15, 15))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-15, 15))))
					)
					part.CFrame = CFrame.new(v) * cframe
					local v11 = ({ -1, 1 })[math.random(1, 2)] * 179
					local tween = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = Vector3.new(5, v5 and 1 or 3, 5),
							Position = position2 + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0),
						{
							Orientation = part.Orientation + Vector3.new(0, v11, 0)
						}
					)
					tween2.Completed:Connect(function()
						if part then
							tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
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
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
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
	end)
	local awakened = rig.VFX.Awakened
	local v = Util.Sound:Play("BF_TigerFt_AWK_PassiveFlame_Loop_01", root)
	task.spawn(function()
		repeat
			task.wait()
		until not (awakened and awakened:IsDescendantOf(workspace))

		Util.Sound:FadeOut(v, 0.2)
	end)
	local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone = FX2:WaitForChild("TigerEffects").V_Awak.eyeL:Clone()
	Util.SetParentOverrideWithColor(clone, awakened, player, "LeopardFruitVFXColor")
	clone.RigidConstraint.Attachment0 = clone.Attachment
	clone.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head["Eye.L"]
	local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone2 = FX3:WaitForChild("TigerEffects").V_Awak.eyeR:Clone()
	Util.SetParentOverrideWithColor(clone2, awakened, player, "LeopardFruitVFXColor")
	clone2.RigidConstraint.Attachment0 = clone2.Attachment
	clone2.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head["Eye.R"]
	local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone3 = FX4:WaitForChild("TigerEffects").V_Awak.Head:Clone()
	Util.SetParentOverrideWithColor(clone3, awakened, player, "LeopardFruitVFXColor")
	clone3.RigidConstraint.Attachment0 = clone3.Attachment
	clone3.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head
	local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone4 = FX5:WaitForChild("TigerEffects").V_Awak.Mouth:Clone()
	Util.SetParentOverrideWithColor(clone4, awakened, player, "LeopardFruitVFXColor")
	clone4.RigidConstraint.Attachment0 = clone4.Attachment
	clone4.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head.Jaw
	local FX6 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone5 = FX6:WaitForChild("TigerEffects").V_Awak.LHand:Clone()
	Util.SetParentOverrideWithColor(clone5, awakened, player, "LeopardFruitVFXColor")
	clone5.RigidConstraint.Attachment0 = clone5.Attachment
	clone5.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.L"]["HandIK.L"]["Hand.L"]
	local FX7 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone6 = FX7:WaitForChild("TigerEffects").V_Awak.RHand:Clone()
	Util.SetParentOverrideWithColor(clone6, awakened, player, "LeopardFruitVFXColor")
	clone6.RigidConstraint.Attachment0 = clone6.Attachment
	clone6.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]
	local FX8 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone7 = FX8:WaitForChild("TigerEffects").V_Awak.Tail1:Clone()
	Util.SetParentOverrideWithColor(clone7, awakened, player, "LeopardFruitVFXColor")
	clone7.RigidConstraint.Attachment0 = clone7.Attachment
	clone7.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Tail1
	local FX9 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone8 = FX9:WaitForChild("TigerEffects").V_Awak.Tail2:Clone()
	Util.SetParentOverrideWithColor(clone8, awakened, player, "LeopardFruitVFXColor")
	clone8.RigidConstraint.Attachment0 = clone8.Attachment
	clone8.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Tail1.Tail2
	local FX10 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone9 = FX10:WaitForChild("TigerEffects").V_Awak.Tail3:Clone()
	Util.SetParentOverrideWithColor(clone9, awakened, player, "LeopardFruitVFXColor")
	clone9.RigidConstraint.Attachment0 = clone9.Attachment
	clone9.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Tail1.Tail2.Tail3
	local FX11 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone10 = FX11:WaitForChild("TigerEffects").V_Awak.Tail4:Clone()
	Util.SetParentOverrideWithColor(clone10, awakened, player, "LeopardFruitVFXColor")
	clone10.RigidConstraint.Attachment0 = clone10.Attachment
	clone10.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Tail1.Tail2.Tail3.Tail4
	local FX12 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone11 = FX12:WaitForChild("TigerEffects").V_Awak.Tail5:Clone()
	Util.SetParentOverrideWithColor(clone11, awakened, player, "LeopardFruitVFXColor")
	clone11.RigidConstraint.Attachment0 = clone11.Attachment
	clone11.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Tail1.Tail2.Tail3.Tail4.Tail5
	local FX13 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone12 = FX13:WaitForChild("TigerEffects").V_Awak.Tail6:Clone()
	Util.SetParentOverrideWithColor(clone12, awakened, player, "LeopardFruitVFXColor")
	clone12.RigidConstraint.Attachment0 = clone12.Attachment
	clone12.RigidConstraint.Attachment1 = rig.RootPart.Controller.Torso1.Tail1.Tail2.Tail3.Tail4.Tail5.Tail6
	local tail7 = rig.RootPart.Controller.Torso1.Tail1.Tail2.Tail3.Tail4.Tail5.Tail6:FindFirstChild("Tail7")

	if not data.wolf and tail7 then
		local FX14 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone13 = FX14:WaitForChild("TigerEffects").V_Awak.TailTip:Clone()
		Util.SetParentOverrideWithColor(clone13, awakened, player, "LeopardFruitVFXColor")
		clone13.RigidConstraint.Attachment0 = clone13.Attachment
		clone13.RigidConstraint.Attachment1 = tail7
	end

	if data.wolf then
		local FX14 = require(ReplicatedStorage:WaitForChild("FX"))
		local wolf = FX14:WaitForChild("TigerEffects").V_Awak.Wolf

		for _, child in pairs(wolf:GetChildren()) do
			local clone13 = child:Clone()
			local child2 = rig:FindFirstChild(child:GetAttribute("ParentString"))

			if not child2 then
				continue
			end

			if child2:FindFirstChildOfClass("SurfaceAppearance") then
				child2:FindFirstChildOfClass("SurfaceAppearance"):Destroy()
			end

			clone13.Parent = child2
		end
	else
		rig.Body.SurfaceAppearance.Color = Color3.fromRGB(186, 154, 133)
		local FX14 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone_2 = FX14:WaitForChild("TigerEffects").V_Awak.NewBandage:Clone()
		clone_2.Parent = rig["Pants + Bandages"]
	end

	local folder = Instance.new("Folder", _WorldOrigin)
	Util.Debris:AddItem(folder, 10)
	local clone13 = tigerEffects.PART_TEMPLATE:Clone()
	clone13.CFrame = root.CFrame
	Util.SetParentOverrideWithColor(clone13, folder, player, "LeopardFruitVFXColor")
end