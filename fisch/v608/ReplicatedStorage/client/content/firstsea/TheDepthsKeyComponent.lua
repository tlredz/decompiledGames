local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local theDepthsKey = ReplicatedStorage:WaitForChild("resources"):WaitForChild("models"):WaitForChild("The Depths Key")
local v = {
	Spawn = CFrame.new(25, 0, 0),
	OnPosition = CFrame.new(0, 0, 0),
	Opened = CFrame.new(0, -2, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
}
local v2 = {
	Close = CFrame.new(0, 0, 0),
	Opened = CFrame.new(0, 0, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
}
local remoteEvent = Net:RemoteEvent("OpenTheDepthsGate")
local v3 = Component.new({
	Tag = "TheDepthsKey"
})

function v3:Open()
	local parent = self.Instance.Parent
	parent:SetAttribute("Opened", true)

	if self.key then
		return
	end

	local clone = theDepthsKey:Clone()
	local transparenciesByPart = {}

	for _, part in clone:GetDescendants() do
		if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
			continue
		end

		transparenciesByPart[part] = part.Transparency
		part.Transparency = 1
	end

	clone.Parent = workspace
	local weld = Instance.new("Weld", clone)
	weld.Part0 = parent:WaitForChild("KeyPoint")
	weld.Part1 = clone:WaitForChild("Handle")
	weld.C0 = v.Spawn
	self.key = clone
	self.trove:Add(clone)
	local lock = parent:WaitForChild("Lock")
	local weld2 = lock:WaitForChild("Weld")
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)

	for k, transparency in transparenciesByPart do
		TweenService:Create(k, tweenInfo, {
			Transparency = transparency
		}):Play()
	end

	TweenService:Create(weld, tweenInfo, {
		C0 = v.OnPosition
	}):Play()
	task.wait(3)
	TweenService:Create(weld, tweenInfo, {
		C0 = v.Opened
	}):Play()
	TweenService:Create(weld2, tweenInfo, {
		C0 = v2.Opened
	}):Play()
	local sound = lock:FindFirstChildOfClass("Sound")

	if sound then
		sound:Play()
	end
end

function v3:ForceOpen()
	local parent = self.Instance.Parent
	parent:SetAttribute("Opened", true)
	local clone = theDepthsKey:Clone()
	clone.Parent = workspace
	local weld = Instance.new("Weld", clone)
	weld.Part0 = parent:WaitForChild("KeyPoint")
	weld.Part1 = clone:WaitForChild("Handle")
	weld.C0 = v.Opened
	self.key = clone
	self.trove:Add(clone)
	local weld_2 = parent:WaitForChild("Lock"):WaitForChild("Weld")
	weld_2.C0 = v2.Opened
end

function v3:Construct()
	self.trove = Trove.new()
end

function v3.Stop(p)
	p.trove:Destroy()
end

function v3:Start()
	if Net:RemoteFunction("GetDoorState"):InvokeServer("TheDepthsGate") == true then
		self:ForceOpen()
	end

	self.trove:Add(remoteEvent.OnClientEvent:Connect(function()
		self:Open()
	end))
end

return v3