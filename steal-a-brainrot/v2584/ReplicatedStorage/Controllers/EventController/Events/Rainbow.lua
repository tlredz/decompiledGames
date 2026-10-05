local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Rainbow = {}
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local _ = script.Name
local rainbow = workspace.Events.Rainbow
local model = nil

if ServerData.IsBiggerServer() then
	rainbow:PivotTo(CFrame.new(-385.131, 18.845, -292.449) * CFrame.fromOrientation(
		0.0586954227445693,
		-1.0170033551370958,
		0.4295604355008444
	))
elseif ServerData.IsJumpLTMServer() then
	model = Instance.new("Model")
	model.Name = "RainbowAmbient"

	for _, model2 in rainbow.Enabled:GetChildren() do
		if model2:IsA("Model") and model2:FindFirstChild("AmbientRainbow") then
			model2.Parent = model
		end
	end
end

local function getJumpLTMBounds()
	local minX = 1e999
	local maxX = -1e999
	local minZ = 1e999
	local maxZ = -1e999
	local minY = 1e999
	local maxY = -1e999

	local function accumulate(p)
		local position = p.Position
		local size = p.Size
		minX = math.min(minX, position.X - size.X / 2)
		maxX = math.max(maxX, position.X + size.X / 2)
		minZ = math.min(minZ, position.Z - size.Z / 2)
		maxZ = math.max(maxZ, position.Z + size.Z / 2)
		minY = math.min(minY, position.Y - size.Y / 2)
		maxY = math.max(maxY, position.Y + size.Y / 2)
	end

	local track = workspace.Map:FindFirstChild("Track")

	if track then
		for _, v7 in track:QueryDescendants("BasePart"), nil, nil do
			accumulate(v7)
		end
	end

	local mapFloor = workspace.Map:FindFirstChild("MapFloor")

	if mapFloor and mapFloor:IsA("BasePart") then
		accumulate(mapFloor)
	end

	if maxX < minX then
		return nil
	end

	return {
		MinX = minX,
		MaxX = maxX,
		MinZ = minZ,
		MaxZ = maxZ,
		MinY = minY,
		MaxY = maxY
	}
end

local flag = false

local function relocateJumpLTMArc()
	if flag then
		return
	end

	local jumpLTMBounds = getJumpLTMBounds()

	if not jumpLTMBounds then
		warn("Rainbow: no map bounds, arc left at authored spot")
		return
	end

	local worldPosition = nil
	local position = nil

	for _, part in rainbow.Enabled:GetChildren() do
		if part:HasTag("ShowIn3Roads") or not part:IsA("BasePart") then
			continue
		end

		if part.Name == "SmokePt2" then
			worldPosition = part.RainbowEnd.Wiggler.AttachmentBeam2.WorldPosition
		elseif part.Name == "gaterainbow" then
			position = part.Position
		end
	end

	if not (worldPosition and position) then
		warn("Rainbow: arc anchors not found, arc left at authored spot")
		return
	end

	local midpoint = (jumpLTMBounds.MinX + jumpLTMBounds.MaxX) / 2
	local midpoint2 = (jumpLTMBounds.MinZ + jumpLTMBounds.MaxZ) / 2
	local v3 = math.max(jumpLTMBounds.MaxX - jumpLTMBounds.MinX, jumpLTMBounds.MaxZ - jumpLTMBounds.MinZ) / 2 + 300
	local v4 = math.atan2(position.Z - midpoint2, position.X - midpoint)
	local v5 = jumpLTMBounds.MinY + 60
	local vector2 = Vector3.new(
		midpoint + math.cos(v4 - 0.6108652381980153) * v3,
		v5,
		midpoint2 + math.sin(v4 - 0.6108652381980153) * v3
	)
	local vector3 = Vector3.new(
		midpoint + math.cos(v4 + 0.6108652381980153) * v3,
		v5,
		midpoint2 + math.sin(v4 + 0.6108652381980153) * v3
	)
	local v6 = (vector3 - vector2).Magnitude / (position - worldPosition).Magnitude
	local v7 = vector2 - worldPosition
	local v8 = vector3 - position
	flag = true

	for _, part in rainbow.Enabled:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name == "RainbowMain" then
			local attachment3 = part.RainbowHandle.Wiggler.Attachment3
			attachment3.WorldPosition += v8

			for _, beam in attachment3:GetChildren() do
				if not beam:IsA("Beam") then
					continue
				end

				beam.CurveSize0 *= v6
				beam.CurveSize1 *= v6
				beam.Width0 *= v6
				beam.Width1 *= v6
				beam.Segments = math.min(math.ceil(beam.Segments * v6), 80)
			end
		elseif part.Name == "SmokePt2" then
			local attachmentBeam2 = part.RainbowEnd.Wiggler.AttachmentBeam2
			local worldPosition2 = attachmentBeam2.WorldPosition
			part:PivotTo(CFrame.new(part.Position + v8) * part.CFrame.Rotation)
			attachmentBeam2.WorldPosition = worldPosition2 + v7
		elseif part.Name == "gaterainbow" then
			part:PivotTo(CFrame.new(part.Position + v8) * part.CFrame.Rotation)
		end
	end
