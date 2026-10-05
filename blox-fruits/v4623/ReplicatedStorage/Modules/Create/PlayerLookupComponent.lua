local VirtualListComponent = require(game.ReplicatedStorage.Modules.Create.VirtualListComponent)
local FriendFinder = require(game.ReplicatedStorage.FriendFinder)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local GetUserInfo = require(game.ReplicatedStorage.Modules.Player.GetUserInfo)
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local screenGui = script:FindFirstChildOfClass("ScreenGui")
local modal = screenGui.Modal
local template = modal.ScrollingFrame.Template
local categoryNavigator = modal.CategoryNavigator
local footer = modal.Footer
local title = modal.Title
local description = modal.Description
local nameTextBox = modal.SearchBar.NameTextBox
local overlay = modal.Overlay
local localPlayer = game.Players.LocalPlayer
local v = {
	Server = {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.494, 0, 0.485, 0)
	},
	Global = {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.494, 0, 1, 0)
	}
}
local v2 = nil
local entries = {}
template.Visible = false
screenGui.Enabled = false
return function(data)
	if v2 then
		v2:Destroy()
		v2 = nil
	end

	local v4 = nil
	local v5 = {
		Modal = modal,
		_Category = "Server",
		_SearchTerm = nil,
		_Data = {},
		_InternalPlayerData = {},
		_Maid = Trove.new(),
		_Connected = false,
		_Destroyed = false,
		_Debounced = false,
		_AllowSelf = false
	}

	if screenGui.Parent == script then
		for _ = 1, modal.ScrollingFrame.AbsoluteSize.Y / template.AbsoluteSize.Y + 2 do
			local clone = template:Clone()
			clone.Visible = false
			local rbx = clone
			table.insert(assert(entries), {
				Rbx = clone,
				Select = function(p)
					return clone
				end,
				Render = function(p, player)
					if player == nil then
						rbx.Visible = false
						return
					end

					rbx.FriendIcon.Visible = player.IsFriend

					if player.DisplayName then
						rbx.Username.Text = player.DisplayName
					else
						rbx.Username.Text = player.Name
					end

					rbx.DisplayName.Text = `@{player.Name}`
					rbx.Icon.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
					rbx.DisplayName.TextColor3 = template.DisplayName.TextColor3

					if v2 and v2._AdjustEntryCallback and v2._Category == "Server" then
						task.spawn(pcall, v2._AdjustEntryCallback, rbx, player, v2)
					end

					rbx.Visible = true
				end
			})
		end

		screenGui.Enabled = false
		screenGui.Parent = localPlayer.PlayerGui
	end

	footer.Visible = false

	for i = 1, #entries do
		local v6 = i
		v5._Maid:Add(entries[i].Rbx.MouseButton1Click:Connect(function()
			local _RenderData = entries[v6]._RenderData

			if data.MouseButton1Click and not v5._Debounced and _RenderData then
				data.MouseButton1Click(v5, _RenderData)
			elseif not _RenderData then
				print("Why don't we have render data", entries[v6])
			end
		end))
	end

	local virtualListComponent = VirtualListComponent({
		Entries = entries,
		TryUpdate = function(p)
			local v7 = {}

			for _, v8 in pairs(v5._Data) do
				if v5._SearchTerm ~= nil then
					local v9 = false
					local v10 = false
					local v11 = false
					local v12 = v8
					pcall(function()
						v9 = v12.Name:lower():match(v5._SearchTerm) ~= nil
						v10 = tostring(v12.UserId):lower():match(v5._SearchTerm) ~= nil

						if v12.DisplayName then
							v11 = v12.DisplayName:lower():match(v5._SearchTerm) ~= nil
						end
					end)

					if not (v9 or v10 or v11) then
						continue
					end
				end

				if not (data.Filter and data.Filter(v5, v8)) then
					table.insert(v7, v8)
				end
			end

			p.Data = v7
			return true
		end
	}, modal.ScrollingFrame)
	v5._Maid:Add(function()
		screenGui.Enabled = false
		nameTextBox.Text = ""
		virtualListComponent:Destroy()
	end)

	function v5:Reflect()
		if self._Destroyed then
			return
		end

		virtualListComponent:UpdateRender(self._SearchTerm and 0.2 or nil)
	end

	function v5:SetAllowSelf(allowSelf: boolean)
		self._AllowSelf = allowSelf
		return v5
	end

	function v5:SetAdjustEntryCallback(adjustEntryCallback)
		self._AdjustEntryCallback = adjustEntryCallback
		return v5
	end

	function v5:_UpdateData(items)
		for _, item in pairs(items) do
			assert(item.UserId, item)
			assert(item.Name, item)

			if not ((item.UserId ~= localPlayer.UserId or self._AllowSelf ~= false) and item.Name ~= "Account Deleted") then
				continue
			end

			local v7 = nil

			for i = 1, #self._Data do
				if self._Data[i].UserId ~= item.UserId then
					continue
				end

				v7 = self._Data[i]
				break
			end

			local isFriend

			if item.IsFriend then
				isFriend = true
			elseif v7 then
				isFriend = v7.IsFriend == true
			else
				isFriend = false
			end

			if v7 then
				v7.IsFriend = isFriend
			else
				table.insert(self._Data, {
					Name = item.Name,
					UserId = item.UserId,
					DisplayName = item.DisplayName,
					IsFriend = isFriend
				})
			end
		end

		self:Reflect()
	end

	function v5:Debounce(p2)
		if v4 then
			v4:Destroy()
		end

		overlay.Visible = true
		v4 = self._Maid:Extend()
		self._Debounced = true
		assert(v4):Add(function()
			v4 = nil
			overlay.Visible = false
			overlay.Loading.ImageLabel.Rotation = 0
			overlay.Loading.TextLabel.Text = ""

			if self._Maid._cleaning == false then
				self._Debounced = false
			end
		end)
		local v7 = 0
		local total = 1

		if p2.Image then
			ImageUtil.applySprite(p2.Image, {
				Icon = overlay.Loading.ImageLabel
			})
		end

		local maid = v4
		local RunService = game:GetService("RunService")
		maid:Add(RunService.Heartbeat:Connect(function(dt: number)
			if total >= 0.33 then
				total = 0
				overlay.Loading.TextLabel.Text = (p2.Text or "") .. string.rep(".", v7)
				v7 = v7 + 1 > 3 and 1 or v7 + 1
			end

			total += dt
		end))
		return function()
			if v4 then
				v4:Destroy()
			end
		end
	end

	local v7 = nil

	function v5:ChangeCategory(category: string)
		assert(category == "Global" or category == "Server")

		if v7 then
			v7:Cancel()
			v7 = nil
		end

		nameTextBox.PlaceholderText = "Search"
		local anchorPoint = v[category].AnchorPoint
		local position = v[category].Position
		local color = Color3.fromRGB(255, 255, 255)
		local color2 = Color3.fromRGB(122, 122, 122)

		if self._Connected then
			local TweenService = game:GetService("TweenService")
			v7 = TweenService:Create(categoryNavigator.SelectedOverlay, TweenInfo.new(0.1), {
				AnchorPoint = anchorPoint,
				Position = position
			})
			assert(v7):Play()
		else
			categoryNavigator.SelectedOverlay.AnchorPoint = anchorPoint
			categoryNavigator.SelectedOverlay.Position = position
		end

		local textLabel = categoryNavigator.ServerTab.TextLabel
		local textColor

		if category == "Server" then
			textColor = color
		else
			textColor = color2
		end

		textLabel.TextColor3 = textColor
		local textLabel2 = categoryNavigator.GlobalTab.TextLabel

		if category == "Global" then
			color2 = color
		end

		textLabel2.TextColor3 = color2

		if self._Connected then
			if self._Category ~= category then
				self._Category = category
				self:Reflect()

				if data.CategoryChanged then
					data.CategoryChanged(self)
				end
			end
		elseif self._Category ~= category then
			self._Category = category
		end

		return v5
	end

	function v5.EnableCategory(p, options)
		categoryNavigator.ServerTab.Visible = table.find(options or {}, "Server") ~= nil
		categoryNavigator.GlobalTab.Visible = table.find(options or {}, "Global") ~= nil
		return p
	end

	function v5.ChangeTitle(p, text: string)
		title.TextLabel.Text = text
		title.TextLabel.TextLabel.Text = text
		return p
	end

	function v5.ChangeDescription(p, text: string)
		description.Text = text
		return p
	end

	function v5:Connect()
		if self._Connected then
			return self
		end

		self._Connected = true

		local function playerAdded(player)
			v5:_UpdateData({
				{
					UserId = player.UserId,
					Name = player.Name,
					DisplayName = player.DisplayName,
					IsFriend = player.UserId < 0 or nil
				}
			})
		end

		self._Maid:Add(game.Players.PlayerAdded:Connect(playerAdded))
		self._Maid:Add(game.Players.PlayerRemoving:Connect(function(player)
			local flag = false

			for i = #self._Data, 1, -1 do
				if self._Data[i] ~= player.UserId then
					continue
				end

				table.remove(self._Data, i)
				flag = true
				break
			end

			if flag then
				self:Reflect()
			end
		end))

		for _, v8 in pairs(game.Players:GetPlayers()) do
			task.spawn(playerAdded, v8)
		end

		self._Maid:AddPromise(FriendFinder:GetFriends():andThen(function(items)
			local v8 = {}

			for _, item in pairs(items) do
				table.insert(v8, {
					IsFriend = true,
					UserId = item.UserId,
					DisplayName = item.DisplayName,
					Name = item.Name
				})
			end

			self:_UpdateData(v8)
		end))
		self._Maid:Add(modal.Title.Close.MouseButton1Click:Connect(function()
			self:Destroy(true)
		end))
		self._Maid:Add(categoryNavigator.ServerTab.MouseButton1Click:Connect(function()
			self:ChangeCategory("Server")
		end))
		self._Maid:Add(categoryNavigator.GlobalTab.MouseButton1Click:Connect(function()
			self:ChangeCategory("Global")
		end))
		local count = 0
		self._Maid:Add(nameTextBox.FocusLost:Connect(function(flag: boolean, _)
			if flag and self._Category == "Global" and self._SearchTerm then
				local v8 = nil
				self._Maid:AddPromise(GetUserInfo:GetUserInfo(self._SearchTerm):andThen(function(_)
					v8 = self:Debounce({
						Text = `Searching for "{self._SearchTerm}"`
					})
					local v9 = GetUserInfo:FromUsernameAsync(self._SearchTerm)

					if v9 and v9.UserId ~= 0 then
						self:_UpdateData({
							{
								Name = v9.Name,
								UserId = v9.UserId,
								DisplayName = v9.DisplayName,
								IsFriend = nil
							}
						})
						return
					end

					nameTextBox.PlaceholderText = "No user found"
					nameTextBox.Text = ""
					count = 0
					print("User not found", v9)
				end):catch(function(p)
					print(p)
					print("Something broke")
					nameTextBox.PlaceholderText = "No user found"
					nameTextBox.Text = ""
					count = 0
				end):finally(function()
					v8()
				end))
			end
		end))
		self._Maid:Add(nameTextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if count == 2 then
				nameTextBox.PlaceholderText = "Search"
				count = 0
			else
				count += 1
			end

			local text = nil

			if nameTextBox.Text ~= "" then
				if nameTextBox.Text:lower() ~= self._SearchTerm then
					text = nameTextBox.Text:lower()
				end
			end

			if text ~= self._SearchTerm then
				self._SearchTerm = text
				self:Reflect()
			end
		end))

		local function controllerAction(_: string, p, p2)
			if p ~= Enum.UserInputState.End or p2.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return Enum.ContextActionResult.Pass
			end

			GuiService.SelectedObject = modal.Title.Close
			return Enum.ContextActionResult.Sink
		end

		ContextActionService:BindActionAtPriority(
			"PlayerLookupEscape",
			controllerAction,
			false,
			3,
			Enum.KeyCode.ButtonB
		)
		self._Maid:Add(function()
			ContextActionService:UnbindAction("PlayerLookupEscape")
		end)
		virtualListComponent:Connect()
		screenGui.Enabled = true
		return self
	end

	function v5:Destroy(flag: boolean?)
		if not self._Destroyed then
			if data.Destroyed then
				task.spawn(data.Destroyed, self, flag == true)
			end

			self._Destroyed = true
			self._Maid:Destroy()
		end
	end

	v2 = v5
	return v5
end