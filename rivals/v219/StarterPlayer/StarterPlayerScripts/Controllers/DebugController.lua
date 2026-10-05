local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MechanicsController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ArcadeController"))
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DuelController"))
local OutOfBoundsParts = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("GameComponents"):WaitForChild("OutOfBoundsParts"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local TableViewer = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("TableViewer"))
local DebugState = require(script:WaitForChild("DebugState"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._are_hitboxes_visible = false
	self._are_map_barriers_visible = false
	self._are_map_barriers_visible_changed_internal = Signal.new()
	self:_Init()
	return self
end

function class:Command(p, p2)
	if self[p] then
		self[p](self, p2)
	else
		self:_Command(p, p2)
	end
end

function class.SetHandicapsEnabled(_, p)
	DebugState:SetReplicate("AreHandicapsEnabled", p)
end

function class.DisableTransparentHats(_, p)
	DebugState:SetReplicate("DisableTransparentHats", p)
end

function class.SpectateNilDuel(_)
	SpectateController:SpectateDuelRequest(nil)
end

function class.ShowClientEnvironment(_)
	local new = TableViewer.new(require(Players.LocalPlayer.PlayerScripts.Client))
	new.ScreenGui.Parent = Players.LocalPlayer.PlayerGui
end

function class:GetMatchmakingData()
	self:_JSONDump(self:_Command("GetMatchmakingData", true))
end

function class:SetMapBarriersVisible(are_map_barriers_visible)
	self._are_map_barriers_visible = are_map_barriers_visible
	self._are_map_barriers_visible_changed_internal:Fire()
	self:_SetupMapBarriersLogic()
end

function class.SetOOBVisible(_, p)
	OutOfBoundsParts:SetVisible(p)
end

function class.DisableDeviceAutoSwitch(_, p)
	ControlsController:DisableVerification(p)
end

function class:SetHitboxesVisible(are_hitboxes_visible)
	self._are_hitboxes_visible = are_hitboxes_visible
	self:_UpdateAllClientFighterCharacterHitboxes()
end

function class.InternalViewRewardSlot(_)
	Pages.PageSystem:OpenPage("Debug", true)
	Pages.PageSystem:WaitForPage("Debug").PromptSystem:Open("InternalViewRewardSlot")
end

function class.SendOfflineGiftRewards(_)
	if not PermissionsLibrary:IsAdministrator(PlayerDataController:Get("PermissionsRoles")) then
		return
	end

	Pages.PageSystem:OpenPage("Debug", true)
	Pages.PageSystem:WaitForPage("Debug").PromptSystem:Open("SendOfflineGiftRewards")
end

function class.SendBugRewards(_)
	if not PermissionsLibrary:HasPermission(
		"permission_testing_publiccommands_bugrewards",
		PlayerDataController:Get("PermissionsRoles")
	) then
		return
	end

	Pages.PageSystem:OpenPage("Debug", true)
	Pages.PageSystem:WaitForPage("Debug").PromptSystem:Open("SendBugRewards")
end

function class:_SetupMapBarriersLogic()
	if self._map_barrier_logic_setup then
		return
	end

	self._map_barrier_logic_setup = true

	local function duel_added(p)
		local function update_map()
			if not p.Map then
				return
			end

			for _, part in pairs(p.Map.Model.Barriers:GetDescendants()) do
				if not part:IsA("BasePart") or part:HasTag("OutOfBoundsPart") then
					continue
				end

				part.Transparency = self._are_map_barriers_visible and 0.5 or 1
				part.Material = Enum.Material.SmoothPlastic
				part.Color = part:HasTag("KillBrick") and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(127, 127, 127)
				part.CastShadow = false
			end
		end

		self._are_map_barriers_visible_changed_internal:Connect(update_map)
		p.MapAdded:Connect(update_map)
		update_map()
	end

	DuelController.ObjectAdded:Connect(duel_added)

	for _, object in pairs(DuelController.Objects) do
		local v = object

		local function update_map()
			if not v.Map then
				return
			end

			for i, part in pairs(v.Map.Model.Barriers:GetDescendants()) do
				if not part:IsA("BasePart") or part:HasTag("OutOfBoundsPart") then
					continue
				end

				part.Transparency = self._are_map_barriers_visible and 0.5 or 1
				part.Material = Enum.Material.SmoothPlastic
				part.Color = part:HasTag("KillBrick") and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(127, 127, 127)
				part.CastShadow = false
			end
		end

		self._are_map_barriers_visible_changed_internal:Connect(update_map)
		object.MapAdded:Connect(update_map)
		update_map()
	end
end

function class:_JSONDump(...)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = Players.LocalPlayer.PlayerGui
	BetterDebris:AddItem(screenGui, 60)
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Parent = screenGui
	local v = { ... }

	for k, v2 in pairs(v) do
		for i = 1, math.ceil(#v2 / 199999) do
			local v3 = (i - 1) * 199999
			local text = string.sub(v2, v3 + 1, v3 + 199999)
			local textBox = Instance.new("TextBox")
			textBox.BackgroundColor3 = Color3.fromHSV(k / #v, 0.75, 1)
			textBox.Size = UDim2.new(0, 200, 0, 200)
			textBox.ClearTextOnFocus = false
			textBox.TextEditable = false
			textBox.Text = text
			textBox.TextWrapped = true
			textBox.Parent = screenGui
		end
	end
end

function class._Encode(_, p)
	local v = {}
	local clone

	clone = function(items)
		local result = {}

		for k, item in pairs(items) do
			if v[item] then
				result[k] = "*** cyclic table detected ***"
			elseif typeof(item) == "table" then
				v[item] = true
				result[k] = clone(item)
			else
				result[k] = item
			end
		end

		return result
	end

	return HttpService:JSONEncode((clone(p)))
end

function class:_Command(...)
	return ReplicatedStorage.Remotes.Debug.Command:InvokeServer(...)
end

function class:_UpdateClientFighterCharacterHitboxes(object)
	object:SetHitboxesVisible(self._are_hitboxes_visible)
end

function class:_UpdateAllClientFighterCharacterHitboxes()
	for _, object2 in pairs(FighterController.Objects) do
		if object2.Entity then
			self:_UpdateClientFighterCharacterHitboxes(object2.Entity)
		end
	end
end

function class:_SetupHitboxesVisualizer()
	local function client_fighter_added(p)
		p.EntityAdded:Connect(function(p2)
			self:_UpdateClientFighterCharacterHitboxes(p2)
		end)

		if p.Entity then
			self:_UpdateClientFighterCharacterHitboxes(p.Entity)
		end
	end

	FighterController.ObjectAdded:Connect(client_fighter_added)

	for _, object2 in pairs(FighterController.Objects) do
		task.defer(client_fighter_added, object2)
	end
end

function class:_Init()
	task.defer(self._SetupHitboxesVisualizer, self)
end

return class._new()