local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
Random.new()
local partyVoteFrame = Client.Interface.PartyVoteFrame
local v = nil

function UpdateVotePoll(items)
	local total = 0

	for _, item in pairs(items) do
		total += item
	end

	for i = 1, 4 do
		local bar = partyVoteFrame["Vote" .. i].Bar
		local v2 = items[tostring(i)] or 0
		local v3 = not (total > 0) and 0 or v2 / total
		bar.Size = UDim2.new(v3, 0, 1, 0)
		local shortNumber = Client.Utility.GetShortNumber(v2)
		partyVoteFrame["Vote" .. i].TotalVotes.Text = shortNumber
	end
end

Client.Events.UpdateVotePoll:Connect(function(p)
	UpdateVotePoll(p)
end)
Client.Events.HideVotePoll:Connect(function(_)
	partyVoteFrame.Visible = false
end)
Client.Events.SetUpVotePoll:Connect(function(text, text2, text3, text4, text5)
	v = nil
	partyVoteFrame.QuestionLabel.Text = text

	if text2 then
		partyVoteFrame.Vote1.QuestionLabel.Text = text2
		partyVoteFrame.Vote1.Visible = true
	else
		partyVoteFrame.Vote1.Visible = false
	end

	if text3 then
		partyVoteFrame.Vote2.QuestionLabel.Text = text3
		partyVoteFrame.Vote2.Visible = true
	else
		partyVoteFrame.Vote2.Visible = false
	end

	if text4 then
		partyVoteFrame.Vote3.QuestionLabel.Text = text4
		partyVoteFrame.Vote3.Visible = true
	else
		partyVoteFrame.Vote3.Visible = false
	end

	if text5 then
		partyVoteFrame.Vote4.QuestionLabel.Text = text5
		partyVoteFrame.Vote4.Visible = true
	else
		partyVoteFrame.Vote4.Visible = false
	end

	UpdateVotePoll({})
	partyVoteFrame.Visible = true
end)

function UpdateVoteSelection()
	for i = 1, 4 do
		local v2 = partyVoteFrame["Vote" .. i]

		if i == v then
			v2.BackgroundColor3 = Color3.fromRGB(13, 75, 3)
			v2.Bar.BackgroundColor3 = Color3.fromRGB(20, 182, 11)
		else
			v2.BackgroundColor3 = Color3.fromRGB(4, 14, 75)
			v2.Bar.BackgroundColor3 = Color3.fromRGB(10, 36, 182)
		end
	end
end

for i = 1, 4 do
	local v2 = i
	partyVoteFrame["Vote" .. i].MouseButton1Click:Connect(function()
		if v and not RunService:IsStudio() then
			return
		end

		v = v2
		UpdateVoteSelection()
		Client.Events.RegisterVote:FireServer(v2)
	end)
end

return {}