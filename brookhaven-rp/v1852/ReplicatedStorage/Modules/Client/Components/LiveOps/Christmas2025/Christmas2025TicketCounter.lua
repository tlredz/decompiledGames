local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local NumberUtil = require(ReplicatedStorage.Modules.Shared.Utils.NumberUtil)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Christmas2025TicketCounter"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

local clone = nil

function v:QueuedTicketCountUpdated(p: number?)
	if not clone then
		local GUID = HttpService:GenerateGUID(false)
		self.queueAnimGUID = GUID
		clone = self.Instance:WaitForChild("TicketChangedEffect"):Clone()
		clone.Parent = self.Instance
		clone.Visible = true
		local mover = clone:WaitForChild("Mover")
		local imageLabel = mover:WaitForChild("ImageLabel")
		local amountChangedLabel = mover:WaitForChild("AmountChangedLabel")
		amountChangedLabel.TextColor3 = Color3.new(0.75, 1, 0.75)
		local now = 0
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		numberValue.Changed:Connect(function()
			if self.queueAnimGUID == GUID then
				local value = math.round(numberValue.Value)

				if `+{value}` ~= amountChangedLabel.Text then
					if tick() - now > 0.2 then
						now = tick()
						local instance = Instance.fromExisting(imageLabel)
						Debris:AddItem(instance, 1)
						instance.Parent = imageLabel
						instance.Size = UDim2.new(1, 0, 1, 0)
						instance.Position = UDim2.new(0, 0, 0.5, 0)
						TweenService:Create(
							instance,
							TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Position = UDim2.new(
									1 + math.random(-40, 40) / 100,
									0,
									0.5 + math.random(-40, 40) / 100,
									0
								),
								ImageTransparency = 1,
								Rotation = math.random(-5, 5)
							}
						):Play()
					end

					amountChangedLabel.Text = `+{value}`
					local tween = TweenService:Create(
						mover,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
						{
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(1, 0, 1, 0)
						}
					)
					tween:Play()
					tween:Cancel()
					mover.Position = UDim2.new(0.5, 0, 0.5, 0)
					mover.Size = UDim2.new(1, 0, 1, 0)
					local v2 = 1 + math.random(0, 100) / 1000
					TweenService:Create(
						mover,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
						{
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(v2, 0, v2, 0)
						}
					):Play()
				end
			end
		end)
		numberValue.Parent = clone
	end

	TweenService:Create(
		clone:WaitForChild("Value"),
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Value = p
		}
	):Play()
end

