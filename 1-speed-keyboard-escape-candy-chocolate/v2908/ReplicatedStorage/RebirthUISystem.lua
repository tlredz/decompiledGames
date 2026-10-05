local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Numbers = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Numbers"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local rebirth = remotes:WaitForChild("Rebirth")
local updateUI = remotes:WaitForChild("UpdateUI")
local formatMultiplier = Numbers.formatMultiplier
local flag = false
local onClientEventConnection = nil
local flag2 = false
local v = {
	modal = nil,
	closeBtn = nil,
	rebirthBtn = nil,
	currentMultText = nil,
	nextMultText = nil,
	reqLevelText = nil,
	progressFill = nil,
	progressText = nil,
	rebirthDevBtn = nil,
	RebirthFrame = nil
}

local function findElements()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local function getOne(tag)
		local tagged = CollectionService:GetTagged(tag)

		for _, v2 in ipairs(tagged) do
			if v2:IsDescendantOf(playerGui) then
				return v2
			end
		end

		return nil
	end

	v.modal = getOne("RebirthModal")
	v.closeBtn = getOne("RebirthCloseBtn")
	v.rebirthBtn = getOne("RebirthConfirmBtn")
	v.currentMultText = getOne("RebirthCurrentMultText")
	v.nextMultText = getOne("RebirthNextMultText")
	v.reqLevelText = getOne("RebirthReqLevelText")
	v.progressFill = getOne("RebirthBarFill")
	v.progressText = getOne("RebirthBarText")
	v.rebirthframe = getOne("RebirthFrame")
	v.rebirthDevBtn = getOne("RebirthDevProduct")
end

local RebirthUISystem = {
	UpdateDisplay = function(self)
		if not v.modal then
			findElements()
		end

		if not v.modal then
			return
		end

		local v2 = ClientState:Get()
		local REBIRTH_TIERS = Config.REBIRTH_TIERS
		local rebirths = v2.Rebirths or 0
		local v3 = rebirths + 1
		local multiplier = rebirths > 0 and Config.REBIRTH_TIERS[rebirths].multiplier or 1

		if #REBIRTH_TIERS < v3 then
			if v.currentMultText then
				v.currentMultText.Text = "x" .. formatMultiplier(multiplier) .. " " .. Config.GetSpeedLabel()
			end

			if v.nextMultText and v.nextMultText.Text ~= "MAX!" then
				v.nextMultText.Text = "MAX!"

				if v.progressFill then
					v.progressFill.Size = UDim2.new(1, 0, 1, 0)
				end

				if v.rebirthBtn then
					v.rebirthBtn.Text = "MAX"
					v.rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)

					if v.rebirthframe then
						v.rebirthframe.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
					end
				end
			end

			if v.rebirthDevBtn then
				v.rebirthDevBtn.Visible = false
			end
		else
			if v.rebirthDevBtn then
				v.rebirthDevBtn.Visible = true
			end

			local v4 = REBIRTH_TIERS[v3]
			local level = v4.level
			local multiplier2 = v4.multiplier

			if v.currentMultText then
				v.currentMultText.Text = "x" .. formatMultiplier(multiplier) .. " " .. Config.GetSpeedLabel()
			end

			if v.nextMultText then
				v.nextMultText.Text = "x" .. formatMultiplier(multiplier2) .. " " .. Config.GetSpeedLabel()
			end

			if v.reqLevelText then
				v.reqLevelText.Text = "Level " .. level
			end

			local v5 = math.clamp(v2.Level / level, 0, 1)

			if v.progressFill then
				v.progressFill.Size = UDim2.new(v5, 0, 1, 0)
			end

			if v.progressText then
				v.progressText.Text = "Level " .. v2.Level .. " / " .. level
			end

			if v.rebirthBtn then
				if level <= v2.Level then
					v.rebirthBtn.Text = flag2 and "WAIT..." or "Rebirth!"
					v.rebirthBtn.BackgroundColor3 = Color3.fromRGB(200, 18, 21)
					v.rebirthframe.BackgroundColor3 = Color3.fromRGB(200, 18, 21)
				else
					v.rebirthBtn.Text = "Need level " .. level
					v.rebirthBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
					v.rebirthframe.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				end
			end
		end
	end
}

local function initialize()
	if flag then
		return
	end

	if not v.modal then
		findElements()
	end

	if v.closeBtn then
		v.closeBtn.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end

	if v.rebirthDevBtn then
		v.rebirthDevBtn.MouseButton1Click:Connect(function()
			local rebirths = ClientState:Get().Rebirths or 0

			if #Config.REBIRTH_TIERS <= rebirths then
				return
			end

			local rebirthProductId = Config.GetRebirthProductId(rebirths)
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, rebirthProductId)
		end)
	end

	local v2 = {
		[Config.DEV_PRODUCTS.INSTANT_REBIRTH_T1] = true,
		[Config.DEV_PRODUCTS.INSTANT_REBIRTH_T2] = true,
		[Config.DEV_PRODUCTS.INSTANT_REBIRTH_T3] = true,
		[Config.DEV_PRODUCTS.INSTANT_REBIRTH_T4] = true
	}
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, p, p2)
		if p2 and v2[p] then
			SoundManager:Play("BUY")
			ClientState:CloseCurrentModal()
		end
	end)

	if v.rebirthBtn then
		v.rebirthBtn.MouseButton1Click:Connect(function()
			if flag2 then
				return
			end

			local v3 = ClientState:Get()
			local v4 = Config.REBIRTH_TIERS[v3.Rebirths + 1]

			if v4 and v3.Level >= v4.level then
				flag2 = true
				rebirth:FireServer()
				task.wait(0.2)
				ClientState:CloseCurrentModal()
				flag2 = false
			end
		end)
	end

	flag = true
end

function RebirthUISystem.OnClose(_)
	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	flag2 = false
end

function RebirthUISystem:InitLogic()
	if not v.modal then
		findElements()
	end

	initialize()
	self:UpdateDisplay()

	if not onClientEventConnection then
		onClientEventConnection = updateUI.OnClientEvent:Connect(function(data)
			if data.Level or data.Rebirths or data.Multiplier then
				self:UpdateDisplay()
			end
		end)
	end
end

return RebirthUISystem