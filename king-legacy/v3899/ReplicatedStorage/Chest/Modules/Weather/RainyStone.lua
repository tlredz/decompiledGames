local createVector = vector.create
local color = Color3.new(1, 1, 1)
local numberSequence = NumberSequence.new(10)
local numberRange = NumberRange.new(0.8)
local numberSequence2 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 5.33, 2.75),
	NumberSequenceKeypoint.new(1, 5.33, 2.75)
})
local numberRange2 = NumberRange.new(0.8)
local numberRange3 = NumberRange.new(0, 360)
local numberSequence3 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.4, 3),
	NumberSequenceKeypoint.new(1, 0)
})
local numberRange4 = NumberRange.new(0.1, 0.15)
local numberRange5 = NumberRange.new(0, 360)
local vector2 = Vector2.new(10, 10)
local collisionMode = {
	None = 0,
	Whitelist = 1,
	Blacklist = 2,
	Function = 3
}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local numberValue = Instance.new("NumberValue")
numberValue.Value = 1
local none = collisionMode.None
local new = Vector3.new
local numberSequenceKeypoint = NumberSequenceKeypoint.new(0, 1, 0)
local numberSequenceKeypoint2 = NumberSequenceKeypoint.new(1, 1, 0)
local v2 = {}
local volume2 = 0
local filterDescendantsInstances = nil
local v5 = nil
local connections = {}
local unit = createVector(0, -1, 0)
local v6 = nil
local v7 = true
local v8 = 1
local v9 = 1
local v10 = 0
local v11 = 0

for _, v12 in pairs({
	createVector(0.14142136, 0, 0.14142136),
	createVector(-0.14142136, 0, 0.14142136),
	createVector(-0.14142136, 0, -0.14142136),
	createVector(0.14142136, 0, -0.14142136),
	createVector(0.4, 0, 0),
	createVector(0.28284273, 0, 0.28284273),
	createVector(2.4492937e-17, 0, 0.4),
	createVector(-0.28284273, 0, 0.28284273),
	createVector(-0.4, 0, 4.8985874e-17),
	createVector(-0.28284273, 0, -0.28284273),
	createVector(-7.3478805e-17, 0, -0.4),
	createVector(0.28284273, 0, -0.28284273),
	createVector(0.6, 0, 0),
	createVector(0.4854102, 0, 0.35267115),
	createVector(0.1854102, 0, 0.57063395),
	createVector(-0.1854102, 0, 0.57063395),
	createVector(-0.4854102, 0, 0.35267115),
	createVector(-0.6, 0, 7.347881e-17),
	createVector(-0.4854102, 0, -0.35267115),
	createVector(-0.1854102, 0, -0.57063395),
	createVector(0.1854102, 0, -0.57063395),
	createVector(0.4854102, 0, -0.35267115),
	createVector(0.77274066, 0, 0.20705524),
	createVector(0.56568545, 0, 0.56568545),
	createVector(0.20705524, 0, 0.77274066),
	createVector(-0.20705524, 0, 0.77274066),
	createVector(-0.56568545, 0, 0.56568545),
	createVector(-0.77274066, 0, 0.20705524),
	createVector(-0.77274066, 0, -0.20705524),
	createVector(-0.56568545, 0, -0.56568545),
	createVector(-0.20705524, 0, -0.77274066),
	createVector(0.20705524, 0, -0.77274066),
	createVector(0.56568545, 0, -0.56568545),
	createVector(0.77274066, 0, -0.20705524)
}) do
	table.insert(v2, v12 * 35)
end

