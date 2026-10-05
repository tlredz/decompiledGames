local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Controllers.UI.ShopController)
require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Shared.LTM)
local localPlayer = Players.LocalPlayer
local abilityVoting = localPlayer.PlayerGui:WaitForChild("AbilityVoting")
local vote = abilityVoting.Vote
local remoteEvent = v2:RemoteEvent("UpdateAbilityVotes")
local remoteEvent2 = v2:RemoteEvent("UpdateAbilityVoteSelected")
local children = {}
local AbilityVotingController = {}

function AbilityVotingController:_updateVoting(p)
	if self._timerThread and self._timerThread.Connected then
		self._timerThread:Disconnect()
	end

	if not p then
		return
	end

	if not self._initialized then
		self._initialized = true
		self:_createAbilityFrames()
	end

	if not localPlayer.Character or localPlayer.Character.Parent ~= workspace.Alive then
		return
	end

	self:Open()
	self._timerThread = v3.Every(1, function()
		local replion = v.Client:GetReplion("AbilityVoting")

		if not replion then
			return
		end

		local voteStartTime = replion:Get("VoteStartTime") or 0
		local v5 = math.round(workspace:GetServerTimeNow() - voteStartTime)
		local v6 = 10 - math.max(0, v5)
		vote.Title.Text = string.format("Vote for an ability for everyone to use (%ss)", (tostring(v6)))

		if 10 - v5 < 0 and v4:IsOpen(abilityVoting.Name) then
			self:Close()
		end
	end)
end

function AbilityVotingController:_updateVoteCount(items)
	local v5 = {}

	for _, item in items do
		for _, v6 in item do
			if not v5[v6] then
				v5[v6] = 0
			end

			v5[v6] += 1
		end
	end

	local v6 = items[localPlayer.Name] or {}

	for _, guiObject in vote.ScrollingFrame:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = guiObject.Name
		guiObject.VoteCount.Text = `Votes: {v5[name] or 0}`
		guiObject.SelectedOverlay.Visible = table.find(v6, name) ~= nil
	end
end

function AbilityVotingController:_createAbilityFrames()
	local scrollingFrame = vote.ScrollingFrame
	local template = scrollingFrame.UIGridLayout.Template
	local replion = v.Client:GetReplion("AbilityVoting")
	local blockedAbilities = replion and replion:Get("BlockedAbilities") or {}

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v5 = 0

	for _, v6 in children do
		if blockedAbilities[v6.Name] then
			continue
		end

		local clone = template:Clone()
		clone.Name = v6.Name
		clone.LayoutOrder = v6:GetAttribute("Order") or 1
		clone.Vector.Image = v6:GetAttribute("Icon") or ""
		clone.VoteCount.Text = "Votes: 0"
		local v7 = v6
		clone.Activated:Connect(function()
			local now = os.clock()

			if now - v5 < 0.1 then
				return
			end

			local replion2 = v.Client:GetReplion("AbilityVoting")

			if replion2 and replion2:Find("SelectedAbilities", v7) ~= nil then
				return
			end

			v5 = now
			remoteEvent:FireServer(v7.Name)
		end)
		clone.Parent = scrollingFrame
	end

	task.wait()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCanvas()
		scrollingFrame.CanvasSize = UDim2.fromOffset(0, scrollingFrame.UIGridLayout.AbsoluteContentSize.Y)
	end

	updateCanvas() -- equivalent call inferred; original call site unknown
	scrollingFrame.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
end

function AbilityVotingController:Open()
	vote.Visible = true

	if not v4:IsOpen(abilityVoting.Name) then
		v4:Open(abilityVoting.Name, true)
		v4:Lock(abilityVoting.Name, true)
	end
end

function AbilityVotingController:Close()
	v4:Unlock(abilityVoting.Name)
	v4:Close(abilityVoting.Name)
end

function AbilityVotingController:Start()
	vote.Close.Activated:Connect(function()
		self:Close()
	end)

	for _, child in ReplicatedStorage2.Misc.DataAbilities:GetChildren() do
		if child.Name == "Dash" or child:GetAttribute("Hidden") then
			continue
		end

		table.insert(children, child)
	end

	local scrollingFrame = vote.ScrollingFrame
	local _ = scrollingFrame.UIGridLayout.Template

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v5 = v.Client:WaitReplion("AbilityVoting")
	v5:OnChange("Active", function(flag: boolean)
		self:_updateVoting(flag)
	end)
	v5:OnChange("Votes", function(p)
		self:_updateVoteCount(p)
	end)
	v5:OnChange("BlockedAbilities", function()
		self._initialized = false

		if v5:Get("Active") then
			self:_createAbilityFrames()
			self:_updateVoteCount(v5:Get("Votes") or {})
		end
	end)
	self:_updateVoteCount(v5:GetExpect("Votes"))
	self:_updateVoting(v5:GetExpect("Active"))
	remoteEvent2.OnClientEvent:Connect(function()
		self:Close()
	end)
end

return AbilityVotingController