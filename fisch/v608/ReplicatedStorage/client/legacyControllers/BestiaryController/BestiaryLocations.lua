local ReplicatedStorage = game:GetService("ReplicatedStorage")
local locations = require(ReplicatedStorage.shared.modules.library.locations)
local Bestiary = require(ReplicatedStorage.shared.modules.Bestiary)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local events = ReplicatedStorage.events
local localPlayer = game.Players.LocalPlayer
local tracker_locationsdiscovered = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("tracker_locationsdiscovered")
local BestiaryLocations = {}
BestiaryLocations.__index = BestiaryLocations
local color = Color3.fromRGB(255, 221, 92)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(35, 35, 35)
local v = {
	island = true,
	isle = true,
	islands = true,
	the = true,
	of = true,
	["and"] = true,
	a = true,
	sea = true,
	ocean = true,
	lake = true,
	river = true,
	bay = true,
	cave = true,
	cavern = true,
	caves = true,
	shore = true,
	shores = true,
	coast = true,
	beach = true,
	reef = true,
	depths = true,
	deep = true,
	waters = true,
	zone = true,
	area = true,
	region = true,
	place = true,
	point = true,
	cove = true,
	port = true,
	harbor = true,
	harbour = true
}

local function connectActivated(button, onActivated)
	if button:IsA("GuiButton") then
		return button.Activated:Connect(onActivated)
	end

	return button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			onActivated()
		end
	end)
end

local function nameOf(name: string)
	local location = locations[name]

	if location then
		name = location.Name or name
	end

	return name
end

local function bestiarySort(name: string, name2: string)
	local location = locations[name]
	local location2 = locations[name2]

	if location and location2 then
		if not location.CustomOrder ~= not location2.CustomOrder then
			return not location.CustomOrder
		end

		if location.CustomOrder and location2.CustomOrder then
			return location.CustomOrder < location2.CustomOrder
		end

		return location.Name < location2.Name
	else
		if location then
			name = location.Name or name
		end

		if location2 then
			name2 = location2.Name or name2
		end

		return name < name2
	end
end

function BestiaryLocations.new(config)
	local object = setmetatable({}, BestiaryLocations)
	object._config = config
	object._mode = "Base"
	object._entries = {}
	object._aggregate = {}
	object._highlight = config.highlightColor or color
	object._discoverables = {}
	object._childrenOf = {}
	object._discoveredCache = {}
	object._searchConn = config.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		object:_updateSearch()
	end)
	object._discoveredConn = tracker_locationsdiscovered.ChildAdded:Connect(function(child)
		local v2 = child.Name:gsub("Discovered$", "")
		object._discoveredCache[v2] = nil
		object:_refreshDiscovery(v2)
		local parentLocation = locations[v2] and locations[v2].ParentLocation

		if parentLocation then
			object._discoveredCache[parentLocation] = nil
			object:_refreshDiscovery(parentLocation)
		end
	end)
	return object
end

-- equivalent calls inferred from this helper; original call sites unknown
local function appendUniqueEntries(items, p, list)
	for _, item in items do
		if p[item] then
			continue
		end

		p[item] = true
		table.insert(list, item)
	end
end

function BestiaryLocations:GetEntries(p2: string)
	local v2 = self._aggregate[p2]

	if not v2 then
		return self._config.getRawEntries(p2)
	end

	local v3 = {}
	local v4 = {}
	appendUniqueEntries(self._config.getRawEntries(p2), v3, v4) -- equivalent call inferred; original call site unknown

	for _, v5 in v2 do
		appendUniqueEntries(self._config.getRawEntries(v5), v3, v4) -- equivalent call inferred; original call site unknown
	end

	return v4
end

function BestiaryLocations:GetCounted(childName: string)
	local getRawCounted = self._config.getRawCounted or self._config.getRawEntries
	local v2 = self._aggregate[childName]

	if v2 then
		local v3 = {}
		local v4 = {}
		appendUniqueEntries(getRawCounted(childName), v3, v4) -- equivalent call inferred; original call site unknown

		for _, v5 in v2 do
			appendUniqueEntries(getRawCounted(v5), v3, v4) -- equivalent call inferred; original call site unknown
		end

		return v4
	else
		local rawCounted = getRawCounted(childName)
		task.defer(function()
			if not tracker_locationsdiscovered:FindFirstChild(childName) then
				local discoveryPercentages = Bestiary:GetDiscoveryPercentages(localPlayer, childName, false)
				local v3 = tonumber(string.format("%.1f", discoveryPercentages))

				if v3 and v3 >= 100 then
					events:WaitForChild("bestiarycomplete"):FireServer(childName)
				end
			end
		end)
		return rawCounted
	end
