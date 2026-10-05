local createVector = vector.create
local FajinFX = {}
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local _ = library.LifeScale
local _ = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
require(game.ReplicatedStorage.Utility)
require(game.ReplicatedStorage.BoatTween)
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local thrown = game.Workspace.Thrown
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local script2 = script
local Vfxmodule = require(game.ReplicatedStorage.Resources.Vfxmodule)
local vFXassets = script2.VFXassets
local _ = vFXassets.FajinAnim
local Firstbake = require(vFXassets.Firstbake)
require(vFXassets.Secondbake)
local Thirdbake = require(vFXassets.Thirdbake)
local MESHFLIPBOOKS = require(vFXassets.MeshFlipbookstuff.MESHFLIPBOOKS)
local charge1Ids = MESHFLIPBOOKS.Charge1Ids
local twirlerIDS = MESHFLIPBOOKS.TwirlerIDS
local FajinAdditions = require(script.Parent.FajinAdditions)

local function Grounddecal(cFrame, duration, scalar)
	local clone = vFXassets.Groundburndecal:Clone()
	task.delay(8, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	clone.CFrame = cFrame * CFrame.new(0, -2.5, -40 * scalar)
	clone.Size *= scalar
	clone.Parent = thrown
	local v = {
		Transparency = 1,
		Color3 = Color3.new(0, 0, 0)
	}
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0)
	local tween = TweenService:Create(clone.Decal, tweenInfo, v)
	tween:Play()
	tween.Completed:Connect(function()
		Debris:AddItem(clone)
	end)
end

