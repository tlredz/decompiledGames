local createVector = vector.create
game:GetService("Players")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local precipitation = game.ReplicatedStorage.Controllers.WeatherController.Precipitation
local TableUtil = require(game.ReplicatedStorage.Modules.TableUtil)
local module = require(precipitation)
local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
local copy = TableUtil.deepCopy(require(precipitation._Config))
copy.CHECK_CHARACTER_INSIDE = true
local v = module.new(script.Name, copy)
local soundGroup = Instance.new("SoundGroup")
soundGroup.Name = ("Environment:%s"):format(script.Name)
soundGroup.Volume = 0.65
local sound = Instance.new("Sound")
sound.Looped = true
sound.SoundId = ""
sound.Volume = 0
sound.SoundGroup = soundGroup
sound.Parent = soundGroup
soundGroup.Parent = game:GetService("SoundService")
Groups.registerSatellite(soundGroup, "LowPriority")
table.insert(v.prepareEffects, function()
	sound.SoundId = "rbxassetid://1516791621"
end)
v.sound = sound
local clone = script.RainTrail.Particle_1:Clone()
clone.Name = "Straight"
clone.Rate = 0
clone.Speed = NumberRange.new(copy.STRAIGHT_MIN_SPEED)
clone.Parent = v.emitter
local children = script.WaterSplashes:GetChildren()
local splashAttachments = {}
local occludedAttachments = {}

for i = 1, copy.OCCLUDED_SPLASH_NUM do
	local attachment = Instance.new("Attachment")
	attachment.Name = ("_Splash%sAttachment"):format(script.Name)

	for _, emitter in pairs(children[i % 5 + 1]:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone2 = emitter:Clone()
		clone2.LockedToPart = false
		clone2.Parent = attachment
	end

	table.insert(v.prepareEffects, function()
		attachment.Parent = workspace.Terrain
	end)
	table.insert(splashAttachments, attachment)
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = ("_Occluded%sAttachment"):format(script.Name)
	local clone2 = clone:Clone()
	clone2.Name = "Occluded"
	clone2.Parent = attachment2
	table.insert(v.prepareEffects, function()
		attachment2.Parent = workspace.Terrain
	end)
	table.insert(occludedAttachments, attachment2)
end

local clone2 = script.CameraFocus:Clone()

for _, child in pairs(clone2:GetChildren()) do
	child:SetAttribute("OriginalRate", child.Rate)
	child:SetAttribute("OriginalSpeedMin", child.Speed.Min)
	child:SetAttribute("OriginalSpeedMax", child.Speed.Max)
end

table.insert(v.prepareEffects, function()
	clone2.Parent = workspace._WorldOrigin
end)
local clone3 = script.GroundDroplets:Clone()
table.insert(v.prepareEffects, function()
	clone3.Parent = workspace._WorldOrigin
end)
v.occludedAttachments = occludedAttachments
v.splashAttachments = splashAttachments
v.cameraFocus = {
	{ clone2, function(p)
			return CFrame.new(p.Position)
		end }
}
v.walkEffect = clone3
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Name = "RainCorrection"
colorCorrectionEffect:SetAttribute("ActiveColor", Color3.fromRGB(164, 185, 255))
colorCorrectionEffect.Enabled = false
colorCorrectionEffect.Parent = game.Lighting
v.colorCorrection = colorCorrectionEffect
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = {
	workspace:WaitForChild("Characters"),
	workspace:WaitForChild("Enemies"),
	workspace:WaitForChild("_WorldOrigin")
}
local AttachmentPair = require(game.ReplicatedStorage.Util.AttachmentPair)
local Misc = require(game.ReplicatedStorage.Util.Misc)
local alignCFrame = Misc.AlignCFrame
require(game.ReplicatedStorage.Util.Debris)
local HeartbeatLoopFor = require(game.ReplicatedStorage.Util.HeartbeatLoopFor)
local awaitHeartbeatLoopFor = HeartbeatLoopFor.AwaitHeartbeatLoopFor
local folder = Instance.new("Folder")
folder.Name = "WaterSplashes"
local v4 = {}

for _, child in pairs(script.WaterSplashes:GetChildren()) do
	local clone4 = child:Clone()
	clone4.Parent = folder
	local v5 = {}

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			table.insert(v5, { emitter, emitter:GetAttribute("EmitCount") })
		end
	end

	table.insert(v4, function(cFrame)
		clone4.CFrame = cFrame

		for k, v8 in pairs(v5) do
			v8[1]:Emit(v8[2])
		end
	end)
end

table.insert(v.prepareEffects, function()
	folder.Parent = workspace._WorldOrigin
end)
local submergedIsland = workspace._WorldOrigin.Locations:FindFirstChild("Submerged Island")
local v5 = {}

function v.specialEffect(cframe: CFrame, vector2: Vector3, range: NumberRange)
	local v6 = math.random(-vector2.X, vector2.X)
	local Y = vector2.Y
	local v7 = math.random(-vector2.Z, vector2.Z)
	local v8 = cframe * CFrame.new(v6, Y, v7)
	local raycastResult = workspace:Raycast(v8.Position, createVector(-0, -800, -0), raycastParams)
	local vector3 = Vector3.new(v8.X, -4, v8.Z)
	local v9

	if submergedIsland and (vector3 - submergedIsland.Position).Magnitude < submergedIsland.Mesh.Scale.Magnitude / 4 then
		raycastResult = nil
		v9 = 9999
	else
		v9 = -3.99
	end

	if raycastResult then
		vector3 = Vector3.new(
			raycastResult.Position.X,
			math.max(-4, raycastResult.Position.Y),
			raycastResult.Position.Z
		)
	end

	local count = #v5
	local v10

	if v5[count] then
		v10 = v5[count]
		table.remove(v5, count)
		v10:setRelativeCFrame(v8)
		task.spawn(function()
			RunService.RenderStepped:Wait()
			v10.attachment0.Trail.Enabled = true
		end)
	else
		v10 = AttachmentPair.new(CFrame.new(0.7, 0, 0), CFrame.new(-0.7, 0, 0))
		v10:hookUp(script.RainTrailOriginal.TrailAttach1.Trail:Clone())
	end

	local magnitude = (v8.Position - vector3).Magnitude
	local v11 = math.random(range.Min, range.Max) / 40
	awaitHeartbeatLoopFor(magnitude / 800 * v11, function(_, _, p)
		v10:setRelativeCFrame(CFrame.new(v8.Position + (vector3 - v8.Position) * p))
	end)
	v10:setRelativeCFrame(CFrame.new(vector3))
	task.delay(v10.attachment0.Trail.Lifetime + 0.05, function()
		v10.attachment0.Trail.Enabled = false
		RunService.RenderStepped:Wait()
		table.insert(v5, v10)
	end)

	if raycastResult or vector3.Y < v9 then
		local normal = raycastResult and raycastResult.Normal or createVector(0, 1, 0)
		v4[math.random(1, #v4)](alignCFrame(CFrame.new(vector3), normal) + normal * 0.01)
	end
end

return v:_Init()