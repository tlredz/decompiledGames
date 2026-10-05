local createVector = vector.create
local AssetService = game:GetService("AssetService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CUI = require(ReplicatedStorage:WaitForChild("CUI"))
local KeycapStreamConfig = require(script.Parent.KeycapStreamConfig)
local KeycapRenderDebugState = require(script.Parent.KeycapRenderDebugState)
local KeycapRecordSchema = require(script.Parent.KeycapRecordSchema)
local noneSentinel = KeycapRecordSchema.NoneSentinel
local chunkSize = KeycapStreamConfig.ChunkSize
local v = { "1.5", "2", "2.5" }
local color = Color3.fromRGB(28, 28, 32)
local v2 = {
	"Loaded",
	"Visibility",
	"Queue",
	"Vis+Queue",
	"Char",
	"KeyType",
	"MusicType"
}
local joined = table.concat({
	"KEYCAP RENDER DEBUG — FIELD GUIDE",
	"",
	"RECORDS / MAP",
	"Records — Streamed keycap records currently known to the client (from snapshot + deltas).",
	"loaded — Records that currently have a live MeshPart instance parented in Workspace.Keycaps.",
	"unloaded — Records known but not currently shown (no _activeInstance; recycled into the pool).",
	"mapDots — How many records the debug map drew on the last map refresh.",
	"",
	"QUEUES",
	"Queues load — Renderer load queue length: records waiting to get an instance this/next frames.",
	"Queues unload — Unload queue length: records waiting to return their instance to the pool.",
	"  High load + unload together often means the camera is moving across chunk boundaries.",
	"",
	"CHUNKS",
	"Chunks all — Total spatial chunks that exist in the client ChunkSystem grid (any with records).",
	"desired — Chunks in the camera’s ±1 neighborhood that should stay loaded right now.",
	"loadedFlag — Chunks marked loaded by the renderer (includes ones still draining via unload queue).",
	"  desired ≈ what should be visible; loadedFlag can lag briefly during transitions.",
	"",
	"INSTANCES / CAPS",
	"Instances — Total MeshPart clones created across all character pools (active + pooled).",
	"MaxCap — How many character pools have reached MaxInstancesPerChar (currently " .. tostring(KeycapStreamConfig.MaxInstancesPerChar) .. ").",
	"MaxCap A, B — Which pools are at that hard clone ceiling.",
	"AtCap — How many character pools have 0 free instances left in the recycle pool (all clones are out/active).",
	"AtCap A, B — Which pools currently have an empty recycle pool.",
	"max/char — Config cap: hard ceiling of clones per glyph; never destroyed, only recycled.",
	"  MaxCap + empty pool (often also AtCap) means new loads for that char must reclaim via unload.",
	"",
	"SNAPSHOT / PENDING",
	"Snapshot YES — Client is mid join-snapshot (Reset → Batch* → Done). Live deltas are buffered.",
	"Snapshot no — Snapshot finished; DeltaAdd/Remove apply immediately.",
	"pending +N — Mid-snapshot DeltaAdds buffered until Done (not in the renderer yet).",
	"pending -N — Mid-snapshot DeltaRemoves buffered; matching Batch ids are skipped.",
	"",
	"CAMERA / VIEW",
	"Camera — Workspace.CurrentCamera world position (what drives real chunk loading).",
	"chunk — Current camera chunk cell center (nil until the renderer has a current chunk).",
	"View — Debug map pan center (XZ). Equals camera when Follow camera is on.",
	"zoom — Map pixels per stud (host UI space).",
	"",
	"BREAKDOWNS",
	"KeyTypes — Count by Type attribute (Normal vs Event, etc.).",
	"Music — Count by MusicType (MusicalKey / MusicalKey2 / None) — drives KeySystem press depth.",
	"",
	"MAP CONTROLS",
	"Render keycaps — When off: unload all live MeshParts and skip chunk load/unload (records stay).",
	"  Cmdr: krender [true|false] (omit arg to toggle). Re-enable reloads around the camera.",
	"Color modes — How dots are colored (Loaded, Visibility, Queue, Vis+Queue, Char, KeyType, MusicType).",
	"  Vis+Queue — queue colors (yellow/orange/magenta) win; otherwise visibility cyan/gray.",
	"Extent ×chunk — Half-size of the map cull AABB as a multiple of ChunkSize (" .. tostring(KeycapStreamConfig.ChunkSize) .. "). 1.5 ≈ renderer ±1 chunk footprint.",
	"Radius view — When on: cull map dots to that AABB (+ overlays in Loaded/Visibility).",
	"  When off: draw every record (no cull) and hide the AABB gizmo.",
	"Chunk grid — Draw all chunk cell outlines (desired cells tinted).",
	"Camera marker — Yellow dot = camera XZ on the map.",
	"Follow camera — Keep map view centered on the camera.",
	"",
	"INSPECT WINDOW",
	"Click a map dot to see Id, Char, pose, size, KeyType, MusicType, chunk, and instance path."
}, "\n")
local v3 = {
	Loaded = "green=loaded  red=unloaded",
	Visibility = "cyan=desired chunk  gray=outside",
	Queue = "yellow=loadQ  orange=unloadQ  magenta=both  gray=idle",
	["Vis+Queue"] = "queue colors first, else cyan=desired / gray=outside",
	Char = "color = hash(Char)",
	KeyType = "blue=Normal  red=Event  gray=other",
	MusicType = "green=MusicalKey  yellow=MusicalKey2  gray=none"
}
local KeycapRenderDebug = {}
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local flag = false
local v8 = false
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
local v18 = nil
local v19 = nil
local ctn = nil
local imageLabel = nil
local frame = nil
local frame2 = nil
local v20 = nil
local v21 = nil
local buf = nil
local buf2 = nil
local flag2 = false
local v22 = nil
local heartbeatConnection = nil
local connections = {}
local v23 = "Loaded"
local v24 = 1.5
local v25 = true
local v26 = true
local v27 = true
local v28 = true
local X = 0
local Z = 0
local v29 = 0.08
local id = nil
local flag3 = false
local vector2 = nil
local v30 = true
local v31 = 0
local v32 = 0
local drawn = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function getNeighborHalfExtent()
	return chunkSize * v24
end

local function hashColor(char: string)
	local v34 = 0

	for i = 1, #char do
		v34 = (v34 * 31 + string.byte(char, i)) % 360
	end

	return Color3.fromHSV(v34 / 360, 0.75, 0.95)
end

local function recordColor(data, p: string, queueSets, p2, _desiredChunks)
	if p == "Loaded" then
		if data._activeInstance then
			return (Color3.fromRGB(80, 220, 120))
		end

		return (Color3.fromRGB(220, 70, 70))
	elseif p == "Visibility" then
		local _chunk = data._chunk

		if _chunk and _desiredChunks[_chunk] then
			return (Color3.fromRGB(80, 200, 230))
		end

		return (Color3.fromRGB(90, 90, 90))
	elseif p == "Queue" or p == "Vis+Queue" then
		local v34 = queueSets and queueSets[data] == true
		local v35 = p2 and p2[data] == true

		if v34 and v35 then
			return Color3.fromRGB(220, 80, 220)
		end

		if v34 then
			return Color3.fromRGB(240, 220, 60)
		end

		if v35 then
			return Color3.fromRGB(240, 140, 40)
		end

		if p ~= "Vis+Queue" then
			return Color3.fromRGB(100, 100, 100)
		end

		local _chunk = data._chunk

		if _chunk and _desiredChunks[_chunk] then
			return (Color3.fromRGB(80, 200, 230))
		end

		return (Color3.fromRGB(90, 90, 90))
	else
		if p == "Char" then
			return hashColor(data.Char or "?")
		end

		if p == "KeyType" then
			local keyType = data.KeyType

			if keyType == "Event" then
				return Color3.fromRGB(230, 70, 70)
			end

			if keyType == noneSentinel or keyType == nil then
				return Color3.fromRGB(70, 130, 230)
			end

			return Color3.fromRGB(160, 160, 160)
		else
			if p ~= "MusicType" then
				return Color3.new(1, 1, 1)
			end

			local musicType = data.MusicType

			if musicType == "MusicalKey" then
				return Color3.fromRGB(80, 220, 120)
			elseif musicType == "MusicalKey2" then
				return Color3.fromRGB(230, 210, 60)
			end

			return Color3.fromRGB(110, 110, 110)
		end
	end
end

local function foreachChunk(grid, chunkDimensions: number, fn)
	if not grid then
		return
	end

	if chunkDimensions == 2 then
		for _, item in pairs(grid) do
			for _, v34 in pairs(item) do
				fn(v34)
			end
		end
	else
		for _, item in pairs(grid) do
			for _, v34 in pairs(item) do
				for _, v35 in pairs(v34) do
					fn(v35)
				end
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMouseGuiPos()
	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

local function getMapHostSize()
	if ctn then
		local absoluteSize = ctn.AbsoluteSize

		if absoluteSize.X > 0 and absoluteSize.Y > 0 then
			return absoluteSize
		end
	end

	return Vector2.new(400, 400)
end

local function worldToHost(p: number, p2: number)
	local absoluteSize

	if ctn then
		absoluteSize = ctn.AbsoluteSize

		if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
			absoluteSize = Vector2.new(400, 400)
		end
	else
		absoluteSize = Vector2.new(400, 400)
	end

	return (p - X) * v29 + absoluteSize.X * 0.5, (p2 - Z) * v29 + absoluteSize.Y * 0.5
end

local function worldToImage(p: number, p2: number)
	local absoluteSize

	if ctn then
		absoluteSize = ctn.AbsoluteSize

		if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
			absoluteSize = Vector2.new(400, 400)
		end
	else
		absoluteSize = Vector2.new(400, 400)
	end

	local v34 = (p - X) * v29 + absoluteSize.X * 0.5
	local v35 = (p2 - Z) * v29 + absoluteSize.Y * 0.5
	local absoluteSize2

	if ctn then
		absoluteSize2 = ctn.AbsoluteSize

		if not (absoluteSize2.X > 0 and absoluteSize2.Y > 0) then
			absoluteSize2 = Vector2.new(400, 400)
		end
	else
		absoluteSize2 = Vector2.new(400, 400)
	end

	return v34 / absoluteSize2.X * 512, v35 / absoluteSize2.Y * 512
end

local function screenToWorld(point: Vector2)
	local absoluteSize

	if ctn then
		absoluteSize = ctn.AbsoluteSize

		if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
			absoluteSize = Vector2.new(400, 400)
		end
	else
		absoluteSize = Vector2.new(400, 400)
	end

	return (point.X - absoluteSize.X * 0.5) / v29 + X, (point.Y - absoluteSize.Y * 0.5) / v29 + Z
end

-- equivalent calls inferred from this helper; original call sites unknown
local function roundChunkAxis(p: number)
	return math.floor(p / chunkSize + 0.5) * chunkSize
end

local function getNeighborhoodOriginXZ()
	return roundChunkAxis(X), roundChunkAxis(Z)
end

local function withinNeighborRadius(p: number, p2: number)
	local v34 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
	local v35 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
	local neighborHalfExtent = getNeighborHalfExtent() -- equivalent call inferred; original call site unknown
	return math.abs(p - v34) <= neighborHalfExtent and math.abs(p2 - v35) <= neighborHalfExtent
end

local function foreachNeighborChunks(p, visit)
	local _grid = p._grid

	if not _grid then
		return
	end

	local currentCamera = Workspace.CurrentCamera
	local Y = currentCamera and currentCamera.CFrame.Position.Y or 0
	local v34 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
	local v35 = roundChunkAxis(Y) -- equivalent call inferred; original call site unknown
	local v36 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
	local v37 = chunkSize
	local v38 = math.max(0, (math.ceil(chunkSize * v24 / v37 - 0.5))) * v37

	for i = -v38, v38, v37 do
		for i2 = -v38, v38, v37 do
			if KeycapStreamConfig.ChunkDimensions == 3 then
				for i3 = -v38, v38, v37 do
					local chunk = _grid:GetChunk(Vector3.new(v34 + i, v35 + i3, v36 + i2), false)

					if chunk then
						visit(chunk)
					end
				end
			else
				local chunk = _grid:GetChunk(Vector3.new(v34 + i, 0, v36 + i2), false)

				if chunk then
					visit(chunk)
				end
			end
		end
	end
end

local function foreachOverlayChunks(p, visit)
	if v23 == "Loaded" then
		for k in pairs(p._loadedChunks) do
			visit(k)
		end
	elseif v23 == "Visibility" or v23 == "Vis+Queue" then
		for k in pairs(p._desiredChunks) do
			visit(k)
		end
	end
end

local function shouldDrawRecord(data, p)
	if not (v27 and id ~= data.Id) then
		return true
	end

	local X2 = data.Position.X
	local Z2 = data.Position.Z
	local v34 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
	local v35 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
	local neighborHalfExtent = getNeighborHalfExtent() -- equivalent call inferred; original call site unknown
	local v36

	if math.abs(X2 - v34) <= neighborHalfExtent then
		v36 = math.abs(Z2 - v35) <= neighborHalfExtent
	else
		v36 = false
	end

	if v36 or v23 == "Loaded" and data._activeInstance or (v23 == "Visibility" or v23 == "Vis+Queue") and data._chunk and p[data._chunk] then
		return true
	end

	return false
end

local function abandonEditableImage()
	if v21 then
		pcall(function()
			v21:Destroy()
		end)
		v21 = nil
	end

	buf = nil
	buf2 = nil
	flag2 = false

	if imageLabel then
		imageLabel.Visible = false
		pcall(function()
			imageLabel.ImageContent = Content.none
		end)
	end
end

local function showMapDisabledMessage()
	if not ctn then
		return
	end

	if imageLabel then
		imageLabel.Visible = false
	end

	if frame then
		frame.Visible = false
	end

	if frame2 then
		frame2.Visible = false
	end

	ctn.Active = false

	if v20 then
		v20.Visible = true
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "EditableImageRequired"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -24, 1, -24)
	textLabel.Position = UDim2.fromOffset(12, 12)
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 16
	textLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Text = "Please enable EditableImage (Experience Settings → Security)"
	textLabel.ZIndex = (ctn.ZIndex or 1) + 2
	textLabel.Parent = ctn
	v20 = textLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disableMap(p: string?)
	if v22 == "disabled" then
		return
	end

	abandonEditableImage()
	v22 = "disabled"
	showMapDisabledMessage()
	warn("[KeycapRenderDebug] EditableImage unavailable — map disabled" .. ((not p or p == "") and ". Enable it in Experience Settings → Security." or ": " .. tostring(p)))
