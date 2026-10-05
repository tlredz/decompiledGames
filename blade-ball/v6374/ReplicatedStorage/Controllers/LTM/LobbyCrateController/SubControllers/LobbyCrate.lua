local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")

if require3(ReplicatedStorage3.ServerInfo).isLTMServer() then
	return {}
end

local clientGameModules = ReplicatedStorage3.ClientGameModules
local _ = ReplicatedStorage3.Common
local packages = ReplicatedStorage3.Packages
local v2 = require3(ReplicatedStorage3.Packages.Replion)
local v3 = require3(ReplicatedStorage3.Packages.Net)
local v4 = require3(ReplicatedStorage3.Common.Utils)
local v5 = require3(clientGameModules.GuiHandler)
local v6 = require3(game.ReplicatedStorage.Shared.Policy)
local v7 = require3(ReplicatedStorage3.Shared.LTM)
local v8 = require3(ReplicatedStorage3.Shared.LTMCrateData)
local v9 = require3(packages.Signal)
local v10 = require3(ReplicatedStorage3.ClientGameModules.CoreCall)
local v11 = require3(ReplicatedStorage3.Controllers.Trading.IndexController)
local v12 = require3(packages.Trove)
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local localPlayer = Players.LocalPlayer
local playerGui = nil
local child = nil
local crates = nil
local left = nil
local right = nil
local odds = nil
local items = nil
local leftList = nil
local rightList = nil
local spinButtons = nil
local spin1 = nil
local spin10 = nil
local spinner = nil
local secret = nil
local secret2 = nil
local glow = nil
local item = nil
local selected = nil
local questionMark = nil
local desc2 = nil
local label = nil
local stock = nil
local main = nil
local desc = nil
local header = nil
local currency = nil
local add = nil
local amount = nil
local dayCount = nil
local label2 = nil
local list = nil
local timer = nil
local close = nil
local lobbyCrateWindow = nil
local lobbyTicketsWindow = nil
local uIType = "Crate"
local flag = false
local v17 = {
	Crate = {},
	SpinWheel = {}
}
local count = 0
local count2 = 0
local halloweenGacha = ReplicatedStorage3.Assets.UI.HalloweenGacha
local maid = v12.new()
local LobbyCrate = {
	BalanceText = "",
	BalanceTextChanged = v9.new(),
	DefaultSecret = function(self)
		local currentLTM = v7.getCurrentLTM()

		if not currentLTM then
			return
		end

		local gameMode = currentLTM.getGameMode()
		local v18 = gameMode and v8.Profiles[gameMode]

		if not v18 then
			return
		end

		local v19 = v18.RewardPool[count]

		if v19 and v19.LimitedStock then
			local formatted = `Received{currentLTM.Id}LTM{v19.Reward.Value}{v19.Reward.Type}`
			local v20 = v2.Client:WaitReplion("LimitedStockItems")
			local v21 = v20:Get({ "Stock", v19.Reward.Value }) or 0
			local v22 = v20:Get({ "InitialStock", v19.Reward.Value }) or 50000
			local v23

			if v13 then
				v23 = v13:Get(formatted) and true or false or v21 <= 0
			else
				v23 = false
			end

			local reward = v19.Reward

			if v23 and v19.Replacement then
				reward = v19.Replacement.Reward
			end

			if reward then
				glow.Visible = true
				selected.Visible = false
				questionMark.Visible = false
				desc2.Text = reward.Value
				item.Image = reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
			end

			if v23 then
				stock.Text = ""
			else
				label.Visible = false
				stock.Text = `{v4.ValueConvertor:AddCommas(v21)}/{v4.ValueConvertor:ShrinkNumber(v22)}`
				stock.Visible = true
			end

			local inspect = secret2 and secret2:FindFirstChild("Inspect")

			if inspect then
				maid:Connect(inspect.Activated, function()
					v11:Preview(reward.Type, reward.Value)
				end)
			end
		else
			glow.Visible = false
			selected.Visible = false
			questionMark.Visible = true
			desc2.Text = "Sword/Explosion"
			item.Image = "rbxassetid://16456337904"
		end
	end,
	LoadItems = function(self)
		local currentLTM = v7.getCurrentLTM()
		local v18 = currentLTM and currentLTM.getGameMode()
		local v19 = v18 and v8.Profiles[v18]

		if not v19 then
			return
		end

		count = 0

		for k, v20 in v19.RewardPool do
			local v21 = v17[uIType][k]

			if not v21 then
				continue
			end

			local reward = v20.Reward

			if uIType == "Crate" then
				v21.Vector.Image = reward.Icon or ""
				v21.Title.Text = reward.DisplayName
				v21.Label.Text = `{v20.Probability}%`
				local selected = v21:FindFirstChild("Selected")
				selected.Visible = false
			elseif uIType == "SpinWheel" then
				v21.Image = reward.Icon or ""
				v21.Amount.Text = `{v20.Probability}%`
			end

			local inspect = v21:FindFirstChild("Inspect")

			if inspect then
				local reward2 = reward
				maid:Connect(inspect.Activated, function()
					v11:Preview(reward2.Type, reward2.Value)
				end)
			end

			count += 1
		end

		if uIType == "Crate" then
			count += 1
			label.Text = `{v19.RewardPool[count].Probability}%`
			self:DefaultSecret(maid)
		end
	end,
	ToggleChances = function(visible: boolean?)
		if uIType == "Crate" then
			for _, v18 in v17.Crate do
				local label3 = v18.Label
				local visible2

				if visible == nil then
					visible2 = not v18.Label.Visible
				else
					visible2 = visible
				end

				label3.Visible = visible2
			end

			if not label then
				return
			end

			local v18 = label

			if visible == nil then
				visible = not label.Visible
			end

			v18.Visible = visible
			stock.Visible = not label.Visible
		end
	end
}