end

function BestiaryLocations:_isLimited(p: string)
	local location = locations[p]
	return location ~= nil and location.Limited == true
end

function BestiaryLocations:_visible(p2: string)
	local location = locations[p2]

	if not location or location.Worlds and not table.find(location.Worlds, self._config.worldIndex) then
		return false
	end

	return not location.SemiHide and not (location.Hide and not location.Limited)
end

function BestiaryLocations:_isDiscovered(p: string)
	if p == "All" or p == "None" or p == "Limited" then
		return true
	end

	local location = locations[p]
	local isEntryDiscovered = self._config.isEntryDiscovered

	if location and self._config.supportsLimited and self:_isLimited(p) then
		return #self:GetEntries(p) > 0
	end

	if location then
		if isEntryDiscovered and self._config.entriesGovernAll then
			for _, v2 in self:GetEntries(p) do
				if isEntryDiscovered(v2) then
					return true
				end
			end

			return false
		else
			if tracker_locationsdiscovered:FindFirstChild(p .. "Discovered") ~= nil or location.Event ~= nil or location.AutoDiscover == true then
				return true
			end

			local v2 = self._childrenOf[p] or self._aggregate[p]

			if v2 then
				for _, v3 in v2 do
					if self:_isDiscovered(v3) then
						return true
					end
				end
			end

			return false
		end
	else
		local v2 = self._childrenOf[p] or self._aggregate[p]

		if v2 then
			for _, v3 in v2 do
				if self:_isDiscovered(v3) then
					return true
				end
			end
		else
			if not isEntryDiscovered then
				return true
			end

			for _, v3 in self:GetEntries(p) do
				if isEntryDiscovered(v3) then
					return true
				end
			end
		end

		return false
	end
end

function BestiaryLocations:_bind(p, button, name: string)
	local location = locations[name]
	p.Name = name
	local _isDiscovered = self:_isDiscovered(name)
	local imageLabel = button:FindFirstChild("ImageLabel")

	if imageLabel and imageLabel:IsA("ImageLabel") then
		imageLabel.Image = location and location.Banner or imageLabel.Image
		imageLabel.ImageColor3 = _isDiscovered and color2 or color3
	end

	local label = button:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Text = not _isDiscovered and "???" or location and location.Name or name or "???"
	end

	local _discoverables = self._discoverables

	if not (label and label:IsA("TextLabel") and label) then
		label = nil
	end

	if not (imageLabel and imageLabel:IsA("ImageLabel") and imageLabel) then
		imageLabel = nil
	end

	_discoverables[name] = {
		button = button,
		label = label,
		image = imageLabel
	}

	local function onActivated()
		if self:_isDiscovered(name) then
			self._config.onSelect(name)
			return
		end

		local location2 = locations[name]

		if not location2 or not location2.Hint or location2.Hint == "TBA" then
			events.anno_localthought:Fire("This location doesn't have a Hint!")
			return
		end

		local hint = location2 and location2.Hint
		events.anno_localthought:Fire((`Hint: {hint}`))
	end

	if button:IsA("GuiButton") then
		button.Activated:Connect(onActivated)
	else
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				onActivated()
			end
		end)
	end
end

function BestiaryLocations:_refreshDiscovery(value: string)
	local _discoverable = self._discoverables[value]

	if not _discoverable then
		return
	end

	local location = locations[value]
	local _isDiscovered = self:_isDiscovered(value)
	self._discoveredCache[value] = _isDiscovered

	if _discoverable.label then
		_discoverable.label.Text = not _isDiscovered and "???" or location and location.Name or value or "???"
	end

	if _discoverable.image then
		_discoverable.image.ImageColor3 = _isDiscovered and color2 or color3
	end
end

function BestiaryLocations:RefreshDiscovery()
	table.clear(self._discoveredCache)

	for k in self._discoverables do
		self._discoveredCache[k] = self:_isDiscovered(k)
	end

	for k in self._discoverables do
		self:_refreshDiscovery(k)
	end

	self:_updateSearch()
end

