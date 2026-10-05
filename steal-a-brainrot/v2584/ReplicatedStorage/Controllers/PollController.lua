local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Timer = require(ReplicatedStorage.Packages.Timer)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.Poll)
local localPlayer = Players.LocalPlayer
local poll = localPlayer.PlayerGui:WaitForChild("TopUI").Frame.Poll
local polls = ReplicatorClient.get("Polls")
return {
	Start = function(_)
		polls:WaitForLoaded()
		local flag = false
		local fill1Text = poll.Bar.Fill1Text
		local fill2Text = poll.Bar.Fill2Text
		local A = 0
		local B = 0
		local A2 = 0
		local B2 = 0
		local v = 0
		local v2 = 0
		local v3 = nil
		poll.Visible = false

		local function refreshPollData()
			local v4 = polls:TryIndex({ "activePoll" })
			local v5 = v4 and polls:TryIndex({ "polls", v4 })

			if v5 then
				if not flag then
					flag = true
					poll.Visible = true
				end

				if v3 ~= v4 then
					v3 = v4
					A2 = v5.votes.A
					B2 = v5.votes.B
					poll.Bar.Fill.UIGradient.Color = ColorSequence.new(Color3.fromHex(v5.option1colorHex or "2197ff"))
					poll.Bar.BackgroundColor3 = Color3.fromHex(v5.option2colorHex or "da261a")
					poll.Buttons["1"].BackgroundColor3 = Color3.fromHex(v5.option1colorHex or "2197ff")
					poll.Buttons["2"].BackgroundColor3 = Color3.fromHex(v5.option2colorHex or "da261a")
				end

				A = v5.votes.A
				B = v5.votes.B
				local serverTimeNow = workspace:GetServerTimeNow()
				local v6 = v5.endsAt <= serverTimeNow
				poll.Buttons["1"].Function.Text = v5.option1
				poll.Buttons["2"].Function.Text = v5.option2

				if v6 then
					A2 = v5.votes.A
					B2 = v5.votes.B
					v = 0
					v2 = 0
					poll.Template.Text = v5.text
					Spr.target(poll.Buttons["1"].Disabled, 1, 5, {
						BackgroundTransparency = 0.5
					})
					Spr.target(poll.Buttons["2"].Disabled, 1, 5, {
						BackgroundTransparency = 0.5
					})
				else
					local v7 = math.max(0, (v5.endsAt - serverTimeNow) // 1)
					poll.Template.Text = `{v5.text} ({v7}s)`
					local v8 = v5.voted[tostring(localPlayer.UserId)]

					if v8 then
						Spr.target(poll.Buttons["1"].Disabled, 1, 5, {
							BackgroundTransparency = v8 == "A" and 1 or 0.5
						})
						Spr.target(poll.Buttons["2"].Disabled, 1, 5, {
							BackgroundTransparency = v8 == "B" and 1 or 0.5
						})
					else
						Spr.target(poll.Buttons["1"].Disabled, 1, 5, {
							BackgroundTransparency = 1
						})
						Spr.target(poll.Buttons["2"].Disabled, 1, 5, {
							BackgroundTransparency = 1
						})
					end
				end
			elseif flag then
				flag = false
				poll.Visible = false
				v3 = nil
			end
		end

		local v4 = -1
		local v5 = -1
		local v6 = -1
		local v7 = -1
		RunService.Heartbeat:Connect(function(dt)
			if not flag then
				return
			end

			if A ~= v4 then
				v4 = A
				local v8 = A - A2
				v = math.abs(v8) < 1 and 0 or v8 / 0.4
			end

			if B ~= v5 then
				v5 = B
				local v8 = B - B2
				v2 = math.abs(v8) < 1 and 0 or v8 / 0.4
			end

			if math.abs(A - A2) >= 1 then
				A2 += v * dt

				if v > 0 then
					A2 = math.min(A2, A)
				elseif v < 0 then
					A2 = math.max(A2, A)
				end
			else
				A2 = A
			end

			if math.abs(B - B2) >= 1 then
				B2 += v2 * dt

				if v2 > 0 then
					B2 = math.min(B2, B)
				elseif v2 < 0 then
					B2 = math.max(B2, B)
				end
			else
				B2 = B
			end

			local v8 = math.round(A2)
			local v9 = math.round(B2)

			if v8 ~= v6 or v9 ~= v7 then
				v6 = v8
				v7 = v9
				fill1Text.Text = NumberUtils:Comma(v8)
				fill2Text.Text = NumberUtils:Comma(v9)
				local v10 = v8 + v9
				local v11 = v10 == 0 and 0.5 or v8 / v10
				Spr.target(poll.Bar.Fill.UIGradient, 1, 5, {
					Offset = Vector2.new(math.lerp(-0.5, 0.5, v11), 0)
				})
			end
		end)
		poll.Buttons["1"].Activated:Connect(function()
			local v8 = polls:TryIndex({ "activePoll" })

			if not v8 then
				return
			end

			local v9 = polls:TryIndex({ "polls", v8 })

			if not v9 or workspace:GetServerTimeNow() >= v9.endsAt or v9.voted[tostring(localPlayer.UserId)] and not v9.allowSwitch then
				return
			end

			Net:RemoteEvent("PollService/Vote"):FireServer(
				"f0cc8bf6-d60f-4619-9393-dd7704297307",
				v8,
				"cd92dbcd-1a45-4bb7-9d1f-b54e53f7bf56"
			)
		end)
		poll.Buttons["2"].Activated:Connect(function()
			local v8 = polls:TryIndex({ "activePoll" })

			if not v8 then
				return
			end

			local v9 = polls:TryIndex({ "polls", v8 })

			if not v9 or workspace:GetServerTimeNow() >= v9.endsAt or v9.voted[tostring(localPlayer.UserId)] and not v9.allowSwitch then
				return
			end

			Net:RemoteEvent("PollService/Vote"):FireServer(
				"f0cc8bf6-d60f-4619-9393-dd7704297307",
				v8,
				"05d09b65-9aba-43d6-92ed-63696cb7bfd4"
			)
		end)
		local fn = nil
		polls:Observe({ "activePoll" }, function(p)
			if fn then
				fn()
				fn = nil
			end

			if p then
				local v8 = polls:Observe({ "polls", p }, refreshPollData)
				local connection = Timer.Simple(1, refreshPollData, true)

				fn = function()
					v8()
					connection:Disconnect()
				end
			elseif flag then
				flag = false
				poll.Visible = false
			end
		end)
	end
}