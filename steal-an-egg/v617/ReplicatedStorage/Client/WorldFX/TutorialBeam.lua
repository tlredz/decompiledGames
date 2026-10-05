local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	stockName = "TutorialBeam",
	anchorPin = "TutorialBeamTargetAttachment",
	followerPin = "TutorialBeamPlayerAttachment",
	rootPart = "HumanoidRootPart",
	rootPartTimeout = 5,
	drifterProperties = {
		Anchored = true,
		CanCollide = false,
		Name = "TutorialBeamContainer",
		Size = vector.create(1, 1, 1),
		Transparency = 1
	},
	beamProperties = {
		Enabled = false,
		FaceCamera = true
	}
}
local localPlayer = Players.LocalPlayer
local tutorialBeam = ReplicatedStorage.Assets.Extra.TutorialBeam

local function dress(p, items)
	for k, item in items do
		p[k] = item
	end

	return p
end

local function demandAnchor(part, p: string)
	local v2

	if typeof(part) == "Vector3" then
		v2 = true
	elseif typeof(part) == "Instance" then
		v2 = part:IsA("BasePart")
	else
		v2 = false
	end

	assert(v2, (`{p} needs a BasePart or a Vector3`))
end

local function pinTo(part, object)
	local attachment = Instance.new("Attachment")
	attachment.Name = v.anchorPin

	if typeof(part) ~= "Vector3" then
		attachment.Parent = part
		return attachment, nil
	end

	local part2 = Instance.new("Part")

	for k, drifterProperty in v.drifterProperties do
		part2[k] = drifterProperty
	end

	part2.Position = part
	part2.Parent = workspace
	object:Add(part2)
	attachment.Parent = part2
	return attachment, part2
end

local function rideCharacter(data)
	local character = data.owner.Character
	local part

	if character then
		part = character:WaitForChild(v.rootPart, v.rootPartTimeout)
	end

	if part == nil or not part:IsA("BasePart") then
		data.beam.Enabled = false
		return
	end

	local pins = data.pins

	if pins.follower then
		data.scope:Remove(pins.follower)
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = v.followerPin
	attachment.Parent = part
	pins.follower = data.scope:Add(attachment)
	data.beam.Attachment0 = attachment
	data.beam.Enabled = true
end

local TutorialBeam = {}

function TutorialBeam.Retarget(data, part)
	t.strict(t.table)(data)
	local v2

	if typeof(part) == "Vector3" then
		v2 = true
	elseif typeof(part) == "Instance" then
		v2 = part:IsA("BasePart")
	else
		v2 = false
	end

	assert(v2, "beam retarget needs a BasePart or a Vector3")
	local pins = data.pins

	if typeof(part) == "Vector3" and pins.drifter ~= nil then
		pins.drifter.Position = part
		return
	end

	if part == pins.anchor.Parent then
		return
	end

	data.scope:Remove(pins.anchor)

	if pins.drifter ~= nil then
		data.scope:Remove(pins.drifter)
	end

	local anchor, drifter = pinTo(part, data.scope)
	pins.anchor = anchor
	pins.drifter = drifter
	data.scope:Add(pins.anchor)
	data.beam.Attachment1 = pins.anchor
end

function TutorialBeam:Destroy()
	t.strict(t.table)(self)
	self.scope:Destroy()
end

function TutorialBeam.Attach(part, p)
	local v2

	if typeof(part) == "Vector3" then
		v2 = true
	elseif typeof(part) == "Instance" then
		v2 = part:IsA("BasePart")
	else
		v2 = false
	end

	assert(v2, "beam anchor needs a BasePart or a Vector3")
	local scope = Trove.new()
	local v4, drifter = pinTo(part, scope)
	scope:Add(v4)
	local v6

	if p and p.Template then
		v6 = p.Template
	else
		v6 = tutorialBeam
	end

	local clone = v6:Clone()

	for k, beamProperty in v.beamProperties do
		clone[k] = beamProperty
	end

	local name

	if p and p.BeamName then
		name = p.BeamName
	else
		name = v.stockName
	end

	clone.Name = name
	clone.Attachment1 = v4
	clone.Parent = workspace
	scope:Add(clone)
	local v8 = {
		scope = scope,
		beam = clone,
		owner = localPlayer,
		pins = {
			anchor = v4,
			follower = nil,
			drifter = drifter
		}
	}
	rideCharacter(v8)

	local function remountOn(instance)
		if instance:WaitForChild(v.rootPart, v.rootPartTimeout) then
			rideCharacter(v8)
		end
	end

	scope:Connect(localPlayer.CharacterAdded, function(p2)
		task.spawn(remountOn, p2)
	end)
	return v8
end

return TutorialBeam