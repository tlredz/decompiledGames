local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local timeChamber = module.Shared.TimeChamber
local v = utf8.char(57346) .. " "
local v2 = {
	"Shop",
	"Confirmation",
	"Settings",
	"Inbox",
	"Guilds",
	"PlayerSelector",
	"TextSelector",
	"Profile",
	"Titles",
	"Banners"
}
local v3 = {
	Fighter = "Fighters",
	Weapon = "Weapons",
	Mount = "Mounts",
	Item = "Items"
}
local v4 = {
	"Fighters",
	"Weapons",
	"Mounts",
	"Items",
	"Tooltip"
}
local _ = {
	Position = createVector(0, -7.5, -7.5),
	Rotation = createVector(0, 0, 0)
}
local _ = {
	Position = createVector(0, -1.25, -4),
	Rotation = createVector(-0, -180, 0)
}
local timeChamber2 = module.Instance:WaitForChild("PlayerGui"):WaitForChild("TimeChamber")
local main = timeChamber2:WaitForChild("Main")
local topFrame = main:WaitForChild("TopFrame")
local header = topFrame:WaitForChild("Header")
local information = topFrame:WaitForChild("Information")
local playerViewport = topFrame:WaitForChild("PlayerViewport")
local downFrame = main:WaitForChild("DownFrame")
local scroll = downFrame:WaitForChild("Rewards"):WaitForChild("Scroll")
local products = downFrame:WaitForChild("Products")
local main2 = main:WaitForChild("ShopButton"):WaitForChild("Main")
local main3 = main:WaitForChild("RewardsButton"):WaitForChild("Main")
local rewards = timeChamber2:WaitForChild("Rewards")
local main4 = rewards:WaitForChild("Main")
local scroll2 = main4:WaitForChild("Rewards"):WaitForChild("Scroll")
local scroll3 = main4:WaitForChild("Chances"):WaitForChild("Scroll")
local main5 = main4:WaitForChild("Close"):WaitForChild("Main")
local close = timeChamber2:WaitForChild("Close")
local main6 = close:WaitForChild("Main")
local timeChamber3 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("TimeChamber")
local displayOrder = timeChamber2.DisplayOrder
local mouse = module.Instance:GetMouse()
local v5 = {}
local innerScopes = {}
local innerScopes2 = {}
local innerScopes3 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local worldModel = Instance.new("WorldModel")
local camera = Instance.new("Camera")
local v9 = nil
local v10 = 0
local spring = scope:Spring(scope:Value(1), 10, 1)
local size = main4.Size
local value = scope:Value(size)
local spring2 = scope:Spring(value, 10, 1)
local flag = false
local v11 = false
local v12 = nil
local v13 = nil
local flag2 = false
local flag3 = false
local TimeChamber = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatClock(time: number)
	local v14 = math.floor((math.max(0, time)))
	return ("%02i:%02i:%02i"):format(v14 // 3600, v14 // 60 % 60, v14 % 60)
end

local function GetRewardIcon(p, p2: string?)
	if p2 and p2 ~= "" then
		return p2
	end

	if p.Type == "Gamepass" then
		local gamepass = module.Shared.Gamepasses[p.Name]
		return v7[p.Name] or gamepass and gamepass.Icon or ""
	end

	local v14 = module.Utils.Info:Get(p.Type, p.Name)
	return v14 and v14.Icon or ""
end

local function ApplyRewardIcon(scope2, icon, reward, icon2: string?)
	if not icon2 or icon2 == "" then
		if reward.Type == "Gamepass" then
			local gamepass = module.Shared.Gamepasses[reward.Name]
			icon2 = v7[reward.Name] or gamepass and gamepass.Icon or ""
		else
			local v14 = module.Utils.Info:Get(reward.Type, reward.Name)
			icon2 = v14 and v14.Icon or ""
		end
	end

	icon.Image = icon2

	if icon.Image ~= "" or reward.Type ~= "Gamepass" then
		return
	end

	local gamepass = module.Shared.Gamepasses[reward.Name]

	if not gamepass or typeof(gamepass.ID) ~= "number" then
		return
	end

	task.spawn(function()
		local success, result = pcall(function()
			return module.Services.MarketplaceService:GetProductInfoAsync(gamepass.ID, Enum.InfoType.GamePass)
		end)

		if not (success and result and result.IconImageAssetId) then
			return
		end

		v7[reward.Name] = "rbxassetid://" .. result.IconImageAssetId

		if next(scope2) and icon.Parent then
			icon.Image = v7[reward.Name]
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsNamedReward(p)
	return p.Type == "Role" or p.Type == "Gamepass"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRewardRarity(reward)
	if IsNamedReward(reward) then
		return "Exclusive"
	end

	local v14 = module.Utils.Info:Get(reward.Type, reward.Name)
	return v14 and v14.Rarity
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatChance(p: number)
	return tostring(math.floor(p * 100 + 0.5) / 100) .. "%"
end

local function GetRandomRewardInfo(value2: string)
	for k, reward in timeChamber.Random.Rewards do
		if timeChamber.GetRewardKey(reward.Reward) == value2 then
			return k, reward.Reward
		end
	end

	local v14, name = string.match(value2, "^(.-):(.*)$")

	if v14 then
		return #timeChamber.Random.Rewards + 1, {
			Type = v14,
			Name = name
		}
	end

	return nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsHoverBlocked(instance)
	if next(v8) then
		return true
	end

	return v11 and not instance:IsDescendantOf(rewards)
end

local function CloseBlockedHover()
	for _, v14 in v4 do
		local v15 = module.Libs.NeoHover.GetByIdentifier(v14)
		local element = v15 and v15.Element

		if not (element and element:IsDescendantOf(timeChamber2) and (next(v8) or v11 and not element:IsDescendantOf(rewards))) then
			continue
		end

		v15:Close(nil, true)
	end

	if v12 and IsHoverBlocked(v12.Element) then
		v12 = nil
	end
end

local function BindRewardHover(connections, element, reward)
	local v14 = v3[reward.Type]
	local hover = module.Utils.Info:Get(reward.Type, reward.Name) and v14 and module.Libs.NeoHover.GetByIdentifier(v14)
	local v16

	if hover then
		v16 = {
			IsFake = true,
			Name = reward.Name,
			Amount = reward.Amount,
			Data = {
				ID = "",
				Name = reward.Name,
				Level = 1,
				Exp = 0,
				Shiny = false
			}
		}
	else
		hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
		v16 = {
			Text = 0
		}
		local text

		if IsNamedReward(reward) then
			text = reward.Name
		else
			text = `{reward.Name} x{module.Utils.Number:Format(reward.Amount)}`
		end

		v16.Text = text
	end

	if not hover then
		return
	end

	table.insert(connections, element.MouseEnter:Connect(function()
		if IsHoverBlocked(element) then
			return
		end

		hover:Open(element, v16)
		v12 = {
			Hover = hover,
			Element = element
		}
	end))
	table.insert(connections, element.MouseLeave:Connect(function()
		hover:Close(element)

		if v12 and v12.Element == element then
			v12 = nil
		end
	end))
	table.insert(connections, element.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 or IsHoverBlocked(element) then
			return
		end

		hover:Click(element, v16)
	end))
