local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v5 = require3(ReplicatedStorage2.Packages.Replion)
local v6 = require3(ReplicatedStorage2.Packages.Trove)
local v7 = require3(ReplicatedStorage2.Shared.FastUtils)
local v8 = require3(ReplicatedStorage2.Common.GlobalTieredCrate)
local v9 = require3(ReplicatedStorage2.Controllers.VisualizerController)
local v10 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local playerGui = Players.LocalPlayer.PlayerGui
local globalTieredCrate = playerGui:WaitForChild("GlobalTieredCrate")
local frame = globalTieredCrate.Frame
local crate = frame.Crate
local globalTieredCrateOpen = playerGui:WaitForChild("GlobalTieredCrateOpen")
local render = globalTieredCrateOpen.Render
local clickDetector = globalTieredCrateOpen.ClickDetector
local remoteFunction = v:RemoteFunction("GlobalTieredCrate/GetPurchases")
local remoteFunction2 = v:RemoteFunction("GlobalTieredCrate/IsActive")
local remoteFunction3 = v:RemoteFunction("GlobalTieredCrate/Open")
local GlobalTieredCrateController = {}
local maid = v6.new()

function GlobalTieredCrateController:DoCrateAnimation(instance)
	local objectSpace = instance.Parent:GetPivot():ToObjectSpace(instance:GetPivot())
	instance:GetPivot()
	local scale = instance:GetScale()
	local v11 = maid:Add(Instance.new("CFrameValue"))
	local v12 = maid:Add(Instance.new("NumberValue"))
	v12.Value = scale
	local v13 = maid:Add(Instance.new("NumberValue"))
	local v14 = maid:Add(Instance.new("NumberValue"))
	maid:Add(RunService.Heartbeat:Connect(function()
		if not instance.Parent then
			return
		end

		instance:PivotTo(instance.Parent:GetPivot() * objectSpace * v11.Value * CFrame.Angles(
			0,
			math.rad(180 + v13.Value),
			0
		))
		instance:ScaleTo(v12.Value)
		local lid = instance:FindFirstChild("Lid")

		if lid then
			lid:PivotTo(instance.LidAttachment.WorldCFrame * CFrame.Angles(math.rad(v14.Value), 0, 0))
		end
	end))
	v11.Value = CFrame.new(0, scale * 5, 0)
	v7.fastTween(v11, TweenInfo.new(0.75, Enum.EasingStyle.Bounce), {
		Value = CFrame.identity
	}).Completed:Wait()
	v7.fastTween(v13, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
		Value = 360
	})
	v7.fastTween(v12, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
		Value = scale * 0.8
	}).Completed:Wait()
	task.wait(0.2)
	v13.Value = 0
	v7.fastTween(v12, TweenInfo.new(0.75), {
		Value = scale * 0.5
	})

	for i = 1, 10 do
		v7.fastTween(v13, TweenInfo.new(0.075), {
			Value = (15 - i) * (i % 2 == 0 and 1 or -1)
		}).Completed:Wait()
	end

	v7.fastTween(v11, TweenInfo.new(0.1), {
		Value = CFrame.Angles(-0.3490658503988659, 0, 0)
	})
	v7.fastTween(v12, TweenInfo.new(0.1), {
		Value = scale * 0.8
	})
	v7.fastTween(v13, TweenInfo.new(0.1), {
		Value = 0
	})
	v7.fastTween(v14, TweenInfo.new(0.1), {
		Value = -40
	}).Completed:Wait()
end

local v11 = false
local maid2 = v6.new()

