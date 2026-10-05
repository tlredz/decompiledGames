local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightTargets = require(ReplicatedStorage.GameServices:WaitForChild("HighlightTargets"))
local blur = Lighting:WaitForChild("Blur")
local v = {}
local v2 = {}
local connections = {}
local v3 = false

local function WorldEgg(highlight)
	local parent = highlight.Parent

	while parent and parent ~= workspace do
		if parent:IsA("Model") and parent.Parent and parent.Parent.Name == "RenderedEggs" and parent.Parent.Parent == workspace then
			return parent
		else
			parent = parent.Parent
		end
	end
end

local function OutsideRange(instance, humanoidRootPart, currentCamera)
	if not (humanoidRootPart and currentCamera and instance.Parent) then
		return true
	end

	local position = instance:GetPivot().Position
	local vector = position - humanoidRootPart.Position
	local vector2 = position - currentCamera.CFrame.Position
	return vector:Dot(vector) > 14400 or vector2:Dot(vector2) > 14400
end

local function View()
	local character = localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart"), workspace.CurrentCamera
end

local function Track(highlight)
	if not highlight:IsA("Highlight") or v[highlight] ~= nil then
		return
	end

	local worldEgg = WorldEgg(highlight)
	local v5

	if worldEgg then
		v5 = v2[worldEgg]

		if not v5 then
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			v5 = {
				Highlights = {},
				Hidden = OutsideRange(worldEgg, humanoidRootPart, workspace.CurrentCamera)
			}
			v2[worldEgg] = v5
		end

		v5.Highlights[highlight] = true
	end

	v[highlight] = worldEgg or false
	local track = HighlightTargets.Track
	local hidden = v3

	if not hidden then
		if v5 == nil then
			hidden = false
		else
			hidden = v5.Hidden
		end
	end

	track(highlight, hidden)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Untrack(k)
	local v4 = v[k]

	if v4 == nil then
		return
	end

	v[k] = nil
	local v5 = v4 and v2[v4]

	if v5 then
		v5.Highlights[k] = nil

		if next(v5.Highlights) == nil then
			v2[v4] = nil
		end
	end

	HighlightTargets.Untrack(k)
end

local function Refresh()
	local v4 = blur.Enabled and blur.Size > 1 and true or (localPlayer:GetAttribute("FocusFrameDepth") or 0) > 0

	if v4 == v3 then
		return
	end

	v3 = v4

	for k, v5 in v do
		local v6 = v5 and v2[v5] or nil
		local setMuted = HighlightTargets.SetMuted
		local hidden = v3

		if not hidden then
			if v6 == nil then
				hidden = false
			else
				hidden = v6.Hidden
			end
		end

		setMuted(k, hidden)
	end
end

local function RefreshDistances()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local currentCamera = workspace.CurrentCamera

	for k, v4 in v2 do
		local hidden = OutsideRange(k, humanoidRootPart, currentCamera)

		if hidden == v4.Hidden then
			continue
		end

		v4.Hidden = hidden

		for k2 in v4.Highlights do
			HighlightTargets.SetMuted(k2, v3 or hidden)
		end
	end
end

table.insert(connections, blur:GetPropertyChangedSignal("Size"):Connect(Refresh))
table.insert(connections, blur:GetPropertyChangedSignal("Enabled"):Connect(Refresh))
table.insert(connections, localPlayer:GetAttributeChangedSignal("FocusFrameDepth"):Connect(Refresh))
Refresh()
table.insert(connections, workspace.DescendantAdded:Connect(Track))
table.insert(connections, workspace.DescendantRemoving:Connect(Untrack))
local flag = true

for _, descendant in workspace:GetDescendants() do
	Track(descendant)
end

task.spawn(function()
	while flag do
		task.wait(0.2)

		if flag then
			RefreshDistances()
		end
	end
end)
script.Destroying:Connect(function()
	flag = false

	for _, connection in connections do
		connection:Disconnect()
	end

	for k in v do
		Untrack(k) -- equivalent call inferred; original call site unknown
	end
end)