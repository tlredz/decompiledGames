local MechCombat = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local _ = libraryNew.EFP
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
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)

function MechCombat.FirstEvent(p)
	local data = p.Data
	local mech = data.Mech
	print(mech)
	print(data)
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
			[30] = function()
				local v2 = quickFX({
					FX = vfx.Hit1,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.Hit1:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[80] = function()
				local v2 = quickFX({
					FX = vfx.Hit2,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.Hit2:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[122] = function()
				local v2 = quickFX({
					FX = vfx.Hit3,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.Hit3:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[187] = function()
				local v2 = quickFX({
					FX = vfx.Hit4,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.Hit4:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[196] = function()
				local v2 = quickFX({
					FX = vfx.floorhit1,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.floorhit1:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[336] = function()
				local v2 = quickFX({
					FX = vfx.Kick,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.Kick:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[360] = function()
				local v2 = quickFX({
					FX = vfx.floorhit2,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.floorhit2:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[412] = function()
				local v2 = quickFX({
					FX = vfx.Hit5,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.Hit5:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[478] = function()
				local v2 = quickFX({
					FX = vfx.BRO,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.BRO:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
				local v3 = quickFX({
					FX = vfx.BROENEBLE,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.BROENEBLE:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v3)
			end,
			[512] = function()
				local v2 = quickFX({
					FX = vfx.BRO2,
					Maid = object._maid,
					Anchor = mech:GetPivot() * vfx.BRO2:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return MechCombat