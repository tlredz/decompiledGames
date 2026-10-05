local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v

if game.PlaceId == 130574217370467 then
	v = game.PrivateServerId == ""
else
	v = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function visibleHitboxes()
	return workspace:GetAttribute("PrivateServerHitboxesEnabled") == true or v and localPlayer:GetAttribute("TestUIHidden") ~= true
end

if not v and game.PrivateServerId == "" then
	return
end

local game2 = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Game")
local CombatPrediction = require(game2:WaitForChild("CombatPrediction"))
CombatPrediction.start()
local hitboxDebugEvent = game2:WaitForChild("HitboxDebugEvent")
local color = Color3.fromRGB(52, 230, 255)
local color2 = Color3.fromRGB(255, 142, 49)
local color3 = Color3.fromRGB(255, 87, 189)
local color4 = Color3.fromRGB(255, 231, 85)
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxComparison"
screenGui:SetAttribute("TestOnlyUI", true)
screenGui.Enabled = v and visibleHitboxes()
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 120
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Legend"
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.Position = UDim2.fromScale(0.5, 0.015)
textLabel.Size = UDim2.fromScale(0.92, 0.065)
textLabel.BackgroundColor3 = Color3.fromRGB(10, 18, 25)
textLabel.BackgroundTransparency = 0.2
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextScaled = true
textLabel.TextWrapped = true
textLabel.Font = Enum.Font.GothamBold
textLabel.Text = "CYAN CLIENT CONTACT · ORANGE VALIDATED HISTORY · GREEN/RED HIT RESULT"
textLabel.Parent = screenGui

local function part(name, color5, transparency)
	local part2 = Instance.new("Part")
	part2.Name = name
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanTouch = false
	part2.CanQuery = false
	part2.CastShadow = false
	part2.Material = Enum.Material.Neon
	part2.Color = color5
	part2.Transparency = transparency
	part2.Parent = workspace
	return part2
end

local function clear(items)
	if items then
		for _, item in items do
			if typeof(item) == "Instance" then
				item:Destroy()
			end
		end
	end
end

