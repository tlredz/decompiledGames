local createVector = vector.create
local WindLines = require(script.WindLines)
return function()
	local v = {
		Wind = {
			Direction = createVector(1, 0, 0.3),
			Speed = 15,
			Power = 0.25
		}
	}
	WindLines:Init({
		Direction = v.Wind.Direction,
		Speed = v.Wind.Speed,
		Lifetime = 2.5,
		SpawnRate = 0.25
	})
	task.spawn(function()
		while task.wait(math.random(30, 60)) do
			v.Wind.Direction = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit
		end
	end)
end