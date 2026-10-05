local TreeRootClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local v = 1
local v2 = false
local treeRootBeam = nil
local attachment = nil
local attachment2 = nil
local v3 = nil
local tagged = {}

function TweenColour(p, color: Color3, p2)
	local color2 = p.Color
	Client.TweenModule.new(function(p3)
		p.Color = color2:Lerp(color, p3)
	end, p2):Play()
end

Client.Events.RootComplete:Connect(function(p)
	Client.TreeRootGen.RootComplete(p)
end)

function RevealEndRoot(instance)
	local v4 = {}
	local part2 = nil

	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name == "Tip" then
			part2 = part
		else
			local sortOrder = tonumber((string.sub(part.Name, 11)))

			if sortOrder and sortOrder >= 10000 then
				table.insert(v4, {
					Part = part,
					SortOrder = sortOrder
				})
			end
		end
	end

	table.sort(v4, function(a, b)
		return a.SortOrder < b.SortOrder
	end)

	if part2 then
		table.insert(v4, {
			Part = part2
		})
	end

	for _, v6 in pairs(v4) do
		TweenService:Create(v6.Part, TweenInfo.new(0.15), {
			Transparency = 0
		}):Play()
		task.wait(0.15)
	end
end

Client.Events.GenerateTreeRoot:Connect(function(p, p2, p3, p4, p5)
	local root = Client.TreeRootGen.GenerateRoot(p, p2, p3, p4, p5)

	if not p5 then
		task.wait(root)
		RevealEndRoot(p4)
	end
end)

function TreeRootClient:PlantAcorn()
	local position = self:GetPivot().Position
	local v4 = 1e999
	local v5 = nil

	for _, v6 in pairs(tagged) do
		if v6:GetAttribute("NodeCooldown") then
			continue
		end

		local magnitude = (position - v6:GetPivot().Position).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v5 = v6
		v4 = magnitude
	end

	if not v5 then
		Client.PopUpUI.AddPopUp("you must plant this in range of a tree root", "warning")
		return
	end

	local position2 = self:GetPivot().Position
	local magnitude = (position2 - v5:GetPivot().Position).Magnitude

	if magnitude < 4 then
		Client.PopUpUI.AddPopUp("you can't plant this so close to a tree root", "warning")
		return
	end

	if magnitude > 60 then
		Client.PopUpUI.AddPopUp("you must plant this in range of a tree root", "warning")
		return
	end

	local parent = self.Parent
	self.Parent = game.ReplicatedStorage.TempStorage
	task.spawn(function()
		local v6 = Client.Events.RequestPlantAcorn:InvokeServer(self, position2)

		if v6 and v6.Success then
			return
		end

		self.Parent = parent
	end)
end

function AdornHighlight(p)
	if p then
	end
end

function TreeRootClient.EnableHighlights()
	local v4 = v + 1
	v = v4
	v2 = true
	task.spawn(function()
		while v == v4 do
			HighlightClosestNode()
			task.wait()
		end

		treeRootBeam.Enabled = false
	end)
end

function TreeRootClient.DisableHighlights()
	v += 1
	v2 = false
	HighlightClosestNode()
end

function PrepareNodes()
	tagged = CollectionService:GetTagged("TreeRootNode")
	CollectionService:GetInstanceAddedSignal("TreeRootNode"):Connect(function(p)
		table.insert(tagged, p)
	end)
	CollectionService:GetInstanceRemovedSignal("TreeRootNode"):Connect(function(p)
		local index = table.find(tagged, p)

		if index then
			table.remove(tagged, index)
		end

		if CurrentFocus == p then
			HighlightClosestNode()
		end
	end)
end

function GetClosestNode()
	if not v2 then
		return
	end

	local v4 = nil
	local draggingItem = Client.InteractionHandler.GetDraggingItem()

	if draggingItem and draggingItem:HasTag("Acorn") then
		v4 = draggingItem
	end

	if not v4 then
		return
	end

	local position = v4:GetPivot().Position
	local v5 = 1e999
	local v6 = nil

	for _, v7 in pairs(tagged) do
		if v7:GetAttribute("NodeCooldown") then
			continue
		end

		local magnitude = (position - v7:GetPivot().Position).Magnitude

		if not (magnitude < v5) then
			continue
		end

		v6 = v7
		v5 = magnitude
	end

	return v6, v5
end

function HighlightClosestNode()
	local v4, v5 = GetClosestNode()
	local v6 = nil

	if v4 and v5 <= 60 then
		v6 = v4
	end

	v3 = v4
	local v7 = nil
	local draggingItem = Client.InteractionHandler.GetDraggingItem()

	if draggingItem and draggingItem:HasTag("Acorn") then
		v7 = draggingItem
	end

	if v6 and v7 then
		attachment.WorldCFrame = v6:GetPivot()
		attachment2.WorldCFrame = v7:GetPivot()
		treeRootBeam.Enabled = true
	else
		treeRootBeam.Enabled = false
	end

	if v6 ~= CurrentFocus then
		if v6 then
			AdornHighlight(v6)
		else
			AdornHighlight(nil)
		end
	end

	CurrentFocus = v6
end

function TreeRootClient.Init()
	task.spawn(function()
		treeRootBeam = workspace:WaitForChild("Highlights"):WaitForChild("TreeRootBeam")
		attachment = Instance.new("Attachment", workspace:WaitForChild("Terrain"))
		attachment2 = Instance.new("Attachment", workspace:WaitForChild("Terrain"))
		treeRootBeam.Attachment0 = attachment
		treeRootBeam.Attachment1 = attachment2
		PrepareNodes()
		TreeRootClient.EnableHighlights()
	end)
end

return TreeRootClient