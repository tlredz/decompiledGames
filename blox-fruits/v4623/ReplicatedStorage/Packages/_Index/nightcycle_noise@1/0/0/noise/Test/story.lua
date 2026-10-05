local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local parentModule = require(script.Parent)
local size = Vector2.one * 128
local v2 = size.X / 8
local v3 = 256 / size.X

function drawNoise(maid, _: string, callback)
	local parent = maid:GiveTask(Instance.new("ImageLabel"))
	parent.Size = UDim2.fromOffset(size.X * v3, size.Y * v3)
	parent.LayoutOrder = -time()
	local v5 = maid:GiveTask(Instance.new("EditableImage"))
	v5.Size = size
	local v6 = true
	maid:GiveTask(function()
		v6 = false
	end)
	local v7 = parentModule.new(tick())
	local total = 0
	local count = 0

	for i = 0, v5.Size.Y - 1 do
		if v6 == false then
			break
		end

		for i2 = 0, v5.Size.X - 1 do
			local lastTime = tick()
			local v8 = callback(v7, i2, i)
			total += tick() - lastTime
			count += 1
			v5:DrawRectangle(Vector2.new(i2, i), Vector2.one, Color3.fromHSV(0, 0, v8), 0)
		end
	end

	v5.Parent = parent
	return parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mathNoise(p: number, p2: number, p3: number)
	return 0.5 + 0.5 * math.noise(p / p3, p2 / p3, 0)
end

return function(parent)
	local v4 = Maid.new()
	task.spawn(function()
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Parent = parent
		uIListLayout.Wraps = true
		uIListLayout.Padding = UDim.new(0, 4)
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingTop = uIListLayout.Padding
		uIPadding.PaddingBottom = uIListLayout.Padding
		uIPadding.PaddingLeft = uIListLayout.Padding
		uIPadding.PaddingRight = uIListLayout.Padding
		uIPadding.Parent = parent
		local drawNoise_2 = drawNoise(v4, "math.noise", function(_, p: number, p2: number)
			return mathNoise(p, p2, v2)
		end)
		drawNoise_2.Parent = parent
		local drawNoise_3 = drawNoise(v4, "random-2D", function(object, p: number, p2: number)
			return (math.clamp(object:Random(p / v2, p2 / v2, 0), 0, 1))
		end)
		drawNoise_3.Parent = parent
		local drawNoise_4 = drawNoise(v4, "perlin-2D", function(object, p: number, p2: number)
			return (math.clamp(object:Perlin(p / v2, p2 / v2), 0, 1))
		end)
		drawNoise_4.Parent = parent
		local drawNoise_5 = drawNoise(v4, "cellular-2D", function(object, p: number, p2: number)
			return (math.clamp(object:Cellular(p / v2, p2 / v2), 0, 1))
		end)
		drawNoise_5.Parent = parent
		local drawNoise_6 = drawNoise(v4, "voronoi-2D", function(object, p: number, p2: number)
			return (math.clamp(object:Voronoi(p / v2, p2 / v2), 0, 1))
		end)
		drawNoise_6.Parent = parent
	end)
	return function()
		v4:Destroy()
	end
end