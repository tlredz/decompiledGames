local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = {
	CashPopup = true
}
local v2 = {}

for _, folder in ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):GetChildren() do
	v[folder.Name] = true

	for _, guiBase2d in folder:GetDescendants() do
		if guiBase2d:IsA("GuiBase2d") then
			guiBase2d.AutoLocalize = false
		end
	end

	if folder:IsA("GuiBase2d") then
		folder.AutoLocalize = false
	end
end

local function ResolveAnchor(billboardGui, p)
	local adornee = billboardGui.Adornee or billboardGui.Parent

	if adornee and adornee:IsA("BasePart") then
		p.Anchor = adornee
		p.AnchorKind = 1
	elseif adornee and adornee:IsA("Attachment") then
		p.Anchor = adornee
		p.AnchorKind = 2
	elseif adornee and adornee:IsA("Model") then
		p.Anchor = adornee
		p.AnchorKind = 3
	else
		p.Anchor = nil
		p.AnchorKind = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetAnchorPosition(p)
	local anchorKind = p.AnchorKind

	if anchorKind == 1 then
		return p.Anchor.Position
	elseif anchorKind == 2 then
		return p.Anchor.WorldPosition
	elseif anchorKind == 3 then
		return p.Anchor:GetPivot().Position
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Drop(p, flag: boolean?)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil

	for _, connection in v3.Connections do
		connection:Disconnect()
	end

	if flag then
		p.MaxDistance = v3.Range
	end
end

local function Manage(billboardGui)
	if not billboardGui:IsA("BillboardGui") or v2[billboardGui] then
		return
	end

	if v[billboardGui.Name] and billboardGui.AutoLocalize then
		billboardGui.AutoLocalize = false
	end

	if billboardGui.MaxDistance == 1e999 then
		return
	end

	local v3 = {
		Range = billboardGui.MaxDistance,
		External = billboardGui.Enabled,
		LastApplied = billboardGui.Enabled,
		ForceDisabled = billboardGui:GetAttribute("ForceDisabled") == true,
		Connections = {}
	}
	ResolveAnchor(billboardGui, v3)
	billboardGui.MaxDistance = 1e999
	local connections = v3.Connections
	table.insert(connections, billboardGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if billboardGui.Enabled ~= v3.LastApplied then
			v3.External = billboardGui.Enabled
			v3.LastApplied = billboardGui.Enabled
		end
	end))
	table.insert(connections, billboardGui:GetAttributeChangedSignal("ForceDisabled"):Connect(function()
		v3.ForceDisabled = billboardGui:GetAttribute("ForceDisabled") == true
	end))
	table.insert(connections, billboardGui:GetPropertyChangedSignal("Adornee"):Connect(function()
		ResolveAnchor(billboardGui, v3)
	end))
	table.insert(connections, billboardGui.AncestryChanged:Connect(function(p, parent)
		if parent then
			if p == billboardGui and not billboardGui.Adornee then
				ResolveAnchor(billboardGui, v3)
			end
		else
			Drop(billboardGui, true) -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, billboardGui.Destroying:Connect(function()
		Drop(billboardGui, false) -- equivalent call inferred; original call site unknown
	end))
	v2[billboardGui] = v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Scan(folder)
	for _, descendant in folder:GetDescendants() do
		Manage(descendant)
	end

	folder.DescendantAdded:Connect(Manage)
end

RunService.Heartbeat:Connect(function()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position

	for k, v3 in v2 do
		local anchorPosition = GetAnchorPosition(v3) -- equivalent call inferred; original call site unknown

		if not anchorPosition then
			continue
		end

		local magnitude = (anchorPosition - position).Magnitude
		local enabled = k.Enabled
		local v5

		if enabled then
			v5 = magnitude <= v3.Range + 4
		else
			v5 = magnitude <= v3.Range
		end

		local v6 = v3.External and v5 and not v3.ForceDisabled

		if enabled == v6 then
			continue
		end

		v3.LastApplied = v6
		k.Enabled = v6
	end
end)
local workspace2 = workspace
Scan(workspace2) -- equivalent call inferred; original call site unknown
Scan(playerGui) -- equivalent call inferred; original call site unknown