end

local function coverJumpLTMRing(model2)
	local jumpLTMBounds = getJumpLTMBounds()

	if not jumpLTMBounds then
		warn("Rainbow: no map bounds, ambient ring skipped")
		return nil
	end

	local minY = jumpLTMBounds.MinY
	local maxY = jumpLTMBounds.MaxY
	local midpoint = (jumpLTMBounds.MinX + jumpLTMBounds.MaxX) / 2
	local midpoint2 = (jumpLTMBounds.MinZ + jumpLTMBounds.MaxZ) / 2
	local v3 = math.max(jumpLTMBounds.MaxX - jumpLTMBounds.MinX, jumpLTMBounds.MaxZ - jumpLTMBounds.MinZ) / 2 + 250
	local descendants = model2:QueryDescendants("BasePart")

	if #descendants == 0 then
		return nil
	end

	local folder = Instance.new("Folder")
	folder.Name = "JumpLTMRainbowRing"
	local count = 0

	for i = 0, math.clamp(math.ceil((maxY - minY) / 250), 1, 8) - 1 do
		local v4 = minY + 125 + i * 250

		for i2 = 0, 5 do
			local v5 = (i2 + i % 2 / 2) / 6 * 2 * 3.141592653589793
			local vector2 = Vector3.new(midpoint + math.cos(v5) * v3, v4, midpoint2 + math.sin(v5) * v3)
			count += 1
			local clone = descendants[(count - 1) % #descendants + 1]:Clone()
			clone.Size *= createVector(3, 3, 1)

			for _, v6 in clone:QueryDescendants("ParticleEmitter"), nil, nil do
				local numberSequenceKeypoints = {}

				for _, keypoint in v6.Size.Keypoints do
					local v7 = math.min(keypoint.Value * 3, 10)
					local v8 = math.min(keypoint.Envelope * 3, 10 - v7)
					table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v7, v8))
				end

				v6.Size = NumberSequence.new(numberSequenceKeypoints)
				v6.Enabled = true
			end

			clone.CFrame = CFrame.lookAt(vector2, (Vector3.new(midpoint, v4, midpoint2)))
			clone.Parent = folder
		end
	end

	folder.Parent = workspace
	local flag2 = false
	return function()
		if flag2 then
			return
		end

		flag2 = true

		for _, v4 in folder:QueryDescendants("ParticleEmitter"), nil, nil do
			v4.Enabled = false
		end

		task.delay(4, function()
			folder:Destroy()
		end)
	end
end

local maid = Trove.new()

function Rainbow.OnStart(_)
	CycleController:Update()
	SoundController:UpdateOST()
	VFX.emit(rainbow.Emit)
	maid:Add(task.spawn(function()
		SoundController:PlaySound(
			"Sounds.Sfx.RainbowActivatedEffect",
			rainbow.SoundParts.RainbowActivatedEffect.Position
		)
	end))
	maid:Add(task.spawn(function()
		SoundController:PlaySound("Sounds.Sfx.RainbowMachineEnabled", rainbow.SoundParts.RainbowMachineEnabled.Position)
	end))

	if model then
		relocateJumpLTMArc()
		local v = coverJumpLTMRing(model)

		if v then
			maid:Add(v)
		end
	end

	maid:Add(Observers.observeTag("RainbowEventAttachment", function(instance)
		local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(
				1,
				1
			) })
		local children = instance:GetChildren()

		for _, v in children do
			v.Transparency = numberSequence
			v.Enabled = true
		end

		local serverTimeNow = workspace:GetServerTimeNow()

		while instance:IsDescendantOf(workspace) do
			local serverTimeNow2 = workspace:GetServerTimeNow()
			local v = (serverTimeNow2 - serverTimeNow) % 3.5 / 3.5
			local numberSequence2 = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1 - v, 1),
				NumberSequenceKeypoint.new(1, 0)
			})

			if serverTimeNow2 - serverTimeNow >= 3.5 then
				for _, v2 in children do
					v2.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0)
					})
				end

				break
			else
				for _, v2 in children do
					v2.Transparency = numberSequence2
				end

				task.wait()
			end
		end

		return nil
	end, { workspace }))
	maid:Add(Observers.observeChildren(rainbow.Enabled, function(p)
		VFX.enable(p)
		return function()
			VFX.disable(p)
		end
	end))
end

function Rainbow.OnStop(_)
	maid:Destroy()
end

function Rainbow.OnLoad(_) end

return Rainbow