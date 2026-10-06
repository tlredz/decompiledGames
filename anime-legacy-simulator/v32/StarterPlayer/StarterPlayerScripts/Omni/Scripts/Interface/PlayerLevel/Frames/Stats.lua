local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local stats = module.Interface:WaitForChild("Frames"):WaitForChild("PlayerLevel"):WaitForChild("Main"):WaitForChild("Stats")
local scroll = stats:WaitForChild("List"):WaitForChild("Scroll")
local playerLevel = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("PlayerLevel")
local v = {}
local innerScopes = {}
local Stats = {}

local function IsNotExpChange(_, _, list)
	return list[1] ~= "Exp"
end

local function IsTokenChange(_, _, list)
	if list[1] ~= "List" then
		return true
	end

	local v2 = list[2]
	return v2 == nil or v2 == module.Shared.PlayerLevel.Price.Name
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = playerLevel.Stat:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, self.Info.Color)
		})
		module.Button:Create(self.Instance.Main.Add.Main, "Small"):BindFunction("Click", function()
			local availablePoints = module.Shared.PlayerLevel.GetAvailablePoints(module.Data)

			if availablePoints <= 0 then
				module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
					Message = "You don't have any points to add",
					Color = Color3.fromRGB(255, 255, 0)
				})
			else
				module.Signal:FireSelf("Interface", "AmountSelector", "Start", {
					Minimum = 1,
					Maximum = availablePoints,
					Callback = function(p: number)
						module.Signal:Fire("General", "PlayerLevel", "UpgradeStat", self.Name, p)
					end
				})
			end
		end)
		self.Instance.LayoutOrder = self.Info.Index
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

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local v2 = module.Shared.Perks[self.Name] or {}
		self.Instance.Main.Title.Text = `{self.Name} ({module.Utils.Number:Format(module.Data.Level.Stats[self.Name] or 0)} Points)`
		self.Instance.Main.Desc.Text = module.Utils.Multipliers.ToStringSingle({
			Name = self.Name,
			RemoveName = true,
			ShowPercentage = not v2.NumericOnly,
			MultiplierArray = {
				{
					Type = self.Info.Type,
					Amount = self.Info.Start + (module.Data.Level.Stats[self.Name] or 0) * self.Info.Increasing
				}
			}
		}) .. " (" .. `{self.Info.Type == "Multi" and `{self.Info.Increasing}x` or `+{self.Info.Increasing}`}` .. " per point)"
	end
})

function Stats.UpdateResetButton()
	local v2 = module.Data.Items.List[module.Shared.PlayerLevel.Price.Name] or 0
	stats.ResetStats.Main.Title.Text = not (v2 > 0) and "Buy" or `Reset ({module.Utils.Number:Format(v2)} {v2 == 1 and "Token" or "Tokens"})`
end

function Stats.UpdateAll()
	stats.Points.Desc.Text = module.Shared.PlayerLevel.GetAvailablePoints(module.Data) .. " Points"

	for k, stat in module.Shared.PlayerLevel.List.Stats do
		local v2 = innerScopes[k]

		if v2 then
			v2:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.Name = k
			innerScope.Info = stat

			if innerScope:Build((stat.Index - 1) * 0.05) then
				innerScopes[k] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end
end

function Stats.Start()
	v.Data = module:OnDataChangedDeferred({ "Level" }, Stats.UpdateAll, IsNotExpChange)
	v.Items = module:OnDataChangedDeferred({ "Items" }, Stats.UpdateResetButton, IsTokenChange)
	Stats.UpdateAll()
	Stats.UpdateResetButton()
end

function Stats.Stop()
	for _, v2 in innerScopes do
		v2.Instance:Destroy()
		v2:doCleanup()
	end

	table.clear(innerScopes)

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
end

function Stats.Init()
	module.Button:Create(stats.ResetStats.Main, "Small"):BindFunction("Click", function()
		local price = module.Shared.PlayerLevel.Price
		local balance = module.Shared.Economy.GetBalance(module.Data, price)

		if balance and balance.Total < price.Amount then
			module.Signal:FireSelf("Interface", "GemProducts", "Open", "PlayerLevel", "PlayerLevel", "PlayerLevel")
		else
			module.Signal:Fire("General", "PlayerLevel", "ResetStats")
		end
	end)
	Controller.FrameChanged:Connect(function(p: string?)
		if p == "Stats" then
			Stats.Start()
		else
			Stats.Stop()
		end
	end)
end

return Stats