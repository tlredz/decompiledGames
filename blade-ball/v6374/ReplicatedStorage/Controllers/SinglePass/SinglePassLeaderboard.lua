local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Packages.Reliever)
local v4 = require3(ReplicatedStorage2.Shared.SinglePass.SinglePassLeaderboard)
local v5 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v6 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v7 = nil
local v8 = nil
local singlePass = Players.LocalPlayer.PlayerGui:WaitForChild("SinglePass")
local leaderboard = singlePass.MainFrame.Main.Pages.Leaderboard
local template = leaderboard.ScrollingFrame.Template
template.Parent = nil
local v9 = v2.new()
local SinglePassLeaderboard = {
	Start = function(_)
		v7 = v.Client:WaitReplion("Data")
		v8 = v.Client:WaitReplion("SinglePassLeaderboard")

		for i, v10 in ipairs(v4) do
			local reward = v10.Rewards[1]
			local formatted = `Item{#v4 - i + 1}`
			local child = template.Holder.Rewards:FindFirstChild(formatted)

			if child then
				child.Vector.Image = reward.Icon or ""
			end
		end

		local v10 = true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isLeaderboardVisible()
			return singlePass.Enabled and leaderboard.Visible
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestUpdate()
			if v10 and isLeaderboardVisible() then
				v10 = false
				task.spawn(UpdateLeaderboard)
			end
		end

		v8:OnChange("Leaderboard", function()
			v10 = true
			requestUpdate() -- equivalent call inferred; original call site unknown
		end)
		singlePass:GetPropertyChangedSignal("Enabled"):Connect(requestUpdate)
		leaderboard:GetPropertyChangedSignal("Visible"):Connect(requestUpdate)
		requestUpdate() -- equivalent call inferred; original call site unknown
	end
}
local count = 0

function UpdateLeaderboard()
	count += 1
	local v10 = count
	v9:Clean()
	local expect = v8:GetExpect("Leaderboard")

	for k, v11 in expect do
		v3.relieve()

		if v10 ~= count then
			break
		end

		local clone = v9:Clone(template)
		clone.Holder.ProfilePicture.Placement.Text = `#{k}`
		clone.Holder.Rewards.Item3.Visible = k <= 3
		clone.Holder.Rewards.Item2.Visible = k <= 10
		clone.Holder.Rewards.Item1.Visible = k <= 25
		clone.Holder.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={math.abs(v11.UserId)}&w=100&h=100`
		clone.Holder.KillsCounter.Text = v5:AddCommas(v11.Kills)
		clone.Holder.Username.PlayerUsername1.Text = "[Loading...]"
		v9:AddPromise(v6:GetDisplayName(v11.UserId)):andThen(function(text: string)
			clone.Holder.Username.PlayerUsername1.Text = text
		end)
		clone.Holder.Username.PlayerUsername2.Text = `@{v11.Name}`
		clone.Parent = leaderboard.ScrollingFrame
	end
end

return SinglePassLeaderboard