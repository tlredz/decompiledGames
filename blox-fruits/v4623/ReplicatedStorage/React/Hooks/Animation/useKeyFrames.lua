local RunService = game:GetService("RunService")
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
return function(list, flag: boolean, flag2: boolean?, value: number?)
	local v = ""

	for k, v2 in list do
		v ..= `[{k}|{v2.Id}:{v2.Duration}]`
	end

	local v2 = React.useMemo(function()
		assert(#list >= 2, "keyframe sequence requires at least 2 frames")
		local total = 0

		for i = 1, #list do
			local v3 = list[i]

			if v3.Duration <= 0 then
				error((`keyframe #{i} has a duration <= 0`))
			end

			total += v3.Duration
		end

		local v3 = {
			Duration = total,
			Frames = TableUtil.deepCopy(list)
		}
		TableUtil.deepFreeze(v3)
		return v3
	end, { v, value })
	local ref = React.useRef(0)
	local state, setState = React.useState(v2.Frames[1].Id)
	local state2, setState2 = React.useState(0)
	React.useEffect(function()
		if not flag then
			ref.current = 0
			return function() end
		end

		local v3 = value or 1
		local duration = v2.Duration

		local function applyTime(current: number)
			local v4 = 0

			for _, frame in v2.Frames do
				local v5 = v4 + frame.Duration

				if current < v5 then
					setState(frame.Id)
					setState2((math.clamp((current - v4) / frame.Duration, 0, 1)))
					return
				else
					v4 = v5
				end
			end

			setState(v2.Frames[#v2.Frames].Id)
			setState2(1)
		end

		local v4

		if v3 > 0 and duration <= ref.current then
			v4 = true
		elseif v3 < 0 then
			v4 = ref.current <= 0
		else
			v4 = false
		end

		if v3 == 0 or v4 and not flag2 then
			applyTime(ref.current)
			return function() end
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			ref.current += dt * v3
			local flag3 = false

			if flag2 then
				ref.current %= duration
			elseif v3 > 0 then
				if duration <= ref.current then
					ref.current = duration
					flag3 = true
				elseif v3 < 0 and ref.current <= 0 then
					ref.current = 0
					flag3 = true
				end
			elseif v3 < 0 and ref.current <= 0 then
				ref.current = 0
				flag3 = true
			end

			applyTime(ref.current)

			if flag3 then
				renderSteppedConnection:Disconnect()
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, {
		flag,
		flag2,
		value,
		v2
	})
	return state, state2
end