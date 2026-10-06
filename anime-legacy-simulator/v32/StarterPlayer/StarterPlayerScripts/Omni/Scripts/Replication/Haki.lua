local module = require("@game/ReplicatedStorage/Omni")
local v = {
	LeftLowerArm = true,
	LeftHand = true,
	RightLowerArm = true,
	RightHand = true
}
local replication = workspace:WaitForChild("Server"):WaitForChild("Replication")
local v2 = {}
local now = 0
local Haki = {}

local function GetRemoteDistance(player)
	if player.Player == module.Instance then
		return
	end

	local character = player.Character

	if not (character and character:IsDescendantOf(workspace) and player.PlayerFolder:GetAttribute("Haki")) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local currentCamera = workspace.CurrentCamera

	if not (humanoidRootPart and currentCamera) then
		return
	end

	local magnitude = (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude

	if magnitude > 80 then
		return
	else
		return magnitude
	end
end

function Haki.ClearCharacter(p: string)
	local v3 = v2[p]

	if not v3 then
		return
	end

	for _, characterConnection in v3.CharacterConnections do
		characterConnection:Disconnect()
	end

	for _, highlight in v3.Highlights do
		highlight:Destroy()
	end

	table.clear(v3.CharacterConnections)
	table.clear(v3.Highlights)
	v3.Character = nil
	v3.InRange = nil
end

function Haki.Destroy(p: string)
	local v3 = v2[p]

	if not v3 then
		return
	end

	Haki.ClearCharacter(p)

	for _, connection in v3.Connections do
		connection:Disconnect()
	end

	table.clear(v3.Connections)
	v2[p] = nil
end

function Haki.Update(p: string)
	local v3 = v2[p]

	if not v3 then
		return
	end

	local character = v3.Character

	if not character then
		return
	end

	local haki = v3.PlayerFolder:GetAttribute("Haki")
	local v4 = haki and module.Shared.Gacha.Sources.Haki.Normal[haki]
	local v5 = v3.Player == module.Instance
	local v6 = v5 and "Hide My Haki" or "Hide Other Haki"
	local enabled

	if v4 == nil then
		enabled = false
	else
		enabled = not module.Data.Settings[v6] and character:IsDescendantOf(workspace) and (v5 or v3.InRange == true)
	end

	local rarityColor = v4 and module.Utils.Colors:GetRarityColor(v4.Rarity)

	for k, highlight in v3.Highlights do
		if not (k.Parent ~= character or not v[k.Name] or highlight.Parent ~= k) then
			continue
		end

		highlight:Destroy()
		v3.Highlights[k] = nil
	end

	for _, part in character:GetChildren() do
		if not (part:IsA("BasePart") and v[part.Name]) then
			continue
		end

		local v8 = v3.Highlights[part]

		if not v8 and enabled then
			v8 = Instance.new("Highlight")
			v8.Name = "HakiHighlight"
			v8.Adornee = part
			v8.FillColor = Color3.new(0, 0, 0)
			v8.FillTransparency = 0
			v8.OutlineTransparency = 0
			v8.DepthMode = Enum.HighlightDepthMode.Occluded
			v8.OutlineColor = rarityColor
			v8.Parent = part
			v3.Highlights[part] = v8
		end

		if not v8 then
			continue
		end

		v8.Enabled = enabled

		if rarityColor then
			v8.OutlineColor = rarityColor
		end
	end
end

function Haki.SetCharacter(p: string, character)
	local v3 = v2[p]

	if not v3 or v3.Character == character then
		return
	end

	Haki.ClearCharacter(p)
	v3.Character = character
	v3.CharacterConnections.Added = character.ChildAdded:Connect(function(part)
		if part:IsA("BasePart") and v[part.Name] then
			Haki.Update(p)
		end
	end)
	v3.CharacterConnections.Removed = character.ChildRemoved:Connect(function(child)
		local highlight = v3.Highlights[child]

		if not highlight then
			return
		end

		highlight:Destroy()
		v3.Highlights[child] = nil
	end)
	v3.CharacterConnections.Ancestry = character.AncestryChanged:Connect(function()
		Haki.Update(p)
	end)
	Haki.Update(p)
end

function Haki.Setup(folder)
	if not folder:IsA("Folder") or folder.Parent ~= replication then
		return
	end

	local child = module.Services.Players:FindFirstChild(folder.Name)

	if not child then
		return
	end

	local v3 = v2[child.Name]

	if v3 and v3.PlayerFolder == folder then
		return
	end

	Haki.Destroy(child.Name)
	local v4 = {
		Player = child,
		PlayerFolder = folder,
		Connections = {},
		CharacterConnections = {},
		Highlights = {}
	}
	v2[child.Name] = v4
	v4.Connections.Haki = folder:GetAttributeChangedSignal("Haki"):Connect(function()
		Haki.Update(child.Name)
	end)
	v4.Connections.CharacterAdded = child.CharacterAdded:Connect(function(character)
		Haki.SetCharacter(child.Name, character)
	end)
	v4.Connections.CharacterRemoving = child.CharacterRemoving:Connect(function(character)
		if v4.Character ~= character then
			return
		end

		Haki.ClearCharacter(child.Name)
	end)
	v4.Connections.Ancestry = folder.AncestryChanged:Connect(function()
		if folder.Parent == replication then
			return
		end

		Haki.Destroy(child.Name)
	end)

	if child.Character then
		Haki.SetCharacter(child.Name, child.Character)
	end
end

function Haki.RefreshVisibility(flag: boolean?)
	now = os.clock()
	local lowMode = module.Data.Settings["Low Mode"] == true

	for k, v3 in v2 do
		local inRange = not lowMode and GetRemoteDistance(v3) ~= nil

		if not (flag or v3.InRange ~= inRange) then
			continue
		end

		v3.InRange = inRange
		Haki.Update(k)
	end
end

function Haki.UpdateAll()
	Haki.RefreshVisibility(true)
end

module:OnDataChanged({ "Settings" }, Haki.UpdateAll)
module.Utils.Instance:ObserveChilds(replication, Haki.Setup)
module.Services.Players.PlayerAdded:Connect(function(player)
	local child = replication:FindFirstChild(player.Name)

	if not child then
		return
	end

	Haki.Setup(child)
end)
module.Services.Players.PlayerRemoving:Connect(function(player)
	Haki.Destroy(player.Name)
end)
module.Services.RunService.Heartbeat:Connect(function()
	if os.clock() - now < 0.5 then
		return
	end

	Haki.RefreshVisibility()
end)
return Haki