function v:TicketCountUpdated(p: number?)
	local amountLabel = self.Instance:WaitForChild("AmountLabel")
	local flag

	if clone then
		flag = true
		Debris:AddItem(clone, 0)
		clone = nil
	else
		flag = false
	end

	if not p then
		amountLabel.Text = NumberUtil.Commas((tostring(self._currentTicketCount)))
		return
	end

	local v2 = self._currentTicketCount - p

	if v2 > 0 then
		local v3 = math.clamp(v2 / 25, 0.25, 2.8)
		local GUID = HttpService:GenerateGUID(false)
		self.animationGUID = GUID
		local clone2 = self.Instance:WaitForChild("TicketChangedEffect"):Clone()
		Debris:AddItem(clone2, v3 + 2.2)
		clone2.Parent = self.Instance
		clone2.Visible = true
		local mover = clone2:WaitForChild("Mover")
		local amountChangedLabel = mover:WaitForChild("AmountChangedLabel")
		local imageLabel = mover:WaitForChild("ImageLabel")
		amountChangedLabel.TextColor3 = Color3.new(0.75, 1, 0.75)
		local now = 0
		local numberValue = Instance.new("NumberValue")
		Debris:AddItem(numberValue, v3)
		numberValue.Value = 0
		numberValue.Changed:Connect(function()
			if self.animationGUID == GUID then
				local value = math.round(numberValue.Value)

				if `+{value}` ~= amountChangedLabel.Text then
					if tick() - now > 0.2 then
						now = tick()
						local instance = Instance.fromExisting(imageLabel)
						Debris:AddItem(instance, 1)
						instance.Parent = imageLabel
						instance.Size = UDim2.new(1, 0, 1, 0)
						instance.Position = UDim2.new(0, 0, 0.5, 0)
						TweenService:Create(
							instance,
							TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Position = UDim2.new(
									1 + math.random(-40, 40) / 100,
									0,
									0.5 + math.random(-40, 40) / 100,
									0
								),
								ImageTransparency = 1,
								Rotation = math.random(-5, 5)
							}
						):Play()
					end

					amountChangedLabel.Text = `+{value}`
					local tween = TweenService:Create(
						mover,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
						{
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(1, 0, 1, 0)
						}
					)
					tween:Play()
					tween:Cancel()
					mover.Position = UDim2.new(0.5, 0, 0.5, 0)
					mover.Size = UDim2.new(1, 0, 1, 0)
					local v4 = 1 + math.random(0, 100) / 1000
					TweenService:Create(
						mover,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
						{
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(v4, 0, v4, 0)
						}
					):Play()
				end
			end
		end)

		if flag then
			numberValue.Value = v2
		else
			TweenService:Create(numberValue, TweenInfo.new(v3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				Value = v2
			}):Play()
		end

		local _currentTicketCount = self._currentTicketCount
		task.delay(v3 + 1.5, function()
			TweenService:Create(mover, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = UDim2.new(1.5, 0, 0.5, 0),
				Transparency = 1,
				Rotation = 15
			}):Play()
			TweenService:Create(
				amountChangedLabel,
				TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{
					TextTransparency = 1
				}
			):Play()
			TweenService:Create(imageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				ImageTransparency = 1
			}):Play()
			task.wait(0.7)
			mover.Visible = false
			amountLabel.Text = NumberUtil.Commas((tostring(_currentTicketCount)))
			amountLabel.TextColor3 = Color3.new(0, 0.75, 0)
			amountLabel.Size = UDim2.new(0.7, 0, 1.1, 0)
			TweenService:Create(amountLabel, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				TextColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(0.65, 0, 1, 0)
			}):Play()
		end)
	else
		self.animationGUID = HttpService:GenerateGUID(false)
		local clone2 = self.Instance:WaitForChild("TicketChangedEffect"):Clone()
		Debris:AddItem(clone2, 2.2)
		clone2.Parent = self.Instance
		clone2.Visible = true
		local mover = clone2:WaitForChild("Mover")
		local amountChangedLabel = mover:WaitForChild("AmountChangedLabel")
		local imageLabel = mover:WaitForChild("ImageLabel")
		amountChangedLabel.Text = tostring(v2)
		amountChangedLabel.TextColor3 = Color3.new(1, 0.75, 0.75)
		local _currentTicketCount = self._currentTicketCount
		task.delay(1.5, function()
			TweenService:Create(mover, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = UDim2.new(1.5, 0, 0.5, 0),
				Transparency = 1,
				Rotation = 15
			}):Play()
			TweenService:Create(
				amountChangedLabel,
				TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{
					TextTransparency = 1
				}
			):Play()
			TweenService:Create(imageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				ImageTransparency = 1
			}):Play()
			task.wait(0.7)
			mover.Visible = false
			amountLabel.Text = NumberUtil.Commas((tostring(_currentTicketCount)))
			amountLabel.TextColor3 = Color3.new(0.75, 0, 0)
			amountLabel.Size = UDim2.new(0.6, 0, 0.9, 0)
			TweenService:Create(amountLabel, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				TextColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(0.65, 0, 1, 0)
			}):Play()
		end)
	end
end

function v:CharAdded(instance)
	if instance then
		self._Janitor:Add(instance:GetAttributeChangedSignal("SkateFlakes"):Connect(function()
			local skateFlakes = instance:GetAttribute("SkateFlakes") or 0

			if skateFlakes > 0 then
				self:QueuedTicketCountUpdated(skateFlakes)
			end
		end), "Disconnect")
	end
end

function v:Start()
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object2)
		self._currentTicketCount = object2.Data.LiveOpsEventData.Christmas2025.Snowflakes
		self._Janitor:Add(object2:OnSet({ "LiveOpsEventData", "Christmas2025", "Snowflakes" }, function()
			local _currentTicketCount = self._currentTicketCount
			self._currentTicketCount = object2.Data.LiveOpsEventData.Christmas2025.Snowflakes
			self:TicketCountUpdated(_currentTicketCount)
		end), "Disconnect")
		local amountLabel = self.Instance:WaitForChild("AmountLabel")
		amountLabel.Text = NumberUtil.Commas((tostring(self._currentTicketCount)))
	end)
	self._Janitor:Add(Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:CharAdded(character)
	end), "Disconnect")

	if Players.LocalPlayer.Character then
		self:CharAdded(Players.LocalPlayer.Character)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v