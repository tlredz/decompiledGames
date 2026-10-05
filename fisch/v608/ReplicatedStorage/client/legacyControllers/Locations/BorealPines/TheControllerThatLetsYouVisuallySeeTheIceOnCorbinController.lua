local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local modules = ReplicatedStorage.client.modules
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
local Observers = require(ReplicatedStorage.packages.Observers)
workspace:WaitForChild("world")
local v = nil
local track = nil
local fetched = nil
local cache = nil
local corbinIceProgress = nil
local part = nil

local function UpdateCorbinIce()
	if not v then
		return
	end

	local value = corbinIceProgress ~= nil and corbinIceProgress.Value or 0
	local boundingBox, v2 = v:GetBoundingBox()
	local cFrame = CFrame.new(boundingBox.X, boundingBox.Y, boundingBox.Z) * CFrame.Angles(0, 1.5707963267948966, 0)
	local size = v2 + createVector(4, 4, 4)
	local proximityPrompt = v:FindFirstChildOfClass("ProximityPrompt")

	if proximityPrompt and value < 15 then
		proximityPrompt.Enabled = false
	end

	if not part then
		part = Instance.new("Part")
		part.Name = "CorbinIce"
		part.Material = Enum.Material.Glacier
		part.Anchored = true
		part.Color = Color3.fromRGB(140, 180, 255)
		part.Transparency = 0.8
		part.CanCollide = false
		part.Size = size
		part.Parent = workspace
		part.CFrame = cFrame
	end

	local v5 = -(value / 15 * 4)
	TweenService:Create(part, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = value < 15 and size + Vector3.new(v5, v5, v5) or createVector(0, 0, 0),
		CFrame = cFrame
	}):Play()

	if proximityPrompt and value >= 15 then
		task.spawn(function()
			task.wait(1)
			proximityPrompt.Enabled = true
			track:AdjustSpeed(1)
		end)
	end
end

local function ConnectIceProgress()
	if not corbinIceProgress then
		return
	end

	UpdateCorbinIce()
	corbinIceProgress:GetPropertyChangedSignal("Value"):Connect(UpdateCorbinIce)
end

return {
	Start = function(_)
		Observers.observeTag("CorbinNpc", function(p)
			v = p
			track = v:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation((v:FindFirstChild("chilly")))
			track.Looped = true
			track:Play(0)
			track:AdjustSpeed(0)
			fetched = legacyLocalPlayerData.fetch()
			cache = fetched:FindFirstChild("Cache")
			corbinIceProgress = cache:FindFirstChild("CorbinIceProgress")
			UpdateCorbinIce()

			if corbinIceProgress then
				task.spawn(ConnectIceProgress)
				return
			end

			local childAddedConnection = nil
			childAddedConnection = cache.ChildAdded:Connect(function(child)
				if child.Name ~= "CorbinIceProgress" then
					return
				end

				corbinIceProgress = cache:FindFirstChild("CorbinIceProgress")
				task.spawn(ConnectIceProgress)
				childAddedConnection:Disconnect()
			end)
		end)
	end
}