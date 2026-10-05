local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("SoundService")
game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
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
local Traits = require(ReplicatedStorage.Datas.Traits)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
require(ReplicatedStorage.Controllers.NotificationController)
require(ReplicatedStorage.Controllers.NewPlayersController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.CharacterController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.PlotController)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local VFX = require(ReplicatedStorage.Shared.VFX)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
require(ReplicatedStorage.Shared.Updates)
require(ReplicatedStorage.Shared.Animals)
local Animals = require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Shared.Index)
local Mutations = require(ReplicatedStorage.Datas.Mutations)
require(ReplicatedStorage.Shared.MutationText)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local remoteEvent = Net:RemoteEvent("CraftingMachineService/CraftNow")
local remoteEvent2 = Net:RemoteEvent("CraftingMachineService/Update")
local remoteEvent3 = Net:RemoteEvent("CraftingMachineService/Return")
local remoteEvent4 = Net:RemoteEvent("CraftingMachineService/Claim")
local remoteFunction = Net:RemoteFunction("CraftingMachineService/Delivery")
local remoteFunction2 = Net:RemoteFunction("CraftingMachineService/Start")
local remoteFunction3 = Net:RemoteFunction("CraftingMachineService/Fetch")
Net:RemoteEvent("ShopService/Purchase")
local craftingMachineStock = ReplicatorClient.get("CraftingMachineStock")

local function getLimitedStock(p: string)
	local v = craftingMachineStock:TryIndex({ "stock", p })

	if typeof(v) == "number" then
		return v
	end

	return nil
end

workspace:WaitForChild("RenderedMovingAnimals")
local localPlayer = Players.LocalPlayer
local craftingMachine = localPlayer.PlayerGui:WaitForChild("CraftingMachine").CraftingMachine
local content = craftingMachine.Content
local time = content.Time
local buy = content.Buy
local close = craftingMachine.Header.Close
local brainrotName = content.BrainrotName
Trove.new()
local v = Trove.new()
local v2 = nil
local v3 = nil
local v4 = "Legendary"
local v5 = nil
local v6 = false
local flag = nil
local v7 = Signal.new()

local function updateVFX()
	local v8 = Synchronizer:Get(localPlayer)

	if not v8 or v6 then
		return
	end

	local craftingMachine2 = workspace:FindFirstChild("CraftingMachine")

	if not craftingMachine2 then
		return
	end

	local craftingMachine3 = v8:Get("CraftingMachine")

	if not craftingMachine3 then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if craftingMachine3.Rarity and craftingMachine3.StartTime and craftingMachine3.FinishTime then
		if not flag then
			flag = true
			v7:Fire(true)
		end

		local v9 = math.clamp(
			(serverTimeNow - craftingMachine3.StartTime) / (craftingMachine3.FinishTime - craftingMachine3.StartTime),
			0,
			1
		)
		local child = craftingMachine2.VFX:FindFirstChild(craftingMachine3.Rarity)

		if child then
			VFX.enable(child.ChargingModel.Charging.Charge)
			child.ChargingModel:ScaleTo((math.lerp(0.25, 1, v9)))

			for _, emitter in child.ChargingModel.Charging.Charge:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.TimeScale = math.lerp(0.3, 0.7, v9)
				end
			end
		end

		if not craftingMachine2.ChargeSoundPart.Sound.IsPlaying then
			craftingMachine2.ChargeSoundPart.Sound:Play()
		end
	else
		if flag then
			flag = false
			v7:Fire(false)
		end

		VFX.disable(craftingMachine2.VFX)

		if craftingMachine2.ChargeSoundPart.Sound.IsPlaying then
			craftingMachine2.ChargeSoundPart.Sound:Stop()
		end
	end
end