function BestiaryLocations:_build()
	local _config = self._config

	for _, guiObject in _config.listFrame:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject ~= _config.currentButton then
			guiObject:Destroy()
		end
	end

	table.clear(self._entries)
	table.clear(self._aggregate)
	table.clear(self._discoverables)
	table.clear(self._childrenOf)
	table.clear(self._discoveredCache)
	local _childrenOf = self._childrenOf
	local v2 = {}

	for k in locations do
		if not (k ~= "All" and k ~= "Limited" and k ~= "None" and self:_visible(k)) then
			continue
		end

		if _config.supportsLimited then
			local _isLimited = self:_isLimited(k)

			if self._mode == "Base" and _isLimited or self._mode == "Limited" and not _isLimited then
				continue
			end
		end

		local parentLocation = locations[k].ParentLocation

		if parentLocation then
			local v3 = _childrenOf[parentLocation]

			if not v3 then
				v3 = {}
				_childrenOf[parentLocation] = v3
			end

			table.insert(v3, k)
		else
			table.insert(v2, k)
		end
	end

	local v3 = {}

	for _, v4 in v2 do
		v3[v4] = true
	end

	for k, v4 in _childrenOf do
		if v3[k] then
			continue
		end

		self._aggregate[k] = v4
		table.insert(v2, k)
		v3[k] = true
	end

	if _config.extraLocations then
		for _, extraLocation in _config.extraLocations do
			if v3[extraLocation] then
				continue
			end

			table.insert(v2, extraLocation)
			v3[extraLocation] = true
		end
	end

	table.sort(v2, bestiarySort)

	for _, list in _childrenOf do
		table.sort(list, bestiarySort)
	end

	if _config.includeAll and (not _config.supportsLimited or self._mode == "Base") then
		local clone = _config.buttonTemplate:Clone()
		clone.LayoutOrder = -2
		self:_bind(clone, clone, "All")
		clone.Parent = _config.listFrame
	end

	if _config.includeRegionless and (not _config.supportsLimited or self._mode == "Base") and #self:GetEntries("None") > 0 then
		local clone = _config.buttonTemplate:Clone()
		clone.LayoutOrder = -1
		self:_bind(clone, clone, "None")
		clone.Parent = _config.listFrame
		local _entries = self._entries
		local none = locations.None
		local v4 = {
			name = none and none.Name or "None",
			key = "None",
			button = clone
		}
		table.insert(_entries, v4)
	end

	local total = 0

	for _, v4 in v2 do
		local v5 = _childrenOf[v4]
		local v6

		if v5 == nil then
			v6 = false
		else
			v6 = #v5 > 0
		end

		if not (not _config.hideEmpty or #self:GetEntries(v4) ~= 0) then
			continue
		end

		local clone = _config.buttonTemplate:Clone()
		clone.LayoutOrder = total
		self:_bind(clone, clone, v4)
		clone.Parent = _config.listFrame

		if v6 then
			local clone2 = _config.dropdownTemplate:Clone()
			clone2.LayoutOrder = total + 1

			for _, child in clone2:GetChildren() do
				if child.Name == "DropdownButton" then
					child:Destroy()
				end
			end

			local children = {}

			for k, v8 in v5 do
				local clone3 = _config.dropdownButtonTemplate:Clone()
				clone3.LayoutOrder = k
				self:_bind(clone3, clone3, v8)
				clone3.Parent = clone2
				local label = clone3:FindFirstChild("Label")
				local v9

				if label == nil then
					v9 = false
				else
					v9 = label:IsA("TextLabel")
				end

				local location = locations[v8]
				local name

				if location then
					name = location.Name or v8
				else
					name = v8
				end

				local v10 = {
					name = name,
					key = v8,
					button = clone3,
					label = v9 and label or nil,
					defaultColor = v9 and label.TextColor3 or color2
				}
				table.insert(children, v10)
			end

			clone2.Parent = _config.listFrame
			local _entries = self._entries
			local location = locations[v4]
			local name2

			if location then
				name2 = location.Name or v4
			else
				name2 = v4
			end

			table.insert(_entries, {
				name = name2,
				key = v4,
				button = clone,
				dropdown = clone2,
				children = children
			})
			total += 3
		else
			local _entries = self._entries
			local location = locations[v4]
			local name

			if location then
				name = location.Name or v4
			else
				name = v4
			end

			table.insert(_entries, {
				name = name,
				key = v4,
				button = clone
			})
			total += 2
		end
	end
end

function BestiaryLocations:_isDiscoveredCached(p: string)
	local v2 = self._discoveredCache[p]

	if v2 == nil then
		v2 = self:_isDiscovered(p)
		self._discoveredCache[p] = v2
	end

	return v2
end

function BestiaryLocations:_updateSearch()
	local text = self._config.searchBox.Text:lower()
	local v2 = text ~= ""

	for _, _entry in self._entries do
		local _isDiscoveredCached = self:_isDiscoveredCached(_entry.key)
		local visible = not v2 or _isDiscoveredCached and _entry.name:lower():find(text, 1, true) ~= nil

		if _entry.children and _entry.dropdown then
			local v4 = false

			for _, v6 in _entry.children do
				if not (v2 and self:_isDiscoveredCached(v6.key) and v6.name:lower():find(text, 1, true) ~= nil) then
					continue
				end

				v4 = true
				break
			end

			local visible2 = visible or v4
			_entry.button.Visible = visible2
			_entry.dropdown.Visible = visible2

			for _, v7 in _entry.children do
				v7.button.Visible = visible2

				if not v7.label then
					continue
				end

				local v8 = v2 and self:_isDiscoveredCached(v7.key) and v7.name:lower():find(text, 1, true) ~= nil
				v7.label.TextColor3 = v8 and self._highlight or v7.defaultColor
			end
		else
			_entry.button.Visible = visible
		end
	end
end

function BestiaryLocations:_defaultLocation()
	local _config = self._config

	if not _config.supportsLimited or self._mode ~= "Limited" then
		return "All"
	end

	local v2 = nil

	for k in locations do
		if not (self:_isLimited(k) and self:_visible(k) and (not _config.hideEmpty or #self:GetEntries(k) ~= 0)) then
			continue
		end

		if v2 then
			local location = locations[k]
			local name

			if location then
				name = location.Name or k
			else
				name = k
			end

			local location2 = locations[v2]
			local v3

			if location2 then
				v3 = location2.Name or v2
			else
				v3 = v2
			end

			if not (name < v3) then
				continue
			end
		end

		v2 = k
	end

	return v2
end

function BestiaryLocations:SetMode(mode: string)
	self._mode = mode
	self:_build()
	local _defaultLocation = self:_defaultLocation()

	if _defaultLocation then
		self._config.onSelect(_defaultLocation)
	end
end

function BestiaryLocations:Rebuild()
	self:SetMode(self._mode)
end

function BestiaryLocations:GetMode()
	return self._mode
end

function BestiaryLocations:Destroy()
	if self._searchConn then
		self._searchConn:Disconnect()
		self._searchConn = nil
	end

	if self._discoveredConn then
		self._discoveredConn:Disconnect()
		self._discoveredConn = nil
	end

	table.clear(self._entries)
	table.clear(self._aggregate)
	table.clear(self._discoverables)
	table.clear(self._childrenOf)
	table.clear(self._discoveredCache)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalize(value: string)
	return (value:lower():gsub("[^%w]", ""))
end

local function meaningfulTokens(value: string)
	local result = {}

	for k in value:lower():gmatch("%w+") do
		if not v[k] then
			table.insert(result, k)
		end
	end

	return result
end

function BestiaryLocations.ResolveZone(value: string)
	if typeof(value) ~= "string" or value == "" then
		return nil
	end

	local v2 = normalize(value) -- equivalent call inferred; original call site unknown

	if v2 == "" then
		return nil
	end

	for k, location in locations do
		if type(location) == "table" and (k:lower():gsub("[^%w]", "") == v2 or location.Name and location.Name:lower():gsub(
			"[^%w]",
			""
		) == v2) then
			return k
		end
	end

	local v3 = meaningfulTokens(value)

	if #v3 == 0 then
		return nil
	end

	local v4 = 0
	local v5 = nil

	for k, location in locations do
		if not (type(location) == "table" and k ~= "All" and k ~= "Limited" and k ~= "None") then
			continue
		end

		local v6 = meaningfulTokens(location.Name or k)

		if #v6 == 0 then
			continue
		end

		local count = 0

		for _, v7 in v3 do
			for _, v9 in v6 do
				if v7 ~= v9 then
					continue
				end

				count += 1
				break
			end
		end

		if not (count > 0) then
			continue
		end

		local v7 = count / math.min(#v3, #v6)

		if not (v4 < v7) then
			continue
		end

		v5 = k
		v4 = v7
	end

	if v4 >= 0.6 then
		return v5
	end

	return nil
end

return BestiaryLocations