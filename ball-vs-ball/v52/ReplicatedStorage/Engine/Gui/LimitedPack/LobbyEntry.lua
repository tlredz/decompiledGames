local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local service = ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service")
local Config = require(service:WaitForChild("Config"))
local TimeService = require(service:WaitForChild("TimeService"))
local LimitedPackService = require(service:WaitForChild("LimitedPackService"))
local BattleSettlementEffects = require(service:WaitForChild("BattleSettlementEffects"))
local EmoteMountService = require(service:WaitForChild("EmoteMountService"))
local ServerTypeService = require(service:WaitForChild("ServerTypeService"))
local ServerTeleport = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServerTeleport"))
local localPlayer = Players.LocalPlayer
local flag = false
local soundGroup2 = nil

local function getMutedSoundGroup()
	if soundGroup2 then
		return soundGroup2
	end

	local soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "限定礼包展台静音"
	soundGroup.Volume = 0
	soundGroup.Parent = game:GetService("SoundService")
	soundGroup2 = soundGroup
	return soundGroup2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findActiveGroup(p: string)
	for _, v2 in LimitedPackService.getActiveGroups() do
		if v2.group == p then
			return v2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pickClosestFriendId()
	local success, result = pcall(function()
		return Players:GetFriendsAsync(localPlayer.UserId)
	end)

	if success and result then
		local v2 = result:GetCurrentPage()[1]
		return v2 and v2.Id
	else
		return nil
	end
end

local function createAvatar(item: number)
	local success, result = pcall(function()
		return Players:GetHumanoidDescriptionFromUserIdAsync(item)
	end)

	if not success then
		return nil
	end

	local success2, result2 = pcall(function()
		return Players:CreateHumanoidModelFromDescriptionAsync(result, Enum.HumanoidRigType.R15)
	end)
	result:Destroy()

	if success2 then
		return result2
	end

	return nil
end

local function replaceWithAvatar(instance, items, isAlive)
	local folder = nil

	for _, item in items do
		folder = createAvatar(item)

		if folder then
			break
		end
	end

	if not folder then
		return nil
	end

	if not isAlive() then
		folder:Destroy()
		return nil
	end

	local humanoid = folder:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart and humanoidRootPart2) then
		folder:Destroy()
		return nil
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BaseScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end

	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.NameDisplayDistance = 0
	humanoid.HealthDisplayDistance = 0
	folder.Name = instance.Name
	folder:ScaleTo(instance:GetScale())
	folder:PivotTo(humanoidRootPart2.CFrame * humanoidRootPart.CFrame:ToObjectSpace(folder:GetPivot()))
	humanoidRootPart.Anchored = true
	folder.Parent = instance.Parent
	instance:Destroy()
	return folder
end