end

local function ensureEditableImage()
	if v21 then
		return true
	end

	local success, result = pcall(function()
		return AssetService:CreateEditableImage({
			Size = Vector2.new(512, 512)
		})
	end)

	if not (success and result) then
		success, result = pcall(function()
			return AssetService:CreateEditableImageAsync({
				Size = Vector2.new(512, 512)
			})
		end)
	end

	if not (success and result) then
		return false
	end

	local buf3 = buffer.create(4)
	buffer.writeu8(buf3, 0, 28)
	buffer.writeu8(buf3, 1, 28)
	buffer.writeu8(buf3, 2, 32)
	buffer.writeu8(buf3, 3, 255)

	if not pcall(function()
		result:WritePixelsBuffer(Vector2.zero, Vector2.new(1, 1), buf3)
	end) then
		pcall(function()
			result:Destroy()
		end)
		return false
	end

	v21 = result
	buf = buffer.create(1048576)
	buf2 = buffer.create(1048576)

	for i = 0, 262143 do
		local v34 = i * 4
		buffer.writeu8(buf2, v34, 28)
		buffer.writeu8(buf2, v34 + 1, 28)
		buffer.writeu8(buf2, v34 + 2, 32)
		buffer.writeu8(buf2, v34 + 3, 255)
	end

	flag2 = false

	if not imageLabel then
		return true
	end

	if pcall(function()
		imageLabel.ImageContent = Content.fromObject(v21)
	end) then
		imageLabel.Visible = true
	else
		abandonEditableImage()
		return false
	end

	return true
