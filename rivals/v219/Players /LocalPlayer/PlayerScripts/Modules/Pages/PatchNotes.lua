local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.CosmeticLibrary)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local patchNoteBalancingOverviewSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PatchNoteBalancingOverviewSlot")
local patchNoteContentSummarySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PatchNoteContentSummarySlot")
local patchNoteBalanceChangeSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PatchNoteBalanceChangeSlot")
local patchNoteViewMoreButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PatchNoteViewMoreButton")
local patchNoteThumbnailSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PatchNoteThumbnailSlot")
local patchNoteChangeSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PatchNoteChangeSlot")
local patchNotesSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PatchNotesSlot")
local patchNotes = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PatchNotes")
local v = {
	"Release",
	"FreezeRay",
	"Matchmaking",
	"Cosmetics",
	"NewMaps",
	"Gamemodes",
	"2024SpookyEvent",
	"Weapons",
	"2024FestiveEvent",
	"BridgeMap",
	"Ranked",
	"TheHunt",
	"Cosmetics2",
	"Gamemodes2",
	"Emotes",
	"Season1",
	"2025SpookyEvent",
	"2025FestiveEvent",
	"LaborOfLove",
	"Lucky",
	"Season3",
	"2026Summer",
	"WildcatRelease",
	"RIA26"
}
local v2 = {
	{ Color3.fromRGB(100, 255, 50), "rbxassetid://72868042131575" },
	{ Color3.fromRGB(255, 50, 50), "rbxassetid://129990470163489" },
	{ Color3.fromRGB(166, 166, 166), "rbxassetid://125168324521437" }
}
local v3 = {
	Title = {
		Weight = 600,
		Transparency = 0,
		Size = 1.5,
		Spaces = 3,
		Prefix = "",
		NewLine = 2
	},
	Header = {
		Weight = 500,
		Transparency = 0.25,
		Size = 0.875,
		Spaces = 9,
		Prefix = "",
		NewLine = 0.5
	},
	Description = {
		Weight = 400,
		Transparency = 0.25,
		Size = 0.75,
		Spaces = 12,
		Prefix = "• ",
		NewLine = nil
	},
	Description2 = {
		Weight = 400,
		Transparency = 0.25,
		Size = 0.75,
		Spaces = 18,
		Prefix = "▪  ",
		NewLine = nil
	}
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.PageContainer = self.PageFrame:WaitForChild("Container")
	self.CloseButton = self.PageContainer:WaitForChild("Close")
	self.List = self.PageContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.ViewMoreButton = self.Container:WaitForChild("ViewMore")
	self._num_patch_notes_generated = 0
	self._is_generating = false
	self._elements = {}
	self:_Init()
	return self
end

function object.ScrollTo(p, parent, p2)
	if not parent then
		return
	end

	TweenService:Create(p.List, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(0, parent.AbsolutePosition.Y - p.Container.AbsolutePosition.Y)
	}):Play()
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = p2 or Color3.fromRGB(255, 255, 255)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(1, 0, 20, 0)
	frame.Parent = parent
	frame:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quint", 0.5, true)
	BetterDebris:AddItem(frame, 3)
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.125, 0),
		NumberSequenceKeypoint.new(0.875, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = frame
	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 1, function(p3)
		frame.BackgroundTransparency = 0 + 1 * (p3 / 100) ^ 4
	end)
end

function object:Open(...)
	Page.Open(self, ...)
	self:_UpdateSize()
	local _is_open_hash = self._is_open_hash
	task.delay(0.5, function()
		for _, _element in pairs(self._elements) do
			if _is_open_hash ~= self._is_open_hash then
				break
			end

			_element[1].Parent = _element[2]
			RunService.RenderStepped:Wait()
		end
	end)
end

function object:Close(...)
	for _, _element in pairs(self._elements) do
		_element[1].Parent = nil
	end

	Page.Close(self, ...)
end

