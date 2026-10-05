local createVector = vector.create
local HttpService = game:GetService("HttpService")
local Track = require(script.Parent.Track)
local PlaybackSession = {}
PlaybackSession.__index = PlaybackSession
local object = setmetatable({}, {
	__mode = "k"
})
local v = {
	position_scale = 200,
	direction_scale = 32767,
	brightness_scale = 1000,
	color_scale = 255,
	angle_scale = 100,
	opacity_scale = 255
}

local function finite(value, p: number)
	if type(value) == "number" and value == value and math.abs(value) < 1e999 then
		return value
	end

	return p
end

local function attribute(instance, attributeName: string, value: number, min: number, max: number)
	local attribute2 = instance:GetAttribute(attributeName)

	if type(attribute2) == "number" and attribute2 == attribute2 and math.abs(attribute2) < 1e999 then
		value = attribute2
	end

	return (math.clamp(value, min, max))
end

local function required(instance, childName: string)
	local selected = instance:FindFirstChild(childName) or instance:WaitForChild(childName, 30)
	assert(selected, (`ShowForge timed out waiting for {instance:GetFullName()}.{childName}`))
	return selected
end

local function readData(instance, flag: boolean)
	local dataChunks = instance:FindFirstChild("DataChunks") or instance:WaitForChild("DataChunks", 30)
	assert(dataChunks, (`ShowForge timed out waiting for {instance:GetFullName()}.DataChunks`))
	assert(dataChunks:IsA("Folder"), "ShowForge DataChunks must be a Folder")
	local children = dataChunks:GetChildren()
	assert(#children > 0, "ShowForge metadata is empty")
	table.sort(children, function(a, b)
		return a.Name < b.Name
	end)
	local v2 = table.create(#children)
	local total = 0

	for k, stringValue in children do
		assert(stringValue:IsA("StringValue"), "ShowForge metadata contains a non-string chunk")
		total += #stringValue.Value
		assert(total <= 16777216, "ShowForge metadata exceeds the client safety limit")
		v2[k] = stringValue.Value
	end

	local jSONDecode = HttpService:JSONDecode(table.concat(v2))
	local v3

	if type(jSONDecode) == "table" and jSONDecode.schema == "showforge.roblox.exchange" then
		v3 = jSONDecode.schema_version == 2 or jSONDecode.schema_version == 3
	else
		v3 = false
	end

	assert(v3, "ShowForge runtime metadata has an unsupported schema")
	local v4

	if type(jSONDecode.timeline) == "table" then
		local fps = jSONDecode.timeline.fps

		if ((type(fps) ~= "number" or fps ~= fps or not (math.abs(fps) < 1e999)) and 0 or fps) > 0 then
			local duration = jSONDecode.timeline.duration
			v4 = ((type(duration) ~= "number" or duration ~= duration or not (math.abs(duration) < 1e999)) and -1 or duration) >= 0
		else
			v4 = false
		end
	else
		v4 = false
	end

	assert(v4, "ShowForge runtime timeline is invalid")
	assert(type(jSONDecode.fixtures) == "table", "ShowForge runtime fixture metadata is missing")
	local v5 = jSONDecode.schema_version == 2 and "delta-varint-oct-v1" or "sparse-delta-varint-oct-v2"
	local v6

	if type(jSONDecode.animation) == "table" then
		v6 = jSONDecode.animation.codec == v5
	else
		v6 = false
	end

	assert(v6, "ShowForge animation codec is unsupported")

	if jSONDecode.schema_version == 2 then
		for k, v7 in v do
			assert(jSONDecode.animation[k] == v7, (`ShowForge animation {k} must be {v7}`))
		end
	end

	local v7 = {}

	for _, fixture in jSONDecode.fixtures do
		local v8

		if type(fixture) == "table" and type(fixture.id) == "string" then
			v8 = fixture.id ~= ""
		else
			v8 = false
		end

		assert(v8, "ShowForge fixture ID is invalid")
		assert(not v7[fixture.id], (`Duplicate ShowForge fixture ID {fixture.id}`))
		v7[fixture.id] = true
		local v9 = jSONDecode.schema_version == 2 and 1 or 0
		local v10

		if type(fixture.key_count) == "number" and v9 <= fixture.key_count then
			v10 = fixture.key_count % 1 == 0
		else
			v10 = false
		end

		assert(v10, (`Fixture {fixture.id} has an invalid key count`))
		assert(fixture.track_codec == v5, (`Fixture {fixture.id} has an unsupported track codec`))

		if jSONDecode.schema_version ~= 3 then
			continue
		end

		local v11

		if type(fixture.initial) == "string" then
			v11 = fixture.initial ~= ""
		else
			v11 = false
		end

		assert(v11, (`Fixture {fixture.id} has an invalid initial state`))
		local v12

		if type(fixture.channel_mask) == "number" and fixture.channel_mask >= 0 and fixture.channel_mask <= 2047 then
			v12 = fixture.channel_mask % 1 == 0
		else
			v12 = false
		end

		assert(v12, (`Fixture {fixture.id} has an invalid channel mask`))
		assert(
			fixture.channel_mask == 0 == (fixture.key_count == 0),
			(`Fixture {fixture.id} has inconsistent sparse animation metadata`)
		)
	end

	if not flag then
		dataChunks:Destroy()
	end

	return jSONDecode
end

local function load(instance, instance2, data, flag: boolean, bufsByAnimation_track)
	local fixtures = instance:FindFirstChild("Fixtures") or instance:WaitForChild("Fixtures", 30)
	assert(fixtures, (`ShowForge timed out waiting for {instance:GetFullName()}.Fixtures`))
	local beamTargetAnchor = instance:FindFirstChild("BeamTargetAnchor") or instance:WaitForChild(
		"BeamTargetAnchor",
		30
	)
	assert(beamTargetAnchor, (`ShowForge timed out waiting for {instance:GetFullName()}.BeamTargetAnchor`))
	local animationData = instance2:FindFirstChild("AnimationData") or instance2:WaitForChild("AnimationData", 30)
	assert(animationData, (`ShowForge timed out waiting for {instance2:GetFullName()}.AnimationData`))
	assert(
		fixtures:IsA("Folder") and beamTargetAnchor:IsA("BasePart") and animationData:IsA("Folder"),
		"ShowForge runtime hierarchy is invalid"
	)
	local v2 = instance2 ~= instance
	local fixturesById = {}

	for _, fixture in data.fixtures do
		fixturesById[fixture.id] = fixture
	end

	local result = {}
	local result2 = {}
	local count = 0

	for _, part in fixtures:GetChildren() do
		if not part:IsA("Part") then
			continue
		end

		local showForgeFixtureId = part:GetAttribute("ShowForgeFixtureId")
		local showForgeFixtureIndex = part:GetAttribute("ShowForgeFixtureIndex")

		if not (type(showForgeFixtureId) == "string" and type(showForgeFixtureIndex) == "number" and fixturesById[showForgeFixtureId]) then
			continue
		end

		assert(not result[showForgeFixtureId], (`Duplicate ShowForge fixture proxy {showForgeFixtureId}`))
		local v3 = fixturesById[showForgeFixtureId]

		if v2 then
			local v4

			if v3.animation_track == nil then
				v4 = true
			elseif type(v3.animation_track) == "string" then
				v4 = v3.animation_track ~= ""
			else
				v4 = false
			end

			assert(v4, (`Fixture {showForgeFixtureId} has an invalid animation track`))
		end

		local animation_track

		if v2 then
			animation_track = v3.animation_track
		else
			animation_track = part:GetAttribute("AnimationTrack")
		end

		local source = part:FindFirstChild("Source")
		local attachment = beamTargetAnchor:FindFirstChild(("Target_%05d"):format(showForgeFixtureIndex))
		assert(source and source:IsA("Attachment"), (`Fixture {showForgeFixtureId} has invalid source attachment`))
		local spotLight = source:FindFirstChild("SpotLight")
		local beam = source:FindFirstChild("Beam")
		assert(spotLight and spotLight:IsA("SpotLight"), (`Fixture {showForgeFixtureId} is missing SpotLight`))

		if v3.type == "STATIC_COLOR" then
			if beam and beam:IsA("Beam") then
				beam.Enabled = false
			end

			attachment = nil
			beam = nil
		else
			assert(
				attachment and attachment:IsA("Attachment"),
				(`Fixture {showForgeFixtureId} is missing target attachment`)
			)
			assert(beam and beam:IsA("Beam"), (`Fixture {showForgeFixtureId} is missing Beam`))
		end

		local buf = buffer.create(0)

		if type(animation_track) == "string" then
			buf = bufsByAnimation_track[animation_track]

			if not buf then
				local folder = animationData:FindFirstChild(animation_track)
				assert(
					folder and folder:IsA("Folder"),
					(`Fixture {showForgeFixtureId} references missing animation {animation_track}`)
				)
				buf = Track.decodeCompressedFolder(folder, flag)
				bufsByAnimation_track[animation_track] = buf
			end
		else
			local v4

			if data.schema_version == 3 then
				v4 = v3.key_count == 0
			else
				v4 = false
			end

			assert(v4, (`Fixture {showForgeFixtureId} has no animation track`))
		end

		result[showForgeFixtureId] = {
			Proxy = part,
			Target = attachment,
			Light = spotLight,
			Beam = beam,
			Last = {}
		}
		result2[showForgeFixtureId] = Track.new(
			buf,
			data.timeline.fps,
			v3.key_count,
			v3.initial,
			v3.channel_mask,
			false
		)
		count += 1
	end

	assert(count == #data.fixtures, (`ShowForge loaded {count} of {#data.fixtures} fixture references`))

	if not flag then
		animationData:Destroy()
	end

	return result, result2
end

local function cylinderCFrame(position: Vector3, direction: Vector3)
	local vector2 = not (direction.Magnitude > 1e-6) and createVector(1, 0, 0) or direction.Unit
	local unit = vector2:Cross(math.abs((vector2:Dot(createVector(0, 1, 0)))) < 0.98 and createVector(0, 1, 0) or createVector(
		0,
		0,
		1
	)).Unit
	return CFrame.fromMatrix(position, vector2, unit:Cross(vector2).Unit, unit)
end

local function staticProxySize(p: number)
	return (Vector3.new(0.18, p, p))
end

local function apply(model, data, fixture, data2, flag: boolean, flag2: boolean)
	if not data2 then
		return
	end

	local last = data.Last
	local lightScale = model:GetAttribute("LightScale")
	local v2 = math.clamp(
		(type(lightScale) ~= "number" or lightScale ~= lightScale or not (math.abs(lightScale) < 1e999)) and 1 or lightScale,
		0.01,
		100
	)
	local beamBaseMultiplier = model:GetAttribute("BeamBaseMultiplier")
	local base = math.clamp(
		(type(beamBaseMultiplier) ~= "number" or beamBaseMultiplier ~= beamBaseMultiplier or not (math.abs(beamBaseMultiplier) < 1e999)) and 1 or beamBaseMultiplier,
		0,
		100
	)
	local beamTopMultiplier = model:GetAttribute("BeamTopMultiplier")
	local top = math.clamp(
		(type(beamTopMultiplier) ~= "number" or beamTopMultiplier ~= beamTopMultiplier or not (math.abs(beamTopMultiplier) < 1e999)) and 1 or beamTopMultiplier,
		0,
		100
	)
	local lightPowerMultiplier = model:GetAttribute("LightPowerMultiplier")
	local v5 = math.clamp(
		(type(lightPowerMultiplier) ~= "number" or lightPowerMultiplier ~= lightPowerMultiplier or not (math.abs(lightPowerMultiplier) < 1e999)) and 1 or lightPowerMultiplier,
		0,
		100
	)
	local staticCylinderWidthMultiplier = model:GetAttribute("StaticCylinderWidthMultiplier")
	local staticWidth = math.clamp(
		(type(staticCylinderWidthMultiplier) ~= "number" or staticCylinderWidthMultiplier ~= staticCylinderWidthMultiplier or not (math.abs(staticCylinderWidthMultiplier) < 1e999)) and 1 or staticCylinderWidthMultiplier,
		0.01,
		100
	)
	local masterIntensity = model:GetAttribute("MasterIntensity")
	local v7 = math.clamp(
		(type(masterIntensity) ~= "number" or masterIntensity ~= masterIntensity or not (math.abs(masterIntensity) < 1e999)) and 1 or masterIntensity,
		0,
		1
	)
	local beam_length = fixture.beam_length
	local range = math.max(
		0.1,
		(type(beam_length) ~= "number" or beam_length ~= beam_length or not (math.abs(beam_length) < 1e999)) and 40 or beam_length
	) * v2

	if fixture.type == "STATIC_COLOR" and last.StaticWidth ~= staticWidth then
		data.Proxy.Size = Vector3.new(0.18, staticWidth, staticWidth)
		last.StaticWidth = staticWidth
	end

	local v9 = last.Position ~= data2.position or last.Direction ~= data2.direction

	if v9 then
		data.Proxy.CFrame = cylinderCFrame(data2.position, data2.direction)
		local position = data2.position
		local direction = data2.direction
		last.Position = position
		last.Direction = direction
	end

	if data.Target and (v9 or last.Range ~= range) then
		data.Target.Position = data2.position + data2.direction * range
	end

	if last.Color ~= data2.color then
		local proxy = data.Proxy
		local light = data.Light
		local color = data2.color
		local color2 = data2.color
		proxy.Color = color
		light.Color = color2

		if data.Beam then
			data.Beam.Color = ColorSequence.new(data2.color)
		end

		last.Color = data2.color
	end

	local brightness = data2.brightness
	local v10 = math.clamp(
		((type(brightness) ~= "number" or brightness ~= brightness or not (math.abs(brightness) < 1e999)) and 0 or brightness) * v7,
		0,
		100
	)
	local transparency

	if fixture.type == "STATIC_COLOR" then
		transparency = v10 <= 0.0001 and 1 or math.clamp(0.55 - v10 * 0.15, 0, 0.5)
	else
		transparency = math.clamp(1 - math.min(1, v10 * 0.15), 0.05, 1)
	end

	if last.Transparency ~= transparency then
		data.Proxy.Transparency = transparency
		last.Transparency = transparency
	end

	local brightness2 = math.clamp(v10 * v5, 0, 100)

	if last.Brightness ~= brightness2 then
		data.Light.Brightness = brightness2
		last.Brightness = brightness2
	end

	if last.Angle ~= data2.angle or last.Range ~= range or last.Base ~= base or last.Top ~= top then
		local angle = data2.angle
		local angle2 = math.clamp(
			(type(angle) ~= "number" or angle ~= angle or not (math.abs(angle) < 1e999)) and 1 or angle,
			1,
			180
		)
		local v14 = math.tan((math.rad(angle2 * 0.5)))
		local light = data.Light
		local light2 = data.Light
		local range2 = math.clamp(range, 0, 60)
		light.Angle = angle2
		light2.Range = range2

		if data.Beam then
			data.Beam.Width0 = math.max(0, range * v14 * 0.015 * base)
			data.Beam.Width1 = math.max(0, range * 2 * v14 * top)
		end

		last.Angle = data2.angle
		last.Range = range
		last.Base = base
		last.Top = top
	end

	if data.Beam and last.Opacity ~= data2.opacity then
		local opacity = data2.opacity
		local v13 = math.clamp(
			(type(opacity) ~= "number" or opacity ~= opacity or not (math.abs(opacity) < 1e999)) and 0 or opacity,
			0,
			1
		)
		data.Beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1 - v13),
			NumberSequenceKeypoint.new(0.82, 1 - v13 * 0.42),
			NumberSequenceKeypoint.new(1, 1)
		})
		last.Opacity = data2.opacity
	end

	local shadows

	if model:GetAttribute("EnableShadows") == true then
		shadows = fixture.shadows == true
	else
		shadows = false
	end

	if last.Shadows ~= shadows then
		data.Light.Shadows = shadows
		last.Shadows = shadows
	end

	local enabled = fixture.enabled ~= false

	if enabled then
		if not (brightness2 > 0.0001) then
			flag = false
		end
	else
		flag = enabled
	end

	if data.Beam == nil then
		flag2 = false
	elseif enabled then
		if v10 > 0.0001 then
			local opacity = data2.opacity

			if not (((type(opacity) ~= "number" or opacity ~= opacity or not (math.abs(opacity) < 1e999)) and 0 or opacity) > 0.0001) then
				flag2 = false
			end
		else
			flag2 = false
		end
	else
		flag2 = enabled
	end

	if last.LightEnabled ~= flag then
		data.Light.Enabled = flag
		last.LightEnabled = flag
	end

	if data.Beam and last.BeamEnabled ~= flag2 then
		data.Beam.Enabled = flag2
		last.BeamEnabled = flag2
	end