table.sort(v2, function(a, b)
	return a.magnitude < b.magnitude
end)
local soundGroup = Instance.new("SoundGroup")
soundGroup.Name = "__RainSoundGroup"
soundGroup.Volume = 0
soundGroup.Archivable = false
local sound = Instance.new("Sound")
sound.Name = "RainSound"
sound.Volume = volume2
sound.SoundId = "rbxassetid://1516791621"
sound.Looped = true
sound.SoundGroup = soundGroup
sound.Parent = soundGroup
sound.Archivable = false
local part = Instance.new("Part")
part.Transparency = 1
part.Anchored = true
part.CanCollide = false
part.CanTouch = false
part.Locked = false
part.Archivable = false
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
part.CanTouch = false
part.Name = "__RainEmitter"
part.Size = createVector(0.05, 0.05, 0.05)
part.Archivable = false
local particleEmitter = Instance.new("ParticleEmitter")
particleEmitter.Name = "RainStraight"
particleEmitter.LightEmission = 0.05
particleEmitter.LightInfluence = 0.9
particleEmitter.Size = numberSequence
particleEmitter.Texture = "rbxassetid://1822883048"
particleEmitter.LockedToPart = true
particleEmitter.Enabled = false
particleEmitter.Lifetime = numberRange
particleEmitter.Rate = 200
particleEmitter.Speed = NumberRange.new(60)
particleEmitter.EmissionDirection = Enum.NormalId.Bottom
particleEmitter.Parent = part
local particleEmitter2 = Instance.new("ParticleEmitter")
particleEmitter2.Name = "RainTopDown"
particleEmitter2.LightEmission = 0.05
particleEmitter2.LightInfluence = 0.9
particleEmitter2.Size = numberSequence2
particleEmitter2.Texture = "rbxassetid://1822856633"
particleEmitter2.LockedToPart = true
particleEmitter2.Enabled = false
particleEmitter2.Rotation = numberRange3
particleEmitter2.Lifetime = numberRange2
particleEmitter2.Rate = 200
particleEmitter2.Speed = NumberRange.new(60)
particleEmitter2.EmissionDirection = Enum.NormalId.Bottom
particleEmitter2.Parent = part
local v12 = {}
local v13 = {}

for _ = 1, 20 do
	local attachment = Instance.new("Attachment")
	attachment.Name = "__RainSplashAttachment"
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.LightEmission = 0.05
	particleEmitter3.LightInfluence = 0.9
	particleEmitter3.Size = numberSequence3
	particleEmitter3.Texture = "rbxassetid://1822856633"
	particleEmitter3.Rotation = numberRange5
	particleEmitter3.Lifetime = numberRange4
	particleEmitter3.Transparency = NumberSequence.new({
		numberSequenceKeypoint,
		NumberSequenceKeypoint.new(0.25, 0.6, 0),
		NumberSequenceKeypoint.new(0.75, 0.6, 0),
		numberSequenceKeypoint2
	})
	particleEmitter3.Enabled = false
	particleEmitter3.Rate = 0
	particleEmitter3.Speed = NumberRange.new(0)
	particleEmitter3.Name = "RainSplash"
	particleEmitter3.Parent = attachment
	attachment.Archivable = false
	table.insert(v12, attachment)
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "__RainOccludedAttachment"
	local clone = part.RainStraight:Clone()
	clone.Speed = NumberRange.new(70, 100)
	clone.SpreadAngle = vector2
	clone.LockedToPart = false
	clone.Enabled = false
	clone.Parent = attachment2
	local clone2 = part.RainTopDown:Clone()
	clone2.Speed = NumberRange.new(70, 100)
	clone2.SpreadAngle = vector2
	clone2.LockedToPart = false
	clone2.Enabled = false
	clone2.Parent = attachment2
	attachment2.Archivable = false
	table.insert(v13, attachment2)
end

