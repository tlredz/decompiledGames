local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local models = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("Models")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Debris = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Debris"))
local WingsOld = {}
WingsOld.__index = WingsOld

function WingsOld.Attach(data)
	local size = data.Size or 1
	local color = data.Color or Color3.new(1, 0, 0)
	local transparency = data.Transparency or 0
	return (setmetatable({
		Root = data.Root,
		Size = size,
		Color = color,
		Transparency = transparency,
		R15 = false
	}, {
		__index = WingsOld
	}))
end

function WingsOld:Activate()
	if not models then
		return
	end

	local wings = models:FindFirstChild("Wings")
	local wingTrail = FX:WaitForChild("WingTrail")
	local clone = wings:Clone()
	local wings2 = {}

	for k, parent in next, { clone.Right, clone.Left }, nil do
		local v2 = k == 1 and 1 or -1
		parent.Transparency = self.Transparency
		parent.CFrame = self.Root.CFrame
		parent.Mesh.VertexColor = Vector3.new(self.Color.R, self.Color.G, self.Color.B)
		parent.Anchored = false
		parent.Mesh.Scale = createVector(1, 1, 1) * self.Size
		local attachments = {}

		for i = 1, 2 do
			local v4 = i == 1 and 0 or 1
			local attachment = Instance.new("Attachment")
			attachment.CFrame = CFrame.new(
				v2 * self.Size * 1.65 - v4 * v2 * self.Size * 0.25,
				self.Size * 0.5,
				-self.Size * 0.125
			)
			attachment.Parent = parent
			table.insert(attachments, attachment)
		end

		local clone2 = wingTrail:Clone()
		local attachment2 = attachments[1]
		local attachment3 = attachments[2]
		clone2.Attachment0 = attachment2
		clone2.Attachment1 = attachment3
		clone2.Parent = attachments[1]
		local motor6D = Instance.new("Motor6D", parent)
		motor6D.Name = "Weld"
		local root = self.Root
		motor6D.Part0 = parent
		motor6D.Part1 = root
		motor6D.C0 = CFrame.Angles(-1.5707963267948966, v2 * 3.141592653589793 / 2, 0) * CFrame.new(
			v2 * -0.5,
			-0.25 + self.Size / 3.5 + (self.R15 and -1.25 or 0),
			-0.25 + self.Size / 10
		)
		table.insert(wings2, {
			Wing = parent,
			Attachments = attachments
		})
	end

	for _, v2 in next, wings2, nil do
		v2.Wing.Parent = self.Root
	end

	self.Wings = wings2
	return self
end

function WingsOld.Update(data, p, value)
	local transparency = value or 0

	for k, wing in next, data.Wings, nil do
		local wing2 = wing.Wing
		local weld = wing2.Weld
		local attachments = wing.Attachments
		local v2 = k == 1 and 1 or -1

		for i = 1, 2 do
			local v3 = i == 1 and 0 or 1
			attachments[i].CFrame = CFrame.new(
				v2 * data.Size * 1.65 - v3 * v2 * data.Size * 0.25,
				data.Size * 0.5,
				-data.Size * 0.125
			)
		end

		wing2.Transparency = transparency
		wing2.Mesh.Scale = createVector(1, 1, 1) * data.Size
		weld.C0 = CFrame.Angles(-1.5707963267948966, v2 * 3.141592653589793 / 2 - v2 * p, 0) * CFrame.new(
			v2 * -0.5,
			-0.25 + data.Size / 3.5 + (data.R15 and -1.25 or 0),
			-0.25 + data.Size / 10
		)
	end

	return data
end

function WingsOld:Destroy()
	for _, wing in next, self.Wings, nil do
		for _, attachment in next, wing.Attachments, nil do
			Debris:AddItem(attachment, 5)
			attachment.CFrame = CFrame.new(attachment.WorldPosition)
			attachment.Parent = workspace.Terrain
		end

		wing.Wing:Destroy()
	end
end

return WingsOld