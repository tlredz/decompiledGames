local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local Map = require(game.ReplicatedStorage.Definitions.Map)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local PUZZLE = CONSTANTS.PUZZLE
local DEFAULT_THEME = CONSTANTS.DEFAULT_THEME
local frozen = table.freeze({})
local frozen2 = table.freeze({})
local frozen3 = table.freeze({})

local function solveTiers(items)
	local v = {}
	local minimumLevels = {}

	for _, item in items do
		local minimumLevel = Map.getMinimumLevel(item)
		local v2 = v[minimumLevel]

		if not v2 then
			v2 = {}
			v[minimumLevel] = v2
			table.insert(minimumLevels, minimumLevel)
		end

		table.insert(v2, item)
	end

	table.sort(minimumLevels)
	local values = table.create(#minimumLevels)
	local v2 = {}

	for k, v3 in minimumLevels do
		local v4 = v[v3]

		for _, v5 in v4 do
			v2[v5.Index.Key] = k
		end

		values[k] = table.freeze(v4)
	end

	return table.freeze({
		Groups = table.freeze(values),
		IndexByKey = table.freeze(v2)
	})
end

local function getIslandTheme(p)
	local color = p.Display.Color
	local HSV, v, v2 = color:ToHSV()
	return table.freeze({
		Background = Color3.fromHSV(
			HSV,
			math.min(v * PUZZLE.BACKGROUND_SATURATION_BOOST, 1),
			v2 * PUZZLE.BACKGROUND_VALUE
		),
		Primary = color,
		Secondary = Color3.fromHSV(
			(HSV + PUZZLE.SECONDARY_HUE_SHIFT) % 1,
			math.max(v, PUZZLE.SECONDARY_MIN_SATURATION),
			(math.max(v2, PUZZLE.SECONDARY_MIN_VALUE))
		),
		Text = DEFAULT_THEME.Text
	})
end

local function hide(items, group)
	local v = {}

	for _, item in group do
		v[item.Index.Key] = true
	end

	local values = {}

	for _, item in items do
		if not v[item.Key] then
			table.insert(values, item)
		end
	end

	for _, item in group do
		table.insert(values, table.freeze({
			Key = item.Index.Key
		}))
	end

	return table.freeze(values)
end

local function scheduleReturn(items)
	local values = {}
	local v = {}

	for _, item in items do
		if item.ReturnAt then
			table.insert(values, item)
		else
			table.insert(v, item)
		end
	end

	local count = #v

	if count == 0 then
		return items
	end

	local now = os.clock()
	local v2 = not (count > 1) and 0 or PUZZLE.RETURN_DURATION / (count - 1)

	for i = count, 1, -1 do
		table.insert(values, table.freeze({
			Key = v[i].Key,
			ReturnAt = now + (count - i) * v2
		}))
	end

	return table.freeze(values)
end

local function releaseDue(list, now: number)
	local v = {}

	for _, v2 in list do
		if not v2.ReturnAt or now < v2.ReturnAt then
			table.insert(v, v2)
		end
	end

	if #v == #list then
		return list
	end

	return (table.freeze(v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getIfScheduled(state)
	for _, item in state do
		if item.ReturnAt then
			return true
		end
	end

	return false
end

return function(items, flag: boolean, callback, flag2: boolean?)
	local state, setState = React.useState(frozen)
	local state2, setState2 = React.useState(frozen3)
	local state3, setState3 = React.useState(false)
	local isSolved = state3 or flag2 == true
	local v2 = React.useMemo(function()
		return solveTiers(items)
	end, { items })
	local isActive = flag and not isSolved

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reset()
		setState(frozen)
		setState2(scheduleReturn)
	end

	local function selectIsland(p)
		if not isActive then
			return
		end

		local v4

		if p then
			v4 = v2.IndexByKey[p.Index.Key]
		end

		if p and #state > 0 and v4 == #state then
			local clone = table.clone(state)
			clone[#state] = p
			setState(table.freeze(clone))
		elseif p and v4 == #state + 1 then
			if #state + 1 >= #v2.Groups then
				setState3(true)
				setState(frozen)

				if callback then
					callback()
				end
			else
				local group = v2.Groups[#state]
				local clone = table.clone(state)
				table.insert(clone, p)
				setState(table.freeze(clone))

				if group then
					setState2(function(p2)
						return hide(p2, group)
					end)
				end
			end
		elseif #state > 0 then
			reset() -- equivalent call inferred; original call site unknown
		end
	end

	React.useEffect(function()
		if #state > 0 then
			reset() -- equivalent call inferred; original call site unknown
		end
	end, { isActive, v2 })
	React.useEffect(function()
		-- equivalent call inferred; original call site unknown
		if not getIfScheduled(state2) then
			return function() end
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local now = os.clock()
			setState2(function(p)
				return (releaseDue(p, now))
			end)
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { state2 })
	local orbit = React.useMemo(function()
		if isSolved then
			return frozen2
		end

		if #state2 == 0 then
			return items
		end

		local v5 = {}

		for _, v6 in state2 do
			v5[v6.Key] = true
		end

		local v6 = {}

		for _, item in items do
			if not v5[item.Index.Key] then
				table.insert(v6, item)
			end
		end

		return table.freeze(v6)
	end, { items, state2, isSolved })
	local theme = React.useMemo(function()
		local v6 = state[#state]

		if v6 then
			return (getIslandTheme(v6))
		end

		return nil
	end, { state })
	return {
		Orbit = orbit,
		Order = v2.Groups,
		Chain = state,
		Theme = theme,
		IsActive = isActive,
		IsSolved = isSolved,
		Select = selectIsland
	}
end