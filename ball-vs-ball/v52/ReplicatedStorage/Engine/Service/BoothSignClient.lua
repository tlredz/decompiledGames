local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local BoothService = require(script.Parent.BoothService)
local client = BoothService.client
local BoothGoodsRenderer = require(script.Parent.BoothGoodsRenderer)
local Booth = require(ReplicatedStorage.Engine.Gui.Booth)
local BoothSignClient = {}
local fn = nil
local v = false
local v2 = {}
local connection = nil

local function apply(result)
	if not v or typeof(result) ~= "table" then
		return
	end

	local v3 = v2[result.ownerUserId]

	if not v3 or (result.version or 0) < v3.version then
		return
	end

	v3.version = result.version or 0
	v3.payload = result

	for k in v3.listeners do
		k(result)
	end
end

local function subscribe(p, callback)
	local userId = p.UserId
	local v3 = v2[userId]

	if not v3 then
		v3 = {
			version = -1,
			payload = nil,
			listeners = {}
		}
		v2[userId] = v3
	end

	v3.listeners[callback] = true

	if v3.payload then
		callback(v3.payload)
	end

	if not v3.fetching then
		v3.fetching = true
		task.spawn(function()
			for _ = 1, 10 do
				if not v or v2[userId] ~= v3 then
					return
				end

				local success, result = pcall(client.getSellerListings, userId)

				if not v or v2[userId] ~= v3 then
					return
				end

				if success and result then
					apply(result)
					break
				else
					task.wait(1)
				end
			end

			v3.fetching = false
		end)
	end

	return function()
		v3.listeners[callback] = nil

		if next(v3.listeners) == nil and v2[userId] == v3 then
			v2[userId] = nil
		end
	end
end

local function bindGoodsPanel(instance, instance2, p, p2)
	local scrollingFrame = instance:FindFirstChild("出售列表", true)

	if not (scrollingFrame and scrollingFrame:IsA("ScrollingFrame")) then
		return nil, nil
	end

	local _1 = scrollingFrame:FindFirstChild("商品格1")

	if not (_1 and _1:IsA("Frame")) then
		return nil, nil
	end

	local firstChild = scrollingFrame:FindFirstChild("添加按钮")
	local flag = false
	local v3 = BoothGoodsRenderer.bind(scrollingFrame, _1, function(p3)
		if not flag then
			p2.onSelect(p3)
		end
	end)
	v3:Update({})
	local activatedConnection = firstChild and firstChild.Activated:Connect(function()
		if not flag and p == Players.LocalPlayer then
			p2.onManageRequested()
		end
	end)

	local function render(data)
		if flag then
			return
		end

		v3:Update(data.listings or {})

		if firstChild then
			firstChild.Visible = p == Players.LocalPlayer and #(data.listings or {}) < 8
		end

		local label = instance2:FindFirstChild("玩家名")

		if label and label:IsA("TextLabel") then
			label.Text = data.ownerName .. "'s Booth"
		end

		local label2 = instance2:FindFirstChild("售出金额")

		if label2 and label2:IsA("TextLabel") then
			label2.Text = tostring(data.totalSold or 0)
		end
	end

	local function dispose()
		if flag then
			return
		end

		flag = true

		if activatedConnection then
			activatedConnection:Disconnect()
		end

		v3:Destroy()
	end

	return render, dispose
end

function BoothSignClient.subscribe(p, callback)
	BoothSignClient.Init()
	return (subscribe(p, callback))
end

function BoothSignClient.bindGoodsPanel(p, p2, p3, p4)
	return bindGoodsPanel(p, p2, p3, p4)
end

