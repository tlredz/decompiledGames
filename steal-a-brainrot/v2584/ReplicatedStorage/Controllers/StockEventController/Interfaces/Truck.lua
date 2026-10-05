local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local stockMachine = localPlayer.PlayerGui:WaitForChild("StockMachine").StockMachine
local content = stockMachine.Content
local close = stockMachine.Header.Close
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
stockMachine.Visible = false
local v = InterfaceController:Register("StockMachine", stockMachine, "TopQuint")
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

		local class = {}

		for k, item in items do
			local clone = content.Template:Clone()
			clone.Visible = true
			clone.LayoutOrder = item.Order or 1
			clone.Parent = content
			clone.Output.LayoutOrder = 999999999
			renderBrainrotAtFrame(clone.Output, item.Output)
			local v3 = {}

			for k2, input in item.Inputs do
				local animal = Animals2[input]

				if not animal then
					continue
				end

				local rarity = Rarities[animal.Rarity]
				local clone2 = maid:Clone(clone.Input)
				clone2.LayoutOrder = rarity.Weight * 100 + k2
				renderBrainrotAtFrame(clone2, input)
				clone2.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
				clone2.Return.Visible = false
				clone2.Visible = true
				clone2.Parent = clone

				if not v3[input] then
					v3[input] = {}
				end

				table.insert(v3[input], clone2)
				local v4 = AnimatedButton.new(clone2.Return)
				maid:Add(v4)
				v4:Animate()
				local v5 = input
				maid:Add(v4.OnActivated:Connect(function()
					local animalPodiums = v2:Get("AnimalPodiums")

					for k3, animalPodium in animalPodiums do
						if not (type(animalPodium) == "table" and animalPodium.Index == v5 and animalPodium.Machine and animalPodium.Machine.Type == object.MachineName) then
							continue
						end

						if animalPodium.Machine.Active then
							continue
						end

						object:Return(k3)
						break
					end
				end))
			end

			local function updateBrainrotFrame()
				local animalPodiums = v2:Get("AnimalPodiums")
				local v6 = {}

				for k2, animalPodium in animalPodiums do
					if type(animalPodium) ~= "table" or not animalPodium.Machine or animalPodium.Machine.Type ~= object.MachineName or animalPodium.Machine.Active then
						continue
					end

					v6[animalPodium.Index] = (v6[animalPodium.Index] or 0) + 1
				end

				local flag = true

				for k2, v7 in v3 do
					local v8 = v6[k2] or 0

					for k3, v9 in v7 do
						local visible = k3 <= v8
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

				clone.Output.Spawn.Interactable = flag
				local spawn = clone.Output.Spawn
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
			local child = stockMachine:FindFirstChild(item.Order == 2 and "RightLists" or "LeftLists")
			local mutations

			if child then
				mutations = child.Lists:FindFirstChild("Mutations")
			else
				mutations = nil
			end

			local traits

			if child then
				traits = child.Lists:FindFirstChild("Traits")
			else
				traits = nil
			end

			if child then
				child.Title.Text = Animals:GetDisplayName(item.Output)
			end

			local v6 = item

			local function computeOdds()
				local animalPodiums = v2:Get("AnimalPodiums")
				local v7 = {}

				for k2, input in v6.Inputs do
					v7[input] = (v7[input] or 0) + 1
				end

				local v8 = {}
				local result = {}

				if typeof(animalPodiums) == "table" then
					for k2, animalPodium in animalPodiums do
						if not (typeof(animalPodium) == "table" and animalPodium.Machine and animalPodium.Machine.Type == object.MachineName and v7[animalPodium.Index]) then
							continue
						end

						if not (v7[animalPodium.Index] > 0) then
							continue
						end

						local index = animalPodium.Index
						v7[index] -= 1

						if typeof(animalPodium.Traits) == "table" then
							for k3, trait in animalPodium.Traits do
								v8[trait] = (v8[trait] or 0) + 1
							end
						end

						if animalPodium.Mutation then
							result[animalPodium.Mutation] = (result[animalPodium.Mutation] or 0) + 15
						end
					end
				end

				local v9 = Mutations.get()

				if v9 then
					result[v9] = (result[v9] or 0) + 15
				end

				local v10 = 100

				for k2, v11 in result do
					v10 -= v11
				end

				result.Normal = math.max(v10, 0)
				local result2 = {}

				for k2, v11 in v8 do
					result2[k2] = math.clamp(v11 / 3, 0, 1) * 30
				end

				return result, result2
			end

			local v7 = maid:Extend()
			local computeOdds2 = computeOdds

			local function updateOdds()
				v7:Clean()

				if not (mutations or traits) then
					return
				end

				local v11, v12 = computeOdds2()
				local visible = false

				if mutations then
					for i, frame in mutations.ScrollingFrame:GetChildren() do
						if frame:IsA("Frame") and frame.Name ~= "Template" then
							frame:Destroy()
						end
					end

					for k2, v14 in v11 do
						local mutation = Mutations2[k2]

						if not mutation then
							continue
						end

						local clone2 = mutations.ScrollingFrame.Template:Clone()
						clone2.Name = k2
						clone2.LayoutOrder = -v14
						clone2.Vector.Image = mutation.Icon or ""
						local v15 = MutationText.apply(clone2.Title, k2, "Auto")

						if v15 then
							v7:Add(v15)
						end

						local v16, v17 = math.modf(v14)
						clone2.Chance.Text = `{string.format(v17 == 0 and "%d" or "%.2f", v14)}%`
						clone2.Visible = true
						clone2.Parent = mutations.ScrollingFrame
						visible = true
					end

					mutations.Visible = visible
				end

				local visible2 = false

				if traits then
					for i, frame in traits.ScrollingFrame:GetChildren() do
						if frame:IsA("Frame") and frame.Name ~= "Template" then
							frame:Destroy()
						end
					end

					for k2, v15 in v12 do
						if v15 <= 0 then
							continue
						end

						local trait = Traits[k2]

						if not trait then
							continue
						end

						local clone2 = traits.ScrollingFrame.Template:Clone()
						clone2.Name = k2
						clone2.LayoutOrder = -v15
						clone2.Vector.Image = trait.Icon or ""
						clone2.Title.Text = trait.DisplayWithRichText
						clone2.Title.TextColor3 = trait.Color
						clone2.Title.RichText = true
						local v16, v17 = math.modf(v15)
						clone2.Chance.Text = `{string.format(v17 == 0 and "%d" or "%.2f", v15)}%`
						clone2.Visible = true
						clone2.Parent = traits.ScrollingFrame
						visible2 = true
					end

					traits.Visible = visible2
				end

				if child then
					child.Visible = visible or visible2
				end
			end

			maid:Add(v2:OnChanged("AnimalAddedOrRemoved", updateOdds))
			maid:Add(Mutations.watch(updateOdds))
			task.spawn(updateOdds)
			local v11 = AnimatedButton.new(clone.Output.Spawn)
			maid:Add(v11)
			v11:Animate()
			local v12 = k
			maid:Add(v11.OnActivated:Connect(function()
				object:Redeem(v12)
				class:Close()
			end))
			local v13 = nil
			local v14 = k
			local quantity = clone.Output.Quantity
			local parent = clone

			local function updateStock()
				local stock = object:GetStock(v14)
				quantity.TextColor3 = Color3.fromRGB(255, 255, 255)

				if stock == nil or stock > 0 then
					quantity.Text = stock and `{NumberUtils:Comma(stock)} Left` or "Loading..."

					if not v13 then
						v13 = Gradients.apply(parent.Output.Quantity, "Rainbow")
					end
				else
					quantity.TextColor3 = Color3.fromRGB(255, 0, 0)
					quantity.Text = "SOLD OUT"

					if v13 then
						v13()
						v13 = nil
					end
				end
			end

			maid:Add(function()
				if v13 then
					v13()
					v13 = nil
				end
			end)
			maid:Add(object:OnStockChange(k, updateStock))
			task.spawn(updateStock)
		end

		function class:Toggle()
			InterfaceController:Toggle("StockMachine")
		end

		function class.Open(_)
			InterfaceController:SetState("StockMachine", true)
		end

		function class:Close()
			InterfaceController:SetState("StockMachine", false)
		end

		function class:Destroy()
			maid:Destroy()
		end

		return class
	end
}