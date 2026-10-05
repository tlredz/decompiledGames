local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ConceptsLibrary = require(ReplicatedStorage.Modules.ConceptsLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(user_id, username)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.Headshot = self.PromptFrame:WaitForChild("Headshot")
	self.Title = self.PromptFrame:WaitForChild("Title")
	self.Points = self.PromptFrame:WaitForChild("Points")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._user_id = user_id
	self._username = username
	self._conceptor_info = ConceptsLibrary.Conceptors[tostring(self._user_id)]
	self._reward_slots = {}
	self:_Init()
	return self
end

function object:Destroy()
	for _, _reward_slot in pairs(self._reward_slots) do
		_reward_slot:Destroy()
	end

	Prompt.Destroy(self)
end

function object:_Update()
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.List.ClipsDescendants = self.List.AbsoluteCanvasSize.Y > self.List.AbsoluteWindowSize.Y
end

function object:_Setup()
	self.Title.Text = self._username
	self.Points.Text = string.format("%.1f", ConceptsLibrary:GetConceptScore(self._user_id)) .. " points"
	self.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, self._user_id)

	for _, cosmeticConcept in pairs(self._conceptor_info.CosmeticConcepts) do
		local cosmetic = CosmeticLibrary.Cosmetics[cosmeticConcept]
		local v = RewardSlot.new({
			Name = cosmeticConcept,
			Weapon = cosmetic.ItemName
		})
		v:SetParent(self.Container)
		table.insert(self._reward_slots, v)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.List:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		self:_Update()
	end)
	self.List:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.CloseButton)
end

return object