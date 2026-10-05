local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Prompts = {
	CurrentPrompt = nil
}

if RunService:IsServer() then
	function Prompts:Start()
		warn("Called Prompts.lua from the server. This is a client only module.")
	end

	return Prompts
end

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local sharedUtils = ReplicatedStorage:WaitForChild("SharedUtils")
local Maid = require(sharedUtils.Maid)
local Signal = require(sharedUtils.Signal)
local v = {}
local v2 = {}

function v2.new(p, parent)
	assert(p and v[p], "Need correct template key, received: " .. tostring(p))
	local self = setmetatable({}, {
		__index = v2
	})
	self.Frame = v[p]:Clone()
	self.Parent = parent
	self.Maid = Maid.new()
	self.Answer = Signal.new()
	self.Maid:GiveTask(self.Frame)
	Prompts.CurrentPrompt = self
	return self
end

function v2:SetTitle(value)
	self.Frame.Title.Text = value or "Important question"
end

function v2:SetDescription(value)
	self.Frame.Description.Text = value or "What do you decide?"
end

function v2:AddResponse(p2, p3: string, callback)
	self.Maid:GiveTask(p2[p3]:Connect(function()
		callback(self)
	end))
end

function v2:Start()
	self.Frame.Visible = true
	self:AddResponse(self.Frame.Exit, "Activated", function(p)
		p.Answer:Fire(nil, true)
	end)
	self.Frame.Parent = self.Parent
end

function v2:Destroy()
	if Prompts.CurrentPrompt == self then
		Prompts.CurrentPrompt = nil
	end

	self.Maid:Destroy()
end

function Prompts:AddTemplate(p, p2)
	v[p] = p2
	p2.Parent = nil
end

function Prompts.Confirm(_, p, p2, p3: string?)
	local v3 = "Boolean"

	if p3 and v[v3 .. "_" .. p3] then
		v3 ..= "_" .. p3
	end

	local v4 = v2.new(v3, Prompts.Container)
	v4:SetTitle(p)
	v4:SetDescription(p2)
	v4:Start()
	v4:AddResponse(v4.Frame.CancelButton, "Activated", function(p4)
		p4.Answer:Fire(false, false)
	end)
	v4:AddResponse(v4.Frame.AcceptButton, "Activated", function(p4)
		p4.Answer:Fire(true, false)
	end)
	local v5, v6 = v4.Answer:Wait()
	v4:Destroy()
	return v5, v6
end

function Prompts.Notify(_, p, p2)
	local notification = v2.new("Notification", Prompts.Container)
	notification:SetTitle(p)
	notification:SetDescription(p2)
	notification:Start()
	notification:AddResponse(notification.Frame.AcceptButton, "Activated", function(p3)
		p3.Answer:Fire(true, false)
	end)
	local v3, v4 = notification.Answer:Wait()
	notification:Destroy()
	return v3, v4
end

function Prompts:Start()
	local mainGui = playerGui:WaitForChild("MainGui")
	local flag = false
	local popups = nil

	local function init()
		if not popups then
			return
		end

		local container = popups:WaitForChild("Container")
		local templates = container:WaitForChild("Templates")
		Prompts.Container = container

		for _, child in pairs(templates:GetChildren()) do
			self:AddTemplate(child.Name, child)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkForPopupFrame()
		if flag then
			return
		end

		popups = mainGui:FindFirstChild("Popups")

		if popups then
			flag = true
			init()
		end
	end

	mainGui.ChildAdded:Connect(checkForPopupFrame)
	checkForPopupFrame() -- equivalent call inferred; original call site unknown
end

Prompts:Start()
return Prompts