function GlobalTieredCrateController:Render(list, flag: boolean?, instance)
	v11 = true
	maid2:Clean()
	render.Visible = true
	local _10

	if #list > 3 then
		_10 = render["10"]
	elseif #list > 2 then
		_10 = render["3"]
	else
		_10 = render["1"]
	end

	for _, child in render:GetChildren() do
		child.Visible = child == _10
	end

	if not v2:IsOpen("GlobalTieredCrateOpen") then
		v2:Open("GlobalTieredCrateOpen")
	end

	v2:Lock("GlobalTieredCrateOpen")
	local name = tonumber(_10.Name) or #list
	local v12 = math.min(name, 5)
	local v13 = math.floor((name - 1) / 5 + 1)
	local model = Instance.new("Model")
	model.Parent = workspace
	local v14 = false

	for i = 1, name do
		local child = _10:FindFirstChild(tostring(i), true)
		child.Card.Visible = false
		local v15 = list[i]

		if not v15 then
			continue
		end

		local v16

		if flag then
			v16 = nil
		else
			v16 = maid2:Add(instance:Clone())
			local v17 = (i - 1) % 5 + 1 - v12 / 2 - 0.5
			local v18 = math.floor((i - 1) / 5 + 1) - v13 / 2 - 0.5
			v16:PivotTo(CFrame.new(v17 * 6, v18 * 6, 0))
			v16.Parent = model
		end

		local v17 = child
		local v18 = v15
		task.delay(0.1, function()
			if v16 then
				v16:PivotTo(CFrame.lookAt(v16:GetPivot().Position, workspace.CurrentCamera.CFrame.Position))
				self:DoCrateAnimation(v16)
			end

			v17.Card.Title.TextLabel.Text = v18.DisplayName
			v17.Card.Vector.Image = v18.Icon
			v17.Card.Visible = true

			if not v14 then
				v14 = true
				maid2:Clean()
			end
		end)
	end

	if not flag then
		v9:Visualize(model, (v12 - 1) * 0.3 + 1)
	end

	task.wait(3.5)
	clickDetector.Visible = true
	local thread = coroutine.running()
	task.defer(function()
		clickDetector.Activated:Wait()

		if thread then
			task.spawn(thread)
			thread = nil
		end
	end)
	task.delay(3, function()
		if thread then
			task.spawn(thread)
			thread = nil
		end
	end)
	coroutine.yield()
	clickDetector.Visible = false
	render.Visible = false
	v11 = false
	v2:Unlock("GlobalTieredCrateOpen")
	v2:Close("GlobalTieredCrateOpen")
	v9:Clear()
	v2:Open("GlobalTieredCrate")
end

local flag = false

function GlobalTieredCrateController:Open(p: number)
	if flag then
		return
	end

	flag = true
	local v12, v13 = remoteFunction3:InvokeServer(p)
	task.defer(GlobalTieredCrateController.Refresh, GlobalTieredCrateController)
	flag = false

	if v12 then
		self:Render(v13.rewards, false, script[`Crate{v13.tier}`])
	end
end

local function fixNumber(p: number)
	for i = 6, 1, -1 do
		local v12 = 10 ^ i
		local v13 = p * v12
		local v14 = v13 % 1

		if math.floor(v13) == v13 then
			continue
		end

		if v14 < 0.0001 then
			p = math.floor(v13) / v12
		elseif 1 - v14 < 0.0001 then
			p = math.ceil(v13) / v12
		end
	end

	return p
end

local maid3 = v6.new()

