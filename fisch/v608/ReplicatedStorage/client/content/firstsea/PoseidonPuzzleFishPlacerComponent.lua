local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.shared.modules
local fish = require(modules.library.fish)
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local assets = require(ReplicatedStorage.shared.utils.assets)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local remoteEvent = Net:RemoteEvent("PoseidonPuzzleService/PlaceFish")
local remoteFunction = Net:RemoteFunction("PoseidonPuzzleService/RequestInfo")
Net:RemoteEvent("PoseidonPuzzleService/RequestInfo")
local v = Component.new({
	Tag = "PoseidonPuzzleFishPlacer"
})

function v:TogglePrompt(enabled: boolean)
	local proximityPrompt = self.Instance:FindFirstChild("ProximityPrompt")

	if not proximityPrompt then
		return
	end

	proximityPrompt.Enabled = enabled
end

function v:Tick(_: number)
	local now = os.clock()
	self.lastTick = self.lastTick or 0

	if now - self.lastTick < 1 then
		return
	end

	self.lastTick = now
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	if self.fishPlaced == true then
		self:TogglePrompt(false)
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return self:TogglePrompt(false)
	end

	local itemFromLink = DataController.getItemFromLink(tool)

	if not (itemFromLink and fish[itemFromLink.name]) then
		return self:TogglePrompt(false)
	end

	self:TogglePrompt(true)
end

function v:Update(p, flag: boolean, flag2: boolean)
	if p and p.Fish then
		if self.fishPlaced == true then
			return
		end

		self.fishPlaced = true
		local root = self.Instance:WaitForChild("Root")
		local clone = assets.getAsync("fish", p.Fish.Name):Clone()
		clone.Name = "Fish"
		clone.Parent = self.Instance
		local extentsSize = clone:GetExtentsSize()
		clone:ScaleTo(math.min(
			6.004677772521973 / extentsSize.X,
			3.8849878311157227 / extentsSize.Y,
			10.292858123779297 / extentsSize.Z
		) * clone:GetScale())
		local extentsSize2 = clone:GetExtentsSize()
		clone.handle.Anchored = true
		local v2 = self.Instance.Root.CFrame * CFrame.new(0, extentsSize2.Y / 1.5, 0)
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
			local now = os.clock()
			local v3 = 0.08726646259971647 * now
			local v4 = math.sin(now * 2) * 0.2
			local cFrame = v2 * CFrame.new(0, v4, 0) * CFrame.Angles(0, v3, 0)

			if clone and clone.Parent and clone.PrimaryPart then
				clone.PrimaryPart.CFrame = cFrame
			else
				renderSteppedConnection:Disconnect()
			end
		end)

		if flag == true then
			self.fishTrove:Add(clone)
			self.fishTrove:Add(renderSteppedConnection)
		end

		if flag2 == true or flag2 == false then
			local _, _ = pcall(function()
				task.wait(2)

				if not (clone and clone.Parent) then
					return
				end

				local highlight = Instance.new("Highlight")
				highlight.OutlineTransparency = 1
				highlight.FillTransparency = 0.3
				highlight.FillColor = flag2 == true and Color3.fromRGB(0, 110, 255) or Color3.fromRGB(255, 0, 0)
				highlight.Parent = clone
				local child = root and root.Parent and root:FindFirstChild(flag2 == true and "Success" or "Error")

				if child then
					child:Play()
				end

				task.wait(0.5)
				highlight:Destroy()

				if flag2 ~= false then
					return
				end

				self.fishPlaced = false

				if clone and clone.Parent then
					renderSteppedConnection:Disconnect()
					clone:Destroy()
				end
			end)
		end
	else
		self.fishTrove:Clean()
		self.fishPlaced = false
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.fishTrove = Trove.new()
	self.fishPlaced = false
	self.trove:Add(self.fishTrove, "Destroy")
end

function v:Start()
	self:Update((remoteFunction:InvokeServer(self.Instance.Name)))
	self.trove:Add(RunService.Stepped:Connect(function(_, dt)
		self:Tick(dt)
	end))
	local proximityPrompt = self.Instance:WaitForChild("ProximityPrompt")
	self.trove:Add(proximityPrompt.Triggered:Connect(function()
		remoteEvent:FireServer(self.Instance.Name)
	end))
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p: string, p2, flag: boolean, flag2: boolean?)
		if self.Instance.Name ~= p then
			return
		end

		self:Update(p2, flag, flag2)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v