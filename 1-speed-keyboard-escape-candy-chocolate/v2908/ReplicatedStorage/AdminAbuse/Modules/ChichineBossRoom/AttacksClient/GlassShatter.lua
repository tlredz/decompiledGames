local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OrbController = require(ReplicatedStorage.AdminAbuse.Modules.Shared.OrbController)
local ClientDebris = require(script.Parent.ClientDebris)
local v = {}
local v2 = nil
local v3 = nil

local function getPortalTemplate()
	if v3 and v3.Parent then
		return v3
	end

	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local chichineBossRoom = adminAbuse and adminAbuse:FindFirstChild("ChichineBossRoom")
	local VFX = chichineBossRoom and chichineBossRoom:FindFirstChild("VFX")

	if not VFX then
		warn("[GlassShatterClient] ReplicatedStorage.AdminAbuse.ChichineBossRoom.VFX not found")
		return nil
	end

	local portal = VFX:FindFirstChild("Portal")

	if not portal then
		local children = VFX:GetChildren()

		if #children == 0 then
			warn("[GlassShatterClient] ChichineBossRoom.VFX is empty — no portal asset")
			return nil
		else
			portal = children[1]
		end
	end

	v3 = portal
	return portal
end

local function getPartsOf(instance)
	local result = {}

	if instance:IsA("Model") then
		for _, part in instance:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(result, part)
			end
		end
	elseif instance:IsA("BasePart") then
		table.insert(result, instance)
	end

	return result
end

local function getOrbController()
	if v2 then
		return v2
	end

	local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse", 10)

	if not adminAbuse then
		return nil
	end

	local remotes = adminAbuse:WaitForChild("Remotes", 10)

	if not remotes then
		return nil
	end

	local chichineOrbCollected = remotes:FindFirstChild("ChichineOrbCollected")

	if not (chichineOrbCollected and chichineOrbCollected:IsA("RemoteEvent")) then
		warn("[GlassShatterClient] ChichineOrbCollected remote not found")
		return nil
	end

	local chichineGiantOrbCollected = remotes:FindFirstChild("ChichineGiantOrbCollected")
	local new = OrbController.new

	if not (chichineGiantOrbCollected and chichineGiantOrbCollected:IsA("RemoteEvent") and chichineGiantOrbCollected) then
		chichineGiantOrbCollected = nil
	end

	v2 = new(chichineOrbCollected, {
		giantOrbRemote = chichineGiantOrbCollected,
		parent = ClientDebris()
	})
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeSingle(p: number)
	local v4 = v[p]

	if not v4 then
		return
	end

	v[p] = nil
	pcall(function()
		v4:Destroy()
	end)
end

local GlassShatter = {}

function GlassShatter.open(data)
	local id = data.id or 1
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local orbCount = data.orbCount or 1
	print("[GlassShatterClient] open id=" .. tostring(id) .. " pos=(" .. tostring((math.round(x))) .. "," .. tostring((math.round(y))) .. "," .. tostring((math.round(z))) .. ")")
	local portalTemplate = getPortalTemplate()

	if not portalTemplate then
		print("[GlassShatterClient] open: no template found, aborting")
		return
	end

	local success, result = pcall(function()
		return portalTemplate:Clone()
	end)

	if not (success and result) then
		print("[GlassShatterClient] open: clone failed: " .. tostring(result))
		return
	end

	local partsOf = getPartsOf(result)
	local transparencies = table.create(#partsOf)

	for k, v4 in partsOf do
		transparencies[k] = v4.Transparency
		v4.Transparency = 1
		v4.Anchored = true
		v4.CanCollide = false
		v4.CanQuery = false
		v4.CanTouch = false
	end

	if result:IsA("Model") then
		result:PivotTo(CFrame.new(x, y, z))
	elseif result:IsA("BasePart") then
		result.CFrame = CFrame.new(x, y, z) * CFrame.Angles(math.random(90, 300), math.random(90, 300), 0)
	end

	result.Parent = ClientDebris()
	v[id] = result

	for k, v4 in partsOf do
		TweenService:Create(v4, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = transparencies[k]
		}):Play()
	end

	local lifetime = data.lifetime

	if lifetime and lifetime > 0 then
		task.delay(lifetime, function()
			closeSingle(id) -- equivalent call inferred; original call site unknown
		end)
	end

	task.delay(0.5, function()
		if not (result and result.Parent) then
			return
		end

		local orbController = getOrbController()

		if orbController then
			orbController:spawnOrbs({ (Vector3.new(x, y + 1, z)) }, orbCount)
		end
	end)
end

function GlassShatter.closeAll()
	for k, v4 in v do
		v[k] = nil

		if not (v4 and v4.Parent) then
			continue
		end

		local partsOf = getPartsOf(v4)

		for _, v5 in partsOf do
			TweenService:Create(v5, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end

		local v5 = v4
		task.delay(0.5, function()
			pcall(function()
				v5:Destroy()
			end)
		end)
	end

	table.clear(v)
end

function GlassShatter.cleanup()
	for _, v4 in v do
		local v5 = v4
		pcall(function()
			v5:Destroy()
		end)
	end

	table.clear(v)

	if v2 then
		v2:destroy()
		v2 = nil
	end
end

function GlassShatter:scan()
	local orbController = getOrbController()

	if orbController then
		orbController:scan(self)
	end
end

function GlassShatter:spawnFromZone()
	local orbController = getOrbController()

	if orbController then
		orbController:spawnFromZone(self)
	end
end

function GlassShatter:spawnGiantFromZone()
	local orbController = getOrbController()

	if orbController then
		orbController:spawnGiantFromZone(self)
	end
end

return GlassShatter