local function beamcres(cFrame, p, p2, p3)
	local clone = vFXassets.beamcres:Clone()
	task.delay(8, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	clone.CFrame = cFrame
	clone.Parent = thrown
	Vfxmodule.beamcrescent(clone, p2, 2 * p3, 0, p)
	Debris:AddItem(clone, p2 + 0.1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bodytrailfunc(torso)
	local clone = vFXassets.PlayerTrail.PAttach:Clone()
	task.delay(8, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	clone.Parent = torso
	return clone
end

local function WindBeams(parent, duration, p, p2)
	local clone = vFXassets.WindBeamsDash.Core:Clone()
	task.delay(8, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	local model = Instance.new("Model")
	task.delay(8, function()
		if model and model.Parent then
			model:Destroy()
		end
	end)
	clone.Parent = model
	model:ScaleTo(p * p2)
	Debris:AddItem(model, 0.001)
	clone.Parent = parent
	TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0), {
		CFrame = clone.CFrame * CFrame.new(0, 0, 10)
	}):Play()
	Vfxmodule.WindBeams(clone, duration)
	Debris:AddItem(clone, duration + 0.2)
end

local function BeamWindBeams(cFrame, p, p2, scalar)
	local clone = vFXassets.WindBeamFired:Clone()
	task.delay(8, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	clone.CFrame = cFrame
	local model = Instance.new("Model")
	clone.Parent = model
	model:ScaleTo(p2 * scalar)
	Debris:AddItem(model, 0.001)
	clone.Parent = thrown
	Vfxmodule.WindBeams(clone, p)
end

local function FiringTwirler(p, scalar)
	local clone = vFXassets.charge:Clone()
	task.delay(8, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	clone.CFrame = p * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0) * CFrame.new(0, 42 * scalar, 0)
	clone.Mesh.Scale = clone.Mesh.Scale * scalar
	clone.Parent = thrown
	Vfxmodule.textureflipbook(clone.Decal, twirlerIDS, 0.78)
end

local function LegsEmit(folder)
	local clone = vFXassets.LEGVFX:Clone()
	local clone2 = vFXassets.LEGVFX:Clone()
	local result = {}

	for _, v in pairs({ clone, clone2 }) do
		local v2 = v
		task.delay(8, function()
			if v2 and v2.Parent then
				v2:Destroy()
			end
		end)
	end

	local children = clone:GetChildren()
	local children2 = clone2:GetChildren()
	local leftLeg = folder:FindFirstChild("Left Leg")
	local rightLeg = folder:FindFirstChild("Right Leg")

	for _, v in children do
		v.Parent = leftLeg
		table.insert(result, v)
	end

	for _, v in children2 do
		v.Parent = rightLeg
		table.insert(result, v)
	end

	return result
end

local function ArmsEmit(folder, duration)
	local leftArm = folder:FindFirstChild("Left Arm")
	local rightArm = folder:FindFirstChild("Right Arm")
	local clone = vFXassets.ARMVFX.ARMVFX:Clone()
	local clone2 = vFXassets.ARMVFX.ARMVFX:Clone()
	task.delay(8, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	task.delay(8, function()
		if clone2 and clone2.Parent then
			clone2:Destroy()
		end
	end)
	task.spawn(function()
		clone.Parent = leftArm:FindFirstChild("LeftGripAttachment")
		clone2.Parent = rightArm:FindFirstChild("RightGripAttachment")
		task.wait(duration)
		clone:GetDescendants()
		clone:GetDescendants()
		clone.Trail.Enabled = false
		clone2.Trail.Enabled = false
	end)
end

local function ChargeGroundRocks(p, p2, p3, duration)
	local raycastBelow = Vfxmodule.RaycastBelow(p, p2)
	local result = {}
	local tweens = {}
	task.spawn(function()
		for _ = 1, p3 do
			local v = math.random(-10, 10)
			local v2 = math.random(-10, 10)
			local v3 = math.rad((math.random(-360, 360)))
			local v4 = math.rad((math.random(-360, 360)))
			local v5 = math.rad((math.random(-360, 360)))
			local v6 = math.random(30, 200) / 100
			local v7 = math.random(250, 1000) / 100
			local v8 = math.random(250, 320) / 100
			local part = Instance.new("Part")
			task.delay(8, function()
				if part and part.Parent then
					part:Destroy()
				end
			end)
			part.Parent = thrown
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(0.01, 0.01, 0.01)
			part.Material = raycastBelow.Material
			part.Color = raycastBelow.Instance.Color
			part.CFrame = CFrame.new(raycastBelow.Position + Vector3.new(v, 0, v2))
			local tween = TweenService:Create(
				part,
				TweenInfo.new(v8, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = part.CFrame * CFrame.new(0, v7, 0) * CFrame.Angles(v3, v4, v5),
					Size = Vector3.new(v6, v6, v6)
				}
			)
			tween:Play()
			table.insert(result, part)
			table.insert(tweens, tween)
			task.wait(duration)
		end
	end)
	return result, tweens
end

function FajinFX.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local charging = data.Charging
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		task.spawn(function()
			FajinAdditions.FirstEvent({
				Char = char,
				Charging = charging
			})
		end)
		local v2 = nil
		local folder = char
		local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
		local torso = folder:FindFirstChild("Torso")
		folder:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
		local v3 = true
		ArmsEmit(folder, 1.05)
		task.delay(6, function()
			v2 = nil
			v3 = nil
		end)
		local children = vFXassets.ChargingTrailParts:GetChildren()
		local count = #children
		local children2 = vFXassets.BeamCrescents:GetChildren()
		local count2 = #children2
		local random = math.random
		local rad = math.rad
		local new = CFrame.new
		local angles = CFrame.Angles
		local new2 = Vector3.new
		local new3 = TweenInfo.new
		local cubic = Enum.EasingStyle.Cubic
		local quad = Enum.EasingStyle.Quad
		local circular = Enum.EasingStyle.Circular
		local out = Enum.EasingDirection.Out
		local flag = false
		task.delay(10, function()
			flag = true
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isAlive()
			return not flag and charging and charging.Parent
		end

		local function BezierCharge(cframe: CFrame, p2)
			local position = cframe.Position
			task.spawn(function()
				while v3 == true do
					-- equivalent call inferred; original call site unknown
					if not isAlive() then
						break
					end

					local v4 = children[random(1, count)]
					Vfxmodule.beziertrailpart(v4, position, 0.3, 25)
					task.wait(p2 * (random(100, 150) * 0.01))
				end
			end)
		end

		local function chargingbeams(p2, duration)
			task.spawn(function()
				while v2 == true do
					-- equivalent call inferred; original call site unknown
					if not isAlive() then
						break
					end

					if random(1, 2) == 2 then
						task.wait(duration)
					else
						local clone = children2[random(1, count2)]:Clone()
						task.delay(8, function()
							if clone and clone.Parent then
								clone:Destroy()
							end
						end)
						clone.Transparency = 1
						game.Debris:AddItem(clone, 2)
						local cFrame3 = p2 * angles(
							rad((random(-6, 6))),
							rad((random(-360, 360))),
							(rad((random(-6, 6))))
						) * new(0, -1, 0)
						clone.CFrame = cFrame3
						clone.Parent = thrown
						local v13 = random(600, 1000) * 0.001
						local v14 = {
							CFrame = cFrame3 * angles(0, rad((random(-180, 180))), 0) * new(
								0,
								random(150, 250) * 0.01,
								0
							)
						}
						TweenService:Create(clone, new3(v13, cubic, out, 0, false, 0), v14):Play()
						Vfxmodule.BeamScaleTween(clone, random(500, 700) * 0.001, v13)
						local count3 = 0
						local beams = {}

						for _, beam in clone:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							count3 += 1
							beams[count3] = beam
						end

						local v17 = v13 * 0.49
						local v18 = v13 * 0.49
						local v19 = v13 * 0.5

						for i = 1, count3 do
							Vfxmodule.tweenbeamtransparency(beams[i], v17, 0.5)
						end

						task.spawn(function()
							task.wait(v19)

							for i = 1, count3 do
								Vfxmodule.tweenbeamtransparency(beams[i], v18, 1)
							end
						end)
						task.wait(duration)
					end
				end
			end)
		end

		local function Chargemeshfb1(p2, duration)
			task.spawn(function()
				while v2 == true do
					-- equivalent call inferred; original call site unknown
					if not isAlive() then
						break
					end

					local v4 = object._maid:give(vFXassets.ChargingMeshfb:Clone())
					task.delay(8, function()
						if v4 and v4.Parent then
							v4:Destroy()
						end
					end)
					local cFrame3 = p2 * new(0, -2.6, 0)
					v4.CFrame = cFrame3
					v4.Parent = thrown
					local v7 = random(200, 300) * 0.01
					local v8 = random(300, 400) * 0.01
					local v9 = random(750, 1000) * 0.001
					local tweenInfo = new3(v9, quad, out, 0, false, 0)
					TweenService:Create(v4, tweenInfo, {
						CFrame = cFrame3 * angles(0, rad((random(-140, 140))), 0) * new(0, 1.5, 0)
					}):Play()
					TweenService:Create(v4.Mesh, tweenInfo, {
						Scale = new2(v7, v8, v7)
					}):Play()
					TweenService:Create(v4.Decal, tweenInfo, {
						Transparency = 1
					}):Play()
					Vfxmodule.textureflipbook(v4.Decal, charge1Ids, v9)
					Debris:AddItem(v4, v9 + 0.001)
					task.wait(duration)
				end
			end)
		end

		Vfxmodule.HighlightTween(
			folder,
			Color3.fromRGB(0, 0, 0),
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(0, 0, 0),
			0.7,
			0
		)
		Firstbake(humanoidRootPart.CFrame * new(0, 17, 0), thrown)
		local folder2 = object._maid:give(vFXassets.DashChargeEmit:Clone())
		task.delay(8, function()
			if folder2 and folder2.Parent then
				folder2:Destroy()
			end
		end)
		folder2.CFrame = humanoidRootPart.CFrame
		folder2.Parent = thrown
		local descendants = folder2:GetDescendants()
		local count3 = 0
		local emitters = {}

		for i = 1, #descendants do
			local emitter = descendants[i]

			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			count3 += 1
			emitters[count3] = emitter
		end

		local raycastBelow = Vfxmodule.RaycastBelow(humanoidRootPart.CFrame, folder:GetDescendants())
		Vfxmodule.recolor(folder2.Recolorable, raycastBelow.Instance.Color)
		Vfxmodule.EmitAttributes(folder2)
		v2 = true

		local function ChargingSwirl(p2, duration)
			task.spawn(function()
				while v2 == true do
					-- equivalent call inferred; original call site unknown
					if not isAlive() then
						break
					end

					local clone = vFXassets.ChargingSwirl1:Clone()
					task.delay(8, function()
						if clone and clone.Parent then
							clone:Destroy()
						end
					end)
					local cFrame3 = p2 * angles(0, rad((random(-360, 360))), 0) * new(0, -2.5, 0)
					clone.CFrame = cFrame3
					clone.Parent = thrown
					local v9 = random(400, 800) * 0.001
					TweenService:Create(clone, new3(v9, circular, out, 0, false, 0), {
						Size = new2(0, random(300, 500) * 0.01, 0),
						CFrame = cFrame3 * angles(
							rad((random(-5, 5))),
							rad((random(-360, 360))),
							(rad((random(-5, 5))))
						),
						Transparency = 0.4
					}):Play()
					Debris:AddItem(clone, v9 + 0.05)
					task.wait(duration)
				end
			end)
		end

		local cFrame = humanoidRootPart.CFrame
		local v4 = 0.25
		task.spawn(function()
			while v2 == true do
				-- equivalent call inferred; original call site unknown
				if not isAlive() then
					break
				end

				local clone = vFXassets.ChargingSwirl1:Clone()
				task.delay(8, function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				local cFrame3 = cFrame * angles(0, rad((random(-360, 360))), 0) * new(0, -2.5, 0)
				clone.CFrame = cFrame3
				clone.Parent = thrown
				local v10 = random(400, 800) * 0.001
				TweenService:Create(clone, new3(v10, circular, out, 0, false, 0), {
					Size = new2(0, random(300, 500) * 0.01, 0),
					CFrame = cFrame3 * angles(rad((random(-5, 5))), rad((random(-360, 360))), (rad((random(-5, 5))))),
					Transparency = 0.4
				}):Play()
				Debris:AddItem(clone, v10 + 0.05)
				task.wait(v4)
			end
		end)
		local position = torso.CFrame.Position
		local v5 = 0.13
		task.spawn(function()
			while v3 == true do
				-- equivalent call inferred; original call site unknown
				if not isAlive() then
					break
				end

				local v6 = children[random(1, count)]
				Vfxmodule.beziertrailpart(v6, position, 0.3, 25)
				task.wait(v5 * (random(100, 150) * 0.01))
			end
		end)
		local cFrame2 = humanoidRootPart.CFrame
		local v6 = 0.22
		task.spawn(function()
			while v2 == true do
				-- equivalent call inferred; original call site unknown
				if not isAlive() then
					break
				end

				local v7 = object._maid:give(vFXassets.ChargingMeshfb:Clone())
				task.delay(8, function()
					if v7 and v7.Parent then
						v7:Destroy()
					end
				end)
				local cFrame3 = cFrame2 * new(0, -2.6, 0)
				v7.CFrame = cFrame3
				v7.Parent = thrown
				local v10 = random(200, 300) * 0.01
				local v11 = random(300, 400) * 0.01
				local v12 = random(750, 1000) * 0.001
				local tweenInfo = new3(v12, quad, out, 0, false, 0)
				TweenService:Create(v7, tweenInfo, {
					CFrame = cFrame3 * angles(0, rad((random(-140, 140))), 0) * new(0, 1.5, 0)
				}):Play()
				TweenService:Create(v7.Mesh, tweenInfo, {
					Scale = new2(v10, v11, v10)
				}):Play()
				TweenService:Create(v7.Decal, tweenInfo, {
					Transparency = 1
				}):Play()
				Vfxmodule.textureflipbook(v7.Decal, charge1Ids, v12)
				Debris:AddItem(v7, v12 + 0.001)
				task.wait(v6)
			end
		end)
		local v7 = humanoidRootPart.CFrame * new(0, -2, 0)
		local v8 = 0.35
		task.spawn(function()
			while v2 == true do
				-- equivalent call inferred; original call site unknown
				if not isAlive() then
					break
				end

				if random(1, 2) == 2 then
					task.wait(v8)
				else
					local clone = children2[random(1, count2)]:Clone()
					task.delay(8, function()
						if clone and clone.Parent then
							clone:Destroy()
						end
					end)
					clone.Transparency = 1
					game.Debris:AddItem(clone, 2)
					local cFrame3 = v7 * angles(rad((random(-6, 6))), rad((random(-360, 360))), (rad((random(-6, 6))))) * new(
						0,
						-1,
						0
					)
					clone.CFrame = cFrame3
					clone.Parent = thrown
					local v18 = random(600, 1000) * 0.001
					local v19 = {
						CFrame = cFrame3 * angles(0, rad((random(-180, 180))), 0) * new(0, random(150, 250) * 0.01, 0)
					}
					TweenService:Create(clone, new3(v18, cubic, out, 0, false, 0), v19):Play()
					Vfxmodule.BeamScaleTween(clone, random(500, 700) * 0.001, v18)
					local count4 = 0
					local beams = {}

					for _, beam in clone:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						count4 += 1
						beams[count4] = beam
					end

					local v22 = v18 * 0.49
					local v23 = v18 * 0.49
					local v24 = v18 * 0.5

					for i = 1, count4 do
						Vfxmodule.tweenbeamtransparency(beams[i], v22, 0.5)
					end

					task.spawn(function()
						task.wait(v24)

						for i = 1, count4 do
							Vfxmodule.tweenbeamtransparency(beams[i], v23, 1)
						end
					end)
					task.wait(v8)
				end
			end
		end)
		local legsEmit = LegsEmit(folder)
		local v10 = nil

		local function finish()
			if not v10 then
				v10 = true
				v2 = nil
				v3 = nil

				if legsEmit then
					for i = 1, #legsEmit do
						local v11 = legsEmit[i]

						if v11 and v11.Parent then
							v11:Destroy()
						end
					end
				end

				if emitters then
					for i = 1, count3 or 0 do
						local v11 = emitters[i]

						if v11 and v11.Parent then
							v11.Enabled = false
						end
					end
				end
			end
		end

		task.delay(10, finish)

		if charging then
			object._maid:give(charging.Destroying:Once(finish))
		end
	end

	task.spawn(FirstEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function FajinFX.DashEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
	local anchor = data.Anchor
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DashEvent()
		task.spawn(function()
			FajinAdditions.DashEvent({
				Char = char
			})
		end)
		local v2 = true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Windfront(p2, duration)
			task.spawn(function()
				while v2 == true do
					local v3 = object._maid:give(vFXassets.WindMesh:Clone())
					task.delay(8, function()
						if v3 and v3.Parent then
							v3:Destroy()
						end
					end)
					v3.CFrame = p2.CFrame * CFrame.new(0, 0, 5) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-360, 360))),
						0
					)
					v3.Parent = thrown
					local v5 = math.random(800, 1000) / 100
					local v6 = math.random(3000, 4000) / 100
					local tweenInfo = TweenInfo.new(
						0.5,
						Enum.EasingStyle.Circular,
						Enum.EasingDirection.Out,
						0,
						false,
						0
					)
					local v7 = {
						CFrame = v3.CFrame * CFrame.Angles(0, math.rad((math.random(-100, 100))), 0) * CFrame.new(
							0,
							-20,
							0
						)
					}
					local v8 = {
						Scale = Vector3.new(v5, v6, v5)
					}
					local tween = TweenService:Create(v3, tweenInfo, v7)
					local tween2 = TweenService:Create(v3.Mesh, tweenInfo, v8)
					local tween3 = TweenService:Create(v3.Decal, tweenInfo, {
						Transparency = 1
					})
					tween:Play()
					tween2:Play()
					tween3:Play()
					task.wait(duration)
				end
			end)
		end

		Windfront(primaryPart, 0.05) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			task.wait(0.4)
			v2 = false
		end)
		local v5 = object._maid:give(vFXassets.DashVFX:Clone())
		task.delay(8, function()
			if v5 and v5.Parent then
				v5:Destroy()
			end
		end)
		v5.Parent = thrown
		v5.CFrame = anchor
		Vfxmodule.RaycastBelow(anchor, char:GetDescendants())
		Vfxmodule.EmitAttributes(v5)
		local v6 = object._maid:give(bodytrailfunc(char:FindFirstChild("Torso")))
		task.delay(8, function()
			if v6 and v6.Parent then
				v6:Destroy()
			end
		end)
		game.Debris:AddItem(v6, 0.8)
	end

	task.spawn(DashEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function FajinFX.BlastEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local scalar = data.scalar

	local function BlastEvent()
		local primaryPart2 = primaryPart
		Thirdbake(primaryPart2.CFrame * CFrame.new(0, 0, -55), thrown, scalar)
		local cFrame = primaryPart2.CFrame
		local v3 = -50 * scalar
		local clone = vFXassets.beamcres:Clone()
		task.delay(8, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
		clone.CFrame = cFrame
		clone.Parent = thrown
		Vfxmodule.beamcrescent(clone, 0.4, 2 * scalar, 0, v3)
		Debris:AddItem(clone, 0.5)
		local clone2 = vFXassets.FajinHIT:Clone()
		task.delay(8, function()
			if clone2 and clone2.Parent then
				clone2:Destroy()
			end
		end)
		local raycastBelow = Vfxmodule.RaycastBelow(primaryPart2.CFrame, char:GetDescendants())
		Vfxmodule.recolor(clone2.Recolorable, raycastBelow.Instance.Color)
		Vfxmodule.recolor(clone2.Smokesandstuff, raycastBelow.Instance.Color)
		clone2.Parent = thrown
		Vfxmodule.Modelscale(clone2, scalar)
		clone2.CFrame = primaryPart2.CFrame * CFrame.new(0, 0, -3 * scalar)

		if char ~= game.Players.LocalPlayer.Character then
			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
					emitter:SetAttribute("EmitCount", emitter:GetAttribute("EmitCount") / 1.35)
				end
			end
		end

		Vfxmodule.EmitAttributes(clone2)
		BeamWindBeams(primaryPart2.CFrame, 2, 2.5, data.scalar)
		FiringTwirler(primaryPart2.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0), data.scalar)
		Grounddecal(primaryPart2.CFrame, 4.1, scalar)
	end

	task.spawn(BlastEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

return FajinFX