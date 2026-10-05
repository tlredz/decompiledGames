local terrain = workspace:WaitForChild("Terrain")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local util = ReplicatedStorage:WaitForChild("Util")
require(util:WaitForChild("Tween"))
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("MovementTrail", Enum.RenderPriority.Last.Value - 1, function(_)
	for k, v2 in pairs(v) do
		local width = v2.width
		local anchor = v2.anchor
		local offset = v2.offset
		local attachments = v2.attachments
		local v3 = tick() - v2.start

		if v2.duration * 2 < v3 then
			for _, attachment in next, attachments, nil do
				attachment:Destroy()
			end

			v2.trail:Destroy()
			v[k] = nil
		elseif v2.duration < v3 then
			v2.trail.Enabled = false
		elseif v3 < v2.duration then
			for k2, attachment in next, attachments, nil do
				attachment.CFrame = anchor.CFrame * offset * CFrame.new((k2 % 2 == 0 and 1 or -1) * width / 2, 0, 0)
			end
		end
	end
end)
return function(data)
	if not data.Anchor then
		return error("Apply an Anchor (BasePart)", 0)
	end

	local width = data.Width or 0.5
	local color = data.Color or Color3.new()
	local anchor = data.Anchor
	local offset = data.Offset or CFrame.new()
	local lifetime = data.Lifetime or 1
	local rotate = data.Rotate
	local attachments = {}

	for i = 1, 2 do
		local attachment = Instance.new("Attachment")
		attachment.CFrame = anchor.CFrame * offset * CFrame.new((i % 2 == 0 and 1 or -1) * width / 2, 0, 0)
		table.insert(attachments, attachment)
	end

	local clone = FX:WaitForChild("MovementTrail"):Clone()
	clone.Enabled = true
	clone.Color = ColorSequence.new(color)
	clone.Lifetime = lifetime
	local attachment2 = attachments[1]
	local attachment3 = attachments[2]
	clone.Attachment0 = attachment2
	clone.Attachment1 = attachment3

	for _, v5 in next, attachments, nil do
		v5.Parent = workspace.Terrain
	end

	clone.Parent = terrain
	table.insert(v, {
		start = tick(),
		trail = clone,
		attachments = attachments,
		anchor = anchor,
		offset = offset,
		width = width,
		duration = lifetime,
		rotate = rotate
	})
end