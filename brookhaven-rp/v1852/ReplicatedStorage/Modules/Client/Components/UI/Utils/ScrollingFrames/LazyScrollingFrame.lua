local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local function estimateCanvasHeight(gridLayout, p: number, scrollingFrame)
	if p == 0 then
		return 0
	end

	local X = scrollingFrame.AbsoluteWindowSize.X
	local X2 = gridLayout.AbsoluteCellSize.X
	assert(gridLayout.CellPadding.X.Scale == 0)
	assert(gridLayout.CellPadding.Y.Scale == 0)
	local offset = gridLayout.CellPadding.X.Offset
	local v = math.ceil(p / math.max(1, (math.floor((X + offset) / (X2 + offset)))))
	return v * X2 + math.max(0, v - 1) * offset
end

return {
	new = function(data)
		local scope = data.scope
		local scrollingFrame = data.scrollingFrame
		local gridLayout = data.gridLayout
		local fullData = data.fullData
		local itemsPerBatch = data.itemsPerBatch or 30
		local scrollThreshold = data.scrollThreshold or 200
		local maid = Janitor.new()
		local value = scope:Value(itemsPerBatch)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function shouldLoadMore()
			local currentFullData = Fusion.peek(fullData)

			if Fusion.peek(value) >= #currentFullData then
				return false
			end

			local Y = scrollingFrame.AbsoluteSize.Y
			local Y2 = gridLayout.AbsoluteContentSize.Y
			local v = Y + scrollingFrame.CanvasPosition.Y
			return Y2 - scrollThreshold <= v
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function loadMore()
			local currentFullData = Fusion.peek(fullData)
			local v = Fusion.peek(value)

			if #currentFullData <= v then
				return
			end

			value:set((math.min(v + itemsPerBatch, #currentFullData)))
		end

		local v = 0
		local v2 = false
		local visibleData = scope:Computed(function(use, _)
			local currentFullData = use(fullData)
			local count = #currentFullData
			local v3 = math.min(use(value), count)
			local result = table.create(v3)

			for i = 1, v3 do
				result[i] = currentFullData[i]
			end

			if count ~= v and not v2 then
				v2 = true
				task.defer(function()
					v2 = false
					local count2 = #Fusion.peek(fullData)

					if count2 < Fusion.peek(value) then
						value:set((math.max(count2, 0)))
					end

					v = count2

					while true do
						-- equivalent call inferred; original call site unknown
						if not shouldLoadMore() then
							break
						end

						loadMore() -- equivalent call inferred; original call site unknown
					end
				end)
			end

			return result
		end)
		v = #Fusion.peek(fullData)
		scope:Hydrate(scrollingFrame)({
			CanvasSize = scope:Computed(function(use, _)
				local v3 = estimateCanvasHeight(gridLayout, #use(fullData), scrollingFrame)
				return UDim2.new(0, 0, 0, v3)
			end)
		})
		maid:Add(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			while true do
				-- equivalent call inferred; original call site unknown
				if not shouldLoadMore() then
					break
				end

				loadMore() -- equivalent call inferred; original call site unknown
			end
		end))
		local flag = false
		maid:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if flag then
				return
			end

			flag = true
			task.delay(0.05, function()
				flag = false

				while true do
					-- equivalent call inferred; original call site unknown
					if not shouldLoadMore() then
						scrollingFrame.CanvasSize = UDim2.new(
							0,
							0,
							0,
							(estimateCanvasHeight(gridLayout, #Fusion.peek(fullData), scrollingFrame))
						)
						break
					end

					loadMore() -- equivalent call inferred; original call site unknown
				end
			end)
		end))
		maid:Add(gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			while true do
				-- equivalent call inferred; original call site unknown
				if not shouldLoadMore() then
					break
				end

				loadMore() -- equivalent call inferred; original call site unknown
			end
		end))
		task.defer(function()
			while true do
				-- equivalent call inferred; original call site unknown
				if not shouldLoadMore() then
					break
				end

				loadMore() -- equivalent call inferred; original call site unknown
			end
		end)
		return {
			visibleData = visibleData,
			janitor = maid
		}
	end
}