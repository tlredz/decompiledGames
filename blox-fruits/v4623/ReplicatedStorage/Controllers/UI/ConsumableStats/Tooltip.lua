require(game.ReplicatedStorage.Modules.Consumables.Types)
local ConsumablesClient = require(game.ReplicatedStorage.Controllers.ConsumablesClient)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local MathUtil = require(game.ReplicatedStorage.Modules.Util.MathUtil)
local ColorUtil = require(game.ReplicatedStorage.Modules.Util.ColorUtil)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
require(game.ReplicatedStorage.Modules.Consumables.Potions)
require(game.ReplicatedStorage.Modules.Consumables.Food)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local v = nil
return function(parent)
	if v then
		return v
	end

	local now = tick()
	local clones = {}
	local uIScale = parent:FindFirstChildOfClass("UIScale")
	local consumableName = parent:FindFirstChild("ConsumableName")
	local uIGradient = consumableName:FindFirstChildOfClass("UIGradient")
	local timer = parent:FindFirstChild("Timer")
	local description = parent:FindFirstChild("Description")
	local queuedheader = parent:FindFirstChild("Queuedheader")
	local queuedRef = parent:FindFirstChild("QueuedRef")
	local dividerLine2 = parent:FindFirstChild("DividerLine2")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function platformChanged()
		uIScale.Scale = LastInput:GetScaleForPlatform()
	end

	LastInput.Changed:Connect(platformChanged)
	platformChanged() -- equivalent call inferred; original call site unknown
	local v2 = nil
	local v3 = {
		Update = function(self)
			if not v2 then
				return
			end

			local UserInputService = game:GetService("UserInputService")
			local mouseLocation = UserInputService:GetMouseLocation()
			local _ = parent.AbsoluteSize
			parent.Position = UDim2.new(0, mouseLocation.X + 3, 0, mouseLocation.Y - 3)

			if v2.Enabled then
				if v2.Type == "Food" then
					timer.Text = `{MathUtil.round(ConsumablesClient.Hunger * 100, 1)}%`
				elseif v2.TimeExpires then
					local v4 = math.round((math.max(0, v2.TimeExpires - workspace:GetServerTimeNow())))
					timer.Text = TimeUtil.format(v4, "minimal")
				else
					timer.Text = ""
				end
			else
				timer.Text = "[PAUSED]"
			end

			timer.Visible = timer.Text ~= ""
		end
	}

	function v3.Reflect(_, _, list)
		now = tick()
		v2 = list[1]

		if not v2 then
			return v3
		end

		local v4 = now

		for _, v5 in pairs(clones) do
			v5.Visible = false
			v5.LayoutOrder = 0
		end

		consumableName.Text = v2.DisplayName
		local color = assert(RarityUtil.tryGetRarity(v2.Rarity), (`bad rarity for "{v2.Rarity}"`)).Color
		local tuneBrightness = ColorUtil.tuneBrightness(color, 0.7)
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, tuneBrightness),
			ColorSequenceKeypoint.new(0.5, color),
			ColorSequenceKeypoint.new(1, tuneBrightness)
		})
		description.Text = v2.Description or ""
		description.Visible = description.Text ~= ""
		queuedRef.Visible = false
		local v5 = 0

		for i = 1, #list do
			if now ~= v4 then
				break
			end

			local v6 = list[i]

			if v6.StorageName == v2.StorageName then
				continue
			end

			local roman = TextUtil.toRoman(v6.Rarity + 1)
			local clone = parent:FindFirstChild((`Queue:{roman}`))

			if not clone then
				clone = queuedRef:Clone()
				local assert_2 = assert(clone, "bad tierLabel")
				assert_2.Parent = parent
				table.insert(clones, clone)
			end

			assert(clone, "bad tierLabel")
			clone.Name = `Queue:{roman}`

			if v6.Duration then
				clone.Text = `Tier {roman}: {TimeUtil.format(v6.Duration, "minimal")}`
			else
				clone.Text = `Tier {roman}`
			end

			clone.LayoutOrder = i + 10
			clone.Visible = true
			v5 = i
		end

		if now ~= v4 then
			return v3
		end

		dividerLine2.Visible = v5 > 0
		queuedheader.Visible = v5 > 0
		v3:Update()
		parent.Visible = true
		return v3
	end

	v = v3
	return v3
end