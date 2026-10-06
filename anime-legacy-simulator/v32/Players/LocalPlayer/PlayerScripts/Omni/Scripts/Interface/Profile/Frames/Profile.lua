local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local v = {
	["Damage Dealt"] = 0,
	["Defeated Enemies"] = 0,
	["Time Played"] = 0,
	["Total Power"] = 0,
	["Highest Power"] = 0,
	["Highest DPS"] = 0,
	["Total Stars Opened"] = 0,
	["Total Traits Rolls"] = 0,
	["Total Yen"] = 0
}
local v2 = {
	Damage = {
		Fn = "Damage",
		Multiplier = "Damage"
	},
	["Player Damage"] = {
		Fn = "PlayerDamage",
		Multiplier = "Player Damage",
		AffectedBy = "Damage"
	},
	["Fighter Damage"] = {
		Fn = "FighterDamage",
		Multiplier = "Fighter Damage",
		AffectedBy = "Damage"
	},
	Yen = {
		Fn = "Yen",
		Multiplier = "Yen"
	},
	["Max Star Opens"] = {
		Fn = "MaxStarOpens",
		Multiplier = "Star Open",
		Base = "3"
	},
	["Star Open Speed"] = {
		Fn = "StarOpenSpeed",
		Multiplier = "Star Open Speed"
	},
	["Max Fighters Equipped"] = {
		Fn = "FightersEquipped",
		Multiplier = "Fighter Equip",
		Base = "3"
	},
	["Shiny Chance"] = {
		Fn = "ShinyChance",
		Multiplier = "Shiny Chance",
		Base = "2.5%"
	},
	Luck = {
		Fn = "Luck",
		Multiplier = "Luck"
	},
	["Gacha Luck"] = {
		Fn = "GachaLuck",
		Multiplier = "Gacha Luck"
	},
	Drops = {
		Fn = "Drops",
		Multiplier = "Drops"
	},
	["Player Exp"] = {
		Fn = "PlayerExp",
		Multiplier = "Player Exp"
	},
	["Mythical Chance"] = {
		Fn = "MythicalChance",
		Multiplier = "Mythical Chance"
	},
	["Secret Chance"] = {
		Fn = "SecretChance",
		Multiplier = "Secret Chance"
	}
}
local color = Color3.fromRGB(135, 144, 153)
local color2 = Color3.fromRGB(255, 214, 25)
local color3 = Color3.fromRGB(255, 76, 190)
local _ = {
	Position = createVector(0, -7.5, -7.5),
	Rotation = createVector(0, 0, 0)
}
local _ = {
	Position = createVector(0, -1.25, -4),
	Rotation = createVector(-0, -180, 0)
}
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local Controller = require(script.Parent.Parent.Controller)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Omni.DataTemplate)
local profile = module.Interface:WaitForChild("Frames"):WaitForChild("Profile")
local profile2 = profile:WaitForChild("Main"):WaitForChild("Profile")
local scroll = profile2:WaitForChild("List"):WaitForChild("Scroll")
local slots = profile2:WaitForChild("Slots")
local mouse = module.Instance:GetMouse()
local titles = module.Assets:WaitForChild("Interface"):WaitForChild("Titles")
local profile3 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Profile")
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = "Stats"
local v7 = nil
local count = 0
local v8 = false
local v9 = nil
local humanoidModels = {}
local v10 = nil
local v11 = 0
local value = scope:Value(1)
local spring = scope:Spring(value, 10, 1)
local spring2 = scope:Spring(value, 10, 1)
local Profile = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCurrentUserId()
	return v9 and v9.UserId or module.Instance.UserId
end

