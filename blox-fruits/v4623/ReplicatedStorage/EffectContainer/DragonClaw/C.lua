local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local _ = coroutine.resume
local _ = coroutine.create
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local debris2 = Util.Debris
local cameraShaker = Util.CameraShaker

local function Rocks(data)
	for i = 1, data.amount do
		local v = data.origin * CFrame.Angles(0, math.rad(360 / data.amount * i), 0) * CFrame.new(0, 0, data.offset).Position + createVector(
			0,
			10,
			0
		)
		local ray, v2, _ = Util.Ray(
			v,
			CFrame.new(v).upVector.Unit * -20,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if not ray then
			continue
		end

		local clone = script.RockMesh:Clone()
		clone.CastShadow = false
		clone.Size = createVector(0.5, 0.5, 0.5)
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = data.origin * CFrame.fromOrientation(0, math.rad(360 / data.amount * i), 0) * CFrame.new(
			0,
			0,
			data.offset - data.offset / 2
		)
		clone.Color = ray.Color
		clone.Material = ray.Material
		clone.Rocks.Color = ColorSequence.new(ray.Color)
		clone.sm2.Color = ColorSequence.new(ray.Color)
		clone.Parent = _WorldOrigin
		task.delay(0.3, function()
			clone.Rocks:Emit(5)
			clone.sm2:Emit(3)
		end)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(data.tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = Vector3.new(
					math.random(data.size[1] - data.size[1] / 3.5, data.size[1]),
					math.random(data.size[2] - data.size[2] / 3.5, data.size[2]),
					math.random(data.size[3] - data.size[3] / 3.5, data.size[3])
				),
				CFrame = CFrame.new(v2) * CFrame.fromOrientation(0, math.rad(360 / data.amount * i), 0) * CFrame.Angles(
					math.rad((math.random(-65, -45))),
					0,
					0
				)
			}
		)
		tween:Play()
		local v5 = clone
		coroutine.wrap(function()
			tween.Completed:Wait()
			wait(data.waitTime)
			local tween2 = TweenService:Create(
				v5,
				TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = v5.Position - Vector3.new(0, data.size[2] / 2, 0),
					Transparency = 1,
					Size = Vector3.new()
				}
			)
			tween2:Play()
			tween2.Completed:Wait()
			v5:Destroy()
		end)()
	end
end

return function(data)
	local subEffect = data.SubEffect or 1

	if subEffect == 1 then
		local root = data.Root

		if root then
			if (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude > 800 then
				return
			end

			local clone = script.BreathingIn:Clone()
			clone.CFrame = CFrame.new(root.Position)
			clone.Parent = _WorldOrigin

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Util.Sound:Play("BreathIn", clone)
			debris2:AddItem(clone, 3)
		end
	elseif subEffect == 2 then
		local cFrame = data.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 800 then
			return
		end

		local clone = script.Explosion:Clone()
		clone.CFrame = cFrame * CFrame.new(0, -2.5, 0)
		clone.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		debris2:AddItem(clone, 3)
		Util.Sound:Play("ExplosionSound", clone)
		Util.Sound:Play("ExplosionSound2", clone)

		if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 100 then
			cameraShaker:Shake(Util.CameraShaker.Presets.Explosion)
		end

		coroutine.wrap(function()
			Rocks({
				origin = CFrame.new(clone.Position + createVector(0, 0.5, 0)),
				amount = 7,
				size = { 7, 7, 8.5 },
				offset = 24,
				tweenTime = 0.5,
				waitTime = 1
			})
		end)()
		coroutine.wrap(function()
			Rocks({
				origin = CFrame.new(clone.Position + createVector(0, 0.5, 0)),
				amount = 12,
				size = { 14, 14, 19 },
				offset = 60,
				tweenTime = 0.3,
				waitTime = 1.5
			})
		end)()
		local ray, v, _ = Util.Ray(
			clone.Position,
			CFrame.new(clone.Position).upVector.Unit * -15,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			local clone2 = script.BurntFloor:Clone()
			clone2.Parent = _WorldOrigin
			clone2.CFrame = CFrame.new(v)
			clone2.Orientation += createVector(0, 0, 0)
			TweenService:Create(clone2, tweenInfo, {
				Size = createVector(65.101, 0.001, 65.101)
			}):Play()
			task.delay(1, function()
				for _, decal in pairs(clone2:GetDescendants()) do
					if decal:IsA("Decal") then
						TweenService:Create(decal, tweenInfo, {
							Transparency = 1
						}):Play()
					end
				end
			end)
			debris:AddItem(clone2, 3)
		end
	end
end