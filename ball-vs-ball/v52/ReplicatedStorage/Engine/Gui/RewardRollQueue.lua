local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local WheelController = require(script.Parent.WheelController)
local ClaimQueue = require(script.Parent.ClaimQueue)
local UnifiedPanel = require(ReplicatedStorage.Engine.Service.GamepadSupport.UnifiedPanel)
local v = ReplicatedStorage:WaitForChild("音效素材")
local tickSFXV4 = v:WaitForChild("TickSFX V4")
local orchestraHit = v:WaitForChild("Orchestra Hit")
local RewardRollQueue = {}
local flag = false
local parent = nil
local parent2 = nil
local v4 = nil
local text = nil
local v5 = {}
local v6 = nil
local v7 = {}
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function findRatingColor(rating: number)
	for _, v8 in Config.rating.list do
		if v8.lvl == rating then
			return v8.colorHex
		end
	end

	return "FFFFFF"
end

local function resolveTargetDisplay(itemType: string?, p: string)
	if itemType == "爆炸特效" or itemType == "飞行器" then
		local v8 = Config.skin.byCnId[p]

		if v8 then
			return {
				image = v8.image,
				name = v8.name,
				rating = v8.rating
			}
		end

		return nil
	else
		local v8 = Config.ball.byCnId[p]

		if v8 then
			return {
				image = v8.image,
				name = v8.displayName,
				rating = v8.rating
			}
		end

		return nil
	end
end

local function enqueueClaim(data)
	local v8 = data.cnId and resolveTargetDisplay(data.itemType, data.cnId)

	if not v8 then
		return
	end

	local enqueue = ClaimQueue.enqueue
	local v9 = {
		image = v8.image,
		name = v8.name,
		colorHex = 0,
		serial = 0,
		killCount = 0
	}
	local ratingColor = findRatingColor(v8.rating) -- equivalent call inferred; original call site unknown
	v9.colorHex = ratingColor
	v9.serial = data.serial
	v9.killCount = data.killCount
	enqueue(v9)
end

local function buildWheelAssets(gachaCnId: string)
	local result = {}
	local weightsByTargetId = {}
	local v8 = Config.crate.byCnId[gachaCnId]
	local getChances = GachaPool.getChances

	if v8 then
		gachaCnId = v8.gachaCnId
	end

	local chances = getChances(gachaCnId)

	for _, chance in chances do
		local row = chance.row
		local v9

		if chance.weight > 0 then
			v9 = resolveTargetDisplay(row.itemType, row.targetId)
		else
			v9 = false
		end

		if not v9 then
			continue
		end

		local targetId = row.targetId
		local v10 = {
			image = v9.image,
			name = v9.name,
			strokeColorHex = 0
		}
		local ratingColor = findRatingColor(v9.rating) -- equivalent call inferred; original call site unknown
		v10.strokeColorHex = ratingColor
		result[targetId] = v10
		weightsByTargetId[row.targetId] = chance.weight
	end

	return result, weightsByTargetId
end

local function skipMatching(p: string?)
	local v8 = v6
	local v9 = not v8 and {} or v8.groupIds or {}

	for i = #v5, 1, -1 do
		local v10 = v5[i]

		if not (p and v10.source == p or not p and v10.groupId and v9[v10.groupId]) then
			continue
		end

		table.remove(v5, i)

		for _, result in v10.results do
			enqueueClaim(result)
		end
	end

	if v8 and (not p or v8.source == p) then
		for _, v10 in table.clone(v7) do
			v10:Skip()
		end
	end
end

local function skipActiveWheels()
	if v6 and v6.skipAll then
		skipMatching(nil)
		return
	end

	for _, v8 in table.clone(v7) do
		v8:Skip()
	end
end

local fn

local function finishBatch(p)
	if v6 ~= p or p.remaining ~= 0 then
		return
	end

	parent.Visible = false
	v6 = nil
	fn()
end

