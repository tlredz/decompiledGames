local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
require3(ReplicatedStorage2.Common.MarketplaceService)
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Shared.SealCrate.SealCrates)
local v4 = require3(ReplicatedStorage2.Shared.WeightRandom)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Common.RewardInfo)
local v6 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v7 = require3(ReplicatedStorage2.Packages.Trove)
local v8 = require3(ReplicatedStorage2.Shared.FastUtils)
local v9 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v10 = require3(ReplicatedStorage2.Controllers.VisualizerController)
local v11 = require3(ReplicatedStorage2.Common.Utils)
local v12 = require3(ReplicatedStorage2.Controllers.StPatricksDayEventController)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local remoteFunction = v2:RemoteFunction("OpenSealCrate")
local sealCrates = playerGui:WaitForChild("SealCrates")
local render = sealCrates.Render
local clickDetector = sealCrates.ClickDetector

local function shorten(p: number)
	for i = 6, 1, -1 do
		local v13 = 10 ^ i
		local v14 = p * v13
		local v15 = v14 % 1

		if math.floor(v14) == v14 then
			continue
		end

		if v15 < 0.0001 then
			p = math.floor(v14) / v13
		elseif 1 - v15 < 0.0001 then
			p = math.ceil(v14) / v13
		end
	end

	return p
end

local v13 = nil
local v14 = nil
local maid = v7.new()
local SealCrateController = {
	DoCrateAnimation = function(self, instance)
		local objectSpace = instance.Parent:GetPivot():ToObjectSpace(instance:GetPivot())
		instance:GetPivot()
		local scale = instance:GetScale()
		local v15 = maid:Add(Instance.new("CFrameValue"))
		local v16 = maid:Add(Instance.new("NumberValue"))
		v16.Value = scale
		local v17 = maid:Add(Instance.new("NumberValue"))
		local v18 = maid:Add(Instance.new("NumberValue"))
		maid:Add(RunService.Heartbeat:Connect(function()
			if not instance.Parent then
				return
			end

			instance:PivotTo(instance.Parent:GetPivot() * objectSpace * v15.Value * CFrame.Angles(
				0,
				math.rad(180 + v17.Value),
				0
			))
			instance:ScaleTo(v16.Value)
			local lid = instance:FindFirstChild("Lid")

			if lid then
				lid:PivotTo(instance.Main.Attachment.WorldCFrame * CFrame.Angles(math.rad(v18.Value), 0, 0))
			end
		end))
		v15.Value = CFrame.new(0, scale * 5, 0)
		v8.fastTween(v15, TweenInfo.new(0.75, Enum.EasingStyle.Bounce), {
			Value = CFrame.identity
		}).Completed:Wait()
		v8.fastTween(v17, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
			Value = 360
		})
		v8.fastTween(v16, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
			Value = scale * 0.8
		}).Completed:Wait()
		task.wait(0.2)
		v17.Value = 0
		v8.fastTween(v16, TweenInfo.new(0.75), {
			Value = scale * 0.5
		})

		for i = 1, 10 do
			v8.fastTween(v17, TweenInfo.new(0.075), {
				Value = (15 - i) * (i % 2 == 0 and 1 or -1)
			}).Completed:Wait()
		end

		v8.fastTween(v15, TweenInfo.new(0.1), {
			Value = CFrame.Angles(-0.3490658503988659, 0, 0)
		})
		v8.fastTween(v16, TweenInfo.new(0.1), {
			Value = scale * 0.8
		})
		v8.fastTween(v17, TweenInfo.new(0.1), {
			Value = 0
		})
		v8.fastTween(v18, TweenInfo.new(0.1), {
			Value = -40
		}).Completed:Wait()
	end,
	Open = function(self, p: string)
		if not v3.IsActive() then
			return
		end

		for _, child in sealCrates.Views:GetChildren() do
			child.Visible = child.Name == p
		end

		if not v5:IsOpen("SealCrates") then
			v5:Open("SealCrates")
		end
	end
}
local v15 = {}
local flag = false
local v16 = false
local maid2 = v7.new()

