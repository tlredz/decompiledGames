local module = require("@game/ReplicatedStorage/Omni")
local uDim = UDim2.fromScale(-0.05, 0)
local uDim2 = UDim2.fromScale(0.95, 0)
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local SidePanels = require(script.Parent.SidePanels)
local quests = module.Interface:WaitForChild("HUD"):WaitForChild("Quests")
local list = quests:WaitForChild("List")
local scroll = list:WaitForChild("Scroll")
local arrow = quests:WaitForChild("Arrow")
local quests2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Quests")
local v = false
local v2 = false
local flag = false
local count = 0
local v3 = nil
local v4 = {}
local v5 = {}
local value = scope:Value(uDim2)
local spring = scope:Spring(value, 10, 1)
local value2 = scope:Value(0)
local spring2 = scope:Spring(value2, 10, 1)
local Quests = {}
local v6 = {
	Build = function(self, duration: number)
		local v7 = count
		self.NeededText = module.Utils.Number:Format(self.Info.Amount)
		self.Progress = self:Value(0)
		self.ProgressSpring = self:Spring(self.Progress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(1.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = quests2.Hud:Clone()
		self.Instance.Name = self.Index
		self.Instance.Main.Title.Text = self.Info.Title
		self.Instance.Main.Info.Desc.Text = self.Info.Description
		self.Instance.LayoutOrder = self.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.ProgressSpring):onBind(function()
			local progressSpring = self.peek(self.ProgressSpring)

			if not progressSpring then
				return
			end

			local rounded = module.Utils.Number:Round(self.Info.Amount * progressSpring)
			local formatted = module.Utils.Number:Format(rounded)
			self.Instance.Main.Info.Bar.Value.Text = formatted .. " / " .. self.NeededText

			if progressSpring == 1 then
				self.Instance.Main.Info.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0)
				})
				return
			elseif progressSpring == 0 then
				self.Instance.Main.Info.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
				return
			end

			local numberSequenceKeypoints = {}
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(progressSpring, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, progressSpring + 0.1), 1))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
			self.Instance.Main.Info.Bar.Slider.UIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
		end)

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) or not v or count ~= v7 then
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
	Update = function(data)
		local v7 = data.Amount / data.Info.Amount
		data.Instance.Main.Completed.Visible = v7 == 1
		data.Instance.Main.CompletedPoint.Visible = v7 == 1
		data.Instance.Main.NormalPoint.Visible = v7 ~= 1
		data.Progress:set(v7)
	end
}
local scope2 = fusion.scoped(fusion, v6)

local function CanOpen()
	if flag then
		return false
	end

	if module.Data.Quests.Pinned then
		local pinned = module.Data.Quests.Pinned
		local v7 = module.Shared.Quests.List[pinned.Class]
		local v8 = module.Data.Quests.List[pinned.Class]
		return v7 ~= nil and v8 ~= nil and v7.List[pinned.Name] ~= nil and v8.List[pinned.Name] ~= nil
	else
		module.Frame:Open("Quests")
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = "You need to pin a quest to use this!",
			Color = Color3.new(1, 1, 0)
		})
		return false
	end
end

local function Open()
	count += 1
	v = true
	list.Visible = true
	v4.Data = module:OnDataChangedDeferred({ "Quests" }, Quests.Update)
	Quests.Update()
	value:set(uDim)
	value2:set(180)
end

local function Close()
	v = false
	count += 1

	if v4.Data then
		v4.Data:Disconnect()
		v4.Data = nil
	end

	for _, v7 in v5 do
		v7.Position:set(UDim2.fromScale(1.5, 0.5))
	end

	value:set(uDim2)
	value2:set(0)
	local v7 = os.clock() + 3

	while true do
		task.wait()

		if flag then
			break
		end

		local v8 = math.abs(fusion.peek(spring).X.Scale - uDim2.X.Scale) * quests.AbsoluteSize.X
		local v9 = math.abs(fusion.peek(spring2) - 0)

		if not (v8 <= 1 and v9 <= 1 or v7 <= os.clock()) then
			continue
		end

		list.Visible = false
		spring:setPosition(uDim2)
		spring:setVelocity(UDim2.fromScale(0, 0))
		spring2:setPosition(0)
		spring2:setVelocity(0)
		Quests.Clear()
		break
	end
end

function Quests.Clear()
	for _, v7 in v5 do
		v7.Instance:Destroy()
		v7:doCleanup()
	end

	table.clear(v5)
end

function Quests.Update()
	if not v or flag then
		return
	end

	local pinned = module.Data.Quests.Pinned

	if not pinned then
		Quests.Stop()
		return
	end

	local v7 = module.Shared.Quests.List[pinned.Class]
	local v8 = module.Data.Quests.List[pinned.Class]

	if not (v7 and v8) then
		Quests.Stop()
		return
	end

	local v9 = v7.List[pinned.Name]
	local v10 = v8.List[pinned.Name]

	if not (v9 and v10) then
		Quests.Stop()
		return
	end

	local v11 = {}

	for k, mission in v9.Missions do
		local amount = v10.Missions[k] or 0
		local v13 = pinned.Name .. k
		local v14 = v5[v13]

		if v14 then
			v14.Amount = amount
			v14:Update()
		else
			local innerScope = scope2:innerScope()
			innerScope.Info = mission
			innerScope.Amount = amount
			innerScope.Index = k

			if innerScope:Build((k - 1) * 0.05) then
				v5[v13] = innerScope
			else
				innerScope:doCleanup()
				continue
			end
		end

		v11[v13] = true
	end

	for k, v12 in v5 do
		if v11[k] then
			continue
		end

		v12.Instance:Destroy()
		v12:doCleanup()
		v5[k] = nil
	end
end

function Quests.Start()
	SidePanels.Open("Quests")
end

function Quests.Stop()
	SidePanels.Close("Quests")
end

function Quests.Toggle()
	SidePanels.Toggle("Quests")
end

function Quests.Destroy()
	if flag then
		return
	end

	flag = true
	v = false
	count += 1
	SidePanels.Unregister("Quests")

	for _, connection in v4 do
		connection:Disconnect()
	end

	table.clear(v4)
	list.Visible = false

	if v3 then
		v3:UnbindFunction("Click")
	end

	Quests.Clear()
	scope:doCleanup()
end

function Quests.Init()
	if v2 or flag then
		return
	end

	v2 = true
	list.Visible = false
	SidePanels.Register("Quests", {
		Arrow = arrow,
		CanOpen = CanOpen,
		Open = Open,
		Close = Close
	})
	v3 = module.Button:Create(arrow.Main, "Small")
	v3:BindFunction("Click", Quests.Toggle)
	scope:Hydrate(arrow)({
		Position = spring,
		Rotation = spring2
	})
	v4.Destroying = quests.Destroying:Connect(Quests.Destroy)
end

return Quests