local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("SoundService")
game:GetService("TweenService")
game:GetService("HttpService")
game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
require(ReplicatedStorage.Packages.Serialization)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Packages.TopbarPlus)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Packages.Moonlite)
local Signal = require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Squash)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Controllers.NotificationController)
require(ReplicatedStorage.Controllers.NewPlayersController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.CharacterController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.ShopController)
require(ReplicatedStorage.Controllers.PlotController)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local VFX = require(ReplicatedStorage.Shared.VFX)
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local brainrotTraderStock = ReplicatorClient.get("BrainrotTraderStock")
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
require(ReplicatedStorage.Shared.Updates)
require(ReplicatedStorage.Shared.Animals)
local Animals = require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Shared.Index)
local Mutations = require(ReplicatedStorage.Datas.Mutations)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
local remoteEvent = Net:RemoteEvent("BrainrotTraderService/Animation")
local remoteEvent2 = Net:RemoteEvent("BrainrotTraderService/Update")
local remoteEvent3 = Net:RemoteEvent("BrainrotTraderService/Return")
local remoteEvent4 = Net:RemoteEvent("BrainrotTraderService/Trade")
local remoteFunction = Net:RemoteFunction("BrainrotTraderService/Delivery")
local remoteFunction2 = Net:RemoteFunction("BrainrotTraderService/Fetch")
local remoteEvent5 = Net:RemoteEvent("ShopService/Purchase")
local localPlayer = Players.LocalPlayer
local brainrotTrader = localPlayer.PlayerGui:WaitForChild("BrainrotTrader").BrainrotTrader
local frame = brainrotTrader.Frame
local _ = frame.List
local txt1 = frame.Header.Txt1
local close = frame.Header.Close
Trove.new()
local v = Trove.new()
local v2 = nil
local v3 = nil

local function loadAnimation(animator, animation, maid)
	local track = animator:LoadAnimation(animation)
	maid:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local function updateTimer()
	v:Clean()

	if not Synchronizer:Get(localPlayer) then
		return
	end

	txt1.Visible = false
	local losTraders = workspace:FindFirstChild("LosTraders")

	if not losTraders then
		return
	end

	local countdown = losTraders.Overhead.BillboardGui.Countdown

	if not countdown then
		return
	end

	txt1.Visible = true
	local serverTimeNow = workspace:GetServerTimeNow()
	local formatted = `Restocking in {TimeUtils:E((math.max((v3 and v3.Refresh or 0) - serverTimeNow, 0)))}`
	countdown.Text = formatted
	txt1.Text = formatted
end

local maid = Trove.new()

local function renderBrainrotAtFrame(brainrot, name)
	local animal = Animals2[name]

	if not animal then
		return
	end

	local rarity = Rarities[animal.Rarity]
	brainrot.Title.Text = Animals:GetDisplayName(name)

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
	Animals:AttachOnViewportWithOptimizations(name, brainrot.ViewportFrame)
end

local v4 = Trove.new()

