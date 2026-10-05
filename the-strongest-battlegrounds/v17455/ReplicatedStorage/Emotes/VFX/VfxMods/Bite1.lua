local Bite1 = {}
local library = require(script.Parent.library)
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
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local _ = library.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)

function Bite1.FirstEvent(p)
	local shark = p.Data.Shark
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
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[13] = function()
				local v2 = quickFX({
					FX = vfx.bite1,
					Maid = object._maid,
					Anchor = shark:GetPivot() * vfx.bite1:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[48] = function()
				local v2 = quickFX({
					FX = vfx.bite1,
					Maid = object._maid,
					Anchor = shark:GetPivot() * vfx.bite1:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Bite1