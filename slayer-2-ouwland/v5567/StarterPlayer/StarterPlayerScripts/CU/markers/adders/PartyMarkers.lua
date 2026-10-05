local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local color = Color3.fromRGB(255, 255, 255)
return function(p, p2)
	local partyId = p2.Parent.Parent:WaitForChild("partyInfo"):WaitForChild("partyId")
	local parties = ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Parties")
	local v = cleanit.new()
	local v2 = nil
	local v3 = {}
	local count = 0

	local function markerKey(p3: number)
		return "party_" .. p3
	end

	local parent = workspace:FindFirstChild("PartyMarkerAnchors")

	if parent == nil then
		parent = Instance.new("Folder")
		parent.Name = "PartyMarkerAnchors"
		parent.Parent = workspace
	end

	local function bindMember(playerByUserId, instance)
		local userId = playerByUserId.UserId

		if v3[userId] then
			return
		end

		local maid = cleanit.new()
		v3[userId] = maid
		local name = "party_" .. userId
		local part = Instance.new("Part")
		part.Name = name
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		maid:Add(part)

		local function resolve()
			local character = playerByUserId.Character
			local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart") or nil

			if humanoidRootPart ~= nil then
				return humanoidRootPart.Position
			end

			local position = instance:GetAttribute("Position")

			if typeof(position) == "Vector3" then
				return position
			end

			return nil
		end

		local flag = false

		local function show()
			if flag then
				return
			end

			flag = true
			part.Parent = parent
			MarkerHandler.addMarker(name, {
				markerType = MarkerHandler.markerType.Regular,
				style = "PartyMember",
				position = part,
				offset = createVector(0, 3, 0),
				player = playerByUserId,
				color = color,
				onMap = true,
				tag = "PartyMarkers",
				displayDistance = true,
				minDistance = 15,
				margin = 10
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hide()
			if not flag then
				return
			end

			flag = false
			MarkerHandler.removeMarker(name)
			part.Parent = nil
		end

		local function update()
			local character = playerByUserId.Character
			local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart") or nil
			local position

			if humanoidRootPart == nil then
				position = instance:GetAttribute("Position")

				if typeof(position) ~= "Vector3" then
					position = nil
				end
			else
				position = humanoidRootPart.Position
			end

			if position == nil then
				hide() -- equivalent call inferred; original call site unknown
			else
				part.Position = position
				show()
			end
		end

		local character = playerByUserId.Character
		local humanoidRootPart

		if character ~= nil then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or nil
		end

		local position

		if humanoidRootPart == nil then
			position = instance:GetAttribute("Position")

			if typeof(position) ~= "Vector3" then
				position = nil
			end
		else
			position = humanoidRootPart.Position
		end

		if position == nil then
			hide() -- equivalent call inferred; original call site unknown
		else
			part.Position = position
			show()
		end

		maid:Connect(RunService.Heartbeat, update)
		maid:Add(function()
			MarkerHandler.removeMarker(name)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function unbindMember(p3: number?)
		if p3 == nil then
			return
		end

		local v5 = v3[p3]

		if v5 then
			v5:Destroy()
			v3[p3] = nil
		end

		MarkerHandler.removeMarker("party_" .. p3)
	end

	local function tryBind(p3: number?, instance)
		if p3 == nil or p3 == p.UserId or v3[p3] or instance:FindFirstChild((tostring(p3))) == nil then
			return
		end

		local playerByUserId = Players:GetPlayerByUserId(p3)

		if playerByUserId == nil then
			return
		end

		bindMember(playerByUserId, instance:FindFirstChild((tostring(p3))))
	end

	local function unbindParty()
		count += 1

		if v2 then
			v2:Destroy()
			v2 = nil
		end

		for k, v5 in v3 do
			v5:Destroy()
			MarkerHandler.removeMarker("party_" .. k)
		end

		table.clear(v3)
	end

	local function bindParty(childName: string)
		unbindParty()

		if childName == nil or childName == "" then
			return
		end

		count += 1
		local v5 = count
		task.spawn(function()
			local v6 = parties:FindFirstChild(childName) or parties:WaitForChild(childName, 10)

			if v6 == nil or v5 ~= count then
				return
			end

			v2 = cleanit.new()

			for _, child in v6:GetChildren() do
				tryBind(tonumber(child.Name), v6)
			end

			v2:Connect(v6.ChildAdded, function(p3)
				tryBind(tonumber(p3.Name), v6)
			end)
			v2:Connect(v6.ChildRemoved, function(p3)
				unbindMember(tonumber(p3.Name)) -- equivalent call inferred; original call site unknown
			end)
			v2:Connect(Players.PlayerAdded, function(p3)
				tryBind(p3.UserId, v6)
			end)
			v2:Connect(Players.PlayerRemoving, function(p3)
				unbindMember(p3.UserId) -- equivalent call inferred; original call site unknown
			end)
		end)
	end

	local value = partyId.Value
	unbindParty()

	if value ~= nil and value ~= "" then
		count += 1
		local v5 = count
		task.spawn(function()
			local v6 = parties:FindFirstChild(value) or parties:WaitForChild(value, 10)

			if v6 == nil or v5 ~= count then
				return
			end

			v2 = cleanit.new()

			for _, child in v6:GetChildren() do
				tryBind(tonumber(child.Name), v6)
			end

			v2:Connect(v6.ChildAdded, function(p3)
				tryBind(tonumber(p3.Name), v6)
			end)
			v2:Connect(v6.ChildRemoved, function(p3)
				unbindMember(tonumber(p3.Name)) -- equivalent call inferred; original call site unknown
			end)
			v2:Connect(Players.PlayerAdded, function(p3)
				tryBind(p3.UserId, v6)
			end)
			v2:Connect(Players.PlayerRemoving, function(p3)
				unbindMember(p3.UserId) -- equivalent call inferred; original call site unknown
			end)
		end)
	end

	v:Connect(partyId.Changed, function()
		local value2 = partyId.Value
		unbindParty()

		if value2 ~= nil then
			if value2 == "" then
				return
			end

			count += 1
			local v5 = count
			task.spawn(function()
				local v6 = parties:FindFirstChild(value2) or parties:WaitForChild(value2, 10)

				if v6 == nil or v5 ~= count then
					return
				end

				v2 = cleanit.new()

				for _, child in v6:GetChildren() do
					tryBind(tonumber(child.Name), v6)
				end

				v2:Connect(v6.ChildAdded, function(p3)
					tryBind(tonumber(p3.Name), v6)
				end)
				v2:Connect(v6.ChildRemoved, function(p3)
					unbindMember(tonumber(p3.Name)) -- equivalent call inferred; original call site unknown
				end)
				v2:Connect(Players.PlayerAdded, function(p3)
					tryBind(p3.UserId, v6)
				end)
				v2:Connect(Players.PlayerRemoving, function(p3)
					unbindMember(p3.UserId) -- equivalent call inferred; original call site unknown
				end)
			end)
		end
	end)
end