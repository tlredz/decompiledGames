local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local TweenService = game:GetService("TweenService")
return function(p, p2, p3, p4)
	local position = (p.CFrame * CFrame.new(p3, 0, -7.5)).Position
	local v = (p.CFrame * CFrame.Angles(0, math.rad(p2), 0)).LookVector * p4
	local _, v2 = Util.Ray(position, v, { workspace.Characters, workspace.Enemies, workspace._WorldOrigin })
	local v3 = {}

	for i = 1, (position - v2).Magnitude, 8 do
		local v4 = CFrame.new(position, v2) * Vector3.new(0, 0, -i)
		local ray = Util.Ray
		local v5 = { workspace.Characters, workspace.Enemies }
		local v6, v7 = ray(v4, createVector(0, -15, 0), v5)

		if v6 then
			local integer = Random.new():NextInteger(4, 4.5)
			local part = Instance.new("Part")
			part.Position = v7 + createVector(0, -5, 0)
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new(integer, integer, integer)
			part.Material = v6.Material
			part.Color = v6.Color
			part.CFrame *= CFrame.Angles(
				math.rad((Random.new():NextInteger(-180, 180))),
				math.rad((Random.new():NextInteger(-180, 180))),
				(math.rad((Random.new():NextInteger(-180, 180))))
			)

			if i == 1 then
				part.Size /= 2
			end

			TweenService:Create(part, TweenInfo.new(0.05, Enum.EasingStyle.Exponential), {
				Position = part.Position + createVector(0, 5, 0)
			}):Play()
			table.insert(v3, part)
			part.Parent = workspace._WorldOrigin
		end

		task.wait(0.03333333333333333)
	end

	task.delay(0.25, function()
		for _, v4 in pairs(v3) do
			TweenService:Create(v4, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Position = v4.Position + createVector(0, -5, 0),
				Size = createVector(0.5, 0.5, 0.5)
			}):Play()
			debris:AddItem(v4, 0.5)
			task.wait(0.03)
		end

		table.clear(v3)
	end)
end