local function updateTimer()
	v:Clean()
	local v8 = Synchronizer:Get(localPlayer)

	if not v8 then
		return
	end

	time.Visible = false
	local v9 = v8:Get("CraftingMachine.FinishTime")
	local craftingMachine2 = workspace:FindFirstChild("CraftingMachine")

	if not craftingMachine2 then
		return
	end

	local countdown = craftingMachine2.Overhead.BillboardGui.Countdown

	if not countdown then
		return
	end

	time.Visible = true
	local serverTimeNow = workspace:GetServerTimeNow()
	local v10 = v3 and v4 and v3.List[v4]

	if v10 then
		time.Text = `Crafting Time (<font color="#ffff00">{TimeUtils:E(v10.CraftTime)}</font>)`
	else
		time.Text = ""
	end

	if v9 then
		local v11 = math.max(v9 - serverTimeNow, 0)
		countdown.Text = v11 <= 0 and "READY" or TimeUtils:E(v11)
	else
		countdown.Text = `Refreshes in {TimeUtils:E((math.max((v3 and v3.Refresh or 0) - serverTimeNow, 0)))}`
	end
end

local function updateLists()
	for _, frame in craftingMachine.Lists.Mutations.ScrollingFrame:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame:Destroy()
		end
	end

	for _, frame in craftingMachine.Lists.Traits.ScrollingFrame:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "Template" then
			frame:Destroy()
		end
	end

	local v8 = Synchronizer:Get(localPlayer)
	local v9 = not v8 and {} or v8:Get("CraftingMachine.OutputMutationOdds") or {}
	local v10 = v8 and v8:Get("CraftingMachine.OutputTraitsOdds") or {}
	local v11 = v4 and v9[v4] or {}
	local v12 = v4 and v10[v4] or {}
	local visible = false

	for k, v14 in v11 do
		local mutation = Mutations[k]

		if not mutation then
			continue
		end

		local clone = craftingMachine.Lists.Mutations.ScrollingFrame.Template:Clone()
		clone.Name = k
		clone.LayoutOrder = -v14
		clone.Vector.Image = mutation.Icon or ""
		MutationText.apply(clone.Title, k, "Auto")
		local _, v15 = math.modf(v14)
		clone.Chance.Text = `{string.format(v15 == 0 and "%d" or "%.2f", v14)}%`
		clone.Visible = true
		clone.Parent = craftingMachine.Lists.Mutations.ScrollingFrame
		visible = true
	end

	craftingMachine.Lists.Mutations.Visible = visible
	local visible2 = false

	for k, v15 in v12 do
		local trait = Traits[k]

		if not trait then
			continue
		end

		local clone = craftingMachine.Lists.Traits.ScrollingFrame.Template:Clone()
		clone.Name = k
		clone.LayoutOrder = -v15
		clone.Vector.Image = trait.Icon or ""
		clone.Title.Text = trait.DisplayWithRichText
		clone.Title.TextColor3 = trait.Color
		clone.Title.RichText = true
		local _, v16 = math.modf(v15)
		clone.Chance.Text = `{string.format(v16 == 0 and "%d" or "%.2f", v15)}%`
		clone.Visible = true
		clone.Parent = craftingMachine.Lists.Traits.ScrollingFrame
		visible2 = true
	end

	craftingMachine.Lists.Traits.Visible = visible2
end

local maid = Trove.new()

