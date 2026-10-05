local HunterVariant = {}
local library = require(game.ReplicatedStorage.library)
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
local lifeScale = library.LifeScale
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
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
require(game.ReplicatedStorage.Resources.FrameMarker)

function HunterVariant.auraevent(instance)
	local v = {}

	for _, child in pairs(vfx.victimaura:GetChildren()) do
		local child2 = instance:FindFirstChild(child.Name)

		if not child2 then
			continue
		end

		for _, child3 in pairs(child:GetChildren()) do
			local clone = child3:Clone()
			task.delay(3, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
			clone.Parent = child2
			local random = Random.new()
			clone.Brightness = random:NextNumber(1, 6)
			clone.Rate = random:NextNumber(9, 22)
			clone.Speed = NumberRange.new(random:NextNumber(0.001, 0.005))
			table.insert(v, clone)
		end
	end
end

function HunterVariant.FirstEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
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
	local v2 = {}
	local v3 = nil

	for _, v5 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v5.Animation.AnimationId ~= "rbxassetid://76676838298555" then
			continue
		end

		v3 = v5
		break
	end

	task.delay(0.3, function()
		local v5 = quickFX({
			FX = vfx.Holy,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -30) * CFrame.Angles(-1.5707963267948966, 0, 0)
		})
		shared.vfx.emit(v5)
		local lastTime = tick()

		while tick() - lastTime < 0.7 do
			if v3 and (not v3 or v3.IsPlaying) then
				v5:PivotTo(char:GetPivot() * CFrame.new(0, 5, -10) * CFrame.Angles(-1.5707963267948966, 0, 0))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			else
				v5:Destroy()
				break
			end
		end
	end)
	local victimsvariant = char:WaitForChild("victimsvariant")
	local v5 = {}

	local function Hit(value)
		local particles = {}

		for _, child in pairs(vfx.victimaura:GetChildren()) do
			local child2 = value:FindFirstChild(child.Name)

			if not child2 then
				continue
			end

			for _, child3 in pairs(child:GetChildren()) do
				local v7 = object._maid:give(child3:Clone())
				v7.Parent = child2
				table.insert(particles, v7)
				task.delay(2.5, function()
					v7.Enabled = false
					warn(0.65)

					if v7 and v7.Parent then
						v7:Destroy()
					end
				end)
			end
		end

		v5[value] = particles
		local folder = quickFX({
			FX = vfx.Hit2,
			Maid = object._maid,
			Anchor = CFrame.new(value:GetPivot().Position, char:GetPivot().Position)
		})
		playAttachment(folder)
		task.delay(0.1, function()
			lifeScale({
				FX = folder,
				Scale = 0.5
			})

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						TimeScale = 0.1
					}):Play()
				end
			end
		end)

		for _, light in pairs(folder:GetDescendants()) do
			if light:IsA("PointLight") then
				TweenService:Create(light, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Brightness = 0
				}):Play()
			end
		end

		local v7 = object._maid:give(Instance.new("Highlight"))
		v7.Parent = value
		v7.FillTransparency = 0
		v7.FillColor = Color3.new(1, 1, 1)
		v7.OutlineTransparency = 1
		TweenService:Create(v7, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()
		table.insert(v2, {
			targ = value,
			Hit = folder,
			particles = particles
		})
	end

	if victimsvariant then
		victimsvariant.ChildAdded:Connect(function(child)
			Hit(child.Value)
		end)
	end

	v3:GetMarkerReachedSignal("finish"):Once(function()
		for k, v6 in pairs(v2) do
			local folder = quickFX({
				FX = vfx.Hit2,
				Maid = object._maid,
				Anchor = v6.targ:GetPivot()
			})
			folder:ScaleTo(2)
			lifeScale({
				FX = folder,
				Scale = 0.2
			})
			playAttachment(folder)

			for _, emitter in pairs(v6.particles) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, light in pairs(folder:GetDescendants()) do
				if light:IsA("PointLight") then
					TweenService:Create(light, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Brightness = 0
					}):Play()
				end
			end

			for _, emitter in pairs(v6.Hit:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						TimeScale = 1
					}):Play()
				end
			end

			local v7 = v2[k + 1]
			local targ

			if v7 then
				targ = v7.targ
			else
				targ = char
			end

			if targ then
				local _ = (v6.targ:GetPivot().Position - targ:GetPivot().Position).Magnitude
				playAttachment((quickFX({
					FX = vfx.blitz,
					Maid = object._maid,
					Anchor = CFrame.new(v6.targ:GetPivot().Position, targ:GetPivot().Position) * CFrame.new(
						0,
						-humanoidRootPart.Size.Y * 1.5,
						0
					) * CFrame.Angles(0, 0, 0)
				})))
				task.wait(0.05)
				local FX = quickFX({
					FX = vfx.pe,
					Maid = object._maid,
					Anchor = CFrame.new(v6.targ:GetPivot().Position, char:GetPivot().Position)
				})
				lifeScale({
					FX = FX,
					Scale = 0.5
				})
				playAttachment(FX)
				local FX2 = quickFX({
					FX = vfx.boom,
					Maid = object._maid,
					Anchor = CFrame.new(v6.targ:GetPivot().Position, char:GetPivot().Position)
				})
				lifeScale({
					FX = FX2,
					Scale = 0.3
				})
				shared.vfx.emit(FX2)
			end

			task.wait(0.05)
		end
	end)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return HunterVariant