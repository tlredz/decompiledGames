local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Shared.GameModes)
local v4 = require3(ReplicatedStorage2.Shared.LTM)
local v5 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
Color3.fromRGB(255, 255, 255)
Color3.fromRGB(255, 255, 255)
local localPlayer = Players.LocalPlayer
local voter = localPlayer.PlayerGui:WaitForChild("voter")
local frame = voter.Frame
local v6 = {
	Default = frame.LTM
}

for _, v7 in v4.getProfiles() do
	local id = v7.Id
	local v8

	if v7.LobbyLTM then
		v8 = frame:FindFirstChild(v7.Id)
	else
		v8 = v6.Default
	end

	v6[id] = v8

	if not v7.LobbyLTM or v6[v7.Id] then
		continue
	end

	warn("[!] [voter] Could not find special voting button for lobby LTM! Missing button:", v7.Id)
end

local v7 = { frame["1"], frame["2"], frame["3"] }
local v8 = { frame["1"].Position, frame["2"].Position, frame["3"].Position }
local remoteEvent = v2:RemoteEvent("UpdateVotes")
local VotingController = {}
local v9 = nil

function VotingController:_updateVoting(flag: boolean?)
	if flag ~= nil then
		v9 = flag
	end

	voter.Enabled = v9 and not (v5.IsUICovered.CurrentState or workspace:GetAttribute("NotStartMatch"))
end

v5.IsUICovered.StateChanged:Connect(function()
	VotingController:_updateVoting()
end)

function VotingController:_updateModes(items)
	local clone = table.clone(v7)

	for k, item in items do
		local default = v6[item]

		if not default and v4.getLTM(item) then
			local LTM = v4.getLTM(item)
			default = v6.Default
			local text = default.Text

			if LTM then
				item = LTM.getModeName() or item
			end

			text.Text = item
		end

		if default then
			clone[k] = default
		end
	end

	for _, button in frame:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local index = table.find(clone, button)
		local visible = index ~= nil

		if index ~= nil then
			button.Position = v8[index]
		end

		button.Name = visible and tostring(index) or "Disabled"
		button.Visible = visible

		if visible then
			continue
		end

		button.Check.Visible = false
		button.Counter.Texter.Text = "0"
	end

	for childName, item in items do
		local child = frame:FindFirstChild(childName)

		if not child then
			continue
		end

		local mode = v3.Modes[item]

		if not mode or v6[item] then
			continue
		end

		local text_2 = child:FindFirstChild("Text")
		text_2.Text = mode.DisplayName
	end

	local replion = v.Client:GetReplion("Voting")

	if not replion then
		return
	end

	self:_updateVoteCount(replion:GetExpect("Votes"))
end

function VotingController:_getVoteCount()
	local result = {
		FFA = 0,
		["2Teams"] = 0,
		["4Teams"] = 0,
		Randomizer = 0,
		NoAbilityFFA = 0
	}

	for _, v10 in v4.getProfiles() do
		if v10.IsActive(true) then
			result[v10.Id] = 0
		end
	end

	return result
end

function VotingController:_updateVoteCount(items)
	local _getVoteCount = VotingController:_getVoteCount()
	local v10 = nil

	for k, item in items do
		if k == localPlayer then
			v10 = item
		end

		_getVoteCount[item] = (_getVoteCount[item] or 0) + 1
	end

	local replion = v.Client:GetReplion("Voting")

	if not replion then
		return
	end

	local modes = replion:Get("Modes")

	for k, text in _getVoteCount do
		local index = table.find(modes, k)

		if not index then
			continue
		end

		local child = frame:FindFirstChild(index)

		if not child then
			continue
		end

		child.Counter.Texter.Text = text
		child.Check.Visible = false

		if v10 and v10 == k then
			child.Check.Visible = true
		end
	end
end

function VotingController:Start()
	local v10 = v.Client:WaitReplion("Voting")
	local v11 = 0

	for _, button in frame:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v12 = button
		button.Activated:Connect(function()
			local now = os.clock()

			if now - v11 < 0.1 then
				return
			end

			v11 = now
			local name = tonumber(v12.Name)
			local v13 = v10:GetExpect("Modes")[name]
			print(v13, v12, "--------------------------")
			remoteEvent:FireServer(v13)
		end)
	end

	v10:OnChange("Active", function(flag: boolean)
		self:_updateVoting(flag)
	end)
	workspace:GetAttributeChangedSignal("NotStartMatch"):Connect(function()
		self:_updateVoting(v10:GetExpect("Active"))
	end)
	v10:OnChange("Votes", function(p)
		self:_updateVoteCount(p)
	end)
	v10:OnChange("Modes", function(p)
		self:_updateModes(p)
	end)
	self:_updateVoteCount(v10:GetExpect("Votes"))
	self:_updateVoting(v10:GetExpect("Active"))
	self:_updateModes(v10:GetExpect("Modes"))
end

return VotingController