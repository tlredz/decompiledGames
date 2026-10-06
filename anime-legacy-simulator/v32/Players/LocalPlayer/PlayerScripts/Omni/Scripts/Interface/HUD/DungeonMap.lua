local module = require("@game/ReplicatedStorage/Omni")
local v = {
	Completed = Color3.fromRGB(70, 220, 90),
	Start = Color3.fromRGB(60, 140, 255),
	Treasure = Color3.fromRGB(255, 200, 40),
	Default = Color3.fromRGB(128, 128, 128)
}
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local stateManager = module.Utils.StateManager
local gamemodeMinimap = module.Interface:WaitForChild("HUD"):WaitForChild("GamemodeMinimap")
local rooms = gamemodeMinimap:WaitForChild("Rooms")
local arrow = gamemodeMinimap:WaitForChild("Arrow")
local addZoom = gamemodeMinimap:WaitForChild("AddZoom")
local removeZoom = gamemodeMinimap:WaitForChild("RemoveZoom")
local roomTemplate = rooms:WaitForChild("RoomTemplate")
local doorTemplate = roomTemplate:WaitForChild("DoorTemplate")
local currentCamera = workspace.CurrentCamera
local maps = workspace:WaitForChild("Client"):WaitForChild("Maps")
local v2 = {}
local v3 = nil
local v4 = {}
local v5 = {}
local v6 = nil
local v7 = nil
local minimapColors = {}
local v8 = 0
local size = roomTemplate.Size
local v9 = 1
local thread = nil
local value = scope:Value(v9)
local spring = scope:Spring(value, 10, 1)
local DungeonMap = {}

local function ClearDoors(parent)
	for _, child in parent:GetChildren() do
		if child.Name == "Door" then
			child:Destroy()
		end
	end
end

local function BuildEdge(p: string, parent, flag: boolean)
	if not flag then
		return
	end

	local clone = doorTemplate:Clone()
	clone.Name = "Door"
	clone.Visible = true

	if p == "East" then
		clone.AnchorPoint = Vector2.new(1, 0.5)
		clone.Position = UDim2.fromScale(1, 0.5)
		clone.Size = UDim2.fromScale(0.1, 1)
	elseif p == "North" then
		clone.AnchorPoint = Vector2.new(0.5, 0)
		clone.Position = UDim2.fromScale(0.5, 0)
		clone.Size = UDim2.fromScale(1, 0.1)
	elseif p == "South" then
		clone.AnchorPoint = Vector2.new(0.5, 1)
		clone.Position = UDim2.fromScale(0.5, 1)
		clone.Size = UDim2.fromScale(1, 0.1)
	else
		clone.AnchorPoint = Vector2.new(0, 0.5)
		clone.Position = UDim2.fromScale(0, 0.5)
		clone.Size = UDim2.fromScale(0.1, 1)
	end

	clone.Parent = parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyRoomColor(p: string, p2)
	local v10 = v3 and v3[p]
	local type = "Default"

	if v5[p] then
		type = "Completed"
	elseif v10 and (v10.Type == "Start" or v10.Type == "Treasure") then
		type = v10.Type
	end

	p2.BackgroundColor3 = minimapColors[type] or v[type]
end

local function ApplyRoomMeta(p: string, parent)
	ApplyRoomColor(p, parent) -- equivalent call inferred; original call site unknown
	local v10 = v3 and v3[p]

	if not v10 then
		return
	end

	local connections = v10.Connections or {}
	local north = connections.North == true
	local south = connections.South == true
	local east = connections.East == true
	local west = connections.West == true
	local formatted = `{north and 1 or 0}{south and 1 or 0}{east and 1 or 0}{west and 1 or 0}`

	if parent:GetAttribute("Doors") == formatted then
		return
	end

	parent:SetAttribute("Doors", formatted)
	ClearDoors(parent)

	if north then
		local clone = doorTemplate:Clone()
		clone.Name = "Door"
		clone.Visible = true
		clone.AnchorPoint = Vector2.new(0.5, 0)
		clone.Position = UDim2.fromScale(0.5, 0)
		clone.Size = UDim2.fromScale(1, 0.1)
		clone.Parent = parent
	end

	if south then
		local clone = doorTemplate:Clone()
		clone.Name = "Door"
		clone.Visible = true
		clone.AnchorPoint = Vector2.new(0.5, 1)
		clone.Position = UDim2.fromScale(0.5, 1)
		clone.Size = UDim2.fromScale(1, 0.1)
		clone.Parent = parent
	end

	if east then
		local clone = doorTemplate:Clone()
		clone.Name = "Door"
		clone.Visible = true
		clone.AnchorPoint = Vector2.new(1, 0.5)
		clone.Position = UDim2.fromScale(1, 0.5)
		clone.Size = UDim2.fromScale(0.1, 1)
		clone.Parent = parent
	end

	if not west then
		return
	end

	local clone = doorTemplate:Clone()
	clone.Name = "Door"
	clone.Visible = true
	clone.AnchorPoint = Vector2.new(0, 0.5)
	clone.Position = UDim2.fromScale(0, 0.5)
	clone.Size = UDim2.fromScale(0.1, 1)
	clone.Parent = parent
