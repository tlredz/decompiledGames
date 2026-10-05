local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")

local function glass(p)
	local model = Instance.new("Model")
	model.Name = "glass"
	model.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(model, 0.25)

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
			TweenService:Create(wedgePart, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				CFrame = wedgePart.CFrame * CFrame.new(
					-Random.new():NextInteger(5, 40),
					Random.new():NextInteger(-25, 25),
					Random.new():NextInteger(-25, 25)
				) * CFrame.Angles(
					math.rad((Random.new():NextInteger(-180, 180))),
					math.rad((Random.new():NextInteger(-180, 180))),
					(math.rad((Random.new():NextInteger(-180, 180))))
				),
				Size = Vector3.new()
			}):Play()
		end
	end
end

local function createLine(p, p2, p3, parent)
	local clones = {}
	local v = nil

	for _ = 1, 3 do
		local clone = script.cylinder:Clone()
		clone.Size = Vector3.new(0.25, p3, 0.25)
		clone.Parent = parent
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
				clone2.Parent = parent
				clone2.Size = Vector3.new(0.1, Random.new():NextInteger(2, 12), 0.1)
				clone2.CFrame = v.CFrame * CFrame.new(0, v.Size.Y / 2, 0) * CFrame.Angles(
					0,
					0,
					Random.new():NextInteger(0, 1) == 1 and 1.5707963267948966 or -1.5707963267948966
				) * CFrame.new(0, clone2.Size.Y / 2, 0)
				table.insert(clones, clone2)
			end
		end

		task.wait(0.025)
		v = clone
	end

	Util.Debris:AddItem(parent, 1)

	for _, v2 in pairs(clones) do
		TweenService:Create(v2, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
	end

	table.clear(clones)
end

local function createSpheres(cf)
	for _ = 1, 3 do
		local integer = Random.new():NextInteger(0, 1)
		local clone = script.sphere:Clone()
		clone.Parent = workspace._WorldOrigin
		clone.CFrame = cf * CFrame.Angles(
			math.rad((Random.new():NextNumber(-55, 55))),
			math.rad((Random.new():NextNumber(-55, 55))),
			(math.rad((Random.new():NextNumber(-55, 55))))
		) * CFrame.new(0, 0, Random.new():NextInteger(3, 5))
		clone.Size = Vector3.new(
			Random.new():NextInteger(5, 10),
			Random.new():NextInteger(5, 10),
			Random.new():NextInteger(20, 30)
		)
		clone.Material = Enum.Material.Neon
		clone.Transparency = 0
		clone.Material = Enum.Material.Neon
		clone.Color = integer == 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(137, 200, 255)
		local number = Random.new():NextNumber(0.25, 0.5)
		Util.Debris:AddItem(clone, number)
		TweenService:Create(clone, TweenInfo.new(number, Enum.EasingStyle.Exponential), {
			Size = createVector(0, 0, 0),
			CFrame = clone.CFrame * CFrame.new(0, 0, Random.new():NextInteger(24, 34))
		}):Play()
	end
end

return function(data)
	local cf = data.cf
	local size = data.size
	local angle = data.angle
	local amount = data.amount
	task.spawn(glass, cf * CFrame.new(-6, -6, 0))
	createSpheres(cf)
	local model = Instance.new("Model")
	model.Parent = workspace._WorldOrigin
	model.Name = "crack"

	for i = 1, 360, 360 / amount do
		task.spawn(createLine, cf, i + angle, size, model)
	end
end