end

local function GetEffectiveInterval(p: number)
	return (math.floor(p / timeChamber.GetMultiplier(module.Instance)))
end

local function GetControls()
	local success, result = pcall(function()
		local PlayerModule = require(module.Instance:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		return PlayerModule:GetControls()
	end)

	if success then
		return result
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FetchStatus()
	if flag2 then
		return
	end

	flag2 = true
	local success, result = pcall(function()
		return module.Signal:Invoke("General", "Marketplace", "Status")
	end)
	flag2 = false

	if success and typeof(result) == "table" then
		v13 = result
	end

	TimeChamber.UpdateProducts()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SubmitVip(p: string, p2)
	flag3 = true
	pcall(function()
		if p == "Gems" then
			return module.Signal:Invoke("General", "Marketplace", "BuyGems", "V.I.P", p2.Sequence, p2.Price, 0)
		end

		return module.Signal:Invoke("General", "Marketplace", "Purchase", "V.I.P")
	end)
	flag3 = false
	FetchStatus() -- equivalent call inferred; original call site unknown
end

local function PurchaseVip(p: string)
	if flag3 or module.Data.Gamepasses["V.I.P"] then
		return
	end

	local VIP = v13 and v13["V.I.P"]

	if p == "Gems" and VIP then
		VIP = VIP.Gems
	end

	if not (VIP and VIP.Available) then
		task.spawn(FetchStatus)
		return
	end

	if p == "Gems" then
		module.Scripts.Interface.Confirmation.Start({
			Title = "Confirm purchase",
			Description = `Buy {timeChamber.Boosts["V.I.P"].Title} for {VIP.Price} Gems?`,
			ConfirmText = "Buy",
			CancelText = "Cancel",
			Callback = function(flag4: boolean)
				if not flag4 then
					return
				end

				SubmitVip(p, VIP) -- equivalent call inferred; original call site unknown
			end
		})
		return
	end

	SubmitVip(p, VIP) -- equivalent call inferred; original call site unknown
end

local scope2 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Instance = timeChamber3.Info:Clone()
		self.Instance.Name = self.Key
		self.Instance.LayoutOrder = self.Order
		local size2 = self.Instance.Main.Size
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)

		if self.Reward then
			ApplyRewardIcon(self, self.Instance.Main.Left.Icon, self.Reward)
			BindRewardHover(self, self.Instance.Main.Left.Icon, self.Reward)
		elseif self.Category == "Random" then
			self.Instance.Main.Left.Icon.Image = main3.Icon.Image
		end

		self.Instance.Parent = information
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Size:set(size2)
			end)
		else
			self.Size:set(size2)
		end

		self:Update()
		return true
	end,
	Update = function(data)
		local timeChamber4 = module.Data.TimeChamber
		local value2 = data.Instance.Main.Left.Value
		local value3 = data.Instance.Main.Right.Value

		if data.Category == "Total" then
			value2.Text = "Total Time"
			value3.Text = FormatClock(timeChamber4.Time)
		elseif data.Category == "Random" then
			value2.Text = module.Utils.Number:Format(timeChamber4.Random.Rolls)
			value3.Text = `+1 every {module.Utils.Number:Time2((math.floor(timeChamber.Random.Interval / timeChamber.GetMultiplier(module.Instance))))}`
		else
			local v14 = timeChamber4[data.Category][tostring(data.Index)]
			local time2 = module.Utils.Number:Time2((math.floor(data.Info.Interval / timeChamber.GetMultiplier(module.Instance))))
			value2.Text = module.Utils.Number:Format(not v14 and 0 or v14.Earned)
			local formatted = module.Utils.Number:Format(data.Reward.Amount or 1)

			if data.Category == "Periodic" then
				value3.Text = `+{formatted} every {time2}`
			else
				value3.Text = `+{formatted} every {time2} ({data.Info.Chance}%)`
			end
		end
	end
})
local scope3 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Instance = timeChamber3.Reward:Clone()
		self.Instance.Name = tostring(self.Index)
		self.Instance.LayoutOrder = self.Info.Time
		local position = self.Instance.Main.Position
		self.Position = self:Value(position - UDim2.fromScale(0.5, 0))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		local reward = self.Info.Reward
		self.Instance.Main.Title.Text = `{module.Utils.Number:Time2(self.Info.Time)} Reward`
		self.Instance.Main.Desc.Text = "Pre-Release reward"
		local value2 = self.Instance.Main.Amount.Value
		local text

		if IsNamedReward(reward) then
			text = reward.Name
		else
			text = `{module.Utils.Number:Format(reward.Amount)}x`
		end

		value2.Text = text
		ApplyRewardIcon(self, self.Instance.Main.Icon, reward, self.Info.Icon)
		BindRewardHover(self, self.Instance.Main.Icon, reward)
		module.Button:Create(self.Instance.Main.Buttons.Claim.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "TimeChamber", "Claim", self.Index)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(position)
			end)
		else
			self.Position:set(position)
		end

		self:Update()
		return true
	end,
	Update = function(data)
		local timeChamber4 = module.Data.TimeChamber
		local visible = timeChamber4.Claimed[tostring(data.Index)] == true
		local visible2 = not visible and timeChamber4.Time >= data.Info.Time
		local buttons = data.Instance.Main.Buttons
		buttons.Visible = not visible
		buttons.Claim.Visible = visible2
		buttons.Locked.Visible = not (visible or visible2)
		buttons.Locked.Main.Title.Text = module.Utils.Number:Time2((math.ceil((math.max(
			0,
			data.Info.Time - timeChamber4.Time
		)))))
		data.Instance.Main.Claimed.Visible = visible
	end
})
local scope4 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Instance = timeChamber3.RandomReward:Clone()
		self.Instance.Name = self.Key
		self.Instance.LayoutOrder = self.Order
		local size2 = self.Instance.Main.Size
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance.Main.Title.Text = self.Reward.Name
		self.Instance.Main.Viewport.Visible = false
		local uIGradient = self.Instance.Main.UIGradient
		local rewardRarity = GetRewardRarity(self.Reward) -- equivalent call inferred; original call site unknown
		uIGradient:SetAttribute("Rarity", rewardRarity)
		ApplyRewardIcon(self, self.Instance.Main.Icon, self.Reward)
		BindRewardHover(self, self.Instance.Main, self.Reward)
		local instance = self.Instance
		local parent

		if self.Kind == "Owned" then
			parent = scroll2
		else
			parent = scroll3
		end

		instance.Parent = parent
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Size:set(size2)
			end)
		else
			self.Size:set(size2)
		end

		self:Update()
		return true
	end,
	Update = function(data)
		local amount = data.Instance.Main.Amount

		if data.Kind == "Owned" then
			local v14 = module.Data.TimeChamber.Random.Rewards[data.Key] or 0
			amount.Text = `{module.Utils.Number:Format(v14)}x`
		else
			if not data.Chance then
				amount.Text = "Owned"
				return
			end

			local randomAmountRange, v14 = timeChamber.GetRandomAmountRange(data.Info)
			local v15

			if randomAmountRange < v14 then
				v15 = `{randomAmountRange}-{v14}x`
			else
				v15 = `{randomAmountRange}x`
			end

			amount.Text = ("%* (%*)"):format(v15, FormatChance(data.Chance))
		end
	end
})
local v14 = {
	Build = function(self, duration: number)
		self.Instance = timeChamber3.Product:Clone()
		self.Instance.Name = self.Name
		self.Instance.LayoutOrder = self.Info.Order
		local size2 = self.Instance.Main.Size
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance.Main.Title.Text = self.Info.Title
		self.Instance.Main.Desc.Text = self.Info.Description
		local gamepass = module.Shared.Gamepasses[self.Name]
		local color = self.Info.Color or gamepass and gamepass.Color
		local uIGradient = self.Instance.Main:FindFirstChild("UIGradient")

		if uIGradient and color then
			uIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
		end

		if self.Info.Icon == "" then
			if gamepass then
				task.spawn(function()
					local success, result = pcall(function()
						return module.Services.MarketplaceService:GetProductInfoAsync(
							gamepass.ID,
							Enum.InfoType.GamePass
						)
					end)

					if not (success and result and result.IconImageAssetId) then
						return
					end

					if next(self) and self.Instance.Parent then
						self.Instance.Main.Icon.Image = "rbxassetid://" .. result.IconImageAssetId
					end
				end)
			end
		else
			self.Instance.Main.Icon.Image = self.Info.Icon
		end

		local buttons = self.Instance.Main.Buttons

		if self.Info.Kind == "Gamepass" then
			module.Button:Create(buttons.Robux.Main, "Small"):BindFunction("Click", function()
				if flag3 or module.Data.Gamepasses["V.I.P"] then
					return
				end

				local VIP = v13 and v13["V.I.P"]

				if not (VIP and VIP.Available) then
					task.spawn(FetchStatus)
					return
				end

				flag3 = true
				local v15 = "Robux"
				pcall(function()
					if v15 == "Gems" then
						return module.Signal:Invoke(
							"General",
							"Marketplace",
							"BuyGems",
							"V.I.P",
							VIP.Sequence,
							VIP.Price,
							0
						)
					end

					return module.Signal:Invoke("General", "Marketplace", "Purchase", "V.I.P")
				end)
				flag3 = false
				FetchStatus() -- equivalent call inferred; original call site unknown
			end)
			module.Button:Create(buttons.Gems.Main, "Small"):BindFunction("Click", function()
				PurchaseVip("Gems")
			end)
		else
			module.Button:Create(buttons.Robux.Main, "Small"):BindFunction("Click", function()
				if timeChamber.IsBoostActive(module.Instance, self.Name) then
					return
				end

				pcall(function()
					module.Services.MarketplaceService:PromptPremiumPurchase(module.Instance)
				end)
			end)
		end

		self.Instance.Parent = products
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Size:set(size2)
			end)
		else
			self.Size:set(size2)
		end

		self:Update()
		return true
	end,
	Update = function(data)
		local buttons = data.Instance.Main.Buttons
		local isBoostActive = timeChamber.IsBoostActive(module.Instance, data.Name)

		if data.Info.Kind == "Gamepass" then
			local v15 = v13 and v13[data.Name]
			local gems = v15 and v15.Gems
			buttons.Robux.Main.Title.Text = isBoostActive and "Owned" or not (v15 and v15.Price) and "..." or v .. module.Utils.Number:Format(v15.Price)
			local gems2 = buttons.Gems
			local visible = not isBoostActive

			if visible then
				if gems == nil then
					visible = false
				else
					visible = gems.Price ~= nil
				end
			end

			gems2.Visible = visible

			if gems and gems.Price then
				buttons.Gems.Main.Title.Text = `{module.Utils.Number:Format(gems.Price)} Gems`
			end
		else
			buttons.Robux.Main.Title.Text = isBoostActive and "Active" or "Subscribe"
			buttons.Gems.Visible = false
		end
	end
}
local scope5 = fusion.scoped(fusion, v14)