local function setupEntry(clone, p: string, callback)
	local flag2 = true

	local function isAlive()
		return flag2
	end

	local v2 = nil
	clone.Destroying:Connect(function()
		flag2 = false

		if v2 then
			v2.destroy()
			v2 = nil
		end
	end)
	local textLabel = clone:WaitForChild("倒计时"):WaitForChild("BillboardGui"):WaitForChild("Frame"):WaitForChild("TextLabel")
	local proximityPrompt = clone:WaitForChild("交互点"):WaitForChild("ProximityPrompt")
	local folder = clone:WaitForChild("小球")
	local v3 = clone:WaitForChild("好友模型")
	local rig = clone:WaitForChild("飞行器"):WaitForChild("Rig")
	local activeGroup = findActiveGroup(p) -- equivalent call inferred; original call site unknown
	local v4 = not activeGroup and {} or LimitedPackService.getGroupContents(activeGroup)
	task.spawn(function()
		while flag2 do
			local activeGroup2 = findActiveGroup(p) -- equivalent call inferred; original call site unknown

			if activeGroup2 then
				textLabel.Text = "Ends in " .. TimeService.formatCountdown(LimitedPackService.getGroupRemainingSeconds(activeGroup2))
				task.wait(1)
			else
				clone:Destroy()
				break
			end
		end
	end)
	proximityPrompt.Triggered:Connect(function(player)
		if player == localPlayer then
			callback(p)
		end
	end)
	local humanoidRootPart = v3:WaitForChild("HumanoidRootPart")
	task.spawn(function()
		local closestFriendId = pickClosestFriendId() -- equivalent call inferred; original call site unknown

		if not closestFriendId then
			return
		end

		local v6 = replaceWithAvatar(v3, { closestFriendId }, isAlive)

		if v6 then
			humanoidRootPart = v6:FindFirstChild("HumanoidRootPart")
		elseif flag2 then
			warn((`[LimitedPack.LobbyEntry] {p} 好友外观生成失败，保留占位好友模型`))
		end
	end)
	task.spawn(function()
		local v5 = replaceWithAvatar(rig, { localPlayer.UserId }, isAlive)

		if not flag2 then
			return
		end

		if v5 then
			if not v4.flyer then
				warn((`[LimitedPack.LobbyEntry] {p} 全套奖励里没有飞行器，不挂载`))
			elseif not EmoteMountService.client.mountLocal(v5, v4.flyer) then
				warn((`[LimitedPack.LobbyEntry] {p} 飞行器 {v4.flyer} 挂载失败`))
			end
		else
			warn((`[LimitedPack.LobbyEntry] {p} 本地玩家外观生成失败，保留占位飞行器 Rig`))
			local humanoid = rig:FindFirstChildOfClass("Humanoid")
			local firstChild = rig:FindFirstChild("动画")

			if humanoid and firstChild then
				local track = (humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)):LoadAnimation(firstChild)
				track.Looped = true
				track:Play()
			end
		end
	end)

	if not v4.explosion then
		warn((`[LimitedPack.LobbyEntry] {p} 全套奖励里没有爆炸特效，使用默认特效`))
	end

	local pivot = folder:GetPivot()
	local transparenciesByPart = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			transparenciesByPart[part] = part.Transparency
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setBallVisible(flag3: boolean)
		for k, v5 in transparenciesByPart do
			k.Transparency = not flag3 and 1 or v5
		end
	end

	task.spawn(function()
		while flag2 do
			task.wait(3)

			if not flag2 then
				break
			end

			local thread = coroutine.running()
			local flyAndImpact = BattleSettlementEffects.flyAndImpact
			local position = humanoidRootPart.Position

			local function fn(duration)
				setBallVisible(false) -- equivalent call inferred; original call site unknown
				task.wait(duration)

				if flag2 then
					folder:PivotTo(pivot)
					setBallVisible(true) -- equivalent call inferred; original call site unknown
				end

				task.spawn(thread)
			end

			if not soundGroup2 then
				local soundGroup = Instance.new("SoundGroup")
				soundGroup.Name = "限定礼包展台静音"
				soundGroup.Volume = 0
				soundGroup.Parent = game:GetService("SoundService")
				soundGroup2 = soundGroup
			end

			v2 = flyAndImpact(folder, position, fn, {
				startShake = true,
				muted = true,
				soundGroup = soundGroup2,
				skinCnId = v4.explosion
			})
			coroutine.yield()
			v2 = nil
		end
	end)
end

return {
	Start = function(callback)
		if flag then
			return
		end

		flag = true

		if ServerTeleport.getServerType() == ServerTypeService.TRADE_POOL_NAME then
			return
		end

		task.spawn(function()
			local parent = workspace:WaitForChild("大厅"):WaitForChild("捆绑包")
			local v3 = {}

			for _, v4 in Config.limitedPack and Config.limitedPack.list or {} do
				local group = v4.group

				if typeof(group) ~= "string" or group == "" or v3[group] then
					continue
				end

				v3[group] = true
				local group2 = group
				task.spawn(function()
					local clone = parent:WaitForChild(group2)
					local clone2 = clone:Clone()
					clone2.Parent = nil
					local v6 = false

					while parent:IsDescendantOf(workspace) do
						-- equivalent call inferred; original call site unknown
						if findActiveGroup(group2) then
							if not clone or clone.Parent ~= parent then
								clone = clone2:Clone()
								clone.Parent = parent
								v6 = false
							end

							if not v6 then
								setupEntry(clone, group2, callback)
								v6 = true
							end
						elseif clone then
							clone:Destroy()
							clone = nil
							v6 = false
						end

						task.wait(1)
					end

					if clone then
						clone:Destroy()
					end

					clone2:Destroy()
				end)
			end
		end)
	end
}