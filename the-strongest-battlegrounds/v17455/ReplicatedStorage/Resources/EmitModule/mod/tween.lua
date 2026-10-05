local RunService = game:GetService("RunService")
local module = require("./logger")
local module2 = require("./utility")
local module3 = require("../obj/Bezier")
local v = {}
local renderSteppedConnection = nil

local function ensureMaster()
	if renderSteppedConnection or #v == 0 then
		return
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local v2 = 1

		while v2 <= #v do
			local v3 = v[v2]

			if v3.dead then
				v[v2] = v[#v]
				v[#v] = nil
			else
				local success, result = pcall(v3.step, dt)

				if not success then
					warn("[EmitModule.tween] step error: " .. tostring(result))
					v3.dead = true
					v3.Connected = false
				end

				if v3.dead then
					v[v2] = v[#v]
					v[#v] = nil
				else
					v2 += 1
				end
			end
		end

		if #v == 0 and renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function makeEntry(step)
	local v2 = {
		__tweenEntry = true,
		step = step,
		dead = false,
		Connected = true
	}

	function v2:Disconnect()
		if v2.dead then
			return
		end

		v2.dead = true
		v2.Connected = false
	end

	return v2
end

local Tween = {}

function Tween.fromParams(p: string, p2: number, callback, p3, callback2, flag: boolean?, p4: number?)
	local success, result = pcall(function()
		return module2.deserializePath(p)
	end)

	if not success then
		module.error((`failed to decode bezier path data with error: {result}`))
	end

	local v2 = module3.new(result, 0)
	local v3 = 0
	local fn

	local function step(p5)
		if not flag and v3 == 0 then
			v3 = math.clamp(v3 + p5, 0, (math.max(p2, 0)))
		end

		local v6 = callback(1 - v2:getEase((math.clamp(v3 / p2, 0, 1))).y, p5, v3)

		if v6 == nil then
			if not (p3 and p3.Connected) then
				fn()

				if callback2 then
					callback2(true)
				end
			end
		else
			local v7

			if p2 == 0 then
				v7 = p2 < v3
			else
				v7 = p2 <= v3
			end

			if v7 then
				if p3 and p3.Connected then
					if v6 then
						v3 = math.clamp(v3 + v6, 0, (math.max(p2, 0.001)))
					end
				else
					fn()

					if callback2 then
						callback2(true)
					end
				end
			elseif v6 then
				v3 = math.clamp(v3 + v6, 0, (math.max(p2, 0.001)))
			end
		end
	end

	if p4 then
		local ranomId = module2.getRanomId()
		RunService:BindToRenderStep(ranomId, p4, step)
		local v4 = true

		fn = function()
			if not v4 then
				return
			end

			v4 = false
			RunService:UnbindFromRenderStep(ranomId)
		end

		return fn
	else
		local entry = makeEntry(step) -- equivalent call inferred; original call site unknown

		fn = function()
			entry:Disconnect()
		end

		table.insert(v, entry)

		if not renderSteppedConnection and #v ~= 0 then
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				local v4 = 1

				while v4 <= #v do
					local v5 = v[v4]

					if v5.dead then
						v[v4] = v[#v]
						v[#v] = nil
					else
						local success2, result2 = pcall(v5.step, dt)

						if not success2 then
							warn("[EmitModule.tween] step error: " .. tostring(result2))
							v5.dead = true
							v5.Connected = false
						end

						if v5.dead then
							v[v4] = v[#v]
							v[#v] = nil
						else
							v4 += 1
						end
					end
				end

				if #v == 0 and renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)
		end

		return entry
	end
end

function Tween.timer(p: number, callback, p2, list, p3: number?)
	local thread = coroutine.running()
	local v2 = 0
	local fn

	local function step(p4)
		local v3 = callback(p4, v2)

		if v3 == nil then
			if not (p2 and p2.Connected) then
				fn()
				task.spawn(thread)
			end
		else
			local v4

			if p == 0 then
				v4 = p < v2
			else
				v4 = p <= v2
			end

			if v4 then
				if p2 and p2.Connected then
					if v3 then
						v2 = math.clamp(v2 + v3, 0, (math.max(p, 0.001)))
					end
				else
					fn()
					task.spawn(thread)
				end
			elseif v3 then
				v2 = math.clamp(v2 + v3, 0, (math.max(p, 0.001)))
			end
		end
	end

	if p3 then
		local ranomId = module2.getRanomId()
		RunService:BindToRenderStep(ranomId, p3, step)
		local v3 = true

		fn = function()
			if not v3 then
				return
			end

			v3 = false
			RunService:UnbindFromRenderStep(ranomId)
		end

		if list then
			table.insert(list, fn)
		end
	else
		local entry = makeEntry(step) -- equivalent call inferred; original call site unknown

		fn = function()
			entry:Disconnect()
		end

		table.insert(v, entry)

		if not renderSteppedConnection and #v ~= 0 then
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				local v3 = 1

				while v3 <= #v do
					local v4 = v[v3]

					if v4.dead then
						v[v3] = v[#v]
						v[#v] = nil
					else
						local success, result = pcall(v4.step, dt)

						if not success then
							warn("[EmitModule.tween] step error: " .. tostring(result))
							v4.dead = true
							v4.Connected = false
						end

						if v4.dead then
							v[v3] = v[#v]
							v[#v] = nil
						else
							v3 += 1
						end
					end
				end

				if #v == 0 and renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)
		end

		if list then
			table.insert(list, entry)
		end
	end

	coroutine.yield()
end

return Tween