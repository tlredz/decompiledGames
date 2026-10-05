local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = {}

local function initAttachment(folder)
	local function createObject()
		if v[folder] then
			return
		end

		local v2 = {
			Connections = {},
			Particles = {}
		}

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				v2.Particles[emitter] = emitter
			end
		end

		table.insert(v2.Connections, folder.DescendantRemoving:Connect(function(emitter)
			if emitter:IsA("ParticleEmitter") and v[folder] and v[folder].Particles[emitter] then
				v[folder].Particles[emitter] = nil
			end
		end))
		table.insert(v2.Connections, folder.DescendantAdded:Connect(function(emitter)
			if emitter:IsA("ParticleEmitter") and v[folder] then
				v[folder].Particles[emitter] = emitter
			end
		end))
		v[folder] = v2
	end

	local function destroyObject()
		if v[folder] == nil then
			return
		end

		if v[folder].Connections then
			for _, connection in v[folder].Connections do
				if connection.Connected then
					connection:Disconnect()
				end
			end
		end

		v[folder] = nil
	end

	folder.AncestryChanged:Connect(function()
		if not folder:IsDescendantOf(workspace) then
			destroyObject()
		elseif v[folder] == nil then
			createObject()
		end
	end)

	if folder:IsDescendantOf(workspace) then
		createObject()
	end

	folder.Destroying:Connect(destroyObject)
end

for _, v2 in CollectionService:GetTagged("FixParticleRotation") do
	initAttachment(v2)
end

CollectionService:GetInstanceAddedSignal("FixParticleRotation"):Connect(function(p)
	initAttachment(p)
end)
RunService.Heartbeat:Connect(function(_)
	for k, v2 in v do
		local _, _, v3 = k.WorldCFrame:ToOrientation()
		local numberRange = NumberRange.new((math.deg(v3)))

		for _, particle in v2.Particles do
			particle.Rotation = numberRange
		end
	end
end)