local function playResult(state, data)
	if not (data.ok and data.cnId) then
		return
	end

	state.remaining += 1
	local clone = v4:Clone()
	clone.Name = "滚动条"
	clone.Visible = true
	clone.Parent = parent2
	local assets = state.assets
	local weights = state.weights

	if data.crateCnId and data.crateCnId ~= state.crateCnId then
		assets, weights = buildWheelAssets(data.crateCnId)
	end

	local v8 = WheelController.new({
		ScrollFrame = clone,
		AssetsMap = assets,
		Weights = weights
	})

	function v8.OnTicked()
		if not tickSFXV4.IsPlaying then
			tickSFXV4:Play()
		end
	end

	function v8.OnCompleted()
		if not orchestraHit.IsPlaying then
			orchestraHit:Play()
		end
	end

	table.insert(v7, v8)
	task.spawn(function()
		v8:Start(data.cnId, function()
			local index = table.find(v7, v8)

			if index then
				table.remove(v7, index)
			end

			clone:Destroy()
			enqueueClaim(data)
			state.remaining -= 1
			local v10 = state

			if v6 == v10 then
				if v10.remaining ~= 0 then
					return
				end

				parent.Visible = false
				v6 = nil
				fn()
			end
		end)
	end)
end

fn = function()
	if v6 or #v5 == 0 then
		return
	end

	local v8 = table.remove(v5, 1)
	local wheelAssets, weights = buildWheelAssets(v8.crateCnId)
	local v10 = {
		results = v8.results,
		skipAll = v8.skipAll,
		crateCnId = v8.crateCnId,
		source = v8.source,
		assets = wheelAssets,
		weights = weights,
		remaining = 0,
		groupIds = 0
	}
	local groupIds

	if v8.groupId then
		groupIds = {}
		groupIds[v8.groupId] = true
	else
		groupIds = {}
	end

	v10.groupIds = groupIds
	v6 = v10
	text.Text = v10.skipAll and "Skip All" or "Skip"
	parent.Visible = true

	for _, result in v10.results do
		playResult(v10, result)
	end

	if v6 == v10 then
		if v10.remaining ~= 0 then
			return
		end

		parent.Visible = false
		v6 = nil
		fn()
	end
end

local function samePool(p: string, p2: string)
	local v8 = Config.crate.byCnId[p]
	local v9 = Config.crate.byCnId[p2]

	if p == p2 then
		return true
	elseif v8 == nil or v9 == nil then
		return false
	else
		return v8.gachaCnId == v9.gachaCnId
	end
end

function RewardRollQueue.enqueue(list, crateCnId2: string, source: string)
	if not flag or typeof(crateCnId2) ~= "string" then
		warn("[RewardRollQueue] 转盘未初始化或箱子配置无效")
		return
	end

	local v8 = {}

	for _, v9 in list do
		if v9.ok and v9.cnId then
			table.insert(v8, v9)
		end
	end

	if #v8 == 0 then
		return
	end

	count += 1
	local groupId = count
	local skipAll

	if source == "store" then
		skipAll = #list == 100
	else
		skipAll = false
	end

	local v11 = source == "store" and 5 or #v8

	for i = 1, #v8, v11 do
		local results = {}

		for i2 = i, math.min(i + v11 - 1, #v8) do
			table.insert(results, v8[i2])
		end

		if i == 1 and source == "store" and v6 and v6.source == source then
			local crateCnId = v6.crateCnId
			local v13 = Config.crate.byCnId[crateCnId]
			local v14 = Config.crate.byCnId[crateCnId2]
			local v15

			if crateCnId == crateCnId2 then
				v15 = true
			elseif v13 == nil or v14 == nil then
				v15 = false
			else
				v15 = v13.gachaCnId == v14.gachaCnId
			end

			if v15 then
				v6.groupIds[groupId] = true
				v6.skipAll = v6.skipAll or skipAll
				text.Text = v6.skipAll and "Skip All" or "Skip"

				for _, v16 in results do
					playResult(v6, v16)
				end

				continue
			end
		end

		table.insert(v5, {
			results = results,
			crateCnId = crateCnId2,
			source = source,
			groupId = groupId,
			skipAll = skipAll
		})
	end

	fn()
end

function RewardRollQueue.skipCurrentSource(p: string)
	skipMatching(p)
end

function RewardRollQueue.Init()
	if flag then
		return
	end

	flag = true
	parent = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("抽奖转盘"):WaitForChild("背景")
	parent2 = parent:WaitForChild("卷轴列表")
	local directA = parent:WaitForChild("跳过按钮")
	text = directA:WaitForChild("text")
	text.Text = "Skip"
	v4 = parent:FindFirstChild("滚动条模板", true)
	assert(v4, "[RewardRollQueue] 抽奖转盘缺少「滚动条模板」")
	v4.Parent = parent
	v4.Visible = false
	parent.Visible = false
	UnifiedPanel.new(parent, {
		directA = directA,
		overClaims = true
	}):Bind(directA, skipActiveWheels)
end

return RewardRollQueue