local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = require3("@game/ReplicatedStorage/Packages/Charm")
local v2 = require3("@game/ReplicatedStorage/Packages/Replion")
local v3 = require3("@game/ReplicatedStorage/Packages/Trove")
local v4 = require3("@game/ReplicatedStorage/Packages/Net")
local v5 = require3("@game/ReplicatedStorage/Packages/Observers")
local v6 = require3("@game/ReplicatedStorage/Common/Utils")
require3("@game/ReplicatedStorage/Shared/Polls")
local v7 = require3("@game/ReplicatedStorage/Shared/ReplionUtils")
local v8 = require3("@game/ReplicatedStorage/ClientGameModules/GuiHandler")
local spring = v6.Spring
local remoteEvent = v4:RemoteEvent("Polls/Vote")
local conceptsUI = Players.LocalPlayer.PlayerGui.ConceptsUI
local concepts = conceptsUI.Concepts
local zoomedIn = conceptsUI.ZoomedIn
local conceptBox = concepts.Selection.UIGridLayout.ConceptBox
local v9 = nil
local v10 = nil
local v11 = {}
local v12 = {}
local atom = v.atom(nil)
local PollController = {}

local function formatRatio(p: number, p2: number)
	if p == 0 and p2 == 0 then
		return "0"
	end

	local v13 = math.max(p, p2)
	local v14 = math.min(p, p2)

	if v14 == 0 then
		return (tostring(v13))
	end

	local v15 = v13 / v14
	local v16 = math.round(v15)

	if math.abs(v15 - v16) >= 0.1 then
		return string.format("%.1f", v15)
	end

	return (tostring(v16))
end

local function reorderPolls()
	table.sort(v12, function(a, b)
		return a.votes > b.votes
	end)
end

function PollController:_setupPoll(name: string)
	if v11[name] then
		return
	end

	local maid = v3.new()
	v11[name] = maid
	local v13 = {
		votes = 0,
		pollId = name
	}
	table.insert(v12, v13)
	local clone = maid:Clone(conceptBox)
	clone.Name = name
	clone.Parent = concepts.Selection
	local a = 0
	local b = 0
	local v14 = 0
	local v15 = 0
	local v16 = 0
	local v17 = 0

	local function updatePollData()
		local v18 = v9:Get({ "polls", name })

		if not v18 then
			return
		end

		if atom() == name then
			zoomedIn.ConceptBox.ConceptDecal.Image = v18.image
		end

		clone.ConceptDecal.Image = v18.image
		a = v18.votes.a
		b = v18.votes.b
		v13.votes = a + b
		local v19 = v10:Get({ "PollVotes", name })

		if v19 then
			local target = spring.target
			local like = clone.Voting.Like
			local imageColor

			if v19 == "a" then
				imageColor = Color3.fromRGB(255, 255, 255)
			else
				imageColor = Color3.fromRGB(150, 150, 150)
			end

			target(like, 1, 5, {
				ImageColor3 = imageColor
			})
			local target2 = spring.target
			local dislike = clone.Voting.Dislike
			local imageColor2

			if v19 == "b" then
				imageColor2 = Color3.fromRGB(255, 255, 255)
			else
				imageColor2 = Color3.fromRGB(150, 150, 150)
			end

			target2(dislike, 1, 5, {
				ImageColor3 = imageColor2
			})

			if atom() == name then
				local target3 = spring.target
				local like2 = zoomedIn.Voting.Like
				local imageColor3

				if v19 == "a" then
					imageColor3 = Color3.fromRGB(255, 255, 255)
				else
					imageColor3 = Color3.fromRGB(150, 150, 150)
				end

				target3(like2, 1, 5, {
					ImageColor3 = imageColor3
				})
				local target4 = spring.target
				local dislike2 = zoomedIn.Voting.Dislike
				local imageColor4

				if v19 == "b" then
					imageColor4 = Color3.fromRGB(255, 255, 255)
				else
					imageColor4 = Color3.fromRGB(150, 150, 150)
				end

				target4(dislike2, 1, 5, {
					ImageColor3 = imageColor4
				})
			end
		end

		task.defer(reorderPolls)
	end

	maid:Add(v7.observeReplionPath(v9, { "polls", name }, updatePollData))
	maid:Add(v7.observeReplionPath(v10, { "PollVotes", name }, updatePollData))
	maid:Add(clone.Voting.Like.Activated:Connect(function()
		remoteEvent:FireServer(name, "a")
	end))
	maid:Add(clone.Voting.Dislike.Activated:Connect(function()
		remoteEvent:FireServer(name, "b")
	end))
	maid:Add(clone.Expand.Activated:Connect(function()
		atom(name)
		updatePollData()
	end))
	maid:Add(function()
		local index = table.find(v12, v13)

		if not index then
			return
		end

		table.remove(v12, index)
	end)
	local v18 = -1
	local v19 = -1
	local v20 = -1
	local v21 = -1
	local v22 = false
	maid:Add(RunService.Heartbeat:Connect(function(dt)
		if a ~= v18 then
			v18 = a
			local v23 = a - v14
			v16 = math.abs(v23) < 1 and 0 or v23 / 0.4
		end

		if b ~= v19 then
			v19 = b
			local v23 = b - v15
			v17 = math.abs(v23) < 1 and 0 or v23 / 0.4
		end

		if math.abs(a - v14) >= 1 then
			v14 += v16 * dt

			if v16 > 0 then
				v14 = math.min(v14, a)
			elseif v16 < 0 then
				v14 = math.max(v14, a)
			end
		else
			v14 = a
		end

		if math.abs(b - v15) >= 1 then
			v15 += v17 * dt

			if v17 > 0 then
				v15 = math.min(v15, b)
			elseif v17 < 0 then
				v15 = math.max(v15, b)
			end
		else
			v15 = b
		end

		local v23 = math.round(v14)
		local v24 = math.round(v15)
		local v25 = v22
		v22 = atom() == name

		if v23 ~= v20 or v24 ~= v21 or v22 and not v25 then
			v20 = v23
			v21 = v24
			local v26 = v23 + v24

			if v26 ~= 0 then
				local _ = v23 / v26
			end

			if v26 ~= 0 then
				local _ = v24 / v26
			end

			clone.VoteCounter.Description.Text = `{v6.ValueConvertor:AddCommas(v26)} Votes`
			clone.Voting.Like.Title.Text = v6.ValueConvertor:AddCommas(v23)
			clone.Voting.Dislike.Title.Text = v6.ValueConvertor:AddCommas(v24)

			if v23 == 0 and v24 == 0 then
				clone.Voting.Ratio.Good.Text = "0"
				clone.Voting.Ratio.Bad.Text = "0"
			elseif v24 <= v23 then
				clone.Voting.Ratio.Good.Text = formatRatio(v23, v24)
				clone.Voting.Ratio.Bad.Text = "1"
			else
				clone.Voting.Ratio.Good.Text = "1"
				clone.Voting.Ratio.Bad.Text = formatRatio(v23, v24)
			end

			if v22 then
				zoomedIn.VoteCounter.Description.Text = clone.VoteCounter.Description.Text
				zoomedIn.Voting.Like.Title.Text = clone.Voting.Like.Title.Text
				zoomedIn.Voting.Dislike.Title.Text = clone.Voting.Dislike.Title.Text
				zoomedIn.Voting.Ratio.Good.Text = clone.Voting.Ratio.Good.Text
				zoomedIn.Voting.Ratio.Bad.Text = clone.Voting.Ratio.Bad.Text
			end
		end
	end))