local function updateSelection()
	if v5 == v4 then
		return
	end

	local v8 = Synchronizer:Get(localPlayer)

	if not v8 then
		return
	end

	maid:Clean()
	updateLists()

	if not v3 then
		return
	end

	if v4 and not v3.List[v4] then
		v4 = "Legendary"
	end

	local v9 = v4 and v3.List[v4]

	if v4 and not v9 then
		return
	end

	v5 = v4

	if not v4 then
		content.Visible = false
		return
	end

	content.Visible = true
	brainrotName.Title.Text = Animals:GetDisplayName(v9.Name)
	local rarity = Rarities[v9.Rarity]

	if rarity.GradientPreset then
		brainrotName.Title.TextColor3 = Color3.new(1, 1, 1)
		brainrotName.UIStroke.Color = Color3.new(1, 1, 1)
		maid:Add(Gradients.apply(brainrotName.Title, rarity.GradientPreset))
		maid:Add(Gradients.apply(brainrotName.UIStroke, rarity.GradientPreset))
	else
		brainrotName.Title.TextColor3 = rarity.Color
		brainrotName.UIStroke.Color = rarity.Color
	end

	local v10 = Animals2[v9.Name] and Animals:AttachOnViewport(v9.Name, brainrotName.ViewportFrame, true)

	if v10 then
		maid:Add(v10)
	end

	local required = content.Required
	required.TextColor3 = Color3.fromRGB(255, 255, 255)

	if v9.StockKey == nil then
		required.Text = "Brainrots Required:"
	else
		local stockKey = v9.StockKey
		local v11 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setRainbow(flag2: boolean)
			if flag2 and not v11 then
				v11 = Gradients.apply(required, "Rainbow")
			elseif not flag2 and v11 then
				v11()
				v11 = nil
			end
		end

		maid:Add(function()
			if v11 then
				v11()
				v11 = nil
			end
		end)

		local function refreshStockText()
			local v12 = craftingMachineStock:TryIndex({ "stock", stockKey })

			if typeof(v12) ~= "number" then
				v12 = nil
			end

			local v13

			if v12 == nil then
				v13 = false
			else
				v13 = v12 <= 0
			end

			required.Text = v12 == nil and "Loading..." or v13 and "SOLD OUT!" or `{NumberUtils:Comma(v12)} LEFT`
			local required2 = required
			local textColor

			if v13 then
				textColor = Color3.fromRGB(255, 0, 0)
			else
				textColor = Color3.fromRGB(255, 255, 255)
			end

			required2.TextColor3 = textColor
			setRainbow(not v13) -- equivalent call inferred; original call site unknown
		end

		maid:Add(craftingMachineStock:Listen({ "stock", v9.StockKey }, refreshStockText))
		refreshStockText()
	end

	local v11 = {}

	for k, v12 in v9.Recipe do
		local animal = Animals2[v12]

		if not animal then
			continue
		end

		local rarity2 = Rarities[animal.Rarity]
		local clone = maid:Clone(content.Brainrots.Template)
		clone.LayoutOrder = rarity2.Weight * 100 + k
		clone.Title.Text = Animals:GetDisplayName(v12)
		clone.Title.TextColor3 = Color3.new(1, 1, 1)

		if rarity2.GradientPreset then
			clone.UIStroke.Color = Color3.new(1, 1, 1)
			maid:Add(Gradients.apply(clone.UIStroke, rarity2.GradientPreset))
		else
			clone.UIStroke.Color = rarity2.Color
		end

		clone.Visible = true
		clone.Return.Visible = false
		clone.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
		local v13 = Animals:AttachOnViewport(v12, clone.ViewportFrame, true)

		if v13 then
			maid:Add(v13)
		end

		clone.Parent = content.Brainrots

		if not v11[v12] then
			v11[v12] = {}
		end

		table.insert(v11[v12], clone)
		local v14 = maid:Add(AnimatedButton.new(clone.Return))
		v14:Animate()
		local v15 = v12
		maid:Add(v14.OnActivated:Connect(function()
			local animalPodiums = v8:Get("AnimalPodiums")

			for k2, animalPodium in animalPodiums do
				if not (type(animalPodium) == "table" and animalPodium.Index == v15 and animalPodium.Machine and animalPodium.Machine.Type == "Crafting") then
					continue
				end

				if animalPodium.Machine.Active then
					continue
				end

				remoteEvent3:FireServer(k2)
				break
			end
		end))
	end

	local v12 = false

	local function updateBrainrotFrame()
		local animalPodiums = v8:Get("AnimalPodiums")
		local v13 = {}

		for _, animalPodium in animalPodiums do
			if type(animalPodium) ~= "table" or not animalPodium.Machine or animalPodium.Machine.Type ~= "Crafting" or animalPodium.Machine.Active then
				continue
			end

			v13[animalPodium.Index] = (v13[animalPodium.Index] or 0) + 1
		end

		local visible = true

		for k, v15 in v11 do
			local v16 = v13[k] or 0

			for k2, v17 in v15 do
				local visible2 = k2 <= v16
				v17.Return.Visible = visible2
				local viewportFrame = v17.ViewportFrame
				local imageColor

				if visible2 then
					imageColor = Color3.new(1, 1, 1)
				else
					imageColor = Color3.new(0, 0, 0)
				end

				viewportFrame.ImageColor3 = imageColor

				if not visible2 then
					visible = false
				end
			end
		end

		buy.Visible = visible
		local v15 = buy
		local backgroundColor

		if v12 then
			backgroundColor = Color3.fromRGB(127, 127, 127)
		else
			backgroundColor = Color3.fromRGB(81, 158, 86)
		end

		v15.BackgroundColor3 = backgroundColor
	end

	maid:Add(v8:OnChanged("AnimalAddedOrRemoved", updateBrainrotFrame))
	maid:Add(task.spawn(updateBrainrotFrame))

	if v9.StockKey ~= nil then
		local stockKey = v9.StockKey

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshSoldOut()
			local v13 = craftingMachineStock:TryIndex({ "stock", stockKey })

			if typeof(v13) ~= "number" then
				v13 = nil
			end

			v12 = v13 ~= nil and v13 <= 0
			updateBrainrotFrame()
		end

		maid:Add(craftingMachineStock:Listen({ "stock", stockKey }, refreshSoldOut))
		refreshSoldOut() -- equivalent call inferred; original call site unknown
	end

	buy.Price.Text = `${NumberUtils:ToString(v9.Cost)}`
	local v13 = maid:Add(AnimatedButton.new(buy))
	v13:Animate()
	maid:Add(v13.OnActivated:Connect(function()
		if not remoteFunction2:InvokeServer(v4, v9.Name) then
			return
		end

		InterfaceController:SetState("CraftingMachine", false)
	end))
	updateTimer()
