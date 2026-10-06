local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GameFlags = require(ReplicatedStorage:WaitForChild("GameFlags"))
local ServerTeleport = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServerTeleport"))
local ServerTypeService = {
	server = {},
	TRADE_POOL_NAME = "tradeServer",
	TWO_V_TWO_POOL_NAME = "twoVTwoServer"
}
local flag = false

local function hideReferences(instance)
	local _2v2 = instance:FindFirstChild("2v2服")
	local part = instance:FindFirstChild("双人对战地板参考")

	if part and part:IsA("BasePart") then
		part.Transparency = 1
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	if _2v2 then
		for _, part2 in _2v2:GetDescendants() do
			if not part2:IsA("BasePart") then
				continue
			end

			part2.Transparency = 1
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
		end
	end
end

local function buildTwoVTwoTables(instance)
	local parent = assert(instance:FindFirstChild("双人对战"), "双人对战文件夹不存在")
	local part = assert(instance:FindFirstChild("双人对战地板参考"), "大厅地板参考不存在")
	local v2 = assert(instance:FindFirstChild("2v2服"), "2v2服参考文件夹不存在")
	local part2 = assert(v2:FindFirstChild("地板参考"), "2v2服地板参考不存在")
	local v3 = assert(v2:FindFirstChild("桌子定位"), "桌子定位文件夹不存在")
	assert(part:IsA("BasePart") and part2:IsA("BasePart"), "地板参考必须是 Part")
	parent:SetAttribute("ready", nil)
	local model = assert(
		assert(assert(ReplicatedStorage:FindFirstChild("美术素材"), "美术素材文件夹不存在"):FindFirstChild("杂项"), "美术素材.杂项文件夹不存在"):FindFirstChild("2v2模式"),
		"美术素材.杂项.2v2模式模板不存在"
	)
	assert(model:IsA("Model"), "2v2模式桌子模板必须是 Model")
	assert(model:GetAttribute("GameMode") == "TwoVTwo", "2v2模式桌子模板必须设置 GameMode=TwoVTwo")
	local parts = {}

	for _, part3 in v3:GetChildren() do
		assert(part3:IsA("BasePart"), "桌子定位下只能放 Part")
		table.insert(parts, part3)
	end

	assert(#parts == 6, "2v2服必须有 6 个桌子定位 Part")
	table.sort(parts, function(a, b)
		return a.Name < b.Name
	end)
	local clones = {}

	for _, v4 in parts do
		local clone = model:Clone()
		clone.Name = "2v2模式"
		clone:SetAttribute("GameMode", "TwoVTwo")
		clone:SetAttribute("DuelTableId", nil)
		clone:PivotTo(part.CFrame * part2.CFrame:ToObjectSpace(v4.CFrame))
		table.insert(clones, clone)
	end

	for _, child in parent:GetChildren() do
		child:Destroy()
	end

	for _, v4 in clones do
		v4.Parent = parent
	end

	parent:SetAttribute("ready", true)
	print("[ServerTypeService] 2v2 桌子已生成：" .. tostring(#clones))
end

local function init()
	if flag then
		error("[ServerTypeService] init() called more than once")
	end

	flag = true
	local TRADE_POOL_NAME = nil

	if RunService:IsStudio() then
		local v = GameFlags.studioOnly["强制服务器"]

		if v == "交易服" then
			TRADE_POOL_NAME = ServerTypeService.TRADE_POOL_NAME
		elseif v == "2v2服" then
			TRADE_POOL_NAME = ServerTypeService.TWO_V_TWO_POOL_NAME
		end
	end

	ServerTeleport.server.init(TRADE_POOL_NAME, {
		[ServerTypeService.TWO_V_TWO_POOL_NAME] = true
	})
	task.spawn(function()
		local serverType = ServerTeleport.getServerType()
		local firstChild = Workspace:FindFirstChild("大厅")

		if serverType == ServerTypeService.TRADE_POOL_NAME then
			if firstChild then
				firstChild:Destroy()
			end
		else
			local firstChild2 = Workspace:FindFirstChild("交易大厅")

			if firstChild2 then
				firstChild2:Destroy()
			end

			if not firstChild then
				warn("[ServerTypeService] 大厅不存在")
				return
			end

			if serverType == ServerTypeService.TWO_V_TWO_POOL_NAME then
				local success, result = pcall(buildTwoVTwoTables, firstChild)

				if not success then
					warn("[ServerTypeService] 2v2 桌子生成失败：" .. tostring(result))
				end
			end

			hideReferences(firstChild)
			local v2 = GameFlags.feature["交易服"] ~= true and firstChild:FindFirstChild("交易服传送门")

			if v2 then
				v2:Destroy()
			end
		end
	end)
end

ServerTypeService.server.init = init
return ServerTypeService