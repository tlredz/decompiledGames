local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function alignCF(data, p, _)
	local p2 = data.p
	local unit = data.LookVector:Cross(p).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(p).Unit.Unit
	return CFrame.fromMatrix(p2, unit2, p, unit3)
end

return function(p)
	local origin = p.Origin
	local direction = p.Direction

	if (origin - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	if (origin - workspace.CurrentCamera.CFrame.p).magnitude < 120 then
		Util.CameraShaker:ShakeOnce(6, 12, 0.1, 1.5, createVector(1, 1, 1), createVector(1, 1, 2))
	end

	sound:Play("SandZ1", origin)
	task.delay(0.25, function()
		sound:FadeOut(sound:Play("SandZ2", origin), 1.75)
	end)
	task.delay(0.5, function()
		sound:Play("sDustBoom", origin)

		if (origin - workspace.CurrentCamera.CFrame.p).magnitude < 120 then
			Util.CameraShaker:ShakeOnce(9, 18, 0.1, 2, createVector(1, 1, 1), createVector(1, 1, 2))
		end
	end)
	local v = _G.FastMode and 0.5 or 1
	local cframe = CFrame.new(origin, origin + direction * createVector(1, 0, 1))

	for i = 0, 405, 15 do
		local v2 = cframe * CFrame.new(0, 60, -i)
		local ray = Util.Ray
		local p2 = v2.p
		local v3 = { workspace._WorldOrigin, workspace.Enemies, workspace.Characters }
		local v4, v5, v6 = ray(p2, createVector(0, -180, 0), v3)

		if v4 and v4.Transparency <= 0 and v4.Anchored then
			local v7 = CFrame.new(v5, v5 + direction * createVector(1, 0, 1)) * CFrame.new(0, 1.5, 0)
			local clone = script.SandWall:Clone()
			clone.CFrame = v7 * CFrame.Angles(-1.5707963267948966, 3.141592653589793, 0) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			clone.Parent = _WorldOrigin
			clone.Lines:Emit(math.random(4, 6) * v)
			clone.Lines.Enabled = true
			task.delay(0.4, function()
				clone.Lines.Enabled = false
			end)

			for i2 = -1, 1, 2 do
				local v9 = 2.5 + math.random() * 2.5
				local part = Instance.new("Part")
				part.Color = v4.Color
				part.Material = v4.Material
				part.Transparency = v4.Transparency
				part.Size = Vector3.new(15, v9, v9)
				part.CFrame = alignCF(CFrame.new(v5, v5 + direction), v6 or createVector(0, 1, 0)) * CFrame.new(
					i2 * (7 + math.random()),
					0,
					0
				) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(-0.7853981633974483, 0, 0)
				part.Anchored = true
				part.CanCollide = false
				part.TopSurface = 0
				part.BottomSurface = 0
				part.Parent = _WorldOrigin
				task.delay(2, function()
					local tween = TweenService:Create(part, TweenInfo.new(0.25), {
						CFrame = part.CFrame - createVector(0, 7.5, 0)
					})
					tween.Completed:Connect(function()
						part:Destroy()
					end)
					tween:Play()
				end)
			end

			local v9 = clone
			task.delay(0.5, function()
				v9.Sand.Enabled = true
				v9.Sand.Speed = NumberRange.new(140, 220)
				v9.Sand.Size = NumberSequence.new(17.5, 12.5)
				v9.Background.Size = NumberSequence.new(20, 25)
				v9.Background.Speed = NumberRange.new(70, 220)
				v9.BoomFireflies.Speed = NumberRange.new(100, 300)
				v9.SandBoom.Size = NumberSequence.new(17.5, 22.5)
				v9.SandBoom.Speed = NumberRange.new(75, 150)
				v9.Sand:Emit(math.random(10, 15) * v)
				v9.SandBoom:Emit(math.random(8, 12) * v)
				v9.Background:Emit(math.random(5, 10) * v)
				v9.BoomFireflies:Emit(4 * v)
				task.delay(1, function()
					v9.Sand.Enabled = false
				end)
				task.delay(5, function()
					v9:Destroy()
				end)
			end)
		end

		if i % 30 == 0 then
			task.wait()
		end
	end
end