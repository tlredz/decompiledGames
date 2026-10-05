local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Packages.Observers)
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.CutsceneUtil)
local v3 = require3(ReplicatedStorage2.Shared.JumpModifiers)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local cutsceneOutside = playerGui:WaitForChild("CutsceneOutside")
local cutscene = playerGui:WaitForChild("Cutscene")
local v4 = { playerGui:WaitForChild("HUD"), playerGui:WaitForChild("Hotbar") }
local remoteFunction = v2:RemoteFunction("ClientCutscene")
local remoteEvent = v2:RemoteEvent("CutsceneTimer")
local remoteEvent2 = v2:RemoteEvent("CutsceneSkip")
local v5 = {}

local function hidePlayer(player)
	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	end

	if character and humanoidRootPart then
		humanoidRootPart.Anchored = true

		if not character:GetAttribute("PlayerHidden") then
			character:SetAttribute("PlayerHidden", character:GetPivot())
		end

		character:PivotTo(CFrame.new(0, 1000000000, 0))
	end
end

local function showPlayer(player)
	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	end

	if character and humanoidRootPart then
		local playerHidden = character:GetAttribute("PlayerHidden")

		if playerHidden then
			character:PivotTo(playerHidden)
			local humanoid = player == Players.LocalPlayer and character:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end

			character:SetAttribute("PlayerHidden", nil)
		end

		humanoidRootPart.Anchored = false
	end
end

local CutsceneController = {}

function CutsceneController:Play(state)
	local UUID = state.UUID

	if not UUID then
		return false
	end

	local v6 = v5[state.Name]

	if not v6 then
		return false
	end

	local thread = coroutine.running()
	cutscene.Enabled = true
	cutsceneOutside.Enabled = false
	local activatedConnection = cutscene.Skip.Activated:Connect(function()
		remoteEvent2:FireServer(UUID)
	end)

	local function updateText()
		cutscene.Skip.Count.Label.Text = workspace:GetAttribute((`Skip_{UUID}`)) or "0/0"
	end

	cutscene.Skip.Visible = false
	cutscene.Loading.Visible = true
	local connection = workspace:GetAttributeChangedSignal((`Skip_{UUID}`)):Connect(updateText)
	task.spawn(updateText)
	local onClientEventConnection = remoteEvent2.OnClientEvent:Once(function(p)
		if p == UUID then
			v.Thread.SafeResume(thread)
		end
	end)
	local v7

	if localPlayer.Character then
		v7 = v3:SetModifierFor(localPlayer.Character, "CutsceneFreeze", function(_: number, _)
			return 0
		end, -999)
	end

	local parents = {}

	local function onHideInCutsceneObjectAdded(p)
		parents[p] = p.Parent
		p.Parent = ReplicatedStorage2
	end

	local connection2 = CollectionService:GetInstanceAddedSignal("HideInCutscene"):Connect(onHideInCutsceneObjectAdded)

	for _, v8 in CollectionService:GetTagged("HideInCutscene") do
		task.spawn(onHideInCutsceneObjectAdded, v8)
	end

	function state.CutsceneLoaded(flag: boolean?)
		cutscene.Loading.Visible = false
		local skip = cutscene.Skip
		skip.Visible = (state.Skippable == nil or state.Skippable == true) and state.Name ~= "Horseman"

		if not flag then
			for _, v9 in Players:GetPlayers() do
				task.spawn(hidePlayer, v9)
			end
		end

		for _, v9 in v4 do
			v9.Enabled = false
		end
	end

	local thread2 = task.spawn(function()
		v6(state)
		v.Thread.SafeResume(thread)
	end)
	coroutine.yield()

	for _, v8 in Players:GetPlayers() do
		task.spawn(showPlayer, v8)
	end

	for _, v8 in v4 do
		v8.Enabled = true
	end

	cutscene.Enabled = false
	cutsceneOutside.Enabled = true
	cutscene.Loading.Visible = false
	cutscene.Skip.Visible = false
	connection2:Disconnect()

	for _, v8 in CollectionService:GetTagged("HideInCutscene") do
		local parent = parents[v8]

		if parent and parent:IsDescendantOf(workspace) then
			v8.Parent = parent
		else
			v8:Destroy()
		end
	end

	if v7 then
		v7()
	end

	onClientEventConnection:Disconnect()
	connection:Disconnect()
	activatedConnection:Disconnect()

	while coroutine.status(thread2) == "suspended" do
		v.Thread.SafeResume(thread2, true)
	end

	v.Thread.SafeCancel(thread2)
	return true
end

function CutsceneController:Start()
	remoteFunction.OnClientInvoke = function(p)
		return self:Play(p)
	end

	remoteEvent.OnClientEvent:Connect(function(value: string?)
		cutsceneOutside.Status.Text = value or ""
	end)

	for _, moduleScript in script:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			v5[moduleScript.Name] = require3(moduleScript)
		end
	end
end

return CutsceneController