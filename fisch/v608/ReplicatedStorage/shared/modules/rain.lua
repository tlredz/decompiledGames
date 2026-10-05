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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local numberValue = Instance.new("NumberValue")
numberValue.Value = 1
local none = collisionMode.None
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local ZoneController = require(ReplicatedStorage.client.legacyControllers.ZoneController)
local new = Vector3.new
local numberSequenceKeypoint = NumberSequenceKeypoint.new(0, 1, 0)
local numberSequenceKeypoint2 = NumberSequenceKeypoint.new(1, 1, 0)
local v2 = {}
local v3 = nil
local connections = {}
local unit = createVector(0, -1, 0)
local v4 = nil
local v5 = 1
local v6 = 1
local v7 = true
local v8 = 0
local v9 = 0
local filterDescendantsInstances = nil

for _, v11 in pairs({
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
	table.insert(v2, v11 * 35)
end

table.sort(v2, function(a, b)
	return a.magnitude < b.magnitude
end)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { game.Workspace:WaitForChild("zones"):WaitForChild("player") }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterDescendantsInstances = { game.Workspace:WaitForChild("zones"):WaitForChild("player") }
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.RespectCanCollide = true
local part = Instance.new("Part")
part.Transparency = 1
part.Anchored = true
part.CanCollide = false
part.Locked = false
part.Archivable = false
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
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
particleEmitter.Rate = 150
particleEmitter.Speed = NumberRange.new(60)
particleEmitter.EmissionDirection = Enum.NormalId.Bottom
particleEmitter.Parent = part
particleEmitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
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
particleEmitter2.Rate = 90
particleEmitter2.Speed = NumberRange.new(60)
particleEmitter2.EmissionDirection = Enum.NormalId.Bottom
particleEmitter2.Parent = part
local v11 = {}
local v12 = {}

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
		NumberSequenceKeypoint.new(0.25, 0.8, 0),
		NumberSequenceKeypoint.new(0.75, 0.8, 0),
		numberSequenceKeypoint2
	})
	particleEmitter3.Enabled = false
	particleEmitter3.Rate = 0
	particleEmitter3.Speed = NumberRange.new(0)
	particleEmitter3.Name = "RainSplash"
	particleEmitter3.Parent = attachment
	attachment.Archivable = false
	table.insert(v11, attachment)
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
	table.insert(v12, attachment2)
end

local raycastParams3 = RaycastParams.new()
raycastParams3.FilterDescendantsInstances = { part, Players.LocalPlayer and Players.LocalPlayer.Character }
raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
local raycastParams4 = RaycastParams.new()
raycastParams4.FilterDescendantsInstances = { part, game.Workspace:WaitForChild("zones"):WaitForChild("player") }
raycastParams4.FilterType = Enum.RaycastFilterType.Exclude
local v13 = {
	[collisionMode.None] = function(p, p2, p3)
		local raycastResult = workspace:Raycast(p, p2, p3 and raycastParams3 or raycastParams4)

		if raycastResult then
			return raycastResult.Instance, raycastResult.Position, raycastResult.Normal, raycastResult.Material
		end
	end,
	[collisionMode.Blacklist] = function(p, p2)
		local raycastResult = workspace:Raycast(p, p2, raycastParams)

		if raycastResult then
			return raycastResult.Instance, raycastResult.Position, raycastResult.Normal, raycastResult.Material
		end
	end,
	[collisionMode.Whitelist] = function(p, p2)
		local raycastResult = workspace:Raycast(p, p2, raycastParams2)

		if raycastResult then
			return raycastResult.Instance, raycastResult.Position, raycastResult.Normal, raycastResult.Material
		end
	end,
	[collisionMode.Function] = function(p, p2)
		local v14 = p + p2

		while p2.magnitude > 0.001 do
			local raycastResult = workspace:Raycast(p, p2, raycastParams4)

			if raycastResult and not v3(raycastResult.Instance) or not raycastResult then
				p = raycastResult.Position + p2.Unit * 0.001
				p2 = v14 - p
			else
				return raycastResult.Instance, raycastResult.Position, raycastResult.Normal, raycastResult.Material
			end
		end
	end
}
local v14 = v13[none]