function TimeChamber.ClearViewport()
	if v9 then
		v9:Destroy()
		v9 = nil
	end
end

function TimeChamber.BuildViewport()
	TimeChamber.ClearViewport()
	local humanoidModel = module.Utils.Players.GetHumanoidModel(module.Instance.UserId)

	if not humanoidModel then
		return
	end

	if not flag or v9 then
		humanoidModel:Destroy()
		return
	end

	humanoidModel.Parent = worldModel
	local humanoid = humanoidModel:FindFirstChildOfClass("Humanoid")
	local characterAnimation = module.Utils.Characters.GetCharacterAnimation("Default", "Idle")

	if characterAnimation and humanoid then
		local v15 = humanoid:FindFirstChildOfClass("Animator")

		if not v15 then
			v15 = Instance.new("Animator")
			v15.Parent = humanoid
		end

		local track = v15:LoadAnimation(characterAnimation)
		track.Looped = true
		track:Play()
	end

	v9 = humanoidModel
	spring:setPosition(0)
	TimeChamber.UpdatePlayerPosition()
end

function TimeChamber.UpdatePlayerPosition()
	if not v9 then
		return
	end

	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	local lerped = (createVector(0, -7.5, -7.5)):Lerp(createVector(0, -1.25, -4), currentSpring)
	local lerped2 = (createVector(0, 0, 0)):Lerp(createVector(-0, -180, 0), currentSpring)
	local v15 = CFrame.new(lerped) * CFrame.Angles(
		math.rad(lerped2.X),
		math.rad(lerped2.Y + v10),
		(math.rad(lerped2.Z))
	)
	v9:PivotTo(v15)
