local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")
local Net = require(ReplicatedStorage.Packages.Net)
local remoteFunction = Net:RemoteFunction("RedeemCodeRedeem")
local _ = {
	SUCCESS = "SUCCESS",
	INVALID = "INVALID",
	EXPIRED = "EXPIRED",
	PROCESSING = "PROCESSING",
	ERROR = "ERROR",
	CLAIMED = "CLAIMED"
}
local v = {
	SUCCESS = Color3.fromRGB(85, 255, 0),
	INVALID = Color3.fromRGB(255, 70, 70),
	EXPIRED = Color3.fromRGB(255, 165, 0),
	PROCESSING = Color3.fromRGB(220, 220, 220),
	ERROR = Color3.fromRGB(150, 150, 150),
	CLAIMED = Color3.fromRGB(80, 170, 255)
}
local codes = {}
local v2 = {}
local v3 = {}
local dataStore = nil
local dataStore2 = nil
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeCode(value: string)
	return value:gsub("%s+", ""):upper()
end

local function retry(fn, ...)
	local v5 = table.pack(...)

	for i = 1, 3 do
		local success, result = pcall(fn, table.unpack(v5, 1, v5.n))

		if success then
			return true, result
		end

		if i < 3 then
			task.wait(1)
		end
	end

	return false, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getClaims(p)
	local v5, v6 = retry(function()
		return dataStore:GetAsync((tostring(p.UserId)))
	end)

	if v5 then
		return v6 or {}
	end

	return nil
end

local function addClaim(p, p2: string)
	return (retry(function()
		dataStore:UpdateAsync(tostring(p.UserId), function(options)
			local selected = options or {}
			selected[p2] = true
			return selected
		end)
	end))
end

local function removeClaim(p, p2: string)
	return (retry(function()
		dataStore:UpdateAsync(tostring(p.UserId), function(options)
			local selected = options or {}
			selected[p2] = nil
			return selected
		end)
	end))
end

local function clearClaims(p)
	return (retry(function()
		dataStore:UpdateAsync(tostring(p.UserId), function(p2)
			if p2 then
				return {
					__redeemCodeGrants = p2.__redeemCodeGrants
				}
			end

			return {}
		end)
	end))
end

local function grantToPlayerName(value: string, value2: string)
	if type(value) ~= "string" or value == "" or type(value2) ~= "string" then
		return false, "INVALID_INPUT"
	end

	local code = normalizeCode(value2) -- equivalent call inferred; original call site unknown
	local v5 = codes[code]

	if not (v5 and v5.grantOnly) then
		return false, "INVALID_CODE"
	end

	local v6, v7 = retry(function()
		return Players:GetUserIdFromNameAsync(value)
	end)

	if not v6 or type(v7) ~= "number" then
		return false, "PLAYER_NOT_FOUND"
	end

	local v8 = retry(function()
		dataStore:UpdateAsync(tostring(v7), function(options)
			local v9 = options or {}
			local __redeemCodeGrants = v9.__redeemCodeGrants or {}
			__redeemCodeGrants[code] = true
			v9.__redeemCodeGrants = __redeemCodeGrants
			return v9
		end)
	end)

	if v8 then
		return v8, "GRANTED"
	end

	return v8, "DATASTORE_ERROR"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function incrementCount(code: string, maxCount: number)
	local v5, v6 = retry(function()
		return dataStore2:UpdateAsync(code, function(value)
			local v7 = type(value) ~= "number" and 0 or value

			if maxCount <= v7 then
				return nil
			end

			return v7 + 1
		end)
	end)
	local v7

	if v5 then
		if type(v6) == "number" then
			v7 = v6 <= maxCount
		else
			v7 = false
		end
	else
		v7 = v5
	end

	return v5, v7
end

local function decrementCount(p: string)
	return (retry(function()
		dataStore2:UpdateAsync(p, function(value)
			return (math.max(0, (type(value) ~= "number" and 0 or value) - 1))
		end)
	end))
end