end

local function ensureMapBackend()
	if v22 == "disabled" then
		return false
	end

	if v22 == "editable" then
		return ctn ~= nil and v21 ~= nil
	else
		if not ctn then
			return false
		end

		if ensureEditableImage() then
			v22 = "editable"
			return true
		end

		disableMap(false) -- equivalent call inferred; original call site unknown
		return false
	end
end

local function clearPixels()
	if flag2 then
		if not v21 then
			return
		end

		if not pcall(function()
			v21:DrawRectangle(Vector2.zero, Vector2.new(512, 512), color, 0, Enum.ImageCombineType.Overwrite)
		end) then
			if v22 == "disabled" then
				return
			end

			abandonEditableImage()
			v22 = "disabled"
			showMapDisabledMessage()
			warn("[KeycapRenderDebug] EditableImage unavailable — map disabled" .. ": " .. tostring("DrawRectangle blocked"))
		end
	elseif buf and buf2 then
		buffer.copy(buf, 0, buf2, 0, 1048576)
	end
end

local function setPixel(p: number, p2: number, color2: Color3)
	if flag2 then
		if not v21 then
			return
		end

		local v34 = math.floor(p)
		local v35 = math.floor(p2)

		if v34 < 0 or v35 < 0 or v34 >= 512 or v35 >= 512 then
			return
		end

		if not pcall(function()
			v21:DrawRectangle(Vector2.new(v34, v35), Vector2.new(2, 2), color2, 0, Enum.ImageCombineType.Overwrite)
		end) then
			if v22 == "disabled" then
				return
			end

			abandonEditableImage()
			v22 = "disabled"
			showMapDisabledMessage()
			warn("[KeycapRenderDebug] EditableImage unavailable — map disabled" .. ": " .. tostring("DrawRectangle blocked"))
		end
	else
		if not buf then
			return
		end

		local v34 = math.floor(p)
		local v35 = math.floor(p2)

		if v34 < 0 or v35 < 0 or v34 >= 512 or v35 >= 512 then
			return
		end

		local v36 = (v35 * 512 + v34) * 4
		buffer.writeu8(buf, v36, (math.floor(color2.R * 255 + 0.5)))
		buffer.writeu8(buf, v36 + 1, (math.floor(color2.G * 255 + 0.5)))
		buffer.writeu8(buf, v36 + 2, (math.floor(color2.B * 255 + 0.5)))
		buffer.writeu8(buf, v36 + 3, 255)

		if v34 + 1 < 512 then
			local v37 = v36 + 4
			buffer.writeu8(buf, v37, (math.floor(color2.R * 255 + 0.5)))
			buffer.writeu8(buf, v37 + 1, (math.floor(color2.G * 255 + 0.5)))
			buffer.writeu8(buf, v37 + 2, (math.floor(color2.B * 255 + 0.5)))
			buffer.writeu8(buf, v37 + 3, 255)
		end

		if v35 + 1 < 512 then
			local v37 = v36 + 2048
			buffer.writeu8(buf, v37, (math.floor(color2.R * 255 + 0.5)))
			buffer.writeu8(buf, v37 + 1, (math.floor(color2.G * 255 + 0.5)))
			buffer.writeu8(buf, v37 + 2, (math.floor(color2.B * 255 + 0.5)))
			buffer.writeu8(buf, v37 + 3, 255)

			if v34 + 1 < 512 then
				local v38 = v37 + 4
				buffer.writeu8(buf, v38, (math.floor(color2.R * 255 + 0.5)))
				buffer.writeu8(buf, v38 + 1, (math.floor(color2.G * 255 + 0.5)))
				buffer.writeu8(buf, v38 + 2, (math.floor(color2.B * 255 + 0.5)))
				buffer.writeu8(buf, v38 + 3, 255)
			end
		end
	end
end

local function drawRectOutline(p: number, p2: number, p3: number, p4: number, color2: Color3)
	local v34 = math.clamp(math.floor(p), 0, 511)
	local v35 = math.clamp(math.floor(p2), 0, 511)
	local v36 = math.clamp(math.floor(p3), 0, 511)
	local v37 = math.clamp(math.floor(p4), 0, 511)

	if v36 < v34 or v37 < v35 then
		return
	end

	local v38 = v36 - v34 + 1
	local v39 = v37 - v35 + 1

	if flag2 then
		v21:DrawRectangle(Vector2.new(v34, v35), Vector2.new(v38, 1), color2, 0, Enum.ImageCombineType.Overwrite)
		v21:DrawRectangle(Vector2.new(v34, v37), Vector2.new(v38, 1), color2, 0, Enum.ImageCombineType.Overwrite)
		v21:DrawRectangle(Vector2.new(v34, v35), Vector2.new(1, v39), color2, 0, Enum.ImageCombineType.Overwrite)
		v21:DrawRectangle(Vector2.new(v36, v35), Vector2.new(1, v39), color2, 0, Enum.ImageCombineType.Overwrite)
	else
		if not buf then
			return
		end

		local v40 = math.floor(color2.R * 255 + 0.5)
		local v41 = math.floor(color2.G * 255 + 0.5)
		local v42 = math.floor(color2.B * 255 + 0.5)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function plot(p5: number, p6: number)
			local v43 = (p6 * 512 + p5) * 4
			buffer.writeu8(buf, v43, v40)
			buffer.writeu8(buf, v43 + 1, v41)
			buffer.writeu8(buf, v43 + 2, v42)
			buffer.writeu8(buf, v43 + 3, 255)
		end

		for i = v34, v36 do
			plot(i, v35) -- equivalent call inferred; original call site unknown
			plot(i, v37) -- equivalent call inferred; original call site unknown
		end

		for i = v35, v37 do
			plot(v34, i) -- equivalent call inferred; original call site unknown
			plot(v36, i) -- equivalent call inferred; original call site unknown
		end
	end
end

local function flushPixels()
	if flag2 or not (v21 and buf) then
		return
	end

	local success, result = pcall(function()
		v21:WritePixelsBuffer(Vector2.zero, Vector2.new(512, 512), buf)
	end)

	if not success then
		disableMap(tostring(result)) -- equivalent call inferred; original call site unknown
	end
end

local function buildQueueSets(data)
	if v23 ~= "Queue" and v23 ~= "Vis+Queue" then
		return nil, nil
	end

	local result = {}
	local result2 = {}

	for _, v34 in ipairs(data._loadQueue) do
		result[v34] = true
	end

	for _, v34 in ipairs(data._unloadQueue) do
		result2[v34] = true
	end

	return result, result2
end

local function countDict(items)
	local count = 0

	for _ in pairs(items) do
		count += 1
	end

	return count
end

