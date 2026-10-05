local createVector = vector.create
game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").C.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
end

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt0(player, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 10
	v.Frequency = 0.35
	v.AnimationSpeed = 5
	local maxThicknessMultiplier = math.random(1, 2)
	v.MinThicknessMultiplier = 0.35
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(5, 7)
	v.PulseLength = 10000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.45098, 0.992157, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 5
	return v
end

local function ShafiBolt(player, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 3
	v.Frequency = 0.5
	v.AnimationSpeed = 6
	local maxThicknessMultiplier = math.random(1, 2)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(5, 7)
	v.PulseLength = 10000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.368627, 1, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

local function ImpactLine(p, cFrame, primaryPart, p2, p3)
	local clone = assets.Phase2.ImpactLine:Clone()
	Util.SetParentOverrideWithColor(clone, p2, p, "LightningFruitVFXColor")
	clone.CFrame = CFrame.new(primaryPart.Position, cFrame.Position) * p3
	clone.CFrame *= CFrame.new(0, 0, 65.71428571428571)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone2 = assets.Phase2.HitImpact:Clone()
	Util.SetParentOverrideWithColor(clone2, p2, p, "LightningFruitVFXColor")
	clone2.CFrame = CFrame.new(primaryPart.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	TweenService:Create(clone, TweenInfo.new(0.25), {
		Position = CFrame.new(clone.Position, cFrame.Position) * CFrame.new(0, 0, 15).Position
	}):Play()
	local clone3 = assets.Phase2.Barrage:Clone()
	clone3.CFrame = CFrame.new(primaryPart.Position, cFrame.Position) * CFrame.new(
		math.random(-3, 3),
		math.random(1, 3),
		-3
	) * CFrame.Angles(0, 3.141592653589793, 0)
	Util.SetParentOverrideWithColor(clone3, p2, p, "LightningFruitVFXColor")

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local function DragonGrab(cFFloor, root, enemyGrabbed, child, dragon, endPoint2, player)
	local parent = root.Parent
	Util.Sound:Play("BF_Thunder_C_DragonGrab_GrabSequence_01", enemyGrabbed.PrimaryPart, nil, 1.1428571428571428)

	if parent and parent:FindFirstChild("Humanoid") then
		local lightningR15CSuccess = Util.Anims:Get(parent, "Lightning_R15_CSuccess")
		lightningR15CSuccess:Play()
		lightningR15CSuccess:AdjustSpeed(2.02)
	end

	task.spawn(function()
		local clone = assets.Phase1.WeldPart:Clone()
		clone.CFrame = cFFloor
		Util.SetParentOverrideWithColor(clone, child, player, "LightningFruitVFXColor")
		local magnitude = (enemyGrabbed.PrimaryPart.Position - root.Position).Magnitude
		clone.Weld.C0 = CFrame.new(0, 1.5, -magnitude)
		task.spawn(function()
			dragon.Weld.Part1 = clone
			dragon.PrimaryPart.Anchored = false
			dragon.PrimaryPart.Massless = true
			dragon.Weld.C0 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0)
		end)
		local lightningCSuccess = Util.Anims:Get(dragon, "Lightning_CSuccess")
		lightningCSuccess:Play()
		lightningCSuccess:AdjustSpeed(2.02)

		local function screenEffect()
			if root.Parent == game.Players.LocalPlayer.Character or enemyGrabbed == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(8, 6, 0.1, 0.8)
				local Effect = require(game.ReplicatedStorage.Effect)
				Effect.new("ColorCorrection"):replicate({
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(172, 204, 255),
						player,
						"LightningFruitVFXColor"
					),
					Brightness = 0.1,
					Saturation = 0.1,
					Contrast = 0.1,
					FadeIn = 0,
					FadeOut = 0.1,
					Lifetime = 0.1
				})
			end
		end

		task.spawn(function()
			local primaryPart = enemyGrabbed.PrimaryPart
			local cFrame = root.CFrame
			TweenService:Create(clone, TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFrame
			}):Play()
			TweenService:Create(root, TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(endPoint2) * cFrame.Rotation
			}):Play()
			task.wait(0.35)
			local cFrame2 = root.CFrame
			ImpactLine(
				player,
				cFrame,
				primaryPart,
				child,
				CFrame.new(-1, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(0, 0.3490658503988659, 0)
			)
			screenEffect()
			TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFrame2
			}):Play()
			task.wait(0.165)
			local cFrame3 = root.CFrame
			ImpactLine(
				player,
				cFrame,
				primaryPart,
				child,
				CFrame.new(2, 1, -1) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
					0.3490658503988659,
					2.6179938779914944,
					0
				)
			)
			screenEffect()
			TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFrame3
			}):Play()
			task.wait(0.23)
			local cFrame4 = root.CFrame
			ImpactLine(
				player,
				cFrame,
				primaryPart,
				child,
				CFrame.new(5, 1, -1) * CFrame.Angles(-0.2617993877991494, 1.6580627893946132, 0)
			)
			screenEffect()
			TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFrame4
			}):Play()
			task.wait(0.2)
			local cFrame5 = root.CFrame
			ImpactLine(
				player,
				cFrame,
				primaryPart,
				child,
				CFrame.new(1, 1, 1) * CFrame.Angles(0.6108652381980153, -1.7453292519943295, 0)
			)
			screenEffect()
			TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFrame5
			}):Play()
			task.wait(0.275)
			local cFrame6 = root.CFrame
			ImpactLine(
				player,
				cFrame,
				primaryPart,
				child,
				CFrame.new(-0, 0, 1) * CFrame.Angles(-0.5235987755982988, 0.4363323129985824, 0)
			)
			screenEffect()
			TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFrame6
			}):Play()
			task.wait(0.2)
			local cFrame7 = root.CFrame
			ImpactLine(
				player,
				cFrame,
				primaryPart,
				child,
				CFrame.new(4, 1, 0) * CFrame.Angles(0.2617993877991494, 3.141592653589793, 0)
			)
			screenEffect()
			TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFrame7
			}):Play()
			TweenService:Create(root, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = root.CFrame * CFrame.new(0, 0, -15)
			}):Play()
		end)
		task.wait(1.55)

		if (workspace.CurrentCamera.CFrame.p - dragon.PrimaryPart.Position).Magnitude < 100 or root.Parent == game.Players.LocalPlayer.Character or enemyGrabbed == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(14, 14, 0.2, 1)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(164, 231, 255),
					player,
					"LightningFruitVFXColor"
				),
				Brightness = 0.5,
				Saturation = 0.1,
				Contrast = 0.1,
				FadeIn = 0,
				FadeOut = 0.1,
				Lifetime = 0.3
			})
		end

		local clone2 = assets.Phase3.EndImpact:Clone()
		clone2.CFrame = dragon.PrimaryPart.CFrame * CFrame.new(0, 0, 30)
		Util.SetParentOverrideWithColor(clone2, child, player, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		dragon:Destroy()
		clone:Destroy()
	end)
	local clone = assets.Phase1.StartImpact:Clone()
	clone.CFrame = cFFloor * CFrame.new(0, 0, -20)
	Util.SetParentOverrideWithColor(clone, child, player, "LightningFruitVFXColor")
	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	task.spawn(function()
		local v = cFFloor * CFrame.new(0, 30, 5)
		local clone2 = assets.Phase1.SlashModel:Clone()
		clone2.PrimaryPart.CFrame = v * CFrame.new(0, -0, 0) * CFrame.Angles(-1.3962634015954636, 0, 0)
		Util.SetParentOverrideWithColor(clone2, child, player, "LightningFruitVFXColor")
		task.spawn(function()
			for _, beam in pairs(clone2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				local startDelay = beam:GetAttribute("StartDelay")
				local v3 = beam
				local v4 = beam:GetAttribute("EndDelay") / 0.75
				task.spawn(function()
					local tween = TweenService:Create(
						v3,
						TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Width0 = v3.Width0,
							Width1 = v3.Width1
						}
					)
					v3.Width0 = 0
					v3.Width1 = 0
					task.wait(startDelay)
					tween:Play()
					task.wait(v4)
					local tween2 = TweenService:Create(
						v3,
						TweenInfo.new(v4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					v3:Destroy()
				end)
			end
		end)
		TweenService:Create(clone2.PrimaryPart, TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = v * CFrame.new(0, 0, 0) * CFrame.Angles(0.4363323129985824, 0, 0)
		}):Play()
		task.delay(0.125, function()
			TweenService:Create(
				clone2.PrimaryPart,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone2.PrimaryPart.CFrame * CFrame.new(0, 0.5, 1) * CFrame.Angles(1.3962634015954636, 0, 0)
				}
			):Play()
			task.wait(0.25)
			TweenService:Create(
				clone2.PrimaryPart,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone2.PrimaryPart.CFrame * CFrame.new(0, 0.5, 1) * CFrame.Angles(2.9670597283903604, 0, 0)
				}
			):Play()
		end)
		task.spawn(function()
			local v2 = v * CFrame.new(0, 0, -22.5)

			for _ = 1, 5 do
				local clone3 = assets.Phase1.SpinTrailModel:Clone()
				clone3.PrimaryPart.CFrame = v2 * CFrame.new(0, -10, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				Util.SetParentOverrideWithColor(clone3, child, player, "LightningFruitVFXColor")
				local v3 = math.random(3, 5)
				local v4 = math.random(10, 15)
				clone3.PrimaryPart.Attach0.Position = Vector3.new(-v3, 0, -v4)
				clone3.PrimaryPart.Attach1.Position = Vector3.new(v3, 0, -v4)
				local v5 = 0.25 + math.random(-10, 10) / 100
				TweenService:Create(
					clone3.PrimaryPart.Attach0,
					TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Position = Vector3.new(0, 0, -v4 / 3)
					}
				):Play()
				TweenService:Create(
					clone3.PrimaryPart.Attach1,
					TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Position = Vector3.new(0, 0, -v4 / 3)
					}
				):Play()
				task.spawn(function()
					local v8 = math.random(8, 12)

					for i = 1, 5 do
						local tween = TweenService:Create(
							clone3.PrimaryPart,
							TweenInfo.new(v5 / 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone3.PrimaryPart.CFrame * CFrame.new(0, v8, 0) * CFrame.Angles(
									0,
									1.3962634015954636,
									0
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end
				end)
			end
		end)
	end)
	task.spawn(function()
		task.wait(0.375)
		local v = true
		task.spawn(function()
			local primaryPart = enemyGrabbed.PrimaryPart
			local clone2 = assets.Phase2.Barrage:Clone()
			Util.SetParentOverrideWithColor(clone2, child, player, "LightningFruitVFXColor")
			clone2.CFrame = primaryPart.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.LockedToPart = false
				end
			end

			local now = tick()

			repeat
				local _ = now - tick() <= 0
				task.wait(0.115)
			until v ~= true
		end)
		task.spawn(function()
			task.wait(0.75)
			v = false
			task.wait(0.3675)
			local clone2 = assets.Phase3.Explosion:Clone()
			clone2.CFrame = enemyGrabbed.PrimaryPart.CFrame
			Util.SetParentOverrideWithColor(clone2, child, player, "LightningFruitVFXColor")
			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end
		end)
	end)
	task.wait(1.525)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RockCrater(p, parent, data, p2, _)
	task.spawn(function()
		if not p or typeof(p.Position) ~= "Vector3" or typeof(p.Normal) ~= "Vector3" then
			return
		end

		local rockType = data.RockType
		local radius = data.Radius
		local size = data.Size
		local duration = data.Duration
		local amount = data.Amount
		local offset = data.Offset
		local v = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
		local v2 = {}

		for _ = 1, amount do
			local clone = rockType:Clone()
			clone.Parent = parent
			task.delay(7, function()
				clone:Destroy()
			end)
			table.insert(v2, clone)
		end

		task.spawn(function()
			task.wait(duration * 2)

			for _, v3 in pairs(v2) do
				v3:Destroy()
			end

			v2 = nil
		end)
		local v3 = 360 / #v2
		local total = 0

		for _, v4 in pairs(v2) do
			total += v3
			v4.CFrame = v * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)

			if math.random(1, 7) < 2 then
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(0, 0, offset)
			end

			v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-offset, offset * 2)
			)
			local ray = Ray.new(v4.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
			local part, v5 = workspace:FindPartOnRayWithIgnoreList(ray, p2.FilterDescendantsInstances)

			if part then
				local v6 = (v4.Position - p.Position).Magnitude / 150
				local v7 = size * math.random(20, 40) / 10
				local v8 = size * math.random(10, 25) / 10
				local v9 = size * math.random(30, 50) / 10
				v4.Size = Vector3.new(v7 * v6, v8 * v6, v9 * v6)
				v4.Position = v5 + Vector3.new(0, -v4.Size.Y * math.random(5, 6) / 15, 0)
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 5,
					math.random(-offset / 2, offset / 2)
				)
				v4.CFrame = CFrame.new(
					v4.Position,
					v.Position + Vector3.new(0, math.random(-55, -45) / 100 + v4.Size.Y / 500, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 2 - 45 * v6 / 1.7), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v4.Material = part.Material
				v4.Color = part.Color
			else
				v2[v4] = nil
				v4:Destroy()
			end

			TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
				Position = v4.Position + Vector3.new(0, v4.Size.Y * math.random(3, 5) / 8, 0)
			}):Play()
			local v6 = v4
			local v7 = v4
			task.spawn(function()
				wait(duration + math.random(10, 50) / 100)
				local tween = TweenService:Create(
					v6,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v6.Position + Vector3.new(
							math.random(-1, 1),
							-v6.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v6:Destroy()

				if v2 then
					v2[v6] = nil
				end
			end)
		end
	end)
end

return function(data)
	local player = data.Player

	if (currentCamera.CFrame.p - data.Origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding:IsDescendantOf(workspace) and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "LightningC_" .. data.Player.Name
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		local root = data.Root
		local v = root:GetAttribute("LightningSkin") and root:GetAttribute("LightningSkin") == "Purple"
		Util.Sound:Play("BF_Thunder_C_DragonGrab_Activate_01", root)
		local clone = assets.Phase0.HoldAura:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		clone.Anchored = false
		clone.Weld.Part1 = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone2 = assets.Phase0.StartImpact:Clone()
		clone2.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone3 = assets.Phase0.Dragon:Clone()
		clone3:PivotTo(root.CFrame * CFrame.Angles(0, 3.141592653589793, 0))

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			local v2 = clone3

			local function makeProxyPartAtBone(attachment, _, cframe: CFrame?)
				local cFrame = cframe or CFrame.new()
				local part = Instance.new("Part")
				part.CastShadow = false
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Massless = true
				part.Anchored = false
				part.Locked = true
				part.Size = createVector(2, 0.2, 2)
				part.Name = "ProxyPart_" .. attachment.Name
				local attachment2 = Instance.new("Attachment")
				attachment2.CFrame = cFrame
				Util.SetParentOverrideWithColor(attachment2, part, player, "LightningFruitVFXColor")
				local rigidConstraint = Instance.new("RigidConstraint")
				rigidConstraint.Attachment0 = attachment
				rigidConstraint.Attachment1 = attachment2
				Util.SetParentOverrideWithColor(rigidConstraint, part, player, "LightningFruitVFXColor")
				part.Transparency = 1
				Util.SetParentOverrideWithColor(part, v2.RootPart, player, "LightningFruitVFXColor")
				return part
			end

			local proxyPartAtBone = makeProxyPartAtBone(v2.RootPart.Controller.Head)
			clone3.Aura.Weld.C0 = CFrame.new(0, 0, 0)
			clone3.Aura.Weld.C1 = CFrame.new(0, 0, 0)
			clone3.Aura.Weld.Part0 = proxyPartAtBone
			local proxyPartAtBone2 = makeProxyPartAtBone(v2.RootPart.Controller.Body1.Body2.Body3)
			clone3.Aura1.Weld.C0 = CFrame.new(0, 0, 0)
			clone3.Aura1.Weld.C1 = CFrame.new(0, 0, 0)
			clone3.Aura1.Weld.Part0 = proxyPartAtBone2
			local proxyPartAtBone3 = makeProxyPartAtBone(v2.RootPart.Controller.Body1.Body2.Body3.Body4.Body5)
			clone3.Aura2.Weld.C0 = CFrame.new(0, 0, 0)
			clone3.Aura2.Weld.C1 = CFrame.new(0, 0, 0)
			clone3.Aura2.Weld.Part0 = proxyPartAtBone3
			local proxyPartAtBone4 = makeProxyPartAtBone(v2.RootPart.Controller.Body1.Body2.Body3.Body4.Body5.Body6.Body7)
			clone3.Aura3.Weld.C0 = CFrame.new(0, 0, 0)
			clone3.Aura3.Weld.C1 = CFrame.new(0, 0, 0)
			clone3.Aura3.Weld.Part0 = proxyPartAtBone4
		end)
		Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")

		if v then
			clone3["Body.009"].Color = Color3.fromRGB(109, 69, 159)
			clone3.Aura.Attachment.Particle_.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
			clone3.Aura.Attachment1.Particle_.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
		end

		local lightningCWindup = Util.Anims:Get(clone3, "Lightning_CWindup")
		lightningCWindup.Priority = Enum.AnimationPriority.Action4
		lightningCWindup.Looped = false
		lightningCWindup:Play()
		local lightningCHold = Util.Anims:Get(clone3, "Lightning_CHold")
		lightningCHold.Priority = Enum.AnimationPriority.Idle
		lightningCHold.Looped = true
		lightningCHold:Play()
		local v2 = Util.Sound:Play("BF_Thunder_C_DragonGrab_HeldLoop_01", root)
		TweenService:Create(v2, TweenInfo.new(0.2), {
			Volume = 1
		}):Play()

		if lightningCWindup then
			lightningCWindup:Stop(0.2)
		end

		lightningCHold.TimePosition = 0
		local _ = tick() + 0.25
		local now = tick()
		local v3 = {}
		local v4 = {}

		while true do
			if now - tick() <= 0 then
				now = tick() + 0.125

				for _ = 1, math.random(1, 2) do
					task.spawn(function()
						local position = root.Position
						local clone4 = FX:WaitForChild("Lightning2").C.Part:Clone()
						clone4.CFrame = CFrame.new(position) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
						Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
						local v5 = math.random(1, 4)
						local aura1

						if v5 == 4 then
							aura1 = clone3.Aura.Aura1
						else
							aura1 = clone3["Aura" .. v5]
						end

						clone4.Attach1.WorldPosition = aura1.Position
						local shafiBolt0 = ShafiBolt0(player, clone4.Attach0, clone4.Attach1, 10, 0.35, folder)
						local curveSize = math.random(-5, 5)
						local curveSize2 = math.random(-5, 5)
						shafiBolt0.CurveSize0 = curveSize
						shafiBolt0.CurveSize1 = curveSize2
						v3[clone4.Attach1] = aura1
						v4[shafiBolt0] = shafiBolt0
						task.wait(0.2 + math.random() * 0.25)
						v3[clone4.Attach1] = nil

						if v4 == nil then
							return
						end

						v4[shafiBolt0] = nil
						shafiBolt0:Destroy()
					end)
				end
			end

			for k, v5 in pairs(v3) do
				k.WorldPosition = v5.Position
			end

			for _, v5 in pairs(v4) do
				v5.CurveSize0 *= 1.025
				v5.CurveSize1 *= 1.025
			end

			task.wait()

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			for _, v5 in pairs(v4) do
				v5:Destroy()
			end

			v4 = nil

			if lightningCHold then
				lightningCHold:Stop()
			end

			if lightningCWindup then
				lightningCWindup:Stop()
			end

			Util.Anims:Get(clone3, "Lightning_CLaunch"):Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone.Weld.Enabled = false
			clone.Anchored = true
			Util.Debris:AddItem(folder, 15)
			return
		end
	elseif stage == 2 then
		local v = _WorldOrigin:FindFirstChild("LightningC_" .. data.Player.Name)

		if not v then
			v = Instance.new("Folder")
			v.Name = "LightningC_" .. data.Player.Name
			v.Parent = _WorldOrigin
			Util.Debris:AddItem(v, 15)
		end

		local startCFrame = data.StartCFrame
		local root = data.Root
		local dragon = v:FindFirstChild("Dragon")

		if not dragon then
			local lightningR15CLaunch = Util.Anims:Get(root.Parent, "Lightning_R15_CLaunch")
			lightningR15CLaunch.Priority = Enum.AnimationPriority.Action2
			lightningR15CLaunch:Play()
			dragon = assets.Phase0.Dragon:Clone()
			dragon:PivotTo(startCFrame * CFrame.Angles(0, 3.141592653589793, 0))

			for _, emitter in pairs(dragon:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				local v2 = dragon

				local function makeProxyPartAtBone(attachment, _, cframe: CFrame?)
					local cFrame = cframe or CFrame.new()
					local part = Instance.new("Part")
					part.CastShadow = false
					part.CanCollide = false
					part.CanTouch = false
					part.CanQuery = false
					part.Massless = true
					part.Anchored = false
					part.Locked = true
					part.Size = createVector(2, 0.2, 2)
					part.Name = "ProxyPart_" .. attachment.Name
					local attachment2 = Instance.new("Attachment")
					attachment2.CFrame = cFrame
					attachment2.Parent = part
					local rigidConstraint = Instance.new("RigidConstraint")
					rigidConstraint.Attachment0 = attachment
					rigidConstraint.Attachment1 = attachment2
					rigidConstraint.Parent = part
					part.Transparency = 1
					part.Parent = v2.RootPart
					return part
				end

				local proxyPartAtBone = makeProxyPartAtBone(v2.RootPart.Controller.Head)
				dragon.Aura.Weld.C0 = CFrame.new(0, 0, 0)
				dragon.Aura.Weld.C1 = CFrame.new(0, 0, 0)
				dragon.Aura.Weld.Part0 = proxyPartAtBone
				local proxyPartAtBone2 = makeProxyPartAtBone(v2.RootPart.Controller.Body1.Body2.Body3)
				dragon.Aura1.Weld.C0 = CFrame.new(0, 0, 0)
				dragon.Aura1.Weld.C1 = CFrame.new(0, 0, 0)
				dragon.Aura1.Weld.Part0 = proxyPartAtBone2
				local proxyPartAtBone3 = makeProxyPartAtBone(v2.RootPart.Controller.Body1.Body2.Body3.Body4.Body5)
				dragon.Aura2.Weld.C0 = CFrame.new(0, 0, 0)
				dragon.Aura2.Weld.C1 = CFrame.new(0, 0, 0)
				dragon.Aura2.Weld.Part0 = proxyPartAtBone3
				local proxyPartAtBone4 = makeProxyPartAtBone(v2.RootPart.Controller.Body1.Body2.Body3.Body4.Body5.Body6.Body7)
				dragon.Aura3.Weld.C0 = CFrame.new(0, 0, 0)
				dragon.Aura3.Weld.C1 = CFrame.new(0, 0, 0)
				dragon.Aura3.Weld.Part0 = proxyPartAtBone4
			end)
			Util.SetParentOverrideWithColor(dragon, v, player, "LightningFruitVFXColor")

			if root:GetAttribute("LightningSkin") and root:GetAttribute("LightningSkin") == "Purple" then
				pcall(function()
					dragon["Body.009"].Color = Color3.fromRGB(109, 69, 159)
					dragon.Aura.Attachment.Particle_.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
					dragon.Aura.Attachment1.Particle_.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
				end)
			end

			Util.Anims:Get(dragon, "Lightning_CLaunch"):Play()
		end

		local clone = assets.Phase0.StartImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, v, player, "LightningFruitVFXColor")
		Util.Sound:Play("BF_Thunder_C_DragonGrab_Release_01", root)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local _ = data.distTravelledForward
		local v2 = startCFrame * CFrame.Angles(0, 3.141592653589793, 0)
		dragon:PivotTo(v2)
		local _ = data.endPoint
		local timeUntilReachedEndPoint = data.timeUntilReachedEndPoint or 0.1
		local distTravelledForward = data.distTravelledForward
		local cFrame2 = CFrame.new(data.endPoint, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
		local clone2 = assets.Phase0.DashAura:Clone()
		clone2.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone2, v, player, "LightningFruitVFXColor")
		clone2.Anchored = true
		task.spawn(function()
			root.Anchored = true
			task.delay(timeUntilReachedEndPoint, function()
				root.Anchored = false
			end)
			local lastTime = os.clock()

			while os.clock() - lastTime < timeUntilReachedEndPoint do
				local v4 = (os.clock() - lastTime) / timeUntilReachedEndPoint
				root.CFrame = cFrame2 * CFrame.new(0, 0, distTravelledForward * (1 - v4 ^ 0.5))
				clone2.CFrame = root.CFrame
				dragon.PrimaryPart.CFrame = root.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				RunService.PreSimulation:Wait()
			end

			root.CFrame = cFrame2
			clone2.CFrame = root.CFrame
			dragon.PrimaryPart.CFrame = root.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		end)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v4 = tick() + timeUntilReachedEndPoint
		local now = tick()
		local v5 = {}

		while true do
			if now - tick() <= 0 then
				now = tick() + 0.025
				local position = root.Position
				local raycastResult = workspace:Raycast(
					position + createVector(0, 1, 0),
					createVector(-0, -5, -0),
					raycastParams
				)

				for _ = 1, math.random(2, 3) do
					if not raycastResult then
						continue
					end

					local v6 = raycastResult
					task.spawn(function()
						local worldPosition = v6.Position + Vector3.new(math.random(-25, 25), 0, math.random(-25, 25))
						local clone3 = FX:WaitForChild("Lightning2").C.Part:Clone()
						clone3.CFrame = CFrame.new(root.Position, worldPosition)
						Util.SetParentOverrideWithColor(clone3, v, player, "LightningFruitVFXColor")
						clone3.Anchored = false
						clone3.Weld.Part1 = root
						clone3.Massless = true
						clone3.Weld.C1 = CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-0, 0)) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							-1.5707963267948966
						)
						clone3.Attach1.WorldPosition = worldPosition
						clone3.Attach1:SetAttribute("Pos", worldPosition)
						clone3.Attach0.Orientation = Vector3.new(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						)
						local shafiBolt = ShafiBolt(
							player,
							clone3.Attach0,
							clone3.Attach1,
							math.random(15, 20),
							0.5 + math.random() * 0.25,
							v
						)
						local curveSize = math.random(-15, 5) * 1.75
						local curveSize2 = math.random(-5, 15) * 1.75
						shafiBolt.CurveSize0 = curveSize
						shafiBolt.CurveSize1 = curveSize2
						v5[clone3.Attach1] = shafiBolt
						task.wait(0.15 * math.random() + 0.15)
						v5[clone3.Attach1] = nil
						shafiBolt:Destroy()
					end)
				end
			end

			for k, _ in pairs(v5) do
				local pos = k:GetAttribute("Pos")
				k.WorldPosition = CFrame.new(pos, root.Position).Position
			end

			task.wait()

			if not (v4 - tick() <= 0) then
				continue
			end

			for k, _ in pairs(v5) do
				k.Parent.Weld.Enabled = false
				k.Parent.Anchored = true
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone2.Anchored = true
			return
		end
	elseif stage == 3 then
		local child = _WorldOrigin:FindFirstChild("LightningC_" .. data.Player.Name)

		if not child then
			return
		end

		child.Name = "Destroying"
		local _ = data.StartCFrame
		local root = data.Root
		local dragon = child:FindFirstChild("Dragon")

		if not dragon then
			return
		end

		local grabObject = data.GrabObject
		local enemyGrabbed = data.EnemyGrabbed
		local enemyRoot = data.EnemyRoot
		local enemyHum = data.EnemyHum
		local attackerHum = data.AttackerHum
		task.spawn(function()
			local lastTime = tick()
			tick()
			tick()

			while tick() - lastTime < data.dur and enemyGrabbed and enemyHum and root and grabObject and grabObject:IsDescendantOf(workspace) and not (attackerHum.Health <= 0) and enemyHum and not (enemyHum.Health <= 0) do
				local _, v = Util.Ray(
					root.Position,
					root.CFrame.LookVector * 15,
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				)
				local magnitude = (v - root.Position).Magnitude
				enemyRoot.CFrame = CFrame.new(root.Position + root.CFrame.LookVector * magnitude, root.Position)
				task.wait()
			end
		end)
		DragonGrab(data.CFFloor, root, enemyGrabbed, child, dragon, data.EndPoint2, player)

		local function fn(lightningBonus)
			root.Anchored = true
			local clone = assets.BonusPhase1.DashAura:Clone()
			clone.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone, child, player, "LightningFruitVFXColor")
			clone.Anchored = true

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				repeat
					task.wait()
					clone.CFrame = root.CFrame
				until not clone or clone:GetAttribute("Stop")
			end)
			local v = root
			local position = v.Position
			local position2 = lightningBonus.Position
			local unit = (position2 - position).Unit
			local rightVector = v.CFrame.RightVector
			local v2 = (position2 - position).Magnitude / 4

			for i = 1, 4 do
				local _ = i / 4
				local v3 = unit * (v2 * i)
				local v4 = rightVector * ((i % 2 == 0 and 1 or -1) * 20)
				local v5 = position + v3 + v4 + createVector(0, 0, 0)
				local cframe = CFrame.new(v5, position2)
				local tween = TweenService:Create(v, TweenInfo.new(0.0625, Enum.EasingStyle.Linear), {
					CFrame = cframe
				})
				tween:Play()
				tween.Completed:Wait()

				if i == 3 then
					break
				end
			end

			TweenService:Create(root, TweenInfo.new(0.05), {
				CFrame = lightningBonus
			}):Play()
			task.wait(0.05)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone:SetAttribute("Stop", true)
			clone.Anchored = true
			clone.CFrame = root.CFrame
			task.wait(0.5)
			local ray = Ray.new(position2, CFrame.new(position2).UpVector * -1000)
			local part, position3, normal = workspace:FindPartOnRayWithIgnoreList(
				ray,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)
			local clone2 = assets.BonusPhase1.StartImpact:Clone()
			clone2.CFrame = CFrame.new(root.Position, position3) * CFrame.new(0, 0, -5)
			Util.SetParentOverrideWithColor(clone2, child, player, "LightningFruitVFXColor")
			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

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

			task.spawn(function()
				local clone3 = assets.BonusPhase1.SpinSlash:Clone()
				clone3:PivotTo(CFrame.new(root.Position) * CFrame.new(0, -15, 0))
				Util.SetParentOverrideWithColor(clone3, child, player, "LightningFruitVFXColor")
				local model = clone3.Model

				for i = 1, 3 do
					local v5 = i * 0.1 + 0.75
					local clone4 = model:Clone()
					clone4:ScaleTo(v5)
					local primaryPart = clone4.PrimaryPart
					local v6 = clone3.PrimaryPart.CFrame * CFrame.new(0, v5, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
					local angularVelocity = primaryPart.AngularVelocity
					primaryPart.Anchored = false
					primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(0, i * 2 * 5, 0)
					angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)

					if i == 3 then
						v6 *= CFrame.new(0, -20, 0)
						primaryPart.AlignPosition.Responsiveness = 25
						primaryPart.AlignPosition.Position = primaryPart.Position + createVector(0, 35, 0)
					end

					clone4:PivotTo(v6)
					Util.SetParentOverrideWithColor(clone4, clone3, player, "LightningFruitVFXColor")
					primaryPart.AlignPosition.Enabled = true
					angularVelocity.Enabled = true
					clone4:GetScale()
					local v8 = i
					local folder = clone4
					task.spawn(function()
						task.spawn(function()
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
										0,
										math.random(5, 15),
										0
									)
								}
							):Play()
						end)

						if v8 == 3 then
							task.wait(0.025)
						else
							task.wait(0.035 * math.random() + 0.05)
						end

						for i2, effect in pairs(folder:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.25 + math.random() * 0.15 / i2), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v9 = effect
								task.delay(1, function()
									v9:Destroy()
								end)
							elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						task.wait(1)
						angularVelocity.Enabled = false
					end)
				end

				model:Destroy()
				task.spawn(function()
					local scale = clone3:GetScale()
					local v5 = scale * 2.5

					for i = scale * 100, v5 * 100, 10 do
						clone3:ScaleTo(i / 100)
						task.wait(0.005)
					end
				end)
			end)
			task.wait(0.125)
			local clone3 = assets.BonusPhase1.Explosion:Clone()
			clone3.CFrame = CFrame.new(position3) * CFrame.new(0, 5, 0)
			Util.SetParentOverrideWithColor(clone3, child, player, "LightningFruitVFXColor")
			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone3:GetDescendants()) do
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

			if part then
				task.spawn(function()
					task.wait(0.1)
					local cFrame = AlignCFrame(CFrame.new(position3), normal) + normal * 0.01
					local clone4 = assets.BonusPhase1.GroundCrack:Clone()
					clone4.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone4, child, player, "LightningFruitVFXColor")
					DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

					for _, emitter in pairs(clone4:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v6 = emitter
						task.spawn(function()
							if v6:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v6:GetAttribute("EmitDelay"))
							end

							v6:Emit(v6:GetAttribute("EmitCount"))
						end)
					end

					local v6 = {
						Radius = 70,
						Size = 10,
						Duration = 1,
						Amount = 20,
						RockType = assets.CraterRock,
						Offset = 10
					}
					task.spawn(function()
						RockCrater({
							Position = position3,
							Normal = normal,
							Instance = nil
						}, child, v6, raycastParams) -- equivalent call inferred; original call site unknown
					end)
					task.spawn(function()
						for _ = 1, 20 do
							task.spawn(function()
								local clone5 = assets.BonusPhase1.Rock:Clone()
								clone5.CFrame = CFrame.new(position3) * CFrame.Angles(
									0,
									math.rad((math.random(-180, 180))),
									0
								)
								Util.SetParentOverrideWithColor(clone5, child, player, "LightningFruitVFXColor")
								clone5.CFrame = clone5.CFrame * CFrame.new(0, 0, -50) * CFrame.Angles(
									math.rad(90 + math.random(-50, -0)),
									0,
									0
								)
								clone5.Size = Vector3.new(
									math.random(2, 5) * 2,
									math.random(1, 2) * 2,
									math.random(2, 5) * 2
								)
								clone5.Anchored = false
								clone5.Material = part.Material
								clone5.Color = part.Color
								clone5.AngularVelocity.AngularVelocity = Vector3.new(
									math.random(-10, 10),
									math.random(-10, 10),
									math.random(-10, 10)
								)
								clone5.AngularVelocity.Enabled = true
								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(7000000, 7000000, 7000000)
								bodyVelocity.P = 5000
								Util.SetParentOverrideWithColor(bodyVelocity, clone5, player, "LightningFruitVFXColor")
								local v7 = math.random(50, 150) * 1.25
								task.delay(math.random(5, 20) / 50, function()
									bodyVelocity:Destroy()
								end)
								bodyVelocity.Velocity = clone5.CFrame.LookVector * v7
								task.delay(0.25, function()
									clone5.CanCollide = true
								end)
								task.wait(math.random() * 0.5)
								clone5.AngularVelocity.Enabled = false
								task.wait(math.random() * 0.5 + 1.5)
								TweenService:Create(clone5, TweenInfo.new(0.5 + math.random() * 0.25), {
									Size = createVector(0, 0, 0)
								}):Play()
							end)
							task.wait(math.random() * 0.0015)
						end
					end)
				end)
			end

			root.Anchored = false
			task.wait(0.5)
		end

		if data.BonusDoable then
			local clone = assets.BonusPhase1.Target:Clone()
			clone.CFrame = enemyGrabbed.PrimaryPart.CFrame
			Util.SetParentOverrideWithColor(clone, child, player, "LightningFruitVFXColor")
			clone.Anchored = false

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit(1)
			end

			local v = tick() + 1

			while true do
				clone.CFrame = enemyGrabbed.PrimaryPart.CFrame

				if root:GetAttribute("LightningBonus") then
					clone:Destroy()
					fn(root:GetAttribute("LightningBonus"))
					break
				end

				task.wait()

				if v - tick() <= 0 then
					break
				end
			end

			if clone then
				clone:Destroy()
			end
		end
	elseif stage == 4 then
		local player2 = data.Player
		local v = _WorldOrigin:FindFirstChild("LightningC_" .. (not player2 and "" or player2.Name or ""))

		if not v then
			v = Instance.new("Folder")
			v.Name = "LightningC_" .. (not player2 and "Boss" or player2.Name or "Boss")
			v.Parent = _WorldOrigin
			Util.Debris:AddItem(v, 15)
		end

		local lifetime = data.Lifetime
		v.Name = "Destroying"
		local startCFrame = data.StartCFrame
		local _ = data.Root
		local dragon = v:FindFirstChild("Dragon")

		if not dragon then
			dragon = assets.Phase0.Dragon:Clone()
			dragon:PivotTo(startCFrame * CFrame.Angles(0, 3.141592653589793, 0))
			Util.SetParentOverrideWithColor(dragon, v, player2, "LightningFruitVFXColor")
		end

		if not dragon.PrimaryPart then
			dragon.PrimaryPart = dragon:FindFirstChildWhichIsA("BasePart") or dragon.PrimaryPart
		end

		dragon:SetPrimaryPartCFrame(startCFrame)
		TweenService:Create(
			dragon.PrimaryPart,
			TweenInfo.new(lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = data.EndCFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}
		):Play()
		local clone = assets.Phase3.DragonAura:Clone()
		clone.CFrame = dragon.PrimaryPart.CFrame
		Util.SetParentOverrideWithColor(clone, v, player2, "LightningFruitVFXColor")
		clone.Anchored = false
		clone.Weld.Part1 = dragon.PrimaryPart
		TweenService:Create(
			Util.Sound:Play("BF_Thunder_C_NoGrab_ContinuedProjectile_Launch_02", clone.CFrame),
			TweenInfo.new(0.1),
			{
				Volume = 1
			}
		):Play()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(lifetime)
		local cFrame = dragon.PrimaryPart.CFrame
		local clone2 = assets.Phase3.EndImpact:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, v, player2, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone3 = assets.Phase3.Explosion2:Clone()
		clone3.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone3, v, player2, "LightningFruitVFXColor")
		Util.Sound:Play("BF_Thunder_C_NoGrab_ContinuedProjectile_Explosion_03", clone3.CFrame)
		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		if (workspace.CurrentCamera.CFrame.p - cFrame.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(14, 14, 0.2, 1)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(156, 215, 255),
					player2,
					"LightningFruitVFXColor"
				),
				Brightness = 0.5,
				Saturation = 0.1,
				Contrast = 0.1,
				FadeIn = 0,
				FadeOut = 0.1,
				Lifetime = 0.1
			})
		end

		dragon:Destroy()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone.Weld.Enabled = false
		clone.Anchored = true
		task.spawn(function()
			local position = cFrame.Position
			local ray = Ray.new(position, CFrame.new(position).UpVector * -50)
			local part, position2, normal = workspace:FindPartOnRayWithIgnoreList(
				ray,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)

			if part then
				local v5 = {
					Radius = 70,
					Size = 10,
					Duration = 1,
					Amount = 20,
					RockType = assets.CraterRock,
					Offset = 10
				}
				task.spawn(function()
					RockCrater({
						Position = position2,
						Normal = normal,
						Instance = nil
					}, v, v5, raycastParams) -- equivalent call inferred; original call site unknown
				end)
				task.spawn(function()
					for _ = 1, 10 do
						task.spawn(function()
							task.wait(math.random() * 0.0015)
							local clone4 = assets.BonusPhase1.Rock:Clone()
							clone4.CFrame = CFrame.new(position2) * CFrame.Angles(
								0,
								math.rad((math.random(-180, 180))),
								0
							)
							Util.SetParentOverrideWithColor(clone4, v, player2, "LightningFruitVFXColor")
							clone4.CFrame = clone4.CFrame * CFrame.new(0, 0, -50) * CFrame.Angles(
								math.rad(90 + math.random(-50, -0)),
								0,
								0
							)
							clone4.Size = Vector3.new(
								math.random(2, 5) * 2,
								math.random(1, 2) * 2,
								math.random(2, 5) * 2
							)
							clone4.Anchored = false
							clone4.Material = part.Material
							clone4.Color = part.Color
							rocks:ApplyCollision(clone4, nil, true)
							clone4.AngularVelocity.AngularVelocity = Vector3.new(
								math.random(-10, 10),
								math.random(-10, 10),
								math.random(-10, 10)
							)
							clone4.AngularVelocity.Enabled = true
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.MaxForce = createVector(7000000, 7000000, 7000000)
							bodyVelocity.P = 5000
							Util.SetParentOverrideWithColor(bodyVelocity, clone4, player2, "LightningFruitVFXColor")
							local v6 = math.random(50, 150) * 1.25
							task.delay(math.random(5, 20) / 100, function()
								bodyVelocity:Destroy()
							end)
							bodyVelocity.Velocity = clone4.CFrame.LookVector * v6
							task.delay(0.25, function()
								clone4.CanCollide = true
							end)
							task.wait(math.random() * 0.5)
							clone4.AngularVelocity.Enabled = false
							task.wait(math.random() * 0.5 + 1.5)
							TweenService:Create(clone4, TweenInfo.new(0.5 + math.random() * 0.25), {
								Size = createVector(0, 0, 0)
							}):Play()
						end)
					end
				end)
			end
		end)
	elseif stage == 5 then
		local position = data.Position
		local norm = data.Norm
		local hitMaterial = data.HitMaterial
		local hitColor = data.HitColor
		local root = data.Root

		if typeof(position) ~= "Vector3" or typeof(norm) ~= "Vector3" then
			return
		end

		local particleScaler = Util.ParticleScaler
		local folder = Instance.new("Folder")
		folder.Name = "BossCrater_" .. (not player and "Unknown" or player.Name or "Unknown")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local clone = assets.Phase1.StartImpact:Clone()
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		clone.CFrame = root * CFrame.new(0, 0, -20)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				particleScaler.Particle(emitter, 0.45)
			end
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				local emitDelay = v:GetAttribute("EmitDelay")

				if emitDelay and emitDelay ~= 0 then
					task.wait(emitDelay)
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			task.wait(0.1)
			local cFrame = AlignCFrame(CFrame.new(position), norm) + norm * 0.01
			local clone2 = assets.BonusPhase1.GroundCrack:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					particleScaler.Particle(emitter, 0.45)
				end
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					local emitDelay = v2:GetAttribute("EmitDelay")

					if emitDelay and emitDelay ~= 0 then
						task.wait(emitDelay)
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end

			local v2 = {
				Radius = 31.5,
				Size = 4.5,
				Duration = 1,
				Amount = 15,
				RockType = assets.CraterRock,
				Offset = 8
			}
			task.spawn(function()
				RockCrater({
					Position = position,
					Normal = norm,
					Instance = nil
				}, folder, v2, raycastParams) -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				for _ = 1, 9 do
					task.spawn(function()
						local clone3 = assets.BonusPhase1.Rock:Clone()
						Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
						clone3.CFrame = CFrame.new(position) * CFrame.new(0, 0, -18) * CFrame.Angles(
							math.rad(90 + math.random(-50, 0)),
							0,
							0
						)
						clone3.Size *= 0.45
						clone3.Anchored = false
						clone3.Material = hitMaterial or Enum.Material.Rock
						clone3.Color = hitColor or Color3.new(0.3, 0.3, 0.3)
						local angularVelocity = clone3.AngularVelocity
						angularVelocity.AngularVelocity = Vector3.new(
							math.random(-10, 10),
							math.random(-10, 10),
							math.random(-10, 10)
						)
						angularVelocity.Enabled = true
						local bodyVelocity = Instance.new("BodyVelocity")
						Util.SetParentOverrideWithColor(bodyVelocity, clone3, player, "LightningFruitVFXColor")
						bodyVelocity.MaxForce = createVector(7000000, 7000000, 7000000)
						bodyVelocity.P = 5000
						bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(50, 150) * 0.45
						task.delay(0.25, function()
							clone3.CanCollide = true
						end)
						task.wait(0.15 + math.random() * 0.35)
						angularVelocity.Enabled = false
						task.wait(0.675)
						TweenService:Create(clone3, TweenInfo.new(0.25 + math.random() * 0.2), {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
					task.wait(math.random() * 0.002)
				end
			end)
		end)
	end
end