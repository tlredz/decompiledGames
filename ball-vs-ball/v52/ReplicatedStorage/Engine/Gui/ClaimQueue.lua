local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local ButtonActions = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local FlightController = require(script.FlightController)

local function formatSerial(serial: number)
	return "#" .. string.format("%d", serial):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo4 = TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
local tweenInfo5 = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local parent = nil
local v2 = nil
local size = nil
local position = nil
local v3 = nil
local size2 = nil
local v4 = nil
local v5 = nil
local count = 0
local v6 = {}
local v7 = {}
local v8 = nil
local flag = false
local v9 = false
local flag2 = false
local v10 = nil
local v11 = 0
local v12 = -1e999
local v13 = -1e999

local function bounceInventoryButton()
	local size3 = size2
	local uDim = UDim2.new(size3.X.Scale * 1.25, size3.X.Offset * 1.25, size3.Y.Scale * 1.25, size3.Y.Offset * 1.25)

	if v4 then
		v4:Cancel()
	end

	local tween = TweenService:Create(v3, tweenInfo5, {
		Size = uDim
	})
	v4 = tween
	tween.Completed:Connect(function(p)
		if p == Enum.PlaybackState.Completed then
			local tween2 = TweenService:Create(v3, tweenInfo6, {
				Size = size3
			})
			v4 = tween2
			tween2:Play()
		end
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playLandingSound()
	if not v5 then
		return
	end

	count += 1
	v5.PlaybackSpeed = math.min((count - 1) * 0.05 + 1, 1.8)
	v5:Play()
end

local function landingFeedback(flag3: boolean)
	local now = os.clock()

	if flag3 and now - v13 >= 0.1 and v3.Parent then
		v13 = now
		bounceInventoryButton()
	end

	if now - v12 >= 0.05 then
		v12 = now
		playLandingSound() -- equivalent call inferred; original call site unknown
	end
end

local function bindPayload(state, payload)
	local color = Color3.fromHex(payload.colorHex)
	state.image.Image = payload.image
	state.nameLabel.Text = payload.name
	state.light.ImageColor3 = color
	state.shadow.Color = color

	if state.trackingBadge and state.trackingBadge:IsA("GuiObject") then
		state.trackingBadge.Visible = typeof(payload.killCount) == "number"
	end

	if state.serialLabel then
		state.serialLabel.Visible = payload.serial ~= nil
		state.serialLabel.Text = payload.serial == nil and "" or formatSerial(payload.serial)
	end

	state.payload = payload
end

local function refresh()
	if not flag2 or v9 then
		return
	end

	local v14 = v10 or v6
	local count2 = #v14

	for k, v15 in v7 do
		local payload = v14[count2 - k + 1]
		local visible = v15.frame.Visible

		if v15.sizeTween then
			v15.sizeTween:Cancel()
		end

		if v15.moveTween then
			v15.moveTween:Cancel()
		end

		v15.frame.Visible = payload ~= nil
		local button = v15.button
		button.Visible = payload ~= nil and k == 1 and v10 == nil

		if payload then
			if v15.payload ~= payload then
				bindPayload(v15, payload)
			end

			local v18 = k - 1
			local v19 = v18 % 2 == 1 and 1 or -1
			local rotation = v18 == 0 and 0 or math.clamp(v19 * 3 * v18, -8, 8)
			local v21 = math.min(3 * v18, 6)
			v15.frame.ZIndex = 5 - v18
			v15.moveTween = TweenService:Create(v15.frame, tweenInfo2, {
				Rotation = rotation,
				Position = position + UDim2.fromOffset(v19 * v21, v21 * 0.6)
			})
			v15.moveTween:Play()

			if visible then
				v15.frame.Size = size
			else
				v15.frame.Size = UDim2.fromScale(0, 0)
				v15.sizeTween = TweenService:Create(v15.frame, tweenInfo, {
					Size = size
				})
				v15.sizeTween:Play()
				v15.light.Rotation = 0
				v15.spin:Play()
			end

			if k == 1 then
				v15.button.Text = count2 >= 3 and "Receive All" or "Receive"
			end
		else
			v15.payload = nil
			v15.spin:Cancel()
			v15.frame.Size = size
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestRefresh()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		refresh()
	end)
end

local function animateOutgoingCard()
	if v11 >= 6 then
		return
	end

	local clone = v7[1].frame:Clone()
	clone.Name = "退出卡片"
	clone.ZIndex = 6
	clone["领取按钮"].Visible = false
	clone["领取按钮"].Active = false
	clone["领取按钮"].Selectable = false
	clone.Size = size
	clone.Parent = parent
	v11 += 1
	TweenService:Create(clone, tweenInfo3, {
		Size = UDim2.fromScale(0, 0)
	}):Play()
	task.delay(0.18, function()
		clone:Destroy()
		v11 -= 1
	end)
