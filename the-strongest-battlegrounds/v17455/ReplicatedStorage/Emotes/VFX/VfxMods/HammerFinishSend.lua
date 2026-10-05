local HammerFinishSend = {}
local library = require(script.Parent.library)
local playAttachment = library.PlayAttachment
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
local lifeScale = library.LifeScale
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function HammerFinishSend.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local victim = data.Victim
	local _ = char.HumanoidRootPart
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
		local HammerReal = require(script.Parent.HammerReal)
		HammerReal({
			Char = char,
			Victim = victim
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function HammerFinishSend.RipEvent(p)
	local data = p.Data
	local char = data.Char
	local _ = data.Victim
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

	local function RipEvent()
		local FX = quickFX({
			FX = vfx.TinyHit,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)
		})
		lifeScale({
			FX = FX,
			Scale = 1
		})
		FX:ScaleTo(1)
		playAttachment(FX)
		local v3 = quickFX({
			FX = vfx.Impact,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)
		})
		v3:ScaleTo(1)
		playAttachment(v3)
	end

	task.spawn(RipEvent)
	wait(5)
	Clean() -- equivalent call inferred; original call site unknown
end

return HammerFinishSend