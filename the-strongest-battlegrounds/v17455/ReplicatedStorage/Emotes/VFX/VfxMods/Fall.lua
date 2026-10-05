local createVector = vector.create
local Fall = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local EFP = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local lightingmanager = require(script.Parent.lightingmanager)
local Trail = require(script.Parent.Trail)

function Fall.FirstEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local parent = object._maid:give(Instance.new("Part"))
		parent.Anchored = true
		parent.Transparency = 1
		parent.CanCollide = false
		parent.Parent = EFP
		local folder = object._maid:give(vfx.Spin:Clone())
		folder.Name = "SpinNew"
		folder.Parent = parent
		task.delay(0.1, function()
			able({
				FX = folder,
				On = true
			})
		end)
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 1 do
				local orientation, v3, v4 = humanoidRootPart.CFrame:ToOrientation()
				parent:PivotTo(CFrame.new(char.Torso.Position) * CFrame.Angles(orientation, v3, v4))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end)
		local v3 = object._maid:give(Instance.new("Highlight"))
		v3.FillColor = Color3.new(1, 1, 1)
		v3.FillTransparency = 0
		v3.OutlineTransparency = 1
		v3.Parent = char
		TweenService:Create(v3, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()

		for _, part in pairs({ char["Left Arm"], char["Right Leg"] }) do
			local v5 = object._maid:give(vfx.TrailArm:Clone())
			local weld = Instance.new("Weld")
			weld.Part0 = v5
			weld.Part1 = part
			weld.Parent = v5
			v5.Parent = EFP
			local folder2 = v5
			task.delay(2, function()
				for i, trail in pairs(folder2:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					playTween(trail, {
						Time = 0.5,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						}
					})
					game.Debris:AddItem(trail, 0.5)
				end
			end)
		end

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.RotSpeed = NumberRange.new(emitter.RotSpeed.Min * 3, emitter.RotSpeed.Max * 3)
			end
		end

		task.delay(0.35, function()
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.RotSpeed = NumberRange.new(descendant.RotSpeed.Min * 0.3, descendant.RotSpeed.Max * 0.3)
				elseif descendant:IsA("ObjectValue") then
					descendant:SetAttribute("TimeScale", 0.9)
				end
			end

			task.wait(0.05)
			able({
				FX = folder,
				On = false
			})
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Fall.DashEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local hit = data.hit
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DashEvent()
		local v2 = object._maid:give(Instance.new("Highlight"))
		v2.FillColor = Color3.new(1, 1, 1)
		v2.FillTransparency = 0
		v2.OutlineTransparency = 1
		v2.Parent = char
		TweenService:Create(v2, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()

		if game.Players.LocalPlayer == char or game.Players.LocalPlayer.Character == hit then
			lightingmanager.Trigger({
				Source = humanoidRootPart,
				FadeInTime = 0,
				SustainTime = 0,
				FadeOutTime = 0.2,
				MaxDistance = 100,
				RequiresLineOfSight = true,
				LookSensitivity = 0.6,
				Instances = {
					{
						Class = "BloomEffect",
						Properties = {
							Intensity = 2,
							Size = 35,
							Threshold = 0.8
						}
					},
					{
						Class = "ColorCorrectionEffect",
						Properties = {
							Contrast = 1.5,
							Saturation = -0.5
						}
					}
				}
			})
		end

		local targetCFrame = data.targetCFrame
		local startpentago = data.startpentago
		local bind = data.Bind
		local orientation, _, _ = CFrame.new(startpentago.Position, targetCFrame.Position):ToOrientation()
		local v3 = orientation + 1.5707963267948966
		local FX = quickFX({
			FX = vfx.Dash,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 130, 0)
		})
		lifeScale({
			FX = FX,
			Scale = 0.5
		})
		playAttachment(FX)

		local function Rest()
			local FX2 = quickFX({
				FX = vfx.NewFall,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame
			})
			tick()
			task.delay(0.95, function()
				able({
					FX = FX2,
					On = false
				})
			end)
			local v6 = object._maid:give(vfx.Reda3:Clone())
			local scale = v6.Mesh.Scale
			v6.Parent = EFP
			local v7 = object._maid:give(vfx.Wind2:Clone())
			v7.Parent = EFP
			local v8 = object._maid:give(Instance.new("NumberValue"))
			v8.Value = 0
			TweenService:Create(v8, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Value = 0.7
			}):Play()
			local v9 = object._maid:give(Instance.new("NumberValue"))
			v9.Value = 1
			task.delay(1, function()
				v9.Value = 2
			end)
			local count = 0

			while bind.Parent do
				local orientation2, v10, _ = humanoidRootPart.CFrame:ToOrientation()

				if count % 5 == 0 then
					local clone = vfx.Shockwave2:Clone()
					clone:ScaleTo(3 * v9.Value)
					playMesh({
						Model = clone,
						T = 0.5,
						EndT = 1,
						Anchor = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v10, 0) * CFrame.Angles(
							v3,
							math.rad((random:NextNumber(-360, 360))),
							0
						) * CFrame.new(0, -33, 0),
						Info = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)
					})
				end

				if count % 7 == 0 then
					local clone = vfx.New:Clone()
					clone:ScaleTo(1 * v9.Value)
					playMesh({
						Model = clone,
						T = 0.5,
						EndT = 1,
						Anchor = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v10, 0) * CFrame.Angles(
							v3 + 3.141592653589793,
							math.rad((random:NextNumber(-360, 360))),
							0
						) * CFrame.new(0, 33, 0),
						Info = TweenInfo.new(0.1, Enum.EasingStyle.Exponential)
					})
				end

				if count % 9 == 0 then
					local clone = vfx.Wind:Clone()
					clone:ScaleTo(5 * v9.Value)
					playMesh({
						Model = clone,
						T = 1,
						EndT = 1,
						Anchor = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v10, 0) * CFrame.Angles(
							v3,
							math.rad((random:NextNumber(-360, 360))),
							0
						) * CFrame.new(0, -33, 0),
						Info = TweenInfo.new(0.4, Enum.EasingStyle.Sine)
					})

					for _, decal in pairs(clone.Start:GetDescendants()) do
						if not decal:IsA("Decal") then
							continue
						end

						decal.Transparency = 0.9
						TweenService:Create(decal, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end

				v6.Mesh.Scale = scale * random:NextNumber(1.5, 2.2) * v8.Value * v9.Value
				v6:PivotTo(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v10, 0) * CFrame.Angles(
					v3,
					math.rad((random:NextNumber(-360, 360))),
					1.5707963267948966
				) * CFrame.new(0, 0, 0))
				v7:PivotTo(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v10, 0) * CFrame.Angles(
					v3,
					math.rad((random:NextNumber(-360, 360))),
					1.5707963267948966
				) * CFrame.new(33, 0, 0))
				v7.Mesh.Scale = scale * random:NextNumber(1.5, 2.2) + createVector(1.9499999, 0, 0) * v9.Value
				FX2:PivotTo(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v10, 0) * CFrame.Angles(
					math.rad(orientation2),
					0,
					0
				))
				count += 1
				task.wait(0.01)
			end

			v6:Destroy()
			v7:Destroy()
		end

		task.wait(0.1)
		Rest()
	end

	task.spawn(DashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Fall.LandEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local hit = data.hit
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(25, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v2 = game.Players.LocalPlayer == char or game.Players.LocalPlayer.Character == hit

	local function LandEvent()
		local _, v3, _ = humanoidRootPart.CFrame:ToOrientation()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.Map }
		local raycastResult = game.Workspace:Raycast(humanoidRootPart.Position, createVector(0, -100, 0), raycastParams)
		local targetCFrame = data.targetCFrame

		if not raycastResult then
			return
		end

		local v4 = quickFX({
			FX = vfx.Blowup,
			Maid = object._maid,
			Anchor = CFrame.new(targetCFrame.Position) * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, v3, 0)
		})
		v4:ScaleTo(1.2)
		playAttachment(v4)
		local clone = vfx.WindDecal2:Clone()
		clone:ScaleTo(8)
		playMesh({
			Model = clone,
			EndT = 1,
			Anchor = v4:GetPivot() * CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, 1.5707963267948966),
			Info = TweenInfo.new(6, Enum.EasingStyle.Sine)
		})
		local clone2 = vfx.WindDecal2:Clone()
		clone2.Start.Decal.Color3 = Color3.new(
			raycastResult.Instance.Color.R * 3,
			raycastResult.Instance.Color.G * 3,
			raycastResult.Instance.Color.B * 3
		)
		clone2:ScaleTo(12)
		playMesh({
			Model = clone2,
			EndT = 1,
			Anchor = v4:GetPivot() * CFrame.new(0, 22, 0) * CFrame.Angles(
				0,
				math.rad((random:NextNumber(-360, 360))),
				1.5707963267948966
			),
			Info = TweenInfo.new(2, Enum.EasingStyle.Sine)
		})
		local clone3 = vfx.LingerMesh:Clone()
		clone3.Start.Decal.Color3 = Color3.new(
			raycastResult.Instance.Color.R * 3,
			raycastResult.Instance.Color.G * 3,
			raycastResult.Instance.Color.B * 3
		)
		clone3:ScaleTo(12)
		playMesh({
			Model = clone3,
			EndT = 1,
			Anchor = v4:GetPivot() * CFrame.new(0, 12, 0) * CFrame.Angles(
				0,
				math.rad((random:NextNumber(-360, 360))),
				0
			),
			Info = TweenInfo.new(4, Enum.EasingStyle.Quad)
		})
		local clone4 = vfx.Big:Clone()
		clone4.Start.Decal.Color3 = Color3.new(
			raycastResult.Instance.Color.R * 3,
			raycastResult.Instance.Color.G * 3,
			raycastResult.Instance.Color.B * 3
		)
		clone4:ScaleTo(1)
		playMesh({
			Model = clone4,
			EndT = 1,
			Anchor = v4:GetPivot() * CFrame.new(0, -80, 0) * CFrame.Angles(
				0,
				math.rad((random:NextNumber(-360, 360))),
				0
			),
			Info = TweenInfo.new(1, Enum.EasingStyle.Quad)
		})

		if v2 then
			lightingmanager.Trigger({
				Source = v4:GetPivot(),
				FadeInTime = 0,
				SustainTime = 0.3,
				FadeOutTime = 1.5,
				MaxDistance = 450,
				RequiresLineOfSight = true,
				LookSensitivity = 0.6,
				Instances = {
					{
						Class = "BloomEffect",
						Properties = {
							Intensity = 2,
							Size = 35,
							Threshold = 0.8
						}
					},
					{
						Class = "ColorCorrectionEffect",
						Properties = {
							Contrast = 1.5,
							Saturation = -0.5
						}
					}
				}
			})
		end

		local function YEA()
			local v5 = v4:GetPivot().Position - Vector3.new(0, random:NextNumber(-40, -20), 0)

			for _ = 1, 30 do
				local vector2 = Vector3.new(
					random:NextNumber(-1, 1),
					random:NextNumber(0.1, 1),
					random:NextNumber(-1, 1)
				)
				local v6 = {
					Speed = random:NextNumber(120, 150),
					Drag = 1,
					Spread = 75,
					Gravity = createVector(0, -5, 0),
					TurbulenceStrength = 350,
					LifeTime = random:NextNumber(1, 2.5)
				}
				Trail.Create(v5, vector2, vfx.NewTrail, v6)
				task.wait(0.01)
			end
		end

		task.wait(0.25)
		YEA()
	end

	task.spawn(LandEvent)
	wait(20)
	Clean() -- equivalent call inferred; original call site unknown
end

return Fall