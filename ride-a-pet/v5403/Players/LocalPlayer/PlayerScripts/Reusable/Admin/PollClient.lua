local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local adminPollUI = playerGui:WaitForChild("AdminPollUI")
adminPollUI.Enabled = false
local adminPoll = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("AdminPoll")
local PollView = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PollView"))
local SoundService = game:GetService("SoundService")
local Audio = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Audio"))
local click = SoundService:WaitForChild("SFX"):WaitForChild("Click")
local choicesById = {}
local changedAtsById = {}
local v = nil
local v2 = nil
local v3 = nil
local v4 = 0
local v5 = nil

local function flush()
	if v or not (v2 and v3) then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if v3.EndsAt <= serverTimeNow then
		v2 = nil
		v5.Acknowledge({
			Id = v3.Id,
			Choice = choicesById[v3.Id],
			Error = "Voting has closed."
		})
	else
		if serverTimeNow < v4 then
			return
		end

		v = v2
		v2 = nil
		v.SentAt = os.clock()
		adminPoll:FireServer("Vote", v.Id, v.Choice)
	end
end

v5 = PollView.new(playerGui, function(id, choice)
	Audio:PlayOnce(click, SoundService)
	v2 = {
		Id = id,
		Choice = choice
	}
	flush()
end)
adminPoll.OnClientEvent:Connect(function(p, state)
	if p == "State" then
		if not state or not v3 or state.Id ~= v3.Id then
			v = nil
			v2 = nil
			v4 = 0
		end

		v3 = state
		v5.Set(state, state and choicesById[state.Id])
	elseif p == "Vote" then
		if not v3 or state.Id ~= v3.Id or state.Sync and (v or v2) or state.ChangedAt and state.ChangedAt < (changedAtsById[state.Id] or -1) then
			return
		end

		if state.ChangedAt then
			changedAtsById[state.Id] = state.ChangedAt
			v4 = state.ChangedAt + 1
		end

		if state.Choice then
			choicesById[state.Id] = state.Choice
		end

		if not state.Sync then
			local v6 = v
			v = nil

			if not v2 and v6 and state.Choice and state.Choice ~= v6.Choice and not state.Error and workspace:GetServerTimeNow() < v3.EndsAt then
				v2 = {
					Id = v6.Id,
					Choice = v6.Choice
				}
			end
		end

		if v2 and v2.Choice == state.Choice then
			v2 = nil
		end

		state.KeepSelection = v2 ~= nil
		v5.Acknowledge(state)
		flush()
	elseif p == "Notice" then
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = "Admin Poll",
				Text = tostring(state),
				Duration = 7
			})
		end)
	end
end)
adminPoll:FireServer("Sync")

while true do
	task.wait(0.1)
	v5.Tick(workspace:GetServerTimeNow())
	flush()

	if not (v and os.clock() - v.SentAt > 3) then
		continue
	end

	v.SentAt = os.clock()
	adminPoll:FireServer("Vote", v.Id, v.Choice)
end