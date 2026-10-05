local VegetableOutside = {}
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

function VegetableOutside.FirstEvent(p)
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	object._maid:giveTask(bind:GetPropertyChangedSignal("Parent"):Connect(function()
		Clean() -- equivalent call inferred; original call site unknown
	end))

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[26] = function()
				if not bind.Parent then
					return
				end

				local auraFx = vfx.AuraFx
				local folder = quickFX({
					FX = auraFx,
					Maid = object._maid,
					Anchor = char:GetPivot() * auraFx:GetAttribute("Offset"):Inverse()
				})

				for _, effect in pairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true
				end

				object.AuraFx = folder
			end,
			[73] = function()
				if not bind.Parent then
					return
				end

				local auraFx = object.AuraFx

				for _, effect in pairs(auraFx:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = false
				end
			end,
			[184] = function()
				if not bind.Parent then
					return
				end

				local BGFX = vfx.BGFX
				local folder = quickFX({
					FX = BGFX,
					Maid = object._maid,
					Anchor = char:GetPivot() * BGFX:GetAttribute("Offset"):Inverse()
				})

				for _, effect in pairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true
				end

				object.BGFX = folder
			end,
			[320] = function()
				if not bind.Parent then
					return
				end

				local transitionFx1 = vfx.TransitionFx1
				local v2 = quickFX({
					FX = transitionFx1,
					Maid = object._maid,
					Anchor = char:GetPivot() * transitionFx1:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v2)
			end,
			[346] = function()
				if not bind.Parent then
					return
				end

				local Part_Icles = require(script.Parent.Vegetable.Misc.Part_Icles)
				local mesh = vfx.Mesh
				local mesh2 = quickFX({
					FX = mesh,
					Maid = object._maid,
					Anchor = char:GetPivot() * mesh:GetAttribute("Offset"):Inverse()
				})
				object.Mesh = mesh2
				Part_Icles:AbsoluteEmit(mesh2.Explosion)
				local miniBombFx = vfx.MiniBombFx
				local folder = quickFX({
					FX = miniBombFx,
					Maid = object._maid,
					Anchor = char:GetPivot() * miniBombFx:GetAttribute("Offset"):Inverse()
				})
				object.MiniBombFx = folder

				for _, effect in pairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true
				end

				local BGFX = object.BGFX

				for _, effect in pairs(BGFX:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = false
				end
			end,
			[499] = function()
				if not bind.Parent then
					return
				end

				local dustFx = vfx.DustFx
				local folder = quickFX({
					FX = dustFx,
					Maid = object._maid,
					Anchor = char:GetPivot() * dustFx:GetAttribute("Offset"):Inverse()
				})
				object.DustFx = folder

				for _, effect in pairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true
				end

				local miniBombFx = object.MiniBombFx

				for _, effect in pairs(miniBombFx:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = false
				end
			end,
			[521] = function()
				if not bind.Parent then
					return
				end

				local Part_Icles = require(script.Parent.Vegetable.Misc.Part_Icles)
				Part_Icles:AbsoluteEmit(object.Mesh.BigExplosion)
				local bombFx = vfx.BombFx
				local folder = quickFX({
					FX = bombFx,
					Maid = object._maid,
					Anchor = char:GetPivot() * bombFx:GetAttribute("Offset"):Inverse()
				})
				object.BombFx = folder
				print(object.BombFx)

				for _, effect in pairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true
				end
			end,
			[533] = function()
				if not bind.Parent then
					return
				end

				local dustFx = object.DustFx

				for _, effect in pairs(dustFx:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = false
				end

				local dustFx2 = object.DustFx

				for _, effect in pairs(dustFx2:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					local v2 = effect
					delay(effect:GetAttribute("EmitDelay"), function()
						v2:Emit(v2:GetAttribute("EmitCount"))
					end)
				end
			end,
			[574] = function()
				if not bind.Parent then
					return
				end

				local transitionFx1 = vfx.TransitionFx1
				local folder = quickFX({
					FX = transitionFx1,
					Maid = object._maid,
					Anchor = char:GetPivot() * transitionFx1:GetAttribute("Offset"):Inverse()
				})

				for _, effect in pairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					local v2 = effect
					delay(effect:GetAttribute("EmitDelay"), function()
						v2:Emit(v2:GetAttribute("EmitCount"))
					end)
				end
			end,
			[586] = function()
				if not bind.Parent then
					return
				end

				local bombFx = object.BombFx

				for _, effect in pairs(bombFx:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = false
				end
			end
		})
	end

	task.spawn(FirstEvent)
	wait(15)
	Clean() -- equivalent call inferred; original call site unknown
end

return VegetableOutside