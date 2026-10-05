local CyborgBurst = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local EFP = library.EFP
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

function CyborgBurst.FirstEvent(p)
	local char = p.Data.Char
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

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[4] = function()
				shared.vfx.emit(v2["Left Arm"].Attachment, v2["Right Arm"].Attachment)
			end,
			[6] = function()
				shared.vfx.emit(v2["Left Arm"].STAR, v2["Right Arm"].STAR)
			end,
			[8] = function()
				shared.vfx.emit(v2["Left Arm"].Attachment2, v2["Right Arm"].Attachment2)
			end,
			[27] = function()
				local bURST = vfx.bURST
				local v3 = quickFX({
					FX = bURST,
					Maid = object._maid,
					Anchor = char:GetPivot() * bURST:GetAttribute("Offset"):Inverse()
				})
				local v4 = object._maid:give(vfx.Start:Clone())
				v4.Part0 = char.Torso
				v4.Part1 = v3.Up2.Start
				v4.Parent = char.Torso
				local v5 = object._maid:give(vfx.End:Clone())
				v5.Part0 = char.Torso
				v5.Part1 = v3.Up2.End
				v5.Parent = char.Torso
				shared.vfx.emit(v3)
				shared.vfx.emit(v2["Right Arm"].xd, v2["Left Arm"].xd)
				v2.Torso.BURN.WorldCFrame *= CFrame.new(0, -8, 0.35)

				for _, emitter in pairs(v2.Torso.BURN:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:SetAttribute("EmitCount", emitter:GetAttribute("EmitCount") / 2.5)
					end
				end

				shared.vfx.emit(v2.Torso.BURN)
			end,
			[55] = function()
				local done = vfx.Done
				local anchor = char:GetPivot() * CFrame.new(0, 5.5, 0)
				playAttachment((quickFX({
					FX = done,
					Maid = object._maid,
					Anchor = anchor
				})))
			end
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return CyborgBurst