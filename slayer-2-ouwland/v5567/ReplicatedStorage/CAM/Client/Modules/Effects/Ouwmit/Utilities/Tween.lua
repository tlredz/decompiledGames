local Tween = {}
local OuwmitUtility = require(script.Parent.OuwmitUtility)
local Bezier = require(script.Parent.Bezier)
local RunService = game:GetService("RunService")
local insert = table.insert
local find = table.find
local remove = table.remove
local v = {}
local v2 = 0
local v3 = {}

local function getBezier(p: string)
	local v4 = v3[p]

	if v4 == nil then
		v4 = Bezier.new(OuwmitUtility.deserializePath(p), 0)
		v3[p] = v4
	end

	return v4
end

local v4 = {}

function Upd(p)
	local count = #v
	table.move(v, 1, count, 1, v4)

	for i = 1, count do
		v4[i](p)
		v4[i] = nil
	end
end

local clamp = math.clamp

function Tween.new(p: string, p2: number, callback, callback2)
	if p == nil or p2 == nil or callback == nil then
		return
	end

	local v5 = math.max(p2, 0.001)
	local v6 = v3[p]

	if v6 == nil then
		v6 = Bezier.new(OuwmitUtility.deserializePath(p), 0)
		v3[p] = v6
	end

	local total = 0
	local flag = false
	local fn

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop()
		if flag then
			return
		end

		flag = true
		local index = find(v, fn)

		if index == nil then
			return
		end

		remove(v, index)
		v2 -= 1

		if v2 == 0 then
			RunService:UnbindFromRenderStep("ForgeEmitBind")
		end
	end

	fn = function(p3)
		if flag then
			return
		end

		local v8 = clamp(total / v5, 0, 1)
		local success, result = pcall(callback, 1 - v6:getEase(v8).y, p3, total)

		if success then
			if v8 == 1 then
				stop() -- equivalent call inferred; original call site unknown

				if callback2 ~= nil then
					callback2()
				end
			else
				if result ~= nil then
					total += result
					return
				end

				stop() -- equivalent call inferred; original call site unknown
			end
		else
			stop() -- equivalent call inferred; original call site unknown
			warn("Tween broke due to an error: " .. tostring(result))
		end
	end

	v2 += 1
	insert(v, fn)

	if v2 == 1 then
		RunService:BindToRenderStep("ForgeEmitBind", Enum.RenderPriority.Last.Value, Upd)
	end

	return stop
end

return Tween