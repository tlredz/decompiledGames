local createVector = vector.create
local RunService = game:GetService("RunService")
local Shared = {}
Shared.Ran = Random.new()

function Shared.CreateIntangible(parent)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(5, 5, 5)
	part.Transparency = 1
	part.Massless = true
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = parent
	return part
end

function Shared.FixedUpdate(callback, p: number, callback2)
	local v = 0
	local total = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if callback2 then
			callback2(dt)
		end

		v += dt
		total += dt

		while p <= v do
			task.spawn(callback, total)
			v -= p
			total = 0
		end
	end)
	return function()
		heartbeatConnection:Disconnect()
	end
end

function Shared.GetPath(parent, p)
	local names = {}
	local v = ""

	repeat
		names[#names + 1] = parent.Name
		parent = parent.Parent
	until parent == p

	for i = #names, 1, -1 do
		v ..= names[i] .. "/"
	end

	return v:sub(1, #v - 1)
end

return Shared