local function ApplyTween(clone, p, uDim, p2, p3)
	local tween = TweenService:Create(
		clone,
		p3 or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			[p] = uDim
		}
	)
	tween:Play()

	if not p2 then
		return
	end

	tween.Completed:Connect(function()
		clone:Destroy()
	end)
end

function LobbyCrate.SpinCrate(p, p2, p3)
	local currentLTM = v7.getCurrentLTM()

	if not currentLTM then
		return
	end

	local gameMode = currentLTM.getGameMode()
	local profile = v8.Profiles[gameMode]

	if not profile or flag then
		return
	end

	local replacement = profile.RewardPool[p]
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local limitedStock = replacement.LimitedStock

	if p2 and replacement.Replacement then
		replacement = replacement.Replacement
	end

	local v18 = p3 and 0.015 or 0.045
	local v19 = p3 and 3 or 5
	flag = true

	if not limitedStock then
		LobbyCrate:DefaultSecret()
	end

	local v20 = v17[uIType]

	for i = 1, v19 do
		for i2 = 1, count do
			for _, v21 in v20 do
				TweenService:Create(
					v21:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
				local selected_2 = v21:FindFirstChild("Selected")
				selected_2.Visible = true
			end

			selected.Visible = true
			TweenService:Create(
				selected,
				tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					ImageTransparency = 1
				}
			):Play()

			if count <= i2 then
				TweenService:Create(
					selected,
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			else
				TweenService:Create(
					v20[i2]:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			end

			if i == v19 and i2 == p then
				break
			end

			local clone = halloweenGacha.bink:Clone()
			clone.Parent = playerGui
			clone.Volume = clone.Volume or 0.34
			clone:Play()
			task.delay(clone.TimeLength + 0.1, function()
				clone:Destroy()
			end)
			task.wait(v18)
			v18 = math.min(v18 * 1.015, 0.1)
		end
	end

	if (replacement.Replacement or p2) and not limitedStock then
		local lastTime = tick()
		v4.Sounds:Play("SecretOpened")
		local v21 = 0.8
		local v22 = 9

		while tick() - lastTime < v21 do
			local v23 = v22 * (1 - (tick() - lastTime) / 0.8)
			local number = Random.new():NextNumber(-v23, v23)
			local number2 = Random.new():NextNumber(-v23, v23)
			secret2.Position = UDim2.new(0.5, number, 0.5, number2)
			task.wait()
		end

		secret2.Position = UDim2.new(0.5, 0, 0.5, 0)
		item.Image = replacement.Reward.Icon or ""
		glow.Visible = true
		questionMark.Visible = false
		desc2.Text = replacement.Reward.DisplayName
		v15:FireServer()
		local clone = halloweenGacha.reward:Clone()
		clone.Volume = 0.34
		clone.Parent = playerGui
		clone:Play()
		local clone2 = secret2:Clone()
		clone2.Parent = secret2.Parent

		for _, descendant in clone2:GetDescendants() do
			if descendant:IsA("TextLabel") or descendant:IsA("TextBox") or descendant:IsA("TextButton") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						TextTransparency = 1
					}
				):Play()
			elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1
					}
				):Play()
			end
		end

		TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			ImageTransparency = 1
		}):Play()
		ApplyTween(clone2, "Size", UDim2.fromScale(2.5, 2.5), true)
	else
		local clone = halloweenGacha.reward:Clone()
		clone.Volume = 0.34
		clone.Parent = playerGui
		clone:Play()
		v15:FireServer()
	end

	task.wait(0.5)

	if limitedStock then
		LobbyCrate:DefaultSecret()
	end

	flag = false
	local v21 = v13:Get(currentLTM.TicketName) or 0

	if p3 and count2 < 9 and v21 > 0 then
		count2 += 1
		v14:FireServer(true)
	end
