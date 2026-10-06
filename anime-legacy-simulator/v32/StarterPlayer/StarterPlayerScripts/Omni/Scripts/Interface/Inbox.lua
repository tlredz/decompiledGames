local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 255, 100)
local fusion = module.Libs.Fusion
local inbox = module.Interface:WaitForChild("Frames"):WaitForChild("Inbox")
local buttons = inbox:WaitForChild("Buttons")
local scroll = inbox:WaitForChild("List"):WaitForChild("Scroll")
local message = inbox:WaitForChild("Message")
local buttons2 = message:WaitForChild("Buttons")
local rewards = message:WaitForChild("Main"):WaitForChild("Rewards")
local description = message:WaitForChild("Main"):WaitForChild("Description")
local inbox2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inbox")
local v = {}
local v2 = {}
local v3 = {}
local v4 = nil
local Inbox = {}
local v5 = {
	Build = function(self, duration: number)
		self.Transparency = self:Value(0)
		self.TransparencySpring = self:Spring(self.Transparency, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = inbox2.Message:Clone()
		self.Instance.Name = self.ID
		self.Instance.Main.Title.Text = self.Data.Title
		self.Instance.Main.Author.Text = `by @{self.Data.UserInfo.UserName} ({self.Data.UserInfo.NickName})`
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Inbox.SetMessage(self.ID)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance)({
			GroupTransparency = self.TransparencySpring
		})
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
		local v6 = v4 == self.ID
		local serverTimeNow = workspace:GetServerTimeNow()
		local v7 = self.Data.Claimed and color or color2
		self.Instance.LayoutOrder = self.Index
		self.Instance.Main.ImageColor3 = v7
		self.Instance.Main.Title.TextColor3 = v7
		self.Instance.Main.Exclamation.Visible = self.Data.Claimed ~= true
		self.Instance.Main.Time.Text = module.Utils.Number:Time2(serverTimeNow - self.Data.Time) .. " ago"
		self.Transparency:set(v6 and 0 or 0.4)
	end
}
local scope = fusion.scoped(fusion, v5)
local scope2 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = inbox2.Reward:Clone()
		self.Instance.Name = self.ID
		self.Instance.Main.Amount.Text = module.Utils.Number:Format(self.Data.Amount) .. "x"
		self.Instance.Main.UIGradient:SetAttribute("Rarity", self.Info.Rarity or "Common")

		if self.Data.Type == "Gamepass" and self.Info.Color then
			self.Instance.Main.UIGradient:SetAttribute("Rarity", nil)
			self.Instance.Main.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), self.Info.Color)
		end

		if self.Data.Type == "Fighter" then
			self.Instance.Main.Icon.Visible = false
			self.Instance.Main.Viewport.Visible = true
			module.Utils.Camera.ViewportCharacter({
				Viewport = self.Instance.Main.Viewport,
				Animation = module.Utils.Characters.GetCharacterAnimation(self.Data.Name, "Idle"),
				Character = module.Utils.Characters.Get({
					Name = self.Data.Name,
					Shiny = self.Data.Shiny,
					RemoveHumanoidStates = true
				})
			})
		else
			self.Instance.Main.Icon.Visible = true
			self.Instance.Main.Viewport.Visible = false
			self.Instance.Main.Icon.Image = self.Info.Icon or ""

			if self.Data.Type == "Gamepass" and typeof(self.Info.ID) == "number" and self.Info.ID > 0 then
				local instance = self.Instance
				local ID = self.Info.ID
				task.spawn(function()
					local success, result = pcall(function()
						return module.Services.MarketplaceService:GetProductInfoAsync(ID, Enum.InfoType.GamePass)
					end)

					if success and result and result.IconImageAssetId and instance.Parent then
						instance.Main.Icon.Image = "rbxassetid://" .. result.IconImageAssetId
					end
				end)
			end
		end

		local hover = self.Hover or module.Libs.NeoHover.GetByIdentifier("Tooltip")
		local v6

		if self.Hover then
			v6 = {
				IsFake = true,
				Name = self.Data.Name,
				Amount = self.Data.Amount,
				Data = self.Data
			}
		else
			v6 = {
				Text = self.Data.Name .. " x" .. self.Data.Amount
			}
		end

		table.insert(self, function()
			if hover and hover.Element == self.Instance then
				hover:Close(nil, true)
			end
		end)
		local v7 = module.Button:Create(self.Instance.Main, "Small")
		v7:BindFunction("Click", function()
			if hover then
				hover:Click(self.Instance, v6)
			end
		end)
		v7:BindOnEnter("Hover", function()
			if hover then
				hover:Open(self.Instance, v6)
			end
		end)
		v7:BindOnLeave("Hover", function()
			if hover then
				hover:Close(self.Instance)
			end
		end)
		self.Instance.Parent = rewards
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

