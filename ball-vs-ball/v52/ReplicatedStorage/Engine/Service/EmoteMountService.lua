local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local PlayerData = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerData"))
local EmoteMountService = {
	server = {},
	client = {}
}
local remoteEvent = Net:RemoteEvent("EmoteMountService/Play")
local remoteEvent2 = Net:RemoteEvent("EmoteMountService/PlayWheelSlot")
local v = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("飞行器")
local v2 = {}
local v3 = {}
local v4 = {}

local function getRelativePath(model, parent)
	local result = {}

	while parent and parent ~= model do
		table.insert(result, 1, parent.Name)
		parent = parent.Parent
	end

	return result
end

local function resolvePath(child, vehiclePartPath)
	for _, childName in ipairs(vehiclePartPath) do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	return child
end

local function scanMountPlan(child)
	local rig = child:FindFirstChild("Rig")

	if not (rig and rig:IsA("Model")) then
		warn((`[EmoteMountService] {child.Name} 缺少 Rig，已跳过`))
		return nil
	end

	local model = rig:FindFirstChild("飞行器模型")

	if not (model and model:IsA("Model")) then
		warn((`[EmoteMountService] {child.Name} 缺少 飞行器模型，已跳过`))
		return nil
	end

	local animation = rig:FindFirstChild("动画")

	if not (animation and animation:IsA("Animation")) then
		warn((`[EmoteMountService] {child.Name} 缺少 动画，已跳过`))
		return nil
	end

	local numberValue = child:FindFirstChild("离地高度")

	if not (numberValue and numberValue:IsA("NumberValue")) then
		warn((`[EmoteMountService] {child.Name} 缺少 离地高度 NumberValue，已跳过`))
		return nil
	end

	local joints = {}

	for _, descendant in ipairs(rig:GetDescendants()) do
		if not (descendant:IsA("Motor6D") or descendant:IsA("Weld") or descendant:IsA("WeldConstraint")) or descendant:IsDescendantOf(model) then
			continue
		end

		local part0 = descendant.Part0
		local part1 = descendant.Part1
		local v6

		if part0 == nil then
			v6 = false
		else
			v6 = part0:IsDescendantOf(model)
		end

		local vehiclePartIsPart

		if part1 == nil then
			vehiclePartIsPart = false
		else
			vehiclePartIsPart = part1:IsDescendantOf(model)
		end

		if v6 and vehiclePartIsPart then
			warn((`[EmoteMountService] {child.Name} 关节 {descendant:GetFullName()} 两端都在飞行器模型内，已跳过`))
		elseif v6 or vehiclePartIsPart then
			local v8

			if vehiclePartIsPart then
				v8 = part0
			else
				v8 = part1
			end

			if vehiclePartIsPart then
				part0 = part1
			end

			local parent = descendant.Parent

			if v8 and part0 and parent and parent:IsA("BasePart") then
				table.insert(joints, {
					jointClass = descendant.ClassName,
					bodyPartName = parent.Name,
					vehiclePartPath = getRelativePath(model, part0),
					vehiclePartIsPart1 = vehiclePartIsPart,
					c0 = descendant.C0,
					c1 = descendant.C1,
					relativeCFrame = v8.CFrame:ToObjectSpace(part0.CFrame)
				})
			else
				warn((`[EmoteMountService] {child.Name} 关节 {descendant:GetFullName()} 结构不符合预期，已跳过`))
			end
		end
	end

	if #joints ~= 0 then
		return {
			vehicleModel = model,
			animation = animation,
			joints = joints,
			groundHeight = numberValue
		}
	end

	warn((`[EmoteMountService] {child.Name} 未扫描到跨界挂点关节，已跳过`))
	return nil
end

local function buildMountPlanCache()
	for _, child in ipairs(v:GetChildren()) do
		local v5 = scanMountPlan(child)

		if v5 then
			v2[child.Name] = v5
		end
	end
end

local function getOrBuildMountPlan(childName: string)
	local v5 = v2[childName]

	if v5 then
		return v5
	end

	local child = v:FindFirstChild(childName)

	if not child then
		return nil
	end

	local v6 = scanMountPlan(child)

	if v6 then
		v2[childName] = v6
	end

	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopActiveEmote(data)
	data.track:Stop()
	data.track:Destroy()

	if data.mountFolder then
		data.mountFolder:Destroy()
	end

	if data.previousHipHeight ~= nil and data.humanoid.Parent then
		data.humanoid.HipHeight = data.previousHipHeight
	end
end

local function mountVehicle(instance, p)
	local folder = Instance.new("Folder")
	folder.Name = "飞行器挂载"
	local clone = p.vehicleModel:Clone()
	clone.Parent = folder

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.Massless = true
	end

	local flag = false

	for _, joint in ipairs(p.joints) do
		local part = instance:FindFirstChild(joint.bodyPartName)
		local path = resolvePath(clone, joint.vehiclePartPath)

		if part and part:IsA("BasePart") and path and path:IsA("BasePart") then
			if joint.jointClass == "WeldConstraint" then
				path.CFrame = part.CFrame * joint.relativeCFrame
			end

			local instance2 = Instance.new(joint.jointClass)

			if joint.vehiclePartIsPart1 then
				instance2.Part0 = part
				instance2.Part1 = path
			else
				instance2.Part0 = path
				instance2.Part1 = part
			end

			if joint.jointClass ~= "WeldConstraint" then
				instance2.C0 = joint.c0
				instance2.C1 = joint.c1
			end

			instance2.Parent = part
			flag = true
		else
			warn((`[EmoteMountService] 挂点 {joint.bodyPartName} 在角色身上匹配失败，已跳过`))
		end
	end

	if flag then
		return folder
	end

	folder:Destroy()
	return nil
