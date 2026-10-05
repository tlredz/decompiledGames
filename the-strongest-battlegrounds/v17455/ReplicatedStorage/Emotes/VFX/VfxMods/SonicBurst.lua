local SonicBurst = {}
local libraryNew = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew)
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

function SonicBurst.FirstEvent(p)
	local char = p.Data.Char
	local _ = char.HumanoidRootPart
	local humanoid = char.Humanoid
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
	local v2 = nil

	for _, v4 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v4.Animation.AnimationId ~= "rbxassetid://99798123383608" then
			continue
		end

		v2 = v4
		break
	end

	local clone1 = char:FindFirstChild("Clone1")
	local clone2 = char:FindFirstChild("Clone2")

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[20] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(5, Clean)
					return
				end

				local flash = vfx.Flash
				local v4 = quickFX({
					FX = flash,
					Maid = object._maid,
					Anchor = char:GetPivot() * flash:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v4)
			end,
			[25] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(5, Clean)
					return
				end

				for _, v5 in pairs({ clone1, clone2 }) do
					for _, child in pairs(vfx.CloneTemplate:GetChildren()) do
						local child2 = v5:FindFirstChild(child.Name)

						if not child2 then
							continue
						end

						for _, child3 in pairs(child:GetChildren()) do
							local v6 = object._maid:give(child3:Clone())
							game.Debris:AddItem(v6, 3)
							v6.Parent = child2
						end
					end
				end

				shared.vfx.emit(clone1, clone2)
				local spinModel = vfx.SpinModel
				local particle = quickFX({
					FX = spinModel,
					Maid = object._maid,
					Anchor = char:GetPivot() * spinModel:GetAttribute("Offset"):Inverse()
				})
				libraryNew.ChangeParticleColor({
					Particle = particle,
					IsSmoke = true
				})
				shared.vfx.emit(particle)
				local slash4 = vfx.slash4
				local v6 = quickFX({
					FX = slash4,
					Maid = object._maid,
					Anchor = char:GetPivot() * slash4:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v6)
				task.spawn(function()
					local lastTime = tick()
					local total = 0

					while tick() - lastTime < 1.5 do
						total += 5
						particle:PivotTo(char:GetPivot() * CFrame.Angles(0, math.rad(total), 0) * slash4:GetAttribute("Offset"):Inverse())
						v6:PivotTo(char:GetPivot() * slash4:GetAttribute("Offset"):Inverse())
						task.wait(0.01)
					end
				end)
			end,
			[79] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(0.5, Clean)
					return
				end

				warn("yoggg")
				local F = vfx.F
				local v4 = quickFX({
					FX = F,
					Maid = object._maid,
					Anchor = char:GetPivot() * F:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v4)
				object.F = v4
			end,
			[80] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(0.65, Clean)
					return
				end

				local F = object.F

				for _, emitter in pairs(F:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(emitter, TweenInfo.new(1), {
						TimeScale = 0
					}):Play()
				end
			end,
			[111] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(5, Clean)
					return
				end

				local F = object.F

				for _, emitter in pairs(F:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(emitter, TweenInfo.new(0.1), {
						TimeScale = 1
					}):Play()
				end
			end,
			[112] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(5, Clean)
					return
				end

				local F2 = vfx.F2
				local particle = quickFX({
					FX = F2,
					Maid = object._maid,
					Anchor = char:GetPivot() * F2:GetAttribute("Offset"):Inverse()
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

return SonicBurst