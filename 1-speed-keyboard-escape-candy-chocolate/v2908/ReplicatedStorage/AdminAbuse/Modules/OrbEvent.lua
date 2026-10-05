local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local PartyEvent = require(adminAbuse:WaitForChild("PartyEvent"))
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local orbEvent = EventsConfig.OrbEvent
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local v = PartyEvent.new({
	DisplayName = orbEvent.DisplayName,
	MaxDurationSeconds = orbEvent.MaxDurationSeconds,
	DefaultDurationSeconds = orbEvent.DefaultDurationSeconds,
	NeedsDuration = orbEvent.NeedsDuration,
	RequiresRespawnRefire = true,
	SkipDoorTransition = orbEvent.SkipDoorTransition,
	IsAdminAbuse = orbEvent.IsAdminAbuse,
	Sounds = orbEvent.Sounds
})

local function getCollectRemote()
	local remotes = adminAbuse:FindFirstChild("Remotes")
	local orbEventCollect = remotes and remotes:FindFirstChild("OrbEventCollect")

	if orbEventCollect and orbEventCollect:IsA("RemoteEvent") then
		return orbEventCollect
	end

	return nil
end

local function getOrbTemplate()
	local part = adminAbuse:FindFirstChild(orbEvent.OrbTemplateName)

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function applyOrbVisuals(clone)
	local orbLight = orbEvent.OrbLight

	if orbLight then
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = orbLight.Brightness or 2
		pointLight.Range = orbLight.Range or 20
		local color = orbLight.Color or { 255, 200, 0 }
		pointLight.Color = Color3.fromRGB(color[1], color[2], color[3])
		pointLight.Parent = clone
	end

	local orbHighlight = orbEvent.OrbHighlight

	if orbHighlight then
		local highlight = Instance.new("Highlight")
		local fillColor = orbHighlight.FillColor or { 255, 230, 50 }
		local outlineColor = orbHighlight.OutlineColor or { 255, 200, 0 }
		highlight.FillColor = Color3.fromRGB(fillColor[1], fillColor[2], fillColor[3])
		highlight.OutlineColor = Color3.fromRGB(outlineColor[1], outlineColor[2], outlineColor[3])
		highlight.FillTransparency = orbHighlight.FillTransparency or 0.7
		highlight.OutlineTransparency = orbHighlight.OutlineTransparency or 0
		highlight.Adornee = clone
		highlight.Parent = clone
	end
end

local function isLocalCharacterPart(instance)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

local function checkSpawnPayload(p)
	if type(p) == "table" and type(p.id) == "string" and typeof(p.spawnPosition) == "Vector3" then
		return true, p.id, p.spawnPosition
	end

	return false, nil, nil
end

local function checkMountLocal(p, p2)
	local id, spawnPosition, v2

	if type(p2) == "table" and type(p2.id) == "string" and typeof(p2.spawnPosition) == "Vector3" then
		id = p2.id
		spawnPosition = p2.spawnPosition
		v2 = true
	else
		v2 = false
	end

	if not (v2 and id and spawnPosition) or p._localOrbs[id] then
		return false, nil, nil, nil
	end

	local part = adminAbuse:FindFirstChild(orbEvent.OrbTemplateName)

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if part then
		return true, id, spawnPosition, part
	end

	return false, nil, nil, nil
end

local function connectOrbTouch(p, state)
	local remotes = adminAbuse:FindFirstChild("Remotes")
	local orbEventCollect = remotes and remotes:FindFirstChild("OrbEventCollect")

	if not (orbEventCollect and orbEventCollect:IsA("RemoteEvent")) then
		orbEventCollect = nil
	end

	return state.part.Touched:Connect(function(part)
		if not state.pendingCollect and part:IsA("BasePart") then
			local localPlayer = Players.LocalPlayer
			local character = localPlayer and localPlayer.Character
			local v2

			if character == nil then
				v2 = false
			else
				v2 = part:IsDescendantOf(character)
			end

			if v2 then
				state.pendingCollect = true

				if orbEventCollect then
					orbEventCollect:FireServer(state.id)
				end

				local id = state.id
				task.delay(0.25, function()
					local _localOrbs = p._localOrbs
					local v3 = _localOrbs and _localOrbs[id]

					if v3 and v3.pendingCollect and v3.part.Parent then
						v3.pendingCollect = false
					end
				end)
			end
		end
	end)
end

local function applyDestroyLocalOrb(p, flag: boolean)
	if flag and p.part.Parent then
		p.part.Transparency = 1
		local pointLight = p.part:FindFirstChildOfClass("PointLight")

		if pointLight then
			pointLight.Enabled = false
		end

		local highlight = p.part:FindFirstChildOfClass("Highlight")

		if highlight then
			highlight.Enabled = false
		end

		task.delay(0.15, function()
			if p.part.Parent then
				p.part:Destroy()
			end
		end)
	else
		p.part:Destroy()
	end

	if p.janitor then
		p.janitor:Cleanup()
	end
end

function v:_ensureOrbFolder()
	if self._orbFolder and self._orbFolder.Parent then
		return
	end

	local child = workspace:FindFirstChild(orbEvent.OrbFolderName)

	if child then
		child:Destroy()
	end

	self._orbFolder = Instance.new("Folder")
	self._orbFolder.Name = orbEvent.OrbFolderName
	self._orbFolder.Parent = workspace
