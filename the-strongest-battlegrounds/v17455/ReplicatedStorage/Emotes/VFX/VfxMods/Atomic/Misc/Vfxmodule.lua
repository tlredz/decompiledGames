local createVector = vector.create
game:GetService("ReplicatedStorage")
game:GetService("Debris")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Vfxmodule = {}

function Vfxmodule.worldpreload()
	local folder = Instance.new("Folder")
	folder.Name = "worldpreload"
	folder.Parent = game.Workspace
	local part = Instance.new("Part", folder)
	part.Position = createVector(0, -200, 0)
	part.Anchored = true
	local descendants = game.Workspace:GetDescendants()

	for _, emitter in descendants do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local decal = Instance.new("Decal", part)
		decal.Texture = emitter.Texture
	end
end

function Vfxmodule.textureflipbook(instance, list, p: number)
	if not (instance and (instance:IsA("Decal") or instance:IsA("Beam") or instance:IsA("ParticleEmitter"))) then
		warn("Flipbook only works with instances that have a 'Texture' property")
		return
	end

	if type(list) ~= "table" or #list == 0 then
		warn("Flipbook requires a non-empty texture table")
		return
	end

	if p <= 0 then
		warn("Flipbook requires duration > 0")
		return
	end

	local lastTime = os.clock()
	local count = #list
	local v = p / count
	task.spawn(function()
		while true do
			local v2 = os.clock() - lastTime

			if p <= v2 then
				break
			end

			instance.Texture = list[math.floor(v2 / v) + 1]
			task.wait(0.01)
		end

		instance.Texture = list[count]
	end)
end

function Vfxmodule.textureflipbookLoop(instance, list, p: number)
	if not (instance and (instance:IsA("Decal") or instance:IsA("Beam") or instance:IsA("ParticleEmitter"))) then
		warn("Flipbook only works with instances that have a 'Texture' property")
		return
	end

	if type(list) ~= "table" or #list == 0 then
		warn("Flipbook requires a non-empty texture table")
		return
	end

	if p <= 0 then
		warn("Flipbook requires duration > 0")
		return
	end

	local count = #list
	local v = count / p
	local v2 = {
		_running = true,
		Stop = function(p2)
			p2._running = false
		end
	}
	task.spawn(function()
		local v3 = 0
		local v4 = 1

		while v2._running do
			v3 += RunService.Heartbeat:Wait()
			local v5 = math.floor(v3 * v)

			if not (v5 > 0) then
				continue
			end

			v4 += v5
			v3 -= v5 / v

			if count < v4 then
				v4 = (v4 - 1) % count + 1
			end

			instance.Texture = list[v4]
		end
	end)
	return v2
end

function Vfxmodule.TexturePreload(list)
	local Workspace = game:GetService("Workspace")
	local folder = Instance.new("Folder")
	folder.Name = "TextureParts"
	folder.Parent = Workspace

	local function createPartWithDecal(texture, _)
		local part = Instance.new("Part")
		part.Name = "TexturePart_" .. tostring(texture):gsub("rbxassetid://", ""):gsub("rbxasset://textures/", "")
		part.Size = createVector(4, 4, 0.2)
		part.Position = createVector(0, -300, 0)
		part.Anchored = true
		part.BrickColor = BrickColor.new("Medium stone grey")
		part.Material = Enum.Material.SmoothPlastic
		part.Parent = folder
		local decal = Instance.new("Decal")
		decal.Name = "TextureDecal"
		decal.Texture = texture
		decal.Face = Enum.NormalId.Front
		decal.Parent = part
		return part
	end

	print("Generating " .. #list .. " texture parts...")

	for i, v in ipairs(list) do
		local v2 = math.floor((i - 1) / 5)
		createPartWithDecal(v, Vector3.new((i - 1) % 5 * 1, 5, -v2 * 1))
	end

	print("Finished creating all texture parts!")
	print("Parts are organized in the '" .. folder.Name .. "' folder in Workspace")
end

return Vfxmodule