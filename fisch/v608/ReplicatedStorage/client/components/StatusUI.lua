local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "StatusUI"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:SetInfoVisible(visible: boolean)
	local info = self.Instance:FindFirstChild("info") or self.Instance:FindFirstChild("tooltip")

	if info and info:GetAttribute("HasContent") ~= false then
		info.Visible = visible
	end
end

function v:Start()
	self.trove:Add(self.Instance.MouseEnter:Connect(function()
		self:SetInfoVisible(true)
	end))
	self.trove:Add(self.Instance.MouseLeave:Connect(function()
		self:SetInfoVisible(false)
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v