end

function v:_destroyLocalOrb(p2: string, flag: boolean)
	local _localOrbs = self._localOrbs
	local v2 = _localOrbs and _localOrbs[p2]

	if v2 then
		_localOrbs[p2] = nil
		applyDestroyLocalOrb(v2, flag)
	end
end

function v:_clearLocalOrbs()
	local _localOrbs = self._localOrbs

	if _localOrbs then
		for k in _localOrbs do
			self:_destroyLocalOrb(k, false)
		end

		table.clear(_localOrbs)
	end

	if self._orbFolder then
		self._orbFolder:Destroy()
		self._orbFolder = nil
	end
end

function v:_mountLocalOrb(orbEventId: string, position: Vector3, instance)
	self:_ensureOrbFolder()
	local clone = instance:Clone()
	clone.Name = "OrbEventOrb_" .. orbEventId
	clone:SetAttribute("OrbEventId", orbEventId)
	clone.Anchored = false
	clone.CanCollide = true
	clone.CanTouch = true
	clone.CFrame = CFrame.new(position)
	applyOrbVisuals(clone)
	clone.Parent = self._orbFolder
	Debris:AddItem(clone, orbEvent.OrbLifetimeSec + 1)
	local v2 = {
		id = orbEventId,
		part = clone,
		pendingCollect = false,
		janitor = nil
	}
	self._localOrbs[orbEventId] = v2
	local remotes = adminAbuse:FindFirstChild("Remotes")
	local orbEventCollect = remotes and remotes:FindFirstChild("OrbEventCollect")

	if not (orbEventCollect and orbEventCollect:IsA("RemoteEvent")) then
		orbEventCollect = nil
	end

	local touchedConnection = v2.part.Touched:Connect(function(part)
		if not v2.pendingCollect and part:IsA("BasePart") then
			local localPlayer = Players.LocalPlayer
			local character = localPlayer and localPlayer.Character
			local v3

			if character == nil then
				v3 = false
			else
				v3 = part:IsDescendantOf(character)
			end

			if v3 then
				v2.pendingCollect = true

				if orbEventCollect then
					orbEventCollect:FireServer(v2.id)
				end

				local id = v2.id
				task.delay(0.25, function()
					local _localOrbs = self._localOrbs
					local v4 = _localOrbs and _localOrbs[id]

					if v4 and v4.pendingCollect and v4.part.Parent then
						v4.pendingCollect = false
					end
				end)
			end
		end
	end)
	local destroyingConnection = clone.Destroying:Connect(function()
		local _localOrbs = self._localOrbs

		if _localOrbs then
			_localOrbs[orbEventId] = nil
		end
	end)
	local janitor = Janitor.new()
	janitor:Add(touchedConnection)
	janitor:Add(destroyingConnection)
	v2.janitor = janitor
end

function v:_spawnLocalOrb(p)
	local id, spawnPosition, v2

	if type(p) == "table" and type(p.id) == "string" and typeof(p.spawnPosition) == "Vector3" then
		id = p.id
		spawnPosition = p.spawnPosition
		v2 = true
	else
		v2 = false
	end

	local part, v3

	if v2 and id and spawnPosition and not self._localOrbs[id] then
		part = adminAbuse:FindFirstChild(orbEvent.OrbTemplateName)

		if not (part and part:IsA("BasePart")) then
			part = nil
		end

		if part then
			v3 = true
		else
			v3 = false
			id = nil
			spawnPosition = nil
			part = nil
		end
	else
		v3 = false
		id = nil
		spawnPosition = nil
	end

	if v3 and id and spawnPosition and part then
		self:_mountLocalOrb(id, spawnPosition, part)
	end
end

function v:OnStart(p, _, _, _)
	self._localOrbs = {}
	local clientColorCorrection = orbEvent.ClientColorCorrection
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "OrbEventColorCorrection"
	colorCorrectionEffect.Brightness = clientColorCorrection.Brightness
	colorCorrectionEffect.Contrast = clientColorCorrection.Contrast
	colorCorrectionEffect.Saturation = clientColorCorrection.Saturation
	local tintColor = clientColorCorrection.TintColor
	colorCorrectionEffect.TintColor = Color3.fromRGB(tintColor[1], tintColor[2], tintColor[3])
	colorCorrectionEffect.Parent = Lighting
	local v2 = SharedSyncedEvent.new(orbEvent.SyncChannelName)
	v2:onFire("OrbSpawn", function(p2)
		self:_spawnLocalOrb(p2)
	end)
	v2:onFire("OrbPickup", function(p2)
		if type(p2) == "table" and type(p2.id) == "string" then
			self:_destroyLocalOrb(p2.id, true)
		end
	end)
	v2:onFire("OrbDespawn", function(p2)
		if type(p2) == "table" and type(p2.id) == "string" then
			self:_destroyLocalOrb(p2.id, false)
		end
	end)
	v2:onFire("OrbClear", function()
		self:_clearLocalOrbs()
	end)
	p.janitor:Add(colorCorrectionEffect, "Destroy")
	p.janitor:Add(v2, "destroy")
	p.janitor:Add(function()
		self:_clearLocalOrbs()
		self._localOrbs = nil
	end)
end

function v:OnStop(_)
	self:_clearLocalOrbs()
	self._localOrbs = nil
end

return v