local function gatherStats(object)
	local count = 0
	local count2 = 0
	local byKeyType = {}
	local byMusic = {}

	for _, v36 in pairs(object._byId) do
		count += 1

		if v36._activeInstance then
			count2 += 1
		end

		local v37 = v36.KeyType == noneSentinel and "Normal" or tostring(v36.KeyType)
		byKeyType[v37] = (byKeyType[v37] or 0) + 1
		local v38 = v36.MusicType == noneSentinel and "None" or tostring(v36.MusicType)
		byMusic[v38] = (byMusic[v38] or 0) + 1
	end

	local total = 0
	local maxCapChars = {}
	local atCapChars = {}

	for k, v38 in pairs(object._instanceCounts or {}) do
		total += v38
		local v39 = not object._pools[k] and 0 or #object._pools[k] or 0

		if KeycapStreamConfig.MaxInstancesPerChar <= v38 then
			table.insert(maxCapChars, k)
		end

		if v38 > 0 and v39 == 0 then
			table.insert(atCapChars, k)
		end
	end

	table.sort(maxCapChars)
	table.sort(atCapChars)
	local count3 = 0
	foreachChunk(object._grid and object._grid.Grid, KeycapStreamConfig.ChunkDimensions, function()
		count3 += 1
	end)
	local currentCamera = Workspace.CurrentCamera
	local position = currentCamera and currentCamera.CFrame.Position or createVector(0, 0, 0)
	local _currentChunk = object._currentChunk
	local position2 = _currentChunk and _currentChunk:GetPosition() or nil
	local v38 = {
		total = count,
		loaded = count2,
		unloaded = count - count2,
		loadQueue = #object._loadQueue,
		unloadQueue = #object._unloadQueue,
		desiredChunks = 0,
		loadedChunks = 0,
		chunkCount = 0,
		instanceTotal = 0,
		maxCapCount = 0,
		maxCapChars = 0,
		atCapCount = 0,
		atCapChars = 0,
		byKeyType = 0,
		byMusic = 0,
		camPos = 0,
		curPos = 0,
		snapshotActive = 0,
		pendingAdds = 0,
		pendingRemoves = 0,
		drawn = 0,
		avgLoadMs = 0,
		avgUnloadMs = 0,
		renderingEnabled = 0
	}
	local _desiredChunks = object._desiredChunks
	local count4 = 0

	for _ in pairs(_desiredChunks) do
		count4 += 1
	end

	v38.desiredChunks = count4
	local _loadedChunks = object._loadedChunks
	local count5 = 0

	for _ in pairs(_loadedChunks) do
		count5 += 1
	end

	v38.loadedChunks = count5
	v38.chunkCount = count3
	v38.instanceTotal = total
	v38.maxCapCount = #maxCapChars
	v38.maxCapChars = maxCapChars
	v38.atCapCount = #atCapChars
	v38.atCapChars = atCapChars
	v38.byKeyType = byKeyType
	v38.byMusic = byMusic
	v38.camPos = position
	v38.curPos = position2
	v38.snapshotActive = KeycapRenderDebugState.snapshotActive
	v38.pendingAdds = KeycapRenderDebugState.pendingAddCount
	v38.pendingRemoves = KeycapRenderDebugState.pendingRemoveCount
	v38.drawn = drawn
	v38.avgLoadMs = (object._avgLoadSec or 0) * 1000
	v38.avgUnloadMs = (object._avgUnloadSec or 0) * 1000
	v38.renderingEnabled = object:IsRenderingEnabled()
	return v38
end

local function formatStats(data)
	local v34 = not data.curPos and "nil" or string.format(
		"(%.0f, %.0f, %.0f)",
		data.curPos.X,
		data.curPos.Y,
		data.curPos.Z
	)
	local v35 = {
		string.format("Rendering %s", data.renderingEnabled and "ON" or "OFF"),
		string.format(
			"Records %d  |  loaded %d  unloaded %d  |  mapDots %d",
			data.total,
			data.loaded,
			data.unloaded,
			data.drawn or 0
		),
		string.format("Queues load %d  unload %d", data.loadQueue, data.unloadQueue),
		string.format("Avg load %.3f ms  unload %.3f ms", data.avgLoadMs, data.avgUnloadMs),
		string.format(
			"Chunks all %d  desired %d  loadedFlag %d",
			data.chunkCount,
			data.desiredChunks,
			data.loadedChunks
		),
		string.format(
			"Instances %d  |  MaxCap %d  |  AtCap %d  |  max/char %d",
			data.instanceTotal,
			data.maxCapCount,
			data.atCapCount,
			KeycapStreamConfig.MaxInstancesPerChar
		),
		string.format(
			"Snapshot %s  pending +%d -%d",
			data.snapshotActive and "YES" or "no",
			data.pendingAdds,
			data.pendingRemoves
		),
		string.format("Camera (%.0f, %.0f, %.0f)  chunk %s", data.camPos.X, data.camPos.Y, data.camPos.Z, v34),
		string.format("View (%.0f, %.0f)  zoom %.3f", X, Z, v29)
	}

	if data.maxCapCount > 0 then
		table.insert(v35, 7, "MaxCap " .. table.concat(data.maxCapChars, ", "))
	end

	if data.atCapCount > 0 then
		local v36 = "AtCap " .. table.concat(data.atCapChars, ", ")
		table.insert(v35, data.maxCapCount > 0 and 8 or 7, v36)
	end

	local v36 = {}

	for k, v37 in pairs(data.byKeyType) do
		table.insert(v36, k .. "=" .. v37)
	end

	table.sort(v36)
	table.insert(v35, "KeyTypes " .. table.concat(v36, " "))
	local v37 = {}

	for k, v38 in pairs(data.byMusic) do
		table.insert(v37, k .. "=" .. v38)
	end

	table.sort(v37)
	table.insert(v35, "Music " .. table.concat(v37, " "))
	return table.concat(v35, "\n")
end

local function formatInspect(data)
	if data then
		local _chunk = data._chunk
		local position = _chunk and _chunk:GetPosition()
		local v34 = data._activeInstance ~= nil
		local v35 = not v34 and "—" or data._activeInstance:GetFullName()
		return table.concat({
			string.format("Id %d  Char %q  loaded=%s", data.Id, data.Char, (tostring(v34))),
			string.format("Pos (%.2f, %.2f, %.2f)", data.Position.X, data.Position.Y, data.Position.Z),
			string.format("Size (%.2f, %.2f, %.2f)", data.Size.X, data.Size.Y, data.Size.Z),
			string.format("KeyType %s  MusicType %s", tostring(data.KeyType), (tostring(data.MusicType))),
			string.format(
				"Chunk %s",
				not position and "nil" or string.format("(%.0f, %.0f, %.0f)", position.X, position.Y, position.Z)
			),
			"Instance " .. v35
		}, "\n")
	elseif v22 == "disabled" then
		return "Map requires EditableImage (Experience Settings → Security). Stats still update."
	else
		return "Click a record on the map to inspect."
	end
end

local function findNearestRecord(renderer, p: number, p2: number, p3: number)
	local v34 = nil
	local v35 = p3 * p3
	local _desiredChunks = renderer._desiredChunks
	local v36 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function consider(data)
		if not v36[data.Id] then
			local desiredChunks = _desiredChunks
			local v38

			if v27 and id ~= data.Id then
				local X2 = data.Position.X
				local Z2 = data.Position.Z
				local v39 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
				local v40 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
				local neighborHalfExtent = getNeighborHalfExtent() -- equivalent call inferred; original call site unknown
				v38 = (math.abs(X2 - v39) <= neighborHalfExtent and math.abs(Z2 - v40) <= neighborHalfExtent or v23 == "Loaded" and data._activeInstance or (v23 == "Visibility" or v23 == "Vis+Queue") and data._chunk and desiredChunks[data._chunk]) and true or false
			else
				v38 = true
			end

			if v38 then
				v36[data.Id] = true
				local v39 = data.Position.X - p
				local v40 = data.Position.Z - p2
				local v41 = v39 * v39 + v40 * v40

				if v41 < v35 then
					v35 = v41
					v34 = data
				end
			end
		end
	end

	local function visit(object)
		for _, v37 in ipairs(object:GetObjects()) do
			consider(v37) -- equivalent call inferred; original call site unknown
		end
	end

	if v27 then
		foreachNeighborChunks(renderer, visit)
		foreachOverlayChunks(renderer, visit)
	else
		for _, v37 in pairs(renderer._byId) do
			if v36[v37.Id] then
				continue
			end

			local v38

			if v27 and id ~= v37.Id then
				local X2 = v37.Position.X
				local Z2 = v37.Position.Z
				local v39 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
				local v40 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
				local neighborHalfExtent = getNeighborHalfExtent() -- equivalent call inferred; original call site unknown
				v38 = (math.abs(X2 - v39) <= neighborHalfExtent and math.abs(Z2 - v40) <= neighborHalfExtent or v23 == "Loaded" and v37._activeInstance or (v23 == "Visibility" or v23 == "Vis+Queue") and v37._chunk and _desiredChunks[v37._chunk]) and true or false
			else
				v38 = true
			end

			if not v38 then
				continue
			end

			v36[v37.Id] = true
			local v39 = v37.Position.X - p
			local v40 = v37.Position.Z - p2
			local v41 = v39 * v39 + v40 * v40

			if not (v41 < v35) then
				continue
			end

			v35 = v41
			v34 = v37
		end
	end

	if not id then
		return v34
	end

	local v37 = renderer._byId[id]

	if not (v37 and not v36[v37.Id]) then
		return v34
	end

	local v38

	if v27 and id ~= v37.Id then
		local X2 = v37.Position.X
		local Z2 = v37.Position.Z
		local v39 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
		local v40 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
		local neighborHalfExtent = getNeighborHalfExtent() -- equivalent call inferred; original call site unknown
		v38 = (math.abs(X2 - v39) <= neighborHalfExtent and math.abs(Z2 - v40) <= neighborHalfExtent or v23 == "Loaded" and v37._activeInstance or (v23 == "Visibility" or v23 == "Vis+Queue") and v37._chunk and _desiredChunks[v37._chunk]) and true or false
	else
		v38 = true
	end

	if v38 then
		v36[v37.Id] = true
		local v39 = v37.Position.X - p
		local v40 = v37.Position.Z - p2
		local v41 = v39 * v39 + v40 * v40

		if v41 < v35 then
			v35 = v41
			v34 = v37
		end
	end

	return v34
