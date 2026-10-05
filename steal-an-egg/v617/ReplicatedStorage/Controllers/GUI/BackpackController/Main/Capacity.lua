local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local HoverCard = require(ReplicatedStorage.Client.HoverCard)
local Save = require(ReplicatedStorage.Shared.Save)
local Trove = require(ReplicatedStorage.Packages.Trove)

local function count(options)
	local count2 = 0

	for _ in options or {} do
		count2 += 1
	end

	return count2
end

return function(parent, p)
	local maid = Trove.new()
	local textButton = Instance.new("TextButton")
	textButton.Name = "Capacity"
	textButton.BackgroundTransparency = 1
	textButton.AutoButtonColor = false
	textButton.TextXAlignment = Enum.TextXAlignment.Left
	textButton.Font = Enum.Font.GothamBold
	textButton.TextScaled = true
	local uDim = UDim2.fromScale(0.015, 0.1)
	textButton.Position = uDim
	textButton.Size = UDim2.fromScale(0.3, 0.06)
	textButton.TextColor3 = Color3.fromRGB(225, 225, 235)
	textButton.TextStrokeColor3 = Color3.fromRGB(20, 20, 25)
	textButton.TextStrokeTransparency = 0.3
	textButton.Selectable = true
	textButton.ZIndex = 3
	textButton.Parent = parent
	maid:Add(textButton)
	local capacityCategory = "Pets"
	local v = 0
	local LIMIT = Constants.BACKPACK.LIMIT
	local v2 = false
	local total = 0
	local v3 = nil
	local count2 = 0
	local screenGui = parent:FindFirstAncestorOfClass("ScreenGui")

	local function isOpen()
		local visible = textButton.Visible and parent.Visible and p.Visible

		if visible then
			if screenGui == nil then
				visible = false
			else
				visible = screenGui.Enabled
			end
		end

		return visible
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopWiggle()
		count2 += 1

		if v3 then
			v3:Cancel()
			v3 = nil
		end

		textButton.Position = uDim
		total = 0
	end

	local function refresh()
		capacityCategory = parent:GetAttribute("CapacityCategory") or "Pets"
		textButton.Visible = capacityCategory == "Pets" or capacityCategory == "Eggs"

		if textButton.Visible then
			local v4 = Save.Await()

			if not v4 then
				textButton.Text = "Capacity loading..."
				return
			end

			local inventory

			if capacityCategory == "Pets" then
				inventory = v4.Inventory
			else
				inventory = v4.EggInventory
			end

			local count3 = 0

			for _ in inventory or {} do
				count3 += 1
			end

			v = count3
			local v5

			if capacityCategory == "Pets" then
				v5 = Constants.BACKPACK.LIMIT
			else
				v5 = Eggs.MAX_INVENTORY
			end

			LIMIT = v5
			textButton.Text = `{capacityCategory}: {v}/{LIMIT}`
			local v6 = v / LIMIT
			v2 = v6 >= 1
			local v7 = textButton
			local textColor

			if v6 >= 0.9 then
				textColor = Color3.fromRGB(255, 80, 85)
			else
				textColor = Color3.fromRGB(225, 225, 235)
			end

			v7.TextColor3 = textColor

			if not v2 then
				stopWiggle() -- equivalent call inferred; original call site unknown
			end
		else
			v2 = false
			stopWiggle() -- equivalent call inferred; original call site unknown
		end
	end

	local function tooltipRows()
		if not textButton.Visible then
			return nil
		end

		local v4 = {
			{
				kind = "heading",
				text = `{capacityCategory}: {v} / {LIMIT}`
			}
		}

		if LIMIT < v then
			table.insert(v4, {
				kind = "rule"
			})
			table.insert(v4, {
				kind = "body",
				text = `Overflow: +{v - LIMIT}. Purchases or special grants can exceed the limit.`
			})
		end

		return v4
	end

	local v4 = HoverCard.Attach(textButton, tooltipRows)
	maid:Add(function()
		v4()
	end)
	maid:Add(parent:GetAttributeChangedSignal("CapacityCategory"):Connect(function()
		v4()
		stopWiggle() -- equivalent call inferred; original call site unknown
		refresh()
		v4 = HoverCard.Attach(textButton, tooltipRows)
	end))
	maid:Add(Save.Watch("Inventory"):Connect(refresh))
	maid:Add(Save.Watch("EggInventory"):Connect(refresh))
	maid:Add(Save.Loaded:Connect(refresh))
	maid:Add(RunService.Heartbeat:Connect(function(dt)
		if v2 then
			local visible = textButton.Visible and parent.Visible and p.Visible

			if visible then
				if screenGui == nil then
					visible = false
				else
					visible = screenGui.Enabled
				end
			end

			if visible then
				total += dt

				if total < 8 then
					return
				end

				total = 0
				count2 += 1
				local v5 = count2
				task.spawn(function()
					for _, v6 in {
						-2,
						2,
						-1,
						0
					} do
						if v5 ~= count2 or not textButton.Parent then
							return
						end

						local visible2 = textButton.Visible and parent.Visible and p.Visible

						if visible2 then
							if screenGui == nil then
								visible2 = false
							else
								visible2 = screenGui.Enabled
							end
						end

						if not visible2 then
							return
						end

						local tween = TweenService:Create(textButton, TweenInfo.new(0.09), {
							Position = uDim + UDim2.fromOffset(v6, 0)
						})
						v3 = tween
						tween:Play()
						tween.Completed:Wait()
						continue
					end

					if v5 == count2 then
						v3 = nil
					end
				end)
				return
			end
		end

		if total > 0 or v3 then
			stopWiggle() -- equivalent call inferred; original call site unknown
		end
	end))
	maid:Add(stopWiggle)
	parent.Destroying:Once(function()
		maid:Destroy()
	end)
	refresh()
end