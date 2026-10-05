local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local _ = Players.LocalPlayer
local AvatarEditorController = require(ReplicatedStorage.Modules.Client.AvatarEditor.AvatarEditorController)
local CosmeticEffectController = require(ReplicatedStorage.Modules.Client.AvatarEditor.CosmeticEffectController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local v = Component.new({
	Tag = "EmmiterList"
})
local v2 = false
local name = nil

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._lastScrollPosition = Vector2.new(0, 0)
	self._loadedItems = {}
	self._isFirstLoad = true
	self.selectDebounce = false
	local EmmitersConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Emmiters.EmmitersConfig)
	v2 = EmmitersConfig
end

function v:ClearList()
	self._loadedItems = {}

	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	self._clickJanitor:Cleanup()
end

function v:LoadAllItems(items)
	if not self._isFirstLoad then
		self.Instance.CanvasPosition = self._lastScrollPosition
		return
	end

	self:ClearList()

	for k, item in items do
		if not item or self._loadedItems[item.Id] then
			continue
		end

		self._loadedItems[item.Id] = true

		if item.Name == "0001Remove" then
			continue
		end

		local clone = self.templateButton:Clone()
		local emmitersVIP = item.EmmitersVIP
		clone.Name = string.format("%08d_%s", k, item.Name)
		clone:SetAttribute("Id", item.Id)
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. item.Id .. "&w=150&h=150"
		clone.LayoutOrder = k
		clone.VIP.Visible = emmitersVIP

		if item.Premium then
			clone.PremiumMesh.Visible = true
		end

		if name == clone.Name then
			UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, true)
		end

		clone.Parent = self.Instance
		local v5 = item
		self._clickJanitor:Add(clone.Activated:Connect(function()
			if self.selectDebounce then
				return
			end

			self.selectDebounce = true
			task.delay(0.5, function()
				self.selectDebounce = false
			end)

			local function selectEmitter()
				name = clone.Name

				for i, button in self.Instance:GetChildren() do
					if button:IsA("ImageButton") then
						UIAnimationEffects.SetVisibilityWithPopInOutFX(button.SelectedIcon, button.Name == name)
					end
				end
			end

			if emmitersVIP then
				local formatted = `Asset_{v5.Id}`

				if not UnlockableController.IsFeatureUnlocked(formatted, Gamepasses.VIP) then
					GamepassController.Show(Gamepasses.VIP, clone.Icon.Image, "emitter", nil, {
						id = formatted,
						icon = clone.Icon.Image
					}, nil, "Avatar Editor", tostring(v5.Id), function()
						if clone.Parent == nil or not PanelController.IsOpen("NoResetGUIHandler", "AvatarEditorMenu") then
							return
						end

						if name ~= clone.Name then
							selectEmitter()
							CosmeticEffectController.ApplyEmmiter(v5.Id, v5.Name)
						end
					end)
					return
				end
			end

			if name == clone.Name then
				name = nil

				if clone:FindFirstChild("SelectedIcon") then
					UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, false)
				end
			else
				selectEmitter()
			end

			CosmeticEffectController.ApplyEmmiter(v5.Id, v5.Name)
		end))
	end

	self.Instance.CanvasPosition = self._lastScrollPosition
	self._isFirstLoad = false
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local config = v2.getConfig()
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self._Janitor:Add(AvatarEditorController.OnResetCharacterAppearance:Connect(function()
		self:ClearList()
		self._isFirstLoad = true
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self._lastScrollPosition = self.Instance.CanvasPosition
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:LoadAllItems(config)
		else
			self._lastScrollPosition = self.Instance.CanvasPosition
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v