end

local maid2 = Trove.new()

local function updateList()
	maid2:Clean()

	if not v3 then
		return
	end

	for k, v8 in v3.List do
		local rarity = Rarities[v8.Rarity]
		local clone

		if v8.StockKey == nil then
			clone = maid2:Clone(craftingMachine.List.Template)
		else
			clone = maid2:Clone(craftingMachine.List.TemplateLimited)
		end

		local button = clone.Button
		local animal = Animals2[v8.Name]
		clone.LayoutOrder = animal and animal.Generation or 0
		button.Title.Text = Animals:GetDisplayName(v8.Name)

		if rarity.GradientPreset then
			button.Title.TextColor3 = Color3.new(1, 1, 1)
			button.UIStroke.Color = Color3.new(1, 1, 1)
			maid2:Add(Gradients.apply(button.Title, rarity.GradientPreset))
			maid2:Add(Gradients.apply(button.UIStroke, rarity.GradientPreset))
		else
			button.Title.TextColor3 = rarity.Color
			button.UIStroke.Color = rarity.Color
		end

		local limited = v8.StockKey ~= nil and button:FindFirstChild("Limited")

		if limited then
			maid2:Add(Gradients.apply(limited, "Rainbow"))
		end

		clone.Visible = true
		clone.Parent = craftingMachine.List
		local v9 = maid2:Add(AnimatedButton.new(button))
		v9:Animate()
		local v10 = k
		maid2:Add(v9.OnActivated:Connect(function()
			v4 = v10
			updateSelection()
			updateLists()
		end))

		if not Animals2[v8.Name] then
			continue
		end

		local v11 = Animals:AttachOnViewport(v8.Name, button.ViewportFrame, true)

		if v11 then
			maid2:Add(v11)
		end
	end

	updateSelection()
end

