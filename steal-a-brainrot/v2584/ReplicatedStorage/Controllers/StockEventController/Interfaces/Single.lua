local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local singleStockMachine = localPlayer.PlayerGui:WaitForChild("SingleStockMachine").SingleStockMachine
local content = singleStockMachine.Content
local close = singleStockMachine.Header.Close
local lists = singleStockMachine:FindFirstChild("Lists")
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Animals = require(ReplicatedStorage.Shared.Animals)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local Mutations2 = require(ReplicatedStorage.Datas.Mutations)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Traits = require(ReplicatedStorage.Datas.Traits)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Shared.StockMachineTypes)
singleStockMachine.Visible = false
local v = InterfaceController:Register("SingleStockMachine", singleStockMachine, "TopQuint")
v:AttachCloseButton(close)
v:Close()
return {
	Setup = function(_, object, items)
		local maid = Trove.new()
		local v2 = Synchronizer:Wait(localPlayer)
		maid:Add(v.OnOpen:Connect(function()
			object:SetOpen(true)
		end))
		maid:Add(v.OnClose:Connect(function()
			object:SetOpen(false)
		end))

		local function renderBrainrotAtFrame(state, p)
			local animal = Animals2[p]

			if not animal then
				return
			end

			local rarity = Rarities[animal.Rarity]
			state.Title.Text = Animals:GetDisplayName(p)

			if rarity.GradientPreset then
				state.UIStroke.Color = Color3.new(1, 1, 1)
				state.Title.TextColor3 = Color3.new(1, 1, 1)
				maid:Add(Gradients.apply(state.UIStroke, rarity.GradientPreset))
				maid:Add(Gradients.apply(state.Title, rarity.GradientPreset))
			else
				state.UIStroke.Color = rarity.Color
				state.Title.TextColor3 = rarity.Color
			end

			state.Visible = true
			local v3 = Animals:AttachOnViewportWithOptimizations(p, state.ViewportFrame, true)

			if v3 then
				maid:Add(v3)
			end
		end

		local v3, v4 = next(items)
		assert(v3)
		renderBrainrotAtFrame(singleStockMachine.Output.Brainrot, v4.Output)
		local v5 = {}
		local class = {}

		for k, input in v4.Inputs do
			local animal = Animals2[input]

			if not animal then
				continue
			end

			local rarity = Rarities[animal.Rarity]
			local clone = maid:Clone(content.Template)
			clone.LayoutOrder = rarity.Weight * 100 + k
			renderBrainrotAtFrame(clone, input)
			clone.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
			clone.Return.Visible = false
			clone.Visible = true
			clone.Parent = content

			if not v5[input] then
				v5[input] = {}
			end

			table.insert(v5[input], clone)
			local v6 = AnimatedButton.new(clone.Return)
			maid:Add(v6)
			v6:Animate()
			local v7 = input
			maid:Add(v6.OnActivated:Connect(function()
				local animalPodiums = v2:Get("AnimalPodiums")

				for k2, animalPodium in animalPodiums do
					if not (type(animalPodium) == "table" and animalPodium.Index == v7 and animalPodium.Machine and animalPodium.Machine.Type == object.MachineName) then
						continue
					end

					if animalPodium.Machine.Active then
						continue
					end

					object:Return(k2)
					break
				end
			end))
		end

		local function updateBrainrotFrame()
			local animalPodiums = v2:Get("AnimalPodiums")
			local v6 = {}

			for _, animalPodium in animalPodiums do
				if type(animalPodium) ~= "table" or not animalPodium.Machine or animalPodium.Machine.Type ~= object.MachineName or animalPodium.Machine.Active then
					continue
				end

				v6[animalPodium.Index] = (v6[animalPodium.Index] or 0) + 1
			end

			local flag = true

			for k, v7 in v5 do
				local v8 = v6[k] or 0

				for k2, v9 in v7 do
					local visible = k2 <= v8
					v9.Return.Visible = visible
					local viewportFrame = v9.ViewportFrame
					local imageColor

					if visible then
						imageColor = Color3.new(1, 1, 1)
					else
						imageColor = Color3.new(0, 0, 0)
					end

					viewportFrame.ImageColor3 = imageColor

					if not visible then
						flag = false
					end
				end
			end

			singleStockMachine.Spawn.Interactable = flag
			local spawn = singleStockMachine.Spawn
			local backgroundColor

			if flag then
				backgroundColor = Color3.fromRGB(81, 158, 86)
			else
				backgroundColor = Color3.fromRGB(127, 127, 127)
			end

			spawn.BackgroundColor3 = backgroundColor
		end

		maid:Add(v2:OnChanged("AnimalAddedOrRemoved", updateBrainrotFrame))
		task.spawn(updateBrainrotFrame)
		local mutations

		if lists then
			mutations = lists:FindFirstChild("Mutations")
		else
			mutations = nil
		end

		local traits

		if lists then
			traits = lists:FindFirstChild("Traits")
		else
			traits = nil
		end

		local function computeOdds()
			local animalPodiums = v2:Get("AnimalPodiums")
			local v6 = {}

			for _, input in v4.Inputs do
				v6[input] = (v6[input] or 0) + 1
			end

			local v7 = {}
			local result = {}

			if typeof(animalPodiums) == "table" then
				for _, animalPodium in animalPodiums do
					if not (typeof(animalPodium) == "table" and animalPodium.Machine and animalPodium.Machine.Type == object.MachineName and v6[animalPodium.Index]) then
						continue
					end

					if not (v6[animalPodium.Index] > 0) then
						continue
					end

					local index = animalPodium.Index
					v6[index] -= 1

					if typeof(animalPodium.Traits) == "table" then
						for _, trait in animalPodium.Traits do
							v7[trait] = (v7[trait] or 0) + 1
						end
					end

					if animalPodium.Mutation then
						result[animalPodium.Mutation] = (result[animalPodium.Mutation] or 0) + 15
					end
				end
			end

			local v8 = Mutations.get()

			if v8 then
				result[v8] = (result[v8] or 0) + 15
			end

			local v9 = 100

			for _, v10 in result do
				v9 -= v10
			end

			result.Normal = math.max(v9, 0)
			local result2 = {}

			for k, v10 in v7 do
				result2[k] = math.clamp(v10 / 3, 0, 1) * 30
			end

			return result, result2
		end

		local extended = maid:Extend()

		local function updateOdds()
			extended:Clean()

			if not (mutations or traits) then
				return
			end

			local v6, v7 = computeOdds()

			if mutations then
				for _, frame in mutations.ScrollingFrame:GetChildren() do
					if frame:IsA("Frame") and frame.Name ~= "Template" then
						frame:Destroy()
					end
				end

				local visible = false

				for k, v9 in v6 do
					local mutation = Mutations2[k]

					if not mutation then
						continue
					end

					local clone = mutations.ScrollingFrame.Template:Clone()
					clone.Name = k
					clone.LayoutOrder = -v9
					clone.Vector.Image = mutation.Icon or ""
					local v10 = MutationText.apply(clone.Title, k, "Auto")

					if v10 then
						extended:Add(v10)
					end

					local _, v11 = math.modf(v9)
					clone.Chance.Text = `{string.format(v11 == 0 and "%d" or "%.2f", v9)}%`
					clone.Visible = true
					clone.Parent = mutations.ScrollingFrame
					visible = true
				end

				mutations.Visible = visible
			end

			if traits then
				for _, frame in traits.ScrollingFrame:GetChildren() do
					if frame:IsA("Frame") and frame.Name ~= "Template" then
						frame:Destroy()
					end
				end

				local visible = false

				for k, v9 in v7 do
					if v9 <= 0 then
						continue
					end

					local trait = Traits[k]

					if not trait then
						continue
					end

					local clone = traits.ScrollingFrame.Template:Clone()
					clone.Name = k
					clone.LayoutOrder = -v9
					clone.Vector.Image = trait.Icon or ""
					clone.Title.Text = trait.DisplayWithRichText
					clone.Title.TextColor3 = trait.Color
					clone.Title.RichText = true
					local _, v10 = math.modf(v9)
					clone.Chance.Text = `{string.format(v10 == 0 and "%d" or "%.2f", v9)}%`
					clone.Visible = true
					clone.Parent = traits.ScrollingFrame
					visible = true
				end

				traits.Visible = visible
			end
		end

		maid:Add(v2:OnChanged("AnimalAddedOrRemoved", updateOdds))
		maid:Add(Mutations.watch(updateOdds))
		task.spawn(updateOdds)
		local v6 = AnimatedButton.new(singleStockMachine.Spawn)
		maid:Add(v6)
		v6:Animate()
		maid:Add(v6.OnActivated:Connect(function()
			object:Redeem(v3)
			class:Close()
		end))
		local quantity = singleStockMachine.Output.Holder.Quantity
		local v7 = nil

		local function updateStock()
			local stock = object:GetStock(v3)
			quantity.TextColor3 = Color3.fromRGB(255, 255, 255)

			if stock == nil or stock > 0 then
				quantity.Text = stock and `{NumberUtils:Comma(stock)} Left` or "Loading..."

				if not v7 then
					v7 = Gradients.apply(quantity, "Rainbow")
				end
			else
				quantity.TextColor3 = Color3.fromRGB(255, 0, 0)
				quantity.Text = "SOLD OUT"

				if v7 then
					v7()
					v7 = nil
				end
			end
		end

		maid:Add(object:OnStockChange(v3, updateStock))
		task.spawn(updateStock)
		maid:Add(function()
			if v7 then
				v7()
				v7 = nil
			end
		end)

		function class:Toggle()
			InterfaceController:Toggle("SingleStockMachine")
		end

		function class.Open(_)
			InterfaceController:SetState("SingleStockMachine", true)
		end

		function class:Close()
			InterfaceController:SetState("SingleStockMachine", false)
		end

		function class:Destroy()
			maid:Destroy()
		end

		return class
	end
}