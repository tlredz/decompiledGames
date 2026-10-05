local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local NotificationController = require(controllers.NotificationController)
local CustomRichTextController = require(controllers.CustomRichTextController)
local Updates = require(ReplicatedStorage.Shared.Updates)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Observers = require(packages.Observers)
local Synchronizer = require(packages.Synchronizer)
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local utils = ReplicatedStorage:WaitForChild("Utils")
local TimeUtils = require(utils.TimeUtils)
local NumberUtils = require(utils.NumberUtils)
local datas = ReplicatedStorage:WaitForChild("Datas")
local LuckyBlocks = require(datas.LuckyBlocks)
local EclipseSpinWheel = require(datas.EclipseSpinWheel)
local Animals = require(ReplicatedStorage.Datas.Animals)
local Shop = require(datas.Shop)
local classes = ReplicatedStorage:WaitForChild("Classes")
local EclipseSpinWheel2 = require(script.EclipseSpinWheel)
local AnimatedButton = require(classes.AnimatedButton)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Marketplace = require(shared.Marketplace)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local Policy = require(ReplicatedStorage.Shared.Policy)
local localPlayer = Players.LocalPlayer
local eclipseWheel = localPlayer.PlayerGui:WaitForChild("EclipseWheel").EclipseWheel
local v = nil
local visible = false
local remoteEvent = Net:RemoteEvent("ShopService/Purchase")
local remoteEvent2 = Net:RemoteEvent("EclipseEventService/Spin")
local v3 = {
	Buy1 = 3715911830,
	Buy1Discount = 3715911832,
	Buy3 = 3715911837,
	Buy10 = 3715911840
}
local flag = false

local function IsEnabled()
	return ReplicatedStorage:GetAttribute("EclipseEvent")
end

local function ResultAnimation(p: number, flag2: boolean?)
	local v4 = Synchronizer:Wait(localPlayer)

	if flag then
		return
	end

	flag = true
	local wheel = eclipseWheel.Wheel
	local spinning = SoundService:FindFirstChild("Spinning")
	local volume = visible and 1 or 0.8

	if spinning then
		spinning.Looped = true
		spinning.Volume = volume
		spinning:Play()
	end

	local rotation = (p - 1) * -60 - (math.random() - 0.5) * 0.7 * 60
	local rotation2 = rotation + (visible and 1 or 9) * 360
	local v8 = visible and 0.5 or 5
	local v9 = nil
	local postSimulationConnection = RunService.PostSimulation:Connect(function()
		debug.profilebegin("EclipseEventController:ResultAnimation")
		local v10 = (wheel.Rotation + 30) / 60 // 1

		if v9 ~= v10 then
			v9 = v10
			eclipseWheel.Tick.Rotation = -40
			TweenService:Create(
				eclipseWheel.Tick,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					Rotation = 0
				}
			):Play()
		end

		debug.profileend()
	end)
	local tween = TweenService:Create(wheel, TweenInfo.new(v8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Rotation = rotation2
	})

	if spinning then
		TweenService:Create(spinning, TweenInfo.new(v8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Volume = 0
		}):Play()
	end

	tween:Play()
	tween.Completed:Wait()
	postSimulationConnection:Disconnect()
	wheel.Rotation = rotation

	if spinning then
		spinning:Stop()
		spinning.Volume = volume
	end

	local v10 = flag2 == true and EclipseSpinWheel.AltRewards[p] or EclipseSpinWheel.Rewards[p]
	local display

	if v10.Type == "Cash-Pack" then
		local v11 = Shop[v10.Index]

		if not v11 then
			flag = false
			return false
		end

		local value = v11.Value or 0
		local rebirth = v4:Get("Rebirth") or 0

		if rebirth > 0 then
			value *= rebirth <= 1 and 1.5 or rebirth
		end

		display = `${NumberUtils:ToString(value, 2)}`
	else
		display = v10.Display
	end

	NotificationController:Success((`You received {display}!`))
	flag = false
end

local EclipseEventController = {}

