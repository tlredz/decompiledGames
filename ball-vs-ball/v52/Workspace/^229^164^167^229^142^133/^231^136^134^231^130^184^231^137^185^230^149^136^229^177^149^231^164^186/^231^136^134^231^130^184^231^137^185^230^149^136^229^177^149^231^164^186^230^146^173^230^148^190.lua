local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BattleSettlementEffects = require(ReplicatedStorage.Engine.Service.BattleSettlementEffects)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local soundGroup = Instance.new("SoundGroup")
soundGroup.Name = "爆炸特效展示静音"
soundGroup.Volume = 0
soundGroup.Parent = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local v = parent:WaitForChild("球模型")
local imageLabel = parent:WaitForChild("电视模型"):WaitForChild("特效图标"):WaitForChild("MainFrame"):WaitForChild("ImageLabel")

-- equivalent calls inferred from this helper; original call sites unknown
local function pickFriendUserId()
	local success, result = pcall(function()
		return Players:GetFriendsAsync(localPlayer.UserId)
	end)

	if not (success and result) then
		return nil
	end

	local v2 = result:GetCurrentPage()[1]

	if v2 then
		return v2.Id
	end

	return nil
end

local function buildHumanModel(instance)
	local pivot = instance:GetPivot()
	local friendUserId = pickFriendUserId() -- equivalent call inferred; original call site unknown
	local success, result

	if friendUserId then
		success, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserIdAsync(friendUserId)
		end)
	else
		success = false
		result = nil
	end

	local result2

	if friendUserId then
		if success then
			local success2
			success2, result2 = pcall(function()
				return Players:CreateHumanoidModelFromDescriptionAsync(result, Enum.HumanoidRigType.R15)
			end)

			if not success2 then
				warn("[爆炸特效展示播放] 创建好友人模型失败，使用默认 Rig 继续播放特效")
				result2 = instance
			end
		else
			warn("[爆炸特效展示播放] 获取好友外观失败，使用默认 Rig 继续播放特效")
			result2 = instance
		end
	else
		result2 = instance
	end

	result2.Name = "人模型"
	local humanoid = result2:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.NameDisplayDistance = 0
		humanoid.HealthDisplayDistance = 0
	end

	for _, part in ipairs(result2:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	result2.Parent = parent
	result2:PivotTo(pivot)
	local humanoidRootPart = result2:FindFirstChild("HumanoidRootPart")
	humanoidRootPart.Anchored = true

	if result2 ~= instance then
		instance:Destroy()
	end

	return result2
end

local humanoidRootPart = buildHumanModel(parent:WaitForChild("人模型")):WaitForChild("HumanoidRootPart")
local cFrame = v.CFrame
local v2 = {}

for _, v3 in GachaPool.getAllEntries() do
	if v3.itemType == "爆炸特效" and v3.weight > 0 then
		v2[v3.targetId] = true
	end
end

local cnIds = {}

for _, v3 in ipairs(Config.skin.bySkinType["爆炸特效"] or {}) do
	if v3.rating >= 3 and v2[v3.cnId] then
		table.insert(cnIds, v3.cnId)
	end
end

if #cnIds == 0 then
	warn("[爆炸特效展示播放] 没有 rating>=3 且可从 gacha 抽到的爆炸特效皮肤，跳过展示循环")
	return
end

local function shuffled(cnIds2)
	local clone = table.clone(cnIds2)

	for i = #clone, 2, -1 do
		local v3 = math.random(1, i)
		local v4 = clone[v3]
		local v5 = clone[i]
		clone[i] = v4
		clone[v3] = v5
	end

	return clone
end

local function refillQueue(p: string?)
	local v3 = shuffled(cnIds)

	if not p or not (#v3 > 1) or v3[1] ~= p then
		return v3
	end

	local v4 = v3[2]
	local v5 = v3[1]
	v3[1] = v4
	v3[2] = v5
	return v3
end

local function playCnId(skinCnId: string, playNext)
	local v3 = Config.skin.byCnId[skinCnId]

	if v3 and v3.image then
		imageLabel.Image = v3.image
	else
		warn(string.format("[爆炸特效展示播放] 找不到皮肤配置或图片: %s", skinCnId))
	end

	BattleSettlementEffects.flyAndImpact(v, humanoidRootPart.Position, function(duration)
		v.Transparency = 1
		task.wait(duration)
		v.CFrame = cFrame
		v.Transparency = 0
		playNext()
	end, {
		startShake = true,
		muted = true,
		soundGroup = soundGroup,
		skinCnId = skinCnId
	})
end

task.spawn(function()
	local v3 = {}
	local v4 = nil
	local playNext

	playNext = function()
		if #v3 == 0 then
			local v5 = v4
			local v6 = shuffled(cnIds)

			if v5 and #v6 > 1 and v6[1] == v5 then
				local v7 = v6[2]
				local v8 = v6[1]
				v6[1] = v7
				v6[2] = v8
			end

			v3 = v6
		end

		local skinCnId = table.remove(v3, 1)
		v4 = skinCnId
		playCnId(skinCnId, playNext)
	end

	if #v3 == 0 then
		local v5 = v4
		local v6 = shuffled(cnIds)

		if v5 and #v6 > 1 and v6[1] == v5 then
			local v7 = v6[2]
			local v8 = v6[1]
			v6[1] = v7
			v6[2] = v8
		end

		v3 = v6
	end

	local skinCnId2 = table.remove(v3, 1)
	v4 = skinCnId2
	playCnId(skinCnId2, playNext)
end)