local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatorClient = require(ReplicatedStorage.client.modules.ReplicatorClient)
local module = require("./InputController")
local poll_vote = ReplicatedStorage:WaitForChild("events"):WaitForChild("poll_vote")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function comma(p: number)
	local v = tostring(p)
	local v2 = -1

	while v2 ~= 0 do
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	end

	return v
end

local function safeHex(p: string?, p2: string)
	local success, result = pcall(Color3.fromHex, p or p2)

	if not success then
		result = Color3.fromHex(p2)
	end

	return result
end

return {
	Start = function(_)
		local polls = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("Polls")
		local pollTemplate = polls:WaitForChild("PollTemplate")
		local uIScale = polls:FindFirstChild("UIScale")

		if uIScale then
			module.Observe(function(p: string)
				uIScale.Scale = p == "Touch" and 0.85 or 1
			end)
		end

		local polls2 = ReplicatorClient.get("Polls")
		polls2:WaitForLoaded()
		local v = nil
		local v2 = nil
		local v3 = {}
		local A = 0
		local B = 0
		local A2 = 0
		local B2 = 0
		local v4 = 0
		local v5 = 0
		local v6 = -1
		local v7 = -1
		local v8 = -1
		local v9 = -1
		local v10 = 0.5
		local v11 = -1
		local v12 = nil
		local v13 = {}
		local v14 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopWinnerBlink()
			for _, v15 in v13 do
				v15:Cancel()
			end

			table.clear(v13)
			v14 = nil
		end

		local function startWinnerBlink(instance, p: string)
			local buttons = instance:FindFirstChild("Buttons")
			local bar = instance:FindFirstChild("Bar")
			local child = buttons:FindFirstChild(p == "A" and "Option1" or "Option2")
			local child2 = bar:FindFirstChild(p == "A" and "CountA" or "CountB")
			local hover = child:FindFirstChild("hover")
			local border = child:FindFirstChild("border")
			local stroke = child2:FindFirstChild("stroke")
			hover.ImageTransparency = 0.85
			border.Transparency = 0
			child2.TextTransparency = 0
			stroke.Transparency = 0.36

			for _, v15 in {
				TweenService:Create(hover, tweenInfo, {
					ImageTransparency = 0.45
				}),
				TweenService:Create(border, tweenInfo, {
					Transparency = 0.6
				}),
				TweenService:Create(child2, tweenInfo, {
					TextTransparency = 0.55
				}),
				TweenService:Create(stroke, tweenInfo, {
					Transparency = 0.8
				})
			} do
				v15:Play()
				table.insert(v13, v15)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getPoll(p: string?)
			if p then
				return (polls2:TryIndex({ "polls", p }))
			end

			return nil
		end

		local function destroyCurrentFrame()
			local v15 = v2

			if not v15 then
				return
			end

			v2 = nil
			v = nil
			v12 = nil
			stopWinnerBlink() -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(v15:FindFirstChild("UIScale"), tweenInfo3, {
				Scale = 0.4
			})
			tween.Completed:Once(function()
				v15:Destroy()
			end)
			tween:Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setButtonEnabled(p, flag: boolean)
			p.Active = flag
			p.AutoButtonColor = flag
			p.Selectable = flag
		end

		local now = 0

		local function doPollVote(vote: string)
			local v15 = v
			local poll = getPoll(v15) -- equivalent call inferred; original call site unknown

			if not (v15 and poll) or workspace:GetServerTimeNow() >= poll.endsAt or poll.voted[tostring(localPlayer.UserId)] and not poll.allowSwitch then
				return
			end

			if os.clock() - now < 1 then
				return
			end

			now = os.clock()
			poll_vote:FireServer(v15, vote)
		end

		local function refreshPollData()
			local poll = getPoll(v) -- equivalent call inferred; original call site unknown
			local v16 = v2

			if not (poll and v16) then
				return
			end

			A = poll.votes.A
			B = poll.votes.B
			local title = v16:FindFirstChild("Title")
			local buttons = v16:FindFirstChild("Buttons")
			local option1 = buttons:FindFirstChild("Option1")
			local option2 = buttons:FindFirstChild("Option2")
			option1.Text = `[{poll.option1}]`
			option2.Text = `[{poll.option2}]`
			local serverTimeNow = workspace:GetServerTimeNow()
			local v17 = poll.endsAt <= serverTimeNow

			if v17 then
				A2 = poll.votes.A
				B2 = poll.votes.B
				v4 = 0
				v5 = 0
				title.Text = poll.text
			else
				local v18 = math.max(0, (poll.endsAt - serverTimeNow) // 1)
				title.Text = `{poll.text} ({v18}s)`
			end

			local v18 = poll.voted[tostring(localPlayer.UserId)]
			local v19 = not v17 and (not v18 or poll.allowSwitch == true)
			setButtonEnabled(option1, v19) -- equivalent call inferred; original call site unknown
			setButtonEnabled(option2, v19) -- equivalent call inferred; original call site unknown
			local v20

			if v17 and poll.votes.A ~= poll.votes.B then
				v20 = poll.votes.A > poll.votes.B and "A" or "B"
			end

			if v20 and v14 ~= v then
				v14 = v
				startWinnerBlink(v16, v20)
			end

			for _, v21 in {
				{
					button = option1,
					vote = "A"
				},
				{
					button = option2,
					vote = "B"
				}
			} do
				if not (v14 ~= v or v20 ~= v21.vote) then
					continue
				end

				local border = v21.button:FindFirstChild("border")
				local hover = v21.button:FindFirstChild("hover")
				local v22 = v18 == v21.vote
				TweenService:Create(border, tweenInfo3, {
					Transparency = v22 and 0 or 0.36,
					Thickness = v22 and 2.5 or 1
				}):Play()
				TweenService:Create(hover, tweenInfo3, {
					ImageTransparency = v22 and 0.7 or 1
				}):Play()
				TweenService:Create(v21.button, tweenInfo3, {
					TextTransparency = v17 and not v22 and 0.45 or 0
				}):Play()
			end
		end

		local function showPoll(value: string, poll)
			if v2 then
				v2:Destroy()
				v2 = nil
			end

			stopWinnerBlink() -- equivalent call inferred; original call site unknown
			v = value
			A2 = poll.votes.A
			B2 = poll.votes.B
			A = A2
			B = B2
			v4 = 0
			v5 = 0
			v6 = -1
			v7 = -1
			v8 = -1
			v9 = -1
			local clone = pollTemplate:Clone()
			clone.Name = "CurrentPoll"
			local option1colorHex = poll.option1colorHex
			local success, result = pcall(Color3.fromHex, option1colorHex or "2197ff")

			if not success then
				result = Color3.fromHex("2197ff")
			end

			local option2colorHex = poll.option2colorHex
			local success2, result2 = pcall(Color3.fromHex, option2colorHex or "da261a")

			if not success2 then
				result2 = Color3.fromHex("da261a")
			end

			local lerped = result:Lerp(Color3.new(1, 1, 1), 0.4)
			local lerped2 = result2:Lerp(Color3.new(1, 1, 1), 0.4)
			local bar = clone:FindFirstChild("Bar")
			local fill = bar:FindFirstChild("Fill")
			bar.BackgroundColor3 = result2
			fill.BackgroundColor3 = result
			local v15 = A2 + B2
			v10 = v15 < 1 and 0.5 or A2 / v15
			v11 = -1
			fill.Size = UDim2.fromScale(v10, 1)
			v12 = fill
			local buttons = clone:FindFirstChild("Buttons")

			for _, v16 in {
				{
					name = "Option1",
					color = lerped,
					vote = "A"
				},
				{
					name = "Option2",
					color = lerped2,
					vote = "B"
				}
			} do
				local child = buttons:FindFirstChild(v16.name)
				local border = child:FindFirstChild("border")
				local hover = child:FindFirstChild("hover")
				child.TextColor3 = v16.color
				border.Color = v16.color
				hover.ImageColor3 = v16.color
				local v17 = v16
				child.Activated:Connect(function()
					doPollVote(v17.vote)
				end)
				local v18 = v16
				child.MouseEnter:Connect(function()
					local poll2 = getPoll(v) -- equivalent call inferred; original call site unknown
					local v22 = poll2 and poll2.voted[tostring(localPlayer.UserId)] == v18.vote

					if child.Active and not v22 then
						TweenService:Create(hover, tweenInfo3, {
							ImageTransparency = 0.9
						}):Play()
					end
				end)
				local v21 = v16
				local v22 = hover
				child.MouseLeave:Connect(function()
					local poll2 = getPoll(v) -- equivalent call inferred; original call site unknown

					if not poll2 or poll2.voted[tostring(localPlayer.UserId)] ~= v21.vote then
						TweenService:Create(v22, tweenInfo3, {
							ImageTransparency = 1
						}):Play()
					end
				end)
			end

			local close = clone:FindFirstChild("Close")

			if close then
				close.Activated:Connect(function()
					if v then
						v3[v] = true
					end

					destroyCurrentFrame()
				end)
			end

			local uIScale2 = clone:FindFirstChild("UIScale")
			uIScale2.Scale = 0.4
			clone.Visible = true
			clone.Parent = polls
			TweenService:Create(uIScale2, tweenInfo2, {
				Scale = 1
			}):Play()
			v2 = clone
			refreshPollData()
		end

		RunService.Heartbeat:Connect(function(dt: number)
			local v15 = v2

			if not v15 then
				return
			end

			if A ~= v6 then
				v6 = A
				local v16 = A - A2
				v4 = math.abs(v16) < 1 and 0 or v16 / 0.4
			end

			if B ~= v7 then
				v7 = B
				local v16 = B - B2
				v5 = math.abs(v16) < 1 and 0 or v16 / 0.4
			end

			if math.abs(A - A2) >= 1 then
				A2 += v4 * dt

				if v4 > 0 then
					A2 = math.min(A2, A)
				elseif v4 < 0 then
					A2 = math.max(A2, A)
				end
			else
				A2 = A
			end

			if math.abs(B - B2) >= 1 then
				B2 += v5 * dt

				if v5 > 0 then
					B2 = math.min(B2, B)
				elseif v5 < 0 then
					B2 = math.max(B2, B)
				end
			else
				B2 = B
			end

			local v16 = math.round(A2)
			local v17 = math.round(B2)

			if v16 ~= v8 or v17 ~= v9 then
				v8 = v16
				v9 = v17
				local bar = v15:FindFirstChild("Bar")
				local countA = bar:FindFirstChild("CountA")
				countA.Text = comma(v16)
				local countB = bar:FindFirstChild("CountB")
				countB.Text = comma(v17)
			end

			local v18 = v12

			if v18 then
				local v19 = A2 + B2
				local v20 = v19 < 1 and 0.5 or A2 / v19
				v10 += (v20 - v10) * math.min(1, dt * 5)

				if math.abs(v10 - v11) > 0.0005 then
					v11 = v10
					v18.Size = UDim2.fromScale(math.clamp(v10, 0, 1), 1)
				end
			end
		end)
		local fn = nil
		polls2:Observe({ "activePoll" }, function(value)
			if fn then
				fn()
				fn = nil
			end

			if typeof(value) ~= "string" then
				destroyCurrentFrame()
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function syncPoll()
				if v3[value] then
					return
				end

				local poll = getPoll(value) -- equivalent call inferred; original call site unknown

				if not poll then
					return
				end

				if v == value then
					refreshPollData()
				else
					showPoll(value, poll)
				end
			end

			local v15 = polls2:Observe({ "polls", value }, syncPoll)
			local total = 1e999
			local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
				total += dt

				if total >= 1 then
					total = 0
					syncPoll() -- equivalent call inferred; original call site unknown
				end
			end)

			fn = function()
				v15()
				postSimulationConnection:Disconnect()
			end
		end)
	end
}