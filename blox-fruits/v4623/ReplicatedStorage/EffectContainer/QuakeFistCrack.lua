local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local replicatedTween = Util.ReplicatedTween

local function glass(p)
	local model = Instance.new("Model")
	model.Name = "glass"
	debris:AddItem(model, 0.25)

	for i = 1, 12, 3 do
		for i2 = 1, 12, 3 do
			local wedgePart = Instance.new("WedgePart")
			wedgePart.CFrame = p * CFrame.new(i, i2, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			wedgePart.Size = createVector(0.1, 8, 8)
			wedgePart.Anchored = true
			wedgePart.CanCollide = false
			wedgePart.Material = Enum.Material.Glass
			wedgePart.Transparency = 0.75
			wedgePart.Parent = model
			replicatedTween:Create(wedgePart, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				CFrame = wedgePart.CFrame * CFrame.new(
					-Random.new():NextInteger(5, 40),
					Random.new():NextInteger(-25, 25),
					Random.new():NextInteger(-25, 25)
				) * CFrame.Angles(
					math.rad((Random.new():NextInteger(-180, 180))),
					math.rad((Random.new():NextInteger(-180, 180))),
					(math.rad((Random.new():NextInteger(-180, 180))))
				),
				Size = createVector(0, 0, 0)
			}):Play()
		end
	end

	model.Parent = workspace._WorldOrigin
end

local function createLine(p, p2, p3, parent)
	local clones = {}
	local v = nil

	for _ = 1, 3 do
		local clone = script.cylinder:Clone()
		clone.Size = Vector3.new(0.25, p3, 0.25)
		clone.Anchored = true
		clone.CFrame = p * CFrame.Angles(0, 0, (math.rad(p2))) * CFrame.new(0, clone.Size.Y / 2, 0)
		table.insert(clones, clone)

		if v then
			clone.CFrame = v.CFrame * CFrame.new(0, v.Size.Y / 2, 0) * CFrame.Angles(
				0,
				0,
				(math.rad((Random.new():NextInteger(-45, 45))))
			) * CFrame.new(0, clone.Size.Y / 2, 0)
			clone.Size = v.Size - createVector(0.0875, 0, 0.0875)

			if Random.new():NextInteger(1, 5) == 5 then
				local clone2 = script.cylinder:Clone()
				clone2.Size = Vector3.new(0.1, Random.new():NextInteger(2, 12), 0.1)
				clone2.CFrame = v.CFrame * CFrame.new(0, v.Size.Y / 2, 0) * CFrame.Angles(
					0,
					0,
					Random.new():NextInteger(0, 1) == 1 and 1.5707963267948966 or -1.5707963267948966
				) * CFrame.new(0, clone2.Size.Y / 2, 0)
				clone2.Parent = parent
				table.insert(clones, clone2)
			end
		end

		clone.Parent = parent
		task.wait(0.025)
		v = clone
	end

	debris:AddItem(parent, 1)

	for _, v2 in pairs(clones) do
		Util.ReplicatedTween:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
			Size = Vector3.new(0, v2.Size.Y, 0)
		}):Play()
	end

	table.clear(clones)
end

return function(p, p2, p3, p4)
	task.spawn(glass, p * CFrame.new(-6, -6, 0))
	local model = Instance.new("Model")
	model.Name = "crack"
	model.Parent = workspace._WorldOrigin

	for i = 1, 360, 360 / p4 do
		task.spawn(createLine, p, i + p3, p2, model)
	end
end