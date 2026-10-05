local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:WaitForChild("shared").modules
local EventAppraise = require(modules.EventAppraise)
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages.Trove)
local EventAppraiseButton = {}
EventAppraiseButton.__index = EventAppraiseButton

function EventAppraiseButton:SetSelected(selected: boolean)
	self.Selected = selected
	return self
end

function EventAppraiseButton:SetModifier(modifier: number)
	self.Modifier = modifier
	return self
end

function EventAppraiseButton:SetState(state2: string)
	self.State = state2

	if state2 == "Locked" then
		self.Instance.UIStroke.UIGradient.Enabled = false
		self.Instance.Flare.Visible = false
		self.Instance.corner.UIGradient.Enabled = false
		self.Instance.SecondIcon.Visible = true
		self.Instance.Icon.Visible = false
		self.Instance.Multiplier.Visible = false
		self.Instance.Overlay.Visible = false
		return self
	else
		local modifier = self.Modifier or 1
		local gold, gold2

		if modifier == EventAppraise.SuccessModifier[#EventAppraise.SuccessModifier] then
			gold = EventAppraise.FishIcons.Gold
			gold2 = EventAppraise.Colors.Gold
		elseif modifier >= 1 then
			gold = EventAppraise.FishIcons.Normal
			gold2 = EventAppraise.Colors.Green
		else
			gold = EventAppraise.FishIcons.Trash
			gold2 = EventAppraise.Colors.Red
		end

		self.Instance.Icon.Image = gold
		self.Instance.Multiplier.Text = `x{modifier}`
		self.Instance.Multiplier.TextColor3 = gold2
		self.Instance.Multiplier.Visible = true
		self.Instance.UIStroke.UIGradient.Enabled = true
		self.Instance.Flare.Visible = true
		self.Instance.corner.UIGradient.Enabled = true
		self.Instance.SecondIcon.Visible = false
		self.Instance.Icon.Visible = true
		self.Instance.Overlay.Visible = self.Selected == true
		return self
	end
end

function EventAppraiseButton.SetParent(p, parent)
	p.Instance.Parent = parent
	return p
end

function EventAppraiseButton:SetActivatedCallback(activatedCallback)
	self.ActivatedCallback = activatedCallback
end

function EventAppraiseButton.new()
	local object = setmetatable({}, EventAppraiseButton)
	object.Instance = script.Template:Clone()
	object.Collector = Trove.new()
	object.Collector:Add(object.Instance)
	object.Collector:Add(object.Instance.Activated:Connect(function(...)
		if object.ActivatedCallback then
			object.ActivatedCallback(...)
		end
	end))
	object:SetState("Locked")
	return object
end

function EventAppraiseButton:Destroy()
	self.Collector:Destroy()
end

return EventAppraiseButton