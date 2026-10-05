local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
game:GetService("RunService")
local thrown = game.Workspace.Thrown
local script2 = script
local meshflipbookIDS = require(script2.meshflipbookIDS)
local Vfxmodule = require(script2.Vfxmodule)
local flowerchargeids = meshflipbookIDS.Flowerchargeids
local _ = meshflipbookIDS.orbchargeids
local coneids = meshflipbookIDS.coneids
local beamoverlayids = meshflipbookIDS.Beamoverlayids
local cylinderupids = meshflipbookIDS.cylinderupids

local function emitbeamring(p, p2, duration)
	task.spawn(function()
		for _ = 1, p2 do
			local clone = script2.Meshassets.beamup:Clone()
			clone.CFrame = p * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0) * CFrame.new(0, 0, 0)
			clone.Parent = thrown
			local v = math.random(2000, 2500) / 100 * 4
			local v2 = math.random(3500, 4000) / 100 * 4
			local v3 = math.random(600, 700) / 1000
			local v4 = {
				Scale = Vector3.new(v, v2, v)
			}
			local v5 = {
				CFrame = clone.CFrame * CFrame.new(0, 140, 0) * CFrame.Angles(0, math.rad((math.random(160, 179))), 0)
			}
			local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
			local tween = TweenService:Create(clone.Mesh, tweenInfo, v4)
			TweenService:Create(clone, tweenInfo, v5):Play()
			tween:Play()
			Vfxmodule.textureflipbook(clone.Decal, cylinderupids, v3 * 0.9, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
			Debris:AddItem(clone, v3 * 1.2)
			task.wait(duration)
		end
	end)
end

local function emittwirlers(p, p2, duration)
	task.spawn(function()
		for _ = 1, p2 do
			local clone = script2.Meshassets.Twirlinglines:Clone()
			clone.CFrame = p * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0) * CFrame.new(0, 120, 0)
			clone.Parent = thrown
			local v = math.random(350, 550) / 100 * 4
			local v2 = math.random(500, 800) / 100 * 4
			local v3 = math.random(800, 1400) / 1000
			local v4 = {
				Scale = Vector3.new(v, v2, v)
			}
			local v5 = {
				CFrame = clone.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad((math.random(160, 179))), 0)
			}
			local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
			local tween = TweenService:Create(clone.Mesh, tweenInfo, v4)
			TweenService:Create(clone, tweenInfo, v5):Play()
			tween:Play()
			Vfxmodule.textureflipbook(clone.Decal, flowerchargeids, v3 * 0.9, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
			Debris:AddItem(clone, v3 * 1.2)
			task.wait(duration)
		end
	end)
end

local function emitconemesh(p, p2, duration)
	task.spawn(function()
		for _ = 1, p2 do
			local clone = script2.Meshassets.conemesh:Clone()
			clone.CFrame = p * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
			clone.Parent = thrown
			local v = math.random(15, 23) * 4
			local v2 = math.random(10, 22) * 4
			local v3 = math.random(750, 1100) / 1000
			local v4 = {
				Scale = Vector3.new(v, v2, v)
			}
			local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
			TweenService:Create(clone.Mesh, tweenInfo, v4):Play()
			Vfxmodule.textureflipbook(clone.Decal, coneids, v3, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
			Debris:AddItem(clone, v3 * 1.2)
			task.wait(duration)
		end
	end)
end

local function emitwindtwirlmesh(p, p2, duration)
	task.spawn(function()
		for _ = 1, p2 do
			local clone = script2.Meshassets.vpwindtwirl:Clone()
			clone.CFrame = p * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
			clone.Parent = thrown
			local _ = math.random(15, 23) * 4
			local _ = math.random(3, 12) * 4
			local v = math.random(50, 110)
			local v2 = math.random(50, 100)
			local v3 = math.random(750, 1100) / 1000
			local v4 = {
				Size = Vector3.new(v, v2, v),
				CFrame = clone.CFrame * CFrame.new(0, v2 * 0.5, 0) * CFrame.Angles(
					0,
					math.rad((math.random(150, 179))),
					0
				),
				Transparency = 1
			}
			TweenService:Create(
				clone,
				TweenInfo.new(v3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
				v4
			):Play()
			Debris:AddItem(clone, v3 * 1.2)
			task.wait(duration)
		end
	end)
end

local function emitVPtorus(p, p2, duration)
	task.spawn(function()
		for _ = 1, p2 do
			local clone = script2.Meshassets.vptorus:Clone()
			clone.CFrame = p * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-25, 25))))
			)
			clone.Parent = thrown
			local v = math.random(700, 1200) / 1000
			local v2 = math.random(8, 16) * 4
			local v3 = math.random(80, 130) * 4
			local v4 = {
				Size = Vector3.new(v3, v2, v3),
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			}
			TweenService:Create(
				clone,
				TweenInfo.new(v, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
				v4
			):Play()
			Debris:AddItem(clone, v * 1.2)
			task.wait(duration)
		end
	end)
end

