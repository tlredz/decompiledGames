local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local service = ReplicatedStorage.Engine.Service
local Config = require(service.Config)
local GachaPool = require(service.GachaPool)
local ExperienceService = require(service.ExperienceService)
local PlayerData = require(service.PlayerData)
local client = PlayerData.client
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local RewardRollQueue = require(script.Parent.RewardRollQueue)
local OddsPanel = require(script.Parent.OddsPanel)
local tweenInfo = TweenInfo.new(12, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
local flag = false
local v = nil

local function getRequiredLevel()
	local v2 = Config.lvl.byFeatureUnlock["首充球"]
	local lvl = nil

	if type(v2) == "table" then
		for _, v3 in v2 do
			if typeof(v3.lvl) == "number" and (lvl == nil or v3.lvl < lvl) then
				lvl = math.floor(v3.lvl)
			end
		end
	end

	return lvl
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshVisibility(p: number?)
	v.Visible = p ~= nil and p <= ExperienceService.getLevelInfo(client.exp.total()).level and not client.hasBoughtFirstChargeBall()
end

local function collectBallImages()
	local images = {}

	for _, v2 in GachaPool.getChances("首充小球奖池") do
		local image

		if v2.weight > 0 then
			image = v2.definition and v2.definition.image
		else
			image = false
		end

		if typeof(image) == "string" and image ~= "" then
			table.insert(images, image)
		end
	end

	return images
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startImageCycle(p)
	local random = Random.new()
	task.spawn(function()
		local v2 = nil

		while v.Parent do
			local v3 = collectBallImages()

			if #v3 > 0 then
				local image = v3[random:NextInteger(1, #v3)]

				if #v3 > 1 then
					while image == v2 do
						image = v3[random:NextInteger(1, #v3)]
					end
				end

				p.Image = image
				v2 = image
			end

			task.wait(3)
		end
	end)
end

local FirstChargeBall = {}

function FirstChargeBall.PromptPurchase()
	if client.hasBoughtFirstChargeBall() then
		return
	end

	DevProductService.client.promptPurchase("Random Epic Ball")
end

function FirstChargeBall.Init()
	if flag then
		return
	end

	flag = true
	v = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("界面图标"):WaitForChild("左侧按钮区"):WaitForChild("首充小球按钮")
	local requiredLevel = getRequiredLevel()

	if requiredLevel == nil then
		warn("[FirstChargeBall] Config.lvl.featureUnlock 缺少「首充球」，首充小球按钮不显示")
	end

	refreshVisibility(requiredLevel) -- equivalent call inferred; original call site unknown
	client.exp.Changed(function()
		refreshVisibility(requiredLevel) -- equivalent call inferred; original call site unknown
	end)
	client.hasBoughtFirstChargeBall.Changed(function()
		refreshVisibility(requiredLevel) -- equivalent call inferred; original call site unknown
	end)
	startImageCycle(v:WaitForChild("小球图片")) -- equivalent call inferred; original call site unknown
	local v3 = v:WaitForChild("背景光效")
	v3.Rotation = 0
	TweenService:Create(v3, tweenInfo, {
		Rotation = 360
	}):Play()
	local randomEpicBall = DevProductService.products.byName["Random Epic Ball"]
	local v4 = v:WaitForChild("现价")

	if randomEpicBall then
		v4.Text = DevProductService.robuxEmoji .. " " .. tostring(randomEpicBall.PriceInRobux)
	else
		warn("[FirstChargeBall] 找不到开发者商品「Random Epic Ball」")
	end

	local v5 = v:WaitForChild("查看概率按钮")
	ButtonActions.Bind(v5, function()
		OddsPanel.Open("首充小球奖池")
	end)
	Net:RemoteEvent("FirstChargeBall/Result").OnClientEvent:Connect(function(p)
		RewardRollQueue.enqueue(p, "首充小球奖池", "firstChargeBall")
	end)
end

return FirstChargeBall