return {
	Start = function(_)
		craftingMachine.Visible = false
		v2 = InterfaceController:Register("CraftingMachine", craftingMachine, "TopQuint")
		v2:AttachCloseButton(close)
		v2:Close()
		local track = nil
		local track2 = nil

		local function getTracks()
			local craftingMachine2 = workspace:FindFirstChild("CraftingMachine")
			local animator = craftingMachine2 and craftingMachine2:FindFirstChildWhichIsA("Animator", true)

			if not track2 and animator then
				track2 = animator:LoadAnimation(script.Release)
				track2:GetMarkerReachedSignal("VFX"):Connect(function()
					local machine = craftingMachine2:FindFirstChild("Machine")

					if machine then
						VFX.emit(machine)
					end
				end)
			end

			if not track and animator then
				track = animator:LoadAnimation(script.Insert)
			end

			return {
				insertTrack = track,
				releaseTrack = track2
			}
		end

		Synchronizer:WaitAndCall(localPlayer, function(object)
			local function update()
				task.spawn(updateTimer)
			end

			object:OnChanged("CraftingMachine", update)
			object:OnChanged("CraftingMachine.Brainrot", update)
			object:OnChanged("CraftingMachine.Rarity", update)
			object:OnChanged("CraftingMachine.FinishTime", update)
			object:OnChanged("CraftingMachine.StartTime", update)
			object:OnChanged("CraftingMachine.OutputMutationOdds", function()
				task.spawn(updateLists)
			end)
			object:OnChanged("CraftingMachine.OutputTraitsOdds", function()
				task.spawn(updateLists)
			end)
			task.spawn(update)
			task.spawn(updateLists)
		end)
		Timer.Simple(1, function()
			task.spawn(updateVFX)
			task.spawn(updateTimer)
		end)
		Observers.observeTag("CraftingMachinePrompt", function(p)
			local maid3 = Trove.new()

			local function updatePrompt()
				local v8 = Synchronizer:Wait(localPlayer)

				if not v8 then
					return
				end

				local v9 = v8:Get("CraftingMachine.StartTime")
				local v10 = v8:Get("CraftingMachine.FinishTime")

				if v10 and v10 ~= 0 and v10 <= workspace:GetServerTimeNow() then
					p.ActionText = "Claim"
				elseif v9 and v9 ~= 0 then
					p.ActionText = "Craft Now"
				else
					p.ActionText = "Craft Machine"
				end
			end

			maid3:Add(task.spawn(function()
				local v8 = Synchronizer:Wait(localPlayer)

				if not v8 then
					return
				end

				v8:OnChanged("CraftingMachine", updatePrompt)
				maid3:Add(Timer.Simple(1, updatePrompt))
				task.spawn(updatePrompt)
			end))
			maid3:Add(p.Triggered:Connect(function()
				local v8 = Synchronizer:Get(localPlayer)

				if not v8 then
					return
				end

				local v9 = v8:Get("CraftingMachine.StartTime")
				local v10 = v8:Get("CraftingMachine.FinishTime")

				if v10 and v10 ~= 0 and v10 <= workspace:GetServerTimeNow() then
					remoteEvent4:FireServer()
				elseif v9 and v9 ~= 0 then
					remoteEvent:FireServer()
				else
					InterfaceController:Toggle("CraftingMachine")
				end
			end))
			return function()
				maid3:Destroy()
			end
		end)
		Observers.observeTag("CraftingMachineHitbox", function(p)
			local touchedConnection = p.Touched:Connect(function(otherPart)
				if otherPart.Name ~= "HumanoidRootPart" then
					return
				end

				local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

				if not playerFromCharacter or playerFromCharacter ~= localPlayer then
					return
				end

				if playerFromCharacter:GetAttribute("StealingIndex") then
					local v8, _, _ = remoteFunction:InvokeServer(p)

					if not v8 then
						return
					end

					local tracks = getTracks()

					if tracks.insertTrack then
						tracks.insertTrack:Play()
					end

					task.spawn(function()
						SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx["Crafting Machine"].Deposit)
					end)
					updateTimer()
				end
			end)
			return function()
				touchedConnection:Disconnect()
			end
		end)
		local v8 = {}
		remoteEvent.OnClientEvent:Connect(function(childName: string)
			local craftingMachine2 = workspace:FindFirstChild("CraftingMachine")

			if not craftingMachine2 then
				return
			end

			local tracks = getTracks()
			local GUID = HttpService:GenerateGUID(false)
			v8[GUID] = true
			v6 = next(v8) ~= nil
			local child = craftingMachine2.VFX:FindFirstChild(childName)

			if child then
				child.ChargingModel:ScaleTo(1)

				for _, emitter in child.ChargingModel.Charging.Charge:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.TimeScale = 1
					end
				end

				VFX.enable(child)
				child.SoundPart.Sound:Play()
			else
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Sfx["Crafting Machine"].CraftStart,
					craftingMachine2:GetPivot().Position,
					false
				)
			end

			if craftingMachine2.ChargeSoundPart.Sound.IsPlaying then
				craftingMachine2.ChargeSoundPart.Sound:Stop()
			end

			if tracks.releaseTrack then
				tracks.releaseTrack:Play()
			end

			task.wait(3)

			if child then
				VFX.disable(child)
				VFX.emit(child.Burst)
			end

			local spawnZone = craftingMachine2:FindFirstChild("SpawnZone") or craftingMachine2
			SoundController:PlaySound(
				ReplicatedStorage.Sounds.Sfx["Crafting Machine"].Craft,
				spawnZone:GetPivot().Position,
				false
			)
			v8[GUID] = nil
			v6 = next(v8) ~= nil
		end)
		remoteEvent2.OnClientEvent:Connect(function(p)
			v5 = nil
			v3 = p
			updateList()
		end)
		v3 = remoteFunction3:InvokeServer() or v3
		task.spawn(updateList)
		Timer.Simple(1, function()
			local v9 = (v3 and v3.Refresh or 0) - workspace:GetServerTimeNow()
			craftingMachine.Timer.Text = `Refreshes in {TimeUtils:E((math.max(v9, 0)))}`
		end, true)
		Synchronizer:WaitAndCall(localPlayer, function()
			updateList()
		end)
		Observers.observeTag("CraftingMachineVFXEnable", function(p)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				if flag then
					VFX.enable(p)
				else
					VFX.disable(p)
				end
			end

			local connection = v7:Connect(update)
			update() -- equivalent call inferred; original call site unknown
			return function()
				connection:Disconnect()
			end
		end)
		task.spawn(function()
			local v9 = Synchronizer:Wait(localPlayer)

			if not v9 then
				return
			end

			local v10 = {
				Color3.fromRGB(163, 162, 165),
				Color3.fromRGB(93, 176, 55),
				Color3.fromRGB(179, 168, 48),
				Color3.fromRGB(88, 173, 106)
			}
			local random = Random.new()

			while true do
				local serverTimeNow = workspace:GetServerTimeNow()
				local v11 = v9:Get("CraftingMachine.StartTime")
				local v12 = v9:Get("CraftingMachine.FinishTime")
				local v13, v14

				if v11 and v12 and workspace:GetServerTimeNow() < v12 then
					local v15 = math.clamp((serverTimeNow - v11) / (v12 - v11), 0, 1)
					v13 = math.lerp(0.5, 0.25, v15)
					v14 = math.lerp(4, 5, v15)
				else
					v13 = 1
					v14 = 3
				end

				task.wait(v13)
				local craftingMachine2 = workspace:FindFirstChild("CraftingMachine")

				if not craftingMachine2 then
					continue
				end

				local cubes = craftingMachine2:FindFirstChild("Cubes")

				if not cubes then
					continue
				end

				for _, child in cubes:GetChildren() do
					Spr.target(child, 1, v14, {
						Color = v10[random:NextInteger(1, #v10)]
					})
				end
			end
		end)
	end
}