local function meteor(cFrame, p)
	print("METEOR")
	local clone = script2.modelscaler:Clone()
	clone:ScaleTo(4)
	game.Debris:AddItem(clone, 10)
	local trailsHolder = clone.TrailsHolder
	trailsHolder.CFrame = cFrame * CFrame.new(0, 1400, 0)
	local v = {
		CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(130, 179))), 0)
	}
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0)
	local tween = TweenService:Create(trailsHolder, tweenInfo, v)
	trailsHolder.Parent = thrown
	game.Debris:AddItem(trailsHolder, 10)
	Vfxmodule.EmitAttributes(trailsHolder)
	tween:Play()
	local particles = clone.Particles
	particles.CFrame = cFrame
	particles.Parent = thrown
	game.Debris:AddItem(particles, 10)
	local children = trailsHolder.Attachmentparent:GetChildren()

	for _, attachment in children do
		if not attachment:IsA("Attachment") then
			continue
		end

		local v2 = {
			CFrame = CFrame.new(0, 0, 0)
		}
		TweenService:Create(
			attachment,
			TweenInfo.new(
				0.6000000000000001,
				Enum.EasingStyle.Exponential,
				Enum.EasingDirection.In,
				0,
				false,
				2.4000000000000004
			),
			v2
		):Play()
	end

	local v2 = {
		CFrame = trailsHolder.Attachmentparent.CFrame * CFrame.Angles(0, 3.0543261909900767, 0)
	}
	TweenService:Create(trailsHolder.Attachmentparent, tweenInfo, v2):Play()
	task.spawn(function()
		local function fn(_, p2)
			for _, child in pairs(workspace.Live:GetChildren()) do
				if (child.PrimaryPart.Position - cFrame.Position).Magnitude <= 80 then
					shared.repfire({
						Effect = "Camshake",
						Intensity = p2.shake,
						Last = p2.last
					})
				end
			end
		end

		task.wait(2.7)
		warn("explode?")
		warn(tick() - p)
		local clone2 = script2.Meshassets.twirlingflower:Clone()
		clone2.CFrame = cFrame * CFrame.new(0, 90, 0)
		clone2.Mesh.Scale = clone2.Mesh.Scale * 4
		clone2.Parent = thrown
		game.Debris:AddItem(clone2, 10)
		print(clone2.Decal.Color3)
		Vfxmodule.textureflipbook(clone2.Decal, flowerchargeids, 0.8999999999999999, function()
			if clone2 and clone2.Parent then
				clone2:Destroy()
			end
		end)
		Vfxmodule.EmitAttributes(particles.flowercharge)
		shared.sfx({
			SoundId = "rbxassetid://123325649038297",
			Volume = 6,
			RollOffMaxDistance = 500,
			CFrame = cFrame,
			RollOffMode = Enum.RollOffMode.LinearSquare
		}):Play()
		task.delay(0.705, function()
			fn(40, {
				shake = 20,
				last = 5
			})
			shared.sfx({
				SoundId = "rbxassetid://73031818958325",
				Volume = 6,
				RollOffMaxDistance = 500,
				CFrame = cFrame,
				RollOffMode = Enum.RollOffMode.LinearSquare
			}):Play()
		end)
		task.wait(0.7124999999999999)
		task.spawn(function()
			local beampart = clone.Beampart
			game.Debris:AddItem(beampart, 13)

			for _, emitter in pairs(beampart.Enabled.specs:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.ZOffset -= 160
				print("FIXED")
			end

			beampart.CFrame = cFrame
			beampart.Parent = thrown
			local v3 = {
				CFrame = beampart.Receivergoal1.CFrame
			}
			local v4 = {
				CFrame = beampart.Receivergoal2.CFrame
			}
			local tweenInfo2 = TweenInfo.new(
				0.21000000000000002,
				Enum.EasingStyle.Circular,
				Enum.EasingDirection.Out,
				0,
				false,
				0
			)
			local tweenInfo3 = TweenInfo.new(3.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
			local tween2 = TweenService:Create(beampart.Receiver, tweenInfo2, v3)
			local tween3 = TweenService:Create(beampart.Receiver, tweenInfo3, v4)
			Vfxmodule.EmitAttributes(particles.Detonate)
			local clone3 = script.SpaceBoom2:Clone()
			clone3:PivotTo(beampart:GetPivot())
			clone3.Parent = game.Workspace.Thrown
			clone3:ScaleTo(4)
			game.Debris:AddItem(clone3, 10)

			for _, beam in pairs(beampart.Attachment:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local width0 = beam.Width0
				local width1 = beam.Width1
				beam.Width0 = 0
				beam.Width1 = 0
				beam.ZOffset += 0.5
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(beam, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Width0 = width0 * 0.1,
					Width1 = width1 * 0.1
				}):Play()
			end

			local children2 = beampart:GetChildren()

			for _, emitter in children2 do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone4 = script2.Meshassets.Impactmesh:Clone()
			clone4.CFrame = cFrame
			local tween4 = TweenService:Create(
				clone4,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(0.1, 70, 0.1),
					CFrame = clone4.CFrame * CFrame.new(0, 33, 0)
				}
			)
			clone4.Parent = thrown
			tween4:Play()
			Debris:AddItem(clone4, 1)
			tween2:Play()
			tween2.Completed:Connect(function()
				tween3:Play()
			end)
			local textureflipbookLoop = Vfxmodule.textureflipbookLoop(
				beampart.beamparent.s1swirloverlay,
				beamoverlayids,
				2
			)
			task.spawn(function()
				task.wait(4)
				local descendants = beampart:GetDescendants()

				for _, emitter in descendants do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Vfxmodule.Closebeam(beampart, 0.5)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.5)
				textureflipbookLoop:Stop()
			end)
		end)
	end)
	return tween
end

return {
	pillarthingyemit = function(cframe: CFrame, p)
		meteor(cframe, p)
	end
}