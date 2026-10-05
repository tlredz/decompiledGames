local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "FireHealthBar"
})
local tweenInfo = TweenInfo.new(0.5)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:UpdateHealth(p2: number, p3: number, flag: boolean?)
	if flag then
		TweenService:Create(self.Instance.ProgressBar.Fillbar, tweenInfo, {
			Size = UDim2.fromScale(p2 / p3, 1)
		}):Play()
	else
		self.Instance.ProgressBar.Fillbar.Size = UDim2.fromScale(p2 / p3, 1)
	end

	self.Instance.ProgressBar.ProgressText.Text = math.round(p2)
end

function v:Start()
	self._Janitor:Add(Remotes.connect("SetFireHealthVisible", function(flag: boolean, p: number?, p2: number?)
		if flag and p and p2 and p > 0 then
			self:UpdateHealth(p, p2, false)
			self.Instance.Visible = true
		else
			self.Instance.Visible = false
		end
	end))
	self._Janitor:Add(Remotes.connect("UpdateFireHealth", function(p: number, p2: number)
		if p <= 0 then
			self.Instance.Visible = false
		else
			self:UpdateHealth(p, p2, true)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v