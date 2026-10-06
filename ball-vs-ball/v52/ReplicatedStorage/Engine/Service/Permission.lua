local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Permission = {}
local v = {
	["管理员"] = true,
	["群主"] = true
}
local creatorId = game.CreatorId
local v2 = {}
local v3 = {}
local v4 = nil
local remoteFunction = Net:RemoteFunction("PermissionCanUseCMD")
local v5 = {}

local function logPermission(p, p2: string)
	local v6 = v5[p]

	if not v6 then
		v6 = {}
		v5[p] = v6
	end

	if v6[p2] then
		return
	end

	v6[p2] = true
	print((`[Permission][{RunService:IsServer() and "Server" or "Client"}] 玩家={p.Name} UserId={p.UserId} GroupId={creatorId} | {p2}`))
end

local function describeRoles(result)
	local v6 = {}

	for _, role in result.Roles do
		table.insert(v6, (`{role.Name}(Id={role.Id}, Rank={role.Rank})`))
	end

	return (`IsMember={result.IsMember} 公开角色=[{table.concat(v6, ", ")}]`)
end

local function getIsAdmin(p)
	if RunService:IsStudio() then
		return true
	end

	if game.CreatorType ~= Enum.CreatorType.Group then
		return false
	end

	local v6 = v2[p]

	if v6 ~= nil then
		return v6
	end

	local success, result = pcall(function()
		return GroupService:GetRolesInGroupAsync(p.UserId, creatorId)
	end)

	if not success then
		warn((`[Permission] 获取玩家 {p.Name} 的群组角色失败: {result}`))
		return false
	end

	logPermission(p, "管理员角色查询: " .. describeRoles(result))
	local v7 = false

	for _, role in result.Roles do
		if v[role.Name] ~= true then
			continue
		end

		v7 = true
		break
	end

	logPermission(p, `管理员判断={v7}，要求角色名称为管理员或群主`)
	v2[p] = v7
	return v7
end

Players.PlayerRemoving:Connect(function(player)
	v2[player] = nil
	v3[player] = nil
	v5[player] = nil
end)

function Permission.IsAdmin(p)
	return (getIsAdmin(p))
end

function Permission.IsClientAdmin()
	return (getIsAdmin(Players.LocalPlayer))
end

local function isTestPlace()
	if v4 ~= nil then
		return v4
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfoAsync(game.PlaceId, Enum.InfoType.Asset)
	end)

	if not success or type(result) ~= "table" or type(result.Name) ~= "string" then
		warn((`[Permission][Server] PlaceId={game.PlaceId} 获取测试服名称失败，拒绝 tester CMD 授权: {result}`))
		return false
	end

	v4 = string.find(string.lower(result.Name), "test", 1, true) ~= nil
	print((`[Permission][Server] PlaceId={game.PlaceId} 发布名称="{result.Name}" 名称包含test={v4}`))
	return v4
end

function Permission.CanUseCMD(instance)
	if not RunService:IsServer() or instance.Parent ~= Players then
		return false
	end

	logPermission(
		instance,
		`开始 CMD 检查: CreatorType={game.CreatorType} PlaceId={game.PlaceId} GameId={game.GameId} Studio={RunService:IsStudio()}`
	)

	if getIsAdmin(instance) then
		logPermission(instance, "CMD 允许：管理员、群主或 Studio 调试权限")
		return true
	end

	if game.CreatorType ~= Enum.CreatorType.Group then
		logPermission(instance, "CMD 拒绝：游戏不是群组所有")
		return false
	end

	local v6 = v3[instance]

	if v6 ~= nil then
		logPermission(instance, `CMD 缓存命中：允许={v6}`)
		return v6
	end

	if not isTestPlace() then
		logPermission(instance, `CMD 拒绝：测试服名称未匹配或查询失败；名称判断缓存={v4}`)
		return false
	end

	local success, result = pcall(function()
		return GroupService:GetRolesInGroupAsync(instance.UserId, creatorId)
	end)

	if not success or type(result) ~= "table" or type(result.Roles) ~= "table" then
		warn((`[Permission][Server] 玩家={instance.Name} UserId={instance.UserId} GroupId={creatorId} 获取 tester 角色失败，拒绝 CMD 授权: {result}`))
		return false
	end

	logPermission(instance, "tester 角色查询: " .. describeRoles(result))
	local v7 = false

	if result.IsMember then
		for _, role in result.Roles do
			if not (type(role.Name) == "string" and string.find(string.lower(role.Name), "test", 1, true)) then
				continue
			end

			v7 = true
			break
		end
	end

	logPermission(instance, `CMD tester 判断：允许={v7}，要求群组成员且公开角色名称包含 test；仍在线={instance.Parent == Players}`)

	if instance.Parent == Players then
		v3[instance] = v7
	end

	return v7 and instance.Parent == Players
end

function Permission.CanLocalPlayerUseCMD()
	if not RunService:IsClient() then
		return false
	end

	local success, result = pcall(function()
		return remoteFunction:InvokeServer()
	end)

	if success then
		if Players.LocalPlayer then
			logPermission(Players.LocalPlayer, `服务器返回 CMD 权限={result}`)
		end
	else
		warn((`[Permission][Client] CMD 权限查询失败: {result}`))
	end

	return success and result == true
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p)
		return Permission.CanUseCMD(p)
	end
end

return Permission