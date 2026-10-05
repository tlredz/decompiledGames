local SliceFinish = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local _ = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

function SliceFinish.FirstEvent(p)
	print(p)
	local char = p.Char
	local target = p.Target
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetAnchor()
		local orientation, v2, v3 = humanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(target.Torso.Position) * CFrame.Angles(orientation, v2, v3)
	end

	local function FirstEvent()
		local v2 = object._maid:give(vfx["mrkewlnew2 MeshEmitter"]:Clone())
		v2:PivotTo(humanoidRootPart.CFrame * v2:GetAttribute("Offset"):Inverse())
		local v3 = MoonEmitter.new(v2)
		v3:Play()
		task.delay(0.05, function()
			v2.Parent = EFP
		end)
		v3:AddFrameEvent(function()
			local v4 = quickFX({
				FX = vfx.Slash1,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.Slash1:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v4)
			local firstSlashmesh = v2.VFX.FirstSlashmesh
			shared.vfx.emit(firstSlashmesh)
		end, 34)
		v3:AddFrameEvent(function()
			local v4 = quickFX({
				FX = vfx.BeamSlash,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.BeamSlash:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v4)
		end, 38)
		v3:AddFrameEvent(function()
			local KATANAWEAPON = char:FindFirstChild("#KATANAWEAPON")

			if KATANAWEAPON then
				local v4 = object._maid:give(vfx.spark:Clone())
				v4.Parent = KATANAWEAPON.Main
				shared.vfx.emit(v4)
			end
		end, 92)
		v3:AddFrameEvent(function()
			local v4 = quickFX({
				FX = vfx.windstart,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.windstart:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v4)
		end, 96)
		v3:AddFrameEvent(function()
			local KATANAWEAPON = char:FindFirstChild("#KATANAWEAPON")

			if KATANAWEAPON then
				local v4 = object._maid:give(vfx.Pre:Clone())
				v4.Parent = KATANAWEAPON.Main
				shared.vfx.emit(v4)
			end
		end, 102)
		v3:AddFrameEvent(function()
			local v4 = quickFX({
				FX = vfx.PreFull,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.PreFull:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v4)
		end, 126)
		v3:AddFrameEvent(function()
			local v4 = quickFX({
				FX = vfx.Impale1,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.Impale1:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v4)
		end, 147)
		v3:AddFrameEvent(function()
			local v6 = quickFX({
				FX = vfx.delaySlash,
				Maid = object._maid,
				Anchor = GetAnchor()
			})
			shared.vfx.emit(v6)
		end, 157)
		v3:AddFrameEvent(function()
			local v6 = quickFX({
				FX = vfx.SuperlSAt,
				Maid = object._maid,
				Anchor = GetAnchor()
			})
			shared.vfx.emit(v6)
		end, 265)
		v3:AddFrameEvent(function()
			local v6 = quickFX({
				FX = vfx.LastPre,
				Maid = object._maid,
				Anchor = GetAnchor()
			})
			shared.vfx.emit(v6)
		end, 310)
		v3:AddFrameEvent(function()
			local v4 = quickFX({
				FX = vfx.LastImpact,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.LastImpact:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v4)
		end, 327)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return SliceFinish