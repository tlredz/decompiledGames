local KidClueClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local v = {
	DinoKid = "Dino Kid",
	KrakenKid = "Kraken Kid",
	SquidKid = "Squid Kid",
	KoalaKid = "Koala Kid"
}
local v2 = {
	DinoKid = Color3.fromRGB(255, 45, 45),
	KrakenKid = Color3.fromRGB(125, 205, 255),
	SquidKid = Color3.fromRGB(255, 220, 60),
	KoalaKid = Color3.fromRGB(150, 150, 150)
}
local v3 = {
	KoalaKid = Color3.fromRGB(0, 0, 0)
}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}

function ClueKey(p, p2)
	return p .. p2
end

function MapBuilt()
	for _, v12 in pairs(CollectionService:GetTagged("MapDraw")) do
		if v12:IsDescendantOf(workspace.Structures) then
			return true
		end
	end

	return false
end

function StageSize(p, value)
	return math.max(0.18 - (p - 1) * 0.05, 0.08) + (value or 0)
end

function StageCount()
	local v12 = 1

	while StageSize(v12) > 0.081 do
		v12 += 1
	end

	return v12
end

function MakeCircle(p, p2, imageTransparency, imageColor)
	local clone = Client.Interface.MapHolder.KidClues.Circle:Clone()
	clone.Size = UDim2.new(p2, 0, p2, 0)

	if imageColor then
		clone.ImageColor3 = imageColor
	end

	local worldToScale, v12 = Client.MapDrawClient.WorldToScale(p.X, p.Z)
	clone.Position = UDim2.new(worldToScale, 0, v12, 0)
	clone.ZIndex = 20
	clone.ImageTransparency = 1
	clone.Visible = true
	clone.Parent = Client.MapDrawClient.GetMapFrame().Icons
	TweenService:Create(clone, TweenInfo.new(1), {
		ImageTransparency = imageTransparency
	}):Play()
	return clone
end

function MakeOldCircle(p, p2, p3)
	local v12 = MakeCircle(p, p2, 0.8, p3)
	v12.Name = "CircleOLD"
	v12.ZIndex = 19
	return v12
end

function ClearKidCircles(p)
	local v12 = v5[p]

	if v12 then
		if v12.Circle then
			v12.Circle:Destroy()
		end

		if v12.OldCircle then
			v12.OldCircle:Destroy()
		end
	end

	v5[p] = nil
	v4[p] = nil
	Client.CompassClient.RemoveIconFromCompass("Clue" .. p)
end

function FadeOutCircle(instance)
	if instance == nil then
		return
	end

	local tween = TweenService:Create(instance, TweenInfo.new(1), {
		ImageTransparency = 1
	})
	tween.Completed:Connect(function()
		instance:Destroy()
	end)
	tween:Play()
end

function FadeOutKidCircles(p)
	local v12 = v5[p]

	if v12 then
		FadeOutCircle(v12.Circle)
		FadeOutCircle(v12.OldCircle)
	end

	v5[p] = nil
	v4[p] = nil
	Client.CompassClient.RemoveIconFromCompass("Clue" .. p)
	Client.GiveKidItemClient.CheckHeldItem()
end

function FindTrinket(childName)
	for k in pairs(v10) do
		if k.Parent and k.Parent.Name == childName then
			return k.Parent
		end
	end

	return workspace.Items:FindFirstChild(childName)
end

function AddClueToCompass(p, p2)
	local v12 = nil
	local addIconToCompass = Client.CompassClient.AddIconToCompass(
		"Clue" .. p,
		Client.Databases.HotbarIcons.Icons[p2] or "",
		function()
			if not (v12 and v12.Parent) then
				v12 = FindTrinket(p2)
			end

			local primaryPart = v12 and v12:IsDescendantOf(workspace) and v12.PrimaryPart
			return primaryPart and primaryPart.Position
		end,
		100
	)
	addIconToCompass.ImageColor3 = v3[p] or v2[p]
end

function DrawCircleStage(p, p2)
	ClearKidCircles(p)
	local v12 = v6[p2]
	local v13 = v9[p2]

	if not (v12 and v13) then
		return
	end

	local v14 = v8[p2]
	local v15 = {}

	if v13 > 1 and v12[v13 - 1] then
		v15.OldCircle = MakeOldCircle(v12[v13 - 1], StageSize(v13 - 1, v14), v2[p])
	end

	v15.Circle = MakeCircle(v12[v13] or v12[1], StageSize(v13, v14), 0.1, v2[p])
	v5[p] = v15
	v4[p] = p2
	AddClueToCompass(p, v7[p2])
	Client.GiveKidItemClient.CheckHeldItem()
end

function StartShrinkLoop(p, p2)
	task.spawn(function()
		while v9[p2] and v9[p2] < StageCount() do
			task.wait(270)

			if not v9[p2] then
				continue
			end

			v9[p2] += 1

			if v4[p] == p2 then
				DrawCircleStage(p, p2)
			end
		end
	end)
end

function KidIsFriended(p)
	for _, v12 in pairs(CollectionService:GetTagged("ChildNPC")) do
		if v12:GetAttribute("KidId") == p and v12:GetAttribute("Friending") then
			return true
		end
	end

	return false
end