end

function PlaybackSession.new(model, data)
	assert(model:IsA("Model"), "ShowForge playback target must be a Model")
	local v2

	if data == nil then
		v2 = false
	else
		v2 = data.PreserveStorage == true
	end

	local datasetRoot

	if data and data.DatasetRoot then
		datasetRoot = data.DatasetRoot
	else
		datasetRoot = model
	end

	assert(
		datasetRoot == model or datasetRoot:IsDescendantOf(model),
		"ShowForge dataset must remain under the playback target"
	)
	local loop

	if data then
		loop = data.Loop
	end

	local timeOffset

	if data then
		timeOffset = data.TimeOffset
	end

	assert(loop == nil or type(loop) == "boolean", "ShowForge Loop option must be a boolean")
	assert(
		timeOffset == nil or ((type(timeOffset) ~= "number" or timeOffset ~= timeOffset or not (math.abs(timeOffset) < 1e999)) and 1e999 or timeOffset) ~= 1e999,
		"ShowForge TimeOffset option must be finite"
	)

	if timeOffset ~= nil then
		timeOffset = math.clamp(timeOffset, -3600, 3600)
	end

	local showForgeDataRevision = datasetRoot:GetAttribute("ShowForgeDataRevision") or 0
	local v3 = object[datasetRoot]

	if not v3 or v3.Revision ~= showForgeDataRevision then
		debug.profilebegin("ShowForge.DecodeMetadata")
		local success, result = pcall(readData, datasetRoot, v2)
		debug.profileend()

		if not success then
			error(result, 0)
		end

		v3 = {
			Revision = showForgeDataRevision,
			Data = result,
			Payloads = {}
		}
		object[datasetRoot] = v3
	end

	local v4 = assert(v3)
	local data2 = v4.Data
	debug.profilebegin("ShowForge.BuildSession")
	local success, result, tracks = pcall(load, model, datasetRoot, data2, v2, v4.Payloads)
	debug.profileend()

	if not success then
		error(result, 0)
	end

	return (setmetatable({
		Model = model,
		DatasetRoot = datasetRoot,
		Data = data2,
		Refs = result,
		Tracks = tracks,
		States = {},
		Loop = loop,
		TimeOffset = timeOffset,
		LastTime = nil,
		Destroyed = false
	}, PlaybackSession))