local function connectLoop()
	local random = Random.new()
	local flag = true
	local v15 = 6
	table.insert(connections, RunService.RenderStepped:connect(function()
		local v16, _ = v14(workspace.CurrentCamera.CFrame.p, -unit * 100, true)

		if v4 and not (workspace.CurrentCamera.CFrame.p.y <= v4) or v16 or ZoneController.IsIndoors or ZoneController.IsFakeUnderwater then
			part.RainStraight.Enabled = false
			part.RainTopDown.Enabled = false
			flag = true
		else
			v15 = 6
			local v17 = math.abs((workspace.CurrentCamera.CFrame.lookVector:Dot(unit)))
			local p = workspace.CurrentCamera.CFrame.p
			local cross = workspace.CurrentCamera.CFrame.lookVector:Cross(-unit)
			local unit2 = cross.magnitude > 0.001 and cross.unit or -unit
			local unit3 = unit:Cross(unit2).unit
			part.Size = new(40, 40, (1 - v17) * 60 + 40)
			part.CFrame = CFrame.new(
				p.x,
				p.y,
				p.z,
				unit2.x,
				-unit.x,
				unit3.x,
				unit2.y,
				-unit.y,
				unit3.y,
				unit2.z,
				-unit.z,
				unit3.z
			) + (1 - v17) * workspace.CurrentCamera.CFrame.lookVector * part.Size.Z / 3 - v17 * unit * 20
			part.RainStraight.Enabled = true
			part.RainTopDown.Enabled = true
			flag = false
		end
	end))
	local stepped = RunService:IsRunning() and RunService.Stepped or RunService.RenderStepped
	table.insert(connections, stepped:connect(function()
		debug.profilebegin("rain::Tick")
		v15 += 1

		if v15 >= 6 then
			local v16 = math.abs((workspace.CurrentCamera.CFrame.lookVector:Dot(unit)))
			local numberSequence4 = NumberSequence.new({
				numberSequenceKeypoint,
				NumberSequenceKeypoint.new(0.25, (1 - v16) * v5 + v16, 0),
				NumberSequenceKeypoint.new(0.75, (1 - v16) * v5 + v16, 0),
				numberSequenceKeypoint2
			})
			local numberSequence5 = NumberSequence.new({
				numberSequenceKeypoint,
				NumberSequenceKeypoint.new(0.25, v16 * v6 + (1 - v16), 0),
				NumberSequenceKeypoint.new(0.75, v16 * v6 + (1 - v16), 0),
				numberSequenceKeypoint2
			})
			local v17 = workspace.Camera.CFrame:inverse() * (workspace.Camera.CFrame.p - unit)
			local numberRange6 = NumberRange.new((math.deg((math.atan2(-v17.x, v17.y)))))

			if flag then
				for _, v18 in pairs(v12) do
					v18.RainStraight.Transparency = numberSequence4
					v18.RainStraight.Rotation = numberRange6
					v18.RainTopDown.Transparency = numberSequence5
				end

				if not v7 and (not v4 or workspace.CurrentCamera.CFrame.p.y <= v4) then
					local v18 = -unit * 100
					local magnitude = 35

					for i = 1, #v2 do
						if v14(workspace.CurrentCamera.CFrame * v2[i], v18, true) then
							continue
						end

						magnitude = v2[i].magnitude
						break
					end

					local _ = 1 - magnitude / 35
				end
			else
				part.RainStraight.Transparency = numberSequence4
				part.RainStraight.Rotation = numberRange6
				part.RainTopDown.Transparency = numberSequence5
			end

			v15 = 0
		end

		local p = workspace.CurrentCamera.CFrame.p
		local cross = workspace.CurrentCamera.CFrame.lookVector:Cross(-unit)
		local unit2 = cross.magnitude > 0.001 and cross.unit or -unit
		local unit3 = unit:Cross(unit2).unit
		local cframe = CFrame.new(
			p.x,
			p.y,
			p.z,
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
		local v16 = unit * 550

		for i = 1, v8 do
			local v17 = v11[i]
			local v18 = v12[i]
			local number = random:NextNumber(-100, 100)
			local number2 = random:NextNumber(-100, 100)
			local v19, v20, v21 = v14(cframe * new(number, 500, number2), v16)

			if v19 then
				v17.Position = v20 + v21 * 0.5
				v17.RainSplash:Emit(1)

				if flag then
					local v22 = v20 - unit * 50

					if v4 then
						local Y = v22.Y

						if v4 < Y and unit.Y < 0 then
							v22 += unit * (v4 - v22.Y) / unit.Y
						end
					end

					v18.CFrame = cframe - cframe.p + v22
					v18.RainStraight:Emit(v9)
					v18.RainTopDown:Emit(v9)
				end
			elseif flag then
				local v22 = cframe * new(number, random:NextNumber(20, 100), number2)

				if v4 then
					local Y = v22.Y

					if v4 < Y and unit.Y < 0 then
						v22 += unit * (v4 - v22.Y) / unit.Y
					end
				end

				v18.CFrame = cframe - cframe.p + v22
				v18.RainStraight:Emit(v9)
				v18.RainTopDown:Emit(v9)
			end
		end

		debug.profileend()
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

-- equivalent calls inferred from this helper; original call sites unknown
local function disable()
	disconnectLoop()
	part.RainStraight.Enabled = false
	part.RainTopDown.Enabled = false
	part.Size = createVector(0.05, 0.05, 0.05)
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

	for _, v15 in pairs(v11) do
		v15.RainSplash.Color = colorSequence
	end

	for _, v15 in pairs(v12) do
		v15.RainStraight.Color = colorSequence
		v15.RainTopDown.Color = colorSequence
	end
end

local color3Value = Instance.new("Color3Value")

if color then
	color3Value.Value = color
end

color3Value.Changed:connect(fn)
fn(color3Value.Value)

local function updateTransparency(value)
	local v15 = (1 - value) * (1 - numberValue.Value)
	local v16 = 1 - v15
	v5 = 0.7 * v15 + v16
	v6 = 0.85 * v15 + v16
	local numberSequence4 = NumberSequence.new({
		numberSequenceKeypoint,
		NumberSequenceKeypoint.new(0.25, v15 * 0.8 + v16, 0),
		NumberSequenceKeypoint.new(0.75, v15 * 0.8 + v16, 0),
		numberSequenceKeypoint2
	})

	for _, v17 in pairs(v11) do
		v17.RainSplash.Transparency = numberSequence4
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
numberValue3.Value = 0.9
numberValue3.Changed:connect(fn2)
fn2(numberValue3.Value) -- equivalent call inferred; original call site unknown

-- equivalent calls inferred from this helper; original call sites unknown
local function fn3(value2)
	part.RainStraight.Rate = 150 * value2
	part.RainTopDown.Rate = 90 * value2
	v9 = math.ceil(2 * value2)
	v8 = 20 * value2
end

local numberValue4 = Instance.new("NumberValue")
numberValue4.Value = 1
numberValue4.Changed:connect(fn3)
fn3(numberValue4.Value) -- equivalent call inferred; original call site unknown

local function fn4(value3)
	part.RainStraight.LightEmission = value3
	part.RainTopDown.LightEmission = value3

	for _, v15 in pairs(v12) do
		v15.RainStraight.LightEmission = value3
		v15.RainTopDown.LightEmission = value3
	end

	for _, v15 in pairs(v11) do
		v15.RainSplash.LightEmission = value3
	end
end

local numberValue5 = Instance.new("NumberValue")
numberValue5.Value = 0.05
numberValue5.Changed:connect(fn4)
fn4(numberValue5.Value)

local function fn5(value3)
	part.RainStraight.LightInfluence = value3
	part.RainTopDown.LightInfluence = value3

	for _, v15 in pairs(v12) do
		v15.RainStraight.LightInfluence = value3
		v15.RainTopDown.LightInfluence = value3
	end

	for _, v15 in pairs(v11) do
		v15.RainSplash.LightInfluence = value3
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
local Rain = {
	CollisionMode = collisionMode,
	Enable = function(self, p)
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #1 to 'Enable' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end

		if Players.LocalPlayer and not SettingsController:GetSettingValue("showRain") then
			if not v7 then
				self:Disable()
			end
		else
			disconnectLoop()
			part.RainStraight.Enabled = true
			part.RainTopDown.Enabled = true
			part.Parent = workspace.CurrentCamera

			for i = 1, 20 do
				v11[i].Parent = workspace.Terrain
				v12[i].Parent = workspace.Terrain
			end

			connectLoop()

			if p then
				TweenService:Create(numberValue, p, {
					Value = 0
				}):Play()
			else
				numberValue.Value = 0
			end

			v7 = false
		end
	end,
	Disable = function(self, p)
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
		else
			numberValue.Value = 1
			disable() -- equivalent call inferred; original call site unknown
		end

		v7 = true
	end,
	IsEnabled = function(_)
		return not v7
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

		local v15 = math.clamp(value4, 0, 1)

		if p3 then
			TweenService:Create(p2, p3, {
				Value = v15
			}):Play()
		else
			p2.Value = v15
		end
	end
end

local v15 = "SetTransparency"

function Rain.SetTransparency(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v15 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v15 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v16 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue2, p, {
			Value = v16
		}):Play()
	else
		numberValue2.Value = v16
	end
end

local v16 = "SetSpeedRatio"

function Rain.SetSpeedRatio(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v16 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v16 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v17 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue3, p, {
			Value = v17
		}):Play()
	else
		numberValue3.Value = v17
	end
end

local v17 = "SetIntensityRatio"

function Rain.SetIntensityRatio(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v17 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v17 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v18 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue4, p, {
			Value = v18
		}):Play()
	else
		numberValue4.Value = v18
	end
end

local v18 = "SetLightEmission"

function Rain.SetLightEmission(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v18 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v18 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v19 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue5, p, {
			Value = v19
		}):Play()
	else
		numberValue5.Value = v19
	end
end

local v19 = "SetLightInfluence"

function Rain.SetLightInfluence(_, value4, p)
	if typeof(value4) == "number" then
		if p ~= nil and typeof(p) ~= "TweenInfo" then
			error("bad argument #2 to '" .. v19 .. "' (TweenInfo expected, got " .. typeof(p) .. ")", 2)
		end
	else
		error("bad argument #1 to '" .. v19 .. "' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	local v20 = math.clamp(value4, 0, 1)

	if p then
		TweenService:Create(numberValue6, p, {
			Value = v20
		}):Play()
	else
		numberValue6.Value = v20
	end
end

function Rain.SetDirection(_, p, p2)
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

function Rain.SetCeiling(_, value4)
	if value4 ~= nil and typeof(value4) ~= "number" then
		error("bad argument #1 to 'SetCeiling' (number expected, got " .. typeof(value4) .. ")", 2)
	end

	v4 = value4
end

function Rain.SetStraightTexture(_, texture)
	if typeof(texture) ~= "string" then
		error("bad argument #1 to 'SetStraightTexture' (string expected, got " .. typeof(texture) .. ")", 2)
	end

	part.RainStraight.Texture = texture

	for _, v20 in pairs(v12) do
		v20.RainStraight.Texture = texture
	end
end

function Rain.SetTopDownTexture(_, texture)
	if typeof(texture) ~= "string" then
		error("bad argument #1 to 'SetStraightTexture' (string expected, got " .. typeof(texture) .. ")", 2)
	end

	part.RainTopDown.Texture = texture

	for _, v20 in pairs(v12) do
		v20.RainTopDown.Texture = texture
	end
end

function Rain.SetSplashTexture(_, texture)
	if typeof(texture) ~= "string" then
		error("bad argument #1 to 'SetStraightTexture' (string expected, got " .. typeof(texture) .. ")", 2)
	end

	for _, v20 in pairs(v11) do
		v20.RainSplash.Texture = texture
	end
end

function Rain.SetCollisionMode(_, p, value4)
	if p == collisionMode.None then
		raycastParams.FilterDescendantsInstances = {}
		raycastParams2.FilterDescendantsInstances = { game.Workspace:WaitForChild("zones"):WaitForChild("player") }
		filterDescendantsInstances = nil
		v3 = nil
	elseif p == collisionMode.Blacklist then
		if typeof(value4) == "Instance" then
			filterDescendantsInstances = { value4, part }
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			raycastParams2.FilterDescendantsInstances = {
				game.Workspace:WaitForChild("zones"):WaitForChild("player"),
				value4,
				part
			}
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

			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			raycastParams2.FilterDescendantsInstances = {
				game.Workspace:WaitForChild("zones"):WaitForChild("player"),
				table.unpack(filterDescendantsInstances)
			}
		else
			error(
				"bad argument #2 to 'SetCollisionMode (Instance or array of Instance expected, got " .. typeof(value4) .. ")'",
				2
			)
		end

		v3 = nil
	elseif p == collisionMode.Whitelist then
		if typeof(value4) == "Instance" then
			filterDescendantsInstances = { value4 }
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			raycastParams2.FilterDescendantsInstances = {
				game.Workspace:WaitForChild("zones"):WaitForChild("player"),
				table.unpack(filterDescendantsInstances)
			}
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

			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			raycastParams2.FilterDescendantsInstances = {
				game.Workspace:WaitForChild("zones"):WaitForChild("player"),
				table.unpack(filterDescendantsInstances)
			}
		else
			error(
				"bad argument #2 to 'SetCollisionMode (Instance or array of Instance expected, got " .. typeof(value4) .. ")'",
				2
			)
		end

		v3 = nil
	elseif p == collisionMode.Function then
		if typeof(value4) ~= "function" then
			error("bad argument #2 to 'SetCollisionMode' (function expected, got " .. typeof(value4) .. ")", 2)
		end

		filterDescendantsInstances = nil
		raycastParams.FilterDescendantsInstances = { filterDescendantsInstances }
		raycastParams2.FilterDescendantsInstances = { game.Workspace:WaitForChild("zones"):WaitForChild("player") }
		v3 = value4
	else
		error("bad argument #1 to 'SetCollisionMode (Rain.CollisionMode expected, got " .. typeof(value4) .. ")'", 2)
	end

	none = p
	v14 = v13[p]
end

return Rain