local function clearAll()
	for _, v8 in v7 do
		clear(v8)
	end

	table.clear(v7)

	for k, v8 in v5 do
		clear(v8)
		v5[k] = nil
	end

	for k, v8 in v2 do
		clear(v8)
		v2[k] = nil
	end

	for k, v8 in v3 do
		for k2, v9 in v8 do
			clear(v9)
			v8[k2] = nil
		end

		v3[k] = nil
	end

	for k, v8 in v4 do
		clear(v8)
		v4[k] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function frame(p, direction, forwardStart, forwardEnd)
	local v8 = direction * createVector(1, 0, 1)

	if v8.Magnitude < 0.01 then
		return nil
	end

	return CFrame.lookAt(p, p + v8.Unit) * CFrame.new(0, 0, -(forwardStart + forwardEnd) * 0.5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function draw(p, data, p2)
	local cFrame = frame(p2, data.direction, data.forwardStart, data.forwardEnd) -- equivalent call inferred; original call site unknown

	if not cFrame then
		return
	end

	p.Size = Vector3.new(data.width, data.height, data.forwardEnd - data.forwardStart)
	p.CFrame = cFrame
end

local function clientBox(kind, data)
	local v8 = v2[kind]

	if not v8 then
		v8 = {
			box = 0
		}
		local name = "Client" .. kind .. "Hitbox"
		local part2 = Instance.new("Part")
		part2.Name = name
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.CastShadow = false
		part2.Material = Enum.Material.Neon
		part2.Color = color
		part2.Transparency = 0.67
		part2.Parent = workspace
		v8.box = part2
		v2[kind] = v8
	end

	draw(v8.box, data, data.position) -- equivalent call inferred; original call site unknown
end

hitboxDebugEvent.OnClientEvent:Connect(function(data)
	local DISTANCE_THRESHOLD = 0.15

	if type(data) == "table" and data.kind == "RewindContact" then
		if not visibleHitboxes() then
			return
		end

		local v8 = {
			expires = workspace:GetServerTimeNow() + 1.5
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dot(name, claimedTarget, color5)
			if typeof(claimedTarget) ~= "Vector3" then
				return
			end

			local part2 = Instance.new("Part")
			part2.Name = name
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.CastShadow = false
			part2.Material = Enum.Material.Neon
			part2.Color = color5
			part2.Transparency = 0.2
			part2.Parent = workspace
			part2.Shape = Enum.PartType.Ball
			part2.Size = createVector(0.5, 0.5, 0.5)
			part2.Position = claimedTarget
			v8[name] = part2
			return part2
		end

		local v10 = dot("ClaimedContact", data.claimedTarget, color) -- equivalent call inferred; original call site unknown
		local rewindTarget = data.rewindTarget
		local color6 = color2

		if typeof(rewindTarget) == "Vector3" then
			local part2 = Instance.new("Part")
			part2.Name = "ValidatedTarget"
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.CastShadow = false
			part2.Material = Enum.Material.Neon
			part2.Color = color6
			part2.Transparency = 0.2
			part2.Parent = workspace
			part2.Shape = Enum.PartType.Ball
			part2.Size = createVector(0.5, 0.5, 0.5)
			part2.Position = rewindTarget
			v8.ValidatedTarget = part2
		end

		if type(data.box) == "table" and typeof(data.direction) == "Vector3" then
			local v12 = {
				direction = data.direction,
				width = data.box.width,
				height = data.box.height,
				forwardStart = data.box.near,
				forwardEnd = data.box.far
			}

			for _, v13 in {
				{ "ClaimedStrike", data.claimedOrigin, color },
				{ "ValidatedStrike", data.rewindOrigin, color2 }
			} do
				if typeof(v13[2]) ~= "Vector3" then
					continue
				end

				local name = v13[1]
				local color5 = v13[3]
				local part2 = Instance.new("Part")
				part2.Name = name
				part2.Anchored = true
				part2.CanCollide = false
				part2.CanTouch = false
				part2.CanQuery = false
				part2.CastShadow = false
				part2.Material = Enum.Material.Neon
				part2.Color = color5
				part2.Transparency = 0.88
				part2.Parent = workspace
				draw(part2, v12, v13[2]) -- equivalent call inferred; original call site unknown
				v8[v13[1]] = part2
			end
		end

		if v10 and v then
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Adornee = v10
			billboardGui.Size = UDim2.fromOffset(270, 60)
			billboardGui.StudsOffset = createVector(0, 3, 0)
			billboardGui.AlwaysOnTop = true
			billboardGui.Parent = v10
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Size = UDim2.fromScale(1, 1)
			textLabel2.BackgroundTransparency = 0.3
			textLabel2.BackgroundColor3 = Color3.fromRGB(10, 18, 25)
			textLabel2.TextScaled = true
			textLabel2.TextWrapped = true
			textLabel2.TextColor3 = data.accepted and Color3.fromRGB(100, 255, 130) or Color3.fromRGB(255, 100, 100)
			textLabel2.Text = tostring(data.attackKind) .. (data.accepted and " HIT" or " REJECTED") .. "\\n" .. tostring(data.reason or "resolved") .. (data.rewindTarget and string.format(
				" · %.2f studs pose difference",
				(data.rewindTarget - data.claimedTarget).Magnitude
			) or " · no matching history")
			textLabel2.Parent = billboardGui
		end

		table.insert(v7, v8)

		while #v7 > 8 do
			clear(table.remove(v7, 1))
		end
	elseif type(data) == "table" and data.kind == "PlayerPositions" then
		local v8 = {}

		for _, v9 in data.snapshots or {} do
			if not (typeof(v9.character) == "Instance" and typeof(v9.cf) == "CFrame" and typeof(v9.size) == "Vector3") then
				continue
			end

			v8[v9.character] = v9
		end

		v6 = v8
	else
		if not visibleHitboxes() or type(data) ~= "table" or typeof(data.character) ~= "Instance" or typeof(data.position) ~= "Vector3" or typeof(data.direction) ~= "Vector3" or type(data.kind) ~= "string" then
			return
		end

		local v8 = v3[data.character]

		if not v8 then
			v8 = {}
			v3[data.character] = v8
		end

		local v9 = v8[data.kind]

		if not v9 then
			v9 = {
				box = 0,
				before = 0,
				path = 0
			}
			local name = "Server" .. data.kind .. "Hitbox"
			local part2 = Instance.new("Part")
			part2.Name = name
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.CastShadow = false
			part2.Material = Enum.Material.Neon
			part2.Color = color2
			part2.Transparency = 0.65
			part2.Parent = workspace
			v9.box = part2
			local name2 = "Server" .. data.kind .. "Previous"
			local part3 = Instance.new("Part")
			part3.Name = name2
			part3.Anchored = true
			part3.CanCollide = false
			part3.CanTouch = false
			part3.CanQuery = false
			part3.CastShadow = false
			part3.Material = Enum.Material.Neon
			part3.Color = color3
			part3.Transparency = 0.87
			part3.Parent = workspace
			v9.before = part3
			local name3 = "Server" .. data.kind .. "Path"
			local part4 = Instance.new("Part")
			part4.Name = name3
			part4.Anchored = true
			part4.CanCollide = false
			part4.CanTouch = false
			part4.CanQuery = false
			part4.CastShadow = false
			part4.Material = Enum.Material.Neon
			part4.Color = color3
			part4.Transparency = 0.55
			part4.Parent = workspace
			v9.path = part4
			v8[data.kind] = v9
		end

		v9.expires = workspace:GetServerTimeNow() + 0.25
		draw(v9.box, data, data.position) -- equivalent call inferred; original call site unknown
		local from = typeof(data.from) == "Vector3" and data.from or data.position
		draw(v9.before, data, from) -- equivalent call inferred; original call site unknown
		local v10 = data.position - from
		v9.before.Transparency = v10.Magnitude > DISTANCE_THRESHOLD and 0.87 or 1
		v9.path.Transparency = v10.Magnitude > DISTANCE_THRESHOLD and 0.55 or 1

		if v10.Magnitude > DISTANCE_THRESHOLD then
			v9.path.Size = Vector3.new(0.12, 0.12, v10.Magnitude)
			v9.path.CFrame = CFrame.lookAt((from + data.position) * 0.5, data.position)
		end

		for _, v11 in data.targets or {} do
			if not (typeof(v11.character) == "Instance" and typeof(v11.position) == "Vector3") then
				continue
			end

			local v12 = v4[v11.character]

			if not v12 then
				v12 = {
					box = 0
				}
				local part2 = Instance.new("Part")
				part2.Name = "ServerRunnerRoot"
				part2.Anchored = true
				part2.CanCollide = false
				part2.CanTouch = false
				part2.CanQuery = false
				part2.CastShadow = false
				part2.Material = Enum.Material.Neon
				part2.Color = color4
				part2.Transparency = 0.38
				part2.Parent = workspace
				v12.box = part2
				v12.box.Shape = Enum.PartType.Ball
				v12.box.Size = createVector(1.25, 1.25, 1.25)
				v4[v11.character] = v12
			end

			v12.box.CFrame = CFrame.new(v11.position)
			v12.expires = workspace:GetServerTimeNow() + 0.25
		end
	end
end)
RunService.RenderStepped:Connect(function()
	local v8 = visibleHitboxes() -- equivalent call inferred; original call site unknown
	screenGui.Enabled = v and v8

	if not v8 then
		clearAll()
		return
	end

	local v9 = {}

	for _, v10 in Players:GetPlayers() do
		local character = v10.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not (humanoidRootPart and humanoid and humanoid.Health > 0) then
			continue
		end

		v9[character] = true
		local v11 = v5[character]

		if not v11 then
			v11 = {
				client = 0,
				server = 0
			}
			local part2 = Instance.new("Part")
			part2.Name = "ClientPlayerRoot"
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.CastShadow = false
			part2.Material = Enum.Material.Neon
			part2.Color = color
			part2.Transparency = 0.8
			part2.Parent = workspace
			v11.client = part2
			local part3 = Instance.new("Part")
			part3.Name = "ServerPlayerRoot"
			part3.Anchored = true
			part3.CanCollide = false
			part3.CanTouch = false
			part3.CanQuery = false
			part3.CastShadow = false
			part3.Material = Enum.Material.Neon
			part3.Color = color2
			part3.Transparency = 0.8
			part3.Parent = workspace
			v11.server = part3
			v5[character] = v11

			for _, v14 in { v11.client, v11.server } do
				local selectionBox = Instance.new("SelectionBox")
				selectionBox.Adornee = v14
				selectionBox.Color3 = v14.Color
				selectionBox.LineThickness = 0.035
				selectionBox.SurfaceTransparency = 1
				selectionBox.Parent = v14
			end
		end

		v11.client.CFrame = humanoidRootPart.CFrame
		v11.client.Size = humanoidRootPart.Size
		local v12 = v6[character]
		v11.server.Transparency = v12 and 0.8 or 1
		v11.server.SelectionBox.Visible = v12 ~= nil

		if not v12 then
			continue
		end

		v11.server.CFrame = v12.cf
		v11.server.Size = v12.size
	end

	for k, v10 in v5 do
		if v9[k] then
			continue
		end

		clear(v10)
		v5[k] = nil
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	for i = #v7, 1, -1 do
		if v7[i].expires < serverTimeNow then
			clear(table.remove(v7, i))
		end
	end

	local v10 = {}

	for _, v11 in CombatPrediction.debugAttacks() or {} do
		v10[v11.kind] = true
		clientBox(v11.kind, v11)
	end

	for k, v11 in v2 do
		if v10[k] then
			continue
		end

		clear(v11)
		v2[k] = nil
	end

	for k, v11 in v3 do
		for k2, v12 in v11 do
			if not (v12.expires < serverTimeNow or not k.Parent) then
				continue
			end

			clear(v12)
			v11[k2] = nil
		end

		if not next(v11) then
			v3[k] = nil
		end
	end

	for k, v11 in v4 do
		if not (v11.expires < serverTimeNow or not k.Parent) then
			continue
		end

		clear(v11)
		v4[k] = nil
	end
end)
script.Destroying:Connect(function()
	clearAll()
	screenGui:Destroy()
end)