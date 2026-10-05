local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local DirectionalIndicator = require(ReplicatedStorage.Modules.ClientUI.DirectionalIndicator)
local MyDataController = require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local SkillCheckController = require(ReplicatedStorage.Modules.ClientUI.SkillCheckController)
local v = nil
local v2 = {}
local v3 = nil
local size = nil
local StoryEventsController = {
	init = function(p)
		v = p
		size = GameContext.Gui.MonsterIcon.Size
	end
}

local function ensureChaseCountLabel()
	local gui = GameContext.Gui
	local parent = gui.MonsterIcon:FindFirstChild("ChaseCount")

	if parent then
		return parent
	end

	parent = Instance.new("TextLabel")
	parent.Name = "ChaseCount"
	parent.Size = UDim2.new(0.55, 0, 0.55, 0)
	parent.Position = UDim2.new(0.65, 0, 0.65, 0)
	parent.AnchorPoint = Vector2.new(0, 0)
	parent.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	parent.BackgroundTransparency = 0
	parent.TextColor3 = Color3.fromRGB(255, 255, 255)
	parent.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	parent.TextStrokeTransparency = 0.3
	parent.Font = Enum.Font.GothamBold
	parent.TextScaled = true
	parent.Text = ""
	parent.Visible = false
	parent.ZIndex = gui.MonsterIcon.ZIndex + 1
	parent.Parent = gui.MonsterIcon
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = parent
	return parent
end

local function bounceEye()
	local gui = GameContext.Gui
	gui.MonsterIcon.Size = size
	local tween = TweenService:Create(
		gui.MonsterIcon,
		TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(size.X.Scale * 1.25, 0, size.Y.Scale * 1.25, 0)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		TweenService:Create(gui.MonsterIcon, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = size
		}):Play()
	end)
end

local function updateCounter(chaseCount, p)
	local chaseCount2 = GameContext.Gui.MonsterIcon:FindFirstChild("ChaseCount")

	if not chaseCount2 then
		return
	end

	if not (chaseCount > 1) then
		chaseCount2.Visible = false
		return
	end

	chaseCount2.Text = tostring(chaseCount)
	chaseCount2.Visible = true
	chaseCount2.BackgroundColor3 = p and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(60, 180, 60)
	chaseCount2.Size = UDim2.new(0.35, 0, 0.35, 0)
	TweenService:Create(chaseCount2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.55, 0, 0.55, 0)
	}):Play()
	task.delay(0.25, function()
		TweenService:Create(chaseCount2, TweenInfo.new(0.3), {
			BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		}):Play()
	end)
end

function StoryEventsController.setupAll()
	local gui = GameContext.Gui
	local player = GameContext.Player
	local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
	ensureChaseCountLabel()
	local connections = {}
	local v4 = {
		Default = function(p)
			return p
		end,
		Ranged = function(p)
			p.color = Color3.fromRGB(255, 236, 127)
			p.image = "rbxassetid://89977011599826"
			return p
		end,
		Lethal = function(p)
			p.color = Color3.fromRGB(255, 31, 31)
			p.image = "rbxassetid://130003390406761"
			return p
		end
	}
	local v5 = 0
	table.insert(connections, ReplicatedStorage.StoryEvents.Spotted.OnClientEvent:Connect(function(p, p2)
		local function directionIndicator(p3)
			if not MyDataController:getDataFromPath("Settings.SpottedVisualizer") or p3 and v2[p3] then
				return
			end

			local monster = p3 and TowerLUT:GetMonster(p3.Name)
			local v7 = v4[not monster and "Default" or monster.Lethal and "Lethal" or monster.Ranged and "Ranged" or "Default"] or v4.Default

			if p3 then
				DirectionalIndicator:CreateIndicator(p3, (v7({
					fadeInTime = 0.25,
					fadeOutTime = 1.5,
					timeout = 0.3,
					image = "rbxassetid://108396695400804",
					color = Color3.fromRGB(255, 255, 255)
				})))
				v2[p3] = true
				task.delay(1.8, function()
					v2[p3] = nil
				end)
			end
		end

		if p2 == "ranged" then
			directionIndicator(p)
			return
		end

		task.wait()

		if GameContext.skillchecking == true and not SkillCheckController.isDoorCheckActive() then
			v.circleHandler.CleanUp(player)
			v.treadmillHandler.CleanUp()
			GameContext.skillchecking = false
			GameContext.hideAllSkillCheckUI()
		end

		local now = tick()

		if now - v5 >= 15 then
			v5 = now
			Audio:PlayOne("Sounds.UI.Alerts.Spotted")
			directionIndicator(p)
		elseif now - v5 >= 5 then
			v5 = now
			Audio:PlayOne("Sounds.UI.Alerts.Spotted2")
			directionIndicator(p)
		end
	end))
	table.insert(connections, ReplicatedStorage.StoryEvents.LostInterest.OnClientEvent:Connect(function() end))
	local chaseCount = player:GetAttribute("ChaseCount") or 0
	table.insert(connections, player:GetAttributeChangedSignal("ChaseCount"):Connect(function()
		local chaseCount2 = player:GetAttribute("ChaseCount") or 0

		if chaseCount2 > 0 and chaseCount == 0 then
			if v3 then
				v3:Pause()
				v3:Destroy()
			end

			gui.MonsterIcon.Image = "rbxassetid://18141936824"
			gui.MonsterIcon.ImageTransparency = 0
			bounceEye()

			if chaseCount2 > 1 then
				updateCounter(chaseCount2, true)
			end
		elseif chaseCount < chaseCount2 then
			updateCounter(chaseCount2, true)
		elseif chaseCount2 > 1 and chaseCount2 < chaseCount then
			updateCounter(chaseCount2, false)
		elseif chaseCount2 == 1 and chaseCount > 1 then
			local chaseCount_2 = gui.MonsterIcon:FindFirstChild("ChaseCount")
			chaseCount_2.Visible = false
			gui.MonsterIcon.Image = "rbxassetid://18141936824"
			gui.MonsterIcon.ImageTransparency = 0
			bounceEye()
		elseif chaseCount2 == 0 and chaseCount > 0 then
			local chaseCount_3 = gui.MonsterIcon:FindFirstChild("ChaseCount")
			chaseCount_3.Visible = false

			if v3 then
				v3:Pause()
				v3:Destroy()
			end

			gui.MonsterIcon.Image = "rbxassetid://18142077985"
			gui.MonsterIcon.ImageTransparency = 0
			bounceEye()
			task.delay(1.2, function()
				if (player:GetAttribute("ChaseCount") or 0) == 0 then
					v3 = TweenService:Create(gui.MonsterIcon, TweenInfo.new(0.5), {
						ImageTransparency = 1
					})
					v3:Play()
				end
			end)
		end

		chaseCount = chaseCount2
	end))
	return connections
end

return StoryEventsController