local function CreatePlayerModel(p: number)
	for _, v12 in humanoidModels do
		v12:Destroy()
	end

	local humanoidModel = module.Utils.Players.GetHumanoidModel(p)

	if humanoidModel then
		if not v8 or v10 ~= p then
			humanoidModel:Destroy()
			return
		end

		humanoidModel.Parent = profile2.PlayerViewport.Holder
		local humanoid = humanoidModel:FindFirstChildOfClass("Humanoid")
		local characterAnimation = module.Utils.Characters.GetCharacterAnimation("Default", "Idle")

		if characterAnimation and humanoid then
			local v12 = humanoid:FindFirstChildOfClass("Animator")

			if not v12 then
				v12 = Instance.new("Animator")
				v12.Parent = humanoid
			end

			local track = v12:LoadAnimation(characterAnimation)
			track.Looped = true
			track:Play()
		end

		for _, v12 in humanoidModels do
			v12:Destroy()
		end

		table.clear(humanoidModels)
		table.insert(humanoidModels, humanoidModel)
		spring:setPosition(0)
		return humanoidModel
	elseif v10 == p then
		v10 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPlayerName(p: number)
	if p == module.Instance.UserId then
		return module.Instance.Name
	end

	local playerByUserId = module.Services.Players:GetPlayerByUserId(p)

	if playerByUserId then
		return playerByUserId.Name
	end

	local playerInfo = module.Utils.Players.GetPlayerInfo(p)

	if playerInfo and playerInfo.UserName ~= "Not Found" then
		return playerInfo.UserName
	end

	return "Unknown"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCurrentData()
	return v9 and v9.Data or module.Data
end