local filterDescendantsInstances2 = { part }
local v15 = {
	[collisionMode.None] = function(p, p2)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = p2 and {
			part,
			Players.LocalPlayer and Players.LocalPlayer.Character
		} or filterDescendantsInstances2
		local raycastResult = workspace:Raycast(p.Origin, p.Direction, raycastParams)
		local position = p.Origin + p.Direction
		local instance, normal

		if raycastResult then
			instance = raycastResult.Instance
			position = raycastResult.Position
			normal = raycastResult.Normal
		else
			normal = createVector(0, -1, 0)
		end

		return instance, position, normal
	end,
	[collisionMode.Blacklist] = function(p)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = workspace:Raycast(p.Origin, p.Direction, raycastParams)
		local position = p.Origin + p.Direction
		local instance, normal

		if raycastResult then
			instance = raycastResult.Instance
			position = raycastResult.Position
			normal = raycastResult.Normal
		else
			normal = createVector(0, -1, 0)
		end

		return instance, position, normal
	end,
	[collisionMode.Whitelist] = function(p)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = workspace:Raycast(p.Origin, p.Direction, raycastParams)
		local position = p.Origin + p.Direction
		local instance, normal

		if raycastResult then
			instance = raycastResult.Instance
			position = raycastResult.Position
			normal = raycastResult.Normal
		else
			normal = createVector(0, -1, 0)
		end

		return instance, position, normal
	end,
	[collisionMode.Function] = function(ray)
		local v16 = ray.Origin + ray.Direction

		while ray.Direction.magnitude > 0.001 do
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances2
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local position = ray.Origin + ray.Direction
			local instance, normal, material

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
				normal = raycastResult.Normal
				material = instance.Material
			else
				normal = createVector(0, -1, 0)
			end

			if instance and not v5(instance) then
				local v17 = position + ray.Direction.Unit * 0.001
				ray = Ray.new(v17, v16 - v17)
			else
				return instance, position, normal, material
			end
		end
	end
}
local v16 = v15[none]