end

local function CreateRoomIcon(name: string)
	local clone = roomTemplate:Clone()
	clone.Name = name
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Visible = false
	local doorTemplate2 = clone:FindFirstChild("DoorTemplate")

	if doorTemplate2 then
		doorTemplate2:Destroy()
	end

	clone.Parent = rooms
	v2[name] = clone
	ApplyRoomMeta(name, clone)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveRoomIcon(k: string)
	local v10 = v2[k]

	if not v10 then
		return
	end

	v10:Destroy()
	v2[k] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearAllRoomIcons()
	for _, v10 in v2 do
		v10:Destroy()
	end

	table.clear(v2)
end

local function SyncRoomIcons()
	for k in v2 do
		local v10

		if v3 == nil or v3[k] == nil then
			v10 = false
		else
			v10 = v4[k] == true
		end

		if v10 then
			continue
		end

		RemoveRoomIcon(k) -- equivalent call inferred; original call site unknown
	end

	if not v3 then
		return
	end

	for k in v4 do
		if v2[k] or not v3[k] then
			continue
		end

		CreateRoomIcon(k)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDungeonState(p: string)
	if not v7 then
		return
	end

	local v10 = stateManager.Get(v7)

	if v10 then
		return v10:GetState(p)
	end
end

local function RefreshRoomsMeta()
	local dungeonState = GetDungeonState("Rooms") -- equivalent call inferred; original call site unknown

	if typeof(dungeonState) ~= "table" then
		return
	end

	v3 = dungeonState

	for k, v11 in v2 do
		ApplyRoomMeta(k, v11)
	end

	SyncRoomIcons()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshClearedRooms()
	local dungeonState = GetDungeonState("ClearedRooms") -- equivalent call inferred; original call site unknown

	if typeof(dungeonState) ~= "table" then
		return
	end

	v5 = dungeonState

	for k, v11 in v2 do
		ApplyRoomColor(k, v11) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshVisibleRooms()
	local dungeonState = GetDungeonState("VisibleRooms") -- equivalent call inferred; original call site unknown

	if typeof(dungeonState) ~= "table" then
		return
	end

	v4 = dungeonState
	SyncRoomIcons()
end

local function Unbind()
	ClearAllRoomIcons() -- equivalent call inferred; original call site unknown
	v3 = nil
	v4 = {}
	v5 = {}
	v7 = nil
	minimapColors = {}
end

local function Bind(gamemode: string)
	local child = maps:FindFirstChild(gamemode)

	if not child then
		return
	end

	local v10 = module.Shared.Gamemodes.List[gamemode]
	v7 = child
	minimapColors = typeof(v10) == "table" and v10.MinimapColors or {}
	RefreshClearedRooms() -- equivalent call inferred; original call site unknown
	RefreshVisibleRooms() -- equivalent call inferred; original call site unknown
	RefreshRoomsMeta()
end

local function SetZoom(p: number)
	v9 = math.clamp(math.round(p / 0.1) * 0.1, 0.3, 2)
	value:set(v9)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopZoomHold()
	if not thread then
		return
	end

	if coroutine.status(thread) ~= "running" then
		task.cancel(thread)
	end

	thread = nil
end