function Inbox.Clear()
	for _, v6 in v3 do
		v6.Instance:Destroy()
		v6:doCleanup()
	end

	table.clear(v3)

	for _, v6 in v2 do
		v6.Instance:Destroy()
		v6:doCleanup()
	end

	table.clear(v2)
end

function Inbox.UpdateAll()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v6 = {}
	local v7 = {}

	for k, v8 in module.Data.Inbox.List do
		if not v8.Deleted then
			table.insert(v6, {
				ID = k,
				Time = v8.Time
			})
		end
	end

	table.sort(v6, function(a, b)
		return a.Time > b.Time
	end)

	for k, v8 in v6 do
		v7[v8.ID] = k
	end

	if v4 and not v7[v4] then
		Inbox.SetMessage()
		return
	end

	for k, v8 in module.Data.Inbox.List do
		local v9 = v7[k]
		local v10 = v3[k]

		if v9 then
			if v10 then
				v10.Index = v9
				v10.Data = v8
				v10:Update(v8)
			else
				local innerScope = scope:innerScope()
				innerScope.ID = k
				innerScope.Index = v9
				innerScope.Data = v8

				if innerScope:Build((v9 - 1) * 0.05) then
					v3[k] = innerScope
				else
					innerScope:doCleanup()
				end
			end
		elseif v10 then
			v10.Instance:Destroy()
			v10:doCleanup()
			v3[k] = nil
		end
	end

	local v8 = v4 and module.Data.Inbox.List[v4]

	if v8 then
		for _, label in description:GetChildren() do
			if not (label:IsA("TextLabel") and (label.LayoutOrder > #v8.Messages or label:GetAttribute("ID") ~= v4)) then
				continue
			end

			label:Destroy()
		end

		for k, message2 in v8.Messages do
			local formatted = `Message_{k}`

			if description:FindFirstChild(formatted) then
				continue
			end

			local clone = inbox2.Description:Clone()
			clone.Name = formatted
			clone.LayoutOrder = k
			clone:SetAttribute("ID", v4)
			clone.Parent = description
			clone.Visible = true
			module.Utils.String:Typewrite({
				Label = clone,
				Text = message2,
				Speed = 2
			})
		end

		local v9 = {}

		for k, reward in v8.Rewards do
			local ID = v4 .. ":" .. k
			local info

			if reward.Type == "Gamepass" then
				info = module.Shared.Gamepasses[reward.Name]
			elseif reward.Type == "Banner" then
				info = module.Shared.ProfileBanners.List[reward.Name]
			else
				info = module.Utils.Info:Get(reward.Type, reward.Name)
			end

			if not info then
				continue
			end

			if not v2[ID] then
				local innerScope = scope2:innerScope()
				innerScope.ID = ID
				innerScope.Hover = module.Libs.NeoHover.GetByIdentifier(reward.Type) or module.Libs.NeoHover.GetByIdentifier(reward.Type .. "s") or module.Libs.NeoHover.GetByIdentifier(string.sub(
					reward.Type,
					1,
					#reward.Type - 1
				) .. "ies")
				innerScope.Info = info
				innerScope.Data = reward

				if innerScope:Build((k - 1) * 0.05) then
					v2[ID] = innerScope
				else
					innerScope:doCleanup()
					continue
				end
			end

			v9[ID] = true
		end

		for k, v10 in v2 do
			if v9[k] then
				continue
			end

			v10.Instance:Destroy()
			v10:doCleanup()
			v2[k] = nil
		end

		message.Time.Text = module.Utils.Number:Time2(serverTimeNow - v8.Time) .. " ago"
		message.Main.Visible = true
	else
		for _, label in description:GetChildren() do
			if label:IsA("TextLabel") then
				label:Destroy()
			end
		end

		for k, v9 in v2 do
			v9.Instance:Destroy()
			v9:doCleanup()
			v2[k] = nil
		end

		message.Main.Visible = false
	end
end

function Inbox.UpdateTimes()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v6 in v3 do
		v6.Instance.Main.Time.Text = module.Utils.Number:Time2(serverTimeNow - v6.Data.Time) .. " ago"
	end

	local v6 = v4 and module.Data.Inbox.List[v4]

	if v6 then
		message.Time.Text = module.Utils.Number:Time2(serverTimeNow - v6.Time) .. " ago"
	end
end

function Inbox.SetMessage(p: string?)
	local v6 = module.Data.Inbox.List[p]

	if v4 == p or not v6 then
		module.Utils.String:Typewrite({
			Label = message.Title,
			Text = "..."
		})
		module.Utils.String:Typewrite({
			Label = message.Time,
			Text = "..."
		})
		module.Utils.String:Typewrite({
			Label = message.Author,
			Text = "..."
		})
		v4 = nil
	else
		module.Utils.String:Typewrite({
			Label = message.Title,
			Text = v6.Title
		})
		module.Utils.String:Typewrite({
			Label = message.Author,
			Text = `by @{v6.UserInfo.UserName} ({v6.UserInfo.NickName})`
		})
		v4 = p
	end

	Inbox.UpdateAll()
end

function Inbox.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	Inbox.Clear()
end

function Inbox.Start()
	v.Inbox = module:OnDataChanged({ "Inbox" }, Inbox.UpdateAll)
	v.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = Inbox.UpdateTimes
	})
	Inbox.SetMessage()
