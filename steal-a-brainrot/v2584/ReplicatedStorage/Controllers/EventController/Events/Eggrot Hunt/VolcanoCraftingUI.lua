local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local Animals = require(ReplicatedStorage.Shared.Animals)
local CustomRichTextController = require(ReplicatedStorage.Controllers.CustomRichTextController)
local localPlayer = Players.LocalPlayer
Color3.fromRGB(255, 100, 20)
return table.freeze({
	Start = function(_)
		local maid = Trove.new()
		local v = nil
		local v2 = nil
		local parent2 = nil

		local function refresh()
			local v4 = Synchronizer:Get(localPlayer)
			local v5

			if v4 then
				v5 = v4:Get({ "EasterEvent", "VolcanoMachine" })
			end

			local inputs

			if type(v5) == "table" and type(v5.Inputs) == "table" then
				inputs = v5.Inputs
			end

			local v6 = (type(v5) ~= "table" or type(v5.CraftCost) ~= "number") and 0 or v5.CraftCost
			local v7 = inputs and #inputs or 0
			local stealing = localPlayer:GetAttribute("Stealing") == true
			local stealingFromVolcano = localPlayer:GetAttribute("StealingFromVolcano") == true

			if v then
				if stealing and stealingFromVolcano then
					v.ActionText = "Return Brainrot"
					v.Enabled = true
				elseif stealing and v7 < 3 then
					v.ActionText = `Insert Brainrot ({v7}/{3})`
					v.Enabled = true
				elseif stealing or not (v7 >= 3) then
					v.ActionText = `Insert Brainrot ({v7}/{3})`
					v.Enabled = false
				else
					v.ActionText = `Craft (${NumberUtils:ToString(v6)})`
					v.Enabled = true
				end
			end

			if v2 then
				v2.Enabled = v7 >= 1 and not stealing
			end

			if parent2 then
				for _, label in parent2:GetChildren() do
					if label:IsA("TextLabel") then
						label:Destroy()
					end
				end

				if inputs and #inputs > 0 then
					local count = #inputs
					local v8 = math.floor(100 / count)
					local v9 = 100 - v8 * count

					for k, input in inputs do
						if not (type(input) == "table" and type(input.Index) == "string") then
							continue
						end

						local v10 = v8 + (k <= v9 and 1 or 0)
						local displayName = Animals:GetDisplayName(input.Index)
						local textLabel = Instance.new("TextLabel")
						textLabel.Name = `Slot{k}`
						textLabel.Size = UDim2.new(1, 0, 0.3333333333333333, 0)
						textLabel.BackgroundTransparency = 1
						textLabel.TextColor3 = Color3.new(1, 1, 1)
						textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
						textLabel.TextStrokeTransparency = 0.3
						textLabel.TextScaled = true
						textLabel.Font = Enum.Font.GothamBold
						textLabel.TextXAlignment = Enum.TextXAlignment.Center
						textLabel.LayoutOrder = k
						textLabel.Parent = parent2
						local uIStroke = Instance.new("UIStroke")
						uIStroke.Thickness = 3
						uIStroke.Parent = textLabel
						CustomRichTextController.apply(textLabel, `{displayName} - {v10}%`, {
							attachToInstance = true
						})
					end
				end
			end
		end

		Synchronizer:WaitAndCall(localPlayer, function(object)
			maid:Add(object:OnChanged({ "EasterEvent", "VolcanoMachine" }, refresh))
			task.spawn(refresh)
		end)
		maid:Add(localPlayer:GetAttributeChangedSignal("Stealing"):Connect(refresh))
		maid:Add(localPlayer:GetAttributeChangedSignal("StealingFromVolcano"):Connect(refresh))
		maid:Add(Observers.observeTag("EggrotVolcanoInsertCraft", function(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return nil
			end

			v = proximityPrompt
			refresh()
			return function()
				if v == proximityPrompt then
					v = nil
				end
			end
		end, { workspace }))
		maid:Add(Observers.observeTag("EggrotVolcanoWithdraw", function(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return nil
			end

			v2 = proximityPrompt
			refresh()
			return function()
				if v2 == proximityPrompt then
					v2 = nil
				end
			end
		end, { workspace }))
		maid:Add(Observers.observeTag("EggrotVolcanoMachine", function(parent)
			local v4 = Trove.new()
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = "VolcanoContents"
			billboardGui.AlwaysOnTop = false
			billboardGui.Size = UDim2.fromScale(30, 6)
			billboardGui.StudsOffset = createVector(0, 10, 0)
			billboardGui.MaxDistance = 300
			billboardGui.Parent = parent
			v4:Add(billboardGui)
			local frame = Instance.new("Frame")
			frame.Name = "Container"
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundTransparency = 1
			frame.Parent = billboardGui
			v4:Add(frame)
			local uIListLayout = Instance.new("UIListLayout")
			uIListLayout.FillDirection = Enum.FillDirection.Vertical
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			uIListLayout.Padding = UDim.new(0.02, 0)
			uIListLayout.Parent = frame
			parent2 = frame
			refresh()
			return function()
				v4:Destroy()

				if parent2 == frame then
					parent2 = nil
				end
			end
		end, { workspace }))
		return function()
			maid:Destroy()
		end
	end
})