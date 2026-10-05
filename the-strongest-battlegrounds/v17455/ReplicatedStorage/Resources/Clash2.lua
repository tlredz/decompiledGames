local Clash2 = {}
local libraryNew = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local _ = game.Workspace.Camera
local new = CFrame.new
local angles = CFrame.Angles
local new2 = Vector3.new
local new3 = Color3.new
local rad = math.rad
local color = Color3.fromRGB(100, 87, 171)
local cframe = angles(0, 1.5707963267948966, 0)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) })
local tweenInfos = {}

local function getShardTI(duration)
	local tweenInfo = tweenInfos[duration]

	if not tweenInfo then
		tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine)
		tweenInfos[duration] = tweenInfo
	end

	return tweenInfo
end

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
local v = {
	Time = 0.25,
	EasingStyle = "Sine",
	Goal = {
		Transparency = numberSequence
	}
}

function Clash2.Engage(data)
	local char = data.Char
	local other = data.Other
	local _ = char.Humanoid
	local humanoidRootPart = char.HumanoidRootPart
	local head = char.Head
	local torso = char.Torso
	local rightArm = char["Right Arm"]
	local leftArm = char["Left Arm"]
	local humanoidRootPart2 = other.HumanoidRootPart
	local torso2 = other.Torso
	local Y = humanoidRootPart.Size.Y

	local function GetTorsoCF()
		local _, v2 = humanoidRootPart.CFrame:ToOrientation()
		return new(torso.Position) * angles(0, v2, 0)
	end

	local function EnableTrail(parent, waterPalm, duration)
		local clone = waterPalm.Attachment0:Clone()
		local clone2 = waterPalm.Attachment1:Clone()
		clone.Parent = parent
		clone2.Parent = parent
		local v2 = 2
		local clones = { clone, clone2 }

		for _, child in ipairs(waterPalm:GetChildren()) do
			if child.ClassName ~= "Trail" then
				continue
			end

			local clone3 = child:Clone()
			clone3.Attachment0 = clone
			clone3.Attachment1 = clone2
			clone3.Parent = parent
			v2 += 1
			clones[v2] = clone3
		end

		for i = 1, v2 do
			Debris:AddItem(clones[i], duration)
		end

		task.delay(duration, function()
			for i = 1, v2 do
				local v3 = clones[i]

				if v3.ClassName ~= "Trail" then
					continue
				end

				playTween(v3, v)
				Debris:AddItem(v3, 0.25)
			end
		end)
		return clones
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(10, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancon()
		if v3 or not (bind and bind.Parent and char.Parent) then
			v3 = true
			return false
		else
			return true
		end
	end

	local function Garou()
		task.spawn(function()
			EnableTrail(rightArm, script.Garou.WaterPalm, 3)
			EnableTrail(leftArm, script.Garou.WaterPalm, 3)
			dtwait(0.3)

			-- equivalent call inferred; original call site unknown
			if not cancon() then
				return
			end

			local FX = quickFX({
				FX = script.Garou.pe,
				Anchor = humanoidRootPart2.CFrame * new(0, 0, 2),
				Maid = object._maid
			})
			lifeScale({
				FX = FX,
				Scale = 1.5
			})
			playAttachment(FX)
		end)
	end

	task.spawn(function()
		EnableTrail(rightArm, script.Garou.WaterPalm, 3)
		EnableTrail(leftArm, script.Garou.WaterPalm, 3)
		dtwait(0.3)

		-- equivalent call inferred; original call site unknown
		if not cancon() then
			return
		end

		local FX = quickFX({
			FX = script.Garou.pe,
			Anchor = humanoidRootPart2.CFrame * new(0, 0, 2),
			Maid = object._maid
		})
		lifeScale({
			FX = FX,
			Scale = 1.5
		})
		playAttachment(FX)
	end)

	local function TP(data2)
		local start = data2.Start
		local v4 = data2.End
		local scale = data2.Scale or 1
		local time = data2.Time or random:NextNumber(0.07, 0.1)
		local v5 = object._maid:give(script.ShardSphere:Clone())
		local position = start.Position
		local position2 = v4.Position
		v5.CFrame = CFrame.lookAt(position, position2) * cframe
		v5.Parent = EFP
		v5.Color = color
		local v6 = random:NextNumber(0.5, 0.7) * scale
		v5.Size = new2(0.2, v6, v6)
		local v7 = (position - position2).Magnitude * 1.5
		local v8 = v7 * 0.5
		local tweenInfo2 = tweenInfos[time]

		if not tweenInfo2 then
			tweenInfo2 = TweenInfo.new(time, Enum.EasingStyle.Sine)
			tweenInfos[time] = tweenInfo2
		end

		TweenService:Create(v5, tweenInfo2, {
			Size = new2(v7, 0, 0),
			CFrame = v5.CFrame * new(v8, 0, 0)
		}):Play()
		Debris:AddItem(v5, time)
	end

	task.delay(2.3, function()
		-- equivalent call inferred; original call site unknown
		if not cancon() then
			return
		end

		local FX = quickFX({
			FX = script.Hit,
			Anchor = CFrame.lookAt(head.Position, humanoidRootPart2.Position),
			Maid = object._maid
		})
		lifeScale({
			FX = FX,
			Scale = 0.7
		})
		playAttachment(FX)
		dtwait(0.5)

		-- equivalent call inferred; original call site unknown
		if not cancon() then
			return
		end

		playAttachment((quickFX({
			FX = script.Hit,
			Anchor = CFrame.lookAt(head.Position, humanoidRootPart2.Position),
			Maid = object._maid
		})))
		dtwait(0.9)

		-- equivalent call inferred; original call site unknown
		if not cancon() then
			return
		end

		local cFrame = humanoidRootPart.CFrame
		local v6 = quickFX({
			FX = script.Catch,
			Anchor = cFrame * new(-1.5, -Y * 1.5, -1),
			Maid = object._maid
		})
		v6:ScaleTo(0.7)
		playAttachment(v6)
		local v7 = object._maid:give(Instance.new("Highlight"))
		v7.DepthMode = Enum.HighlightDepthMode.Occluded
		v7.FillTransparency = 0
		v7.FillColor = new3(1, 1, 1)
		v7.OutlineTransparency = 1
		v7.Parent = other
		TweenService:Create(v7, tweenInfo, {
			FillTransparency = 1
		}):Play()
		local FX2 = quickFX({
			FX = script.GrabFX,
			Anchor = cFrame * new(-3.5, 0, -1.8) * cframe,
			Maid = object._maid
		})
		FX2:ScaleTo(1.5)
		lifeScale({
			FX = FX2,
			Scale = 1
		})
		playAttachment(FX2)
	end)
	task.delay(1.2, function()
		-- equivalent call inferred; original call site unknown
		if not cancon() then
			return
		end

		local FX = quickFX({
			FX = script.FirstLand,
			Anchor = new(torso2.Position) * new(0, -Y * 1.5, 0),
			Maid = object._maid
		})
		lifeScale({
			FX = FX,
			Scale = 0.5
		})
		playAttachment(FX)
	end)
	local v4 = nil
	task.spawn(function()
		dtwait(1.5)

		-- equivalent call inferred; original call site unknown
		if not cancon() then
			return
		end

		local lastTime = tick()
		local renderStepped = RunService.RenderStepped

		while tick() - lastTime < 2.2 do
			-- equivalent call inferred; original call site unknown
			if not cancon() then
				break
			end

			local position = torso2.Position
			local v6

			if v4 then
				v6 = (v4 - position).Magnitude > 1 or false
			else
				v6 = true
				v4 = position
			end

			if v6 then
				local v7 = humanoidRootPart.CFrame * new(
					random:NextNumber(-10, 10),
					random:NextNumber(-4, 4),
					random:NextNumber(-10, 10)
				)
				TP({
					Start = v7,
					End = CFrame.lookAt(v4, position),
					Scale = 3,
					Time = 0.07
				})
				playAttachment((quickFX({
					FX = script.Part,
					Anchor = v7,
					Maid = object._maid
				})))

				for _ = 1, 3 do
					local clone = script.WindTime:Clone()
					clone:ScaleTo(random:NextNumber(0.2, 0.5))
					playMesh({
						Model = clone,
						T = 0.98,
						Anchor = v7 * new(0, random:NextNumber(0, 0.5), 0) * angles(
							rad((random:NextNumber(0, 360))),
							rad((random:NextNumber(0, 360))),
							(rad((random:NextNumber(0, 360))))
						),
						Info = TweenInfo.new(random:NextNumber(0.1, 0.2), Enum.EasingStyle.Sine)
					})
				end

				v4 = position
			end

			renderStepped:Wait()
		end
	end)
	task.wait(7)
	Clean() -- equivalent call inferred; original call site unknown
end

return Clash2