local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local accessoryLoadouts = module.Interface:WaitForChild("Frames"):WaitForChild("AccessoryLoadouts")
local scroll = accessoryLoadouts:WaitForChild("List"):WaitForChild("Scroll")
local accessoryLoadouts2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("AccessoryLoadouts")
local v = {}
local v2 = {}
local AccessoryLoadouts = {}
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = accessoryLoadouts2.Team:Clone()
		self.Instance.Name = self.Index
		self.Instance.Main.Title.Text = `Loadout #{self.Index}`
		module.Button:Create(self.Instance.Main.Buttons.Save.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Accessories", "SaveLoadout", self.Index)
		end)
		module.Button:Create(self.Instance.Main.Buttons.Clear.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Accessories", "ClearLoadout", self.Index)
		end)
		module.Button:Create(self.Instance.Main.Buttons.Load.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Accessories", "LoadLoadout", self.Index)
		end)
		self.Instance.LayoutOrder = self.Index
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
		local v3 = module.Data.Accessories.Loadouts[self.Index] or {}

		for childName, v4 in v3 do
			local v5 = module.Data.Accessories.List[v4]

			if not v5 then
				continue
			end

			local v6 = module.Shared.Accessories.List[v5.Name]

			if not v6 then
				continue
			end

			local clone = self.Instance.Main.Slots:FindFirstChild(childName)

			if not clone then
				clone = accessoryLoadouts2.Slot:Clone()
				clone.Name = childName
				clone.Parent = self.Instance.Main.Slots
				clone.Visible = true
			end

			if not clone:GetAttribute("Loaded") then
				clone:SetAttribute("Loaded", true)
				local v7 = module.Button:Create(clone.Main, "Default")
				v7:BindFunction("Click", function()
					local currentID = clone:GetAttribute("CurrentID")

					if not currentID then
						return
					end

					local v8 = module.Data.Accessories.List[currentID]

					if not v8 then
						return
					end

					local v9 = module.Libs.NeoHover.GetByIdentifier("Accessories")

					if v9 then
						v9:Click(clone, {
							IsFake = true,
							Data = v8
						})
					end
				end)
				v7:BindOnEnter("Hover", function()
					local currentID = clone:GetAttribute("CurrentID")

					if not currentID then
						return
					end

					local v8 = module.Data.Accessories.List[currentID]

					if not v8 then
						return
					end

					local v9 = module.Libs.NeoHover.GetByIdentifier("Accessories")

					if v9 then
						v9:Open(clone, {
							IsFake = true,
							Data = v8
						})
					end
				end)
				v7:BindOnLeave("Hover", function()
					local v8 = module.Libs.NeoHover.GetByIdentifier("Accessories")

					if v8 then
						v8:Close(clone)
					end
				end)
			end

			if clone:GetAttribute("CurrentID") ~= v4 then
				clone:SetAttribute("CurrentID", v4)
			end

			clone.Main.Viewport.Image = v6.Icon
			local locked = v5.Locked == true
			local visible = module.Data.Accessories.Equipped[childName] == v4
			clone.Main.InfoList.LockedIcon.Visible = locked
			clone.Main.InfoList.EquippedIcon.Visible = visible
			clone.Main.Title.Text = v5.Name
			clone.Main.UIGradient:SetAttribute("Rarity", module.Shared.Accessories.GetRarity(v5))
		end

		for _, child in self.Instance.Main.Slots:GetChildren() do
			if not child:GetAttribute("Loaded") or v3[child.Name] then
				continue
			end

			child:Destroy()
		end
	end
})

function AccessoryLoadouts.Clear()
	for _, v3 in v do
		v3.Instance:Destroy()
		v3:doCleanup()
	end

	table.clear(v)
end

function AccessoryLoadouts.UpdateAll()
	local v3 = #module.Data.Accessories.Loadouts + 1

	for i = 1, v3 do
		local v4 = v[i]

		if v4 then
			v4:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.Index = i

			if innerScope:Build((i - 1) * 0.05) then
				v[i] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end

	for k, v4 in v do
		if not (v3 < k) then
			continue
		end

		v4.Instance:Destroy()
		v4:doCleanup()
		v[k] = nil
	end
end

function AccessoryLoadouts:Open()
	if self then
		module.Frame:SetPastUI(self)
	end

	module.Frame:Open(accessoryLoadouts)
end

function AccessoryLoadouts.Stop()
	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
	AccessoryLoadouts.Clear()
end

function AccessoryLoadouts.Start()
	v2.Data = module:OnDataChanged({ "Accessories" }, AccessoryLoadouts.UpdateAll)
	AccessoryLoadouts.UpdateAll()
end

function AccessoryLoadouts.Init()
	module.Frame:OnFrameClosed(accessoryLoadouts, AccessoryLoadouts.Stop)
	module.Frame:OnFrameOpened(accessoryLoadouts, AccessoryLoadouts.Start)
end

return AccessoryLoadouts