local function connectLoop()
	local random = Random.new()
	local flag = true
	local v17 = 6
	table.insert(connections, RunService.RenderStepped:connect(function()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { Players.LocalPlayer.Character }
		local raycastResult = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, -unit * 1000, raycastParams)
		local _ = workspace.CurrentCamera.CFrame.Position + -unit * 1000
		local instance

		if raycastResult then
			instance = raycastResult.Instance
			local _ = raycastResult.Position
		end

		if v6 and not (workspace.CurrentCamera.CFrame.Position.y <= v6) or instance then
			part.RainStraight.Enabled = false
			part.RainTopDown.Enabled = false
			flag = true
		else
			if volume2 < 1 and not v7 then
				volume2 = 1
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 1
				}):Play()
			end

			v17 = 6
			local v18 = math.abs((workspace.CurrentCamera.CFrame.lookVector:Dot(unit)))
			local position = workspace.CurrentCamera.CFrame.Position
			local cross = workspace.CurrentCamera.CFrame.lookVector:Cross(-unit)
			local unit2 = cross.magnitude > 0.001 and cross.unit or -unit
			local unit3 = unit:Cross(unit2).unit
			part.Size = new(40, 40, (1 - v18) * 60 + 40)
			part.CFrame = CFrame.new(
				position.x,
				position.y,
				position.z,
				unit2.x,
				-unit.x,
				unit3.x,
				unit2.y,
				-unit.y,
				unit3.y,
				unit2.z,
				-unit.z,
				unit3.z
			) + (1 - v18) * workspace.CurrentCamera.CFrame.lookVector * part.Size.Z / 3 - v18 * unit * 20
			part.RainStraight.Enabled = true
			part.RainTopDown.Enabled = true
			flag = false
		end
	end))
	local stepped = RunService:IsRunning() and RunService.Stepped or RunService.RenderStepped
	table.insert(connections, stepped:connect(function()
		v17 += 1

		if v17 >= 6 then
			local v18 = math.abs((workspace.CurrentCamera.CFrame.lookVector:Dot(unit)))
			local numberSequence4 = NumberSequence.new({
				numberSequenceKeypoint,
				NumberSequenceKeypoint.new(0.25, (1 - v18) * v8 + v18, 0),
				NumberSequenceKeypoint.new(0.75, (1 - v18) * v8 + v18, 0),
				numberSequenceKeypoint2
			})
			local numberSequence5 = NumberSequence.new({
				numberSequenceKeypoint,
				NumberSequenceKeypoint.new(0.25, v18 * v9 + (1 - v18), 0),
				NumberSequenceKeypoint.new(0.75, v18 * v9 + (1 - v18), 0),
				numberSequenceKeypoint2
			})
			local v19 = workspace.CurrentCamera.CFrame:inverse() * (workspace.CurrentCamera.CFrame.Position - unit)
			local numberRange6 = NumberRange.new((math.deg((math.atan2(-v19.x, v19.y)))))

			if flag then
				for _, v20 in pairs(v13) do
					v20.RainStraight.Transparency = numberSequence4
					v20.RainStraight.Rotation = numberRange6
					v20.RainTopDown.Transparency = numberSequence5
				end

				if not v7 then
					local v20

					if v6 and not (workspace.CurrentCamera.CFrame.Position.y <= v6) then
						v20 = 0
					else
						local v21 = -unit * 1000
						local magnitude = 35

						for i = 1, #v2 do
							if v16(Ray.new(workspace.CurrentCamera.CFrame * v2[i], v21), true) then
								continue
							end

							magnitude = v2[i].magnitude
							break
						end

						v20 = 1 - magnitude / 35
					end

					if math.abs(v20 - volume2) > 0.01 then
						volume2 = v20
						TweenService:Create(sound, TweenInfo.new(1), {
							Volume = volume2
						}):Play()
					end
				end
			else
				part.RainStraight.Transparency = numberSequence4
				part.RainStraight.Rotation = numberRange6
				part.RainTopDown.Transparency = numberSequence5
			end

			v17 = 0
		end

		local position = workspace.CurrentCamera.CFrame.Position
		local cross = workspace.CurrentCamera.CFrame.lookVector:Cross(-unit)
		local unit2 = cross.magnitude > 0.001 and cross.unit or -unit
		local unit3 = unit:Cross(unit2).unit
		local cframe = CFrame.new(
			position.x,
			position.y,
			position.z,
			unit2.x,
			-unit.x,
			unit3.x,
			unit2.y,
			-unit.y,
			unit3.y,
			unit2.z,
			-unit.z,
			unit3.z
		)
		local v18 = unit * 550

		for i = 1, v10 do
			local v19 = v12[i]
			local v20 = v13[i]
			local number = random:NextNumber(-100, 100)
			local number2 = random:NextNumber(-100, 100)
			local v21, v22, v23 = v16(Ray.new(cframe * new(number, 500, number2), v18))

			if v21 then
				v19.Position = v22 + v23 * 0.5
				v19.RainSplash:Emit(1)

				if flag then
					local v24 = v22 - unit * 50

					if v6 then
						local Y = v24.Y

						if v6 < Y and unit.Y < 0 then
							v24 += unit * (v6 - v24.Y) / unit.Y
						end
					end

					v20.CFrame = cframe - cframe.p + v24
					v20.RainStraight:Emit(v11)
					v20.RainTopDown:Emit(v11)
				end
			elseif flag then
				local v24 = cframe * new(number, random:NextNumber(20, 100), number2)

				if v6 then
					local Y = v24.Y

					if v6 < Y and unit.Y < 0 then
						v24 += unit * (v6 - v24.Y) / unit.Y
					end
				end

				v20.CFrame = cframe - cframe.p + v24
				v20.RainStraight:Emit(v11)
				v20.RainTopDown:Emit(v11)
			end
		end
	end))
end

local function disconnectLoop()
	if #connections > 0 then
		for _, connection in pairs(connections) do
			connection:disconnect()
		end

		connections = {}
	end
end

