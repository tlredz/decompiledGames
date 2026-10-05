local createVector = vector.create
local GunWall = {}
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
local raiseZIndex = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
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
local ZLib = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib)
local Crater = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib.Crater)

function GunWall.FirstEvent(p)
	local data = p.Data
	local part = data.part
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
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
		ZLib.Crater.GroundRocks({
			origin = humanoidRootPart.Position,
			direction = humanoidRootPart.CFrame.LookVector * 5,
			amount = 4,
			radius = 6,
			config = {
				lingerTime = NumberRange.new(1, 1.6)
			},
			size = createVector(3, 0.75, 1.5)
		})
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.Map }
		local raycastResult = game.Workspace:Raycast(
			humanoidRootPart.CFrame.Position,
			humanoidRootPart.CFrame.LookVector * 5,
			raycastParams
		)

		if raycastResult then
			local orientation, v2, v3 = humanoidRootPart.CFrame:ToOrientation()
			Crater.FlyingRocks({
				Origin = CFrame.new(raycastResult.Position) * CFrame.Angles(orientation, v2, v3),
				Direction = "Back",
				Amount = random:NextNumber(2, 3) * 4,
				MinSize = createVector(0.35, 0.35, 0.35),
				MaxSize = createVector(0.8, 0.8, 0.8),
				SpeedMin = 44,
				SpeedMax = 89,
				SpreadAngle = 83,
				Lifetime = 2,
				Gravity = workspace.Gravity,
				Drag = 0.2,
				Bounciness = 0.5,
				Friction = 0.4,
				MaxBounces = 4,
				MinSpeed = 5,
				FadeTime = 0.5,
				LandSide = "up",
				Parent = workspace:FindFirstChild("Thrown"),
				done = function(anchor)
					playAttachment((quickFX({
						FX = vfx.SmokeBoom,
						Maid = object._maid,
						Anchor = anchor
					})))
				end
			})
		end

		local clone = vfx.Ring:Clone()
		clone:ScaleTo(0.4)
		playMesh({
			Model = clone,
			T = 0,
			EndT = 1,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0),
			Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
		})
		local v2 = object._maid:give(Instance.new("Highlight"))
		v2.FillTransparency = 0
		v2.OutlineTransparency = 1
		v2.DepthMode = Enum.HighlightDepthMode.Occluded
		v2.FillColor = Color3.fromRGB(255, 255, 255)
		v2.Parent = victim
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()
		game.Debris:AddItem(v2, 0.05)
		local folder = quickFX({
			FX = vfx.WallSlam,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		})
		folder:ScaleTo(1)

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant.Name == "Burst" or descendant.Name == "Burstfall" then
				descendant.Color = ColorSequence.new(part.Color)
				print("ADjusted")
			else
				print(descendant.Name)
			end
		end

		playAttachment(folder)
		task.wait(0.4)

		local function shoot()
			local v3 = random:NextNumber(0.8, 1.2) * 0.8
			local clone2 = vfx.Shoot:Clone()
			clone2:PivotTo(char:GetPivot() * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0))
			clone2.Parent = EFP
			game.Debris:AddItem(clone2, 3)
			lifeScale({
				FX = clone2,
				Scale = 0.7
			})
			playAttachment(clone2)
			playAttachment(clone2)
			clone2:ScaleTo(v3)
			raiseZIndex({
				FX = clone2,
				Count = 1
			})
			print(clone2)
			local folder2 = quickFX({
				FX = vfx.Shootslam,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
			})
			folder2:ScaleTo(1.5)

			for _, descendant in pairs(folder2:GetDescendants()) do
				if not (descendant.Name == "Burst" or descendant.Name == "Burstfall") then
					continue
				end

				descendant.Color = ColorSequence.new(part.Color)
				print("ADjusted")
			end

			playAttachment(folder2)
			lifeScale({
				FX = folder2,
				Scale = 0.1
			})
			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Include
			raycastParams2.FilterDescendantsInstances = { game.Workspace.Map }
			local raycastResult2 = game.Workspace:Raycast(
				humanoidRootPart.CFrame.Position,
				humanoidRootPart.CFrame.LookVector * 5,
				raycastParams2
			)

			if raycastResult2 then
				local orientation, v4, v5 = humanoidRootPart.CFrame:ToOrientation()
				Crater.FlyingRocks({
					Origin = CFrame.new(raycastResult2.Position) * CFrame.Angles(orientation, v4, v5),
					Direction = "Back",
					Amount = random:NextNumber(2, 3),
					MinSize = createVector(0.35, 0.35, 0.35),
					MaxSize = createVector(0.8, 0.8, 0.8),
					SpeedMin = 33,
					SpeedMax = 66.75,
					SpreadAngle = 83,
					Lifetime = 2,
					Gravity = workspace.Gravity,
					Drag = 0.2,
					Bounciness = 0.5,
					Friction = 0.4,
					MaxBounces = 4,
					MinSpeed = 5,
					FadeTime = 0.5,
					LandSide = "up",
					Parent = workspace:FindFirstChild("Thrown"),
					done = function(anchor)
						playAttachment((quickFX({
							FX = vfx.SmokeBoom,
							Maid = object._maid,
							Anchor = anchor
						})))
					end
				})
			end

			local pointLight = Instance.new("PointLight")
			pointLight.Brightness = 5 * v3
			pointLight.Color = Color3.new(1, 0.623529, 0.0980392)
			pointLight.Range = 10 * v3
			pointLight.Parent = clone2.PrimaryPart
			game.Debris:AddItem(pointLight, 0.05)
			task.delay(0.025, function()
				local highlight = Instance.new("Highlight")
				highlight.FillTransparency = 0
				highlight.OutlineTransparency = 1
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = Color3.new(1, 0, 0)
				highlight.Parent = victim
				TweenService:Create(highlight, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
					FillTransparency = 1
				}):Play()
				game.Debris:AddItem(highlight, 0.05)
			end)
		end

		for _ = 1, 4 do
			shoot()
			task.wait(0.15)
		end
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GunWall.HitEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim
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

	local function HitEvent()
		local v2 = quickFX({
			FX = vfx.Hit2,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0.5, -1, -1) * CFrame.Angles(
				0.4363323129985824,
				0,
				3.9269908169872414
			) * CFrame.new(0, -1, 0)
		})
		v2:ScaleTo(1.3)
		playAttachment(v2)
		playAttachment((quickFX({
			FX = vfx.Hit3,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 0)
		})))
		local clone = vfx.Ring:Clone()
		clone:ScaleTo(0.35)
		playMesh({
			Model = clone,
			T = 0.9,
			EndT = 1,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 2, 1) * CFrame.Angles(0, 0, -2.356194490192345),
			Info = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
		})
	end

	task.spawn(HitEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GunWall.SpinEvent(p)
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim
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

	local function SpinEvent()
		local folder = quickWeld({
			FX = vfx.DatSpin,
			Maid = object._maid,
			P = char.Torso
		})
		folder:ScaleTo(1.2)

		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local transparency = beam.Transparency
			beam.Transparency = NumberSequence.new(1)
			playTween(beam, {
				Time = 0.1,
				EasingStyle = "Sine",
				Goal = {
					Transparency = transparency
				}
			})
		end

		task.wait(0.4)

		for _, beam in pairs(folder:GetDescendants()) do
			if beam:IsA("Beam") then
				playTween(beam, {
					Time = 0.2,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new(1)
					}
				})
			end
		end

		able({
			FX = folder,
			On = false
		})
	end

	task.spawn(SpinEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GunWall.ChargeEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
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

	local function ChargeEvent()
		local FX = object._maid:give(vfx.Enabled:Clone())
		FX.Parent = char.Deagle.Weapon
		raiseZIndex({
			FX = FX,
			Count = 3
		})
		able({
			FX = FX,
			On = true
		})
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 0
		pointLight.Color = Color3.new(1, 0.623529, 0.0980392)
		pointLight.Range = 6
		pointLight.Parent = char.Deagle.Weapon
		game.Debris:AddItem(pointLight, 1.05)
		TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Brightness = 1
		}):Play()
		task.wait(0.25)
		pointLight:Destroy()
		able({
			FX = FX,
			On = false
		})
		FX:Destroy()
		local v3 = random:NextNumber(0.8, 1.2) * 1.1
		local clone = vfx.Shoot:Clone()
		clone:PivotTo(char:GetPivot() * CFrame.new(0, 1, -1) * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
			-0.2617993877991494,
			0,
			0
		))
		clone.Parent = EFP
		game.Debris:AddItem(clone, 3)
		lifeScale({
			FX = clone,
			Scale = 1
		})
		playAttachment(clone)
		playAttachment(clone)
		clone:ScaleTo(v3)
		raiseZIndex({
			FX = clone,
			Count = 1
		})
		local pointLight2 = Instance.new("PointLight")
		pointLight2.Brightness = 5 * v3
		pointLight2.Color = Color3.new(1, 0.623529, 0.0980392)
		pointLight2.Range = 10 * v3
		pointLight2.Parent = clone.PrimaryPart
		game.Debris:AddItem(pointLight2, 0.05)
		task.delay(0.025, function()
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.new(1, 0, 0)
			highlight.Parent = victim
			TweenService:Create(highlight, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
				FillTransparency = 1
			}):Play()
			game.Debris:AddItem(highlight, 0.05)
		end)
		local v4 = quickFX({
			FX = vfx.ShootFloor,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(2, -humanoidRootPart.Size.Y * 1.4, 0) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
		})
		v4:ScaleTo(1)
		playAttachment(v4)
		local clone2 = vfx.Ring2:Clone()
		clone2:ScaleTo(0.25)
		playMesh({
			Model = clone2,
			T = 0.5,
			EndT = 1,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(0, 0, 0.7853981633974483),
			Info = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
		})
	end

	task.spawn(ChargeEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return GunWall