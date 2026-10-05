local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
return function(data)
	local position = data.Position
	local normal = data.Normal
	local color = data.Color
	local material = data.Material

	if typeof(position) ~= "Vector3" then
		return
	end

	local v = (typeof(normal) ~= "Vector3" or not (normal.Magnitude > 0)) and createVector(0, 1, 0) or normal.Unit
	local random = Random.new()

	for _ = 1, 14 do
		local number = random:NextNumber(1.2, 2.6)
		local part = Instance.new("Part")
		part.CanCollide = false
		part.Size = Vector3.new(number, number, number)
		part.Material = material or Enum.Material.Slate
		part.Color = color or Color3.fromRGB(120, 120, 120)
		part.CFrame = CFrame.new(position + v * random:NextNumber(0.5, 2)) * CFrame.Angles(
			math.rad((random:NextInteger(-180, 180))),
			math.rad((random:NextInteger(-180, 180))),
			(math.rad((random:NextInteger(-180, 180))))
		)
		part.Parent = workspace._WorldOrigin
		debris:AddItem(part, 1.5)
		local vector2 = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
		local velocity = v * 70 + vector2 * 55
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1, 1, 1) * 1e999
		bodyVelocity.Velocity = velocity
		bodyVelocity.Parent = part
		debris:AddItem(bodyVelocity, 0.025)
		local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
		bodyAngularVelocity.MaxTorque = createVector(1, 1, 1) * 1e999
		bodyAngularVelocity.AngularVelocity = Vector3.new(
			random:NextNumber(-15, 15),
			random:NextNumber(-15, 15),
			random:NextNumber(-15, 15)
		)
		bodyAngularVelocity.Parent = part
		debris:AddItem(bodyAngularVelocity, 0.1)
	end
end