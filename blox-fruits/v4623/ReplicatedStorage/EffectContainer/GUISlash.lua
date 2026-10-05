workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
return function(data)
	local duration = data.Duration or 0.25
	local scale = data.Scale or 40
	local color = data.Color or Color3.new(1, 1, 1)
	local part = data.Part

	if not part or (part.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local colors = typeof(color) == "Color3" and { color, color } or color

	if typeof(colors[1]) == "Instance" then
		colors[1] = colors[1].Color
	end

	if typeof(colors[2]) == "Instance" then
		colors[2] = colors[2].Color
	end

	local clone = game.ReplicatedStorage.Assets.GUI.SlashBBG:Clone()
	clone.Image.Rotation = math.random(360)
	clone.Image.ImageColor3 = colors[1] or Color3.new(1, 1, 1)
	clone.Parent = part
	clone.Adornee = part
	Util.Sound:Play("QuickSlice", part)
	local v = math.random(2) == 1 and 1 or -1
	local v2 = math.random()
	local lastTime = tick()

	while tick() - lastTime < duration do
		local v3 = math.min((tick() - lastTime) / duration, 1)
		clone.Image.Rotation = clone.Image.Rotation % 360 + v2 * v
		clone.Size = UDim2.new((1 - v3) * scale * 0.25, 0, v3 ^ 0.75 * scale, 0)
		clone.Image.ImageColor3 = colors[1]:Lerp(colors[2], v3)
		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Wait()
	end

	clone:Destroy()
end