local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local BanjoCricket = require(ReplicatedStorage.Data.BanjoCricket)
local BanjoCricketFlags = require(ReplicatedStorage.Shared.Flags.BanjoCricketFlags)
local MessageTyper = require(ReplicatedStorage.Client.UI.MessageTyper)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.fromRGB(255, 85, 85)
local localPlayer = Players.LocalPlayer
local talk_UI = ReplicatedStorage.Assets.UI.Npcs.Talk_UI
local v = {}
local v2 = nil
local v3 = false
local v4 = false
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function isAvailable()
	return BanjoCricketFlags.Enabled:Get() and v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function close()
	local v6 = v2

	if v6 == nil then
		return
	end

	v2 = nil
	v6.Trove:Destroy()
end

local function show(state)
	local line = state.Lines[state.Index]
	local size = talk_UI.Size
	local v6 = #line > 45 and 2 or 1
	state.Bubble.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale * v6, size.Y.Offset)
	state.NextAt = os.clock() + (utf8.len(line) or #line) * 0.03 + math.max(1.3, #line * 0.025)
	state.Typer:Type(line, state.Label.TextColor3)
end

local function claim()
	if flag then
		return
	end

	flag = true
	local success, result, v6 = pcall(function()
		return Remotes.BanjoCricket.AskClaim:InvokeServer()
	end)
	flag = false

	if success and result == true then
		return
	end

	Toast.Show({
		Text = (not success or typeof(v6) ~= "string") and "Something went wrong, try again." or v6,
		Seconds = 3,
		Color = color
	})
end

local function advance()
	local v6 = v2

	if v6 == nil then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") or humanoid == nil or humanoid.Health <= 0 or not v6.Npc:IsDescendantOf(Workspace) or (humanoidRootPart.Position - v6.Anchor.WorldPosition).Magnitude > v6.Prompt.MaxActivationDistance + 8 then
		close() -- equivalent call inferred; original call site unknown
	else
		if os.clock() < v6.NextAt then
			return
		end

		if v6.Index < #v6.Lines then
			v6.Index += 1
			show(v6)
		else
			local finished = v6.Finished
			close() -- equivalent call inferred; original call site unknown
			task.spawn(finished)
		end
	end
end

local function converse(model, proximityPrompt)
	close() -- equivalent call inferred; original call site unknown
	local primaryPart = model.PrimaryPart
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if primaryPart == nil or playerGui == nil then
		return
	end

	local maid = Trove.new()
	local boundingBox, v6 = model:GetBoundingBox()
	local v7 = maid:Add(Instance.new("Attachment"))
	v7.Name = "BanjoCricketSpeech"
	v7.Position = primaryPart.CFrame:PointToObjectSpace(boundingBox.Position + Vector3.new(0, v6.Y / 2, 0))
	v7.Parent = primaryPart
	local bubble = maid:Add(talk_UI:Clone())
	bubble.Name = "BanjoCricketSpeech"
	bubble.Adornee = v7
	bubble.MaxDistance = 45
	bubble.Enabled = true
	bubble.Parent = playerGui
	local textLabel = bubble:FindFirstChildOfClass("TextLabel")
	assert(textLabel, "Talk_UI needs a TextLabel")
	textLabel.Text = ""
	local typer = MessageTyper.new(textLabel, nil, 0.03, false)
	proximityPrompt.Enabled = false
	maid:Add(function()
		typer:Halt()

		if proximityPrompt.Parent ~= nil then
			proximityPrompt.Enabled = isAvailable()
		end
	end)
	local v10 = {
		Npc = model,
		Prompt = proximityPrompt,
		Lines = 0,
		Index = 1,
		NextAt = 0,
		Anchor = 0,
		Bubble = 0,
		Label = 0,
		Typer = 0,
		Finished = 0,
		Trove = 0
	}
	local lines

	if v4 then
		lines = BanjoCricket.Lines.Encore
	else
		lines = BanjoCricket.Lines.Reward
	end

	v10.Lines = lines
	v10.Anchor = v7
	v10.Bubble = bubble
	v10.Label = textLabel
	v10.Typer = typer
	v10.Finished = v4 and function() end or claim
	v10.Trove = maid
	v2 = v10
	maid:Connect(RunService.Heartbeat, advance)
	show(v10)
end

local function promptParent(instance)
	local attachment = instance:FindFirstChild(BanjoCricket.InteractionPoint, true)

	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	return instance.PrimaryPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshPrompts()
	local available = isAvailable() -- equivalent call inferred; original call site unknown

	for _, v6 in v do
		if v2 == nil or v2.Prompt ~= v6 then
			v6.Enabled = available
		end
	end
end

local function bind(model)
	if v[model] or not (model:IsA("Model") and model:IsDescendantOf(Workspace)) then
		return
	end

	local primaryPart = model:FindFirstChild(BanjoCricket.InteractionPoint, true)

	if not (primaryPart and primaryPart:IsA("Attachment")) then
		primaryPart = model.PrimaryPart
	end

	if primaryPart == nil then
		return
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "BanjoCricketTalk"
	proximityPrompt.ActionText = "Talk"
	proximityPrompt.ObjectText = BanjoCricket.NpcName
	proximityPrompt.HoldDuration = 0
	proximityPrompt.MaxActivationDistance = BanjoCricket.TalkDistance
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Enabled = isAvailable()
	proximityPrompt.Parent = primaryPart
	v[model] = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		if v2 == nil then
			converse(model, proximityPrompt)
		end
	end)
end

local function unbind(p)
	local v6 = v[p]

	if v6 == nil then
		return
	end

	v[p] = nil

	if v2 and v2.Npc == p then
		close() -- equivalent call inferred; original call site unknown
	end

	v6:Destroy()
end

local v5 = {
	Start = function()
		local npc = BanjoCricket.Tags.Npc
		CollectionService:GetInstanceAddedSignal(npc):Connect(bind)
		CollectionService:GetInstanceRemovedSignal(npc):Connect(unbind)

		for _, v6 in CollectionService:GetTagged(npc) do
			bind(v6)
		end

		BanjoCricketFlags.Enabled.Changed:Connect(refreshPrompts)
		Tabs.Activated:Connect(close)
	end,
	Sync = function(flag2: boolean, flag3: boolean)
		v3 = flag2
		v4 = flag3
		refreshPrompts() -- equivalent call inferred; original call site unknown
	end
}
return table.freeze(v5)