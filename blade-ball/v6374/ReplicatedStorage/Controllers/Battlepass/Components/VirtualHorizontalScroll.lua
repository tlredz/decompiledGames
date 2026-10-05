local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local spring = require3("@game/ReplicatedStorage/Common/Utils").Spring
local v = require3("@game/ReplicatedStorage/Packages/Charm")
require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")

local function createInfiniteScroll(data)
	local container = data.container
	local template = data.template
	local itemWidthScale = data.itemWidthScale or 0.15
	local buffer = data.buffer or 2
	local maxTiers = data.maxTiers
	template.Visible = false
	local clones = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local atom = v.atom(0)
	local atom2 = v.atom(container.AbsoluteSize.X)
	local computed = v.computed(function()
		local v5 = atom2()
		local itemWidth = v5 * itemWidthScale
		return {
			itemWidth = itemWidth,
			poolSize = math.ceil(v5 / math.max(itemWidth, 1)) + 1 + buffer * 2,
			firstVisible = math.floor(atom() / math.max(itemWidth, 1))
		}
	end)

	local function clearCleanup(p)
		local callback = v2[p]

		if callback then
			callback()
			v2[p] = nil
		end
	end

	local function getFrameForIndex(i: number)
		if v3[i] then
			return v3[i]
		end

		for _, v5 in clones do
			if v4[v5] ~= nil then
				continue
			end

			v3[i] = v5
			v4[v5] = i
			return v5
		end

		local clone = template:Clone()
		clone.Parent = container
		table.insert(clones, clone)
		v3[i] = clone
		v4[clone] = i
		return clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function releaseFrame(p: number)
		local v5 = v3[p]

		if v5 then
			local callback = v2[v5]

			if callback then
				callback()
				v2[v5] = nil
			end

			v5.Visible = false
			v3[p] = nil
			v4[v5] = nil
		end
	end

	local function updateVisibleRange()
		local v5 = computed()
		local v6 = math.max(1, v5.firstVisible - buffer)
		local v7 = v5.firstVisible + v5.poolSize

		if maxTiers then
			v7 = math.min(v7, maxTiers)
		end

		local v8 = {}

		for k in v3 do
			if k < v6 or v7 < k then
				table.insert(v8, k)
			end
		end

		for _, v9 in v8 do
			releaseFrame(v9) -- equivalent call inferred; original call site unknown
		end

		for i = v6, v7 do
			local tierData = data.getTierData(i)

			if not tierData then
				continue
			end

			local flag = not v3[i]
			local frameForIndex = getFrameForIndex(i)
			local v9 = (i - 1) * v5.itemWidth
			frameForIndex.Position = UDim2.new(0, v9, 0, 0)
			frameForIndex.Size = UDim2.new(0, v5.itemWidth - 8, 1, 0)
			frameForIndex.Visible = true

			if not flag then
				continue
			end

			local v10 = data.render(i, tierData, frameForIndex)

			if v10 then
				v2[frameForIndex] = v10
			end
		end
	end

	template.Visible = false
	local effect = v.effect(function()
		computed()
		updateVisibleRange()
	end)
	local effect2 = v.effect(function()
		local v5 = computed()
		local v6 = (v5.firstVisible + v5.poolSize + 10) * v5.itemWidth

		if maxTiers then
			v6 = math.min(v6, maxTiers * v5.itemWidth)
		end

		if container.CanvasSize.X.Offset < v6 then
			container.CanvasSize = UDim2.new(0, v6, 0, 0)
		end
	end)
	local canvasPositionChangedConnection = container:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		atom(container.CanvasPosition.X)
	end)
	local absoluteSizeChangedConnection = container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		atom2(container.AbsoluteSize.X)
	end)
	return {
		scrollTo = function(p: number, flag: boolean?)
			local v5 = computed()
			local v6 = (p - 1) * v5.itemWidth

			if maxTiers then
				v6 = math.min(v6, (maxTiers - 1) * v5.itemWidth)
			end

			if flag then
				spring.target(container, 0.85, 2.5, {
					CanvasPosition = Vector2.new(v6, 0)
				})
			else
				container.CanvasPosition = Vector2.new(v6, 0)
			end
		end,
		scrollToCurrent = function(flag: boolean?)
			local currentTier = data.currentTier()
			local v5 = computed()
			local v6 = (currentTier - 1) * v5.itemWidth

			if flag then
				spring.target(container, 0.85, 2.5, {
					CanvasPosition = Vector2.new(v6, 0)
				})
			else
				container.CanvasPosition = Vector2.new(v6, 0)
			end
		end,
		getCurrentVisibleTier = function()
			return computed().firstVisible + 1
		end,
		destroy = function()
			assert(clones, "You're trying to use a destroyed VirtualHorizontalScroll!")
			effect()
			effect2()
			canvasPositionChangedConnection:Disconnect()
			absoluteSizeChangedConnection:Disconnect()

			for _, v5 in clones do
				local callback = v2[v5]

				if callback then
					callback()
					v2[v5] = nil
				end

				v5:Destroy()
			end

			clones = {}
			v3 = {}
			v4 = {}
		end
	}
end

return createInfiniteScroll