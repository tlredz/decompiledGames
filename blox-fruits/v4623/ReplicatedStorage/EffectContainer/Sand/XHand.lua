local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

function lerp(p, p2, p3)
	return p:Lerp(p2, p3)
end

function quadBezier(p, p2, p3, p4)
	local lerped = lerp(p2, p3, p)
	local lerped2 = lerp(p3, p4, p)
	return (lerp(lerped, lerped2, p))
end

return function(data)
	local cFrame = data.CFrame
	local dist = data.Dist
	local dur = data.Dur

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 or not data.Ref or not data.Ref:IsDescendantOf(workspace) then
		return
	end

	local _ = data.Ref
	local _ = masterClock:GetTime() - data.Timestamp

	for i = -1, 1, 2 do
		local v = i
		task.spawn(function()
			local clone = script.BoomSand:Clone()
			clone.CFrame = cFrame * CFrame.new(v * dist / 6, 0, 0)
			clone.Parent = _WorldOrigin
			clone.Attachment.Background2:Emit(20)
			clone.Attachment.Spiral:Emit(10)
			clone.Attachment.Sand:Emit(20)
			task.delay(3, function()
				clone:Destroy()
			end)
			local clone2 = script["SandHand" .. (v == -1 and "Left" or "Right")]:Clone()
			clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = _WorldOrigin
			local lastTime = tick()

			while tick() - lastTime < dur do
				local v2 = (tick() - lastTime) / dur
				local v3 = quadBezier(
					v2,
					cFrame * CFrame.new(v * dist / 6, 0, 0),
					cFrame * CFrame.new(v * dist / 3, 0, -dist / 2),
					cFrame * CFrame.new(0, 0, -dist)
				)
				local v4 = quadBezier(
					v2 + 0.001,
					cFrame * CFrame.new(v * dist / 6, 0, 0),
					cFrame * CFrame.new(v * dist / 3, 0, -dist / 2),
					cFrame * CFrame.new(0, 0, -dist)
				)
				clone2.CFrame = CFrame.new(v3.p, v4.p) * CFrame.Angles(1.5707963267948966, 0, 0)

				for i2 = 1, math.random(1, 2) do
					local part = Instance.new("Part")
					part.Shape = "Ball"
					part.Size = createVector(1, 1, 1) * (5 + math.random() * 8)
					part.CFrame = v3 * CFrame.Angles(
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2
					) * CFrame.new(0, 0, -math.random() * 6)
					part.Color = clone2.Color
					part.Material = clone2.Material
					part.CastShadow = false
					part.Anchored = true
					part.CanCollide = false
					part.Parent = _WorldOrigin
					local tween = TweenService:Create(part, TweenInfo.new(0.3 + math.random() * 0.6), {
						Size = Vector3.new(),
						CFrame = part.CFrame - Vector3.new(0, math.random(6, 10), 0)
					})
					tween.Completed:Connect(function()
						part:Destroy()
					end)
					tween:Play()
				end

				task.wait()
			end

			for i2, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local tween = TweenService:Create(clone2, TweenInfo.new(0.3), {
				Size = Vector3.new()
			})
			tween.Completed:Connect(function()
				clone2.Transparency = 1
				wait(1)
				clone2:Destroy()
			end)
			tween:Play()
		end)
	end
end