end

local function updateCameraMarker(renderer)
	if frame and v26 then
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			frame.Visible = false
			return
		end

		local position = currentCamera.CFrame.Position
		local X2 = position.X
		local Z2 = position.Z
		local absoluteSize

		if ctn then
			absoluteSize = ctn.AbsoluteSize

			if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
				absoluteSize = Vector2.new(400, 400)
			end
		else
			absoluteSize = Vector2.new(400, 400)
		end

		local v34 = (X2 - X) * v29 + absoluteSize.X * 0.5
		local v35 = (Z2 - Z) * v29 + absoluteSize.Y * 0.5
		frame.Visible = true
		frame.Position = UDim2.fromOffset(v34, v35)

		if renderer._currentChunk then
			frame.BackgroundColor3 = Color3.fromRGB(255, 255, 80)
		else
			frame.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
		end
	elseif frame then
		frame.Visible = false
	end
end

local function updateRadiusGizmo()
	if not (frame2 and ctn) then
		return
	end

	if not v27 then
		frame2.Visible = false
		return
	end

	local v34 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
	local v35 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
	local neighborHalfExtent = getNeighborHalfExtent() -- equivalent call inferred; original call site unknown
	local v36 = v34 - neighborHalfExtent
	local v37 = v35 - neighborHalfExtent
	local absoluteSize

	if ctn then
		absoluteSize = ctn.AbsoluteSize

		if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
			absoluteSize = Vector2.new(400, 400)
		end
	else
		absoluteSize = Vector2.new(400, 400)
	end

	local v38 = (v36 - X) * v29 + absoluteSize.X * 0.5
	local v39 = (v37 - Z) * v29 + absoluteSize.Y * 0.5
	local v40 = v34 + neighborHalfExtent
	local v41 = v35 + neighborHalfExtent
	local absoluteSize2

	if ctn then
		absoluteSize2 = ctn.AbsoluteSize

		if not (absoluteSize2.X > 0 and absoluteSize2.Y > 0) then
			absoluteSize2 = Vector2.new(400, 400)
		end
	else
		absoluteSize2 = Vector2.new(400, 400)
	end

	local v42 = (v40 - X) * v29 + absoluteSize2.X * 0.5
	local v43 = (v41 - Z) * v29 + absoluteSize2.Y * 0.5
	local v44 = math.max(math.abs(v42 - v38), 4)
	local v45 = math.max(math.abs(v43 - v39), 4)
	frame2.Size = UDim2.fromOffset(v44, v45)
	frame2.Position = UDim2.fromOffset((v38 + v42) * 0.5, (v39 + v43) * 0.5)
	frame2.Visible = true
end

local function drawMap(data)
	local v34

	if v22 == "disabled" then
		v34 = false
	elseif v22 == "editable" then
		if ctn == nil then
			v34 = false
		else
			v34 = v21 ~= nil
		end
	elseif ctn then
		if ensureEditableImage() then
			v22 = "editable"
			v34 = true
		else
			if v22 ~= "disabled" then
				abandonEditableImage()
				v22 = "disabled"
				showMapDisabledMessage()
				warn("[KeycapRenderDebug] EditableImage unavailable — map disabled. Enable it in Experience Settings → Security.")
			end

			v34 = false
		end
	else
		v34 = false
	end

	if not v34 then
		return
	end

	clearPixels()

	if v22 ~= "editable" then
		return
	end

	local queueSets, v35 = buildQueueSets(data)
	local _desiredChunks = data._desiredChunks
	local v36 = {}
	local count = 0
	local v37 = chunkSize * 0.5

	if v25 then
		local color2 = Color3.fromRGB(60, 60, 80)
		local color3 = Color3.fromRGB(50, 90, 120)
		foreachChunk(data._grid and data._grid.Grid, KeycapStreamConfig.ChunkDimensions, function(object)
			local position = object:GetPosition()
			local v38 = position.X - v37
			local v39 = position.Z - v37
			local absoluteSize

			if ctn then
				absoluteSize = ctn.AbsoluteSize

				if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
					absoluteSize = Vector2.new(400, 400)
				end
			else
				absoluteSize = Vector2.new(400, 400)
			end

			local v40 = (v38 - X) * v29 + absoluteSize.X * 0.5
			local v41 = (v39 - Z) * v29 + absoluteSize.Y * 0.5
			local absoluteSize2

			if ctn then
				absoluteSize2 = ctn.AbsoluteSize

				if not (absoluteSize2.X > 0 and absoluteSize2.Y > 0) then
					absoluteSize2 = Vector2.new(400, 400)
				end
			else
				absoluteSize2 = Vector2.new(400, 400)
			end

			local v42 = v40 / absoluteSize2.X * 512
			local v43 = v41 / absoluteSize2.Y * 512
			local v44 = position.X + v37
			local v45 = position.Z + v37
			local absoluteSize3

			if ctn then
				absoluteSize3 = ctn.AbsoluteSize

				if not (absoluteSize3.X > 0 and absoluteSize3.Y > 0) then
					absoluteSize3 = Vector2.new(400, 400)
				end
			else
				absoluteSize3 = Vector2.new(400, 400)
			end

			local v46 = (v44 - X) * v29 + absoluteSize3.X * 0.5
			local v47 = (v45 - Z) * v29 + absoluteSize3.Y * 0.5
			local absoluteSize4

			if ctn then
				absoluteSize4 = ctn.AbsoluteSize

				if not (absoluteSize4.X > 0 and absoluteSize4.Y > 0) then
					absoluteSize4 = Vector2.new(400, 400)
				end
			else
				absoluteSize4 = Vector2.new(400, 400)
			end

			local v48 = v46 / absoluteSize4.X * 512
			local v49 = v47 / absoluteSize4.Y * 512

			if v48 < 0 or v49 < 0 or v42 >= 512 or v43 >= 512 then
				return
			end

			local v51

			if _desiredChunks[object] then
				v51 = color3
			else
				v51 = color2
			end

			drawRectOutline(v42, v43, v48, v49, v51)
		end)

		if data._currentChunk then
			local position = data._currentChunk:GetPosition()
			local v38 = position.X - v37
			local v39 = position.Z - v37
			local absoluteSize

			if ctn then
				absoluteSize = ctn.AbsoluteSize

				if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
					absoluteSize = Vector2.new(400, 400)
				end
			else
				absoluteSize = Vector2.new(400, 400)
			end

			local v40 = (v38 - X) * v29 + absoluteSize.X * 0.5
			local v41 = (v39 - Z) * v29 + absoluteSize.Y * 0.5
			local absoluteSize2

			if ctn then
				absoluteSize2 = ctn.AbsoluteSize

				if not (absoluteSize2.X > 0 and absoluteSize2.Y > 0) then
					absoluteSize2 = Vector2.new(400, 400)
				end
			else
				absoluteSize2 = Vector2.new(400, 400)
			end

			local v42 = v40 / absoluteSize2.X * 512
			local v43 = v41 / absoluteSize2.Y * 512
			local v44 = position.X + v37
			local v45 = position.Z + v37
			local absoluteSize3

			if ctn then
				absoluteSize3 = ctn.AbsoluteSize

				if not (absoluteSize3.X > 0 and absoluteSize3.Y > 0) then
					absoluteSize3 = Vector2.new(400, 400)
				end
			else
				absoluteSize3 = Vector2.new(400, 400)
			end

			local v46 = (v44 - X) * v29 + absoluteSize3.X * 0.5
			local v47 = (v45 - Z) * v29 + absoluteSize3.Y * 0.5
			local absoluteSize4

			if ctn then
				absoluteSize4 = ctn.AbsoluteSize

				if not (absoluteSize4.X > 0 and absoluteSize4.Y > 0) then
					absoluteSize4 = Vector2.new(400, 400)
				end
			else
				absoluteSize4 = Vector2.new(400, 400)
			end

			drawRectOutline(
				v42,
				v43,
				v46 / absoluteSize4.X * 512,
				v47 / absoluteSize4.Y * 512,
				Color3.fromRGB(255, 220, 60)
			)
		end
	end

	local function drawRecord(data2)
		if not v36[data2.Id] then
			local desiredChunks = _desiredChunks
			local v39

			if v27 and id ~= data2.Id then
				local X2 = data2.Position.X
				local Z2 = data2.Position.Z
				local v40 = roundChunkAxis(X) -- equivalent call inferred; original call site unknown
				local v41 = roundChunkAxis(Z) -- equivalent call inferred; original call site unknown
				local neighborHalfExtent = getNeighborHalfExtent() -- equivalent call inferred; original call site unknown
				v39 = (math.abs(X2 - v40) <= neighborHalfExtent and math.abs(Z2 - v41) <= neighborHalfExtent or v23 == "Loaded" and data2._activeInstance or (v23 == "Visibility" or v23 == "Vis+Queue") and data2._chunk and desiredChunks[data2._chunk]) and true or false
			else
				v39 = true
			end

			if v39 then
				v36[data2.Id] = true
				count += 1
				local X2 = data2.Position.X
				local Z2 = data2.Position.Z
				local absoluteSize

				if ctn then
					absoluteSize = ctn.AbsoluteSize

					if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
						absoluteSize = Vector2.new(400, 400)
					end
				else
					absoluteSize = Vector2.new(400, 400)
				end

				local v40 = (X2 - X) * v29 + absoluteSize.X * 0.5
				local v41 = (Z2 - Z) * v29 + absoluteSize.Y * 0.5
				local absoluteSize2

				if ctn then
					absoluteSize2 = ctn.AbsoluteSize

					if not (absoluteSize2.X > 0 and absoluteSize2.Y > 0) then
						absoluteSize2 = Vector2.new(400, 400)
					end
				else
					absoluteSize2 = Vector2.new(400, 400)
				end

				local v42 = v40 / absoluteSize2.X * 512
				local v43 = v41 / absoluteSize2.Y * 512
				local v44 = recordColor(data2, v23, queueSets, v35, _desiredChunks)

				if id == data2.Id then
					setPixel(v42 - 1, v43 - 1, Color3.new(1, 1, 1))
				end

				setPixel(v42, v43, v44)
			end
		end
	end

	local function visit(object)
		for _, v38 in ipairs(object:GetObjects()) do
			drawRecord(v38)
		end
	end

	if v27 then
		foreachNeighborChunks(data, visit)
		foreachOverlayChunks(data, visit)
	else
		for _, v38 in pairs(data._byId) do
			drawRecord(v38)
		end
	end

	local v38 = id and data._byId[id]

	if v38 then
		drawRecord(v38)
	end

	drawn = count

	if v12 then
		if v27 then
			v12:SetText(string.format(
				"%s  |  drawn %d  |  nbr ±%.0f (×%.1f chunk)",
				v3[v23] or "",
				count,
				chunkSize * v24,
				v24
			))
		else
			v12:SetText(string.format("%s  |  drawn %d  |  cull off (all records)", v3[v23] or "", count))
		end
	end

	if not flag2 and v21 and buf then
		local success, result = pcall(function()
			v21:WritePixelsBuffer(Vector2.zero, Vector2.new(512, 512), buf)
		end)

		if not success then
			disableMap(tostring(result)) -- equivalent call inferred; original call site unknown
		end
	end
