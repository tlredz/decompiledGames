game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Painter = {}
Painter.__index = Painter
local Server = require(ReplicatedStorage.Modules.Server)
local paint = ReplicatedStorage.Assets.Misc:WaitForChild("Paint")
local line = ReplicatedStorage.Assets.Misc:WaitForChild("Line")
Painter.ShouldCount = Server:GetServerType() ~= Server.Servers.Neighborhood
Painter.Limit = 15000

function Painter.new()
	local v = {
		OverlapParams = OverlapParams.new(),
		Count = 0
	}
	v.OverlapParams.FilterType = Enum.RaycastFilterType.Include
	v.OverlapParams.FilterDescendantsInstances = { workspace.Graffiti }
	setmetatable(v, Painter)
	v.Count = v:GetCount(Players.LocalPlayer)
	return v
end

function Painter:Paint(raycastResult: RaycastResult, color: Color3, size: number, layer: number, parent, p: number?)
	local clone = paint:Clone()
	clone.Parent = parent
	clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
	clone.CFrame += clone.CFrame.LookVector * (layer * 0.006)
	clone.Size = Vector3.new(size, size, 0)
	clone.Color = color
	clone.Anchored = true
	clone.Name = Players:GetPlayerByUserId(p or game.Players.LocalPlayer.UserId).Name
	clone:SetAttribute("Layer", layer)
	clone:SetAttribute("Color", color)
	clone:SetAttribute("Size", size)
	clone:SetAttribute("Owner", p or game.Players.LocalPlayer.UserId)
	local playerByUserId = p and Players:GetPlayerByUserId(p) or Players.LocalPlayer

	if self.ShouldCount and playerByUserId == Players.LocalPlayer then
		clone.Destroying:Connect(function()
			self.Count -= 1
		end)
		clone:SetAttribute("Cost", self.ShouldCount and 1 or 0)
		self.Count += 1
	end

	return clone
end

function Painter:DrawLineBetween(raycastResult: RaycastResult, raycastResult2: RaycastResult, color: Color3, size: number, layer: number, parent, p: number?)
	local clone = line:Clone()
	clone.Parent = parent
	clone.Color = color
	clone.Anchored = true
	clone.Size = Vector3.new(size, 0, (raycastResult2.Position - raycastResult.Position).Magnitude)
	clone.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult2.Position, raycastResult.Normal) * CFrame.new(
		0,
		layer * 0.006,
		-clone.Size.Z / 2
	)
	clone.Name = Players:GetPlayerByUserId(p or game.Players.LocalPlayer.UserId).Name
	clone:SetAttribute("Layer", layer)
	clone:SetAttribute("Color", color)
	clone:SetAttribute("Size", size)
	clone:SetAttribute("Owner", p or game.Players.LocalPlayer.UserId)
	clone:SetAttribute("Cost", self.ShouldCount and 1 or 0)
	local playerByUserId = p and Players:GetPlayerByUserId(p) or Players.LocalPlayer

	if self.ShouldCount and playerByUserId == Players.LocalPlayer then
		clone.Destroying:Connect(function()
			self.Count -= 1
		end)
		self.Count += 1
	end

	return clone
end

function Painter:DrawLine(raycastResult: RaycastResult, raycastResult2: RaycastResult, color: Color3, p: number, p2: number, p3, p4: number?, _)
	if (p4 and Players:GetPlayerByUserId(p4) or Players.LocalPlayer) == Players.LocalPlayer and self.Count >= self.Limit then
		return
	end

	local v = math.acos((raycastResult.Position:Dot(raycastResult2.Position)))
	local magnitude = (raycastResult.Position - raycastResult2.Position).Magnitude

	if raycastResult.Instance ~= raycastResult2.Instance or not raycastResult.Position:FuzzyEq(raycastResult2.Position) and v < 0.2617993877991494 or magnitude > 50 then
		return
	end

	if raycastResult.Position:FuzzyEq(raycastResult2.Position) then
		return (self:Paint(raycastResult, color, p, p2, p3, p4))
	end

	local v2 = self:DrawLineBetween(raycastResult, raycastResult2, color, p, p2, p3, p4)
	self:Paint(raycastResult, color, p, p2, v2, p4)
	self:Paint(raycastResult2, color, p, p2, v2, p4)
	return v2
end

function Painter:DrawFromData(list)
	local v = list[1]
	local playerByUserId = Players:GetPlayerByUserId(v.Owner)
	local model = Instance.new("Model")
	model.Name = "Line"
	model.Parent = workspace.Graffiti
	model:SetAttribute("Owner", playerByUserId.UserId)
	model:SetAttribute("LineId", v.LineId)

	for k, v2 in list do
		local v3 = list[k + 1]

		if v3 then
			self:DrawLine(v2.Result, v3.Result, v2.Color, v2.Size, v2.Layer, model, v2.Owner)
		else
			self:Paint(v2.Result, v2.Color, v2.Size, v2.Layer, model, v2.Owner)
		end
	end
end

function Painter:GetPaintInBox(cframe: CFrame, p2: number, p3: number, p4)
	local v = p4 or Players.LocalPlayer
	local partBoundsInBox = workspace:GetPartBoundsInBox(
		cframe,
		Vector3.new(p2 * 2.5, p2 * 2.5, p2 * 2.5),
		self.OverlapParams
	)
	local result = {}

	for _, v2 in partBoundsInBox do
		if not (v2:GetAttribute("Layer") == p3 and v2:GetAttribute("Owner") == v.UserId) then
			continue
		end

		table.insert(result, v2)
	end

	return result
end

function Painter:Erase(cframe: CFrame, p: number, p2: number, p3)
	local paintInBox = self:GetPaintInBox(cframe, p, p2, p3)
	local lineIds = {}

	for _, v in paintInBox do
		local model = v:FindFirstAncestorOfClass("Model")

		if not model then
			continue
		end

		model:Destroy()
		table.insert(lineIds, model:GetAttribute("LineId"))
	end

	return lineIds
end

function Painter.EraseAllOfPlayer(_, p)
	local children = workspace.Graffiti:GetChildren()
	local lineIds = {}

	for _, v in children do
		if v:GetAttribute("Owner") ~= p.UserId then
			continue
		end

		table.insert(lineIds, v:GetAttribute("LineId"))
		v:Destroy()
	end

	return lineIds
end

function Painter:GetCount(p)
	local children = workspace.Graffiti:GetChildren()

	for _, v in children do
		if v:GetAttribute("Owner") == p.UserId then
			table.insert(v:GetAttribute("Cost"))
		end
	end

	return 0
end

function Painter.EraseAllBut(_, p)
	local children = workspace.Graffiti:GetChildren()
	local lineIds = {}

	for _, v in children do
		if v:GetAttribute("Owner") == p.UserId then
			continue
		end

		table.insert(lineIds, v:GetAttribute("LineId"))
		v:Destroy()
	end

	return lineIds
end

function Painter.EraseAll(_)
	local children = workspace.Graffiti:GetChildren()
	local lineIds = {}

	for _, v in children do
		table.insert(lineIds, v:GetAttribute("LineId"))
		v:Destroy()
	end

	return lineIds
end

return Painter