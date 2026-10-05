local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "LazyLoadModelTransparencySetter"
})
local v2 = false
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

local function getAncestorGuid(instance)
	local parent = instance.Parent

	while parent ~= nil do
		local lazyLoadModelGuid = parent:GetAttribute("lazyLoadModelGuid")

		if typeof(lazyLoadModelGuid) == "string" then
			return lazyLoadModelGuid
		else
			parent = parent.Parent
		end
	end

	return nil
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local LazyLoadModelController = require(ReplicatedStorage.Modules.Client.LazyLoad.LazyLoadModelController)
	v2 = LazyLoadModelController
	self.currentTransparency = self.Instance.Transparency
	self.startsCollidable = self.Instance:IsA("BasePart") and self.Instance.CanCollide
	self.Instance.Transparency = 0
	local ancestorGuid = getAncestorGuid(self.Instance)

	if ancestorGuid == nil then
		ancestorGuid = v2.GetGuidForInstance(self.Instance)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setLoaded()
		TweenService:Create(self.Instance, tweenInfo, {
			Transparency = self.currentTransparency
		}):Play()

		if self.startsCollidable then
			self.Instance.CanCollide = false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setUnloaded()
		TweenService:Create(self.Instance, tweenInfo2, {
			Transparency = 0
		}):Play()

		if self.startsCollidable then
			self.Instance.CanCollide = true
		end
	end

	self._Janitor:Add(v2.OnModelReceived:Connect(function(ancestor, p: string)
		if ancestor ~= nil and self.Instance:IsDescendantOf(ancestor) then
			ancestorGuid = p
			setLoaded() -- equivalent call inferred; original call site unknown
		end
	end))
	self._Janitor:Add(v2.OnModelDestroyed:Connect(function(p: string)
		if ancestorGuid ~= nil and p == ancestorGuid then
			setUnloaded() -- equivalent call inferred; original call site unknown
		end
	end))

	if ancestorGuid == nil or v2.GetLazyModel(ancestorGuid) == nil then
		setUnloaded() -- equivalent call inferred; original call site unknown
	else
		setLoaded() -- equivalent call inferred; original call site unknown
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v