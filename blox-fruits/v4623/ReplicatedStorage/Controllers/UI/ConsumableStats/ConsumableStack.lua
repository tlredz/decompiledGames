local createVector = vector.create
require(game.ReplicatedStorage.Modules.Consumables.Types)
local ConsumablesClient = require(game.ReplicatedStorage.Controllers.ConsumablesClient)
local Tooltip = require(script.Parent.Tooltip)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local UserInputService = game:GetService("UserInputService")
local v = nil

local function createTooltip(p)
	return Tooltip(p)
end

local function ifHovering(p)
	if v and v.Frame == p then
		return true
	end

	return false
end

return function(instance, p, effectType: string)
	local duration = instance:FindFirstChild("Duration")
	local imageLabel = instance:FindFirstChild("ImageLabel")
	local shaded = instance:FindFirstChild("Shaded")
	local uIGradient = imageLabel:FindFirstChild("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB()),
		ColorSequenceKeypoint.new(1, Color3.fromRGB())
	})
	uIGradient.Rotation = 125
	local v2 = {
		_Destroyed = false,
		Rbx = instance,
		ConsumablesInQueue = {}
	}
	local maid = Trove.new()
	maid:Add(instance)
	maid:Add(function()
		if v and v.Frame == instance then
			v = nil
			p.Visible = false
		end
	end)
	local v3 = maid:Add((Signal.new()))

	function v2.OnMouseEnter(_, p3)
		if v and v.Frame == instance then
			task.defer(function()
				if v and v.Frame == instance then
					assert(v)
					v3:Fire(v)
				end
			end)
		end

		return v3:Connect(p3)
	end

	local v4 = nil

	function v2:Update(_: number)
		if self._Destroyed then
			return
		end

		for i = 1, #self.ConsumablesInQueue do
			local v5 = self.ConsumablesInQueue[i]

			if i ~= 1 then
				continue
			end

			local v6

			if v5.TimeExpires then
				local duration2 = v5.TimeExpires - workspace:GetServerTimeNow()

				if not v5.Enabled then
					duration2 = v5.Duration
				end

				v6 = math.round((math.max(0, duration2)))
			end

			if v4 ~= v5.StorageName then
				ImageUtil.applySpriteFromItemId(v5.StorageName, {
					"Material",
					"Fish",
					"Bait",
					"Scroll",
					"Tool",
					"Consumable",
					"Potion"
				}, {
					Icon = imageLabel
				})
				ImageUtil.applySpriteFromItemId(v5.StorageName, {
					"Material",
					"Fish",
					"Bait",
					"Scroll",
					"Tool",
					"Consumable",
					"Potion"
				}, {
					Icon = shaded
				})
			end

			if v5.EffectType == "Food" then
				duration.Text = ""

				if v5.Enabled then
					imageLabel.ImageTransparency = 0
					local v7 = {
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.001 + (1 - ConsumablesClient.Hunger) * 0.998, 0),
						NumberSequenceKeypoint.new(0.001 + (1 - ConsumablesClient.Hunger) * 0.998 + 0.001, 1),
						NumberSequenceKeypoint.new(1, 1)
					}
					uIGradient.Transparency = NumberSequence.new(v7)
				else
					imageLabel.ImageTransparency = 0.5
				end
			else
				imageLabel.ImageTransparency = v5.Enabled and 0 or 0.5

				if v6 then
					duration.Text = TimeUtil.format(v6, "minimal")
					duration.Visible = true
				else
					duration.Text = ""
					duration.Visible = false
				end
			end

			shaded.Visible = v5.EffectType == "Food" and v5.Enabled
			uIGradient.Enabled = v5.EffectType == "Food" and v5.Enabled
		end

		local v5

		if self.ConsumablesInQueue[1] then
			v5 = self.ConsumablesInQueue[1].StorageName
		end

		v4 = v5

		if v and v.Frame == instance then
			Tooltip(p):Update()
		end
	end

	function v2:Destroy()
		if not self._Destroyed then
			self._Destroyed = true
			maid:Destroy()
		end
	end

	local maid2 = nil

	local function tryHideTooltip()
		if v2._Destroyed then
			return
		end

		if v and v.Frame == instance then
			v = nil
			p.Visible = false

			if maid2 then
				maid2:Destroy()
			end
		end
	end

	local function stackInteracted(_: string)
		if v2._Destroyed then
			return
		end

		if maid2 then
			maid2:Destroy()
		end

		v = {
			EffectType = effectType,
			Frame = instance,
			Refresh = function()
				Tooltip(p):Reflect(instance, v2.ConsumablesInQueue)
			end
		}
		assert(v).Refresh()

		if v and v.Frame == instance then
			v3:Fire(v)
		end
	end

	local position = createVector(0, 0, 0)
	maid:Add(instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch and not UserInputService.MouseEnabled then
			if maid2 then
				maid2:Destroy()
			end

			maid2 = maid:Extend()
			assert(maid2):Add(function()
				maid2 = nil
				position = createVector(0, 0, 0)
			end)
			position = input.Position
			maid2:Add(UserInputService.InputChanged:Connect(function(input2)
				if input2.UserInputType == Enum.UserInputType.Touch and (input2.Position - position).Magnitude > 5 then
					maid2:Destroy()
				end
			end))
			maid2:Add(UserInputService.InputEnded:Connect(function(input2)
				if input2.UserInputType == Enum.UserInputType.Touch then
					maid2:Destroy()
				end
			end))
			maid2:Add(task.delay(0.33, function()
				if maid2 then
					maid2:Destroy()
				end

				stackInteracted("TouchTap")
			end))
		end
	end))
	maid:Add(instance.MouseEnter:Connect(function()
		if UserInputService.MouseEnabled then
			stackInteracted("MouseEnter")
		end
	end))
	maid:Add(instance.MouseLeave:Connect(function()
		if v2._Destroyed then
			return
		end

		if v and v.Frame == instance then
			v = nil
			p.Visible = false

			if maid2 then
				maid2:Destroy()
			end
		end
	end))
	return v2
end