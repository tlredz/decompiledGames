local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Modules.Signal)
local Buttons = require(script:WaitForChild("Buttons"))
local Summary = require(script:WaitForChild("Summary"))
local Winners = require(script:WaitForChild("Winners"))
local FinalResults = {}
FinalResults.__index = FinalResults

function FinalResults.new(duelInterface)
	local self = setmetatable({}, FinalResults)
	self.Activated = Signal.new()
	self.PageChanged = Signal.new()
	self.CurrentPage = nil
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("FinalResults")
	self.Summary = Summary.new(self)
	self.Winners = Winners.new(self)
	self.Buttons = Buttons.new(self)
	self._is_active = false
	self:_Init()
	return self
end

function FinalResults:IsActive()
	return self._is_active
end

function FinalResults:SetPage(currentPage)
	self.CurrentPage = currentPage
	self.PageChanged:Fire()
	self.Winners:SetVisible(self.CurrentPage == "Winners")
	self.Summary:SetVisible(self.CurrentPage == "Summary")
end

function FinalResults:Play(...)
	self._is_active = true
	self.Activated:Fire()
	return self.Winners:Play(...)
end

function FinalResults:UpdateVisibility()
	self.Frame.Visible = self:IsActive() and not self.DuelInterface:IsPageOpen()
end

function FinalResults:Destroy()
	self.Activated:Destroy()
	self.PageChanged:Destroy()
	self.Summary:Destroy()
	self.Winners:Destroy()
	self.Buttons:Destroy()
end

function FinalResults:_Setup()
	self.Frame.Visible = false
end

function FinalResults:_Init()
	self.Activated:Connect(function()
		self:UpdateVisibility()
	end)
	self:_Setup()
	self:SetPage("Winners")
end

return FinalResults