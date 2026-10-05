local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spotlight = {}
Spotlight.__index = Spotlight

function Spotlight.new(data)
	local object = setmetatable({}, Spotlight)
	object._colorSpeed = data.colorSpeed or 0.12
	object._cameraOffset = data.cameraOffset or CFrame.new(0, 20, -50)
	object._range = data.range or 30
	object._speed = data.speed or 1.5
	object._ccSpeed = data.ccSpeed
	return object
end

function Spotlight.setup(_, p, parent, maid)
	local spotlight = ReplicatedStorage:FindFirstChild("Spotlight")

	if spotlight and spotlight:IsA("Model") then
		local folder = maid:Add(spotlight:Clone())

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Massless = true
		end

		folder.Parent = parent
		local pivot = folder:GetPivot()
		local beams = {}
		local entries = {}

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.Name == "Part" then
				local attachment = descendant:FindFirstChildOfClass("Attachment")

				if attachment then
					table.insert(entries, {
						part = descendant,
						partOffset = pivot:ToObjectSpace(descendant.CFrame),
						attachment = attachment,
						attachmentBasePosition = attachment.Position,
						randomOffset = math.random() * 100,
						speed = math.random(80, 140) / 100
					})
				end
			elseif descendant:IsA("Beam") then
				table.insert(beams, {
					beam = descendant,
					colorOffset = math.random()
				})
			end
		end

		p._spotlight = {
			model = folder,
			entries = entries,
			beams = beams
		}
	else
		warn("[Spotlight] Modèle \"Spotlight\" introuvable dans ReplicatedStorage")
		p._spotlight = {
			entries = {},
			beams = {}
		}
	end
end

function Spotlight:update(p, p2, parent)
	local _spotlight = p._spotlight

	if not _spotlight then
		return
	end

	local model = _spotlight.model

	if model then
		if model.Parent ~= parent then
			model.Parent = parent
		end

		local v = CFrame.new(parent.CFrame.Position) * self._cameraOffset

		for _, entry in _spotlight.entries do
			entry.part.CFrame = v * entry.partOffset
			local v2 = (p2 + entry.randomOffset) * self._speed * entry.speed
			entry.attachment.Position = entry.attachmentBasePosition + Vector3.new(
				math.sin(v2) * self._range,
				0,
				math.sin(v2 * 0.7) * self._range
			)
		end
	end

	for _, beam in _spotlight.beams do
		if not beam.beam.Parent then
			continue
		end

		local v = (p2 * self._colorSpeed + beam.colorOffset) % 1
		beam.beam.Color = ColorSequence.new(Color3.fromHSV(v, 1, 1))
	end

	if self._ccSpeed and p._cc and p._cc.Parent then
		local v = p2 * self._ccSpeed % 1
		p._cc.TintColor = Color3.fromHSV(v, 0.25, 1)
	end
end

return Spotlight