end

local rotation = 0
local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopIdle()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playIdle()
	stopIdle() -- equivalent call inferred; original call site unknown
	thread = task.spawn(function()
		while true do
			local v19 = RunService.PreRender:Wait()
			rotation += v19 * 30
			rotation %= 360

			if items then
				items.Rotation = rotation
			end
		end
	end)
end

function LobbyCrate.SpinWheel(p, _, p2)
	local currentLTM = v7.getCurrentLTM()

	if not currentLTM then
		return
	end

	local gameMode = currentLTM.getGameMode()
	local profile = v8.Profiles[gameMode]

	if not profile or flag then
		return
	end

	local _ = profile.RewardPool[p]
	TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local v19 = p2 and 4 or 10
	flag = true
	local v20 = (p - 1) * 360 / 8 + 22.5 + 5400
	local v21 = rotation
	local v22 = v20 - v21
	local v23 = 0
	local v24 = 0
	local now = 0
	task.delay(2 / v19, function()
		v4.Sounds:Play("ChristmasLTMSpin_Start", nil, {
			PlaybackSpeed = 9 / v19
		})
	end)
	stopIdle() -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local v25 = 0

	while true do
		RunService.PostSimulation:Wait()
		local v26 = math.min((tick() - lastTime) / v19, 1)
		rotation = v21 + v22 * (1 - 2 ^ (v26 * -10))
		rotation %= 360
		items.Rotation = rotation
		spinner.Rotation = v25 + (spinner.Rotation - v25) * 0.5
		local v27 = rotation // 45

		if v27 ~= v24 and os.clock() - now > 0.1 then
			now = os.clock()
			v24 = v27
		end

		if v23 ~= v27 then
			v25 += (1 - v26) * 12.5 + 12.5
			v23 = v27
		end

		v25 = math.min(v25 * 0.7, 25)

		if not (v26 >= 1) then
			continue
		end

		v4.Sounds:Play("ChristmasLTMSpin_Reward")
		v15:FireServer()
		task.wait(1)
		flag = false
		playIdle() -- equivalent call inferred; original call site unknown
		local v28 = v13:Get(currentLTM.TicketName) or 0

		if p2 and count2 < 9 and v28 > 0 then
			count2 += 1
			v14:FireServer(true)
		end

		break
	end
end

