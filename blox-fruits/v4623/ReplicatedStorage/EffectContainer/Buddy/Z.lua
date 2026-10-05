local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local heatSlash = script.HeatSlash
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame

	if (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude > 800 then
		return
	end

	if data.Ravage then
		local root = data.Root

		if not (root and root:IsDescendantOf(workspace)) then
			return
		end

		for i = 1, 10, 0.5 do
			local v = i / 20 + 0.75

			if i == 10 then
				task.wait(0.1)
				v = 2
			end

			Util.Sound:Play("SetFire", root.Position)
			Util.Sound:Play("QuickSlice", root.Position)

			for _ = 1, i == 10 and 8 or math.random(1, 2) do
				local clone = script.HeatSlash2:Clone()
				clone.Attachment.Fireflies.Speed = NumberRange.new(v * 400, v * 450)
				clone.Attachment.Fireflies.Size = NumberSequence.new(v * 8, 0, v)
				clone.Attachment.Fireflies.Lifetime = NumberRange.new(v * 0.08, v * 0.16)
				clone.Mesh.Scale *= v
				clone.CFrame = root.CFrame * CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				)
				local tweenInfo = TweenInfo.new(0.2 + math.random() * 0.1)
				TweenService:Create(clone, tweenInfo, {
					Transparency = 1,
					CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone.Mesh, tweenInfo, {
					Scale = clone.Mesh.Scale * 1.75 * (0.75 + math.random() * 0.5),
					VertexColor = clone.Mesh.VertexColor:Lerp(createVector(3, 0, 0), 0.5)
				}):Play()
				clone.Parent = _WorldOrigin
				clone.Attachment.Fireflies:Emit(v * 15)
				task.delay(1, function()
					clone:Destroy()
				end)
			end

			for _ = 1, i == 10 and 16 or 4 do
				local v2 = math.random(10, 30) * v
				local part = Instance.new("Part")
				part.Size = createVector(0.5, 0.5, 5) * (0.3 + math.random() * 0.7) * 4 * v
				part.CFrame = root.CFrame * CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				) * CFrame.new(math.random(5, 20), 0, v2 / 2)
				part.Color = Color3.fromRGB(218, 133, 65)
				part.Material = "Neon"
				part.CastShadow = false
				part.Anchored = true
				part.CanCollide = false
				local specialMesh = Instance.new("SpecialMesh", part)
				specialMesh.MeshType = "Sphere"
				specialMesh.Scale = createVector(1, 1, 1)
				part.Parent = _WorldOrigin
				local tween = TweenService:Create(part, TweenInfo.new(0.05 + math.random() * 0.1), {
					Size = part.Size * Vector3.new(0, 0, v * 2),
					CFrame = part.CFrame * CFrame.new(0, 0, -v2),
					Color = part.Color:Lerp(Color3.new(1, 1, 1), 0.3)
				})
				tween.Completed:Connect(function()
					part:Destroy()
				end)
				tween:Play()
			end

			task.wait()
			task.wait()
		end
	else
		local v = math.min(0.8 - (masterClock:GetTime() - data.Timestamp), 0.8)
		local clone = heatSlash:Clone()
		clone.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0)
		clone.Parent = _WorldOrigin
		local v2 = false
		local tween = TweenService:Create(clone, TweenInfo.new(v), {
			CFrame = clone.CFrame * CFrame.new(0, 0, 240)
		})
		tween.Completed:Connect(function()
			v2 = true
		end)
		tween:Play()

		while wait() and data.Ref and data.Ref:IsDescendantOf(workspace) and not v2 do

		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local tween2 = TweenService:Create(clone, TweenInfo.new(0.075), {
			Transparency = 1
		})
		tween2.Completed:Connect(function()
			task.wait(0.3)
			clone:Destroy()
		end)
		tween2:Play()
	end
end