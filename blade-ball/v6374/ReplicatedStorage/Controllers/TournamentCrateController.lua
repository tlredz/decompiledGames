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
local clientGameModules = ReplicatedStorage3.ClientGameModules
local _ = ReplicatedStorage3.Common
local packages = ReplicatedStorage3.Packages
local v2 = require3(ReplicatedStorage3.Packages.Replion)
local v3 = require3(ReplicatedStorage3.Packages.Net)
local v4 = require3(ReplicatedStorage3.Common.Utils)
local v5 = require3(clientGameModules.GuiHandler)
local v6 = require3(game.ReplicatedStorage.Shared.Policy)
local v7 = require3(ReplicatedStorage3.Shared.TournamentCrateData)
require3(ReplicatedStorage3.Common.MarketplaceService)
local v8 = require3(packages.Signal)
local v9 = require3(ReplicatedStorage3.ClientGameModules.CreatePriceLabel)
local v10 = require3(ReplicatedStorage3.ClientGameModules.CoreCall)
local v11 = require3(ReplicatedStorage3.Controllers.Trading.TradeTokensController)
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local localPlayer = Players.LocalPlayer
local playerGui = nil
local tournamentsCrate = nil
local main = nil
local left = nil
local right = nil
local odds = nil
local items = nil
local leftList = nil
local rightList = nil
local spinButtons = nil
local spin1 = nil
local spin10 = nil
local secret = nil
local secret2 = nil
local glow = nil
local item = nil
local selected = nil
local questionMark = nil
local desc2 = nil
local label = nil
local main2 = nil
local currency = nil
local add = nil
local label2 = nil
local label3 = nil
local list = nil
local close = nil
local ticketsShop = nil
local frame = nil
local timer = nil
local amount = nil
local frame2 = nil
local closeButton = nil
local flag = false
local v16 = {}
local count = 0
local count2 = 0
local halloweenGacha = ReplicatedStorage3.Assets.UI.HalloweenGacha
local TournamentCrateController = {
	BalanceText = "",
	BalanceTextChanged = v8.new(),
	DefaultSecret = function(self)
		glow.Visible = false
		selected.Visible = false
		questionMark.Visible = true
		desc2.Text = "Sword/Explosion"
	end,
	LoadItems = function(self)
		for k, v17 in v7.RewardPool do
			local v18 = v16[k]

			if not v18 then
				continue
			end

			local reward = v17.Reward
			v18.Vector.Image = reward.Icon or ""
			v18.Title.Text = reward.DisplayName
			v18.Label.Text = `{v17.Probability}%`
			local selected = v18:FindFirstChild("Selected")
			selected.Visible = false
			count += 1
		end

		count += 1
		label.Text = `{v7.RewardPool[count].Probability}%`
		self:DefaultSecret()
	end,
	ToggleChances = function(flag2: boolean?)
		for _, v17 in v16 do
			v17.Label.Visible = flag2 or not v17.Label.Visible
		end

		label.Visible = flag2 or not label.Visible
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

function TournamentCrateController.Spin(p, p2, p3)
	if flag then
		return
	end

	local replacement = v7.RewardPool[p]
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)

	if p2 and replacement.Replacement then
		replacement = replacement.Replacement
	end

	local v17 = p3 and 0.015 or 0.045
	local v18 = p3 and 3 or 5
	flag = true
	TournamentCrateController:DefaultSecret()

	for i = 1, v18 do
		for i2 = 1, count do
			for _, v19 in v16 do
				TweenService:Create(
					v19:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
				local selected_2 = v19:FindFirstChild("Selected")
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
					v16[i2]:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			end

			if i == v18 and i2 == p then
				break
			end

			local clone = halloweenGacha.bink:Clone()
			clone.Parent = playerGui
			clone.Volume = clone.Volume or 0.34
			clone:Play()
			task.delay(clone.TimeLength + 0.1, function()
				clone:Destroy()
			end)
			task.wait(v17)
			v17 = math.min(v17 * 1.015, 0.1)
		end
	end

	if replacement.Replacement or p2 then
		local lastTime = tick()
		v4.Sounds:Play("SecretOpened")
		local v19 = 0.8
		local v20 = 9

		while tick() - lastTime < v19 do
			local v21 = v20 * (1 - (tick() - lastTime) / 0.8)
			local number = Random.new():NextNumber(-v21, v21)
			local number2 = Random.new():NextNumber(-v21, v21)
			secret2.Position = UDim2.new(0.5, number, 0.5, number2)
			task.wait()
		end

		secret2.Position = UDim2.new(0.5, 0, 0.5, 0)
		item.Image = replacement.Reward.Icon
		glow.Visible = true
		questionMark.Visible = false
		desc2.Text = replacement.Reward.DisplayName
		v14:FireServer()
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
		v14:FireServer()
	end

	task.wait(0.5)
	flag = false
	local tournamentTickets = v12:Get("TournamentTickets") or 0

	if p3 and count2 < 9 and tournamentTickets > 0 then
		count2 += 1
		v13:FireServer(true)
	end
end

function TournamentCrateController:SetupStreaks()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetTickets(p)
		for _, dailyLoginStreak in v7.DailyLoginStreaks do
			if dailyLoginStreak.Streak == p then
				return dailyLoginStreak.Tickets
			end
		end

		return 0
	end

	local updatesByName = {}

	for k, v18 in {
		["1"] = list:FindFirstChild("1"),
		["3"] = list:FindFirstChild("2"),
		["5"] = list:FindFirstChild("3"),
		["7"] = list:FindFirstChild("4")
	} do
		local v19 = v18
		local v20 = k

		local function update()
			local label4 = v19.Label

			if v12:Get({ "TournamentClaimedStreaks", (`Day{v19.Name}`) }) then
				v19.ImageColor3 = Color3.fromRGB(125, 125, 125)
				label4.Text = "CLAIMED!"
			else
				local tournamentLoginStreak = v12:Get("TournamentLoginStreak")
				v19.ImageColor3 = Color3.new(1, 1, 1)
				local tickets = GetTickets(tonumber(v20)) -- equivalent call inferred; original call site unknown
				label4.Text = `{tickets} Ticket{tickets <= 1 and "" or "s"}`

				if tonumber(v20) <= tournamentLoginStreak then
					label4.Visible = true
					v19:SetAttribute("CanClaim", true)
				else
					label4.Visible = false
					v19:SetAttribute("CanClaim", nil)
				end
			end
		end

		local v21 = v18
		v18.Activated:Connect(function()
			if v12:Get({ "TournamentClaimedStreaks", (`Day{v21.Name}`) }) or not v21:GetAttribute("CanClaim") then
				return
			end

			v4.Sounds:Play("LTMSpin_ClaimSpins")
			v15:FireServer((tonumber(v21.Name)))
		end)
		update()
		updatesByName[v18.Name] = update
		v12:OnChange("TournamentClaimedStreaks", update)
	end

	local function updateStreaks()
		label3.Text = `{v12:Get("TournamentLoginStreak")} Days`

		for _, v18 in updatesByName do
			v18()
		end
	end

	v12:OnChange("TournamentLoginStreak", updateStreaks)
	v12:OnChange("TournamentClaimedStreaks", updateStreaks)
	task.spawn(updateStreaks)
end

function TournamentCrateController:SetupTicketShop()
	for _, child in frame2:GetChildren() do
		local buyButton = child:FindFirstChild("BuyButton")

		if not buyButton then
			continue
		end

		v9(buyButton.Price, child.Name, "DevProduct", "%s")
		local v17 = child
		buyButton.Activated:Connect(function()
			v11:PromptPurchase(tonumber(v17.Name), Enum.InfoType.Product)
		end)
	end
end

function TournamentCrateController.UpdateSpins()
	local tournamentTickets = v12:Get("TournamentTickets") or 0
	label2.Text = tournamentTickets
	amount.Text = label2.Text
	TournamentCrateController.BalanceText = label2.Text
	TournamentCrateController.BalanceTextChanged:Fire(TournamentCrateController.BalanceText)
end

function TournamentCrateController.Init(_) end

function TournamentCrateController:Start()
	v12 = v2.Client:WaitReplion("Data")
	v13 = v3:RemoteEvent("ProcessTournamentRoll")
	v14 = v3:RemoteEvent("ClaimTournamentReward")
	v15 = v3:RemoteEvent("ClaimTournamentStreak")
	playerGui = localPlayer:WaitForChild("PlayerGui")
	tournamentsCrate = playerGui:WaitForChild("TournamentsCrate")
	main = tournamentsCrate:WaitForChild("Crates"):WaitForChild("Main")
	left = main:WaitForChild("Left")
	right = main:WaitForChild("Right")
	odds = left:WaitForChild("Odds")
	items = left:WaitForChild("Items")
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
	main2 = right:WaitForChild("Main")
	currency = right:WaitForChild("Currency")
	add = currency:WaitForChild("Add")
	label2 = currency:WaitForChild("Label")
	label3 = main2:WaitForChild("DayCount"):WaitForChild("DayCount"):WaitForChild("Label")
	list = main2:WaitForChild("List")
	close = right:WaitForChild("Close")
	ticketsShop = tournamentsCrate:WaitForChild("TicketsShop")
	frame = ticketsShop:WaitForChild("Frame")
	timer = frame:WaitForChild("Timer")
	amount = frame:WaitForChild("Currency"):WaitForChild("Amount")
	frame2 = frame:WaitForChild("Frame")
	closeButton = frame:WaitForChild("CloseButton")
	v16[1] = leftList:WaitForChild("Crate1")
	v16[2] = leftList:WaitForChild("Crate2")
	v16[3] = leftList:WaitForChild("Crate3")
	v16[4] = leftList:WaitForChild("Crate4")
	v16[5] = rightList:WaitForChild("Crate5")
	v16[6] = rightList:WaitForChild("Crate6")
	v16[7] = rightList:WaitForChild("Crate7")
	v16[8] = rightList:WaitForChild("Crate8")

	if RunService:IsStudio() then
		v.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.J and not gameProcessed and localPlayer.UserId == 33836554 then
				v5:Open("TournamentsCrate")
			end
		end)
	end

	close.Activated:Connect(function()
		v5:Close("TournamentsCrate")
	end)
	v5:OnGuiOpen("TournamentsCrate", function()
		ticketsShop.Visible = false
		v10(Enum.CoreGuiType.PlayerList, false)
	end)
	v5:OnGuiClose("TournamentsCrate", function()
		v10(Enum.CoreGuiType.PlayerList, true)
	end)
	add.Activated:Connect(function()
		ticketsShop.Visible = true
	end)
	closeButton.Activated:Connect(function()
		ticketsShop.Visible = false
	end)
	spin1.Activated:Connect(function()
		if flag then
			return
		end

		count2 = 0
		v13:FireServer()
	end)
	spin10.Activated:Connect(function()
		if flag or (v12:Get("TournamentTickets") or 0) < 10 then
			return
		end

		count2 = 0
		v13:FireServer(true)
	end)
	odds.Activated:Connect(function()
		self.ToggleChances()
	end)
	v13.OnClientEvent:Connect(TournamentCrateController.Spin)
	v12:OnChange("TournamentTickets", TournamentCrateController.UpdateSpins)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ReflectPolicy()
		local policyInfo = v6:GetPolicyInfo()
		add.Visible = not policyInfo.ArePaidRandomItemsRestricted
	end

	ReflectPolicy() -- equivalent call inferred; original call site unknown
	v6.PolicyInfoAdded:Connect(ReflectPolicy)
	v4.Thread.Every(1, function()
		local dateTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
		timer.Text = v4.ValueConvertor:FormatTimeWithDaysFull(v7.TimeLength.UnixTimestamp - dateTime.UnixTimestamp)
	end)
	self:LoadItems()
	self.UpdateSpins()
	self:SetupStreaks()
	self:SetupTicketShop()
	self.ToggleChances(false)
end

return TournamentCrateController