function GlobalTieredCrateController:Refresh()
	if remoteFunction2:InvokeServer() then
		local key = v4:GetKey("GlobalTieredCrateTiers")

		if not key then
			return
		end

		local key2 = v4:GetKey("GlobalTieredCrateEnd")

		if not key2 then
			return
		end

		local replion = v5.Client:GetReplion("Data")

		if not replion then
			return
		end

		local v12 = remoteFunction:InvokeServer() or 0
		local tier = v8.getTier(key, v12)
		maid3:Clean()
		local v13 = replion:Get({ "GlobalTieredCrateContributions", v8.CrateId }) or 0
		crate.Timer.Text = `Ends In: {v3.ValueConvertor:FormatTimeWithDays(key2 - os.time())}`
		crate.Tier.TierLvl.Text = `Tier {tier}`
		crate.Tier.YourContributions.Text = `Your Contributions: {v13} Crates`
		local v14 = tier == #key
		local v15 = key[tier - 1] or 0
		local v16 = key[tier]
		crate.Tier.Bar.Fill.Size = UDim2.fromScale(v14 and 1 or math.clamp(v12 / v16, 0, 1), 1)
		crate.Tier.Start.Text = `{v3.ValueConvertor:ShrinkNumber(v12)} Crates`
		crate.Tier.Start.Visible = not v14
		crate.Tier.Goal.Text = `{v3.ValueConvertor:ShrinkNumber(v14 and 1e999 or v16)} Crates`
		local price = v8.getPrice(tier, math.map(v12, v15, v16, 0, 1))
		crate.PurchaseButtons.Buy1.Cost.Text = `{v3.ValueConvertor:AddCommas(price)} Coins`
		crate.PurchaseButtons.Buy10.Cost.Text = `{v3.ValueConvertor:AddCommas(price * 10)} Coins`
		local reward = v8.Rewards[tier]
		local v17 = {}
		local total = 0

		for k, v18 in reward do
			table.insert(v17, k)
			total += v18
		end

		table.sort(v17, function(a, b)
			return reward[a] > reward[b]
		end)

		for i = 1, 5 do
			local child = crate.Rewards:FindFirstChild((`{i}`))
			local v18 = v17[i]

			if v18 then
				child.Visible = true
				child.ItemName.Text = v18.DisplayName
				local v19 = reward[v18] / total * 100
				local itemChance = child.ItemChance
				local text

				if v19 < 0.01 then
					text = `{fixNumber(v19)}%`
				else
					text = `{math.round(v19 * 100) / 100}%`
				end

				itemChance.Text = text
				child.ItemDecal.Image = v18.Icon or ""
				local v21 = v18
				maid3:Add(child.ViewItem.Activated:Connect(function()
					v10:PreviewReward(v21, "GlobalTieredCrate")
				end))
			else
				child.Visible = false
			end
		end

		local v18 = 0

		for _, v19 in v8.ContributionsLuck do
			v18 = math.max(v18, v19.Required)
		end

		for _, v19 in v8.ContributionsLuck do
			local clone = crate.Luck.Objectives.Objective:Clone()
			clone.Position = UDim2.fromScale(0.416, 1 - v19.Required / v18 * 0.9)
			clone.Timer.Text = `{v19.Required} Crates`
			clone.Luck.Text = `{v19.Luck}x Luck`
			clone.Visible = true
			clone.Parent = crate.Luck.Objectives
			maid3:Add(clone)
		end

		crate.Luck.LuckBar.Fill.Size = UDim2.fromScale(1, (math.clamp(v13 / v18 * 0.9, 0, 1)))

		for _, v19 in CollectionService:GetTagged("GlobalTieredCrateTimerLabel") do
			v19:SetAttribute("EndTime", key2)
		end
	elseif v2:IsOpen("GlobalTieredCrate") then
		v2:Close("GlobalTieredCrate")
	end
end

function GlobalTieredCrateController.Start(_)
	globalTieredCrate:GetPropertyChangedSignal("Enabled"):Connect(function()
		if globalTieredCrate.Enabled then
			GlobalTieredCrateController:Refresh()
		end
	end)
	task.spawn(function()
		local key = v4:GetKey("GlobalTieredCrateEnd")

		for _, v12 in CollectionService:GetTagged("GlobalTieredCrateTimerLabel") do
			v12:SetAttribute("EndTime", key)
		end
	end)
	task.spawn(function()
		frame.CloseButton.Activated:Connect(function()
			v2:Close("GlobalTieredCrate")
		end)

		while not remoteFunction2:InvokeServer() do
			task.wait(5)
		end

		crate.PurchaseButtons.Buy1.Activated:Connect(function()
			GlobalTieredCrateController:Open(1)
		end)
		crate.PurchaseButtons.Buy10.Activated:Connect(function()
			GlobalTieredCrateController:Open(10)
		end)

		while true do
			if v2:IsOpen("GlobalTieredCrate") then
				task.spawn(GlobalTieredCrateController.Refresh, GlobalTieredCrateController)
			end

			task.wait(5)
		end
	end)
end

return GlobalTieredCrateController