local function disableSound(p)
	volume2 = 0
	local tween = TweenService:Create(sound, p, {
		Volume = 0
	})
	tween.Completed:connect(function(p2)
		if p2 == Enum.PlaybackState.Completed then
			sound:Stop()
		end

		tween:Destroy()
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disable()
	disconnectLoop()
	part.RainStraight.Enabled = false
	part.RainTopDown.Enabled = false
	part.Size = createVector(0.05, 0.05, 0.05)

	if not v7 then
		disableSound(TweenInfo.new(1))
	end
end

local function makeProperty(className, p, callback)
	local instance = Instance.new(className)

	if p then
		instance.Value = p
	end

	instance.Changed:connect(callback)
	callback(instance.Value)
	return instance
end

local function fn(value)
	local colorSequence = ColorSequence.new(value)
	part.RainStraight.Color = colorSequence
	part.RainTopDown.Color = colorSequence

	for _, v17 in pairs(v12) do
		v17.RainSplash.Color = colorSequence
	end

	for _, v17 in pairs(v13) do
		v17.RainStraight.Color = colorSequence
		v17.RainTopDown.Color = colorSequence
	end
end

local color3Value = Instance.new("Color3Value")

if color then
	color3Value.Value = color
end

color3Value.Changed:connect(fn)
fn(color3Value.Value)

local function updateTransparency(value)
	local v17 = (1 - value) * (1 - numberValue.Value)
	local v18 = 1 - v17
	v8 = 0.7 * v17 + v18
	v9 = 0.85 * v17 + v18
	local numberSequence4 = NumberSequence.new({
		numberSequenceKeypoint,
		NumberSequenceKeypoint.new(0.25, v17 * 0.6 + v18, 0),
		NumberSequenceKeypoint.new(0.75, v17 * 0.6 + v18, 0),
		numberSequenceKeypoint2
	})

	for _, v19 in pairs(v12) do
		v19.RainSplash.Transparency = numberSequence4
	end
end

local numberValue2 = Instance.new("NumberValue")
numberValue2.Value = 0
numberValue2.Changed:connect(updateTransparency)
updateTransparency(numberValue2.Value)
numberValue.Changed:connect(updateTransparency)

-- equivalent calls inferred from this helper; original call sites unknown
local function fn2(value)
	part.RainStraight.Speed = NumberRange.new(value * 60)
	part.RainTopDown.Speed = NumberRange.new(value * 60)
end

local numberValue3 = Instance.new("NumberValue")
numberValue3.Value = 1
numberValue3.Changed:connect(fn2)
fn2(numberValue3.Value) -- equivalent call inferred; original call site unknown

-- equivalent calls inferred from this helper; original call sites unknown
local function fn3(value2)
	part.RainStraight.Rate = 200 * value2
	part.RainTopDown.Rate = 200 * value2
	v11 = math.ceil(2 * value2)
	v10 = 20 * value2
end

local numberValue4 = Instance.new("NumberValue")
numberValue4.Value = 1
numberValue4.Changed:connect(fn3)
fn3(numberValue4.Value) -- equivalent call inferred; original call site unknown

local function fn4(value3)
	part.RainStraight.LightEmission = value3
	part.RainTopDown.LightEmission = value3

	for _, v17 in pairs(v13) do
		v17.RainStraight.LightEmission = value3
		v17.RainTopDown.LightEmission = value3
	end

	for _, v17 in pairs(v12) do
		v17.RainSplash.LightEmission = value3
	end
end

local numberValue5 = Instance.new("NumberValue")
numberValue5.Value = 0.05
numberValue5.Changed:connect(fn4)
fn4(numberValue5.Value)

local function fn5(value3)
	part.RainStraight.LightInfluence = value3
	part.RainTopDown.LightInfluence = value3

	for _, v17 in pairs(v13) do
		v17.RainStraight.LightInfluence = value3
		v17.RainTopDown.LightInfluence = value3
	end

	for _, v17 in pairs(v12) do
		v17.RainSplash.LightInfluence = value3
	end
end

local numberValue6 = Instance.new("NumberValue")
numberValue6.Value = 0.9
numberValue6.Changed:connect(fn5)
fn5(numberValue6.Value)

-- equivalent calls inferred from this helper; original call sites unknown
local function fn6(value3)
	if value3.magnitude > 0.001 then
		unit = value3.unit
	end
end

local vector3Value = Instance.new("Vector3Value")
vector3Value.Value = createVector(0, -1, 0)
vector3Value.Changed:connect(fn6)
fn6(vector3Value.Value) -- equivalent call inferred; original call site unknown
local RainyStone = {
	CollisionMode = collisionMode,
	Enable = function(_, p)
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #1 to 'Enable' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end

		disconnectLoop()
		part.RainStraight.Enabled = true
		part.RainTopDown.Enabled = true
		part.Parent = workspace.CurrentCamera

		for i = 1, 20 do
			v12[i].Parent = workspace.Terrain
			v13[i].Parent = workspace.Terrain
		end

		if RunService:IsRunning() then
			soundGroup.Parent = game:GetService("SoundService")
		end

		connectLoop()

		if p then
			TweenService:Create(numberValue, p, {
				Value = 0
			}):Play()
		else
			numberValue.Value = 0
		end

		if not sound.Playing then
			sound:Play()
			sound.TimePosition = math.random() * sound.TimeLength
		end

		v7 = false
	end,
	Disable = function(_, p)
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #1 to 'Disable' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end

		if p then
			local tween = TweenService:Create(numberValue, p, {
				Value = 1
			})
			tween.Completed:connect(function(p2)
				if p2 == Enum.PlaybackState.Completed then
					disable() -- equivalent call inferred; original call site unknown
				end

				tween:Destroy()
			end)
			tween:Play()
			disableSound(p)
		else
			numberValue.Value = 1
			disable() -- equivalent call inferred; original call site unknown
		end

		v7 = true
	end,
	SetColor = function(_, p, p2)
		if typeof(p) == "Color3" then
			if p2 ~= nil and typeof(p2) ~= "TweenInfo" then
				error("bad argument #2 to 'SetColor' (TweenInfo expected, got " .. typeof(p2) .. ")", 2)
			end
		else
			error("bad argument #1 to 'SetColor' (Color3 expected, got " .. typeof(p) .. ")", 2)
		end

		if p2 then
			TweenService:Create(color3Value, p2, {
				Value = p
			}):Play()
		else
			color3Value.Value = p
		end
	end
}

local function makeRatioSetter(p, p2)
	return function(_, value4, p3)
		if typeof(value4) == "number" then
			if p3 ~= nil and typeof(p3) ~= "TweenInfo" then
				error("bad argument #2 to '" .. p .. "' (TweenInfo expected, got " .. typeof(p3) .. ")", 2)
			end
		else
			error("bad argument #1 to '" .. p .. "' (number expected, got " .. typeof(value4) .. ")", 2)
		end

		local v17 = math.clamp(value4, 0, 1)

		if p3 then
			TweenService:Create(p2, p3, {
				Value = v17
			}):Play()
		else
			p2.Value = v17
		end
	end
end

local v17 = "SetTransparency"

function RainyStone.SetTransparency(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v17 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v17 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v18 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue2, p, {
			Value = v18
		}):Play()
	else
		numberValue2.Value = v18
	end
end

local v18 = "SetSpeedRatio"

function RainyStone.SetSpeedRatio(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v18 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v18 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v19 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue3, p, {
			Value = v19
		}):Play()
	else
		numberValue3.Value = v19
	end
end

local v19 = "SetIntensityRatio"

function RainyStone.SetIntensityRatio(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v19 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v19 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v20 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue4, p, {
			Value = v20
		}):Play()
	else
		numberValue4.Value = v20
	end
end

local v20 = "SetLightEmission"

function RainyStone.SetLightEmission(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v20 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v20 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v21 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue5, p, {
			Value = v21
		}):Play()
	else
		numberValue5.Value = v21
	end
end

local v21 = "SetLightInfluence"

function RainyStone.SetLightInfluence(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v21 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v21 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v22 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue6, p, {
			Value = v22
		}):Play()
	else
		numberValue6.Value = v22
	end
end

function RainyStone.SetVolume(_, volume, p)
	if typeof(volume) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to 'SetVolume' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to 'SetVolume' (number expected, got " .. typeof(volume) .. ")", 2)
	end

	if p then
		TweenService:Create(soundGroup, p, {
			Volume = volume
		}):Play()
	else
		soundGroup.Volume = volume
	end
end

function RainyStone.SetDirection(_, p, p2)
	if typeof(p) == "Vector3" then
		if p2 ~= nil and typeof(p2) ~= "TweenInfo" then
			error("bad argument #2 to 'SetDirection' (TweenInfo expected, got " .. typeof(p2) .. ")", 2)
		end
	else
		error("bad argument #1 to 'SetDirection' (Vector3 expected, got " .. typeof(p) .. ")", 2)
	end

	if not (p.unit.magnitude > 0) then
		warn("Attempt to set rain direction to a zero-length vector, falling back on default direction = (" .. tostring(createVector(
			0,
			-1,
			0
		)) .. ")")
		p = createVector(0, -1, 0)
	end

	if p2 then
		TweenService:Create(vector3Value, p2, {
			Value = p
		}):Play()
	else
		vector3Value.Value = p
	end
end

function RainyStone.SetCeiling(_, value4)
	if value4 ~= nil and typeof(value4) ~= "number" then
		error("bad argument #1 to 'SetCeiling' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	v6 = value4
end

function RainyStone.SetStraightTexture(_, texture)
	if typeof(texture) ~= "string" then
		error("bad argument #1 to 'SetStraightTexture' (string expected, got " .. typeof(texture) .. ")", 2)
	end

	part.RainStraight.Texture = texture

	for _, v22 in pairs(v13) do
		v22.RainStraight.Texture = texture
	end
end

function RainyStone.SetTopDownTexture(_, texture)
	if typeof(texture) ~= "string" then
		error("bad argument #1 to 'SetStraightTexture' (string expected, got " .. typeof(texture) .. ")", 2)
	end

	part.RainTopDown.Texture = texture

	for _, v22 in pairs(v13) do
		v22.RainTopDown.Texture = texture
	end
end

function RainyStone.SetSplashTexture(_, texture)
	if typeof(texture) ~= "string" then
		error("bad argument #1 to 'SetStraightTexture' (string expected, got " .. typeof(texture) .. ")", 2)
	end

	for _, v22 in pairs(v12) do
		v22.RainSplash.Texture = texture
	end
end

function RainyStone.SetSoundId(_, soundId)
	if typeof(soundId) ~= "string" then
		error("bad argument #1 to 'SetSoundId' (string expected, got " .. typeof(soundId) .. ")", 2)
	end

	sound.SoundId = soundId
end

function RainyStone.SetCollisionMode(_, p, value4)
	if p == collisionMode.None then
		filterDescendantsInstances = nil
		v5 = nil
	elseif p == collisionMode.Blacklist then
		if typeof(value4) == "Instance" then
			filterDescendantsInstances = { value4, part }
		elseif typeof(value4) == "table" then
			for i = 1, #value4 do
				if typeof(value4[i]) ~= "Instance" then
					error(
						"bad argument #2 to 'SetCollisionMode' (blacklist contained a " .. typeof(value4[i]) .. " on index " .. tostring(i) .. " which is not an Instance)",
						2
					)
				end
			end

			filterDescendantsInstances = { part }

			for i = 1, #value4 do
				table.insert(filterDescendantsInstances, value4[i])
			end
		else
			error(
				"bad argument #2 to 'SetCollisionMode (Instance or array of Instance expected, got " .. typeof(value4) .. ")'",
				2
			)
		end

		v5 = nil
	elseif p == collisionMode.Whitelist then
		if typeof(value4) == "Instance" then
			filterDescendantsInstances = { value4 }
		elseif typeof(value4) == "table" then
			for i = 1, #value4 do
				if typeof(value4[i]) ~= "Instance" then
					error(
						"bad argument #2 to 'SetCollisionMode' (whitelist contained a " .. typeof(value4[i]) .. " on index " .. tostring(i) .. " which is not an Instance)",
						2
					)
				end
			end

			filterDescendantsInstances = {}

			for i = 1, #value4 do
				table.insert(filterDescendantsInstances, value4[i])
			end
		else
			error(
				"bad argument #2 to 'SetCollisionMode (Instance or array of Instance expected, got " .. typeof(value4) .. ")'",
				2
			)
		end

		v5 = nil
	elseif p == collisionMode.Function then
		if typeof(value4) ~= "function" then
			error("bad argument #2 to 'SetCollisionMode' (function expected, got " .. typeof(value4) .. ")", 2)
		end

		filterDescendantsInstances = nil
		v5 = value4
	else
		error("bad argument #1 to 'SetCollisionMode (Rain.CollisionMode expected, got " .. typeof(value4) .. ")'", 2)
	end

	none = p
	v16 = v15[p]
end

return RainyStone