end

function TimeChamber.UpdateMouse()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local absolutePosition = playerViewport.AbsolutePosition
	local absoluteSize = playerViewport.AbsoluteSize
	local v15 = absolutePosition.X + absoluteSize.X / 2
	v10 = (mouse.X - v15) / math.max(viewportSize.X - v15, v15) * 45
	TimeChamber.UpdatePlayerPosition()
end

function TimeChamber.UpdateHeader()
	local text = timeChamber.GetRole(module.Instance) or "Normal"
	local role = timeChamber.Roles[text]
	local v16 = role and (role.EarlyAccess or 0) > 0
	header.Timer.Title.Text = v16 and "Early access in:" or "Game releases in:"
	header.Timer.Value.Text = module.Utils.Number:Time3((math.floor((timeChamber.GetRemainingTime(module.Instance)))))
	header.Special.Visible = v16 == true

	if v16 then
		header.Special.Title.Text = text
		header.Special.Description.Text = role.Description or ""
	end
end

function TimeChamber.GenerateInfos()
	local v15 = {
		{
			Key = "Total",
			Category = "Total"
		}
	}

	if #timeChamber.Random.Rewards > 0 then
		table.insert(v15, {
			Key = "Random",
			Category = "Random"
		})
	end

	for k, info in timeChamber.Periodic do
		table.insert(v15, {
			Key = `Periodic{k}`,
			Category = "Periodic",
			Index = k,
			Info = info
		})
	end

	for k, info in timeChamber.Chance do
		table.insert(v15, {
			Key = `Chance{k}`,
			Category = "Chance",
			Index = k,
			Info = info
		})
	end

	for k, v16 in v15 do
		if innerScopes[v16.Key] then
			continue
		end

		local innerScope = scope2:innerScope()
		innerScope.Key = v16.Key
		innerScope.Order = k
		innerScope.Category = v16.Category
		innerScope.Index = v16.Index
		innerScope.Info = v16.Info
		innerScope.Reward = v16.Info and v16.Info.Reward

		if innerScope:Build((k - 1) * 0.05) then
			innerScopes[v16.Key] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function TimeChamber.GenerateRewards()
	for k, info in timeChamber.Confirmed do
		if innerScopes2[k] then
			continue
		end

		local innerScope = scope3:innerScope()
		innerScope.Index = k
		innerScope.Info = info

		if innerScope:Build((k - 1) * 0.05) then
			innerScopes2[k] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function TimeChamber.GenerateProducts()
	for k, boost in timeChamber.Boosts do
		if innerScopes3[k] then
			continue
		end

		local innerScope = scope5:innerScope()
		innerScope.Name = k
		innerScope.Info = boost

		if innerScope:Build((boost.Order - 1) * 0.05) then
			innerScopes3[k] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function TimeChamber.GenerateRandomRewards()
	if not v11 then
		return
	end

	local v15 = {}

	for k in module.Data.TimeChamber.Random.Rewards do
		local order, reward = GetRandomRewardInfo(k)

		if reward then
			v15[`Owned{k}`] = {
				Kind = "Owned",
				Key = k,
				Order = order,
				Reward = reward
			}
		end
	end

	local chancesByIndex = {}

	for _, v16 in timeChamber.GetRandomPool(module.Data) do
		chancesByIndex[v16.Index] = v16.Chance
	end

	for k, reward in timeChamber.Random.Rewards do
		local randomAmountRange = timeChamber.GetRandomAmountRange(reward)
		local clone = table.clone(reward.Reward)
		clone.Amount = randomAmountRange
		v15[`Chance{k}`] = {
			Kind = "Chance",
			Key = `Chance{k}`,
			Order = k,
			Reward = clone,
			Info = reward,
			Chance = chancesByIndex[k]
		}
	end

	for k, v16 in v6 do
		if v15[k] then
			continue
		end

		v16.Instance:Destroy()
		v16:doCleanup()
		v6[k] = nil
	end

	local v16 = {}

	for k, v17 in v15 do
		local v18 = v6[k]

		if v18 then
			v18.Chance = v17.Chance
			v18:Update()
		else
			v17.TemplateKey = k
			table.insert(v16, v17)
		end
	end

	table.sort(v16, function(a, b)
		if a.Order == b.Order then
			return a.TemplateKey < b.TemplateKey
		end

		return a.Order < b.Order
	end)
	local v17 = {}

	for _, v18 in v16 do
		local v19 = v17[v18.Kind] or 0
		local innerScope = scope4:innerScope()
		innerScope.Kind = v18.Kind
		innerScope.Key = v18.Key
		innerScope.Order = v18.Order
		innerScope.Reward = v18.Reward
		innerScope.Info = v18.Info
		innerScope.Chance = v18.Chance

		if innerScope:Build(v19 * 0.05) then
			v17[v18.Kind] = v19 + 1
			v6[v18.TemplateKey] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function TimeChamber.OpenRewardsPopup()
	if not flag or v11 then
		return
	end

	v11 = true
	CloseBlockedHover()
	spring2:setPosition(UDim2.fromScale(0, 0))
	value:set(size)
	TimeChamber.RefreshVisibility()
	TimeChamber.GenerateRandomRewards()
