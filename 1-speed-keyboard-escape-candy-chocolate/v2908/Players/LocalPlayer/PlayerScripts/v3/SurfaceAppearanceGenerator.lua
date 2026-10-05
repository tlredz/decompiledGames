local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local KeycapStreamConfig = require(ReplicatedStorage.Utilities.KeycapsRendering.KeycapStreamConfig)
local streamedAttributeName = KeycapStreamConfig.StreamedAttributeName
local child = ReplicatedStorage:WaitForChild(KeycapStreamConfig.TemplateFolderName, 60)

if not child then
	warn("[SurfaceAppearanceGenerator] ReplicatedStorage." .. KeycapStreamConfig.TemplateFolderName .. " missing")
	return
end

local child2 = child:WaitForChild(KeycapStreamConfig.SurfaceAppearanceFolderName, 60)

if not child2 then
	warn("[SurfaceAppearanceGenerator] SurfaceAppearances folder missing under " .. KeycapStreamConfig.TemplateFolderName)
	return
end

local keycaps = Workspace:WaitForChild("Keycaps", 60)

if not keycaps then
	warn("[SurfaceAppearanceGenerator] workspace.Keycaps missing")
	return
end

local object = setmetatable({}, {
	__mode = "k"
})
local v = {}
local v2 = 1
local count = 0

local function isStreamedKeycap(instance)
	return instance:GetAttribute(streamedAttributeName) == true
end

local function checkKeycapReady(instance)
	if instance:GetAttribute(streamedAttributeName) == true or object[instance] or instance:FindFirstChildWhichIsA("SurfaceAppearance") then
		return false, nil, ""
	end

	local match = instance.Name:match(KeycapStreamConfig.NamePattern)

	if not match then
		return false, nil, "no keycap name match"
	end

	local surfaceAppearance = child2:FindFirstChild(match)

	if surfaceAppearance and surfaceAppearance:IsA("SurfaceAppearance") then
		return true, surfaceAppearance, ""
	end

	return false, nil, "no SurfaceAppearance prefab for " .. match
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySurfaceAppearance(parent, instance)
	local clone = instance:Clone()
	clone.Color = parent.Color
	clone.Parent = parent
	object[parent] = clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function processQueued(instance)
	if instance.Parent and instance:GetAttribute(streamedAttributeName) ~= true then
		local v3, v4 = checkKeycapReady(instance)

		if v3 then
			applySurfaceAppearance(instance, v4) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enqueue(part)
	if part:IsA("MeshPart") and part:GetAttribute(streamedAttributeName) ~= true and part.Name:match(KeycapStreamConfig.NamePattern) and not object[part] then
		count += 1
		v[count] = part
	end
end

RunService.Heartbeat:Connect(function()
	if v2 <= count then
		local v3 = os.clock() + 0.001

		while true do
			local parent = v[v2]
			v[v2] = nil
			v2 += 1
			processQueued(parent) -- equivalent call inferred; original call site unknown

			if not (count < v2 or v3 <= os.clock()) then
				continue
			end

			if count < v2 then
				v2 = 1
				count = 0
			end

			break
		end
	end
end)

for _, descendant in ipairs(keycaps:GetDescendants()) do
	enqueue(descendant) -- equivalent call inferred; original call site unknown
end

keycaps.DescendantAdded:Connect(enqueue)