function ClueRevealed(p, p2, p3, p4, value)
	if Client.MapDrawClient.GetMapFrame() == nil then
		return
	end

	if not MapBuilt() then
		Client.PopUpUI.AddPopUp("build a map first", "warning")
		return
	end

	local v12 = ClueKey(p, p2)
	v6[v12] = p3
	v7[v12] = p4
	v8[v12] = value or 0

	if v9[v12] == nil then
		v9[v12] = 1
		StartShrinkLoop(p, v12)
	end

	Client.Sound.Play("ClueBoardDraw", {
		Volume = 0.4
	})
	DrawCircleStage(p, v12)
	local v13 = v[p] or p
	local v14 = "Find " .. v13 .. "'s trinket to befriend them"

	if KidIsFriended(p) then
		v14 = "Find " .. v13 .. "'s trinket"
	end

	Client.PopUpUI.AddPopUp(v14)
	Client.MapDrawClient.OpenMap()
end

function TrinketFound(p, p2)
	local v12 = ClueKey(p, p2)
	v9[v12] = nil
	v6[v12] = nil
	v7[v12] = nil
	v8[v12] = nil

	if v4[p] == v12 then
		FadeOutKidCircles(p)
	end
end

function TrinketBillboardAdded(p)
	p.Enabled = false
	v10[p] = true
end

function TrinketBillboardRemoved(p)
	v10[p] = nil
end

function GetBillboardPosition(instance)
	local adornee = instance.Adornee or instance.Parent

	if adornee == nil then
		return nil
	end

	if adornee:IsA("Attachment") then
		return adornee.WorldPosition
	end

	if adornee:IsA("BasePart") then
		return adornee.Position
	end

	if adornee:IsA("Model") then
		return adornee:GetPivot().Position
	end
end

function LoopUpdateTrinketBillboards()
	while true do
		task.wait(0.5)
		local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart

		for k in pairs(v10) do
			if k.Parent == nil then
				v10[k] = nil
			else
				local enabled = false

				if primaryPart then
					local v13 = GetBillboardPosition(k)
					enabled = v13 and (v13 - primaryPart.Position).Magnitude <= 16 and true or false
				end

				k.Enabled = enabled
			end
		end
	end
end

function FindKidTrinketInInventory(instance)
	local pingName = instance:GetAttribute("PingName")
	local inventory = localPlayer:FindFirstChild("Inventory")

	if not (pingName and inventory) then
		return nil
	end

	local v12 = pingName .. "'s "

	for _, child in pairs(inventory:GetChildren()) do
		if string.sub(child.Name, 1, #v12) == v12 then
			return child
		end
	end

	return nil
end

function KidClueClient.CluePromptBlocked(instance)
	if Client.LostChildClient.IsKidSad(instance) then
		return true
	end

	if v4[instance:GetAttribute("KidId")] == nil then
		return false
	end

	if MapBuilt() then
		return FindKidTrinketInInventory(instance) == nil
	end

	return false
end

function UpdateBefriendPromptLabel(instance)
	local kidId = instance:GetAttribute("KidId")

	if instance:GetAttribute("Interaction") ~= "Befriend" .. tostring(kidId) then
		return
	end

	local actionText = "Befriend"

	if instance:GetAttribute("Friending") then
		actionText = "Ask for Clue"
	else
		local pingName = instance:GetAttribute("PingName")
		local v13 = FindKidTrinketInInventory(instance)

		if v13 and pingName then
			actionText = "Befriend with " .. string.sub(v13.Name, #pingName + 4)
		end
	end

	if instance:GetAttribute("InteractLabel") ~= actionText then
		instance:SetAttribute("InteractLabel", actionText)
	end

	local proximityAttachment = instance.PrimaryPart and instance.PrimaryPart:FindFirstChild("ProximityAttachment")
	local proximityInteraction = proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")

	if proximityInteraction then
		proximityInteraction.ActionText = actionText
	end
end

function UpdateAllBefriendPromptLabels()
	for _, v12 in pairs(CollectionService:GetTagged("ChildNPC")) do
		UpdateBefriendPromptLabel(v12)
	end
end

function KidPromptAdded(object)
	local connections = {}

	for _, v12 in pairs({ "Interaction", "InteractLabel", "Friending" }) do
		table.insert(connections, object:GetAttributeChangedSignal(v12):Connect(function()
			UpdateBefriendPromptLabel(object)
		end))
	end

	v11[object] = connections
	UpdateBefriendPromptLabel(object)
end

function KidPromptRemoved(p)
	for _, connection in pairs(v11[p] or {}) do
		connection:Disconnect()
	end

	v11[p] = nil
end

function KidClueClient.Init()
	Client.Utility.ForAllTagged("TrinketFace", TrinketBillboardAdded, TrinketBillboardRemoved)
	Client.Utility.ForAllTagged("ChildNPC", KidPromptAdded, KidPromptRemoved)

	local function refreshCluePrompts()
		Client.GiveKidItemClient.CheckHeldItem()
	end

	Client.Utility.ForAllTagged("MapDraw", refreshCluePrompts, refreshCluePrompts)
	Client.Events.KidClueRevealed:Connect(ClueRevealed)
	Client.Events.KidTrinketFound:Connect(TrinketFound)
	task.spawn(function()
		local inventory = localPlayer:WaitForChild("Inventory")
		inventory.ChildAdded:Connect(function(child)
			for k, v12 in pairs(v4) do
				if v7[v12] == child.Name then
					FadeOutKidCircles(k)
				end
			end

			UpdateAllBefriendPromptLabels()
		end)
		inventory.ChildRemoved:Connect(function()
			UpdateAllBefriendPromptLabels()
		end)
	end)
end

return KidClueClient