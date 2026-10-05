local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local v = Component.new({
	Tag = "QuestCountdown"
})
local color = Color3.fromRGB(255, 214, 49)
local color2 = Color3.fromRGB(255, 51, 71)

function v:Construct()
	self.trove = Trove.new()
	self.icon = self.Instance:FindFirstChild("icon")
	local timer

	if self.Instance:IsA("TextLabel") then
		timer = self.Instance
	else
		timer = self.Instance:FindFirstChild("timerLabel")
	end

	self.timer = timer
end

function v:Update()
	if not (self.Instance.Visible and self.Instance:GetAttribute("ExpiresAt")) then
		return
	end

	local v2 = self.Instance:GetAttribute("ExpiresAt") - workspace:GetServerTimeNow()

	if v2 >= 86400 then
		self.timer.TextColor3 = color
		self.icon.ImageColor3 = color
	else
		self.timer.TextColor3 = color2
		self.icon.ImageColor3 = color2
	end

	local v3 = {}

	if v2 >= 86400 then
		local v4 = v2 // 86400
		v2 -= v4 * 86400
		table.insert(v3, (`{v4}d`))
	end

	if v2 >= 3600 then
		local v4 = v2 // 3600
		v2 -= v4 * 3600
		table.insert(v3, (`{v4}h`))
	end

	if v2 >= 60 then
		table.insert(v3, (`{v2 // 60}m`))
	elseif #v3 == 0 then
		table.insert(v3, "<1m")
	end

	self.timer.Text = table.concat(v3, " ")
end

function v:Start()
	self:Update()
	self.trove:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Update()
	end))
	self.trove:Add(self.Instance:GetAttributeChangedSignal("ExpiresAt"):Connect(function()
		self:Update()
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

task.spawn(function()
	while true do
		task.wait(61 - workspace:GetServerTimeNow() % 60)

		for _, v2 in v:GetAll() do
			task.spawn(v2.Update, v2)
		end
	end
end)
return v