end

local function countTextLines(value: string)
	local v34 = 1

	for _ in string.gmatch(value, "\n") do
		v34 += 1
	end

	return v34
end

local function setInfoText(object, object2, value: string, p: number)
	object:SetText(value)
	local v34 = 1

	for _ in string.gmatch(value, "\n") do
		v34 += 1
	end

	object:SetYSize(p * v34 + 8)
	object2:UpdateHeight()
end

local function updateStats(renderer)
	local success, result = pcall(function()
		return formatStats(gatherStats(renderer))
	end)

	if success then
		local v34 = v9
		local v35 = v5
		v34:SetText(result)
		local v36 = 1

		for _ in string.gmatch(result, "\n") do
			v36 += 1
		end

		v34:SetYSize(v36 * 13 + 8)
		v35:UpdateHeight()
	else
		local v34 = v9
		local v35 = v5
		local v36 = string.format("Stats error: %s", (tostring(result)))
		v34:SetText(v36)
		local v37 = 1

		for _ in string.gmatch(v36, "\n") do
			v37 += 1
		end

		v34:SetYSize(v37 * 13 + 8)
		v35:UpdateHeight()
	end

	local v34

	if id then
		v34 = renderer._byId[id]
	else
		v34 = nil
	end

	local success2, result2 = pcall(function()
		return formatInspect(v34)
	end)

	if success2 then
		local v35 = v10
		local v36 = v6
		v35:SetText(result2)
		local v37 = 1

		for _ in string.gmatch(result2, "\n") do
			v37 += 1
		end

		v35:SetYSize(v37 * 13 + 8)
		v36:UpdateHeight()
	else
		local v35 = v10
		local v36 = v6
		local v37 = string.format("Inspect error: %s", (tostring(result2)))
		v35:SetText(v37)
		local v38 = 1

		for _ in string.gmatch(v37, "\n") do
			v38 += 1
		end

		v35:SetYSize(v38 * 13 + 8)
		v36:UpdateHeight()
	end
end

local function anyDebugVisible()
	local v34 = v4 ~= nil and v4:IsVisible() or v5 ~= nil and v5:IsVisible() or v6 ~= nil and v6:IsVisible()

	if not v34 then
		if v7 == nil then
			return false
		else
			return (v7:IsVisible())
		end
	end

	return v34
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tickFollowCamera()
	if not v28 then
		return false
	end

	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	local position = currentCamera.CFrame.Position
	local v34 = position.X - X
	local v35 = position.Z - Z

	if v34 * v34 + v35 * v35 < 0.25 then
		return false
	end

	X = position.X
	Z = position.Z
	return true
end

local function redraw(flag4: boolean?)
	local v34 = v4 ~= nil and v4:IsVisible() or v5 ~= nil and v5:IsVisible() or v6 ~= nil and v6:IsVisible()

	if not v34 then
		if v7 == nil then
			v34 = false
		else
			v34 = v7:IsVisible()
		end
	end

	if not v34 then
		return
	end

	local renderer = KeycapRenderDebugState.renderer
	local now = os.clock()

	if flag4 or v22 ~= "editable" or now - v32 >= 0.5 then
		v32 = now

		if renderer then
			updateStats(renderer)
		else
			local v35 = v9
			local v36 = v5
			v35:SetText("Waiting for renderer…")
			local v37 = 1

			for _ in string.gmatch("Waiting for renderer…", "\n") do
				v37 += 1
			end

			v35:SetYSize(v37 * 13 + 8)
			v36:UpdateHeight()
		end
	end

	if v22 ~= "editable" or not (renderer and v4 and v4:IsVisible()) then
		return
	end

	-- equivalent call inferred; original call site unknown
	if tickFollowCamera() then
		v30 = true
	end

	local v35 = (flag3 or v30) and 0.05 or 0.2

	if flag4 or v35 <= now - v31 then
		v31 = now
		v30 = false
		pcall(drawMap, renderer)
		pcall(updateRadiusGizmo)
	end

	pcall(updateCameraMarker, renderer)