function EclipseEventController:SetupEclipseWheel()
	v = InterfaceController:Register("EclipseWheel", eclipseWheel, "TopQuint")
	v:AttachCloseButton(eclipseWheel.Close)
	v:Close()
	local v4 = Synchronizer:Wait(localPlayer)

	local function setup()
		local wheel = eclipseWheel.Wheel
		local items = wheel.Items
		local names = wheel.Names
		local odds = wheel.Odds
		local v5 = {}

		for i = 1, #EclipseSpinWheel.Rewards do
			local reward = EclipseSpinWheel.Rewards[i]

			if not reward then
				continue
			end

			if reward.Type == "Item" and v4:Get((`Items.{reward.Index}`)) and EclipseSpinWheel.AltRewards[i] then
				reward = EclipseSpinWheel.AltRewards[i]
			end

			v5[i] = reward.Weight
		end

		local total = 0

		for _, v6 in v5 do
			total += v6
		end

		v5[5] += 100 - total

		for i = 1, #EclipseSpinWheel.Rewards do
			local reward = EclipseSpinWheel.Rewards[i]

			if not reward then
				continue
			end

			if reward.Type == "Item" and v4:Get((`Items.{reward.Index}`)) and EclipseSpinWheel.AltRewards[i] then
				reward = EclipseSpinWheel.AltRewards[i]
			end

			local child = items:FindFirstChild((tostring(i)))
			local child2 = names:FindFirstChild((tostring(i)))
			local child3 = odds:FindFirstChild((tostring(i)))
			local v6 = ""
			local icon

			if reward.Type == "Cash-Pack" then
				local value = Shop[reward.Index].Value
				local rebirth = v4:Get("Rebirth") or 0

				if rebirth > 0 then
					value *= rebirth <= 1 and 1.5 or rebirth
				end

				v6 = `${NumberUtils:ToString(value, 2)}`
				icon = Marketplace:GetProductInfo(reward.Index, "Product").Icon
			else
				icon = reward.Icon
			end

			local display = reward.Display
			local v7 = v6 == "" and display or v6
			local formatted = `{math.floor(v5[i] * 100) / 100}%`
			child.Image = icon
			CustomRichTextController.apply(child2, v7, {
				attachToInstance = true
			})
			child3.Text = formatted
		end
	end

	setup()
	v4:OnDictionaryInserted("Items", function(_: boolean, p: string)
		local flag2 = false

		for i = 1, #EclipseSpinWheel.Rewards do
			local reward = EclipseSpinWheel.Rewards[i]

			if not (reward.Type == "Item" and p == reward.Index) then
				continue
			end

			flag2 = true
			break
		end

		if flag2 then
			while flag do
				task.wait()
			end

			setup()
		end
	end)
	local toggle = eclipseWheel.FastSpin.Toggle
	local v5 = AnimatedButton.new(toggle)
	v5:Animate()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFastSpin()
		toggle.Checkmark.Visible = visible
	end

	v5.OnActivated:Connect(function()
		visible = not visible
		updateFastSpin() -- equivalent call inferred; original call site unknown
	end)
	updateFastSpin() -- equivalent call inferred; original call site unknown

	for _, button in eclipseWheel.Buttons:GetChildren() do
		if not (button:IsA("ImageButton") and button.Name ~= "Spin") then
			continue
		end

		local v6 = v3[button.Name]

		if not v6 then
			continue
		end

		local v7 = AnimatedButton.new(button)
		v7:Animate()
		local v8 = v6
		v7.OnActivated:Connect(function()
			remoteEvent:FireServer(v8)
		end)
		local productInfo = Marketplace:GetProductInfo(v6, "Product")
		button.RbxAmount.Text = productInfo.PriceInRobux
	end

	local spin = eclipseWheel.Buttons.Spin
	local v6 = AnimatedButton.new(spin)
	v6:Animate()
	v6.OnActivated:Connect(function()
		if flag == true then
			return
		end

		remoteEvent2:FireServer()
	end)
	local v7 = nil
	task.spawn(function()
		v7 = Policy.getPolicy(localPlayer)
	end)

	local function mainLoop()
		local count = 0

		if ReplicatedStorage:GetAttribute("EclipseEvent") then
			if v4:Get("EclipseSpinWheel.LastFreeClaimed") == ReplicatedStorage:GetAttribute("EclipseEventLastTime") then
				spin.Main.Timer.Text = `Free Spin in {TimeUtils:D((ReplicatedStorage:GetAttribute("NextEclipseEvent") or 0) - workspace:GetServerTimeNow())}`
			else
				count += 1
				spin.Main.Timer.Text = "SPIN NOW"
			end
		else
			spin.Main.Timer.Text = `Free Spin in {TimeUtils:D((ReplicatedStorage:GetAttribute("NextEclipseEvent") or 0) - workspace:GetServerTimeNow())}`
		end

		local v8 = count + v4:Get("EclipseSpinWheel.Spins")
		spin.Main.Spins.Text = v8 > 1 and `Spins ({v8})` or `Spin ({v8})`
		spin.Main.UIGradient.Enabled = v8 <= 0
		local v9 = v7 and not v7.ArePaidRandomItemsRestricted
		local v10 = workspace:GetServerTimeNow() - v4:Get("EclipseSpinWheel.LastDailyDiscount") >= 86400
		eclipseWheel.Buttons.Buy1.Visible = not v10 and v9
		eclipseWheel.Buttons.Buy1Discount.Visible = v10 and v9
		local v11 = v4:Get("EclipseSpinWheel.PaidSpins.x3") >= 5
		eclipseWheel.Buttons.Buy10.Visible = v11 and v9
		eclipseWheel.Buttons.Buy3.Visible = not v11 and v9
	end

	remoteEvent2.OnClientEvent:Connect(function(p: number, flag2: boolean?)
		task.spawn(mainLoop)
		ResultAnimation(p, flag2)
	end)
	Timer.Simple(1, mainLoop)
	Observers.observeTag("EclipseSpinWheel", function(p)
		local v8 = EclipseSpinWheel2.new(p)
		return function()
			v8:Destroy()
		end
	end)
	ReplicatedStorage:GetAttributeChangedSignal("EclipseWheelActive"):Connect(function()
		if ReplicatedStorage:GetAttribute("EclipseWheelActive") == false and v:IsOpened() then
			InterfaceController:Toggle("EclipseWheel", false)
		end
	end)
	local v8 = Trove.new()

	local function renderLuckyBlock()
		v8:Clean()

		if not v:IsOpened() then
			return
		end

		local luckyBlock = eclipseWheel:FindFirstChild("LuckyBlock")
		local contents = luckyBlock and luckyBlock:FindFirstChild("Contents")
		local template = contents and contents:FindFirstChild("Template")

		if not (contents and template) then
			return
		end

		for _, reward in EclipseSpinWheel.Rewards do
			if not (reward.Type == "Animal" and reward.Index == "Secret Lucky Block") then
				continue
			end

			local mutation = reward.Mutation
			local v9 = {}

			for _, animal in LuckyBlocks[reward.Index].Animals do
				if (not animal.IsEnabled or animal.IsEnabled()) and animal.Chance then
					table.insert(v9, {
						animal = animal.Name,
						chance = animal.Chance
					})
				end
			end

			table.sort(v9, function(a, b)
				return b.chance < a.chance
			end)

			for k, v10 in v9 do
				local clone = v8:Clone(template)
				clone.Name = tostring(k)
				clone.LayoutOrder = k
				clone.Label.Text = Animals[v10.animal].DisplayName
				clone.Chance.Text = `{v10.chance}%`
				clone.Visible = true
				clone.Parent = contents
				local v11 = Animals2:AttachOnViewport(v10.animal, clone.ViewportFrame, true, mutation)

				if v11 then
					v8:Add(v11)
				end
			end

			break
		end
	end

	v.OnOpen:Connect(renderLuckyBlock)
	v.OnClose:Connect(function()
		v8:Clean()
	end)
	Updates.OnUpdateEnabled:Connect(renderLuckyBlock)
	Updates.OnUpdateDisabled:Connect(renderLuckyBlock)
end

function EclipseEventController:Start()
	self:SetupEclipseWheel()
end

return EclipseEventController