function BoothSignClient.Init()
	if fn then
		return
	end

	v = true
	local folder = Instance.new("Folder")
	folder.Name = "手持展牌交互面"
	folder.Parent = workspace
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "手持展牌界面"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	connection = client.onSellerChanged(apply)

	local function attach(player, tool)
		local surfaceGui = tool:FindFirstChild("正面商品界面")
		local surfaceGui2 = tool:FindFirstChild("背面摊主界面")
		local part = tool:FindFirstChild("正面交互面")

		if not (surfaceGui and surfaceGui:IsA("SurfaceGui") and surfaceGui2 and surfaceGui2:IsA("SurfaceGui") and part and part:IsA("BasePart")) then
			return nil
		end

		local weld = part:FindFirstChildOfClass("Weld")

		if not weld or not weld.Part0 or weld.Part1 ~= part or not weld.Part0:IsDescendantOf(tool) then
			return nil
		end

		if not (surfaceGui2.Adornee and surfaceGui2.Adornee:IsDescendantOf(tool)) then
			return nil
		end

		local scrollingFrame = surfaceGui:FindFirstChild("出售列表", true)

		if not (scrollingFrame and scrollingFrame:IsA("ScrollingFrame")) then
			return nil
		end

		local _1 = scrollingFrame:FindFirstChild("商品格1")

		if not (_1 and _1:IsA("Frame")) then
			return nil
		end

		local clone = part:Clone()
		clone.Name = player.Name .. "的展牌交互面"

		for _, child in clone:GetChildren() do
			child:Destroy()
		end

		clone.Anchored = false
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = true
		clone.Massless = true
		clone.Transparency = 1
		local clone2 = weld:Clone()
		clone2.Part0 = weld.Part0
		clone2.Part1 = clone
		clone.CFrame = clone2.Part0.CFrame * clone2.C0 * clone2.C1:Inverse()
		clone2.Parent = clone
		clone.Parent = folder
		local clone3 = surfaceGui:Clone()
		clone3.Name = player.Name .. "的正面商品界面"
		clone3.Adornee = clone
		clone3.Active = true
		clone3.ToolPunchThroughDistance = 100
		clone3.Enabled = true
		clone3.ResetOnSpawn = false
		clone3.Parent = screenGui
		local clone4 = surfaceGui2:Clone()
		clone4.Name = player.Name .. "的背面摊主界面"
		clone4.Adornee = surfaceGui2.Adornee
		clone4.Enabled = true
		clone4.ResetOnSpawn = false
		clone4.Parent = screenGui
		local enabled = surfaceGui.Enabled
		local enabled2 = surfaceGui2.Enabled
		local canQuery = part.CanQuery
		surfaceGui.Enabled = false
		surfaceGui2.Enabled = false
		part.CanQuery = false
		local v3, v4 = bindGoodsPanel(clone3, clone4, player, {
			onSelect = function(p)
				if tool.Parent == player.Character then
					Booth.OpenListing(player.UserId, player.Name, p)
				end
			end,
			onManageRequested = function()
				Booth.OpenManage()
			end
		})

		if not (v3 and v4) then
			return nil
		end

		v3({
			ownerName = player.Name,
			totalSold = 0,
			listings = {}
		})
		local v5 = subscribe(player, v3)
		local flag = false
		return function()
			if flag then
				return
			end

			flag = true
			v5()
			v4()
			clone3:Destroy()
			clone4:Destroy()
			clone:Destroy()

			if surfaceGui.Parent then
				surfaceGui.Enabled = enabled
			end

			if surfaceGui2.Parent then
				surfaceGui2.Enabled = enabled2
			end

			if part.Parent then
				part.CanQuery = canQuery
			end
		end
	end

	local v3 = Observers.observeCharacter(function(player, instance)
		local v4 = true
		local v5 = {}

		local function watch(tool)
			if not tool:IsA("Tool") or v5[tool] then
				return
			end

			local v6 = {
				connections = {},
				cleanup = nil,
				alive = true
			}
			v5[tool] = v6

			local function reconcile()
				if not (v4 and v6.alive) then
					return
				end

				local humanoid = instance:FindFirstChildOfClass("Humanoid")
				local v7

				if tool.Parent == instance and player.Character == instance and tool.Name == "手持展牌" then
					v7 = not humanoid or humanoid.Health > 0
				else
					v7 = false
				end

				if v7 then
					if not v6.cleanup then
						v6.cleanup = attach(player, tool)
					end
				elseif v6.cleanup then
					v6.cleanup()
					v6.cleanup = nil
				end
			end

			table.insert(v6.connections, tool:GetPropertyChangedSignal("Name"):Connect(reconcile))
			table.insert(v6.connections, tool.DescendantAdded:Connect(function()
				task.defer(reconcile)
			end))
			table.insert(v6.connections, tool.DescendantRemoving:Connect(function()
				if v6.cleanup then
					v6.cleanup()
					v6.cleanup = nil
				end

				task.defer(reconcile)
			end))
			reconcile()
			task.delay(10, function()
				if v4 and v6.alive and tool.Parent == instance and tool.Name == "手持展牌" and not v6.cleanup then
					warn("[BoothSignClient] 展牌资源不完整，等待 正面商品界面/背面摊主界面/正面交互面.Weld：" .. tool:GetFullName())
				end
			end)
		end

		local function remove(k)
			local v6 = v5[k]

			if not v6 then
				return
			end

			v5[k] = nil
			v6.alive = false

			for _, connection2 in v6.connections do
				connection2:Disconnect()
			end

			if v6.cleanup then
				v6.cleanup()
				v6.cleanup = nil
			end
		end

		local childAddedConnection = instance.ChildAdded:Connect(watch)
		local childRemovedConnection = instance.ChildRemoved:Connect(remove)
		local diedConnection = nil

		local function bindHumanoid(humanoid)
			if diedConnection or not humanoid:IsA("Humanoid") then
				return
			end

			diedConnection = humanoid.Died:Connect(function()
				for k in v5 do
					remove(k)
				end
			end)
		end

		local childAddedConnection2 = instance.ChildAdded:Connect(bindHumanoid)

		for _, humanoid in instance:GetChildren() do
			watch(humanoid)

			if diedConnection or not humanoid:IsA("Humanoid") then
				continue
			end

			diedConnection = humanoid.Died:Connect(function()
				for k in v5 do
					remove(k)
				end
			end)
		end

		return function()
			if not v4 then
				return
			end

			v4 = false
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
			childAddedConnection2:Disconnect()

			if diedConnection then
				diedConnection:Disconnect()
			end

			for k in v5 do
				remove(k)
			end
		end
	end)

	fn = function()
		v = false
		v3()

		if connection then
			connection:Disconnect()
		end

		table.clear(v2)
		folder:Destroy()
		screenGui:Destroy()
		fn = nil
	end
end

function BoothSignClient.Destroy()
	if fn then
		fn()
	end
end

return BoothSignClient