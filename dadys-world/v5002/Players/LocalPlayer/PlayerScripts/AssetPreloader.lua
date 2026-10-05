local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local v = { function(model)
		if not model:IsA("Model") then
			return nil
		end

		local config = model:FindFirstChild("Config")

		if not config then
			return nil
		end

		local surfaceAppearances = {}

		for _, surfaceAppearance in config:GetChildren() do
			if surfaceAppearance:IsA("SurfaceAppearance") then
				table.insert(surfaceAppearances, surfaceAppearance)
			end
		end

		return surfaceAppearances
	end }
local v2 = {}
local screenGui = nil

local function ensureWarmGui()
	if screenGui and screenGui.Parent then
		return screenGui
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FaceWarmup"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	return screenGui
end

local function gpuWarm(folder, surfaceAppearances)
	local v3 = {}

	for _, v4 in ipairs(surfaceAppearances) do
		local colorMap = nil
		local v5 = v4
		pcall(function()
			colorMap = v5.ColorMap
		end)

		if colorMap and colorMap ~= "" then
			if not v2[colorMap] then
				v2[colorMap] = true
				table.insert(v3, v4)
			end
		else
			table.insert(v3, v4)
		end
	end

	if #v3 == 0 then
		return
	end

	local v4 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("MeshPart") then
			continue
		end

		v4 = part
		break
	end

	if not v4 then
		return
	end

	if not (screenGui and screenGui.Parent) then
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FaceWarmup"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui
	end

	local parent = screenGui
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Size = UDim2.fromOffset(1, 1)
	viewportFrame.Position = UDim2.fromOffset(0, 0)
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Parent = parent
	local camera = Instance.new("Camera")
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	for i, v7 in ipairs(v3) do
		local v8 = i
		local v9 = v7
		pcall(function()
			local clone = v4:Clone()
			clone:ClearAllChildren()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 0
			clone.CFrame = CFrame.new((v8 - 1) * 6, 0, 0)
			local clone_2 = v9:Clone()
			clone_2.Parent = clone
			clone.Parent = viewportFrame
		end)
	end

	local count = #v3
	camera.CFrame = CFrame.new(Vector3.new((count - 1) * 3, 0, count * 6 + 8), (Vector3.new((count - 1) * 3, 0, 0)))
	task.spawn(function()
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
		viewportFrame:Destroy()
	end)
end

local object = setmetatable({}, {
	__mode = "k"
})

local function collect(model)
	local result = {}

	for _, callback in v do
		local success, result2 = pcall(callback, model)

		if not (success and result2) then
			continue
		end

		for _, v3 in result2 do
			table.insert(result, v3)
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preloadList(list, fn, model)
	if #list == 0 then
		return
	end

	task.spawn(function()
		local count = 0

		while count < 12 do
			if fn and not fn() then
				break
			end

			count += 1
			local count2 = 0

			if pcall(function()
				ContentProvider:PreloadAsync(list, function(_, p)
					if p ~= Enum.AssetFetchStatus.Success then
						count2 += 1
					end
				end)
			end) and count2 == 0 then
				if model and model:IsA("Model") then
					local surfaceAppearances = {}

					for _, surfaceAppearance in list do
						if typeof(surfaceAppearance) == "Instance" and surfaceAppearance:IsA("SurfaceAppearance") then
							table.insert(surfaceAppearances, surfaceAppearance)
						end
					end

					if #surfaceAppearances > 0 then
						gpuWarm(model, surfaceAppearances)
					end
				end

				break
			else
				task.wait((math.min(12, 2 ^ (count - 1) * 1)))
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preload(child)
	if object[child] then
		return
	end

	object[child] = true

	local function fn()
		return child.Parent ~= nil
	end

	preloadList(collect(child), fn, child) -- equivalent call inferred; original call site unknown
end

local function preloadBarnabyGlow()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local parts = ReplicatedStorage:WaitForChild("Parts", 30)
	local tBarnaby_v3 = parts and parts:WaitForChild("TBarnaby_v3", 30)

	if not tBarnaby_v3 then
		return
	end

	local surfaceAppearances = {}

	for _, surfaceAppearance in tBarnaby_v3:GetDescendants() do
		if surfaceAppearance:IsA("SurfaceAppearance") then
			table.insert(surfaceAppearances, surfaceAppearance)
		end
	end

	if #surfaceAppearances == 0 then
		return
	end

	local v3 = nil
	task.spawn(function()
		local count = 0

		while count < 12 do
			if v3 and not v3() then
				break
			end

			count += 1
			local count2 = 0

			if pcall(function()
				ContentProvider:PreloadAsync(surfaceAppearances, function(_, p)
					if p ~= Enum.AssetFetchStatus.Success then
						count2 += 1
					end
				end)
			end) and count2 == 0 then
				if tBarnaby_v3 and tBarnaby_v3:IsA("Model") then
					local surfaceAppearances2 = {}

					for _, surfaceAppearance in surfaceAppearances do
						if typeof(surfaceAppearance) == "Instance" and surfaceAppearance:IsA("SurfaceAppearance") then
							table.insert(surfaceAppearances2, surfaceAppearance)
						end
					end

					if #surfaceAppearances2 > 0 then
						gpuWarm(tBarnaby_v3, surfaceAppearances2)
					end
				end

				break
			else
				task.wait((math.min(12, 2 ^ (count - 1) * 1)))
			end
		end
	end)
end

task.spawn(preloadBarnabyGlow)
local childAddedConnection = nil

local function bindMonstersFolder(monsters)
	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	for _, child in monsters:GetChildren() do
		preload(child) -- equivalent call inferred; original call site unknown
	end

	childAddedConnection = monsters.ChildAdded:Connect(preload)
end

local function onMapAdded(model)
	if not model:IsA("Model") then
		return
	end

	local monsters = model:FindFirstChild("Monsters") or model:WaitForChild("Monsters", 10)

	if monsters then
		bindMonstersFolder(monsters)
	end
end

local currentRoom = Workspace:WaitForChild("CurrentRoom")
local model = currentRoom:FindFirstChildOfClass("Model")
local monsters = model and model:IsA("Model") and (model:FindFirstChild("Monsters") or model:WaitForChild(
	"Monsters",
	10
))

if monsters then
	bindMonstersFolder(monsters)
end

currentRoom.ChildAdded:Connect(onMapAdded)