function SealCrateController:Render(p: string, list, flag2: boolean?, flag3: boolean?)
	v16 = true
	flag = true
	script:SetAttribute("Rolling", true)
	maid2:Clean()
	local name = nil

	for _, child in sealCrates.Views:GetChildren() do
		if child.Visible then
			name = child.Name
		end

		child.Visible = false
	end

	render.Visible = true
	sealCrates.Darkness.Visible = false
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

	if not v5:IsOpen("SealCrates") then
		v5:Open("SealCrates")
	end

	v5:Lock("SealCrates")
	local name2 = tonumber(_10.Name) or #list
	local v17 = math.min(name2, 5)
	local v18 = math.floor((name2 - 1) / 5 + 1)
	local model = Instance.new("Model")
	model.Parent = workspace
	local v19 = false

	for i = 1, name2 do
		local child = _10:FindFirstChild(tostring(i), true)
		child.Card.Visible = false
		local v20 = list[i]

		if not v20 then
			continue
		end

		local v21

		if flag3 then
			v21 = nil
		else
			v21 = maid2:Add(script[p]:Clone())
			local v22 = (i - 1) % 5 + 1 - v17 / 2 - 0.5
			local v23 = math.floor((i - 1) / 5 + 1) - v18 / 2 - 0.5
			v21:PivotTo(CFrame.new(v22 * 6, v23 * 6, 0))
			v21.Parent = model
		end

		local v22 = child
		local v23 = v20
		task.delay(0.1, function()
			if v21 then
				v21:PivotTo(CFrame.lookAt(v21:GetPivot().Position, workspace.CurrentCamera.CFrame.Position))
				self:DoCrateAnimation(v21)
			end

			v22.Card.Title.TextLabel.Text = v23.DisplayName
			v22.Card.Vector.Image = v23.Icon
			v22.Card.Visible = true

			if not v19 then
				v8.fastAudio(
					#list > 3 and "rbxassetid://130120626829936" or #list > 2 and "rbxassetid://126310880215822" or "rbxassetid://71807111169811",
					sealCrates
				)
				v19 = true
				maid:Clean()
				maid2:Clean()
			end
		end)
	end

	if not flag3 then
		v10:Visualize(model, (v17 - 1) * 0.3 + 1)
		v8.fastAudio("rbxassetid://101020618689938", sealCrates)
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
	sealCrates.Darkness.Visible = true
	render.Visible = false
	script:SetAttribute("Rolling", false)
	flag = false
	v16 = false
	v5:Unlock("SealCrates")

	if flag2 then
		v5:Close("SealCrates")
		v10:Clear()
	else
		self:Open(name)
	end
end

