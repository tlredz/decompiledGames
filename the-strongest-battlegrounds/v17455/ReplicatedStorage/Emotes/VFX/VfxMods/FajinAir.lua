local FajinAir = {}
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
require(game.ReplicatedStorage.Resources.AfterImages)
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
require(game.ReplicatedStorage.Emotes.VFX.VfxMods.AwakenRedo)

function FajinAir.LandEvent(p)
	local char = p.Data.Char
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

	local function LandEvent()
		warn("here??")
	end

	task.spawn(LandEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

return FajinAir