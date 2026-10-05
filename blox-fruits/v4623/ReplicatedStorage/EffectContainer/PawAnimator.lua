local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Tween = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Tween"))

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Update(data)
	data.MainPart.Size = (data.Mode == "2D" and createVector(0.05, 1, 1) or createVector(1, 1, 1)) * data.Scale
	data.MainPart.Mesh.Scale = createVector(1, 1, 1)

	for k, attachment in next, data.Attachments, nil do
		local v = k == 1 and 1 or -1
		attachment.CFrame = CFrame.new(0, v * data.Scale * 0.4, 0)
	end

	for k, part in next, data.Parts, nil do
		local part2 = part.Part
		part2.Mesh.Scale = createVector(1, 1, 1) * data.Scale * 0.35
		local v = -0.7853981633974483 + 0.5235987755982988 * (k - 1)
		local v2 = math.cos(v)
		local v3 = math.sin(v)
		part2.Weld.C0 = CFrame.new(0, data.Scale * 0.8 * v3, data.Scale * 0.7 * v2)
	end
end

return function(data)
	local main = data.Main
	local parts = data.Parts
	local attachments = data.Attachments
	local data2 = data.Data
	local mode = data.Mode

	if not main then
		return
	end

	local tweenInfo = TweenInfo.new(data2.Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	if data2.Transparency then
		TweenService:Create(main, tweenInfo, {
			Transparency = data2.Transparency
		}):Play()

		for _, part in next, parts, nil do
			TweenService:Create(part.Part, tweenInfo, {
				Transparency = data2.Transparency
			}):Play()
		end
	elseif data2.Scale then
		local lastTime = tick()

		while tick() - lastTime < data2.Duration do
			local v = tick() - lastTime
			local v2 = Tween.ease[data2.Direction or "out"][data2.Ease or "back"](v, 0, 1, data2.Duration)
			local oldScale = data2.OldScale
			Update({
				MainPart = main,
				Parts = parts,
				Mode = mode,
				Attachments = attachments,
				Scale = oldScale + (data2.Scale - oldScale) * v2
			})
			RunService.RenderStepped:Wait()
		end
	end
end