end

local function playerOwnsFlyerAsset(player, p: string)
	for _, v5 in PlayerData.server[player].items() do
		if v5.itemType ~= "飞行器" then
			continue
		end

		local v6 = Config.skin.byCnId[v5.itemId]

		if v6 and v6.assetName == p then
			return true
		end
	end

	return false
end

function EmoteMountService.server.play(player, assetName: string)
	local v5 = v2[assetName]

	if not (v5 and playerOwnsFlyerAsset(player, assetName)) then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local v6 = v3[player]

	if v6 then
		stopActiveEmote(v6) -- equivalent call inferred; original call site unknown
		v3[player] = nil

		if v6.contentKey == "flyer:" .. assetName then
			return
		end
	end

	local mountFolder = mountVehicle(character, v5)

	if not mountFolder then
		return
	end

	mountFolder.Parent = character
	local hipHeight = humanoid.HipHeight
	humanoid.HipHeight = v5.groundHeight.Value
	local v8 = humanoid:FindFirstChildOfClass("Animator")

	if not v8 then
		v8 = Instance.new("Animator")
		v8.Parent = humanoid
	end

	local track = v8:LoadAnimation(v5.animation)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = true
	track:Play()
	v3[player] = {
		contentKey = "flyer:" .. assetName,
		assetName = assetName,
		track = track,
		mountFolder = mountFolder,
		humanoid = humanoid,
		previousHipHeight = hipHeight
	}
end

local function playFreeEmote(player, p)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local contentKey = "freeEmote:" .. p.cnId
	local v6 = v3[player]

	if v6 then
		stopActiveEmote(v6) -- equivalent call inferred; original call site unknown
		v3[player] = nil

		if v6.contentKey == contentKey then
			return
		end
	end

	local v7 = humanoid:FindFirstChildOfClass("Animator")

	if not v7 then
		v7 = Instance.new("Animator")
		v7.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = p.animation
	local success, result = pcall(function()
		return v7:LoadAnimation(animation)
	end)
	animation:Destroy()

	if not success then
		warn("[EmoteMountService] 免费动作加载失败: " .. tostring(result))
		return
	end

	result.Priority = Enum.AnimationPriority.Action
	result.Looped = true
	result:Play()
	v3[player] = {
		contentKey = contentKey,
		assetName = nil,
		track = result,
		mountFolder = nil,
		humanoid = humanoid,
		previousHipHeight = nil
	}
end

function EmoteMountService.server.playWheelSlot(p, value: number)
	if typeof(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 8 then
		return
	end

	local equipment = PlayerData.server[p].equipment()
	local v5

	if typeof(equipment) == "table" then
		v5 = equipment["表情轮盘_" .. tostring(value)]
	else
		v5 = false
	end

	if typeof(v5) ~= "table" or typeof(v5.kind) ~= "string" or typeof(v5.id) ~= "string" then
		return
	end

	if v5.kind == "freeEmote" then
		local v6 = Config.freeEmote.byCnId[v5.id]

		if v6 then
			playFreeEmote(p, v6)
		end
	elseif v5.kind == "flyer" then
		local v6 = PlayerData.server[p].items[v5.id]()
		local v7 = typeof(v6) == "table" and v6.itemType == "飞行器" and next(v6.locks or {}) == nil and Config.skin.byCnId[v6.itemId]

		if v7 then
			EmoteMountService.server.play(p, v7.assetName)
		end
	end
end

function EmoteMountService.server.getRigHipHeight(p: string)
	local v5 = v2[p]
	return v5 and v5.groundHeight.Value
end

function EmoteMountService.server.cancel(p)
	local v5 = v3[p]

	if not v5 then
		return
	end

	stopActiveEmote(v5) -- equivalent call inferred; original call site unknown
	v3[p] = nil
end

function EmoteMountService.server.setLocked(p, flag: boolean)
	v4[p] = flag or nil

	if flag then
		EmoteMountService.server.cancel(p)
	end
end

function EmoteMountService.server.init()
	buildMountPlanCache()
	remoteEvent.OnServerEvent:Connect(function(p, value)
		if typeof(value) ~= "string" or v4[p] then
			return
		end

		EmoteMountService.server.play(p, value)
	end)
	remoteEvent2.OnServerEvent:Connect(function(p, p2)
		if v4[p] then
			return
		end

		EmoteMountService.server.playWheelSlot(p, p2)
	end)
	Players.PlayerRemoving:Connect(function(player)
		v3[player] = nil
		v4[player] = nil
	end)
end

function EmoteMountService.client.play(p: string)
	remoteEvent:FireServer(p)
end

function EmoteMountService.client.playWheelSlot(p: number)
	remoteEvent2:FireServer(p)
end

function EmoteMountService.client.mountLocal(parent, childName: string)
	local v5 = v2[childName]

	if not v5 then
		local child = v:FindFirstChild(childName)

		if child then
			v5 = scanMountPlan(child)

			if v5 then
				v2[childName] = v5
			end
		else
			v5 = nil
		end
	end

	if not v5 then
		return nil, nil
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil, nil
	end

	local v6 = mountVehicle(parent, v5)

	if not v6 then
		return nil, nil
	end

	v6.Parent = parent
	humanoid.HipHeight = v5.groundHeight.Value
	local v7 = humanoid:FindFirstChildOfClass("Animator")

	if not v7 then
		v7 = Instance.new("Animator")
		v7.Parent = humanoid
	end

	local track = v7:LoadAnimation(v5.animation)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = true
	track:Play()
	return v6, track
end

function EmoteMountService.client.unmountLocal(instance, instance2)
	if instance2 then
		instance2:Stop()
		instance2:Destroy()
	end

	if instance then
		instance:Destroy()
	end
end

return EmoteMountService