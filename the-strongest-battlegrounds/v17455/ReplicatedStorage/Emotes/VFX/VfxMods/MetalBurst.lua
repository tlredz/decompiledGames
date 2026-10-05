local MetalBurst = {}
local libraryNew = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local _ = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local lifeScale = libraryNew.LifeScale
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
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)

function MetalBurst.FirstEvent(p)
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

	task.delay(7, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v2 = nil

	for _, v4 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v4.Animation.AnimationId ~= "rbxassetid://127386796069137" then
			continue
		end

		v2 = v4
		break
	end

	local BATWEAPON = char:FindFirstChild("#BATWEAPON")

	if BATWEAPON then
		local v4 = object._maid:give(vfx.BatTemplate:Clone())
		task.delay(0.25, function()
			if not v2 or v2 and not v2.IsPlaying then
				task.delay(2, Clean)
				return
			end

			for _, child in pairs(v4:GetChildren()) do
				local child2 = BATWEAPON:FindFirstChild(child.Name)

				if not child2 then
					continue
				end

				for _, child3 in pairs(child:GetChildren()) do
					local give = object._maid:give(child3)
					give.Parent = child2
				end
			end
		end)
	end

	task.delay(2.5, function()
		if not v2 or v2 and not v2.IsPlaying then
			task.delay(2, Clean)
			return
		end

		for _, trail in pairs(BATWEAPON:GetDescendants()) do
			if not trail:IsA("Trail") then
				continue
			end

			playTween(trail, {
				Time = 0.3,
				EasingStyle = "Sine",
				Goal = {
					Transparency = NumberSequence.new(1)
				}
			})
			game.Debris:AddItem(trail, 0.3)
		end
	end)

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[43] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(3, Clean)
					return
				end

				local stab = vfx.stab
				local particle = quickFX({
					FX = stab,
					Maid = object._maid,
					Anchor = char:GetPivot() * stab:GetAttribute("Offset"):Inverse()
				})
				libraryNew.ChangeParticleColor({
					Particle = particle
				})
				shared.vfx.emit(particle)
			end,
			[56] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(3, Clean)
					return
				end

				local BATWEAPON2 = char:FindFirstChild("#BATWEAPON")

				if BATWEAPON2 then
					shared.vfx.emit(BATWEAPON2.Head.EZ)
				end
			end,
			[79] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(3, Clean)
					return
				end

				local TO1 = vfx.TO1
				local folder = quickFX({
					FX = TO1,
					Maid = object._maid,
					Anchor = char:GetPivot() * TO1:GetAttribute("Offset"):Inverse()
				})
				libraryNew.ChangeParticleColor({
					Particle = folder
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
						emitter:SetAttribute("EmitCount", emitter:GetAttribute("EmitCount") * 1.5)
					end
				end

				shared.vfx.emit(folder)
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 2 do
						if v2 and (not v2 or v2.IsPlaying) then
							folder:PivotTo(char:GetPivot() * TO1:GetAttribute("Offset"):Inverse())
							local RunService = game:GetService("RunService")
							RunService.RenderStepped:Wait()
						else
							task.delay(3, Clean)
							break
						end
					end
				end)
			end,
			[103] = function()
				if not v2 or v2 and not v2.IsPlaying then
					task.delay(3, Clean)
					return
				end

				local TO2 = vfx.TO2
				local particle = quickFX({
					FX = TO2,
					Maid = object._maid,
					Anchor = char:GetPivot() * TO2:GetAttribute("Offset"):Inverse()
				})
				libraryNew.ChangeParticleColor({
					Particle = particle
				})
				lifeScale({
					FX = particle.SpinModel,
					Scale = 0.6
				})
				shared.vfx.emit(particle)
				local v5 = object._maid:give(Instance.new("NumberValue"))
				v5.Value = 3
				TweenService:Create(v5, TweenInfo.new(1.15, Enum.EasingStyle.Sine), {
					Value = 0.01
				}):Play()
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 1.65 and particle and particle.Parent do
						if not (tick() - lastTime >= 0.755) then
							char:GetPivot()
							particle:PivotTo(char:GetPivot() * TO2:GetAttribute("Offset"):Inverse())
						end

						particle.SpinModel:PivotTo(particle.SpinModel:GetPivot() * CFrame.Angles(
							0,
							math.rad(v5.Value),
							0
						))
						local RunService = game:GetService("RunService")
						RunService.RenderStepped:Wait()
					end
				end)
			end
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return MetalBurst