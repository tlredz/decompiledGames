local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local View = require(script.Parent.Shop.View)
local teleport = module.Interface:WaitForChild("Frames"):WaitForChild("Teleport")
local scroll = teleport:WaitForChild("List"):WaitForChild("Scroll")
local teleport2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Teleport")
local v = {}
local innerScopes = {}
local frameName = nil
local v2 = {}
local flag = false
local Teleport = {}
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(0.5, 1.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = teleport2.World:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Info.Title.Text = self.Name
		self.Instance.Main.Thumb.Image = self.Info.Icon or "rbxassetid://117603036318289"
		self.Instance.Main.Info.Index.Text = self.Info.SpecialName or `Map {self.Info.Index}`
		self.SystemResources = {}

		for k, v3 in module.Shared.RemoteSystems.GetForMap(self.Name) do
			local clone = teleport2.System:Clone()
			clone.Name = v3.Name
			clone.LayoutOrder = k
			clone.Main.Icon.Image = v3.Icon

			if v3.OpenFrame and v3.Icon == "" then
				local child = module.Interface.Frames:FindFirstChild(v3.Kind)
				local header = child and child:FindFirstChild("Header")
				local icon = header and header:FindFirstChild("Icon")
				clone.Main.Icon.Image = not icon and "" or icon.Image
			end

			clone.Parent = self.Instance.Main.Info.Systems
			table.insert(self.SystemResources, View.Animate(clone.Main, k))
			local v4 = v3.Kind == "Stars" and "Star" or v3.Kind == "Dialog" and "Main Quest" or v3.Name
			View.Tooltip(clone.Main, v4, self.SystemResources)
			local v5 = v3
			View.Button(clone.Main, function()
				Teleport.OpenSystem(v5.Kind, v5.Name)
			end)
		end

		if self.Info.UnlockMethod then
			self.Instance.Main.LockedFrame.Method.Text = self.Info.UnlockMethod
		else
			self.Instance.Main.LockedFrame.Method.Text = "You need to unlock this first!"
		end

		module.Button:Create(self.Instance.Main.Info.Buttons.Teleport.Main, "Small"):BindFunction("Click", function()
			Teleport.Teleport(self.Name)
		end)
		module.Button:Create(self.Instance.Main.Info.Buttons.Favorite.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Maps", "Favorite", self.Name)
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

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local v3 = module.Data.Maps.List[self.Name]
		local v4 = typeof(v3) ~= "table" and {} or v3
		local ownsMap = module.Utils.PlayerStats.OwnsMap(self.Name, module.Data)
		self.Instance.Main.Info.Visible = ownsMap
		self.Instance.Main.LockedFrame.Visible = not ownsMap
		self.Instance.Main.Info.Buttons.Favorite.Main.UIGradient.Enabled = v4.Favorite == true
		self.Instance.LayoutOrder = self.Index
	end
})

function Teleport.Teleport(p: string)
	if flag then
		return
	end

	flag = true
	local success, result = pcall(module.Signal.Invoke, module.Signal, "General", "Maps", "Teleport", p)
	flag = false

	if success and result == true and module.Frame:IsFrameOpened(teleport) then
		module.Frame:Close(teleport)
	end
end

function Teleport.RefreshReturn()
	if not frameName then
		return
	end

	if module.Frame:IsFrameOpened(teleport) then
		frameName = nil
		table.clear(v2)

		if module.Cache:Get({ "PastUI" }) == teleport.Name then
			module.Frame:RemovePastUI()
		end
	else
		if module.Frame:IsFrameOpened(frameName) then
			module.Frame:SetPastUI(teleport)
			return
		end

		local v3 = module.Cache:Get({ "PastUI" })
		local flag2 = false

		for _, v4 in module.Frame:GetOpenedFrames() do
			if v2[v4] then
				flag2 = true
			elseif v3 and v2[v3] then
				v2[v4] = true
				flag2 = true
			end
		end

		if flag2 then
			return
		end

		frameName = nil
		table.clear(v2)

		if v3 == teleport.Name then
			module.Frame:RemovePastUI()
		end
	end
end

function Teleport.OpenSystem(p: string, p2: string)
	local v3 = module.Shared.RemoteSystems.Get(p, p2)

	if not v3 then
		return
	end

	if module.Data.Gamepasses["Remote Access"] == true then
		if not module.Utils.PlayerStats.OwnsMap(v3.MapName, module.Data) then
			return
		end

		if module.Frame:IsFrameOpened(teleport) then
			frameName = v3.FrameName
			table.clear(v2)
			v2[v3.FrameName] = true
			module.Frame:SetPastUI(teleport)
		end

		if v3.OpenFrame then
			module.Frame:Open(p)
		else
			module.Signal:FireSelf("Interface", p, "Start", p2)
		end
	else
		module.Signal:FireSelf("Interface", "Shop", "Open", "Gamepasses", "RemoteAccess")
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = "You need to buy Remote Access to use this!",
			Color = Color3.new(1, 1, 0)
		})
	end
end

function Teleport.Clear()
	for _, v3 in innerScopes do
		for _, v4 in v3.SystemResources or {} do
			View.Clean(v4)
		end

		v3.Instance:Destroy()
		v3:doCleanup()
	end

	table.clear(innerScopes)
end

function Teleport.UpdateAll()
	local v3 = {}
	local v4 = {}

	for k, v5 in module.Shared.Maps.List do
		if v5.Hidden then
			continue
		end

		local index = v5.Index or 0
		local v6 = module.Data.Maps.List[k]

		if typeof(v6) == "table" and v6.Favorite then
			index -= 999
		end

		table.insert(v3, {
			Name = k,
			Index = index
		})
	end

	table.sort(v3, function(a, b)
		return a.Index < b.Index
	end)

	for k, v5 in v3 do
		v4[v5.Name] = k
	end

	for k, info in module.Shared.Maps.List do
		if info.Hidden then
			continue
		end

		local v6 = v4[k] or 0
		local v7 = innerScopes[k]

		if v7 then
			v7.Index = v6
			v7:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.Name = k
			innerScope.Info = info
			innerScope.Index = v6

			if innerScope:Build(v6 * 0.05) then
				innerScopes[k] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end
end

function Teleport.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	Teleport.Clear()
end

function Teleport.Start()
	v.Maps = module:OnDataChanged({ "Maps" }, Teleport.UpdateAll)
	Teleport.UpdateAll()
end

function Teleport.Init()
	module.Frame:OnFrameClosed(teleport, Teleport.Stop)
	module.Frame:OnFrameOpened(teleport, Teleport.Start)
	module.Frame.FramesChangedSignal:Connect(function()
		task.defer(Teleport.RefreshReturn)
	end)
end

return Teleport