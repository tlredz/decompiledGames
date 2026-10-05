local createVector = vector.create
local Players = game:GetService("Players")
local drops = Players.LocalPlayer.PlayerScripts.Assets.Drops

local function set_ltm(folder, localTransparencyModifier)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("ParticleEmitter") then
			descendant.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

return function(parent, p, p2)
	local attachment = Instance.new("Attachment")
	attachment.Parent = parent
	local clone = drops[p]:Clone()
	clone.PrimaryPart = clone.Primary
	clone:PivotTo(parent.CFrame * CFrame.Angles(
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2
	))

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local anchored = part == clone.PrimaryPart
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.Anchored = anchored

		if anchored then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone.Primary
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
	end

	clone.PrimaryPart.Anchored = false
	clone.Parent = parent
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = clone.PrimaryPart
	local angularVelocity = Instance.new("AngularVelocity")
	angularVelocity.MaxTorque = 1000000
	angularVelocity.AngularVelocity = createVector(0, 2, 0) * math.sign(math.random() - 0.5)
	angularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	angularVelocity.Attachment0 = attachment2
	angularVelocity.Parent = clone.PrimaryPart
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.RigidityEnabled = true
	alignPosition.Attachment0 = attachment2
	alignPosition.Attachment1 = attachment
	alignPosition.Parent = clone.PrimaryPart

	if p2 < 1e999 then
		wait(p2 - 4)

		for _ = 1, 20 do
			set_ltm(parent, 1)
			wait(0.07500000000000001)
			set_ltm(parent, 0)
			wait(0.125)
		end
	end
end