local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
local InventoryController = require(legacyControllers:WaitForChild("InventoryController"))
local v = Component.new({
	Tag = "ToolPrompt"
})

local function arrayAttribute(requiredTool: string?)
	if requiredTool then
		return requiredTool:split(";;")
	end

	return nil
end

function v:Construct()
	self.Trove = Trove.new()
end

function v:UpdatePrompt()
	self.Instance.Enabled = not self.Instance:GetAttribute("ServerDisabled") and InventoryController:CheckHeldItem(arrayAttribute(self.Instance:GetAttribute("RequiredTool")))
end

function v:Start()
	self.Trove:Connect(InventoryController.EquippedToolChanged, function()
		self:UpdatePrompt()
	end)
	self.Trove:Connect(self.Instance.AttributeChanged, function()
		self:UpdatePrompt()
	end)
	self:UpdatePrompt()
end

function v.Stop(p)
	p.Trove:Clean()
end

return v