local function serverRedeem(p, value: string)
	if v2[p] then
		return "PROCESSING"
	end

	v2[p] = true
	local userId = p.UserId
	local now = os.clock()
	local v5 = v3[userId]

	if v5 and now - v5 < 2 then
		v2[p] = nil
		return "PROCESSING"
	end

	v3[userId] = now
	local v6 = "ERROR"

	if not pcall(function()
		local code = normalizeCode(value) -- equivalent call inferred; original call site unknown
		local v7 = codes[code]

		if not v7 then
			v6 = "INVALID"
			return
		end

		local claims = getClaims(p) -- equivalent call inferred; original call site unknown

		if claims == nil then
			v6 = "ERROR"
			return
		end

		if claims[code] then
			v6 = "CLAIMED"
			return
		end

		if v7.grantOnly and not (claims.__redeemCodeGrants or {})[code] then
			v6 = "INVALID"
			return
		end

		local v9 = p

		if not retry(function()
			dataStore:UpdateAsync(tostring(v9.UserId), function(options)
				local selected = options or {}
				selected[code] = true
				return selected
			end)
		end) then
			v6 = "ERROR"
			return
		end

		local v10

		if v7.limited then
			local v11, v12 = incrementCount(code, v7.maxCount) -- equivalent call inferred; original call site unknown

			if v11 and v12 then
				v10 = true
			else
				local v13 = p

				if not retry(function()
					dataStore:UpdateAsync(tostring(v13.UserId), function(options)
						local selected = options or {}
						selected[code] = nil
						return selected
					end)
				end) then
					warn((`[RedeemCodeService] 玩家{p.UserId}的{code}占用回退失败`))
				end

				v6 = v11 and "EXPIRED" or "ERROR"
				return
			end
		else
			v10 = false
		end

		local success, result = pcall(v7.grantReward, p)

		if success and result == true then
			v6 = "SUCCESS"
			return
		end

		if v10 and not retry(function()
			dataStore2:UpdateAsync(code, function(value2)
				return (math.max(0, (type(value2) ~= "number" and 0 or value2) - 1))
			end)
		end) then
			warn((`[RedeemCodeService] {code}份额回退失败`))
		end

		local v11 = p

		if not retry(function()
			dataStore:UpdateAsync(tostring(v11.UserId), function(options)
				local selected = options or {}
				selected[code] = nil
				return selected
			end)
		end) then
			warn((`[RedeemCodeService] 玩家{p.UserId}的{code}领取记录回退失败`))
		end

		v6 = "ERROR"
	end) then
		v6 = "ERROR"
	end

	v2[p] = nil
	return v6
end

local function initServer(p)
	dataStore = DataStoreService:GetDataStore("RedeemCode_Claims_v1")
	dataStore2 = DataStoreService:GetDataStore("RedeemCode_Counts_v1")
	codes = {}

	for _, code in p.codes do
		codes[code.code:gsub("%s+", ""):upper()] = code
	end

	remoteFunction.OnServerInvoke = function(p2, value)
		if type(value) == "string" and #value ~= 0 and not (#value > 64) then
			return (serverRedeem(p2, value))
		end

		return "INVALID"
	end

	Players.PlayerRemoving:Connect(function(player)
		v2[player] = nil
		v3[player.UserId] = nil
	end)
end

local flag = false

local function buildUI()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local clone = script.UITemplate:Clone()
	clone.Name = "RedeemCodeGui"
	clone.ResetOnSpawn = false
	clone.DisplayOrder = 1
	clone.Enabled = false
	local bg = clone.bg
	local _ = bg["标题"]
	local closeBtn = bg["关闭按钮"]
	local inputBox = bg["输入框"]
	local statusLabel = bg["兑换状态"]
	local redeemBtn = bg["兑换按钮"]
	statusLabel.Text = ""
	statusLabel.Visible = false
	inputBox.Text = ""
	clone.Parent = playerGui
	return {
		screenGui = clone,
		bg = bg,
		inputBox = inputBox,
		statusLabel = statusLabel,
		redeemBtn = redeemBtn,
		closeBtn = closeBtn
	}
end

