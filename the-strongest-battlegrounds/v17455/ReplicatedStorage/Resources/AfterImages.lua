local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local function Tween(...)
	local tween = TweenService:Create(...)
	tween:Play()
	tween:Destroy()
end

local function Debris(p, value: number?)
	return task.delay(value or 0, p.Destroy, p)
end

local screenGuiTemplate = script:WaitForChild("ScreenGuiTemplate")
local AfterImages = {}
AfterImages.__index = AfterImages

function AfterImages:new(p2, p3)
	self.Archivable = true
	local player = p3.Player
	local clone = screenGuiTemplate:Clone()
	clone.Name = `AfterImages-{HttpService:GenerateGUID()}`
	clone.Enabled = true
	clone.Parent = player and player.PlayerGui or StarterGui
	local object = setmetatable({
		Model = self,
		ScreenGui = clone,
		ViewportFrame = clone.ViewportFrame
	}, AfterImages)
	object:Toggle(false)
	object:SetCamera(p2)
	object:SetOptions(p3)
	return object
end

function AfterImages:SetOptions(options)
	self.Options = options
end

function AfterImages:GetOptions()
	return self.Options
end

function AfterImages:SetCamera(p2)
	self.Camera = p2
	self.ViewportFrame.CurrentCamera = p2
end

function AfterImages:Toggle(enabled: boolean)
	if enabled == self.Enabled then
		return
	end

	self.Enabled = enabled

	if enabled then
		local total = 0
		self.Connection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total < self:GetOptions().TimeBetween then
				return
			end

			total = 0
			self:Create()
		end)
	elseif self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
end

function AfterImages:Create()
	local options = self:GetOptions()
	local clone = self.ViewportFrame:Clone()
	clone.CurrentCamera = self.ViewportFrame.CurrentCamera
	clone.ImageTransparency = options.StartTransparency
	clone.ImageColor3 = options.StartColor
	clone.Parent = self.ScreenGui
	local clone2 = self.Model:Clone()

	for _, child in clone2:GetChildren() do
		if child:IsA("BasePart") or child:IsA("Accessory") or child:IsA("Pants") or child:IsA("Shirt") or child:IsA("Humanoid") then
			continue
		end

		child:Destroy()
	end

	clone2.Parent = clone
	Tween(clone, TweenInfo.new(options.LifeTime / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		ImageColor3 = options.EndColor
	})
	Tween(clone, TweenInfo.new(options.LifeTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	})
	local lifeTime = options.LifeTime
	task.delay(lifeTime or 0, clone.Destroy, clone)
end

function AfterImages:Destroy()
	local _ = self.ScreenGui
	local screenGui = self.ScreenGui
	local v = self:GetOptions().LifeTime + 1.5
	task.delay(v or 0, screenGui.Destroy, screenGui)
	self:Toggle(false)
	table.clear(self)
end

return AfterImages