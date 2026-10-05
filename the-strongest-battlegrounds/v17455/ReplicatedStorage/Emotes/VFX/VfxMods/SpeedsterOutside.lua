local SpeedsterOutside = {}
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
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)

function SpeedsterOutside.FirstEvent(p)
	local char = p.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local bind = p.Bind
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
	local v2 = object._maid:give(vfx.CloneTemplate:Clone())

	for _, child in pairs(v2:GetChildren()) do
		local child2 = char:FindFirstChild(child.Name)

		if not child2 then
			continue
		end

		local weld = Instance.new("Weld")
		weld.Part0 = child
		weld.Part1 = child2
		weld.Parent = child
	end

	v2.Parent = EFP
	object._maid:giveTask(bind:GetPropertyChangedSignal("Parent"):Connect(function()
		Clean() -- equivalent call inferred; original call site unknown
	end))

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[0] = function()
				if not bind.Parent then
					return
				end

				local handler = vfx.Handler
				object.Handler = quickFX({
					FX = handler,
					Maid = object._maid,
					Anchor = char:GetPivot() * handler:GetAttribute("Offset"):Inverse()
				}).Handler
				shared.vfx.emit(object.Handler.calm)
				shared.vfx.emit(v2.Head:FindFirstChild("eye"))
			end,
			[173] = function()
				if not bind.Parent then
					return
				end

				shared.vfx.emit(object.Handler.aura)
			end,
			[316] = function()
				if not bind.Parent then
					return
				end

				shared.vfx.emit(object.Handler.red)
			end,
			[326] = function()
				if not bind.Parent then
					return
				end

				shared.vfx.emit(v2["Left Leg"], v2["Right Arm"], v2["Right Leg"], v2.Torso, v2["Left Arm"])
				shared.vfx.emit(
					v2.Head.blackspec,
					v2.Head:FindFirstChild("blackfire"),
					v2.Head:FindFirstChild("blackfire"),
					v2.Head.blackfire,
					v2.Head:FindFirstChild("wave2"),
					v2.Head.wave2,
					v2.Head.wave,
					v2.Head:FindFirstChild("static"),
					v2.Head.static,
					v2.Head:FindFirstChild("splat"),
					v2.Head.splat,
					v2.Head.specs,
					v2.Head:FindFirstChild("spec"),
					v2.Head.spec,
					v2.Head:FindFirstChild("smoke"),
					v2.Head:FindFirstChild("smoke"),
					v2.Head.smoke,
					v2.Head.redfire,
					v2.Head.lighting,
					v2.Head.glow,
					v2.Head:FindFirstChild("fire"),
					v2.Head:FindFirstChild("fire"),
					v2.Head:FindFirstChild("fire"),
					v2.Head.fire,
					v2.Head.eyeflare,
					v2.Head:FindFirstChild("eyeflare")
				)
			end,
			[463] = function()
				if not bind.Parent then
					return
				end

				local holymoly = vfx.holymoly
				local v3 = quickFX({
					FX = holymoly,
					Maid = object._maid,
					Anchor = char:GetPivot() * holymoly:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v3)
			end,
			[739] = function()
				if not bind.Parent then
					return
				end

				local scream = vfx.scream
				local v3 = quickFX({
					FX = scream,
					Maid = object._maid,
					Anchor = char:GetPivot() * scream:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v3)
			end
		})
	end

	task.spawn(FirstEvent)
	wait(25)
	Clean() -- equivalent call inferred; original call site unknown
end

return SpeedsterOutside