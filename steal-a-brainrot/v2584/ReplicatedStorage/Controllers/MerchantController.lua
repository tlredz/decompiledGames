local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("ServerStorage")
game:GetService("SoundService")
game:GetService("TweenService")
game:GetService("HttpService")
local RunService = game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
require(ReplicatedStorage.Packages.Serialization)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Packages.TopbarPlus)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local stockCache = ReplicatorClient.get("StockCache")
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
require(ReplicatedStorage.Controllers.NotificationController)
require(ReplicatedStorage.Controllers.NewPlayersController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.CharacterController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.PlotController)
local ShopController = require(ReplicatedStorage.Controllers.ShopController)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local VFX = require(ReplicatedStorage.Shared.VFX)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
require(ReplicatedStorage.Shared.Updates)
require(ReplicatedStorage.Shared.Animals)
local Animals = require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Shared.Index)
local Mutations2 = require(ReplicatedStorage.Datas.Mutations)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local MerchantData = require(ReplicatedStorage.Datas.MerchantData)
local localPlayer = Players.LocalPlayer
local merchant = localPlayer.PlayerGui:WaitForChild("Merchant").Merchant
local frame = merchant.Frame
local list = frame.List
local close = frame.Header.Close
local remoteEvent = Net:RemoteEvent("MerchantService/SetFocused")
local remoteEvent2 = Net:RemoteEvent("MerchantService/Animation")
local remoteEvent3 = Net:RemoteEvent("ShopService/Purchase")
local remoteFunction = Net:RemoteFunction("MerchantService/Buy")
local v = nil
local v2 = RunService:IsStudio() and false

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, maid)
	local track = animator:LoadAnimation(animation)
	maid:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local function getIntervalInSeconds(p: number?)
	local wday = os.date("!*t", (p or workspace:GetServerTimeNow()) // 1).wday

	if wday == 1 or wday == 7 then
		return (FFlags:GetInstant("WeekendMerchantRefreshTime", 1800))
	end

	return (FFlags:GetInstant("WeekdayMerchantRefreshTime", 1800))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRefreshTimestamp(serverTimeNow: number?)
	local v3 = serverTimeNow or workspace:GetServerTimeNow()
	local intervalInSeconds = getIntervalInSeconds(v3)
	return v3 + (intervalInSeconds - v3 % intervalInSeconds)
end

return {
	Start = function(_)
		merchant.Visible = false
		v = InterfaceController:Register("Merchant", merchant, "TopQuint")
		v:AttachCloseButton(close)
		v.OnOpen:Connect(function()
			remoteEvent:FireServer("279bddcd-037a-4a63-94d7-337d00e79754", true)
		end)
		v.OnClose:Connect(function()
			remoteEvent:FireServer("279bddcd-037a-4a63-94d7-337d00e79754", false)
		end)
		v:Close()

		local function renderBrainrotAtFrame(brainrot, brainrot2)
			local animal = Animals2[brainrot2]

			if not animal then
				return
			end

			local rarity = Rarities[animal.Rarity]
			brainrot.Title.Text = Animals:GetDisplayName(brainrot2)

			if rarity.GradientPreset then
				brainrot.UIStroke.Color = Color3.new(1, 1, 1)
				brainrot.Title.TextColor3 = Color3.new(1, 1, 1)
				Gradients.apply(brainrot.UIStroke, rarity.GradientPreset)
				Gradients.apply(brainrot.Title, rarity.GradientPreset)
			else
				brainrot.UIStroke.Color = rarity.Color
				brainrot.Title.TextColor3 = rarity.Color
			end

			brainrot.Visible = true
			Animals:AttachOnViewportWithOptimizations(brainrot2, brainrot.ViewportFrame)
		end

		local clones = table.create(#MerchantData.Brainrots)
		local v3 = Signal.new()
		local v4 = Signal.new()
		local v5 = nil

		for k, brainrot in MerchantData.Brainrots do
			local brainrot2 = brainrot.Brainrot
			local animal = Animals2[brainrot2]
			local clone = list.UIListLayout[brainrot.Template or "Normal"]:Clone()
			clones[k] = clone
			clone.Visible = true
			clone.LayoutOrder = (k - 1) * 2
			local clone2

			if brainrot.ProductId then
				clone2 = list.UIListLayout.DropdownFull:Clone()
			else
				clone2 = list.UIListLayout.DropdownCoins:Clone()
			end

			clone2.LayoutOrder = clone.LayoutOrder + 1
			clone2.Size = UDim2.fromScale(0.973, 0)
			clone2.Visible = false
			clone2.Parent = list
			renderBrainrotAtFrame(clone.Spacer.Brainrot, brainrot2)
			local v6 = brainrot

			local function updateStock()
				local dateTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
				local formatUniversalTime = dateTime:FormatUniversalTime("YYYY", "en-us")
				local formatUniversalTime2 = dateTime:FormatUniversalTime("MM", "en-us")
				local formatUniversalTime3 = dateTime:FormatUniversalTime("DD", "en-us")
				local formatUniversalTime4 = dateTime:FormatUniversalTime("HH", "en-us")
				local v9 = (tonumber((dateTime:FormatUniversalTime("mm", "en-us"))) or 0) < 30 and "00" or "30"
				local v11 = stockCache:TryIndex({
					"stock",
					(`{v6.StockKey}-{formatUniversalTime}{formatUniversalTime2}{formatUniversalTime3}-{formatUniversalTime4}{v9}`)
				}) or 0
				local v12 = v2 and 1 or v11
				clone.Spacer.Left.Txt.Text = not (v12 > 0) and "SOLD OUT" or `{NumberUtils:Comma(v12)} Left`
				local left = clone.Spacer.Left
				local backgroundColor

				if v12 > 0 then
					backgroundColor = Color3.fromRGB(33, 135, 40)
				else
					backgroundColor = Color3.fromRGB(185, 52, 52)
				end

				left.BackgroundColor3 = backgroundColor
				local cash = clone2.Spacer.Cash
				local backgroundColor2

				if v12 > 0 then
					backgroundColor2 = Color3.fromRGB(81, 158, 86)
				else
					backgroundColor2 = Color3.fromRGB(127, 127, 127)
				end

				cash.BackgroundColor3 = backgroundColor2
				clone2.Spacer.Cash.Interactable = v12 > 0
			end

			updateStock()
			v4:Connect(updateStock)
			stockCache:ListenRaw(updateStock)
			clone.Spacer.DropRate.Text = `${NumberUtils:ToString(Animals:GetGeneration(brainrot2))}/s`

			if animal then
				clone2.Spacer.Cash.Txt.Text = `${NumberUtils:ToString(animal.Price or 0)}`
			else
				clone2.Spacer.Cash.Txt.Text = "$???"
			end

			if brainrot.ProductId then
				clone2.Spacer.Robux.Txt.Text = "???"
				local v9 = brainrot
				local v10 = clone2
				task.spawn(function()
					-- equivalent calls inferred from this helper; original call sites unknown
					local function formatPriceInRobux(p)
						if p == 999999999 then
							return "???"
						end

						return (NumberUtils:Comma(p))
					end

					local productInfo = Marketplace:GetProductInfo(v9.ProductId, "Product")
					local txt = v10.Spacer.Robux.Txt
					local priceInRobux = productInfo.PriceInRobux or 999999999
					txt.Text = ("%*"):format(formatPriceInRobux(priceInRobux))
				end)
			end

			clone.Spacer.Txt.Text = Animals:GetDisplayName(brainrot2)

			if animal then
				local rarity = Rarities[animal.Rarity]

				if rarity.GradientPreset then
					clone.Spacer.Txt.TextColor3 = Color3.new(1, 1, 1)
					Gradients.apply(clone.Spacer.Txt, rarity.GradientPreset)
				else
					clone.Spacer.Txt.TextColor3 = rarity.Color
				end
			end

			clone.Parent = list
			local v9 = clone
			local v10 = clone2
			local v11 = k

			local function updateFocus(p, p2)
				if p == v9 then
					v10.Visible = true
					Spr.target(v10, 0.9, 6, {
						Size = UDim2.fromScale(0.973, 0.192)
					})
					local v12 = v9.AbsolutePosition.Y - list.AbsolutePosition.Y + list.CanvasPosition.Y

					if p2 ~= nil and p2 ~= p and table.find(clones, p2) < v11 then
						v12 -= 0.192 * list.AbsoluteSize.Y
					end

					Spr.target(list, 1, 4, {
						CanvasPosition = Vector2.new(0, v12)
					})
				else
					Spr.target(v10, 1, 6, {
						Size = UDim2.fromScale(0.973, 0)
					})
					Spr.completed(v10, function()
						if v10.Size.Y.Scale < 0.01 then
							v10.Visible = false
						end
					end)
				end
			end

			v3:Connect(updateFocus)
			local v12 = clone
			AnimatedButton.new(clone.Spacer).OnActivated:Connect(function()
				SoundController:PlaySound("Sounds.Sfx.Activated")
				local v13 = v5
				local v14

				if v5 ~= v12 then
					v14 = v12
				end

				v5 = v14
				v3:Fire(v5, v13)
			end)
			local v13 = AnimatedButton.new(clone2.Spacer.Cash)
			v13:Animate()
			local v14 = k
			v13.OnActivated:Connect(function()
				if remoteFunction:InvokeServer("9ab73813-531e-4fb1-a671-1fe4ac4a2136", v14) then
					SoundController:PlaySound("Sounds.Sfx.Success")
					InterfaceController:SetState("Merchant", false)
				end
			end)

			if not brainrot.ProductId then
				continue
			end

			local v15 = AnimatedButton.new(clone2.Spacer.Robux)
			v15:Animate()
			local v16 = brainrot
			v15.OnActivated:Connect(function()
				remoteEvent3:FireServer(v16.ProductId)
			end)
			local v17 = AnimatedButton.new(clone2.Spacer.Gift)
			v17:Animate()
			local v18 = brainrot
			v17.OnActivated:Connect(function()
				if ShopController.GiftFrame.Visible then
					return
				end

				ShopController:RemoveGiftingTarget()
				ShopController:OpenGiftingScreen()
				ShopController.GiftFrame:GetPropertyChangedSignal("Visible"):Wait()

				if not v:IsOpened() then
					return
				end

				local giftingTarget = ShopController:GetGiftingTarget()

				if giftingTarget then
					remoteEvent3:FireServer(v18.ProductId, giftingTarget)
				end

				ShopController:RemoveGiftingTarget()
			end)
		end

		local function updateMutation()
			local v6 = Mutations.get()
			frame.Mutation.Visible = v6 ~= nil

			if v6 == nil then
				Spr.target(frame.Mutation, 1, 4, {
					Position = UDim2.fromScale(0.5, 0.9)
				})
				Spr.target(frame, 1, 4, {
					Position = UDim2.fromScale(0.5, 0.5)
				})
			else
				Spr.target(frame.Mutation, 1, 4, {
					Position = UDim2.fromScale(0.5, 1.01)
				})
				Spr.target(frame, 1, 4, {
					Position = UDim2.fromScale(0.5, 0.44)
				})
			end

			if v6 then
				local mutation = Mutations2[v6]
				assert(mutation)
				frame.Mutation.Frame.Icon.Image = mutation.Icon
				frame.Mutation.Frame.Txt.Text = `10% Chance of buying {mutation.DisplayText}`

				if v6 == "YinYang" then
					frame.Mutation.UIStroke.UIGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
						ColorSequenceKeypoint.new(0.49, Color3.new(0, 0, 0)),
						ColorSequenceKeypoint.new(0.51, Color3.new(1, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
					})
				else
					frame.Mutation.UIStroke.UIGradient.Color = ColorSequence.new(mutation.MainColor)
				end
			end
		end

		Mutations.watch(updateMutation)
		updateMutation()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getMinuteBucket(serverTimeNow: number?)
			if (tonumber((DateTime.fromUnixTimestamp(serverTimeNow or workspace:GetServerTimeNow()):FormatUniversalTime(
				"mm",
				"en-us"
			))) or 0) < 30 then
				return "00"
			end

			return "30"
		end

		local v6 = (tonumber((DateTime.fromUnixTimestamp((workspace:GetServerTimeNow())):FormatUniversalTime(
			"mm",
			"en-us"
		))) or 0) < 30 and "00" or "30"
		Timer.Simple(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local formatted = `Restocking in {TimeUtils:E(getRefreshTimestamp(serverTimeNow) - serverTimeNow)}`
			local minuteBucket = getMinuteBucket(serverTimeNow) -- equivalent call inferred; original call site unknown

			if v6 ~= minuteBucket then
				v6 = minuteBucket
				v4:Fire()
			end

			frame.Header.Txt1.Text = formatted
			local merchant2 = workspace:FindFirstChild("Merchant")

			if merchant2 then
				merchant2.Overhead.BillboardGui.Countdown.Text = formatted
			end
		end)
		Observers.observeTag("MerchantNPC", function(instance)
			local maid = Trove.new()
			local animator = instance.Humanoid.Animator
			local track = loadAnimation(animator, script.Idle, maid) -- equivalent call inferred; original call site unknown
			track.Priority = Enum.AnimationPriority.Idle
			track.Looped = true
			track:Play()
			local track2 = loadAnimation(animator, script.IdleToAction, maid) -- equivalent call inferred; original call site unknown
			track2.Priority = Enum.AnimationPriority.Action
			local track3 = loadAnimation(animator, script.ActionIdle, maid) -- equivalent call inferred; original call site unknown
			track3.Priority = Enum.AnimationPriority.Movement
			track3.Looped = true
			local track4 = loadAnimation(animator, script.ActionToIdle, maid) -- equivalent call inferred; original call site unknown
			track4.Priority = Enum.AnimationPriority.Action
			maid:Add(track2.Stopped:Connect(function()
				track3:Play()
			end))
			maid:Add(track3.Stopped:Connect(function()
				track4:Play()
			end))
			maid:Add(remoteEvent2.OnClientEvent:Connect(function(_: string, childName: string)
				local v11 = script.SpawnEffects:FindFirstChild(childName) or script.SpawnEffects:FindFirstChild("Rare")

				if not v11 then
					return
				end

				track2:Play()
				task.wait(0.5)
				local v12 = instance:GetPivot() * CFrame.new(0, 3.5, -3)
				task.spawn(function()
					local child = ReplicatedStorage.Sounds.Sfx.Merchant:FindFirstChild(childName)

					if child then
						SoundController:PlaySound(child, v12.Position)
					end
				end)
				local clone = v11:Clone()
				clone:PivotTo(v12)
				clone.Parent = workspace
				VFX.emit(clone)
				task.wait(2.5)
				track3:Stop()
			end))
			return maid:WrapClean()
		end, { workspace })
		Observers.observeTag("MerchantPrompt", function(p)
			local maid = Trove.new()

			local function updatePrompt()
				if not Synchronizer:Wait(localPlayer) then
					return
				end

				p.ObjectText = "Brainrot Dealer"
				p.ActionText = "View"
			end

			maid:Add(task.spawn(function()
				if not Synchronizer:Wait(localPlayer) then
					return
				end

				maid:Add(Timer.Simple(1, updatePrompt))
				task.spawn(updatePrompt)
			end))
			maid:Add(p.Triggered:Connect(function()
				if not Synchronizer:Get(localPlayer) then
					return
				end

				InterfaceController:Toggle("Merchant")
			end))
			return function()
				maid:Destroy()
			end
		end)
	end
}