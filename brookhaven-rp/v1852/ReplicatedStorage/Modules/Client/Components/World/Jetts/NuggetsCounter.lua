local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local JettsConfig = require(ReplicatedStorage.Modules.Shared.DB.World.JettsConfig)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TweenService = game:GetService("TweenService")
local v = Component.new({
	Tag = "NuggetsCounter"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:ShowMilestoneScreen(p: number)
	if self.finishCelebrationTask then
		task.cancel(self.finishCelebrationTask)
	end

	self.sound:Play()
	local v2 = nil

	while p > 0 do
		local v3 = p % 1000
		p = math.floor(p / 1000)

		if v2 then
			v2 = `{string.format("%03d", v3)},{v2}`
		else
			v2 = `{string.format("%03d", v3)} Nuggets!`
		end
	end

	local v3 = v2:gsub("^0+", "")
	local v4 = #v3 == nil and "0" or v3
	self.container.Visible = true
	self.milestoneText.Text = `{v4}`
	self.milestoneText2.Text = `{v4}`
	self.milestoneText3.Text = `{v4}`
	self.finishCelebrationTask = task.delay(JettsConfig.GetConfig().MilestoneCelebrationDuration, function()
		self.container.Visible = false
	end)

	if self.tween then
		self.tween:Cancel()
	end

	self.container.Position = UDim2.new(1, 0, 0.5, 0)
	self.tween = TweenService:Create(
		self.container,
		TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
		{
			Position = UDim2.new(0, 0, 0.5, 0)
		}
	)
	self.tween:Play()
	self._Janitor:Add(self.tween)
end

function v:Start()
	local milestoneScreen = self.Instance:WaitForChild("MilestoneScreen")

	if not milestoneScreen then
		return
	end

	local surfaceGui = milestoneScreen:WaitForChild("SurfaceGui")

	if not surfaceGui then
		return
	end

	self.container = surfaceGui:WaitForChild("Container")
	self.container.Visible = false
	self.milestoneText = self.container:WaitForChild("MilestoneText")
	self.milestoneText.Text = ""
	self.milestoneText2 = self.container:WaitForChild("MilestoneText2")
	self.milestoneText2.Text = ""
	self.milestoneText3 = self.container:WaitForChild("MilestoneText3")
	self.milestoneText3.Text = ""
	self.sound = milestoneScreen:WaitForChild("Sound")
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "StartMilestoneScreen", function(p)
		self:ShowMilestoneScreen(p)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v