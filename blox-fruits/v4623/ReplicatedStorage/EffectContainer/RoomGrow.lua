local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local duration = data.Duration
	local radius = data.Radius

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	for i = 0, 5 do
		local v = 1 + math.random() * 0.6
		local part = Instance.new("Part")
		part.Material = "Neon"
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(1, 1, 1)
		part.BrickColor = BrickColor.new("Bright blue")
		part.Transparency = 0.05
		part.CFrame = cFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) + Vector3.new(
			0,
			(i - 2.5) * 3,
			0
		)
		local specialMesh = Instance.new("SpecialMesh", part)
		specialMesh.MeshType = "FileMesh"
		specialMesh.MeshId = "rbxassetid://4206036806"
		specialMesh.TextureId = "http://www.roblox.com/asset/?id=4206054466"
		specialMesh.VertexColor = createVector(2, 2, 2)
		specialMesh.Scale = Vector3.new()
		part.Parent = _WorldOrigin
		TweenService:Create(specialMesh, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
			Scale = createVector(1, 1, 1) / createVector(14, 10, 14) * radius * 2 * v
		}):Play()
		local v2 = duration + math.random() * 0.5 + 0.5
		local tween = TweenService:Create(part, TweenInfo.new(v2, Enum.EasingStyle.Quad), {
			Transparency = 1
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
		local v4 = i
		local v5 = part
		spawn(function()
			local v6 = v4 % 2 == 0 and -1 or 1
			local lastTime = tick()

			while true do
				local RunService = game:GetService("RunService")

				if not RunService.RenderStepped:Wait() then
					break
				end

				local v7 = tick() - lastTime

				if v5 and v5.Parent then
					v5.CFrame *= CFrame.Angles(0, v6 * 5 * v7, 0)
					lastTime = tick()
				else
					break
				end
			end
		end)
	end
end