end

function PlaybackSession:Evaluate(value: number, _: number, _)
	assert(not self.Destroyed, "ShowForge playback session is destroyed")
	local duration = self.Data.timeline.duration
	local v2 = math.max(
		0,
		(type(duration) ~= "number" or duration ~= duration or not (math.abs(duration) < 1e999)) and 0 or duration
	)
	local timeOffset

	if self.DatasetRoot ~= self.Model then
		timeOffset = self.DatasetRoot:GetAttribute("TimeOffset")
	end

	local loop

	if self.DatasetRoot ~= self.Model then
		loop = self.DatasetRoot:GetAttribute("Loop")
	end

	local timeOffset2

	if self.TimeOffset == nil then
		if type(timeOffset) == "number" then
			timeOffset2 = math.clamp(
				(type(timeOffset) ~= "number" or timeOffset ~= timeOffset or not (math.abs(timeOffset) < 1e999)) and 0 or timeOffset,
				-3600,
				3600
			)
		else
			local timeOffset3 = self.Model:GetAttribute("TimeOffset")
			timeOffset2 = math.clamp(
				(type(timeOffset3) ~= "number" or timeOffset3 ~= timeOffset3 or not (math.abs(timeOffset3) < 1e999)) and 0 or timeOffset3,
				-3600,
				3600
			)
		end
	else
		timeOffset2 = self.TimeOffset
	end

	if self.Loop == nil then
		if type(loop) ~= "boolean" then
			loop = self.Model:GetAttribute("Loop") == true
		end
	else
		loop = self.Loop
	end

	local lastTime = math.max(
		0,
		((type(value) ~= "number" or value ~= value or not (math.abs(value) < 1e999)) and 0 or value) + timeOffset2
	)

	if v2 > 0 then
		if loop then
			lastTime %= v2
		else
			lastTime = math.clamp(lastTime, 0, v2)
		end
	end

	if self.LastTime ~= lastTime then
		for _, fixture in self.Data.fixtures do
			self.States[fixture.id] = self.Tracks[fixture.id]:Sample(lastTime)
		end

		self.LastTime = lastTime
	end

	for _, fixture in self.Data.fixtures do
		apply(self.Model, self.Refs[fixture.id], fixture, self.States[fixture.id], true, true)
	end
end

function PlaybackSession:Disable()
	for _, ref in self.Refs do
		ref.Light.Enabled = false

		if ref.Beam then
			ref.Beam.Enabled = false
		end

		ref.Proxy.Transparency = 1
		local last = ref.Last
		local last2 = ref.Last
		last.LightEnabled = false
		last2.BeamEnabled = false
		ref.Last.Transparency = nil
	end
end

function PlaybackSession.IsValid(data)
	if data.Destroyed or not data.Model.Parent or data.DatasetRoot ~= data.Model and not data.DatasetRoot:IsDescendantOf(data.Model) then
		return false
	end

	for _, ref in data.Refs do
		if not ref.Proxy:IsDescendantOf(data.Model) then
			return false
		end
	end

	return true
end

function PlaybackSession:Destroy()
	if self.Destroyed then
		return
	end

	self:Disable()
	self.Destroyed = true
	table.clear(self.Refs)
	table.clear(self.Tracks)
	table.clear(self.States)
end

return PlaybackSession