end

function Inbox.Init()
	module.Button:Create(buttons.ClaimAll.Main, "Small"):BindFunction("Click", function()
		module.Signal:Fire("General", "Inbox", "ClaimAll")
	end)
	module.Button:Create(buttons.DeleteAll.Main, "Small"):BindFunction("Click", function()
		local count = 0

		for _, v6 in module.Data.Inbox.List do
			if v6.Deleted or not v6.Claimed then
				continue
			end

			count += 1
		end

		if count == 0 then
			module.Signal:Fire("General", "Inbox", "DeleteAll")
		else
			module.Signal:FireSelf("Interface", "Confirmation", "Start", {
				Title = "Delete All",
				Description = `Delete {count} claimed {count == 1 and "message" or "messages"}? This cannot be undone.`,
				ConfirmText = "Delete",
				CancelText = "Cancel",
				Callback = function(p)
					if not p then
						return
					end

					module.Signal:Fire("General", "Inbox", "DeleteAll")
				end
			})
		end
	end)
	module.Button:Create(buttons2.Claim.Main, "Small"):BindFunction("Click", function()
		if not v4 then
			return
		end

		module.Signal:Fire("General", "Inbox", "Claim", v4)
	end)
	module.Button:Create(buttons2.Delete.Main, "Small"):BindFunction("Click", function()
		if not v4 then
			return
		end

		local v6 = v4
		local v7 = module.Data.Inbox.List[v6]

		if v7 and v7.Claimed then
			module.Signal:FireSelf("Interface", "Confirmation", "Start", {
				Title = "Delete",
				Description = `Delete "{v7.Title}"? This cannot be undone.`,
				ConfirmText = "Delete",
				CancelText = "Cancel",
				Callback = function(p)
					if not p then
						return
					end

					module.Signal:Fire("General", "Inbox", "Delete", v6)
				end
			})
		else
			module.Signal:Fire("General", "Inbox", "Delete", v6)
		end
	end)
	module.Frame:OnFrameClosed(inbox, Inbox.Stop)
	module.Frame:OnFrameOpened(inbox, Inbox.Start)
end

return Inbox