end

function PollController.Start(_)
	v9 = v2.Client:WaitReplion("Polls")
	v10 = v2.Client:WaitReplion("Data")
	v.effect(function()
		local v13 = atom()
		concepts.Visible = v13 == nil
		zoomedIn.Visible = v13 ~= nil
	end)
	zoomedIn.Voting.Like.Activated:Connect(function()
		local v13 = atom()

		if not v13 then
			return
		end

		remoteEvent:FireServer(v13, "a")
	end)
	zoomedIn.Voting.Dislike.Activated:Connect(function()
		local v13 = atom()

		if not v13 then
			return
		end

		remoteEvent:FireServer(v13, "b")
	end)
	concepts.Close.Activated:Connect(function()
		v8:Close(conceptsUI.Name)
	end)
	zoomedIn.Close.Activated:Connect(function()
		atom(nil)
	end)

	local function updatePollIndex(p: number)
		local v13 = atom()
		local v14 = nil

		for k, v16 in v12 do
			if v16.pollId ~= v13 then
				continue
			end

			v14 = k
			break
		end

		local v16 = v14 or 1
		local v17

		if v16 + p > #v12 then
			v17 = 1
		elseif v16 + p < 1 then
			v17 = #v12
		else
			v17 = v16 + p
		end

		atom(v12[v17].pollId)
	end

	zoomedIn.ConceptBox.Right.Activated:Connect(function()
		updatePollIndex(1)
	end)
	zoomedIn.ConceptBox.Left.Activated:Connect(function()
		updatePollIndex(-1)
	end)
	v7.observeReplionPath(v9, "polls", function(items)
		for k in items do
			PollController:_setupPoll(k)
		end

		for k in v11 do
			if items[k] then
				continue
			end

			v11[k]:Destroy()
			v11[k] = nil
		end
	end)
	v5.observeTag("PollNPC", function(instance)
		local connection = v7.observeReplionPath(v9, "polls", function(items)
			if items and next(items) then
				instance:SetAttribute("EndTime", nil)
				return
			end

			instance:SetAttribute("EndTime", 0)

			if v8:IsOpen(conceptsUI.Name) then
				v8:Close(conceptsUI.Name)
				atom(nil)
			end
		end)
		return function()
			connection:Disconnect()
		end
	end)
end

return PollController