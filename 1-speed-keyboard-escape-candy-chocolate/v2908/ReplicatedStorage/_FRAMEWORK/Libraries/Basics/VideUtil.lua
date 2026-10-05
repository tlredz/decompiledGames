local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ripple = require(ReplicatedStorage.Packages.ripple)
local Vide = require(ReplicatedStorage.Packages.Vide)

-- equivalent calls inferred from this helper; original call sites unknown
local function toTagArray(value)
	if type(value) == "string" then
		return { value }
	end

	return value
end

local VideUtil = {}

function VideUtil.read(callback)
	if type(callback) == "function" then
		return callback()
	end

	return callback
end

function VideUtil.defaulted(p, p2)
	if p == nil then
		return p2
	end

	return p
end

function VideUtil.TweenedSource(callback, value: number?, value2)
	local v

	if type(callback) == "function" then
		v = callback
	else
		v = Vide.source(callback)
	end

	local v2 = v()
	local source = Vide.source(v2)
	local tween = ripple.createTween(v2, {
		duration = value or 0.1,
		easing = value2 or "quadOut",
		start = true
	})
	local v3 = tween:onChange(function(p)
		source(p)
	end)

	if type(callback) == "function" then
		Vide.effect(function()
			tween:setGoal(callback())
		end)
	end

	Vide.cleanup(function()
		v3()
		tween:destroy()
	end)
	return function(p, flag: boolean?, p2)
		if p == nil then
			return source()
		end

		if p2 then
			tween:configure(p2)
		end

		if flag then
			tween:setPosition(p)
		end

		tween:setGoal(p)
		return nil
	end
end

function VideUtil.addTag(callback)
	return Vide.action(function(instance)
		if type(callback) == "function" then
			Vide.effect(function(items)
				local tagArray = toTagArray(callback()) -- equivalent call inferred; original call site unknown

				for _, tag in items do
					if not table.find(tagArray, tag) then
						instance:RemoveTag(tag)
					end
				end

				for _, tag in tagArray do
					instance:AddTag(tag)
				end

				return table.clone(tagArray)
			end, {})
			return
		end

		local v = callback

		if type(v) == "string" then
			v = { v }
		end

		for _, tag in v, nil, nil do
			instance:AddTag(tag)
		end
	end)
end

function VideUtil.tagged(instance, value)
	if type(value) == "string" then
		value = { value }
	end

	for _, tag in value, nil, nil do
		instance:AddTag(tag)
	end

	return instance
end

return VideUtil