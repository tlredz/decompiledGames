local TweenService = game:GetService("TweenService")
require(script.Parent.Parent.types)
local config = require(script.Parent.Parent.config)
local intermediate = require(script.Parent.Parent.utils.intermediate)
local merge = require(script.Parent.Parent.utils.merge)

local function createTween(value: number, index: number, data)
	local tweenInfo = TweenInfo.new(
		data.time,
		data.style,
		data.direction,
		data.repeatCount,
		data.reverses,
		data.delayTime
	)
	local numberValue = Instance.new("NumberValue")
	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = index
	})
	numberValue.Value = value
	return {
		value = numberValue,
		tween = tween,
		complete = false
	}
end

local function tween(p, options)
	local v = merge(config.tween.default, options or {})
	local v2 = intermediate.to(p)
	local v3 = {}
	return function(p2, state)
		local index = intermediate.index(v2, p2)

		if not index then
			return false
		end

		if not state.destructor then
			local tween2 = createTween(state.value, index, v)
			v3[p2] = tween2
			tween2.tween.Completed:Connect(function()
				tween2.complete = true
				tween2.value:Destroy()
				tween2.tween:Destroy()
			end)
			tween2.tween:Play()

			function state.destructor()
				tween2.tween:Destroy()
				tween2.value:Destroy()
				v3[p2] = nil
			end
		end

		local v4 = v3[p2]

		if not v4 then
			state.complete = true
			return
		end

		if not v4.complete then
			state.value = v4.value.Value
			return
		end

		state.complete = true
		state.value = index
	end
end

return tween