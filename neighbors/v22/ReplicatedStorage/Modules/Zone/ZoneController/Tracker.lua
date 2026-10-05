local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local _ = RunService.Heartbeat
local Signal = require(script.Parent.Parent.Signal)
local Janitor = require(script.Parent.Parent.Janitor)
local Tracker = {}
Tracker.__index = Tracker
local trackers = {}
Tracker.trackers = trackers
Tracker.itemAdded = Signal.new()
Tracker.itemRemoved = Signal.new()
Tracker.bodyPartsToIgnore = {
	UpperTorso = true,
	LowerTorso = true,
	Torso = true,
	LeftHand = true,
	RightHand = true,
	LeftFoot = true,
	RightFoot = true
}

function Tracker.getCombinedTotalVolumes()
	local total = 0

	for k, _ in pairs(trackers) do
		total += k.totalVolume
	end

	return total
end

function Tracker.getCharacterSize(instance)
	local head = instance and instance:FindFirstChild("Head")
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and head) then
		return nil
	end

	if not head:IsA("BasePart") then
		head = humanoidRootPart
	end

	local Y = head.Size.Y
	local size = humanoidRootPart.Size
	return
		size * createVector(2, 2, 1) + Vector3.new(0, Y, 0),
		humanoidRootPart.CFrame * CFrame.new(0, Y / 2 - size.Y / 2, 0)
end

function Tracker.new(name)
	local class = {}
	setmetatable(class, Tracker)
	class.name = name
	class.totalVolume = 0
	class.parts = {}
	class.partToItem = {}
	class.items = {}
	class.whitelistParams = nil
	class.characters = {}
	class.baseParts = {}
	class.exitDetections = {}
	class.janitor = Janitor.new()

	if name == "player" then
		local function updatePlayerCharacters()
			local characters = {}

			for _, v3 in pairs(Players:GetPlayers()) do
				local character = v3.Character

				if character then
					characters[character] = true
				end
			end

			class.characters = characters
		end

		local function playerAdded(player)
			local function charAdded(character)
				local humanoid = character:WaitForChild("Humanoid", 3)

				if humanoid then
					updatePlayerCharacters()
					class:update()

					for _, numberValue in pairs(humanoid:GetChildren()) do
						if numberValue:IsA("NumberValue") then
							numberValue.Changed:Connect(function()
								class:update()
							end)
						end
					end
				end
			end

			if player.Character then
				charAdded(player.Character)
			end

			player.CharacterAdded:Connect(charAdded)
			player.CharacterRemoving:Connect(function(character)
				class.exitDetections[character] = nil
			end)
		end

		Players.PlayerAdded:Connect(playerAdded)

		for _, v2 in pairs(Players:GetPlayers()) do
			playerAdded(v2)
		end

		Players.PlayerRemoving:Connect(function(_)
			updatePlayerCharacters()
			class:update()
		end)
	elseif name == "item" then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateItem(data, p)
			if data.isCharacter then
				class.characters[data.item] = p
			elseif data.isBasePart then
				class.baseParts[data.item] = p
			end

			class:update()
		end

		Tracker.itemAdded:Connect(function(data)
			updateItem(data, true) -- equivalent call inferred; original call site unknown
		end)
		Tracker.itemRemoved:Connect(function(data)
			class.exitDetections[data.item] = nil
			updateItem(data, nil) -- equivalent call inferred; original call site unknown
		end)
	end

	trackers[class] = true
	task.defer(class.update, class)
	return class
end

function Tracker:_preventMultiFrameUpdates(p2, ...)
	self._preventMultiDetails = self._preventMultiDetails or {}
	local _preventMultiDetail = self._preventMultiDetails[p2]

	if not _preventMultiDetail then
		_preventMultiDetail = {
			calling = false,
			callsThisFrame = 0,
			updatedThisFrame = false
		}
		self._preventMultiDetails[p2] = _preventMultiDetail
	end

	_preventMultiDetail.callsThisFrame += 1

	if _preventMultiDetail.callsThisFrame ~= 1 then
		return true
	end

	local v2 = table.pack(...)
	task.defer(function()
		local callsThisFrame = _preventMultiDetail.callsThisFrame
		_preventMultiDetail.callsThisFrame = 0

		if callsThisFrame > 1 then
			self[p2](self, unpack(v2))
		end
	end)
	return false
end

function Tracker:update()
	if self:_preventMultiFrameUpdates("update") then
		return
	end

	self.totalVolume = 0
	self.parts = {}
	self.partToItem = {}
	self.items = {}

	for k, _ in pairs(self.characters) do
		local characterSize = Tracker.getCharacterSize(k)

		if not characterSize then
			continue
		end

		local v2 = characterSize.X * characterSize.Y * characterSize.Z
		self.totalVolume += v2
		local v3 = self.janitor:add(Janitor.new(), "destroy", "trackCharacterParts-" .. self.name)

		local function updateTrackerOnParentChanged(instance)
			v3:add(instance.AncestryChanged:Connect(function()
				if not instance:IsDescendantOf(game) and instance.Parent == nil and v3 ~= nil then
					v3:destroy()
					v3 = nil
					self:update()
				end
			end), "Disconnect")
		end

		for _, part in pairs(k:GetChildren()) do
			if not part:IsA("BasePart") or Tracker.bodyPartsToIgnore[part.Name] then
				continue
			end

			self.partToItem[part] = k
			table.insert(self.parts, part)
			local v4 = part
			local ancestryChangedConnection = part.AncestryChanged:Connect(function()
				if not v4:IsDescendantOf(game) and v4.Parent == nil and v3 ~= nil then
					v3:destroy()
					v3 = nil
					self:update()
				end
			end)
			v3:add(ancestryChangedConnection, "Disconnect")
		end

		local v4 = k
		local ancestryChangedConnection = k.AncestryChanged:Connect(function()
			if not v4:IsDescendantOf(game) and v4.Parent == nil and v3 ~= nil then
				v3:destroy()
				v3 = nil
				self:update()
			end
		end)
		v3:add(ancestryChangedConnection, "Disconnect")
		table.insert(self.items, k)
	end

	for k, _ in pairs(self.baseParts) do
		local size = k.Size
		local v2 = size.X * size.Y * size.Z
		self.totalVolume += v2
		self.partToItem[k] = k
		table.insert(self.parts, k)
		table.insert(self.items, k)
	end

	self.whitelistParams = OverlapParams.new()
	self.whitelistParams.FilterType = Enum.RaycastFilterType.Whitelist
	self.whitelistParams.MaxParts = #self.parts
	self.whitelistParams.FilterDescendantsInstances = self.parts
end

return Tracker