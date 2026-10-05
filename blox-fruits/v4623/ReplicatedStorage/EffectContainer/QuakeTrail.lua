local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
Color3.fromRGB(175, 221, 255)
return function(p)
	local part = p.Part
	local scale = p.Scale or 5
	local magnitude = (part.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 100 + 100 * scale < magnitude then
		return
	end

	local transparency = part.Transparency
	local lastTime = tick()
	local total = 0

	while part and part.Parent and part:IsDescendantOf(workspace._WorldOrigin) do
		local size = scale * (1 - (part.Transparency - transparency) / (1 - transparency)) ^ 0.5
		local v2 = tick() - lastTime
		local ray, _, _ = Util.Ray(
			part.Position,
			Vector3.new(0, -size, 0),
			{ workspace.Characters, workspace.Enemies, workspace.Boats }
		)

		if ray and total < v2 then
			total += 0.1
			local cframe = CFrame.new(part.Position, part.Position + part.CFrame.lookVector)
			local unit = (cframe.lookVector * createVector(1, 0, 1)).unit
			local v3 = size * 1.8
			Effect.new("Wind"):replicate({
				CFrame = cframe,
				Color = Color3.new(1, 1, 1),
				Size = size,
				Duration = 0.5
			})

			for i = -1, 1, 2 do
				local ray2, v4 = Util.Ray(
					cframe * Vector3.new(v3 / 2 * i * (0.8 + size / 25), size / 2, 0),
					Vector3.new(0, -size * 1.5, 0),
					{ workspace.Characters, workspace.Enemies, workspace.Boats }
				)

				if not (ray2 and ray2.Anchored and ray2.Transparency <= 0) then
					continue
				end

				local cFrame = (CFrame.new(v4, v4 + unit) - createVector(0, 10, 0)) * CFrame.Angles(
					0,
					0,
					3.141592653589793 * math.random() * 2
				)
				local cFrame2 = cFrame + createVector(0, 7, 0)
				local part2 = Instance.new("Part")
				part2.Color = ray2.Color
				part2.TopSurface = 0
				part2.BottomSurface = 0
				part2.Material = ray2.Material
				part2.Transparency = ray2.Transparency
				part2.Anchored = true
				part2.CanCollide = false
				part2.Size = createVector(1, 1, 1) * size
				part2.CFrame = cFrame
				part2.Parent = _WorldOrigin
				local tween = TweenService:Create(part2, TweenInfo.new(0.1), {
					CFrame = cFrame2
				})
				tween.Completed:Connect(function()
					wait(1)
					local tween2 = TweenService:Create(part2, TweenInfo.new(0.2), {
						CFrame = cFrame
					})
					tween2.Completed:Connect(function()
						part2:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end
		end

		wait()
	end
end