local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local BanjoCricket = require(ReplicatedStorage.Data.BanjoCricket)
local Mushrooms = require(script.Parent.Mushrooms)
local color = Color3.fromRGB(130, 130, 125)
local object = setmetatable({}, {
	__mode = "k"
})

local function fade(p: number)
	return NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
end

local function shrink(p: number, p2: number)
	return NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, p2) })
end

local function sporeEmitter(attachment)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Spores"
	particleEmitter.Texture = BanjoCricket.Textures.Spore
	particleEmitter.Rate = 0
	particleEmitter.Lifetime = NumberRange.new(0.6, 1.1)
	particleEmitter.Speed = NumberRange.new(5, 9)
	particleEmitter.SpreadAngle = Vector2.new(55, 55)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Drag = 3
	particleEmitter.Acceleration = createVector(0, 2, 0)
	particleEmitter.Size = shrink(0.45, 0)
	particleEmitter.Transparency = fade(0)
	particleEmitter.LightEmission = 1
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Parent = attachment
	return particleEmitter
end

local function wiltEmitter(attachment)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Wilt"
	particleEmitter.Texture = BanjoCricket.Textures.Spore
	particleEmitter.Rate = 0
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.Lifetime = NumberRange.new(0.7, 1.1)
	particleEmitter.Speed = NumberRange.new(2, 4)
	particleEmitter.SpreadAngle = Vector2.new(80, 80)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Drag = 2
	particleEmitter.Acceleration = createVector(0, -10, 0)
	particleEmitter.Size = shrink(0.35, 0.1)
	particleEmitter.Transparency = fade(0.2)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Parent = attachment
	return particleEmitter
end

local function noteEmitter(attachment)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Note"
	particleEmitter.Texture = BanjoCricket.Textures.Note
	particleEmitter.Rate = 0
	particleEmitter.Lifetime = NumberRange.new(1.2, 1.5)
	particleEmitter.Speed = NumberRange.new(3, 4)
	particleEmitter.SpreadAngle = Vector2.new(12, 12)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Drag = 1
	particleEmitter.Acceleration = createVector(0, 1, 0)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.2, 1.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.LightEmission = 0.4
	particleEmitter.Rotation = NumberRange.new(-15, 15)
	particleEmitter.RotSpeed = NumberRange.new(-20, 20)
	particleEmitter.Parent = attachment
	return particleEmitter
end

-- equivalent calls inferred from this helper; original call sites unknown
local function topOf(p)
	return p.Position + createVector(0, 1, 0) * p.Size.Y / 2
end

local function emittersFor(instance)
	local v2 = object[instance]

	if v2 then
		v2.Attachment.WorldPosition = topOf(instance)
		return v2
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "BanjoCricketSpores"
	attachment.Parent = Workspace.Terrain
	attachment.WorldPosition = topOf(instance)
	instance.Destroying:Once(function()
		attachment:Destroy()
	end)
	local v3 = {
		Attachment = attachment,
		Spores = sporeEmitter(attachment),
		Wilt = wiltEmitter(attachment),
		Note = noteEmitter(attachment)
	}
	object[instance] = v3
	return v3
end

local function isVisible(vector2: Vector3)
	local currentCamera = Workspace.CurrentCamera
	return currentCamera ~= nil and (currentCamera.CFrame.Position - vector2).Magnitude <= 160
end

return table.freeze({
	Puff = function(p: number)
		local anchor = Mushrooms.Anchor(p)
		local mushroom = BanjoCricket.Mushrooms[p]

		if anchor ~= nil and mushroom ~= nil then
			local position = anchor.Position
			local currentCamera = Workspace.CurrentCamera
			local v2

			if currentCamera == nil then
				v2 = false
			else
				v2 = (currentCamera.CFrame.Position - position).Magnitude <= 160
			end

			if v2 then
				local v3 = emittersFor(anchor)
				local colorSequence = ColorSequence.new(mushroom.Color)
				v3.Spores.Color = colorSequence
				v3.Spores:Emit(14)
				v3.Note.Color = colorSequence
				v3.Note:Emit(1)
			end
		end
	end,
	Wilt = function()
		for k in BanjoCricket.Mushrooms do
			local anchor = Mushrooms.Anchor(k)

			if not anchor then
				continue
			end

			local position = anchor.Position
			local currentCamera = Workspace.CurrentCamera
			local v2

			if currentCamera == nil then
				v2 = false
			else
				v2 = (currentCamera.CFrame.Position - position).Magnitude <= 160
			end

			if v2 then
				emittersFor(anchor).Wilt:Emit(10)
			end
		end
	end,
	Spiral = function()
		local v2 = {}
		local colors = {}

		for k, mushroom in BanjoCricket.Mushrooms do
			local anchor = Mushrooms.Anchor(k)

			if not anchor then
				continue
			end

			table.insert(v2, topOf(anchor))
			table.insert(colors, mushroom.Color)
		end

		if not (#v2 < 2) then
			local v3 = v2[1]
			local currentCamera = Workspace.CurrentCamera
			local v4

			if currentCamera == nil then
				v4 = false
			else
				v4 = (currentCamera.CFrame.Position - v3).Magnitude <= 160
			end

			if v4 then
				local part = Instance.new("Part")
				part.Name = "BanjoCricketSpiral"
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.Transparency = 1
				part.Size = createVector(0.2, 0.2, 0.2)
				part.CFrame = CFrame.new(v2[1])
				local attachment = Instance.new("Attachment")
				attachment.Parent = part
				local v5 = sporeEmitter(attachment)
				v5.Rate = 90
				v5.Speed = NumberRange.new(0.5, 1.5)
				v5.Lifetime = NumberRange.new(0.5, 0.8)
				part.Parent = Workspace
				local lastTime = os.clock()
				local preRenderConnection = nil
				preRenderConnection = RunService.PreRender:Connect(function()
					local v6 = math.min((os.clock() - lastTime) / 1.1, 1)
					local v7 = v6 * (#v2 - 1)
					local v8 = math.min(math.floor(v7) + 1, #v2 - 1)
					local v9 = v7 - (v8 - 1)
					local v10 = v6 * 5 * 3.141592653589793 * 2
					local lerped = v2[v8]:Lerp(v2[v8 + 1], v9)
					part.CFrame = CFrame.new(lerped + Vector3.new(
						math.cos(v10) * 1.6,
						math.sin(v6 * 3.141592653589793) * 3,
						math.sin(v10) * 1.6
					))
					v5.Color = ColorSequence.new(colors[v8]:Lerp(colors[v8 + 1], v9))

					if v6 >= 1 then
						preRenderConnection:Disconnect()
						v5.Enabled = false
						task.delay(1, function()
							part:Destroy()
						end)
					end
				end)
			end
		end
	end
})