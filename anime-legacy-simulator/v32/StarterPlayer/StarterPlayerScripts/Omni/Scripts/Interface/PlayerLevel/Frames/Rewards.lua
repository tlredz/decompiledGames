local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 255, 0)
local color3 = Color3.fromRGB(0, 255, 0)
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("PlayerLevel"):WaitForChild("Main"):WaitForChild("Rewards"):WaitForChild("List"):WaitForChild("Scroll")
local playerLevel = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("PlayerLevel")
local v = {}
local innerScopes = {}
local Rewards = {}

local function IsNotExpChange(_, _, list)
	return list[1] ~= "Exp"
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = playerLevel.Reward:Clone()
		self.Instance.Name = self.Info.Name
		self.Instance.Main.Amount.Text = self.Info.Text
		self.Instance.Main.UIGradient:SetAttribute("Rarity", self.Info.Rarity or "Common")

		if self.Info.Icon then
			self.Instance.Main.Icon.Visible = true
			self.Instance.Main.Viewport.Visible = false
			self.Instance.Main.Icon.Image = self.Info.Icon or ""
		else
			self.Instance.Main.Icon.Visible = false
			self.Instance.Main.Viewport.Visible = true
			module.Utils.Camera.ViewportCharacter({
				Viewport = self.Instance.Main.Viewport,
				Animation = module.Utils.Characters.GetCharacterAnimation(self.Info.Name, "Idle"),
				Character = module.Utils.Characters.Get({
					Name = self.Info.Name,
					Shiny = self.Info.Shiny,
					RemoveHumanoidStates = true
				})
			})
		end

		local v2 = module.Button:Create(self.Instance.Main, "Small")
		v2:BindFunction("Click", function()
			if not self.Hover then
				return
			end

			if self.Tooltip then
				self.Hover:Click(self.Instance, {
					Text = self.Info.Name
				})
			else
				self.Hover:Click(self.Instance, {
					IsFake = true,
					Data = self.Info,
					Name = self.Info.Name
				})
			end
		end)
		v2:BindOnEnter("Hover", function()
			if not self.Hover then
				return
			end

			if self.Tooltip then
				self.Hover:Open(self.Instance, {
					Text = self.Info.Name
				})
			else
				self.Hover:Open(self.Instance, {
					IsFake = true,
					Data = self.Info,
					Name = self.Info.Name
				})
			end
		end)
		v2:BindOnLeave("Hover", function()
			if not self.Hover then
				return
			end

			self.Hover:Close(self.Instance)
		end)
		self.Instance.Parent = self.Parent
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Size:set(UDim2.fromScale(1, 1))
			end)
		else
			self.Size:set(UDim2.fromScale(1, 1))
		end

		return true
	end
})
local scope2 = fusion.scoped(fusion, {
	Build = function(self)
		self.Position = self:Value(UDim2.fromScale(0.5, 1.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = playerLevel.LevelReward:Clone()
		self.Instance.Name = self.Index
		self.Instance.Main.Level.Title.Text = module.Utils.Number:Format(self.Info.Level)
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "PlayerLevel", "ClaimReward", self.Info.Level)
		end)
		local v2 = {}

		for k, perk in self.Info.Perks do
			local perk2 = module.Shared.Perks[k]

			if perk2 then
				table.insert(v2, {
					Type = "Perk",
					Name = k,
					Text = module.Utils.Multipliers.ToStringSingle({
						Name = k,
						RemoveName = true,
						ShowPercentage = not perk2.NumericOnly,
						MultiplierArray = { perk }
					}),
					Icon = perk2.Icon,
					Rarity = perk2.Rarity
				})
			end
		end

		for _, reward in self.Info.Rewards do
			local v3 = module.Utils.Info:Get(reward.Type, reward.Name)

			if v3 then
				table.insert(v2, {
					Type = reward.Type,
					Name = reward.Name,
					Text = reward.Amount == 1 and reward.Type or reward.Amount .. "x",
					Icon = reward.Icon or v3.Icon,
					Rarity = reward.Rarity or v3.Rarity
				})
			end
		end

		self.Rewards = {}

		for k, info in v2 do
			local innerScope = scope:innerScope()
			innerScope.Info = info
			innerScope.Parent = self.Instance.Main.Rewards
			innerScope.Hover = module.Libs.NeoHover.GetByPseudoIdentifier(info.Type)

			if not innerScope.Hover then
				innerScope.Tooltip = true
				innerScope.Hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
			end

			if innerScope:Build((k - 1) * 0.05) then
				table.insert(self.Rewards, innerScope)
			else
				innerScope:doCleanup()
			end
		end

		self.Instance.LayoutOrder = self.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		local v3 = (self.Index - 1) * 0.05

		if v3 > 0 then
			task.delay(v3, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local v2 = module.Data.Level.Rewards["Level" .. self.Info.Level] == true
		local imageColor = module.Data.Level.Amount >= self.Info.Level and not v2 and color2 or v2 and color3 or color
		self.Instance.Main.ImageColor3 = imageColor
		self.Instance.Main.Level.BG.ImageColor3 = imageColor
	end
})

function Rewards.UpdateAll()
	for k, reward in module.Shared.PlayerLevel.List.Rewards do
		local v2 = innerScopes[k]

		if v2 then
			v2:Update()
		else
			local innerScope = scope2:innerScope()
			innerScope.Index = k
			innerScope.Info = reward

			if innerScope:Build() then
				innerScopes[k] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end
end

function Rewards.Start()
	v.Data = module:OnDataChangedDeferred({ "Level" }, Rewards.UpdateAll, IsNotExpChange)
	Rewards.UpdateAll()
end

function Rewards.Stop()
	for _, v2 in innerScopes do
		for _, reward in v2.Rewards do
			reward.Instance:Destroy()
			reward:doCleanup()
		end

		v2.Instance:Destroy()
		v2:doCleanup()
	end

	table.clear(innerScopes)

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
end

function Rewards.Init()
	Controller.FrameChanged:Connect(function(p: string?)
		if p == "Rewards" then
			Rewards.Start()
		else
			Rewards.Stop()
		end
	end)
end

return Rewards