end

function TimeChamber.CloseRewardsPopup()
	if not v11 then
		return
	end

	v11 = false

	if v12 and v12.Element:IsDescendantOf(rewards) then
		v12.Hover:Close(v12.Element)
		v12 = nil
	end

	TimeChamber.ClearTemplates(v6)
	TimeChamber.RefreshVisibility()
end

function TimeChamber.UpdateInfos()
	for _, v15 in innerScopes do
		v15:Update()
	end
end

function TimeChamber.UpdateRewards()
	for _, v15 in innerScopes2 do
		v15:Update()
	end
end

function TimeChamber.UpdateProducts()
	for _, v15 in innerScopes3 do
		v15:Update()
	end
end

function TimeChamber:ClearTemplates()
	for k, item in self do
		item.Instance:Destroy()
		item:doCleanup()
		self[k] = nil
	end
end

function TimeChamber.RefreshVisibility()
	local v15 = next(v8) ~= nil
	local visible = not v15
	timeChamber2.Enabled = flag
	timeChamber2.DisplayOrder = v15 and 0 or displayOrder
	topFrame.Visible = visible
	downFrame.Visible = visible
	main2.Parent.Visible = visible
	main3.Parent.Visible = visible
	rewards.Visible = flag and v11 and visible
	close.Visible = flag and visible and timeChamber.HasAccess(module.Instance)

	if flag and not v15 then
		module.Frame:AddFramesHider("TimeChamber")
		module.Frame:CloseHUD()
		task.defer(function()
			if flag and not next(v8) then
				module.Frame:CloseHUD()
			end
		end)
	else
		module.Frame:RemoveFramesHider("TimeChamber")

		if not flag then
			module.Frame:RefreshHUD()
		end
	end