local function FormatValue(p: number)
	return module.Utils.Number:Format(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatSourceName(name: string)
	return (string.gsub(name, "(%l)(%u)", "%1 %2"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOwnMultiplier(multiplier: string, p, instance)
	local currentMultiName = module.Utils.PlayerStats.GetCurrentMultiName(p, multiplier)
	local multiplierAmount, v12 = module.Utils.Multipliers.GetMultiplierAmountFromSystem(
		currentMultiName,
		"All",
		p,
		instance
	)
	return (1 + multiplierAmount) * v12
end

local function GetPerkSources(p: string)
	local v12 = v2[p]

	if not v12 then
		return {}
	end

	local v13 = {}

	if v12.Base then
		table.insert(v13, {
			Key = "Base",
			Name = "Base",
			ValueText = v12.Base,
			Depth = 1
		})
	end

	local v14

	if not v9 then
		v14 = module.Instance
	end

	local sources = module.Utils.PlayerStats.GetSources(GetCurrentData(), v14, v12.Multiplier)
	local v15 = 1
	local v16 = {}
	local total = 0
	local v17 = {}

	for _, source in sources do
		local name = FormatSourceName(source.Name) -- equivalent call inferred; original call site unknown

		if source.Add ~= 0 then
			total += source.Add
			local v19 = {
				Key = "Add_" .. source.Name,
				Name = name,
				ValueText = 0,
				Depth = 2
			}
			local add = source.Add
			v19.ValueText = "+" .. module.Utils.Number:Format(add)
			table.insert(v17, v19)
		end

		if source.Multi == 1 then
			continue
		end

		v15 *= source.Multi
		local v19 = {
			Key = "Multi_" .. source.Name,
			Name = name,
			ValueText = 0,
			Depth = 2
		}
		local multi = source.Multi
		v19.ValueText = "x" .. module.Utils.Number:Format(multi)
		table.insert(v16, v19)
	end

	table.insert(v13, {
		Key = "Add",
		Name = "Add",
		ValueText = "+" .. module.Utils.Number:Format(total),
		Depth = 1
	})
	table.move(v17, 1, #v17, #v13 + 1, v13)
	table.insert(v13, {
		Key = "Multi",
		Name = "Multi",
		ValueText = "x" .. module.Utils.Number:Format(v15),
		Depth = 1
	})
	table.move(v16, 1, #v16, #v13 + 1, v13)
	return v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FocusTemplate(p: string)
	count += 1
	local v12 = count
	task.spawn(function()
		module.Services.RunService.RenderStepped:Wait()

		if v12 ~= count then
			return
		end

		local v13 = v4[p]

		if not (v13 and v13.Instance) then
			return
		end

		local v14 = v13.Instance.AbsolutePosition.Y - scroll.AbsolutePosition.Y
		local v15 = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
		local v16 = math.clamp(scroll.CanvasPosition.Y + v14, 0, v15)
		scroll.CanvasPosition = Vector2.new(scroll.CanvasPosition.X, v16)
	end)
end

local function IsContextChange(list)
	local v12 = list[1]
	return v12 == "Gamemode" or v12 == "Maps" and (list[2] == nil or list[2] == "Current")
end

local function FilterDataChange(p, p2, list)
	if v9 then
		return false
	end

	local v12 = list[1]
	local v13 = list[2]

	if v12 == nil then
		v5.All = true
		return true
	end

	if v12 == "Profile" then
		if v13 == "Stats" then
			if v6 ~= "Stats" then
				return false
			end

			v5.Category = true
		elseif v13 == "Title" then
			v5.Title = true
		elseif v13 == "Banner" then
			v5.Banner = true
		elseif v13 == "Fighters" then
			v5.Fighters = true
		else
			v5.All = true
		end

		return true
	else
		if v6 ~= "Perks" then
			return false
		end

		local v14 = list[1]
		local v15

		if v14 == "Gamemode" then
			v15 = true
		elseif v14 == "Maps" then
			v15 = list[2] == nil or list[2] == "Current"
		else
			v15 = false
		end

		if v15 or module.Utils.Multipliers.IsDataChangeRelevant(list, p, p2) then
			v5.Category = true
			return true
		else
			return false
		end
	end
end

local v12 = {
	Build = function(self, duration: number)
		local depth = self.Depth or 0
		local uDim = UDim2.fromScale(0.5 + 0.05 * depth, 0.5)
		self.Position = self:Value(UDim2.fromScale(-0.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = profile3.Profile.Stat:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		self.Instance.Main.Size = UDim2.fromScale(1 - 0.1 * depth, 1)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if self.Type == "Perk" then
			local name = self.Name
			module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
				Profile.ToggleExpanded(name)
			end)
		end

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(uDim)
			end)
		else
			self.Position:set(uDim)
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local valueText = nil
		local currentData = GetCurrentData() -- equivalent call inferred; original call site unknown

		if self.Type == "Stat" then
			local v14 = currentData.Profile.Stats[self.Name] or 0

			if self.Name == "Time Played" then
				valueText = module.Utils.Number:Time2(v14)
			else
				valueText = module.Utils.Number:Format(v14)
			end
		elseif self.Type == "Source" then
			valueText = self.ValueText
		else
			self.Instance.Main.Title.Text = self.Name .. (v7 == self.Name and " [-]" or " [+]")
			local playerStat = module.Utils.PlayerStats[self.FnName]

			if typeof(playerStat) == "function" then
				local instance

				if not v9 then
					instance = module.Instance
				end

				local v14, v15 = playerStat(currentData, instance)
				local v16 = v2[self.Name]

				if v16.AffectedBy then
					local ownMultiplier = GetOwnMultiplier(v16.Multiplier, currentData, instance) -- equivalent call inferred; original call site unknown
					local v18 = ownMultiplier * module.Utils.PlayerStats[v2[v16.AffectedBy].Fn](currentData, instance)
					valueText = module.Utils.Number:Format(ownMultiplier) .. "x (" .. module.Utils.Number:Format(v18) .. "x)"
				elseif self.Name == "Shiny Chance" then
					valueText = module.Utils.Number:Format(v14) .. "%"
				elseif self.Name == "Drops" then
					valueText = "+" .. module.Utils.Number:Format(v14) .. " / " .. module.Utils.Number:Format(v15) .. "x"
				elseif self.Name == "Luck" or self.Name == "Gacha Luck" then
					valueText = "+" .. module.Utils.Number:Format(v14)
				elseif self.Name == "Max Star Opens" or self.Name == "Max Fighters Equipped" then
					valueText = module.Utils.Number:Format(v14)
				else
					valueText = module.Utils.Number:Format(v14) .. "x"
				end
			end
		end

		if typeof(valueText) == "string" or typeof(valueText) == "number" then
			self.Instance.Main.Value.Text = valueText
		else
			self.Instance.Main.Value.Text = "N/A"
		end

		self.Instance.LayoutOrder = self.Index or 0
	end
}
local scope2 = fusion.scoped(fusion, v12)

function Profile.SetCustomProfile(p)
	v9 = p
	v7 = nil
	Profile.UpdateAll()
end

function Profile.SetCategory(p: string)
	if p == v6 then
		return
	end

	v6 = p
	v7 = nil
	spring2:setPosition(0)
	Profile.UpdateCategory()
end

function Profile.ToggleExpanded(p: string)
	if v6 ~= "Perks" then
		return
	end

	if v7 == p then
		p = nil
	end

	v7 = p
	Profile.UpdateCategory()

	if v7 then
		FocusTemplate("Perk_" .. v7) -- equivalent call inferred; original call site unknown
	end
end

function Profile.UpdateTitle()
	local title = (GetCurrentData()).Profile.Title

	if profile2.Title:GetAttribute("CurrentTitle") ~= title then
		profile2.Title:SetAttribute("CurrentTitle", title)

		for _, frame in profile2.Title:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		local clone = title and titles:FindFirstChild(title) and titles:FindFirstChild(title):Clone()

		if clone then
			clone.Parent = profile2.Title
		end
	end
end

function Profile.UpdateBanner()
	local banner = (GetCurrentData()).Profile.Banner
	local v13 = banner and module.Shared.ProfileBanners.List[banner]
	local icon = v13 and v13.Icon or ""
	profile2.Banner.Main.Image = icon
end

function Profile.UpdatePlayer()
	local currentUserId = GetCurrentUserId() -- equivalent call inferred; original call site unknown
	local playerName = GetPlayerName(currentUserId) -- equivalent call inferred; original call site unknown
	profile2.Back.Visible = v9 ~= nil
	profile2.Username.Title.Text = "@" .. playerName

	if not v8 or v10 == currentUserId then
		return
	end

	v10 = currentUserId
	module.Libs.ThreadSaver.New(CreatePlayerModel, currentUserId)
end

function Profile.UpdateCategory()
	local v13 = {}
	local currentData = GetCurrentData() -- equivalent call inferred; original call site unknown
	local v15 = {}

	if v6 == "Stats" then
		local clone = table.clone(v)

		for k in module.Shared.Gacha.List do
			clone[`Total {k} Rolls`] = 0
		end

		for k in currentData.Profile.Stats do
			clone[k] = 0
		end

		for k in clone do
			table.insert(v13, k)
		end
	else
		for k in v2 do
			table.insert(v13, k)
		end
	end

	table.sort(v13)

	for k, name in v13 do
		if v6 == "Stats" then
			v15["Stat_" .. name] = {
				Name = name,
				Type = "Stat",
				Index = k * 100,
				Stagger = 0.05 * k
			}
		else
			v15["Perk_" .. name] = {
				Name = name,
				FnName = v2[name].Fn,
				Type = "Perk",
				Index = k * 100,
				Stagger = 0.05 * k
			}

			if v7 == name then
				for k2, v17 in GetPerkSources(name) do
					v15[`Source_{name}_{v17.Key}`] = {
						Name = v17.Name,
						ValueText = v17.ValueText,
						Type = "Source",
						Depth = v17.Depth,
						Index = k * 100 + k2,
						Stagger = 0.05 * k2
					}
				end
			end
		end
	end

	for k, v16 in v4 do
		if v15[k] then
			continue
		end

		v16.Instance:Destroy()
		v16:doCleanup()
		v4[k] = nil
	end

	for k, v16 in v15 do
		local v17 = v4[k]

		if v17 then
			v17.Index = v16.Index
			v17.ValueText = v16.ValueText
			v17:Update()
		else
			local innerScope = scope2:innerScope()
			innerScope.Name = v16.Name
			innerScope.FnName = v16.FnName
			innerScope.ValueText = v16.ValueText
			innerScope.Index = v16.Index
			innerScope.Type = v16.Type
			innerScope.Depth = v16.Depth

			if innerScope:Build(v16.Stagger) then
				v4[k] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end
end

function Profile.UpdateFighters()
	local playerData = GetCurrentData() -- equivalent call inferred; original call site unknown

	for i = 1, 6 do
		local clone = slots.Fighters:FindFirstChild(i)

		if not clone then
			clone = profile3.Profile.Fighter:Clone()
			clone.Name = i
			local v14 = module.Button:Create(clone.Main, "Default")
			local v15 = i
			v14:BindFunction("Click", function()
				for k in Controller.OverlayFrames do
					if module.Frame:IsFrameOpened(k) then
						return
					end
				end

				local currentData = GetCurrentData() -- equivalent call inferred; original call site unknown

				if not currentData then
					return
				end

				local currentID = clone:GetAttribute("CurrentID")

				if currentID then
					local v17 = currentData.Fighters.List[currentID]

					if not v17 then
						return
					end

					local v18 = module.Libs.NeoHover.GetByIdentifier("Fighters")

					if v18 then
						local isFromProfile = v9 == nil
						v18:Click(clone, {
							IsFake = true,
							PlayerData = playerData,
							Owner = GetCurrentUserId(),
							IsFromProfile = isFromProfile,
							Data = v17
						})
					end
				else
					if v9 ~= nil then
						return
					end

					local v17 = module.Signal:InvokeSelf("Interface", "Inventory", "GetController")

					if v17 then
						v17.SetMode("Selection", {
							Category = "Fighters",
							PastUI = profile,
							Callback = function(p: string)
								local v18 = module.Data.Fighters.List[p]

								if v18 then
									module.Signal:Fire("General", "Profile", "SetFighter", v15, v18.ID)
								end

								v17.CloseInterface()
							end
						})
						v17.LockMode()
					end
				end
			end)
			v14:BindOnEnter("Hover", function()
				for k in Controller.OverlayFrames do
					if module.Frame:IsFrameOpened(k) then
						return
					end
				end

				local currentData = GetCurrentData() -- equivalent call inferred; original call site unknown

				if not currentData then
					return
				end

				local currentID = clone:GetAttribute("CurrentID")

				if not currentID then
					return
				end

				local v17 = currentData.Fighters.List[currentID]

				if not v17 then
					return
				end

				local v18 = module.Libs.NeoHover.GetByIdentifier("Fighters")

				if v18 then
					local isFromProfile = v9 == nil
					v18:Open(clone, {
						IsFake = true,
						PlayerData = playerData,
						Owner = GetCurrentUserId(),
						IsFromProfile = isFromProfile,
						Data = v17
					})
				end
			end)
			v14:BindOnLeave("Hover", function()
				local v16 = module.Libs.NeoHover.GetByIdentifier("Fighters")

				if v16 then
					v16:Close(clone)
				end
			end)
			clone.LayoutOrder = i
			clone.Parent = slots.Fighters
			clone.Visible = true
		end

		local fighter = playerData.Profile.Fighters[tostring(i)]
		local v14 = fighter and playerData.Fighters.List[fighter]
		local v15 = v14 and module.Shared.Fighters.List[v14.Name]

		if clone:GetAttribute("CurrentID") ~= fighter then
			if v14 and v15 then
				clone.Main.UIGradient:SetAttribute("Rarity", v15.Rarity)
				module.Utils.Camera.ViewportCharacter({
					Viewport = clone.Main.Viewport,
					Animation = module.Utils.Characters.GetCharacterAnimation(v14.Name, "Idle"),
					Character = module.Utils.Characters.Get({
						Name = v14.Name,
						Owner = GetCurrentUserId(),
						Shiny = v14.Shiny,
						RemoveHumanoidStates = true
					})
				})
			else
				local v16 = module.Libs.NeoHover.GetByIdentifier("Fighters")

				if v16 and v16.Element == clone then
					v16:Close()
				end

				clone.Main.UIGradient:SetAttribute("Rarity", nil)
			end

			clone:SetAttribute("CurrentID", fighter)
		end

		clone.Main.Viewport.Visible = fighter ~= nil
		clone.Main.AddSymbol.Visible = fighter == nil
	end
end

function Profile.UpdateMouse()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local vector2 = Vector2.new(mouse.X, mouse.Y)
	local absolutePosition = profile2.PlayerViewport.AbsolutePosition
	local absoluteSize = profile2.PlayerViewport.AbsoluteSize
	local v13 = absolutePosition.X + absoluteSize.X / 2
	v11 = (vector2.X - v13) / math.max(viewportSize.X - v13, v13) * 45
	Profile.UpdatePlayerPosition()
	local v14 = viewportSize.X / 2
	local v15 = viewportSize.Y / 2
	local v16 = vector2.X - v14
	local v17 = vector2.Y - v15
	local v18 = v16 / v14
	local v19 = v17 / v15
	local v20 = v18 * 0.05
	local v21 = v19 * 0.05
	profile2.Banner.Main.Position = UDim2.fromScale(0.5 + v20, 0.5 + v21)
end

function Profile.UpdatePlayerPosition()
	if #humanoidModels == 0 then
		return
	end

	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	local lerped = (createVector(0, -7.5, -7.5)):Lerp(createVector(0, -1.25, -4), currentSpring)
	local lerped2 = (createVector(0, 0, 0)):Lerp(createVector(-0, -180, 0), currentSpring)
	local v13 = CFrame.new(lerped) * CFrame.Angles(
		math.rad(lerped2.X),
		math.rad(lerped2.Y + v11),
		(math.rad(lerped2.Z))
	)

	for _, v14 in humanoidModels do
		v14:PivotTo(v13)
	end
end

function Profile.UpdateAll()
	Profile.UpdateTitle()
	Profile.UpdateBanner()
	Profile.UpdatePlayer()
	Profile.UpdateCategory()
	Profile.UpdateFighters()
end

function Profile.RefreshFromData()
	local clone = table.clone(v5)
	table.clear(v5)

	if v9 then
		return
	end

	if clone.All then
		Profile.UpdateAll()
		return
	end

	if clone.Title then
		Profile.UpdateTitle()
	end

	if clone.Banner then
		Profile.UpdateBanner()
	end

	if clone.Category then
		Profile.UpdateCategory()
	end

	if clone.Fighters then
		Profile.UpdateFighters()
	end
end

function Profile.Start()
	for _, connection in v3 do
		connection:Disconnect()
	end

	table.clear(v3)
	table.clear(v5)
	v8 = true
	v3.DataChanged = module:OnDataChangedDeferred({}, Profile.RefreshFromData, FilterDataChange)
	v3.Weather = module.Services.ReplicatedStorage:GetAttributeChangedSignal(module.Shared.Weather.AttributeName):Connect(function()
		if v6 ~= "Perks" then
			return
		end

		Profile.UpdateCategory()
	end)
	v3.Mouse = mouse.Move:Connect(Profile.UpdateMouse)
	Profile.UpdateMouse()
	Profile.UpdateAll()
end

function Profile.Stop()
	v8 = false
	local v13 = module.Libs.NeoHover.GetByIdentifier("Fighters")

	if v13 then
		v13:Close()
	end

	for _, connection in v3 do
		connection:Disconnect()
	end

	table.clear(v3)
	table.clear(v5)
	v7 = nil

	for _, v14 in v4 do
		v14.Instance:Destroy()
		v14:doCleanup()
	end

	table.clear(v4)

	for _, v14 in humanoidModels do
		v14:Destroy()
	end

	table.clear(humanoidModels)
	v10 = nil
end

function Profile.Init()
	local framesByName = {}

	for _, frame in profile2.Categories:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v13 = frame
		module.Button:Create(frame.Main, "Small"):BindFunction("Click", function()
			Profile.SetCategory(v13.Name)
		end)
		framesByName[frame.Name] = frame
	end

	profile2.PlayerViewport.BackgroundTransparency = 1
	profile2.PlayerViewport.Ambient = Color3.new(1, 1, 1)
	profile2.PlayerViewport.LightColor = Color3.new(1, 1, 1)
	profile2.PlayerViewport.ImageColor3 = Color3.new(1, 1, 1)
	profile2.PlayerViewport.LightDirection = createVector(-1, -1, -1)
	profile2.PlayerViewport.BackgroundColor3 = Color3.fromRGB(-2, -2, -2)
	module.Button:Create(profile2.Back.Main, "Small"):BindFunction("Click", function()
		Profile.SetCustomProfile(nil)
	end)
	profile2.Search.FocusLost:Connect(function()
		local text = profile2.Search.Text

		if text == "" or text == module.Instance.Name then
			profile2.Search.Text = ""
			return
		end

		profile2.Search.Text = "Loading..."
		Controller.SearchProfile(text)
		profile2.Search.Text = ""
	end)
	scope:Observer(spring):onBind(Profile.UpdatePlayerPosition)
	scope:Observer(spring2):onBind(function()
		local currentSpring = scope.peek(spring2)

		if not currentSpring then
			return
		end

		for k, frame in framesByName do
			if not frame:IsA("Frame") then
				continue
			end

			local v13 = k == v6 and currentSpring or 1 - currentSpring
			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color:Lerp(color2, v13)),
				ColorSequenceKeypoint.new(1, color:Lerp(color3, v13))
			})
			frame.Main.UIGradient.Color = colorSequence
		end
	end)
	Controller.FrameChanged:Connect(function(p: string)
		if p == script.Name then
			Profile.Start()
		else
			Profile.Stop()
		end
	end)
end

return Profile