end

local function activateTop()
	if v9 or v10 or #v6 == 0 or not GamepadSupport.CanActivate(v7[1].button) then
		return
	end

	refresh()
	local snapshot = FlightController.snapshot(v7[1].image)

	if #v6 >= 3 then
		local v14 = v6
		v6 = {}
		v10 = v14

		for _, v15 in v7 do
			v15.button.Visible = false
		end

		v8.enqueue(v14, snapshot, true, function()
			animateOutgoingCard()
			refresh()
		end, function()
			v10 = nil
			requestRefresh() -- equivalent call inferred; original call site unknown
		end)
	else
		local v14 = { table.remove(v6) }
		v8.enqueue(v14, snapshot, false)
		v9 = true
		v7[1].button.Visible = false

		if v7[1].sizeTween then
			v7[1].sizeTween:Cancel()
		end

		v7[1].spin:Cancel()
		v7[1].sizeTween = TweenService:Create(v7[1].frame, tweenInfo3, {
			Size = UDim2.fromScale(0, 0)
		})
		v7[1].sizeTween:Play()
		task.delay(0.18, function()
			v7[1].frame.Visible = false
			v9 = false
			requestRefresh() -- equivalent call inferred; original call site unknown
		end)
	end
end

local ClaimQueue = {}

function ClaimQueue.enqueue(data)
	if #v6 + (v10 and #v10 or 0) >= 50 then
		local onLanded = data.onLanded

		if onLanded then
			task.spawn(function()
				local success, result = pcall(onLanded)

				if not success then
					warn("[ClaimQueue] onLanded: " .. tostring(result))
				end
			end)
		end
	else
		if #v6 == 0 and not v10 then
			count = 0
		end

		table.insert(v6, {
			image = data.image,
			name = data.name,
			colorHex = data.colorHex,
			killCount = data.killCount,
			serial = data.serial,
			flyTarget = data.flyTarget,
			onLanded = data.onLanded
		})
		requestRefresh() -- equivalent call inferred; original call site unknown
	end
end

function ClaimQueue.flyToInventory(p, flyTarget, onLanded)
	v8.enqueue({
		{
			image = p.Image,
			flyTarget = flyTarget,
			onLanded = onLanded
		}
	}, FlightController.snapshot(p), false)
end

function ClaimQueue.Init()
	if flag2 then
		return
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local v14 = playerGui:WaitForChild("抽奖效果")
	parent = v14:WaitForChild("背景")
	parent.Visible = true
	v2 = parent:WaitForChild("卡片模板")
	v2.Visible = false
	size = v2.Size
	position = v2.Position
	v3 = playerGui:WaitForChild("界面图标"):WaitForChild("左侧按钮区"):WaitForChild("库存按钮")
	size2 = v3.Size
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ClaimQueueFlightLayer"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 1000
	screenGui.Parent = playerGui
	v5 = ReplicatedStorage:WaitForChild("音效素材"):WaitForChild("入库")
	v8 = FlightController.new(screenGui, v3, landingFeedback)

	for i = 1, 5 do
		local clone = v2:Clone()
		clone.Name = "卡片"
		clone.Visible = false
		clone.Parent = parent
		local v15 = clone:WaitForChild("领取按钮")
		v15.Active = true
		v15.Interactable = true
		v15.Selectable = i == 1
		local light = clone:WaitForChild("light")
		v7[i] = {
			frame = clone,
			button = v15,
			light = light,
			image = clone:WaitForChild("ImageLabel"),
			nameLabel = clone:WaitForChild("名称"),
			shadow = clone:WaitForChild("UIShadow"),
			serialLabel = clone:FindFirstChild("唯一编号"),
			trackingBadge = clone:FindFirstChild("统计标记"),
			spin = TweenService:Create(light, tweenInfo4, {
				Rotation = 360
			})
		}

		if i ~= 1 then
			continue
		end

		ButtonActions.Bind(v15, activateTop)
		GamepadPages.Observe(clone, {
			defaultButton = v15,
			available = function()
				return #v6 > 0 and not v9 and v10 == nil
			end
		})
	end

	GamepadSupport.WatchRoot(v14)
	flag2 = true
	requestRefresh() -- equivalent call inferred; original call site unknown
end

return ClaimQueue