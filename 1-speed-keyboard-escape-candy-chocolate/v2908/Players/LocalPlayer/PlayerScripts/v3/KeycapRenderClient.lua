local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Squash = require(ReplicatedStorage.Packages.Squash)
local keycapsRendering = ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("KeycapsRendering")
local KeycapStreamConfig = require(keycapsRendering:WaitForChild("KeycapStreamConfig"))
local KeycapRecordSchema = require(keycapsRendering:WaitForChild("KeycapRecordSchema"))
local KeycapPoolRenderer = require(keycapsRendering:WaitForChild("KeycapPoolRenderer"))
local KeycapStreamRemotes = require(keycapsRendering:WaitForChild("KeycapStreamRemotes"))
local KeycapRenderDebugState = require(keycapsRendering:WaitForChild("KeycapRenderDebugState"))

local function checkTemplatesReady()
	local child = ReplicatedStorage:WaitForChild(KeycapStreamConfig.TemplateFolderName, 30)

	if not child then
		return false, nil, nil, "ReplicatedStorage." .. KeycapStreamConfig.TemplateFolderName .. " missing"
	end

	local child2 = child:WaitForChild(KeycapStreamConfig.TemplatePartName, 30)
	local child3 = child:WaitForChild(KeycapStreamConfig.SurfaceAppearanceFolderName, 30)

	if child2 and child3 then
		return true, child2, child3, ""
	end

	return
		false,
		nil,
		nil,
		"Keycap template or SurfaceAppearances folder missing under " .. KeycapStreamConfig.TemplateFolderName
end

local v, v2, v3, v4 = checkTemplatesReady()

if not v then
	warn("[KeycapRenderClient]", v4)
	return
end

local keycaps = Workspace:WaitForChild("Keycaps")
local renderer = KeycapPoolRenderer.new(v2, keycaps, v3)
renderer:Start()
KeycapRenderDebugState.renderer = renderer
local vlq = Squash.vlq()
local schema = KeycapRecordSchema.Schema
local idSerDes = KeycapRecordSchema.IdSerDes
local flag = false
local des = {}
local v6 = {}
local v7 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function syncDebugPending()
	KeycapRenderDebugState.snapshotActive = flag
	KeycapRenderDebugState.pendingAddCount = #des
	local count = 0

	for _ in pairs(v7) do
		count += 1
	end

	KeycapRenderDebugState.pendingRemoveCount = count
end

local function dropPendingAdd(des2: number)
	if v6[des2] then
		v6[des2] = nil

		for i, v8 in ipairs(des) do
			if v8.Id ~= des2 then
				continue
			end

			table.remove(des, i)
			return
		end
	end
end

local function applyRecords(buf: buffer, flag2: boolean)
	local frombuffer = Squash.frombuffer(buf)

	for _ = 1, vlq.des(frombuffer) do
		local des2 = schema.des(frombuffer)

		if not (flag2 and v7[des2.Id]) then
			renderer:AddRecord(des2)
		end
	end
end

local function applyRemoves(buf: buffer)
	local frombuffer = Squash.frombuffer(buf)

	for _ = 1, vlq.des(frombuffer) do
		renderer:RemoveRecord(idSerDes.des(frombuffer))
	end
end

local function bufferAdds(buf: buffer)
	local frombuffer = Squash.frombuffer(buf)

	for _ = 1, vlq.des(frombuffer) do
		local des2 = schema.des(frombuffer)

		if v7[des2.Id] or v6[des2.Id] then
			continue
		end

		v6[des2.Id] = des2
		table.insert(des, des2)
	end
end

local function bufferRemoves(buf: buffer)
	local frombuffer = Squash.frombuffer(buf)

	for _ = 1, vlq.des(frombuffer) do
		local des2 = idSerDes.des(frombuffer)
		v7[des2] = true
		dropPendingAdd(des2)
	end
end

local function flushPendingDeltas()
	for _, v8 in ipairs(des) do
		if not v7[v8.Id] then
			renderer:AddRecord(v8)
		end
	end

	for k in pairs(v7) do
		renderer:RemoveRecord(k)
	end

	table.clear(des)
	table.clear(v6)
	table.clear(v7)
end

KeycapStreamRemotes.Reset:connect(function()
	flag = true
	table.clear(des)
	table.clear(v6)
	table.clear(v7)
	syncDebugPending() -- equivalent call inferred; original call site unknown
	renderer:Clear()
end)
KeycapStreamRemotes.Batch:connect(function(buf: buffer)
	if flag then
		applyRecords(buf, true)
	end
end)
KeycapStreamRemotes.DeltaAdd:connect(function(buf: buffer)
	if not flag then
		applyRecords(buf, false)
		return
	end

	bufferAdds(buf)
	syncDebugPending() -- equivalent call inferred; original call site unknown
end)
KeycapStreamRemotes.DeltaRemove:connect(function(buf: buffer)
	if not flag then
		applyRemoves(buf)
		return
	end

	bufferRemoves(buf)
	syncDebugPending() -- equivalent call inferred; original call site unknown
end)
KeycapStreamRemotes.Done:connect(function()
	flushPendingDeltas()
	flag = false
	syncDebugPending() -- equivalent call inferred; original call site unknown
end)
syncDebugPending() -- equivalent call inferred; original call site unknown
KeycapStreamRemotes.RequestStream:fire()