local Graffiti = {}
local CollectionService = game:GetService("CollectionService")
game:GetService("ServerStorage")
game:GetService("TweenService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local Server = require(game.ReplicatedStorage.Modules.Server)
require(game.ReplicatedStorage.Modules.Stats)
local localPlayer = game.Players.LocalPlayer
local folder = Instance.new("Folder", workspace)
folder.Name = "Graffiti"
local v = {}
Graffiti.Modes = {
	Draw = 1,
	Erase = 2,
	Eyedropper = 3,
	Line = 4
}
Graffiti.PIXEL_CollisionGroupName = "SprayPaint_Graffiti_Pixel"
Graffiti.MaxLayer = 8
Graffiti.MaxRange = 100
Graffiti.Limit = 21000
Graffiti.Count = 0
Graffiti.History = {}
Graffiti.MaxHistorySize = 400
Graffiti.HistoryLineData = {}
Graffiti.HistoryCursor = nil
Graffiti.ShouldCreateNewHistoryCursor = true
Graffiti.IsPacketEmpty = false
Graffiti.LastHistoryTime = os.clock()
Graffiti.CurrentSize = 0.2
Graffiti.CurrentLayer = 1
Graffiti.CurrentColor = Color3.fromRGB(255, 0, 0)
Graffiti.DrawPacket = {}
Graffiti.DeletePacket = {}
Graffiti.IsMouseDown = false
Graffiti.CurrentMode = Graffiti.Modes.Draw
Graffiti.Params = RaycastParams.new()
Graffiti.Params.FilterType = Enum.RaycastFilterType.Include
Graffiti.Directory = folder
Graffiti.ShouldCount = Server:GetServerType() ~= Server.Servers.Neighborhood

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshPaintableSurfaces()
	local tagged = CollectionService:GetTagged("GraffitiInclude")

	if Server:GetServerType() == Server.Servers.Neighborhood then
		table.insert(tagged, workspace.Places)
	end

	Graffiti.Params.FilterDescendantsInstances = tagged
end

refreshPaintableSurfaces() -- equivalent call inferred; original call site unknown
CollectionService:GetInstanceAddedSignal("GraffitiInclude"):Connect(refreshPaintableSurfaces)
CollectionService:GetInstanceRemovedSignal("GraffitiInclude"):Connect(refreshPaintableSurfaces)
Graffiti.OverlapParams = OverlapParams.new()
Graffiti.OverlapParams.FilterType = Enum.RaycastFilterType.Include
Graffiti.OverlapParams.FilterDescendantsInstances = { folder }
Graffiti.OverlapParams.CollisionGroup = Graffiti.PIXEL_CollisionGroupName
Graffiti.OverlapParams.RespectCanCollide = false

function Graffiti:UpdateLineBasedOnLayer(p2, p3)
	if p3 == self.CurrentLayer then
		p2.Transparency = 0
	else
		p2.Transparency = 0.7
	end
end

function Graffiti:UpdateLayerTransparency()
	local sprayPaint

	if self.CurrentMode == self.Modes.Erase then
		sprayPaint = localPlayer.Character and localPlayer.Character:FindFirstChild("Spray Paint")
	else
		sprayPaint = false
	end

	local currentLayer = self.CurrentLayer

	for _, child in folder:GetChildren() do
		if child.Name ~= localPlayer.Name then
			continue
		end

		local v2

		if sprayPaint then
			v2 = child:GetAttribute("Layer") or currentLayer
		else
			v2 = currentLayer
		end

		self:UpdateLineBasedOnLayer(child, v2)

		for _, child2 in child:GetChildren() do
			child2.Transparency = child.Transparency * 2
		end
	end
end

function Graffiti:EncodeColor3(color: Color3)
	return color:ToHex()
end

function Graffiti:DecodeColor3(p: string)
	return Color3.fromHex(p)
end

function Graffiti.Color3ToNumber(_, color: Color3)
	return math.round(color.R * 255) * 1000000 + 1000000000 + math.round(color.G * 255) * 1000 + math.round(color.B * 255)
end

function Graffiti.NumberToColor3(_, p)
	local v2 = tostring(p):sub(2)
	return Color3.fromRGB(tonumber(v2:sub(1, 3)), tonumber(v2:sub(4, 6)), (tonumber(v2:sub(7, 9))))
end

function Graffiti:ShouldDraw(p)
	return Server:GetServerType() == Server.Servers.Neighborhood or p == game.Players.LocalPlayer or true
end

function Graffiti.ConstructCFrame(_, p, p2)
	return CFrame.new(p, p + p2) * CFrame.Angles(0, 1.5707963267948966, 0)
end

function Graffiti:GetCorrectCFrame(p)
	return p
end

function Graffiti:DrawPixel(p, p2, p3, color, p4, parent)
	local correctCFrame = self:GetCorrectCFrame(p2)
	local vector = Vector3.new(0.006, p3, p3)

	if not correctCFrame then
		return
	end

	local clone = script.Pixel:Clone()
	clone.Name = p.Name
	clone.Color = color
	clone.Size = vector
	clone.CollisionGroup = Graffiti.PIXEL_CollisionGroupName
	clone.CFrame = correctCFrame * CFrame.new(0.006 * (p4 - 1), 0, 0)
	clone.Parent = parent
	return clone
end

function Graffiti:DrawLineBetween(p, cframe: CFrame, cframe2: CFrame, p2: number, color: Color3, p3: number)
	local clone = script.Line:Clone()
	clone.Name = p.Name
	clone.Color = color
	clone.Size = Vector3.new(0.006, p2, (cframe2.Position - cframe.Position).magnitude)
	clone.CollisionGroup = Graffiti.PIXEL_CollisionGroupName
	clone.CFrame = CFrame.lookAt(cframe.Position, cframe2.Position, cframe.UpVector) * CFrame.new(
		0,
		0,
		-clone.Size.Z / 2
	) + cframe.RightVector * (p3 - 1) * 0.006
	clone.Parent = folder
	return clone
end

function Graffiti.GetNumberOfPixels(_, p, p2, p3)
	return (math.max(1, (p.Position - p2.Position).magnitude / (p3 * 0.5)))
end

function Graffiti:LocalErase(p, p2, ids)
	local partBoundsInBox = workspace:GetPartBoundsInBox(p, Vector3.new(0.5, p2 * 2.5, p2 * 2.5), self.OverlapParams)

	for _, v2 in partBoundsInBox do
		if not (v2.Name == localPlayer.Name and v2.Parent == folder and v2:GetAttribute("Id") and v2:GetAttribute("Layer") == self.CurrentLayer) then
			continue
		end

		self.Count -= v2:GetAttribute("Cost") or 0
		table.insert(ids, v2:GetAttribute("Id"))
		Graffiti.HistoryLineData[tostring(v2:GetAttribute("Id"))] = {
			Header = `{v2.Size.Y}/{Graffiti:EncodeColor3(v2.Color)}/{v2:GetAttribute("Layer")}`,
			Data = {
				v2.CFrame * CFrame.new(0, 0, v2.Size.Z / 2),
				v2.CFrame * CFrame.new(0, 0, -v2.Size.Z / 2),
				v2:GetAttribute("Id")
			}
		}
		Graffiti:AddRemovedLineToHistory(v2:GetAttribute("Id"))
		v2:Destroy()
	end
end

function Graffiti:EraseUsingIds(p2, items)
	local v2 = {}

	while v[p2] do
		task.wait()
	end

	for _, item in items do
		v2[item] = true
	end

	for _, child in folder:GetChildren() do
		if not (child.Name == p2.Name and v2[child:GetAttribute("Id")]) then
			continue
		end

		if p2 == localPlayer then
			self.Count -= child:GetAttribute("Cost") or 0
		end

		child:Destroy()
	end
end

function Graffiti.GetPreviousHistoryPoint(_)
	local index = table.find(Graffiti.History, Graffiti.HistoryCursor or -1) or #Graffiti.History
	return Graffiti.History[index - 1]
end

function Graffiti.GetNextHistoryPoint(_)
	if not Graffiti.HistoryCursor then
		return Graffiti.History[1]
	end

	local index = table.find(Graffiti.History, Graffiti.HistoryCursor or -1) or #Graffiti.History
	return Graffiti.History[index + 1]
end

function Graffiti.Undo(_, p)
	local v2 = {}
	local v3 = {}
	local v4 = {}

	for _, subData in next, Graffiti.DrawPacket, nil do
		for _, line in next, subData, nil do
			v2[line[3]] = {
				SubData = subData,
				Line = line
			}
		end
	end

	for _, v5 in next, p.Draw, nil do
		for _, v6 in next, v5, nil do
			local v7 = v6[3]
			local v8 = v2[v7]
			local index = v8 and table.find(v8.SubData, v8.Line)

			if index then
				table.remove(v8.SubData, index)
			end

			table.insert(v3, v7)
		end
	end

	for _, v5 in next, p.Erase, nil do
		local v6 = tostring(v5)
		local v7 = Graffiti.HistoryLineData[v6]

		if not v4[v7.Header] then
			v4[v7.Header] = {}
		end

		if not v7 then
			warn((`No history line data for: {v6} (Undo)`))
		end

		table.insert(v4[v7.Header], v7.Data)
	end

	Graffiti.LastHistoryTime = os.clock()
	return Network:invoke("SetHistoryGraffiti", v4, v3)
end

function Graffiti.Redo(_, p)
	local v2 = {}
	local v3 = {}

	for k, v4 in next, p.Draw, nil do
		if not v2[k] then
			v2[k] = {}
		end

		for _, v5 in next, v4, nil do
			table.insert(v2[k], v5)
		end
	end

	for _, v4 in next, p.Erase, nil do
		table.insert(v3, v4)
	end

	Graffiti.LastHistoryTime = os.clock()
	return Network:invoke("SetHistoryGraffiti", v2, v3)
end

function Graffiti:RemoveOldestHistoryPoint()
	local v2 = Graffiti.History[1]

	if not v2 then
		return
	end

	for _, v3 in next, v2.Erase, nil do
		for _, v4 in next, v3, nil do
			Graffiti.HistoryLineData[tostring(v4)] = nil
		end
	end

	table.remove(Graffiti.History, 1)
end

function Graffiti:ClearFutureHistoryPoints()
	if not Graffiti.HistoryCursor then
		return
	end

	local index = table.find(Graffiti.History, Graffiti.HistoryCursor)

	if index < #Graffiti.History then
		for i = index + 1, #Graffiti.History do
			Graffiti.History[i] = nil
		end
	end
end

function Graffiti:GetCurrentHistoryCursor()
	if Graffiti.HistoryCursor and not (next(Graffiti.HistoryCursor.Draw) or next(Graffiti.HistoryCursor.Erase)) or not Graffiti.ShouldCreateNewHistoryCursor then
		return Graffiti.HistoryCursor
	end

	Graffiti.ShouldCreateNewHistoryCursor = false
	local historyCursor = {
		Draw = {},
		Erase = {}
	}

	if Graffiti.HistoryCursor then
		Graffiti:ClearFutureHistoryPoints()
	end

	if #Graffiti.History > Graffiti.MaxHistorySize then
		Graffiti:RemoveOldestHistoryPoint()
		print("removed oldest")
	end

	table.insert(Graffiti.History, historyCursor)
	Graffiti.HistoryCursor = historyCursor
	return Graffiti.HistoryCursor
end

function Graffiti.AddDrawnLineToHistory(_, p: string, p2)
	local currentHistoryCursor = Graffiti:GetCurrentHistoryCursor()

	if not currentHistoryCursor then
		return
	end

	if not currentHistoryCursor.Draw[p] then
		currentHistoryCursor.Draw[p] = {}
	end

	if not table.find(currentHistoryCursor.Draw[p], p2) then
		table.insert(currentHistoryCursor.Draw[p], p2)
	end
end

function Graffiti:AddRemovedLineToHistory(p: string)
	local currentHistoryCursor = Graffiti:GetCurrentHistoryCursor()

	if not table.find(currentHistoryCursor.Erase, p) then
		table.insert(currentHistoryCursor.Erase, p)
	end
end

function Graffiti:ClearHistory()
	Graffiti.History = {}
	Graffiti.HistoryLineData = {}
	Graffiti.HistoryCursor = nil
end

function Graffiti:DrawLine(p, id: string, cframe: CFrame, cframe2: CFrame, p2, p3, layer)
	local unit = (cframe2.Position - cframe.Position):Cross(cframe.UpVector).Unit

	if not cframe.Position:FuzzyEq(cframe2.Position) and math.acos((unit:Dot(-cframe.RightVector))) > 0.2617993877991494 and math.acos((unit:Dot(cframe.RightVector))) > 0.2617993877991494 then
		return
	end

	if (cframe.Position - cframe2.Position).magnitude > 50 or p == localPlayer and self.Count >= self.Limit then
		return
	end

	if cframe.Position:FuzzyEq(cframe2.Position) then
		local v2 = self:DrawPixel(p, cframe, p2, p3, layer, folder)
		v2:SetAttribute("Pixel", true)
		v2:SetAttribute("Id", id)
		v2:SetAttribute("Layer", layer)
		v2.CanQuery = true

		if self.ShouldCount then
			v2:SetAttribute("Cost", 1)

			if localPlayer == p then
				self.Count += v2:GetAttribute("Cost")
			end
		end
	else
		local v2 = self:DrawLineBetween(p, cframe, cframe2, p2, p3, layer)
		v2:SetAttribute("Id", id)
		v2:SetAttribute("Layer", layer)

		if self.ShouldCount then
			v2:SetAttribute("Cost", 3)

			if localPlayer == p then
				self.Count += v2:GetAttribute("Cost")
			end
		end

		self:DrawPixel(p, cframe, p2, p3, layer, v2)
		self:DrawPixel(p, cframe2, p2, p3, layer, v2)
	end

	return true
end

function Graffiti:DrawFromData(p, items, flag: boolean?)
	local count = 0

	for k, item in items do
		local v2, v3, v4 = table.unpack(string.split(k, "/"))

		if v2 and v3 and v4 then
			local v5 = tonumber(v2)
			local decodeColor3 = Graffiti:DecodeColor3(v3)
			local v6 = tonumber(v4)

			for _, list in item do
				local v7, v8, v9 = unpack(list)
				self:DrawLine(p, v9, v7, v8, v5, decodeColor3, v6)
				count += 1

				if count % 100 == 0 and flag then
					task.wait()
				end
			end
		else
			print("invalid stuff")
		end
	end
end

function Graffiti:Clear()
	Graffiti.Count = 0
	Graffiti:ClearHistory()
	folder:ClearAllChildren()
end

function Graffiti:ChangeMode(currentMode: number)
	self.CurrentMode = currentMode
end

function Graffiti.ResetParams(_)
	Graffiti.Params.CollisionGroup = "Default"
	Graffiti.OverlapParams.CollisionGroup = Graffiti.PIXEL_CollisionGroupName
end

Network:listen("DrawGraffiti", function(p, p2)
	if Graffiti:ShouldDraw(p) then
		return Graffiti:DrawFromData(p, p2)
	end
end)
Network:listen("EraseGraffiti", function(p, p2)
	if Graffiti:ShouldDraw(p) then
		return Graffiti:EraseUsingIds(p, p2)
	end
end)
Network:listen("ClearGraffiti", function(p)
	if not p then
		Graffiti.Count = 0
		return Graffiti:Clear()
	end

	for _, child in folder:GetChildren() do
		if child.Name == p then
			child:Destroy()
		end
	end

	if p ~= localPlayer.Name then
		return
	end

	Graffiti.Count = 0
	Graffiti:ClearHistory()
end)

local function draw_old_graffiti()
	local v2 = Network:invoke("RequestGraffiti")

	for k, _ in v2 do
		v[k] = true
	end

	for childName, v3 in v2 do
		local child = game.Players:FindFirstChild(childName)

		if child and child ~= localPlayer and Graffiti:ShouldDraw(child) then
			Graffiti:DrawFromData(child, v3, true)
		end
	end

	for k, _ in v2 do
		v[k] = nil
	end
end

local function drawGraffitiOfPlayer(p)
	local v2 = Network:invoke("RequestPlayerGraffiti", p)

	if not v2 then
		return
	end

	v[p] = true
	Graffiti:DrawFromData(p, v2)
	v[p] = nil
end

Network:listen("DrawCompleteDrawing", function(p, p2)
	if not Graffiti:ShouldDraw(p) then
		return
	end

	Graffiti:DrawFromData(p, p2, true)

	if p == localPlayer then
		Graffiti:ClearHistory()
	end
end)
return Graffiti