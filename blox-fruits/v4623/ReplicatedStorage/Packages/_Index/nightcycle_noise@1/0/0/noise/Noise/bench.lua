local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("package")).new()
return {
	Functions = {
		["math.noise"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					math.noise(i, i2)
				end
			end
		end,
		["perlin-2D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Perlin(i, i2)
				end
			end
		end,
		["perlin-3D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Perlin(i, i2, 0)
				end
			end
		end,
		["cellular-2D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Cellular(i, i2)
				end
			end
		end,
		["cellular-3D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Cellular(i, i2, 0)
				end
			end
		end,
		["voronoi-2D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Voronoi(i, i2)
				end
			end
		end,
		["voronoi-3D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Voronoi(i, i2, 0)
				end
			end
		end,
		["random-2D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Random(i, i2)
				end
			end
		end,
		["random-3D"] = function()
			for i = 1, 32 do
				for i2 = 1, 32 do
					v:Random(i, i2, 0)
				end
			end
		end
	}
}