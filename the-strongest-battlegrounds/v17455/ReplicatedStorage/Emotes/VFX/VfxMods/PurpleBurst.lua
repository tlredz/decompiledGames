local PurpleBurst = {}
local libraryNew = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew)
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
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

function PurpleBurst.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local dragon = data.Dragon
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
	local v2 = object._maid:give(vfx["SuiryuAntiTeam1 MeshEmitter"]:Clone())
	v2:PivotTo(humanoidRootPart.CFrame * v2:GetAttribute("Offset"):Inverse())
	local v3 = MoonEmitter.new(v2)
	v3:Play()
	v2.Parent = EFP
	local v4 = {}

	for _, descendant in pairs(dragon:GetDescendants()) do
		if descendant:IsA("BasePart") then
			v4[descendant] = descendant.Transparency
			descendant.Transparency = 1
		elseif descendant:IsA("ParticleEmitter") then
			v4[descendant] = descendant.Enabled
			descendant.Enabled = false
		end
	end

	task.delay(0.3, function()
		for part, v5 in pairs(v4) do
			if part:IsA("BasePart") then
				part.Transparency = v5
			else
				part.Enabled = v5
			end
		end
	end)

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[21] = function()
				local spinModel = vfx.SpinModel
				local particle = quickFX({
					FX = spinModel,
					Maid = object._maid,
					Anchor = char:GetPivot() * spinModel:GetAttribute("Offset"):Inverse()
				})
				task.spawn(function()
					local lastTime = tick()
					local v6 = 0

					while tick() - lastTime < 1 do
						v6 -= 5
						particle:PivotTo(char:GetPivot() * CFrame.Angles(0, math.rad(v6), 0) * spinModel:GetAttribute("Offset"):Inverse())
						task.wait(0.01)
					end
				end)
				libraryNew.ChangeParticleColor({
					Particle = particle,
					IsSmoke = true
				})
				shared.vfx.emit(particle)
				shared.vfx.emit(dragon.RootPart.Root.UpperMouth.Attachment)
			end,
			[41] = function()
				libraryNew.ChangeParticleColor({
					Particle = v3.Model.CframeImpact,
					IsSmoke = true
				})
				shared.vfx.emit(v3.Model.CframeImpact:FindFirstChild("smoke"))
			end,
			[48] = function()
				shared.vfx.emit(v3.Model.CframeImpact.xd)
			end,
			[50] = function()
				local burst = vfx.Burst
				local particle = quickFX({
					FX = burst,
					Maid = object._maid,
					Anchor = char:GetPivot() * burst:GetAttribute("Offset"):Inverse()
				})
				libraryNew.ChangeParticleColor({
					Particle = particle,
					IsSmoke = true
				})
				shared.vfx.emit(particle)
			end,
			[51] = function()
				local impact = vfx.Impact
				local particle = quickFX({
					FX = impact,
					Maid = object._maid,
					Anchor = char:GetPivot() * impact:GetAttribute("Offset"):Inverse()
				})
				libraryNew.ChangeParticleColor({
					Particle = particle,
					IsSmoke = true
				})
				shared.vfx.emit(particle)
			end
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return PurpleBurst