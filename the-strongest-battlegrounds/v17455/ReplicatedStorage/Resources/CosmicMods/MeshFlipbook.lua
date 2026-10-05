local createVector = vector.create
local MeshFlipbook = {}
local v = {}

function MeshFlipbook.flipbook(instance, textures, totalTime)
	if not instance then
		error("Instance cannot be nil")
	end

	if not textures or #textures == 0 then
		error("Textures array cannot be empty")
	end

	if not totalTime or totalTime <= 0 then
		error("Time must be greater than 0")
	end

	local textureProperty = nil

	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		textureProperty = "Image"
	elseif instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Beam") then
		textureProperty = "Texture"
	elseif instance:IsA("SurfaceGui") then
		local imageLabel = instance:FindFirstChild("ImageLabel")

		if imageLabel then
			instance = imageLabel
			textureProperty = "Image"
		else
			error("SurfaceGui must contain an ImageLabel child")
		end
	elseif instance:IsA("Part") or instance:IsA("MeshPart") then
		local particleEmitter = instance:FindFirstChild("ParticleEmitter")
		local beam = instance:FindFirstChild("Beam")
		local decal = instance:FindFirstChild("Decal")

		if particleEmitter then
			instance = particleEmitter
			textureProperty = "Texture"
		elseif beam then
			instance = beam
			textureProperty = "Texture"
		elseif decal then
			instance = decal
			textureProperty = "Texture"
		else
			error("Part must contain a ParticleEmitter, Beam, or Decal child")
		end
	else
		error("Instance type not supported for texture flipbook")
	end

	MeshFlipbook.stop(instance)
	local v4 = {
		instance = instance,
		textures = textures,
		textureProperty = textureProperty,
		timePerFrame = totalTime / #textures,
		currentFrame = 1,
		startTime = tick(),
		totalTime = totalTime,
		isPlaying = true
	}
	v[instance] = v4
	local heartbeatConnection = nil
	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not v4.isPlaying then
			heartbeatConnection:Disconnect()
			return
		end

		local currentFrame = math.floor((tick() - v4.startTime) / v4.timePerFrame) + 1

		if not (#v4.textures < currentFrame) then
			if currentFrame == v4.currentFrame then
				return
			end

			v4.currentFrame = currentFrame

			if v4.instance and v4.instance.Parent then
				v4.instance[v4.textureProperty] = v4.textures[currentFrame]
				return
			end
		end

		v4.isPlaying = false
		v[instance] = nil
		heartbeatConnection:Disconnect()
	end)
	v4.connection = heartbeatConnection
	return v4
end

function MeshFlipbook.stop(p)
	local v2 = v[p]

	if v2 then
		v2.isPlaying = false

		if v2.connection then
			v2.connection:Disconnect()
		end

		v[p] = nil
	end
end

function MeshFlipbook.pause(p)
	local v2 = v[p]

	if v2 then
		v2.isPlaying = false

		if v2.connection then
			v2.connection:Disconnect()
		end
	end
end

function MeshFlipbook.resume(p)
	local v2 = v[p]

	if v2 and not v2.isPlaying then
		v2.isPlaying = true
		v2.startTime = tick() - (v2.currentFrame - 1) * v2.timePerFrame
		local heartbeatConnection = nil
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not v2.isPlaying then
				heartbeatConnection:Disconnect()
				return
			end

			local currentFrame = math.floor((tick() - v2.startTime) / v2.timePerFrame) + 1

			if not (#v2.textures < currentFrame) then
				if currentFrame == v2.currentFrame then
					return
				end

				v2.currentFrame = currentFrame

				if v2.instance and v2.instance.Parent then
					v2.instance[v2.textureProperty] = v2.textures[currentFrame]
					return
				end
			end

			v2.isPlaying = false
			v[p] = nil
			heartbeatConnection:Disconnect()
		end)
		v2.connection = heartbeatConnection
	end
end

function MeshFlipbook.isPlaying(p)
	local v2 = v[p]
	return v2 and v2.isPlaying or false
end

function MeshFlipbook.getCurrentFrame(p)
	local v2 = v[p]

	if v2 then
		return v2.currentFrame, v2.textures[v2.currentFrame]
	end

	return nil, nil
end

function MeshFlipbook.stopAll()
	for k, _ in pairs(v) do
		MeshFlipbook.stop(k)
	end
end

function MeshFlipbook.findCompatibleObjects(instance)
	local result = {}

	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Decal") or instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		table.insert(result, instance)
	end

	for _, child in pairs(instance:GetChildren()) do
		if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Decal") or child:IsA("ImageLabel") or child:IsA("ImageButton") then
			table.insert(result, child)
		end

		if not child:IsA("SurfaceGui") then
			continue
		end

		local imageLabel = child:FindFirstChild("ImageLabel")

		if imageLabel then
			table.insert(result, imageLabel)
		end
	end

	return result
end

function MeshFlipbook.flipbookMultiple(items, p, p2)
	local result = {}

	for _, item in pairs(items) do
		local v2 = item
		local success, result2 = pcall(function()
			return MeshFlipbook.flipbook(v2, p, p2)
		end)

		if success then
			table.insert(result, result2)
		else
			warn("Failed to create flipbook for instance: " .. tostring(item) .. " - " .. result2)
		end
	end

	return result
end

function MeshFlipbook.Preload(list)
	local Workspace = game:GetService("Workspace")
	local folder = Instance.new("Folder")
	folder.Name = "TextureParts"
	folder.Parent = Workspace

	local function createPartWithDecal(texture, position)
		local part = Instance.new("Part")
		part.Name = "TexturePart_" .. tostring(texture):gsub("rbxassetid://", ""):gsub("rbxasset://textures/", "")
		part.Size = createVector(4, 4, 0.2)
		part.Position = position
		part.Anchored = true
		part.BrickColor = BrickColor.new("Medium stone grey")
		part.Material = Enum.Material.SmoothPlastic
		part.Parent = folder
		local decal = Instance.new("Decal")
		decal.Name = "TextureDecal"
		decal.Texture = texture
		decal.Face = Enum.NormalId.Front
		decal.Parent = part
		local decal2 = Instance.new("Decal")
		decal2.Name = "BackTextureDecal"
		decal2.Texture = texture
		decal2.Face = Enum.NormalId.Back
		decal2.Parent = part
		print("Created part with texture: " .. texture)
		return part
	end

	print("Generating " .. #list .. " texture parts...")

	for i, v2 in ipairs(list) do
		local v3 = math.floor((i - 1) / 5)
		createPartWithDecal(v2, Vector3.new((i - 1) % 5 * 6, -300, -v3 * 6))
		wait(0.03)
	end

	print("Finished creating all texture parts!")
	print("Parts are organized in the '" .. folder.Name .. "' folder in Workspace")
end

function MeshFlipbook.MakeTextureParts(list)
	local parent = workspace:FindFirstChild("PRELOAD")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "PRELOAD"
		parent.Parent = workspace
	end

	for _, texture in ipairs(list) do
		local part = Instance.new("Part")
		part.Size = createVector(1, 1, 1)
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Name = "TexturePart"
		part.Parent = parent
		local decal = Instance.new("Decal")
		decal.Texture = texture
		decal.Face = Enum.NormalId.Front
		decal.Parent = part
	end
end

return MeshFlipbook