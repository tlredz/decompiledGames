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
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Controllers.UI.ShopController)
local v6 = require3(ReplicatedStorage2.ServerInfo)
local localPlayer = Players.LocalPlayer
local abilityBanVoting = localPlayer.PlayerGui:WaitForChild("AbilityBanVoting")
local vote = abilityBanVoting.Vote
local abilityBanned = abilityBanVoting.AbilityBanned
local remoteEvent = v2:RemoteEvent("UpdateAbilityBanVotes")
local remoteEvent2 = v2:RemoteEvent("UpdateAbilityBanned")
local children = {}
local AbilityBanVotingController = {}

function AbilityBanVotingController:_updateVoting(p)
	if self._timerThread and self._timerThread.Connected then
		self._timerThread:Disconnect()
	end

	if not p then
		return
	end

	self:Open()
	self._timerThread = v3.Every(1, function()
		local replion = v.Client:GetReplion("AbilityBanVoting")

		if not replion then
			return
		end

		local voteStartTime = replion:Get("VoteStartTime") or 0
		local v7 = 15 - math.max(0, (math.round(workspace:GetServerTimeNow() - voteStartTime)))
		vote.Title.Text = string.format("Vote for an ability to ban (%ss)", (tostring(v7)))
	end)
end

function AbilityBanVotingController:_updateVoteCount(items)
	local v7 = {}

	for _, item in items do
		for _, v8 in item do
			if not v7[v8] then
				v7[v8] = 0
			end

			v7[v8] += 1
		end
	end

	local v8 = items[localPlayer.Name] or {}

	for _, guiObject in vote.ScrollingFrame:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = guiObject.Name
		guiObject.VoteCount.Text = `Votes: {v7[name] or 0}`
		guiObject.SelectedOverlay.Visible = table.find(v8, name) ~= nil
	end
end

function AbilityBanVotingController:_updateBannedAbilities(_)
	local v7 = v.Client:WaitReplion("AbilityBanVoting")

	for _, guiObject in vote.ScrollingFrame:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local visible = v7:Find("BannedAbilities", guiObject.Name) ~= nil
		guiObject.DisabledOverlay.Visible = visible
		guiObject.Active = not visible
		guiObject.Selectable = not visible
	end
end

function AbilityBanVotingController:_createAbilityFrames()
	local scrollingFrame = vote.ScrollingFrame
	local template = scrollingFrame.UIGridLayout.Template

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v7 = 0

	for _, v8 in children do
		local clone = template:Clone()
		clone.Name = v8.Name
		clone.LayoutOrder = v8:GetAttribute("Order") or 1
		clone.Vector.Image = v8:GetAttribute("Icon") or ""
		clone.VoteCount.Text = "Votes: 0"
		local v9 = v8
		clone.Activated:Connect(function()
			local now = os.clock()

			if now - v7 < 0.1 then
				return
			end

			local replion = v.Client:GetReplion("AbilityBanVoting")

			if replion and replion:Find("BannedAbilities", v9) ~= nil then
				return
			end

			v7 = now
			remoteEvent:FireServer(v9.Name)
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

function AbilityBanVotingController:Open()
	vote.Visible = true
	abilityBanned.Visible = false

	if not v4:IsOpen(abilityBanVoting.Name) then
		v4:Open(abilityBanVoting.Name, true)
		v4:Lock(abilityBanVoting.Name, true)
	end
end

function AbilityBanVotingController:Close()
	v4:Unlock(abilityBanVoting.Name)
	v4:Close(abilityBanVoting.Name)
end

function AbilityBanVotingController:Start()
	vote.Close.Activated:Connect(function()
		self:Close()
	end)

	for _, child in ReplicatedStorage2.Misc.DataAbilities:GetChildren() do
		if child.Name == "Dash" or child:GetAttribute("Hidden") then
			continue
		end

		table.insert(children, child)
	end

	self:_createAbilityFrames()

	if not (v6.isRankedMatchServer() or v6.isNoAbilityRankedMatchServer() or v6.isClanWarServer() or v6.isDuelMatchServer()) then
		return
	end

	local v7 = v.Client:WaitReplion("AbilityBanVoting")

	if not v7 then
		return
	end

	v7:OnChange("Active", function(flag: boolean)
		self:_updateVoting(flag)
	end)
	v7:OnChange("Votes", function(p)
		self:_updateVoteCount(p)
	end)
	v7:OnChange("BannedAbilities", function(p)
		self:_updateBannedAbilities(p)
	end)
	self:_updateVoteCount(v7:GetExpect("Votes"))
	self:_updateVoting(v7:GetExpect("Active"))
	self:_updateBannedAbilities(v7:GetExpect("BannedAbilities"))

	local function _openShop()
		self:Close()
		v5:Open()
		v5:GoTo("Ability", true)
	end

	abilityBanned.SelectAbility.Activated:Connect(_openShop)
	abilityBanned.Close.Activated:Connect(_openShop)
	remoteEvent2.OnClientEvent:Connect(function(items)
		v.Client:WaitReplion("Data")
		local equipped = client:GetEquipped("Ability")
		local name = equipped and equipped.Name or "Dash"
		local v8 = false

		for _, childName in items do
			v5:_updateItemStatus("Ability", childName)

			if name ~= childName then
				continue
			end

			v8 = true
			vote.Visible = false
			local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(childName)
			local v9

			if child then
				v9 = child:GetAttribute("Icon")
			end

			abilityBanned.Ability.Vector.Image = v9 or ""
			abilityBanned.Visible = true
		end

		if not v8 then
			self:Close()
		end
	end)
end

return AbilityBanVotingController