function SealCrateController:Start()
	v13 = v.Client:WaitReplion("Data")
	v14 = v.Client:WaitReplion("LimitedStockItems")

	for k, crate in v3.Crates do
		local weights = v4.getWeights(crate.Rewards)
		local view = sealCrates.Views[k]
		local v17 = {}

		for k2, relativeWeight in weights.relativeWeights do
			table.insert(v17, { relativeWeight, k2 })
		end

		table.sort(v17, function(a, b)
			return a[1] > b[1]
		end)

		for k2, v18 in v17 do
			local _ = v18[1]
			local v19 = v18[2]
			local option = weights.options[v19]
			local v20 = view.CrateDisplay[tostring(k2)]

			if not v20 then
				continue
			end

			local v21 = nil
			local v22 = true
			local v23 = crate
			local v24 = option
			local v25 = v20
			local v26 = k

			local function updateChance()
				local serverTimeNow = workspace:GetServerTimeNow()
				local v27 = v11.FFlag.GetInstantFFlag("SealCrateLuckStartTime", 0) <= serverTimeNow and serverTimeNow < v11.FFlag.GetInstantFFlag(
					"SealCrateLuckEndTime",
					0
				) and 1 or v12:HasLuck() and 1 or nil

				if v27 == v21 and not v22 then
					return
				end

				v22 = false
				v21 = v27
				local weights2 = v4.getWeights(v23.Rewards, v27)
				local v28 = 0

				for k3, relativeWeight in weights2.relativeWeights do
					if weights2.options[k3] == v24 then
						v28 = relativeWeight
					end
				end

				local v29 = shorten(v28)
				local v30

				if v29 % 1 == 0 then
					v30 = v29
				else
					v30 = string.format("%.1f", v29 * 100):gsub("(%.0+)$", "")
				end

				v25.Chance.Text = `{v30}%`

				if v26 == "Free" and v29 <= 0.04 then
					v25.Chance.Text = "???"
				end
			end

			task.spawn(updateChance)
			v11.FFlag.OnChange(updateChance)
			v11.Thread.Every(1, updateChance)
			v20.Label.Text = option.DisplayName
			v20.Vector.Image = option.Icon
			v15[`{option.Type}:{option.Value}`] = v20
		end

		view.Close.Activated:Connect(function()
			v5:Close("SealCrates")
		end)
		local v18 = k == "Free" and "Chroma" or "Free"
		local crate2 = v3.Crates[v18]
		view.CrateOpenButton.Label.Text = v18 == "Chroma" and "Slime" or "Free"
		view.CrateOpenButton.Vector.Image = crate2.Icon
		view.CrateOpenButton.Activated:Connect(function()
			self:Open(v18)
		end)
		v6.observeReplionPath(v13, "SealCrate.OpenedFreeCrates", function(p)
			view.Reminder.Info.Text = `OPEN {v3.OpenedFreeCrateRequirement - p} MORE FREE CRATES FOR {v3.OpenedFreeCrateChromaRewardAmount} SLIME CRATES`
		end)
		local v21 = view

		local function updateStock()
			local v22 = v14:Get({ "Stock", v3.LimitedStockRewardId })
			v14:Get({ "InitialStock", v3.LimitedStockRewardId })
			v21.GrandPrize.Left.Text = `{v11.ValueConvertor:AddCommas(v22 or 0)} Left`
		end

		v14:OnChange({ "Stock", v3.LimitedStockRewardId }, updateStock)
		v14:OnChange({ "InitialStock", v3.LimitedStockRewardId }, updateStock)
		updateStock()
		view.GrandPrize.Label.Text = v3.BigReward.DisplayName
		view.GrandPrize.Vector.Image = v3.BigReward.Icon
	end

	v2:Connect("PlaySealCrateAnimation", function(p, value: string?, flag2: boolean?, flag3: boolean?)
		self:Render(value or "Chroma", p, flag2, flag3)
	end)
	local chroma = sealCrates.Views.Chroma
	chroma.Buttons.Buy1.Activated:Connect(function()
		if flag then
			return
		end

		local v17, v18 = remoteFunction:InvokeServer("Chroma", 1)

		if v17 then
			self:Render("Chroma", v18)
		end
	end)
	chroma.Buttons.Buy3.Activated:Connect(function()
		if flag then
			return
		end

		local v17, v18 = remoteFunction:InvokeServer("Chroma", 3)

		if v17 then
			self:Render("Chroma", v18)
		end
	end)
	chroma.Buttons.Buy10.Activated:Connect(function()
		if flag then
			return
		end

		local v17, v18 = remoteFunction:InvokeServer("Chroma", 10)

		if v17 then
			self:Render("Chroma", v18)
		end
	end)
	chroma.Buttons.Gift.Activated:Connect(function()
		v9:SetGift("SealChroma_10")
	end)
	local free = sealCrates.Views.Free
	v6.observeReplionPath(v13, "SealCrate.FreeCrateKills", function(p: number)
		local v17 = math.clamp(p / v3.FreeCrateKillsRequirement, 0, 1)
		free.Bar.Bar.Fill.Size = UDim2.fromScale(v17, 1)
		free.Bar.KillCounter.Total.Text = `{p}/{v3.FreeCrateKillsRequirement}`
	end)
	task.delay(10, function()
		while true do
			if localPlayer.Character and localPlayer.Character.Parent == workspace.Alive or (v13:Get("SealCrate.FreeCrates") or 0) < 1 then
				task.wait(1)
			else
				while (v13:Get("SealCrate.FreeCrates") or 0) >= 1 do
					local v17 = v13:Get("SealCrate.FreeCrates")
					local v18 = v17 >= 10 and 10 or v17 >= 3 and 3 or 1

					while flag do
						task.wait()
					end

					local v19, v20 = remoteFunction:InvokeServer("Free", v18)

					if v19 then
						self:Render("Free", v20, not v5:IsOpen("SealCrates"))
					end
				end
			end
		end
	end)
end

return SealCrateController