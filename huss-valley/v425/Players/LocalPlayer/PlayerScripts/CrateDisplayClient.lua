local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {
	EmberCrate = Color3.fromRGB(255, 155, 67),
	CelestialCrate = Color3.fromRGB(164, 119, 255),
	FreeReward = Color3.fromRGB(123, 232, 184),
	ShopModel = Color3.fromRGB(245, 202, 116)
}
local v3 = {
	FreeReward = "Model",
	ShopModel = "Shop"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function restore(data)
	if data.model.Parent then
		data.model:PivotTo(data.base)
	end

	if data.lid and data.lid.Parent and data.body.Parent then
		data.lid.CFrame = data.body.CFrame * data.hingeOffset * data.closedOffset
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(p)
	local v4 = v[p]

	if not v4 then
		return
	end

	restore(v4) -- equivalent call inferred; original call site unknown

	if v4.attachment.Parent then
		v4.attachment:Destroy()
	end

	v[p] = nil
end

local function add(instance)
	if v[instance] or not v2[instance.Name] then
		return
	end

	local instance2 = instance:FindFirstChild(v3[instance.Name] or "CrateModel")

	if not (instance2 and (instance2:IsA("Model") or instance2:IsA("BasePart"))) then
		return
	end

	local v4 = instance.Name == "EmberCrate" or instance.Name == "CelestialCrate"
	local body = v4 and instance2:FindFirstChild("Body")
	local lid = v4 and instance2:FindFirstChild("Lid")
	local lidHinge = body and body:FindFirstChild("LidHinge")

	if v4 and not (body and body:IsA("BasePart") and lid and lid:IsA("BasePart") and lidHinge and lidHinge:IsA("Attachment")) then
		return
	end

	local parent = instance2:IsA("BasePart") and instance2 or instance2:FindFirstChildWhichIsA("BasePart", true)

	if not parent then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "LocalCrateSparkles"
	attachment.Parent = parent

	if v4 then
		attachment.Parent = body
		attachment.Position = Vector3.new(0, body.Size.Y * 0.45, 0)
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Color = v2[instance.Name]
	pointLight.Range = 12
	pointLight.Brightness = 0
	pointLight.Shadows = false
	pointLight.Parent = attachment
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(v2[instance.Name])
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Rate = 3
	particleEmitter.Lifetime = NumberRange.new(1, 1.8)
	particleEmitter.Speed = NumberRange.new(0.8, 1.4)
	particleEmitter.SpreadAngle = Vector2.new(80, 80)
	particleEmitter.LightEmission = 0.9
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.25, 0.16),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.2, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Enabled = false
	particleEmitter.Parent = attachment
	v[instance] = {
		model = instance2,
		base = instance2:GetPivot(),
		attachment = attachment,
		light = pointLight,
		sparks = particleEmitter,
		phase = ({
			EmberCrate = 0,
			CelestialCrate = 2,
			FreeReward = 4,
			ShopModel = 6
		})[instance.Name],
		amplitude = instance.Name == "ShopModel" and 0.65 or 1,
		active = false,
		body = body,
		lid = lid,
		hingeOffset = lidHinge and lidHinge.CFrame,
		closedOffset = lidHinge and lidHinge.WorldCFrame:ToObjectSpace(lid.CFrame),
		lastCycleTime = 0
	}
end

local connections = {}
local v4 = true

for _, child in workspace:GetChildren() do
	add(child)
end

