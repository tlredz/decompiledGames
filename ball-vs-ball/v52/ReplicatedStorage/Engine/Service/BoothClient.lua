local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)
local BoothGoodsRenderer = require(ReplicatedStorage.Engine.Service.BoothGoodsRenderer)
local ServerTypeService = require(ReplicatedStorage.Engine.Service.ServerTypeService)
local BoothService = require(ReplicatedStorage.Engine.Service.BoothService)
local client = BoothService.client
local Booth = require(ReplicatedStorage.Engine.Gui.Booth)
local BoothClient = {}
local v = {}
local v2 = 0.5

-- equivalent calls inferred from this helper; original call sites unknown
local function readEmptyTransparency(p)
	if p and p.Value >= 0 and p.Value <= 1 then
		return p.Value
	end

	return 0.5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyStallTransparency(p, flag: boolean)
	local transparency = not flag and 0 or v2

	for _, dimPart in p.dimParts do
		dimPart.Transparency = transparency
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function localPlayerHasBooth()
	local localPlayer = Players.LocalPlayer

	for _, v3 in v do
		if v3.ownerUserId == localPlayer.UserId then
			return true
		end
	end

	return false
end

local function refreshPromptText(data)
	local localPlayer = Players.LocalPlayer

	if data.ownerUserId == nil then
		-- equivalent call inferred; original call site unknown
		if localPlayerHasBooth() then
			data.prompt.Enabled = false
			return
		end

		data.prompt.Enabled = true
		data.prompt.ActionText = "Claim"
		data.prompt.ObjectText = "Booth"
	elseif data.ownerUserId == localPlayer.UserId then
		data.prompt.Enabled = true
		data.prompt.ActionText = "Manage"
		data.prompt.ObjectText = "My Booth"
	else
		data.prompt.Enabled = true
		data.prompt.ActionText = "View"
		data.prompt.ObjectText = (data.ownerName or "?") .. "'s Booth"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshEmptyStallPrompts()
	for _, v3 in v do
		if v3.ownerUserId == nil then
			refreshPromptText(v3)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAddButtonVisibility(p, p2: number)
	if not p.addButton then
		return
	end

	local localPlayer = Players.LocalPlayer
	local addButton = p.addButton
	addButton.Visible = p.ownerUserId == localPlayer.UserId and p2 < 8
end

local function applyStallPayload(allState)
	local v3 = v[allState.stallName]

	if not v3 then
		return
	end

	v3.ownerUserId = allState.ownerUserId
	v3.ownerName = allState.ownerName
	refreshPromptText(v3)
	refreshEmptyStallPrompts() -- equivalent call inferred; original call site unknown
	local transparency = allState.ownerUserId ~= nil and 0 or v2

	for _, dimPart in v3.dimParts do
		dimPart.Transparency = transparency
	end

	if allState.ownerUserId then
		v3.infoGui.Enabled = true
		v3.goodsGui.Enabled = true
		v3.nameLabel.Text = allState.ownerName .. "'s Booth"
		v3.soldLabel.Text = tostring(allState.totalSold or 0)
		v3.renderer:Update(allState.listings or {})
		refreshAddButtonVisibility(v3, #(allState.listings or {})) -- equivalent call inferred; original call site unknown
	else
		v3.infoGui.Enabled = false
		v3.goodsGui.Enabled = false
		v3.renderer:Update({})

		if not v3.addButton then
			return
		end

		local localPlayer = Players.LocalPlayer
		v3.addButton.Visible = v3.ownerUserId == localPlayer.UserId
	end
end

function BoothClient.Init()
	task.spawn(function()
		if ServerTeleport.getServerType() ~= ServerTypeService.TRADE_POOL_NAME then
			return
		end

		local v3 = Workspace:WaitForChild("交易大厅", 10)

		if not v3 then
			return
		end

		local firstChild = v3:FindFirstChild("摊位")

		if not firstChild then
			return
		end

		BoothClient.bindStalls(firstChild)
	end)
end

function BoothClient.bindStalls(instance)
	local numberValue = instance:WaitForChild("无人摊位透明度", 5)

	if numberValue and not numberValue:IsA("NumberValue") then
		numberValue = nil
	end

	v2 = readEmptyTransparency(numberValue)

	for _, model in instance:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local proximityPrompt = model:WaitForChild("交互点"):WaitForChild("ProximityPrompt")
		local surfaceGui = model:WaitForChild("屏幕"):WaitForChild("小摊信息界面")
		local surfaceGui2 = model:WaitForChild("商品"):WaitForChild("小摊售卖物界面")

		if proximityPrompt:IsA("ProximityPrompt") and surfaceGui:IsA("SurfaceGui") and surfaceGui2:IsA("SurfaceGui") then
			local goodsList = surfaceGui2:WaitForChild("出售列表")
			local _1 = goodsList:WaitForChild("商品格1")
			local firstChild = goodsList:FindFirstChild("添加按钮")
			local parts = {}

			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") and part.Transparency == 0 then
					table.insert(parts, part)
				end
			end

			local v4 = {
				model = model,
				prompt = proximityPrompt,
				infoGui = surfaceGui,
				nameLabel = surfaceGui:WaitForChild("玩家名"),
				soldLabel = surfaceGui:WaitForChild("售出金额"),
				goodsGui = surfaceGui2,
				goodsList = goodsList,
				goodsTemplate = _1,
				addButton = firstChild,
				dimParts = parts,
				ownerUserId = nil,
				ownerName = nil,
				renderer = nil
			}
			v4.renderer = BoothGoodsRenderer.bind(goodsList, _1, function(p)
				if v4.ownerUserId then
					Booth.OpenListing(v4.ownerUserId, v4.ownerName or "?", p)
				end
			end)

			if firstChild then
				local v6 = v4
				firstChild.Activated:Connect(function()
					if v6.ownerUserId == Players.LocalPlayer.UserId then
						Booth.OpenManage()
					end
				end)
			end

			v[model.Name] = v4
			surfaceGui.Enabled = false
			surfaceGui2.Enabled = false
			applyStallTransparency(v4, true) -- equivalent call inferred; original call site unknown
			refreshPromptText(v4)
		else
			warn(("[BoothClient] 摊位 %s 结构类型不匹配，已跳过绑定：交互点.ProximityPrompt=%s 屏幕.小摊信息界面=%s 商品.小摊售卖物界面=%s"):format(
				model.Name,
				proximityPrompt.ClassName,
				surfaceGui.ClassName,
				surfaceGui2.ClassName
			))
		end
	end

	if numberValue then
		numberValue.Changed:Connect(function()
			v2 = readEmptyTransparency(numberValue)

			for _, v4 in v do
				if v4.ownerUserId ~= nil then
					continue
				end

				applyStallTransparency(v4, true) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	client.onStateChanged(applyStallPayload)
	local allStates = client.getAllStates()

	if typeof(allStates) == "table" then
		for _, allState in allStates do
			applyStallPayload(allState)
		end
	end
end

return BoothClient