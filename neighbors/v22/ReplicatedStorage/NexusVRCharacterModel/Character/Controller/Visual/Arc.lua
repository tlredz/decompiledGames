local createVector = vector.create
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local parent = script.Parent.Parent.Parent.Parent
local FindCollidablePartOnRay = require(parent:WaitForChild("Util"):WaitForChild("FindCollidablePartOnRay"))
local Arc = {}
Arc.__index = Arc

function Arc.new()
	local self = setmetatable({
		BeamParts = {}
	}, Arc)
	self:Hide()
	return self
end

function Arc.Update(p, cframe: CFrame)
	local position = cframe.Position
	local v = math.atan2(-cframe.LookVector.X, -cframe.LookVector.Z)
	local v2 = math.asin(cframe.LookVector.Y)
	local v3 = v2 + 1.0471975511965976 * (1.5707963267948966 - math.abs(v2)) / 1.5707963267948966
	local v4 = CFrame.new(position) * CFrame.Angles(0, v, 0)
	local v5 = math.tan(v3) / -0.4
	local v6 = v5 ^ 2 * -0.2

	for i = 0, 99 do
		local position2 = (v4 * CFrame.new(0, (i + v5) ^ 2 * -0.2 - v6, i * -2)).Position
		local position3 = (v4 * CFrame.new(0, (i + 1 + v5) ^ 2 * -0.2 - v6, (i + 1) * -2)).Position

		if not p.BeamParts[i] then
			p.BeamParts[i] = Instance.new("Part")
			p.BeamParts[i].Transparency = 1
			p.BeamParts[i].Size = createVector(0, 0, 0)
			p.BeamParts[i].Anchored = true
			p.BeamParts[i].CanCollide = false
			p.BeamParts[i].CanQuery = false
			p.BeamParts[i].Parent = Workspace.CurrentCamera
			local attachment = Instance.new("Attachment")
			attachment.Name = "BeamAttachment"
			attachment.CFrame = CFrame.Angles(0, 0, 1.5707963267948966)
			attachment.Parent = p.BeamParts[i]
		end

		if not p.BeamParts[i + 1] then
			p.BeamParts[i + 1] = Instance.new("Part")
			p.BeamParts[i + 1].Transparency = 1
			p.BeamParts[i + 1].Size = createVector(0, 0, 0)
			p.BeamParts[i + 1].Anchored = true
			p.BeamParts[i + 1].CanCollide = false
			p.BeamParts[i + 1].CanQuery = false
			p.BeamParts[i + 1].Parent = Workspace.CurrentCamera
			local attachment = Instance.new("Attachment")
			attachment.Name = "BeamAttachment"
			attachment.CFrame = CFrame.Angles(0, 0, 1.5707963267948966)
			attachment.Parent = p.BeamParts[i + 1]
			local beam = Instance.new("Beam")
			beam.Name = "Beam"
			beam.Attachment0 = p.BeamParts[i].BeamAttachment
			beam.Attachment1 = attachment
			beam.Segments = 1
			beam.Width0 = 0.1
			beam.Width1 = 0.1
			beam.Parent = p.BeamParts[i + 1]
		end

		local v7, v8 = FindCollidablePartOnRay(
			position2,
			position3 - position2,
			Players.LocalPlayer and Players.LocalPlayer.Character,
			Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		)
		p.BeamParts[i].CFrame = CFrame.new(position2) * CFrame.Angles(0, v, 0)
		p.BeamParts[i + 1].Beam.Enabled = true

		if v7 then
			p.BeamParts[i + 1].CFrame = CFrame.new(v8)

			for i2 = 0, i do
				p.BeamParts[i2 + 1].Beam.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
			end

			for i2 = i + 1, #p.BeamParts - 1 do
				p.BeamParts[i2 + 1].Beam.Enabled = false
			end

			return v7, v8
		else
			p.BeamParts[i + 1].CFrame = CFrame.new(position3)
		end
	end

	for i = 0, #p.BeamParts - 1 do
		p.BeamParts[i + 1].Beam.Color = ColorSequence.new(Color3.fromRGB(200, 0, 0))
	end

	return nil, nil
end

function Arc:Hide()
	for i = 0, #self.BeamParts - 1 do
		self.BeamParts[i + 1].Beam.Enabled = false
	end
end

function Arc:Destroy()
	for _, beamPart in self.BeamParts do
		beamPart:Destroy()
	end

	self.BeamParts = {}
end

return Arc