function object:_GenerateNext()
	if self._num_patch_notes_generated >= #v then
		return
	end

	self._is_generating = true
	self._num_patch_notes_generated += 1
	self.ViewMoreButton.Visible = self._num_patch_notes_generated < #v
	local v4 = #v - self._num_patch_notes_generated + 1
	local module = require(patchNotes:WaitForChild(v[v4]))
	local clone = patchNotesSlot:Clone()
	clone.LayoutOrder = self._num_patch_notes_generated
	clone.Container.Thumbnail.Image = module.Image or ""
	clone.Container.Thumbnail.Visible = clone.Container.Thumbnail.Image ~= ""
	clone.Container.Details.Title.Text = module.Title
	clone.Container.Details.Changes.Date.Text = module.Date
	clone.Parent = self.Container
	clone.Container.Details.Changes.CodeButton.Button.MouseButton1Click:Connect(function()
		clone.Container.Details.Changes.CodeButton.Visible = false
		ReplicatedStorage.Remotes.Data.RedeemCode:InvokeServer(string.lower(module.Code))
	end)
	clone.Container.Details.Changes.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		clone.Size = UDim2.new(
			1,
			0,
			0,
			clone.Container.Details.Changes.AbsolutePosition.Y - clone.AbsolutePosition.Y + clone.Container.Details.Changes.Layout.AbsoluteContentSize.Y
		)
	end)
	ButtonEffect:Add(clone.Container.Details.Changes.CodeButton.Button)

	if module.Code and v4 == #v then
		task.delay(20, function()
			clone.Container.Details.Changes.CodeButton.Visible = not PlayerDataController:Get("RedeemedCodes")[string.lower(module.Code)]
		end)
	end

	local v5 = Signal.new()
	local flag = true
	local v6 = nil
	local total = 0
	local v7 = {}
	local v8 = false
	local clones = {}
	local count = 0

	local function new_layout_order()
		count += 1
		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function register_element(clone2)
		clone2.Parent = self._is_open and clone.Container.Details.Changes or nil
		table.insert(self._elements, { clone2, clone.Container.Details.Changes })
	end

	local function add_to_collapsed_list(clone2, p, value)
		if v7 then
			clone2.Visible = false
			table.insert(v7, clone2)

			if p then
				p.Visible = false
				table.insert(v7, p)
			end
		elseif total == 10 then
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			})
			uIGradient.Rotation = 90
			uIGradient.Parent = clone2
			local v9 = {}
			v7 = v9
			local clone3 = patchNoteViewMoreButton:Clone()
			clone3.Parent = clone2

			local function expand()
				if flag then
					return
				end

				for _, v10 in pairs(v9) do
					v10.Visible = true
				end

				uIGradient:Destroy()
				clone3:Destroy()
			end

			clone3.MouseButton1Click:Connect(expand)
			v5:Connect(expand)
			ButtonEffect:Add(clone3)
			RunService.RenderStepped:Wait()
		else
			total += value or 1
		end
	end

	local function generate_balancing_overview(p)
		v8 = true
		local clone2 = patchNoteBalancingOverviewSlot:Clone()
		count += 1
		clone2.LayoutOrder = count

		for i = 1, 3 do
			local v9 = v2[i]
			local v10 = p[i + 1] or {}

			for _, v11 in pairs(v10) do
				assert(ItemLibrary.ViewModels[v11], v11)
				local clone3 = patchNoteBalanceChangeSlot:Clone()
				clone3.Button.Label.Icon.Image = v9[2]
				clone3.Button.Label.Icon.ImageColor3 = v9[1]
				clone3.Button.Background.BackgroundColor3 = v9[1]
				clone3.Button.Background.UIStroke.Color = v9[1]
				clone3.Button.Graphic.Picture.Image = ItemLibrary.ViewModels[v11].ImageCentered or ItemLibrary.Items[v11].Image
				clone3.Parent = clone2.Slots
				local v12 = v11
				local v13 = v9
				clone3.Button.MouseButton1Click:Connect(function()
					v5:Fire()
					task.defer(self.ScrollTo, self, clones[v12], v13[1])
				end)
				ButtonEffect:Add(clone3.Button)
			end
		end

		register_element(clone2) -- equivalent call inferred; original call site unknown
		local layout = clone2.Slots.Layout

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			clone2.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	local function generate_content_summary(list)
		local v9 = list[3]

		for i = 1, math.ceil(#v9 / 7) do
			local clone2 = patchNoteContentSummarySlot:Clone()
			count += 1
			clone2.LayoutOrder = count
			clone2.Slots.Layout.HorizontalAlignment = Enum.HorizontalAlignment[list[2] or "Center"]

			for i2 = (i - 1) * 7 + 1, i * 7 do
				local name = v9[i2]

				if not name then
					continue
				end

				local v11 = typeof(name) ~= "table" and {
					Name = name
				} or name
				local v12 = RewardSlot.new(v11)
				v12.Frame.LayoutOrder = i2
				v12:SetParent(clone2.Slots)

				if v8 and ItemLibrary.Items[v11.Name] then
					clones[v11.Name] = clone2
				end
			end

			add_to_collapsed_list(clone2, nil, 3)
			register_element(clone2) -- equivalent call inferred; original call site unknown
			local layout = clone2.Slots.Layout

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				clone2.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
			end

			layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
		end
	end

	local function generate_thumbnail(list)
		local image = list[2]
		local text = list[3]
		local clone2 = patchNoteThumbnailSlot:Clone()
		count += 1
		clone2.LayoutOrder = count
		clone2.Thumbnail.Image = image
		clone2.Title.Text = text
		clone2.Title.AutoLocalize = false
		add_to_collapsed_list(clone2)
		register_element(clone2) -- equivalent call inferred; original call site unknown
	end

	local function generate_text(list)
		local v9 = list[1]
		local v10 = list[2]
		local v11 = v3[v9]
		assert(v11 ~= nil, v9, list)

		if v9 == "Title" then
			v6 = list
			total = 0
			v7 = nil
		end

		local clone2

		if v11.NewLine then
			clone2 = patchNoteChangeSlot:Clone()
			count += 1
			clone2.LayoutOrder = count
			clone2.Text = ""
			clone2.Size = UDim2.new(clone2.Size.X.Scale, 0, clone2.Size.Y.Scale * v11.NewLine, 0)
			clone2.AutoLocalize = false
			register_element(clone2) -- equivalent call inferred; original call site unknown
		end

		local clone3 = patchNoteChangeSlot:Clone()
		count += 1
		clone3.LayoutOrder = count
		clone3.Text = string.format(
			"%s%s<font weight=\"%s\">%s</font>",
			string.rep(" ", v11.Spaces),
			v11.Prefix,
			v11.Weight,
			v10
		)
		clone3.TextTransparency = v11.Transparency
		clone3.Size = UDim2.new(clone3.Size.X.Scale, 0, clone3.Size.Y.Scale * math.ceil(#v10 / 80) * v11.Size, 0)
		clone3.AutoLocalize = false
		register_element(clone3) -- equivalent call inferred; original call site unknown

		if v8 and v9 == "Header" and ItemLibrary.Items[v10] then
			WeaponStatusHandler:ApplyItemStatusToText(clone3, ItemLibrary.Items[v10].Status)
			clones[v10] = clone3
		end

		add_to_collapsed_list(clone3, clone2)
	end

	local function generate(list)
		local v9 = list[1]

		if v9 == "Thumbnail" then
			return generate_thumbnail(list)
		elseif v9 == "BalancingOverview" then
			return generate_balancing_overview(list)
		elseif v9 == "ContentSummary" then
			return generate_content_summary(list)
		end

		return generate_text(list)
	end

	for _, list in pairs(module.Changes) do
		if typeof(list[1]) == "function" then
			for _, v9 in pairs(list[1](select(2, table.unpack(list)))) do
				local v10 = v9[1]

				if v10 == "Thumbnail" then
					local image = v9[2]
					local text = v9[3]
					local clone2 = patchNoteThumbnailSlot:Clone()
					count += 1
					clone2.LayoutOrder = count
					clone2.Thumbnail.Image = image
					clone2.Title.Text = text
					clone2.Title.AutoLocalize = false
					add_to_collapsed_list(clone2)
					local parent

					if self._is_open then
						parent = clone.Container.Details.Changes or nil
					end

					clone2.Parent = parent
					table.insert(self._elements, { clone2, clone.Container.Details.Changes })
				elseif v10 == "BalancingOverview" then
					generate_balancing_overview(v9)
				elseif v10 == "ContentSummary" then
					generate_content_summary(v9)
				else
					generate_text(v9)
				end
			end
		else
			local v9 = list[1]

			if v9 == "Thumbnail" then
				local image = list[2]
				local text = list[3]
				local clone2 = patchNoteThumbnailSlot:Clone()
				count += 1
				clone2.LayoutOrder = count
				clone2.Thumbnail.Image = image
				clone2.Title.Text = text
				clone2.Title.AutoLocalize = false
				add_to_collapsed_list(clone2)
				local parent

				if self._is_open then
					parent = clone.Container.Details.Changes or nil
				end

				clone2.Parent = parent
				table.insert(self._elements, { clone2, clone.Container.Details.Changes })
			elseif v9 == "BalancingOverview" then
				generate_balancing_overview(list)
			elseif v9 == "ContentSummary" then
				generate_content_summary(list)
			else
				generate_text(list)
			end
		end
	end

	flag = false
	self._is_generating = false
end

function object:_UpdateList()
	self.CloseButton.Position = UDim2.new(0.975, 0, 0.0225, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Position = UDim2.new(0.5, 9, 0, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Size = UDim2.new(0.85, 0, 0, self.PageFrame.AbsoluteSize.Y * 0.75)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function object:_UpdateSize()
	self.PageContainer.Size = UDim2.new(0, math.min(1000, UILibrary.MainGui.AbsoluteSize.X * 0.875), 1, 0)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		if PlayerDataController:Get("LastPatchNotesVersion") ~= CONSTANTS.GAME_VERSION then
			ReplicatedStorage.Remotes.Misc.ViewedPatchNotes:FireServer()
		end

		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.List:GetPropertyChangedSignal("CanvasPosition"):Connect(function() end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateList()
	end)
	self.PageFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateList()
	end)
	self.ViewMoreButton.MouseButton1Click:Connect(function()
		self:_GenerateNext()
	end)
	UILibrary.MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSize()
	end)
	self:_UpdateSize()
	self:_UpdateList()
	task.spawn(self._GenerateNext, self)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ViewMoreButton)
end

return object._new()