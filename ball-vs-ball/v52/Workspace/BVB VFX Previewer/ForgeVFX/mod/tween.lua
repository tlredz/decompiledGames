local RunService = game:GetService("RunService")
local module = require("./logger")
local module2 = require("./utility")
local module3 = require("../obj/Bezier")
local Tween = {
	bezier_cache = {}
}

function Tween.fromParams(p: string, p2: number, callback, p3, callback2, flag: boolean?, p4: number?)
	local v = Tween.bezier_cache[p]

	if not v then
		local success, result = pcall(function()
			return module2.deserializePath(p)
		end)

		if not success then
			module.error((`failed to decode bezier path data with error: {result}`))
		end

		v = module3.new(result, 0)
		Tween.bezier_cache[p] = v
	end

	local v2 = 0
	local fn

	local function step(p5)
		if not flag and v2 == 0 then
			v2 = math.clamp(v2 + p5, 0, (math.max(p2, 0)))
		end

		local v5 = callback(1 - v:getEase((math.clamp(v2 / p2, 0, 1))).y, p5, v2)

		if v5 == nil then
			if not (p3 and p3.Connected) then
				fn()

				if callback2 then
					callback2(true)
				end
			end
		else
			local v6

			if p2 == 0 then
				v6 = p2 < v2
			else
				v6 = p2 <= v2
			end

			if v6 then
				if p3 and p3.Connected then
					if v5 then
						v2 = math.clamp(v2 + v5, 0, (math.max(p2, 0.001)))
					end
				else
					fn()

					if callback2 then
						callback2(true)
					end
				end
			elseif v5 then
				v2 = math.clamp(v2 + v5, 0, (math.max(p2, 0.001)))
			end
		end
	end

	if p4 then
		local randomId = module2.getRandomId()
		RunService:BindToRenderStep(randomId, p4, step)
		local v3 = true

		fn = function()
			if not v3 then
				return
			end

			v3 = false
			RunService:UnbindFromRenderStep(randomId)
		end

		return fn
	else
		local renderSteppedConnection = RunService.RenderStepped:Connect(step)

		fn = function()
			renderSteppedConnection:Disconnect()
		end

		return renderSteppedConnection
	end
end

function Tween.timer(p: number, callback, p2, list, p3: number?)
	local thread = coroutine.running()
	local v = 0
	local fn

	local function step(p4)
		local v2 = callback(p4, v)

		if v2 == nil then
			if not (p2 and p2.Connected) then
				fn()
				task.spawn(thread)
			end
		else
			local v3

			if p == 0 then
				v3 = p < v
			else
				v3 = p <= v
			end

			if v3 then
				if p2 and p2.Connected then
					if v2 then
						v = math.clamp(v + v2, 0, (math.max(p, 0.001)))
					end
				else
					fn()
					task.spawn(thread)
				end
			elseif v2 then
				v = math.clamp(v + v2, 0, (math.max(p, 0.001)))
			end
		end
	end

	if p3 then
		local randomId = module2.getRandomId()
		RunService:BindToRenderStep(randomId, p3, step)
		local v2 = true

		fn = function()
			if not v2 then
				return
			end

			v2 = false
			RunService:UnbindFromRenderStep(randomId)
		end
	else
		local renderSteppedConnection = RunService.RenderStepped:Connect(step)

		fn = function()
			renderSteppedConnection:Disconnect()
		end
	end

	if list then
		table.insert(list, fn)
	end

	coroutine.yield()
end

return Tween