local function updateMutationList()
	v4:Clean()

	if not v3 then
		return
	end

	local v5 = Synchronizer:Get(localPlayer)

	if not v5 then
		return
	end

	local v6 = v5:Get("BrainrotTrader.Info")

	if not v6 then
		return
	end

	local v7 = {}

	for k, v8 in v6 do
		local mutations = v8.Mutations
		local traits = v8.Traits
		mutations.Normal = nil

		if not (next(mutations) or next(traits)) then
			continue
		end

		local name = v3 and v3.List[k] and v3.List[k].Name

		if not name then
			continue
		end

		local animal = Animals2[name]

		if not (animal and tonumber(string.match(k, "(%d+)"))) then
			continue
		end

		local rarity = Rarities[animal.Rarity]
		local total = 0

		for _, mutation in mutations do
			total += mutation
		end

		local total2 = 0

		for _, trait in traits do
			total2 += trait
		end

		local score = rarity.Weight * 10 + #v3.List[k].Recipe * 5 + total2 / 10 + total / 10
		local clone = v4:Clone(brainrotTrader.Odds.UIListLayout.Template)
		table.insert(v7, {
			frame = clone,
			score = score
		})
		clone.Header.Title.Text = Animals:GetDisplayName(name)

		for k2, mutation in mutations do
			local mutation2 = Mutations[k2]

			if not mutation2 then
				continue
			end

			local clone2 = v4:Clone(clone.ScrollingFrame.UIListLayout.Template)
			clone2.Name = k2
			clone2.LayoutOrder = -mutation
			clone2.Vector.Image = mutation2.Icon or ""
			MutationText.apply(clone2.Title, k2, "Auto")
			local _, v10 = math.modf(mutation)
			clone2.Chance.Text = `{string.format(v10 == 0 and "%d" or "%.2f", mutation)}%`
			clone2.Visible = true
			clone2.Parent = clone.ScrollingFrame
		end

		for k2, trait in traits do
			local trait2 = Traits[k2]

			if not trait2 then
				continue
			end

			local clone2 = v4:Clone(clone.ScrollingFrame.UIListLayout.Template)
			clone2.Name = k2
			clone2.LayoutOrder = -trait
			clone2.Vector.Image = trait2.Icon or ""
			clone2.Title.Text = trait2.DisplayWithRichText
			clone2.Title.TextColor3 = trait2.Color
			clone2.Title.RichText = true
			local _, v10 = math.modf(trait)
			clone2.Chance.Text = `{string.format(v10 == 0 and "%d" or "%.2f", trait)}%`
			clone2.Visible = true
			clone2.Parent = clone.ScrollingFrame
		end
	end

	table.sort(v7, function(a, b)
		return a.score < b.score
	end)

	for i = math.max(#v7 - 4, 1), #v7 do
		local frame2 = v7[i].frame
		frame2.LayoutOrder = -i
		local parent

		if #v7 - 2 < i then
			parent = brainrotTrader.Odds2
		else
			parent = brainrotTrader.Odds
		end

		frame2.Parent = parent
	end
end

local function updateList()
	maid:Clean()

	if not v3 then
		return
	end

	local v5 = Synchronizer:Get(localPlayer)

	if not v5 then
		return
	end

	local list = frame.List
	local v6 = Signal.new()
	maid:Add(v6)
	local v7 = {}
	local v8 = nil

	for k, v9 in v3.List do
		local v10 = tonumber(string.match(k, "(%d+)"))

		if not v10 then
			continue
		end

		local animal = Animals2[v9.Name]

		if not animal then
			continue
		end

		local _ = Rarities[animal.Rarity]
		local name = v9.Name
		local animal2 = Animals2[name]
		local clone = maid:Clone(list:FindFirstChild(v9.Template or "Normal") or list.Normal)
		v7[v10] = clone
		clone.Visible = true
		clone.LayoutOrder = ((Animals:GetGeneration(v9.Name) or 0) - 1) * 2
		local clone2 = maid:Clone(list.Dropdown)
		clone2.LayoutOrder = clone.LayoutOrder + 1
		clone2.Size = UDim2.fromScale(0.973, 0)
		clone2.Visible = false
		clone2.Spacer.Txt.Visible = false
		clone2.Parent = list
		renderBrainrotAtFrame(clone.Spacer.Brainrot, name)
		clone.Spacer.DropRate.Text = `${NumberUtils:ToString(Animals:GetGeneration(name))}/s`
		clone.Spacer.Txt.Text = Animals:GetDisplayName(name)

		if animal2 then
			local rarity = Rarities[animal2.Rarity]

			if rarity.GradientPreset then
				clone.Spacer.Txt.TextColor3 = Color3.new(1, 1, 1)
				Gradients.apply(clone.Spacer.Txt, rarity.GradientPreset)
			else
				clone.Spacer.Txt.TextColor3 = rarity.Color
			end
		end

		clone.Parent = list

		local function setExpanded(p)
			if p then
				clone2.Visible = true
				Spr.target(clone2, 0.9, 6, {
					Size = UDim2.fromScale(0.973, 0.192)
				})
			else
				Spr.target(clone2, 1, 6, {
					Size = UDim2.fromScale(0.973, 0)
				})
				Spr.completed(clone2, function()
					if clone2.Size.Y.Scale < 0.01 then
						clone2.Visible = false
					end
				end)
			end
		end

		local v13 = {}

		for k2, v14 in v9.Recipe do
			local animal3 = Animals2[v14]

			if not animal3 then
				continue
			end

			local rarity = Rarities[animal3.Rarity]
			local clone3 = maid:Clone(clone.Spacer.List.UIListLayout.Template)
			clone3.LayoutOrder = rarity.Weight * 100 + k2
			clone3.Title.Text = Animals:GetDisplayName(v14)
			clone3.Title.TextColor3 = Color3.new(1, 1, 1)

			if rarity.GradientPreset then
				clone3.UIStroke.Color = Color3.new(1, 1, 1)
				maid:Add(Gradients.apply(clone3.UIStroke, rarity.GradientPreset))
			else
				clone3.UIStroke.Color = rarity.Color
			end

			clone3.Visible = true
			clone3.Return.Visible = false
			clone3.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
			clone3.Parent = clone.Spacer.List

			if not v13[v14] then
				v13[v14] = {}
			end

			local v15 = {
				Frame = clone3,
				Attach = nil,
				Signature = nil,
				Render = nil
			}
			local v17 = v14

			function v15.Render(p)
				local mutation

				if typeof(p) == "table" then
					mutation = p.Mutation
				end

				local v19 = (typeof(p) ~= "table" or typeof(p.Traits) ~= "table") and {} or p.Traits
				local formatted = `{mutation or ""}|{table.concat(v19, ",")}`

				if v15.Signature == formatted then
					return
				end

				v15.Signature = formatted

				if v15.Attach then
					v15.Attach:Destroy()
				end

				local maid2, v20, v21 = Animals:AttachOnViewportWithOptimizations(
					v17,
					clone3.ViewportFrame,
					true,
					mutation
				)
				v15.Attach = maid2

				if #v19 > 0 and v21 then
					v21(function(p2)
						maid2:Add(Animals:ApplyTraits(p2, v17, v19))
					end)
				end
			end

			v15.Render(nil)
			local v19 = v15
			maid:Add(function()
				if v19.Attach then
					v19.Attach:Destroy()
				end
			end)
			table.insert(v13[v14], v15)
			local v20 = maid:Add(AnimatedButton.new(clone3.Return))
			v20:Animate()
			local v21 = v14
			maid:Add(v20.OnActivated:Connect(function()
				local animalPodiums = v5:Get("AnimalPodiums")

				for k3, animalPodium in animalPodiums do
					if not (type(animalPodium) == "table" and animalPodium.Index == v21 and animalPodium.Machine and animalPodium.Machine.Type == "BrainrotTrader") then
						continue
					end

					if animalPodium.Machine.Active then
						continue
					end

					remoteEvent3:FireServer(k3)
					break
				end
			end))
		end

		local v14 = true
		local setExpanded2 = setExpanded
		maid:Add(v6:Connect(function(p)
			setExpanded2(p == clone)
		end))
		local v17 = clone
		maid:Add(maid:Add(AnimatedButton.new(clone.Spacer)).OnActivated:Connect(function()
			SoundController:PlaySound("Sounds.Sfx.Activated")
			local v18

			if v8 ~= v17 then
				v18 = v17
			end

			v8 = v18
			v6:Fire(v8)
		end))
		local v19 = clone2

		local function updateBrainrotFrame()
			local animalPodiums = v5:Get("AnimalPodiums")
			local v20 = {}

			for k2, animalPodium in animalPodiums do
				if type(animalPodium) ~= "table" or not animalPodium.Machine or animalPodium.Machine.Type ~= "BrainrotTrader" or animalPodium.Machine.Active then
					continue
				end

				if not v20[animalPodium.Index] then
					v20[animalPodium.Index] = {}
				end

				table.insert(v20[animalPodium.Index], animalPodium)
			end

			local v21 = true

			for k2, v22 in v13 do
				local v23 = v20[k2]

				for k3, v24 in v22 do
					local v25 = v23 and v23[k3]
					local visible = v25 ~= nil
					v24.Frame.Return.Visible = visible
					local viewportFrame = v24.Frame.ViewportFrame
					local imageColor

					if visible then
						imageColor = Color3.new(1, 1, 1)
					else
						imageColor = Color3.new(0, 0, 0)
					end

					viewportFrame.ImageColor3 = imageColor
					v24.Render(v25)

					if not visible then
						v21 = false
					end
				end
			end

			local interactable = v21 and v14
			v19.Spacer.Spawn.Interactable = interactable
			local spawn = v19.Spacer.Spawn
			local backgroundColor

			if interactable then
				backgroundColor = Color3.fromRGB(81, 158, 86)
			else
				backgroundColor = Color3.fromRGB(127, 127, 127)
			end

			spawn.BackgroundColor3 = backgroundColor
			v19.Spacer.Robux.Interactable = v14
			local robux = v19.Spacer.Robux
			local backgroundColor2

			if v14 then
				backgroundColor2 = Color3.fromRGB(155, 67, 209)
			else
				backgroundColor2 = Color3.fromRGB(127, 127, 127)
			end

			robux.BackgroundColor3 = backgroundColor2
		end

		maid:Add(v5:OnChanged("AnimalAddedOrRemoved", updateBrainrotFrame))
		maid:Add(task.spawn(updateBrainrotFrame))
		local stock = v9.Stock or 0
		local v22 = clone
		local updateBrainrotFrame2 = updateBrainrotFrame

		local function updateStock()
			local v23 = brainrotTraderStock:TryIndex({ "stock", name })

			if typeof(v23) ~= "number" then
				v23 = stock
			end

			v14 = v23 > 0
			v22.Spacer.Label.Visible = v14

			if v14 then
				v22.Spacer.Label.Text = `{NumberUtils:Comma(v23)} <font color="rgb(255,127,0)">left</font>`
			end

			v22.Spacer.List.Visible = v14
			local soldOut = v22.Spacer:FindFirstChild("SoldOut")

			if soldOut then
				soldOut.Visible = not v14
			end

			updateBrainrotFrame2()
		end

		maid:Add(brainrotTraderStock:Listen({ "stock", name }, updateStock))
		maid:Add(task.spawn(updateStock))
		local productId = v9.ProductId
		local v23

		if typeof(productId) == "number" then
			v23 = productId > 0
		else
			v23 = false
		end

		if not v23 then
			clone2.Spacer.Robux.Visible = false
			clone2.Spacer.Spawn.Size = UDim2.fromScale(0.955, 0.713)
		end

		local v24 = AnimatedButton.new(clone2.Spacer.Spawn)
		maid:Add(v24)
		v24:Animate()
		local v25 = k
		local name2 = name
		maid:Add(v24.OnActivated:Connect(function()
			remoteEvent4:FireServer(v25, name2)
			InterfaceController:Toggle("BrainrotTrader", false)
		end))

		if not v23 then
			continue
		end

		local txt = clone2.Spacer.Robux.Txt
		txt.Text = "<font weight=\"500\"></font>???"
		local productId2 = productId
		maid:Add(task.spawn(function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function formatPriceInRobux(p)
				if p == 999999999 then
					return "???"
				end

				return (NumberUtils:Comma(p))
			end

			local productInfo = Marketplace:GetProductInfo(productId2, "Product")

			if not txt.Parent then
				return
			end

			local txt2 = txt
			local priceInRobux = productInfo.PriceInRobux or 999999999
			txt2.Text = ("<font weight=\"500\"></font>%*"):format(formatPriceInRobux(priceInRobux))
		end))
		local v29 = AnimatedButton.new(clone2.Spacer.Robux)
		maid:Add(v29)
		v29:Animate()
		local productId3 = productId
		maid:Add(v29.OnActivated:Connect(function()
			remoteEvent5:FireServer(productId3)
		end))
	end
end

return {
	Start = function(_)
		brainrotTrader.Visible = false
		v2 = InterfaceController:Register("BrainrotTrader", brainrotTrader, "TopQuint")
		v2:AttachCloseButton(close)
		v2:Close()
		Synchronizer:WaitAndCall(localPlayer, function(object)
			local function update()
				task.spawn(updateTimer)
			end

			object:OnChanged("BrainrotTrader", update)
			object:OnChanged("BrainrotTrader.Id", update)
			task.spawn(update)
		end)
		Timer.Simple(1, function()
			task.spawn(updateTimer)
		end)
		Observers.observeTag("BrainrotTraderPrompt", function(p)
			local maid2 = Trove.new()

			local function updatePrompt()
				if not Synchronizer:Wait(localPlayer) then
					return
				end

				p.ActionText = "View"
				p.ObjectText = "Brainrot Trader"
			end

			maid2:Add(task.spawn(function()
				local v5 = Synchronizer:Wait(localPlayer)

				if not v5 then
					return
				end

				v5:OnChanged("BrainrotTrader", updatePrompt)
				maid2:Add(Timer.Simple(1, updatePrompt))
				task.spawn(updatePrompt)
			end))
			maid2:Add(p.Triggered:Connect(function()
				if not Synchronizer:Get(localPlayer) then
					return
				end

				InterfaceController:Toggle("BrainrotTrader")
			end))
			return function()
				maid2:Destroy()
			end
		end)
		Observers.observeTag("BrainrotTrader", function(instance)
			local maid2 = Trove.new()

			for _, child in instance:WaitForChild("Hitboxes"):GetChildren() do
				local v5 = child
				maid2:Add(child.Touched:Connect(function(otherPart)
					if otherPart.Name ~= "HumanoidRootPart" then
						return
					end

					local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

					if not playerFromCharacter or playerFromCharacter ~= localPlayer then
						return
					end

					if playerFromCharacter:GetAttribute("StealingIndex") then
						local v6, v7, v8 = remoteFunction:InvokeServer(v5)

						if not v6 then
							return
						end

						task.spawn(function()
							SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx["Fuse Machine"].Deposit)
						end)
						updateTimer()
					end
				end))
			end

			return function()
				maid2:Destroy()
			end
		end)
		Observers.observeTag("BrainrotTraderNPC", function(instance)
			local maid2 = Trove.new()
			maid2:Add(remoteEvent.OnClientEvent:Connect(function(_: string, childName: string)
				local v5 = script.SpawnEffects:FindFirstChild(childName) or script.SpawnEffects.Rare

				if not v5 then
					return
				end

				local lastTime = os.clock()
				local v6 = true

				for _, animator in instance.Parent:QueryDescendants("Animator[$RigAnimation]"), nil, nil do
					local rigAnimation = animator:GetAttribute("RigAnimation")

					if not (rigAnimation ~= "" and animator:IsDescendantOf(workspace)) then
						continue
					end

					local child = script.Animations:FindFirstChild(rigAnimation)

					if not child then
						continue
					end

					local track = animator:LoadAnimation(child)
					track.Looped = false
					track:Play()
					task.spawn(function()
						while v6 and track.Length == 0 do
							task.wait()
						end

						if not v6 then
							return
						end

						track.TimePosition = os.clock() - lastTime
					end)
				end

				task.wait(0.5)
				local v7 = instance:GetPivot() * CFrame.new(0, 3.5, -3)
				task.spawn(function()
					local child = ReplicatedStorage.Sounds.Sfx.Merchant:FindFirstChild(childName)

					if child then
						SoundController:PlaySound(child, v7.Position)
					end
				end)
				local clone = v5:Clone()
				clone:PivotTo(v7)
				clone.Parent = workspace
				VFX.emit(clone)
				task.wait(2.5)
				v6 = false
			end))
			return maid2:WrapClean()
		end, { workspace })
		remoteEvent2.OnClientEvent:Connect(function(p)
			v3 = p
			updateList()
			updateMutationList()
		end)
		v3 = remoteFunction2:InvokeServer() or v3
		task.spawn(updateList)
		Synchronizer:WaitAndCall(localPlayer, function(object)
			object:OnChanged("BrainrotTrader.Info", updateMutationList)
			task.spawn(updateMutationList)
			updateList()
		end)
	end
}