end

function TimeChamber.Update()
	if not flag then
		return
	end

	TimeChamber.UpdateHeader()
	TimeChamber.UpdateInfos()
	TimeChamber.UpdateRewards()
end

function TimeChamber.Start()
	if flag then
		return
	end

	flag = true
	local success, result = pcall(function()
		local PlayerModule = require(module.Instance:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		return PlayerModule:GetControls()
	end)

	if not success then
		result = nil
	end

	if result then
		result:Disable()
	end

	TimeChamber.RefreshVisibility()
	module.Scripts.Rendering.Weather.RefreshSounds()
	TimeChamber.UpdateHeader()
	TimeChamber.GenerateInfos()
	TimeChamber.GenerateRewards()
	TimeChamber.GenerateProducts()
	task.spawn(TimeChamber.BuildViewport)
	v5.TimeChamber = module:OnDataChanged({ "TimeChamber" }, function()
		TimeChamber.UpdateInfos()
		TimeChamber.UpdateRewards()
		TimeChamber.GenerateRandomRewards()
	end)
	v5.Gamepasses = module:OnDataChanged({ "Gamepasses" }, function()
		TimeChamber.UpdateInfos()
		TimeChamber.UpdateProducts()
		TimeChamber.GenerateRandomRewards()
	end)
	v5.Membership = module.Instance:GetPropertyChangedSignal("MembershipType"):Connect(function()
		TimeChamber.UpdateInfos()
		TimeChamber.UpdateProducts()
	end)
	v5.Vip = module.Instance:GetAttributeChangedSignal("VIP"):Connect(function()
		TimeChamber.UpdateInfos()
		TimeChamber.UpdateProducts()
	end)
	v5.Mouse = mouse.Move:Connect(TimeChamber.UpdateMouse)
	task.spawn(FetchStatus)
end

function TimeChamber.Stop()
	if not flag then
		return
	end

	flag = false

	for _, connection in v5 do
		connection:Disconnect()
	end

	table.clear(v5)
	v11 = false
	v12 = nil
	TimeChamber.ClearTemplates(v6)
	TimeChamber.ClearTemplates(innerScopes)
	TimeChamber.ClearTemplates(innerScopes2)
	TimeChamber.ClearTemplates(innerScopes3)
	TimeChamber.ClearViewport()
	v13 = nil
	local success, result = pcall(function()
		local PlayerModule = require(module.Instance:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		return PlayerModule:GetControls()
	end)

	if not success then
		result = nil
	end

	if result then
		result:Enable()
	end

	TimeChamber.RefreshVisibility()
	module.Scripts.Rendering.Weather.RefreshSounds()
	module.Scripts.Interface.Tutorial.Refresh()
end

function TimeChamber.IsActive()
	return flag
end

function TimeChamber.Refresh()
	if timeChamber.IsRunning() and not timeChamber.GetRole(module.Instance) then
		return
	end

	local v15 = not timeChamber.Check(module.Instance)

	if v15 and not flag then
		TimeChamber.Start()
	elseif not v15 and flag then
		TimeChamber.Stop()
	end

	local v16 = close
	local visible = flag

	if visible then
		if next(v8) == nil then
			visible = timeChamber.HasAccess(module.Instance)
		else
			visible = false
		end
	end

	v16.Visible = visible
	TimeChamber.Update()
end

function TimeChamber.Init()
	for _, v15 in v2 do
		local v16 = v15
		module.Frame:OnFrameOpened(v15, function()
			v8[v16] = true
			CloseBlockedHover()
			TimeChamber.RefreshVisibility()
		end)
		local v17 = v15
		module.Frame:OnFrameClosed(v15, function()
			v8[v17] = nil
			TimeChamber.RefreshVisibility()
		end)
	end

	module.Button:Create(main2, "HUD"):BindFunction("Click", function()
		module.Scripts.Interface.Shop.Open(nil, "TimeChamber")
	end)
	module.Button:Create(main3, "HUD"):BindFunction("Click", function()
		TimeChamber.OpenRewardsPopup()
	end)
	module.Button:Create(main5, "Close"):BindFunction("Click", function()
		TimeChamber.CloseRewardsPopup()
	end)
	module.Button:Create(main6, "Close"):BindFunction("Click", function()
		module.Signal:Fire("General", "TimeChamber", "Leave")
	end)
	module.Instance:GetAttributeChangedSignal(timeChamber.RoleAttribute):Connect(function()
		TimeChamber.Refresh()
		module.Scripts.Interface.Tutorial.Refresh()
	end)
	module.Instance:GetAttributeChangedSignal(timeChamber.LeftAttribute):Connect(TimeChamber.Refresh)
	TimeChamber.Refresh()
	task.spawn(function()
		while task.wait(1) do
			TimeChamber.Refresh()
		end
	end)
end

timeChamber2.Enabled = false
rewards.Visible = false
close.Visible = false
scope:Hydrate(main4)({
	Size = spring2
})
worldModel.Name = "Holder"
worldModel.Parent = playerViewport
camera.CFrame = CFrame.new()
camera.Parent = playerViewport
playerViewport.CurrentCamera = camera
playerViewport.Ambient = Color3.new(1, 1, 1)
playerViewport.LightColor = Color3.new(1, 1, 1)
playerViewport.ImageColor3 = Color3.new(1, 1, 1)
playerViewport.LightDirection = createVector(-1, -1, -1)
scope:Observer(spring):onBind(TimeChamber.UpdatePlayerPosition)
return TimeChamber