end

local function requestMapRedraw()
	v30 = true
end

local function onMapInputBegan(p)
	if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
		flag3 = true
		vector2 = Vector2.new(p.Position.X, p.Position.Y)
		v28 = false

		if v18 then
			v18:SetValue(false)
		end

		local renderer = KeycapRenderDebugState.renderer

		if renderer and ctn then
			local v34 = getMouseGuiPos() - ctn.AbsolutePosition
			local absoluteSize

			if ctn then
				absoluteSize = ctn.AbsoluteSize

				if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
					absoluteSize = Vector2.new(400, 400)
				end
			else
				absoluteSize = Vector2.new(400, 400)
			end

			local nearestRecord = findNearestRecord(
				renderer,
				(v34.X - absoluteSize.X * 0.5) / v29 + X,
				(v34.Y - absoluteSize.Y * 0.5) / v29 + Z,
				math.max(4 / v29, 2)
			)
			id = nearestRecord and nearestRecord.Id or nil
			v30 = true
			redraw(true)
		end
	end
end

local function onMapInputChanged(input)
	if not (flag3 and vector2) or input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local vector3 = Vector2.new(input.Position.X, input.Position.Y)
	local v34 = vector3 - vector2
	vector2 = vector3
	X -= v34.X / v29
	Z -= v34.Y / v29
	v30 = true
	local renderer = KeycapRenderDebugState.renderer

	if renderer then
		updateCameraMarker(renderer)
	end
end

local function onMapInputEnded(p)
	if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
		flag3 = false
		vector2 = nil
	end
end

local function onMouseWheel(input)
	if not (v4 and v4:IsVisible() and ctn) then
		return
	end

	local absolutePosition = ctn.AbsolutePosition
	local absoluteSize = ctn.AbsoluteSize
	local mouseGuiPos = getMouseGuiPos() -- equivalent call inferred; original call site unknown

	if mouseGuiPos.X < absolutePosition.X or mouseGuiPos.Y < absolutePosition.Y or mouseGuiPos.X > absolutePosition.X + absoluteSize.X or mouseGuiPos.Y > absolutePosition.Y + absoluteSize.Y then
		return
	end

	local v34 = mouseGuiPos - absolutePosition
	local absoluteSize2

	if ctn then
		absoluteSize2 = ctn.AbsoluteSize

		if not (absoluteSize2.X > 0 and absoluteSize2.Y > 0) then
			absoluteSize2 = Vector2.new(400, 400)
		end
	else
		absoluteSize2 = Vector2.new(400, 400)
	end

	local v35 = (v34.X - absoluteSize2.X * 0.5) / v29 + X
	local v36 = (v34.Y - absoluteSize2.Y * 0.5) / v29 + Z
	local v37 = input.Position.Z > 0 and 1.15 or 0.8695652173913044
	v29 = math.clamp(v29 * v37, 0.002, 8)
	local absoluteSize3

	if ctn then
		absoluteSize3 = ctn.AbsoluteSize

		if not (absoluteSize3.X > 0 and absoluteSize3.Y > 0) then
			absoluteSize3 = Vector2.new(400, 400)
		end
	else
		absoluteSize3 = Vector2.new(400, 400)
	end

	local v38 = (v35 - X) * v29 + absoluteSize3.X * 0.5
	local v39 = (v36 - Z) * v29 + absoluteSize3.Y * 0.5
	X += (v38 - v34.X) / v29
	Z += (v39 - v34.Y) / v29
	v28 = false

	if v18 then
		v18:SetValue(false)
	end

	v30 = true
end

local function bindMapInput()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)

	if not ctn then
		return
	end

	table.insert(connections, ctn.InputBegan:Connect(onMapInputBegan))
	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if flag3 then
			onMapInputChanged(input)
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(onMapInputEnded))
	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			onMouseWheel(input)
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureRefreshLoop()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v34 = v4 ~= nil and v4:IsVisible() or v5 ~= nil and v5:IsVisible() or v6 ~= nil and v6:IsVisible()

		if not v34 then
			if v7 == nil then
				v34 = false
			else
				v34 = v7:IsVisible()
			end
		end

		if v34 then
			redraw(false)
		end
	end)
end