local function setupButtonEffects(data)
	local size = data.Size
	local uDim = UDim2.new(size.X.Scale * 1.04, 0, size.Y.Scale * 1.04, 0)
	local uDim2 = UDim2.new(size.X.Scale * 0.95, 0, size.Y.Scale * 0.95, 0)
	local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	data.MouseEnter:Connect(function()
		TweenService:Create(data, tweenInfo2, {
			Size = uDim
		}):Play()
	end)
	data.MouseLeave:Connect(function()
		TweenService:Create(data, tweenInfo2, {
			Size = size
		}):Play()
	end)
	data.MouseButton1Down:Connect(function()
		TweenService:Create(data, tweenInfo, {
			Size = uDim2
		}):Play()
	end)
	data.MouseButton1Up:Connect(function()
		TweenService:Create(data, tweenInfo2, {
			Size = size
		}):Play()
	end)
end

local function initClient()
	if flag then
		return
	end

	flag = true
	local UI = buildUI()
	local size = UI.bg.Size
	setupButtonEffects(UI.redeemBtn)
	setupButtonEffects(UI.closeBtn)
	local uIStroke = UI.statusLabel:FindFirstChildWhichIsA("UIStroke")
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local v5 = nil
	local thread = nil

	local function showStatus(text: string)
		if thread then
			task.cancel(thread)
			thread = nil
		end

		if v5 then
			v5:Cancel()
		end

		UI.statusLabel.Text = text
		UI.statusLabel.TextColor3 = v[text] or Color3.fromRGB(255, 255, 255)
		UI.statusLabel.Visible = true
		UI.statusLabel.TextTransparency = 1

		if uIStroke then
			uIStroke.Transparency = 1
		end

		v5 = TweenService:Create(UI.statusLabel, tweenInfo, {
			TextTransparency = 0
		})
		v5:Play()

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 0
			}):Play()
		end

		thread = task.delay(3, function()
			thread = nil
			local tween = TweenService:Create(UI.statusLabel, tweenInfo2, {
				TextTransparency = 1
			})
			v5 = tween
			tween:Play()

			if uIStroke then
				TweenService:Create(uIStroke, tweenInfo2, {
					Transparency = 1
				}):Play()
			end

			tween.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed then
					UI.statusLabel.Visible = false
				end
			end)
		end)
	end

	local flag2 = false

	local function attemptRedeem()
		if flag2 then
			return
		end

		local text = UI.inputBox.Text

		if not text or #text == 0 then
			return
		end

		flag2 = true
		showStatus("PROCESSING")
		local success, result = pcall(function()
			return remoteFunction:InvokeServer(text)
		end)
		flag2 = false
		local text2 = success and result or "ERROR"
		showStatus(text2)

		if text2 == "SUCCESS" then
			UI.inputBox.Text = ""
		end
	end

	ButtonActions.Bind(UI.redeemBtn, attemptRedeem)
	UI.inputBox.FocusLost:Connect(function(p)
		if p then
			attemptRedeem()
		end
	end)
	local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo4 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local v6 = nil

	local function showUI()
		if v6 then
			v6:Cancel()
		end

		UI.screenGui.Enabled = true
		UI.bg.Size = UDim2.fromScale(0, 0)
		local tween = TweenService:Create(UI.bg, tweenInfo3, {
			Size = size
		})
		v6 = tween
		tween:Play()
	end

	local function hideUI()
		if v6 then
			v6:Cancel()
		end

		local tween = TweenService:Create(UI.bg, tweenInfo4, {
			Size = UDim2.fromScale(0, 0)
		})
		v6 = tween
		tween:Play()
		tween.Completed:Once(function(p)
			if p == Enum.PlaybackState.Completed then
				UI.screenGui.Enabled = false
			end
		end)
	end

	local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
	v4 = TopbarPlus.new()
	v4:setImage(131348681804975)
	v4:setImageScale(1)
	v4:setLabel("Codes")
	v4:autoDeselect(false)
	v4.selected:Connect(showUI)
	v4.deselected:Connect(hideUI)
	ButtonActions.Bind(UI.closeBtn, function()
		v4:deselect()
	end)
end

local function getIcon()
	initClient()
	return v4
end

local function setTopbarEnabled(flag2: boolean)
	if v4 and not flag2 then
		v4:deselect()
	end
end

return {
	server = {
		init = initServer,
		clearClaims = clearClaims,
		grantToPlayerName = grantToPlayerName
	},
	client = {
		init = initClient,
		getIcon = getIcon,
		setTopbarEnabled = setTopbarEnabled
	}
}