table.insert(connections, workspace.ChildAdded:Connect(function(child)
	task.delay(1, function()
		if v4 and child.Parent == workspace then
			add(child)
		end
	end)
end))
table.insert(connections, workspace.ChildRemoved:Connect(remove))
table.insert(connections, workspace.DescendantAdded:Connect(function(instance)
	if not (instance:IsA("BasePart") or instance:IsA("Attachment")) then
		return
	end

	local parent = instance.Parent

	while parent and parent.Parent ~= workspace do
		parent = parent.Parent
	end

	if parent and v2[parent.Name] and not v[parent] then
		task.defer(function()
			if v4 and parent.Parent == workspace then
				add(parent)
			end
		end)
	end
end))
local total = 0
local total2 = 0
script.Destroying:Connect(function()
	v4 = false

	for _, connection in connections do
		connection:Disconnect()
	end

	local v5 = {}

	for k in v do
		table.insert(v5, k)
	end

	for _, v6 in v5 do
		remove(v6) -- equivalent call inferred; original call site unknown
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function smooth(value)
	local v5 = math.clamp(value, 0, 1)
	return v5 * v5 * (3 - 2 * v5)
end

table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	total += dt
	total2 += dt

	if total2 < 0.03333333333333333 then
		return
	end

	total2 = 0
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	for k, v5 in v do
		if v5.model.Parent and k.Parent and (not v5.lid or v5.lid.Parent and v5.body.Parent) then
			local v6

			if humanoidRootPart == nil then
				v6 = false
			else
				v6 = (humanoidRootPart.Position - v5.base.Position).Magnitude < 100
			end

			v5.sparks.Enabled = v6

			if v6 then
				local v7 = total + v5.phase
				local amplitude = v5.amplitude
				local lastCycleTime = v7 % 8.4
				local v9 = 0
				local v10 = 0
				local v11 = 0

				if v5.lid then
					if lastCycleTime >= 2.2 and lastCycleTime < 2.65 then
						local v12 = (lastCycleTime - 2.2) / 0.45
						v10 = math.sin(v12 * 34) * 0.045 * v12
						v11 = -0.07 * v12
					elseif lastCycleTime >= 2.65 and lastCycleTime < 3.35 then
						local v12 = (lastCycleTime - 2.65) / 0.7
						v9 = 1 - (1 - v12) ^ 3
						v11 = math.sin(v12 * 3.141592653589793) * 0.12
					elseif lastCycleTime >= 3.35 and lastCycleTime < 4.9 then
						v9 = math.sin((lastCycleTime - 3.35) * 5) * 0.018 + 1
					elseif lastCycleTime >= 4.9 and lastCycleTime < 5.65 then
						v9 = 1 - smooth((lastCycleTime - 4.9) / 0.75)
					elseif lastCycleTime >= 5.65 and lastCycleTime < 6.15 then
						local v12 = (lastCycleTime - 5.65) / 0.5
						v9 = math.abs((math.sin(v12 * 3.141592653589793 * 2))) * (1 - v12) * 0.07
						v11 = -math.sin(v12 * 3.141592653589793) * 0.06
					end

					if v5.active and v5.lastCycleTime < 2.85 and lastCycleTime >= 2.85 then
						v5.sparks:Emit(18)
					end

					v5.lastCycleTime = lastCycleTime
				end

				v5.model:PivotTo(v5.base * CFrame.new(0, (math.sin(v7 * 1.8) * 0.14 + 0.16) * amplitude + v11, 0) * CFrame.Angles(
					math.sin(v7 * 1.3) * 0.025 * amplitude,
					math.sin(v7 * 0.55) * 0.15 * amplitude,
					math.sin(v7 * 1.7) * 0.035 * amplitude + v10
				))

				if v5.lid then
					v5.lid.CFrame = v5.body.CFrame * v5.hingeOffset * CFrame.Angles(v9 * 1.7802358370342162, 0, 0) * v5.closedOffset
				end

				v5.light.Brightness = (math.sin(v7 * 2) + 1) * 0.3 + 0.65 + v9 * 1.8
				v5.sparks.Rate = v9 * 9 + 3
			elseif v5.active then
				restore(v5) -- equivalent call inferred; original call site unknown
				v5.light.Brightness = 0
			end

			v5.active = v6
		else
			remove(k) -- equivalent call inferred; original call site unknown
		end
	end
end))