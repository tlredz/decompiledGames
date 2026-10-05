local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Spring = require(ReplicatedStorage.Packages.Spring)
local v = {}

local function collectBeams(instance)
	local v2 = {}
	local cube = instance:FindFirstChild("Cube")
	local bone = cube and cube:FindFirstChild("Bone")
	local boosting = bone and bone:FindFirstChild("Boosting")
	local rearAnchor = boosting and boosting:FindFirstChild("RearAnchor")

	if not rearAnchor then
		return v2
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(beam)
		if beam and beam:IsA("Beam") then
			table.insert(v2, {
				Beam = beam,
				Width0 = beam.Width0,
				Width1 = beam.Width1
			})
		end
	end

	add(rearAnchor:FindFirstChild("WaterLoops")) -- equivalent call inferred; original call site unknown
	local rotate = rearAnchor:FindFirstChild("Rotate")

	if not rotate then
		return v2
	end

	add(rotate:FindFirstChild("ThurstMain")) -- equivalent call inferred; original call site unknown
	add(rotate:FindFirstChild("Water")) -- equivalent call inferred; original call site unknown
	return v2
end

Observers.observeTag("WaveriderRig", function(instance)
	local beams = collectBeams(instance)

	if #beams == 0 then
		return nil
	end

	local boostBeams = instance:GetAttribute("BoostBeams") == true
	local spring = Spring.new(boostBeams and 1 or 0)
	spring.Speed = 16
	spring.Damper = 0.7
	spring.Target = boostBeams and 1 or 0
	v[instance] = {
		Spring = spring,
		Beams = beams
	}
	local boostBeamsChangedConnection = instance:GetAttributeChangedSignal("BoostBeams"):Connect(function()
		spring.Target = instance:GetAttribute("BoostBeams") == true and 1 or 0
	end)
	return function()
		boostBeamsChangedConnection:Disconnect()
		v[instance] = nil
	end
end)
RunService.RenderStepped:Connect(function()
	for _, v2 in v do
		local v3 = math.max(v2.Spring.Position, 0)

		for _, beam in v2.Beams do
			beam.Beam.Width0 = beam.Width0 * v3
			beam.Beam.Width1 = beam.Width1 * v3
		end
	end
end)