local function buildInfoWindows()
	v5 = CUI.GetWindow("KeycapRenderDebug.Stats", 360, function(object)
		object:SetTitle("Keycap Stats")
	end)
	v5.Components:AddText(function(object)
		v9 = object
		object:SetTextSize(13)
		object:SetTextYAlignment(Enum.TextYAlignment.Top)
		local v34 = v5
		object:SetText("Waiting for renderer…")
		local v35 = 1

		for _ in string.gmatch("Waiting for renderer…", "\n") do
			v35 += 1
		end

		object:SetYSize(v35 * 13 + 8)
		v34:UpdateHeight()
	end)
	v6 = CUI.GetWindow("KeycapRenderDebug.Inspect", 360, function(object)
		object:SetTitle("Keycap Inspect")
	end)
	v6.Components:AddText(function(object)
		v10 = object
		object:SetTextSize(13)
		object:SetTextYAlignment(Enum.TextYAlignment.Top)
		local v34 = v6
		object:SetText("Click a record on the map to inspect.")
		local v35 = 1

		for _ in string.gmatch("Click a record on the map to inspect.", "\n") do
			v35 += 1
		end

		object:SetYSize(v35 * 13 + 8)
		v34:UpdateHeight()
	end)
	v7 = CUI.GetWindow("KeycapRenderDebug.Help", 420, function(object)
		object:SetTitle("Keycap Debug Help")
	end)
	v7.Components:AddText(function(object)
		v11 = object
		object:SetTextSize(12)
		object:SetTextYAlignment(Enum.TextYAlignment.Top)
		local v34 = v7
		local v35 = joined
		object:SetText(v35)
		local v36 = 1

		for _ in string.gmatch(v35, "\n") do
			v36 += 1
		end

		object:SetYSize(v36 * 12 + 8)
		v34:UpdateHeight()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildCoreControls(components)
	components:AddCheckbox(function(object)
		v19 = object
		object:SetText("Render keycaps")
		local renderer = KeycapRenderDebugState.renderer
		object:SetValue(not renderer or renderer:IsRenderingEnabled())
		object:SetOnChanged(function(p)
			KeycapRenderDebug.SetRenderingEnabled(p)
		end)
	end)
end

local function buildMapControls(object)
	object:AddText(function(object2)
		v12 = object2
		object2:SetTextSize(12)
		object2:SetYSize(18)
		object2:SetText(v3[v23])
	end)
	object:AddDropdown(function(object2)
		v13 = object2
		object2:SetText("Color")
		object2:SetChoiceList(v2)
		object2:SetSelected("Loaded")
		object2:SetOnChanged(function(p)
			v23 = p
			redraw(true)
		end)
	end)
	object:AddDropdown(function(object2)
		v14 = object2
		object2:SetText("Extent ×chunk")
		object2:SetChoiceList(v)
		object2:SetSelected("1.5")
		object2:SetOnChanged(function(p)
			local v34 = tonumber(p)

			if v34 then
				v24 = v34
				redraw(true)
			end
		end)
	end)
	object:AddCheckbox(function(object2)
		v15 = object2
		object2:SetText("Chunk grid")
		object2:SetValue(true)
		object2:SetOnChanged(function(p)
			v25 = p
			redraw(true)
		end)
	end)
	object:AddCheckbox(function(object2)
		v17 = object2
		object2:SetText("Radius view")
		object2:SetValue(true)
		object2:SetOnChanged(function(p)
			v27 = p
			redraw(true)
		end)
	end)
	object:AddCheckbox(function(object2)
		v16 = object2
		object2:SetText("Camera marker")
		object2:SetValue(true)
		object2:SetOnChanged(function(p)
			v26 = p
			local renderer = KeycapRenderDebugState.renderer

			if renderer then
				updateCameraMarker(renderer)
			end
		end)
	end)
	object:AddCheckbox(function(object2)
		v18 = object2
		object2:SetText("Follow camera")
		object2:SetValue(true)
		object2:SetOnChanged(function(p)
			v28 = p
			v30 = true
		end)
	end)
	object:AddButton(function(object2)
		object2:SetButtonText("Fit all records")
		object2:SetButtonCallback(function()
			local renderer = KeycapRenderDebugState.renderer

			if not renderer then
				return
			end

			local v34 = 1e999
			local v35 = -1e999
			local v36 = 1e999
			local v37 = -1e999
			local v38 = false

			for _, v39 in pairs(renderer._byId) do
				v34 = math.min(v34, v39.Position.X)
				v35 = math.max(v35, v39.Position.X)
				v36 = math.min(v36, v39.Position.Z)
				v37 = math.max(v37, v39.Position.Z)
				v38 = true
			end

			if not v38 then
				return
			end

			X = (v34 + v35) / 2
			Z = (v36 + v37) / 2
			local v39 = math.max(v35 - v34, v37 - v36, 1)
			local absoluteSize

			if ctn then
				absoluteSize = ctn.AbsoluteSize

				if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
					absoluteSize = Vector2.new(400, 400)
				end
			else
				absoluteSize = Vector2.new(400, 400)
			end

			v29 = absoluteSize.X * 0.9 / v39
			v28 = false

			if v18 then
				v18:SetValue(false)
			end

			redraw(true)
		end)
	end)
end

local function buildMapSection(components)
	components:AddTitle(function(object)
		object:SetTitle("Map (Y squashed · drag pan · wheel zoom)")
	end)
	components:AddImage(function(object)
		object:SetHeight(400)
		local v34 = object.UI.Ctn:FindFirstChildOfClass("UIAspectRatioConstraint")

		if not v34 then
			v34 = Instance.new("UIAspectRatioConstraint")
			v34.Parent = object.UI.Ctn
		end

		v34.AspectRatio = 1
		ctn = object.UI.Ctn
		ctn.Active = true
		ctn.ClipsDescendants = true
		ctn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		ctn.BackgroundTransparency = 0
		ctn.Size = UDim2.fromOffset(400, 400)
		ctn.AnchorPoint = Vector2.new(0.5, 0.5)
		ctn.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel = ctn:FindFirstChildWhichIsA("ImageLabel")

		if imageLabel then
			imageLabel.ScaleType = Enum.ScaleType.Stretch
			imageLabel.BackgroundTransparency = 1
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Active = false
		end

		frame = Instance.new("Frame")
		frame.Name = "CameraMarker"
		frame.Size = UDim2.fromOffset(10, 10)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
		frame.BorderSizePixel = 0
		frame.ZIndex = (imageLabel and imageLabel.ZIndex or ctn.ZIndex or 1) + 5
		frame.Parent = ctn
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = 1
		uIStroke.Color = Color3.new(0, 0, 0)
		uIStroke.Parent = frame
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = frame
		frame2 = Instance.new("Frame")
		frame2.Name = "DisplayRadius"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
		frame2.BackgroundTransparency = 0.92
		frame2.BorderSizePixel = 0
		frame2.ZIndex = (imageLabel and imageLabel.ZIndex or ctn.ZIndex or 1) + 3
		frame2.Active = false
		frame2.Parent = ctn
		local uIStroke2 = Instance.new("UIStroke")
		uIStroke2.Thickness = 1.5
		uIStroke2.Color = Color3.fromRGB(80, 200, 255)
		uIStroke2.Transparency = 0.25
		uIStroke2.Parent = frame2
	end)
	local v34

	if v22 == "disabled" then
		v34 = false
	elseif v22 == "editable" then
		if ctn == nil then
			v34 = false
		else
			v34 = v21 ~= nil
		end
	elseif ctn then
		if ensureEditableImage() then
			v22 = "editable"
			v34 = true
		else
			if v22 ~= "disabled" then
				abandonEditableImage()
				v22 = "disabled"
				showMapDisabledMessage()
				warn("[KeycapRenderDebug] EditableImage unavailable — map disabled. Enable it in Experience Settings → Security.")
			end

			v34 = false
		end
	else
		v34 = false
	end

	if not v34 then
		return false
	end

	buildMapControls(components)
	bindMapInput()
	return true
end

local function buildMapUnavailableSection(object)
	v22 = "disabled"
	object:AddTitle(function(object2)
		object2:SetTitle("Map unavailable")
	end)
	object:AddText(function(object2)
		object2:SetTextSize(14)
		object2:SetYSize(56)
		object2:SetText([[
Please enable EditableImage
(Experience Settings → Security)
Stats / Inspect / Help still work.]])
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyMapUnavailable(components, p: string?)
	if ctn then
		disableMap(p) -- equivalent call inferred; original call site unknown
	else
		pcall(buildMapUnavailableSection, components)
		v22 = "disabled"
		warn("[KeycapRenderDebug] EditableImage unavailable — map disabled. Stats / Inspect / Help still work.")
	end

	local v34 = v10
	local v35 = v6
	v34:SetText("Map requires EditableImage (Experience Settings → Security). Stats still update.")
	local v36 = 1

	for _ in string.gmatch("Map requires EditableImage (Experience Settings → Security). Stats still update.", "\n") do
		v36 += 1
	end

	v34:SetYSize(v36 * 13 + 8)
	v35:UpdateHeight()
end

local function mountCoreWindows()
	if flag then
		return
	end

	v4 = CUI.GetWindow("KeycapRenderDebug", 440, function(object)
		object:SetTitle("Keycap Render Debug")
	end)
	buildCoreControls(v4.Components) -- equivalent call inferred; original call site unknown
	buildInfoWindows()
	local position = v4:GetPosition()
	v5:SetPosition(position.X + 440 + 16, position.Y)
	v6:SetPosition(position.X + 440 + 16, position.Y + 220)
	v7:SetPosition(position.X - 420 - 16, position.Y)
	ensureRefreshLoop() -- equivalent call inferred; original call site unknown
	flag = true
end

local function mountMapOrFallback()
	if v8 or not v4 then
		return
	end

	v8 = true
	local components = v4.Components
	local success, result = pcall(function()
		return (buildMapSection(components))
	end)

	if success and result then
		return
	end

	if success == false then
		warn("[KeycapRenderDebug] Map UI failed:", result)
	end

	local v34

	if not success then
		v34 = tostring(result)
	end

	applyMapUnavailable(components, v34) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAllVisible(flag4: boolean)
	if v4 then
		v4:SetVisible(flag4)

		if flag4 then
			v4:SetMinimize(false)
		end
	end

	if v5 then
		v5:SetVisible(flag4)

		if flag4 then
			v5:SetMinimize(false)
		end
	end

	if v6 then
		v6:SetVisible(flag4)

		if flag4 then
			v6:SetMinimize(false)
		end
	end

	if v7 then
		v7:SetVisible(flag4)

		if flag4 then
			v7:SetMinimize(false)
		end
	end
end

function KeycapRenderDebug.Show()
	mountCoreWindows()
	setAllVisible(true)
	redraw(true)
	mountMapOrFallback()
	redraw(true)
end

function KeycapRenderDebug.Hide()
	setAllVisible(false) -- equivalent call inferred; original call site unknown
end

function KeycapRenderDebug.Toggle()
	mountCoreWindows()

	if v4 and v4:IsVisible() then
		KeycapRenderDebug.Hide()
	else
		KeycapRenderDebug.Show()
	end
end

function KeycapRenderDebug.IsVisible()
	return v4 ~= nil and v4:IsVisible()
end

function KeycapRenderDebug.SetRenderingEnabled(flag4: boolean?)
	local renderer = KeycapRenderDebugState.renderer

	if not renderer then
		warn("[KeycapRenderDebug] Renderer not ready — cannot change rendering")
		return false
	end

	if flag4 == nil then
		flag4 = not renderer:IsRenderingEnabled()
	end

	renderer:SetRenderingEnabled(flag4)

	if v19 then
		v19:SetValue(flag4)
	end

	return flag4
end

function KeycapRenderDebug.IsRenderingEnabled()
	local renderer = KeycapRenderDebugState.renderer
	return not renderer or renderer:IsRenderingEnabled()
end

return KeycapRenderDebug