local Bite = {}
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

function Bite.FirstEvent(p)
	local data = p.Data
	local shark = data.Shark
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
	print(data)

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[17] = function()
				local v2 = quickFX({
					FX = vfx.jumnp,
					Maid = object._maid,
					Anchor = shark:GetPivot() * vfx.jumnp:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)

				for _, child in pairs(vfx.headparticles:GetChildren()) do
					local clone = child:Clone()
					game.Debris:AddItem(clone, 3)
					clone.Parent = shark.Head
				end

				playAttachment(shark.Head)
			end,
			[100] = function()
				local v2 = quickFX({
					FX = vfx.WaterSplash2,
					Maid = object._maid,
					Anchor = shark:GetPivot() * vfx.WaterSplash2:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[110] = function()
				local v2 = quickFX({
					FX = vfx.WaterSplash3,
					Maid = object._maid,
					Anchor = shark:GetPivot() * vfx.WaterSplash3:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Bite