local function StartZoomHold(p: number)
	StopZoomHold() -- equivalent call inferred; original call site unknown
	v9 = math.clamp(math.round((v9 + p * 0.1) / 0.1) * 0.1, 0.3, 2)
	value:set(v9)
	thread = task.delay(0.35, function()
		while gamemodeMinimap.Visible do
			v9 = math.clamp(math.round((v9 + p * 0.1) / 0.1) * 0.1, 0.3, 2)
			value:set(v9)
			task.wait(0.08)
		end

		thread = nil
	end)
end

function DungeonMap.Refresh()
	local gamemode = module.Data.Gamemode
	local v10

	if typeof(gamemode) == "string" then
		v10 = module.Shared.Gamemodes.List[gamemode]
	else
		v10 = false
	end

	local v11

	if typeof(v10) == "table" then
		v11 = v10.Type == "Dungeon"
	else
		v11 = false
	end

	if v11 then
		if v6 ~= gamemode then
			Unbind()
			v6 = gamemode
			Bind(gamemode)
		end

		gamemodeMinimap.Visible = true
	else
		if v6 then
			Unbind()
			v6 = nil
		end

		StopZoomHold() -- equivalent call inferred; original call site unknown
		gamemodeMinimap.Visible = false
	end
end

function DungeonMap.Init()
	roomTemplate.Visible = false
	stateManager.MonitorateState("Rooms", function(p)
		if p ~= v7 then
			return
		end

		RefreshRoomsMeta()
	end)
	stateManager.MonitorateState("VisibleRooms", function(p)
		if p ~= v7 then
			return
		end

		RefreshVisibleRooms() -- equivalent call inferred; original call site unknown
	end)
	stateManager.MonitorateState("ClearedRooms", function(p)
		if p ~= v7 then
			return
		end

		RefreshClearedRooms() -- equivalent call inferred; original call site unknown
	end)
	module:OnDataChanged({ "Gamemode" }, DungeonMap.Refresh)
	DungeonMap.Refresh()
end

local v10 = module.Button:Create(addZoom, "Small")
v10:BindOnPress("Zoom", function()
	StopZoomHold() -- equivalent call inferred; original call site unknown
	v9 = math.clamp(math.round((v9 + 0.1) / 0.1) * 0.1, 0.3, 2)
	value:set(v9)
	local v11 = 1
	thread = task.delay(0.35, function()
		while gamemodeMinimap.Visible do
			v9 = math.clamp(math.round((v9 + v11 * 0.1) / 0.1) * 0.1, 0.3, 2)
			value:set(v9)
			task.wait(0.08)
		end

		thread = nil
	end)
end)
v10:BindOnRelease("Zoom", StopZoomHold)
local v11 = module.Button:Create(removeZoom, "Small")
v11:BindOnPress("Zoom", function()
	StopZoomHold() -- equivalent call inferred; original call site unknown
	v9 = math.clamp(math.round((v9 + -0.1) / 0.1) * 0.1, 0.3, 2)
	value:set(v9)
	local v12 = -1
	thread = task.delay(0.35, function()
		while gamemodeMinimap.Visible do
			v9 = math.clamp(math.round((v9 + v12 * 0.1) / 0.1) * 0.1, 0.3, 2)
			value:set(v9)
			task.wait(0.08)
		end

		thread = nil
	end)
end)
v11:BindOnRelease("Zoom", StopZoomHold)
module.Services.RunService.Heartbeat:Connect(function()
	if not gamemodeMinimap.Visible then
		return
	end

	local now = os.clock()

	if now - v8 < 0.03333333333333333 then
		return
	end

	v8 = now
	local HRP = module:GetHRP()

	if not (HRP and v3) then
		return
	end

	local currentSpring = fusion.peek(spring)
	local uDim = UDim2.fromScale(size.X.Scale * currentSpring, size.Y.Scale * currentSpring)
	local position = HRP.Position
	local v12 = rooms.AbsoluteSize.X * size.X.Scale * currentSpring / 69

	for k, v13 in v2 do
		local v14 = v3[k]
		local center = v14 and v14.Center

		if typeof(center) == "Vector3" then
			local v15 = center - position
			v13.Size = uDim
			v13.Position = UDim2.new(0.5, v15.X * v12, 0.5, v15.Z * v12)
			v13.Visible = true
		else
			v13.Visible = false
		end
	end

	local lookVector = currentCamera.CFrame.LookVector
	arrow.Rotation = math.deg((math.atan2(lookVector.X, -lookVector.Z)))
end)
return DungeonMap