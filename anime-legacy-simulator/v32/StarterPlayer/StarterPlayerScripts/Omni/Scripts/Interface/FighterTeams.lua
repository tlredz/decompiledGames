local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local fighterTeams = module.Interface:WaitForChild("Frames"):WaitForChild("FighterTeams")
local scroll = fighterTeams:WaitForChild("List"):WaitForChild("Scroll")
local fighterTeams2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("FighterTeams")
local v = {}
local v2 = {}
local FighterTeams = {}
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = fighterTeams2.Team:Clone()
		self.Instance.Name = self.Index
		self.Instance.Main.Title.Text = `Team #{self.Index}`
		module.Button:Create(self.Instance.Main.Buttons.Save.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Fighters", "SaveTeam", self.Index)
		end)
		module.Button:Create(self.Instance.Main.Buttons.Clear.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Fighters", "ClearTeam", self.Index)
		end)
		module.Button:Create(self.Instance.Main.Buttons.Load.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Fighters", "LoadTeam", self.Index)
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
		local v3 = module.Data.Fighters.Teams[self.Index] or {}

		for childName in v3 do
			local v4 = module.Data.Fighters.List[childName]

			if not v4 then
				continue
			end

			local v5 = module.Shared.Fighters.List[v4.Name]

			if not v5 then
				continue
			end

			local clone = self.Instance.Main.Slots:FindFirstChild(childName)

			if not clone then
				clone = fighterTeams2.Slot:Clone()
				clone.Name = childName
				clone.Parent = self.Instance.Main.Slots
				clone.Visible = true
			end

			if not clone:GetAttribute("Loaded") then
				clone:SetAttribute("Loaded", true)
				local v6 = module.Button:Create(clone.Main, "Default")
				v6:BindFunction("Click", function()
					local currentID = clone:GetAttribute("CurrentID")

					if not currentID then
						return
					end

					local v7 = module.Data.Fighters.List[currentID]

					if not v7 then
						return
					end

					local v8 = module.Libs.NeoHover.GetByIdentifier("Fighters")

					if v8 then
						v8:Click(clone, {
							IsFake = true,
							Data = v7
						})
					end
				end)
				v6:BindOnEnter("Hover", function()
					local currentID = clone:GetAttribute("CurrentID")

					if not currentID then
						return
					end

					local v7 = module.Data.Fighters.List[currentID]

					if not v7 then
						return
					end

					local v8 = module.Libs.NeoHover.GetByIdentifier("Fighters")

					if v8 then
						v8:Open(clone, {
							IsFake = true,
							Data = v7
						})
					end
				end)
				v6:BindOnLeave("Hover", function()
					local v7 = module.Libs.NeoHover.GetByIdentifier("Fighters")

					if v7 then
						v7:Close(clone)
					end
				end)
			end

			if clone:GetAttribute("CurrentID") ~= childName then
				clone:SetAttribute("CurrentID", childName)
				module.Utils.Camera.ViewportCharacter({
					Viewport = clone.Main.Viewport,
					Animation = module.Utils.Characters.GetCharacterAnimation(v4.Name, "Idle"),
					Character = module.Utils.Characters.Get({
						Name = v4.Name,
						Shiny = v4.Shiny,
						RemoveHumanoidStates = true
					})
				})
			end

			local v6 = module.Shared.Traits.Get(v4)
			local icon = v6 and v6.Icon or ""
			local locked = v4.Locked == true
			local visible = module.Data.Fighters.Equipped[childName] == true
			clone.Main.InfoList.LockedIcon.Visible = locked
			clone.Main.InfoList.EquippedIcon.Visible = visible
			clone.Main.MiscList.TraitIcon.Image = icon
			clone.Main.MiscList.TraitIcon.Visible = icon ~= ""
			clone.Main.Title.Text = module.Shared.Fighters.GetDisplayName(v4.Name)
			clone.Main.UIGradient:SetAttribute("Rarity", v5.Rarity)
		end

		for _, child in self.Instance.Main.Slots:GetChildren() do
			if not child:GetAttribute("Loaded") then
				continue
			end

			local currentID = child:GetAttribute("CurrentID")

			if not currentID or v3[currentID] then
				continue
			end

			child:Destroy()
		end
	end
})

function FighterTeams.Clear()
	for _, v3 in v do
		v3.Instance:Destroy()
		v3:doCleanup()
	end

	table.clear(v)
end

function FighterTeams.UpdateAll()
	local v3 = #module.Data.Fighters.Teams + 1

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

function FighterTeams:Open()
	if self then
		module.Frame:SetPastUI(self)
	end

	module.Frame:Open(fighterTeams)
end

function FighterTeams.Stop()
	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
	FighterTeams.Clear()
end

function FighterTeams.Start()
	v2.Data = module:OnDataChanged({ "Fighters" }, FighterTeams.UpdateAll)
	FighterTeams.UpdateAll()
end

function FighterTeams.Init()
	module.Frame:OnFrameClosed(fighterTeams, FighterTeams.Stop)
	module.Frame:OnFrameOpened(fighterTeams, FighterTeams.Start)
end

return FighterTeams