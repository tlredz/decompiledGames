local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local UpdateLogService = require(ReplicatedStorage.Engine.Service.UpdateLogService)
local RewardAutoOpenQueue = require(ReplicatedStorage.Engine.Gui.RewardAutoOpenQueue)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local UnifiedPanel = require(ReplicatedStorage.Engine.Service.GamepadSupport.UnifiedPanel)
local v = nil
local flag = false

local function fn() end

local function fn2() end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(image)
	return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
end

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local function setupButtonFeedback(clone)
	local size = clone.Size
	clone.MouseEnter:Connect(function()
		local size2 = size
		TweenService:Create(clone, TweenInfo.new(0.1), {
			Size = UDim2.new(size2.X.Scale * 1.05, size2.X.Offset * 1.05, size2.Y.Scale * 1.05, size2.Y.Offset * 1.05)
		}):Play()
	end)
	clone.MouseLeave:Connect(function()
		TweenService:Create(clone, TweenInfo.new(0.1), {
			Size = size
		}):Play()
	end)
end

local UpdateLog = {
	SetTopbarEnabled = function(flag2: boolean)
		if not flag2 then
			fn2()
		end

		if v then
			v:setEnabled(flag2)
		end
	end
}

local function ensureIcon()
	if v then
		return v
	end

	v = TopbarPlus.new()
	v:setImage("rbxassetid://86038512915255"):setImageScale(0.8)
	v:setLabel("Updates")
	v:bindEvent("selected", function()
		fn()
	end)
	v:bindEvent("deselected", function()
		fn2()
	end)
	return v
end

function UpdateLog.GetIcon()
	return (ensureIcon())
end

function UpdateLog.Init()
	local background = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("更新日志"):WaitForChild("Background")
	local frame = background:WaitForChild("Frame")
	local updateFrame = frame:WaitForChild("updateFrame")
	local left = updateFrame:WaitForChild("left")
	local right = updateFrame:WaitForChild("right")
	local closeBtn = frame:WaitForChild("closeBtn")
	local logBtn = left:WaitForChild("logBtn")
	local text = right:WaitForChild("text")
	local typeLabel = right:WaitForChild("typeLabel")
	logBtn.Visible = false
	text.Visible = false
	typeLabel.Visible = false
	background.Visible = false
	local size = frame.Size
	local v2 = UnifiedPanel.new(background, {
		closeButton = closeBtn,
		scroll = right,
		isOpen = function()
			return flag
		end
	})
	local v3 = {}
	local names = {}

	for _, v4 in ipairs(Config.updateLog.list) do
		local name = v4.name

		if not v3[name] then
			table.insert(names, name)
			v3[name] = {
				date = v4.date,
				image = v4.image,
				entries = {}
			}
		end

		table.insert(v3[name].entries, v4)
	end

	local v4 = names[1]
	local clones = {}

	local function clearRight()
		for _, v5 in clones do
			v5:Destroy()
		end

		clones = {}
		right.CanvasPosition = Vector2.zero
	end

	local function renderRight(p: string)
		clearRight()
		local v5 = v3[p]

		if not v5 then
			return
		end

		local group = nil
		local count = 0

		for _, entry in v5.entries do
			if entry.group ~= group then
				group = entry.group
				count += 1
				local clone = typeLabel:Clone()
				clone.Text = entry.group
				clone.LayoutOrder = count
				clone.Visible = true
				clone.Parent = right
				table.insert(clones, clone)
			end

			count += 1
			local clone = text:Clone()

			if entry.group == "Redeem Code" then
				clone.AutoLocalize = false
			end

			clone.Text = entry.txt
			clone.LayoutOrder = count
			clone.Visible = true
			clone.Parent = right
			table.insert(clones, clone)
		end
	end

	for i, text2 in ipairs(names) do
		local v6 = v3[text2]
		local clone = logBtn:Clone()
		clone.LayoutOrder = i

		-- equivalent call inferred; original call site unknown
		if isValidImageValue(v6.image) then
			clone.Image = v6.image
		end

		local update = clone:WaitForChild("update")
		local time = clone:WaitForChild("time")
		update.Text = text2
		time.Text = v6.date
		clone.Visible = true
		clone.Parent = left
		setupButtonFeedback(clone)
		clone.Active = true
		local v7 = text2
		v2:Bind(clone, function()
			renderRight(v7)
		end, i)
	end

	if v4 then
		renderRight(v4)
	end

	fn = function()
		if flag then
			return false
		end

		flag = true
		background.Visible = true
		frame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(frame, tweenInfo, {
			Size = size
		}):Play()

		if v then
			v:select()
		end

		v2:Refresh()
		return true
	end

	fn2 = function()
		if not flag then
			return
		end

		flag = false
		TweenService:Create(frame, tweenInfo2, {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.delay(tweenInfo2.Time, function()
			if not flag then
				background.Visible = false
			end
		end)

		if v then
			v:deselect()
		end

		v2:Refresh()
		RewardAutoOpenQueue.Finish("UpdateLog")
	end

	v2:Bind(closeBtn, function()
		if not flag then
			return
		end

		if v4 then
			UpdateLogService.client.markRead(v4)
		end

		fn2()
	end, #names + 1)
	ensureIcon()
	local localPlayer = Players.LocalPlayer
	local updateLogSkipAutoOpen = localPlayer:GetAttribute("UpdateLogSkipAutoOpen")

	if updateLogSkipAutoOpen == nil then
		localPlayer:GetAttributeChangedSignal("UpdateLogSkipAutoOpen"):Wait()
		updateLogSkipAutoOpen = localPlayer:GetAttribute("UpdateLogSkipAutoOpen")
	end

	RewardAutoOpenQueue.ResolveInitial("UpdateLog", function()
		if updateLogSkipAutoOpen or not v4 or client.updateLog() == v4 then
			return false
		end

		return fn()
	end)
end

return UpdateLog