function LobbyCrate.Spin(p, p2, p3)
	if uIType == "Crate" then
		return LobbyCrate.SpinCrate(p, p2, p3)
	elseif uIType == "SpinWheel" then
		return LobbyCrate.SpinWheel(p, p2, p3)
	end
end

function LobbyCrate:SetupStreaks()
	local currentLTM = v7.getCurrentLTM()

	if not currentLTM then
		return
	end

	local gameMode = currentLTM.getGameMode()
	local profile = v8.Profiles[gameMode]

	if not profile or flag then
		return
	end

	local v19 = {
		["1"] = list:FindFirstChild("1"),
		["2"] = list:FindFirstChild("2"),
		["3"] = list:FindFirstChild("3"),
		["4"] = list:FindFirstChild("4")
	}

	local function GetStreakData(p)
		if not profile.DailyLoginStreaks then
			return
		end

		for _, dailyLoginStreak in profile.DailyLoginStreaks do
			if dailyLoginStreak.Streak == p then
				return dailyLoginStreak
			end
		end

		return {
			Streak = 0,
			Tickets = 0
		}
	end

	if currentLTM.LoginStreak and currentLTM.ClaimedStreaks and currentLTM.LastLoginStreak then
		local updatesByName = {}

		for k, v20 in v19 do
			local button = v20:FindFirstChild("Button") or v20
			local v22 = v20
			local v23 = k

			local function update()
				local label3 = button.Label
				local v24 = v13:Get({ currentLTM.ClaimedStreaks, (`Day{v22.Name}`) })
				local streakData = GetStreakData(tonumber(v23))

				if not streakData then
					return
				end

				v22.Days.Label.Text = `Day {streakData.Streak}`
				local tickets = streakData.Tickets
				label3.Text = `+{tickets} Ticket{tickets <= 1 and "" or "s"}`
				label3.Visible = true

				if v24 then
					v22.ImageColor3 = Color3.new(0.9, 0.9, 0.9)
					v22.Claimed.Visible = true
				else
					local v26 = v13:Get(currentLTM.LoginStreak) or 0
					v22.ImageColor3 = Color3.new(1, 1, 1)
					v22.Claimed.Visible = false

					if button ~= v22 then
						button.Visible = true
					end

					if tonumber(v23) <= v26 then
						label3.Text = `+{tickets} (Click to claim)`
						v22:SetAttribute("CanClaim", true)
					else
						v22:SetAttribute("CanClaim", nil)
					end
				end
			end

			local v24 = v20
			maid:Connect(button.Activated, function()
				if v13:Get({ currentLTM.ClaimedStreaks, (`Day{v24.Name}`) }) or not v24:GetAttribute("CanClaim") then
					return
				end

				v4.Sounds:Play("LTMSpin_ClaimSpins")
				v16:FireServer((tonumber(v24.Name)))
			end)
			update()
			updatesByName[v20.Name] = update
			maid:Add(v13:OnChange(currentLTM.ClaimedStreaks, update))
		end

		local function updateStreaks()
			label2.Text = `{v13:Get(currentLTM.LoginStreak)} Days`

			for _, v20 in updatesByName do
				v20()
			end
		end

		maid:Add(v13:OnChange(currentLTM.LastLoginStreak, updateStreaks))
		maid:Add(v13:OnChange(currentLTM.LoginStreak, updateStreaks))
		maid:Add(v13:OnChange(currentLTM.ClaimedStreaks, updateStreaks))
		task.spawn(updateStreaks)
	end
end

function LobbyCrate.UpdateSpins()
	local currentLTM = v7.getCurrentLTM()

	if not currentLTM then
		return
	end

	local v19 = v13:Get(currentLTM.TicketName) or 0
	amount.Text = v4.ValueConvertor:AddCommas(v19)
	LobbyCrate.BalanceText = amount.Text
	LobbyCrate.BalanceTextChanged:Fire(LobbyCrate.BalanceText)
end

