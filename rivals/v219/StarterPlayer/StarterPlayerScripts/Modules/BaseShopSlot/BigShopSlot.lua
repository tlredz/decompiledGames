local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local EmoteViewportFrame = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("EmoteViewportFrame"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local parentModule = require(script.Parent)
local shopBigSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ShopBigSlot")
local object = setmetatable({}, parentModule)
object.__index = object

function object.new(...)
	local self = setmetatable(parentModule.new(...), object)
	self.Frame = shopBigSlot:Clone()
	self._emote_viewport_frame = nil
	self:_Init()
	return self
end

function object.OnClick(p, onMouseButton1Click)
	p.Frame.Button.MouseButton1Click:Connect(onMouseButton1Click)
end

function object:SetDescription(text)
	self.Frame.Button.Description.Text = text
end

function object:Destroy()
	if self._emote_viewport_frame then
		self._emote_viewport_frame:Destroy()
	end

	self.Frame:Destroy()
end

function object:_Setup()
	local cosmetic = CosmeticLibrary.Cosmetics[self.FirstRewardData.Name]
	self.Frame.Button.Background.BackgroundColor3 = CosmeticLibrary.Rarities[cosmetic.Rarity].Color
	self.Frame.Button.Background.UIStroke.Color = self.Frame.Button.Background.BackgroundColor3
	self.Frame.Button.Icon.Image = cosmetic.ImageHighResolution or ""
	self.Frame.Button.Title.Text = self.FirstRewardData.Name
	self.Frame.Button.Weapon.Text = cosmetic.Rarity .. " " .. (cosmetic.ItemName or "???") .. " " .. cosmetic.Type

	if not (self.IsOwned or self.IsLocked) then
		ButtonEffect:Add(self.Frame.Button, nil, {
			HoverRatio = 1.03,
			ReleaseRatio = 1.03
		})
	end

	if cosmetic.Type == "Emote" then
		self._emote_viewport_frame = EmoteViewportFrame.new(self.FirstRewardData.Name)
		self._emote_viewport_frame:SetParent(self.Frame.Button)
		self._emote_viewport_frame.Frame.ZIndex = 9
		self._emote_viewport_frame.Frame.Position = UDim2.new(0.5, 0, 1, 0)
		self._emote_viewport_frame.EmoteGlow.Position = UDim2.new(0.5, 0, 0.85, 0)
		self._emote_viewport_frame.EmoteGlow.Position = UDim2.new(0.5, 0, 0.85, 0)
	end
end

function object:_Init()
	self:_Setup()
	self:_SetupBuyButton(self.Frame.Button.Buy, self.Frame.Button.Owned)
	self:SetDescription("")
end

return object