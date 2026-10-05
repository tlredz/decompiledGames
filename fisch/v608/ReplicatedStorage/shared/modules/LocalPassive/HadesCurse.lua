local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local Net = require(ReplicatedStorage.packages.Net)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
require(ReplicatedStorage.shared.modules.fx)
local InventoryController = require(ReplicatedStorage.client.legacyControllers.InventoryController)
local EnvironmentResourceController = require(ReplicatedStorage.client.legacyControllers.EnvironmentResourceController)
local module = require("./PassiveHandler")
local remoteEvent = Net:RemoteEvent("HadesCurse/Update")
ReplicatedStorage:WaitForChild("world")
local v = nil
local HadesCurse = {
	NoMock = true,
	AddChange = function(self, p2)
		for _, parent in self.ChangeGuis do
			local clone

			if p2.Change > self.config.SpecialThreshold then
				clone = script.changeEntrySpecial:Clone()
			elseif p2.Change >= 0 then
				clone = script.changeEntry:Clone()
			else
				clone = script.changeEntryNegative:Clone()
			end

			clone.changeLabel.TextTransparency = 1
			clone.changeLabel.UIStroke.Transparency = 1
			clone.changeLabel.Position = UDim2.fromScale(0, 5)
			clone.changeLabel.Text = string.format("%+d%% %s", p2.Change, p2.Name)
			clone.Parent = parent
			TweenService:Create(clone.changeLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				Position = UDim2.new(),
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.changeLabel.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				Transparency = 0
			}):Play()
			task.delay(2.5, function()
				if not clone.Parent then
					return
				end

				TweenService:Create(clone.changeLabel, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					TextTransparency = 1
				}):Play()
				TweenService:Create(clone.changeLabel.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				task.wait(2)

				if not clone.Parent then
					return
				end

				clone:Destroy()
			end)
		end
	end,
	HandleUpdate = function(self, data)
		self.StartTime = data.StartTime
		self.EndTime = data.EndTime

		for _, newChange in data.NewChanges do
			self:AddChange(newChange)
			task.wait(0.1)
		end
	end,
	Update = function(self, p: number)
		if not self.StartTime then
			return
		end

		local v2 = math.clamp(math.map(workspace:GetServerTimeNow(), self.StartTime, self.EndTime, 0, 1), 0, 1)
		local smoothDamp, barVelocity = TweenService:SmoothDamp(self._BarSize, v2, self._BarVelocity, 0.25, nil, p)
		self._BarSize = smoothDamp
		self._BarVelocity = barVelocity

		for _, v4 in self.BarGuis do
			if InventoryController.EquippedTool and rods[InventoryController.EquippedTool.Name] and self.StartTime then
				v4.Visible = true
				v4.inner.bg.Bar.Size = UDim2.fromScale(1, self._BarSize)

				if workspace:GetServerTimeNow() >= self.EndTime then
					if not self.LastActive then
						script.readyCue:Play()
					end

					self.LastActive = true
					v4.inner.shine.Visible = true
					local imageTransparency = math.abs(1 - tick() % 2)
					v4.inner.shine.ImageTransparency = imageTransparency
				else
					v4.inner.shine.Visible = false
					self.LastActive = false
				end
			else
				v4.Visible = false
			end
		end
	end,
	new = function(p, config, env)
		local object = setmetatable({}, {
			__index = p
		})
		object.config = config
		object.trove = Trove.new()
		object.reelTrove = object.trove:Extend()
		object.env = env
		object.uid = game.HttpService:GenerateGUID(false)
		object.trove:Extend()
		object._BarVelocity = 0
		object._BarSize = 0
		object.trove:Add(remoteEvent.OnClientEvent:Connect(function(p2)
			object:HandleUpdate(p2)
			v = {
				StartTime = p2.StartTime,
				EndTime = p2.EndTime,
				NewChanges = {}
			}
		end))
		local v2 = object.trove:Add(script.barTemplate:Clone())
		local v3 = object.trove:Add(script.barTemplate:Clone())
		local v4 = object.trove:Add(script.changesTemplate:Clone())
		local v5 = object.trove:Add(script.changesTemplate:Clone())
		v2.LayoutOrder *= -1
		v4.LayoutOrder *= -1
		EnvironmentResourceController:AddCustomEntry(v2, v3, false)
		EnvironmentResourceController:AddCustomEntry(v4, v5, false)
		object.BarGuis = { v2, v3 }
		object.ChangeGuis = { v4, v5 }
		object.trove:Add(RunService.RenderStepped:Connect(function(dt: number)
			object:Update(dt)
		end))

		if v then
			object:HandleUpdate(v)
		end

		return object
	end
}
setmetatable(HadesCurse, module)
return HadesCurse