function LobbyCrate:Start()
	v13 = v2.Client:WaitReplion("Data")
	v14 = v3:RemoteEvent("ProcessLTMRoll")
	v15 = v3:RemoteEvent("ClaimLTMReward")
	v16 = v3:RemoteEvent("ClaimLTMStreak")
	playerGui = localPlayer:WaitForChild("PlayerGui")
	local v19 = lobbyCrateWindow
	local v20 = lobbyTicketsWindow
	local id = nil
	local versionId = nil

	local function UpdateMode()
		local currentLTM = v7.getCurrentLTM()

		if not currentLTM or id == currentLTM.Id and versionId == currentLTM.VersionId then
			return
		end

		maid:Clean()
		lobbyCrateWindow = currentLTM.LobbyCrateWindow or "LobbyCrate"
		lobbyTicketsWindow = currentLTM.LobbyTicketsWindow or "LobbyTickets"

		if v19 then
			v5:Close(v19)
		end

		if v20 then
			v5:Close(v20)
		end

		count = 0
		count2 = 0
		v19 = lobbyCrateWindow
		id = currentLTM.Id
		versionId = currentLTM.VersionId
		child = playerGui:WaitForChild(lobbyCrateWindow)
		crates = child:WaitForChild("Crates")
		left = crates:WaitForChild("Left")
		right = crates:WaitForChild("Right")
		items = left:WaitForChild("Items")
		uIType = currentLTM.UIType or "Crate"

		if uIType == "Crate" then
			odds = left:WaitForChild("Odds")
			leftList = items:WaitForChild("LeftList")
			rightList = items:WaitForChild("RightList")
			spinButtons = items:WaitForChild("SpinButtons")
			spin1 = spinButtons:WaitForChild("Spin1")
			spin10 = spinButtons:WaitForChild("Spin10")
			secret = items:WaitForChild("Secret")
			secret2 = secret:WaitForChild("Secret")
			glow = secret2:WaitForChild("Glow")
			item = glow:WaitForChild("Item")
			selected = secret2:WaitForChild("Selected")
			questionMark = secret2:WaitForChild("QuestionMark")
			desc2 = secret2:WaitForChild("Desc2")
			label = secret2:WaitForChild("Label")
			stock = secret2:FindFirstChild("Stock")
		elseif uIType == "SpinWheel" then
			spinButtons = left:WaitForChild("SpinButtons")
			spin1 = spinButtons:WaitForChild("Spin1")
			spin10 = spinButtons:WaitForChild("Spin10")
			spinner = left:WaitForChild("Spinner")
		end

		main = right:WaitForChild("Main")
		desc = main:WaitForChild("Desc")
		header = main:WaitForChild("Header")
		currency = right:WaitForChild("Currency")
		add = currency:WaitForChild("Add")
		amount = currency:WaitForChild("List"):WaitForChild("Amount")
		dayCount = main:WaitForChild("DayCount")
		label2 = dayCount:WaitForChild("DayCount"):WaitForChild("Label")
		list = main:WaitForChild("List")
		timer = main:WaitForChild("Timer")
		close = right:WaitForChild("Close")

		if uIType == "Crate" then
			v17.Crate[1] = leftList:WaitForChild("Crate1")
			v17.Crate[2] = leftList:WaitForChild("Crate2")
			v17.Crate[3] = leftList:WaitForChild("Crate3")
			v17.Crate[4] = leftList:WaitForChild("Crate4")
			v17.Crate[5] = rightList:WaitForChild("Crate5")
			v17.Crate[6] = rightList:WaitForChild("Crate6")
			v17.Crate[7] = rightList:WaitForChild("Crate7")
			v17.Crate[8] = rightList:WaitForChild("Crate8")
		elseif uIType == "SpinWheel" then
			v17.SpinWheel[1] = items:WaitForChild("1")
			v17.SpinWheel[2] = items:WaitForChild("2")
			v17.SpinWheel[3] = items:WaitForChild("3")
			v17.SpinWheel[4] = items:WaitForChild("4")
			v17.SpinWheel[5] = items:WaitForChild("5")
			v17.SpinWheel[6] = items:WaitForChild("6")
			v17.SpinWheel[7] = items:WaitForChild("7")
			v17.SpinWheel[8] = items:WaitForChild("8")
		end

		if lobbyCrateWindow then
			v5:OnGuiOpen(lobbyCrateWindow, function()
				v10(Enum.CoreGuiType.PlayerList, false)
			end)
			v5:OnGuiClose(lobbyCrateWindow, function()
				v10(Enum.CoreGuiType.PlayerList, true)
			end)
			maid:Add(function()
				v5:Close(lobbyCrateWindow)
			end)
		end

		maid:Connect(workspace.Alive.ChildAdded, function(p)
			if lobbyCrateWindow and p.Name == localPlayer.Name and v5:IsOpen(lobbyCrateWindow) then
				v5:Close(lobbyCrateWindow)
			end
		end)
		maid:Connect(close.MouseButton1Click, function()
			v5:Close(lobbyCrateWindow)
		end)

		if lobbyTicketsWindow then
			maid:Connect(add.MouseButton1Click, function()
				v5:Open(lobbyTicketsWindow)
			end)
		end

		maid:Connect(spin1.MouseButton1Click, function()
			if flag then
				return
			end

			count2 = 0
			v14:FireServer()
		end)
		maid:Connect(spin10.MouseButton1Click, function()
			if flag or (v13:Get(currentLTM.TicketName) or 0) < 10 then
				return
			end

			count2 = 0
			v14:FireServer(true)
		end)

		if odds then
			maid:Connect(odds.MouseButton1Click, function()
				self.ToggleChances()
			end)
		end

		if uIType == "SpinWheel" then
			playIdle() -- equivalent call inferred; original call site unknown
		end

		maid:Add(v13:OnChange(currentLTM.TicketName, LobbyCrate.UpdateSpins))
		header.Text = string.upper((`{currentLTM.getModeName()} ltm`))
		desc.Text = `Play "{currentLTM.getModeName()} LTM" to earn free rewards`
		self:LoadItems()
		self.UpdateSpins()
		self:SetupStreaks()
	end

	if RunService:IsStudio() then
		v.InputBegan:Connect(function(input, gameProcessed)
			if lobbyCrateWindow and input.KeyCode == Enum.KeyCode.J and not gameProcessed and (localPlayer.UserId == 33836554 or localPlayer.UserId == 250083132) then
				v5:Open(lobbyCrateWindow)
			end
		end)
	end

	v14.OnClientEvent:Connect(LobbyCrate.Spin)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ReflectPolicy()
		if not add then
			return
		end

		local policyInfo = v6:GetPolicyInfo()
		add.Visible = not policyInfo.ArePaidRandomItemsRestricted
	end

	ReflectPolicy() -- equivalent call inferred; original call site unknown
	v6.PolicyInfoAdded:Connect(ReflectPolicy)

	local function UpdateDailyStreakTime()
		local currentLTM = v7.getCurrentLTM()

		if not (dayCount and currentLTM) then
			return
		end

		local v21 = currentLTM.LastLoginStreak and v13:Get(currentLTM.LastLoginStreak)

		if not v21 then
			dayCount.Label.Text = "Something went wrong!"
			return
		end

		local v22 = math.clamp(v21 + 86400 - workspace:GetServerTimeNow(), 0, 1e999)
		dayCount.Label.Text = `Next rewards: {v4.ValueConvertor:FormatTimeHHMMSS(v22)}`
	end

	v4.Thread.Every(1, function()
		local currentLTM = v7.getCurrentLTM()

		if not (dayCount and currentLTM) then
			return
		end

		local dateTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
		local endTime = v7.getEndTime()
		local formatTimeWithDaysFull = v4.ValueConvertor:FormatTimeWithDaysFull(endTime - dateTime.UnixTimestamp)
		timer.Text = `{formatTimeWithDaysFull}`
		UpdateDailyStreakTime()
	end)
	UpdateMode()
	v7.OnModeChange(function()
		UpdateMode()
	end)
	self.ToggleChances(false)
end

return LobbyCrate