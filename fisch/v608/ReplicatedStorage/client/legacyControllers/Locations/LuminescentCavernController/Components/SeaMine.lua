game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local module = require("../LocalDataState")
local module2 = require("../Utility")
local v = Component.new({
	Tag = LuminescentCavern.Enums.CollectionService.SeaMine,
	Ancestors = { Workspace }
})

function v:Construct()
	self.DataObserver = module:observe(function(p)
		if self.Instance:IsDescendantOf(Workspace) and not module2.IsCrackVFXRunning() and module2.IsPlacementsFinished(p) then
			self:TweenToRed().Completed:Connect(function()
				self:CreateExplosion()
				self:DestroyMineAndCrackBlocker()
			end)

			if self.DataObserver then
				self.DataObserver()
				self.DataObserver = nil
			end
		end
	end, true)
end

function v:TweenToRed()
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local v2 = {
		Color = Color3.fromRGB(255, 0, 0)
	}

	if self.Instance:IsA("Model") then
		local v3 = {}

		for _, part in ipairs(self.Instance:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(v3, (TweenService:Create(part, tweenInfo, v2)))
			end
		end

		for _, v4 in ipairs(v3) do
			v4:Play()
		end

		return v3[1] or TweenService:Create(Instance.new("Part"), tweenInfo, v2)
	else
		local tween = TweenService:Create(self.Instance, tweenInfo, v2)
		tween:Play()
		return tween
	end
end

function v:CreateExplosion()
	local explosion = Instance.new("Explosion")
	explosion.Position = self.Instance:IsA("Model") and self.Instance:GetPivot().Position or self.Instance.Position
	explosion.BlastRadius = 10
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = Workspace
end

function v:DestroyMineAndCrackBlocker()
	if self.Instance:IsDescendantOf(Workspace) then
		self.Instance:Destroy()
	end

	local tagged = CollectionService:GetTagged(LuminescentCavern.Enums.CollectionService.CrackBlocker)

	for _, v2 in tagged do
		v2:Destroy()
	end
end

function v:Stop()
	if self.DataObserver then
		self.DataObserver()
		self.DataObserver = nil
	end
end

return v