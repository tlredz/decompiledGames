local Component = require(game.ReplicatedStorage.Modules.Component)
require(game.ReplicatedStorage.Util.Signal2)
require(game.ReplicatedStorage.Types.SlappingArenaTypes)
local Maid = require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.Util.IsTransformed)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local slappingArena = IrisLog.new("SlappingArena", nil, {
	Hidden = true
})
local v = Component.new({
	Tag = "SlappingArenaRemoteEvent",
	Ancestors = { game.Players.LocalPlayer }
})
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local function getColorFromValue(p)
	return Color3.new(0, 1, 0):Lerp(Color3.new(1, 0, 0), math.abs(0.5 - p) * 2)
end

function v:setSlapText(text)
	self.Gui.SlapButton.TextLabel.Text = text
	self.Gui.SlapButton.TextLabel.TextLabel.Text = text
end

function v:UpdateBarHeight(value: number, value2: number)
	if self.Gui then
		self.Gui.Bar.Tick.Position = UDim2.new(0.5, 0, math.clamp(value, 0, 1), 0)
		self.Gui.Bar.GreenZone.Position = UDim2.new(0, 0, math.clamp(value2, 0, 1), 0)
	end
end

function v:startBar(p, p2, p3, p4, p5, value, p6)
	local _ = workspace:GetServerTimeNow() - p
	local v2 = p2 * 0.5
	local v3 = p2 * 0.5 * 3
	local v4 = 0.96 / v2
	local v5 = 0.19999999999999996 / v3

	local function getBarPos(p7: number)
		local v6 = 0.02 + (p7 - p) % p2 * v4

		if v6 < 0.98 then
			return v6
		end

		return 0.98 - (v6 - 0.98)
	end

	local function getGreenZonePos(p7: number)
		local v6 = 0.4 + (p7 - p) % (p2 * 3) * v5

		if v6 < 0.6 then
			return v6
		end

		return 0.6 - (v6 - 0.6)
	end

	if p3 ~= game.Players.LocalPlayer then
		return
	end

	local clone = script.FishSlapMinigame:Clone()

	if p5 then
		local finishHimTextLabel = clone.FinishHimTextLabel
		self.Maid.FinishText = finishHimTextLabel
		finishHimTextLabel.Visible = true
		local children = { finishHimTextLabel, finishHimTextLabel.TextLabel }
		local descendants = {}

		for _, child in finishHimTextLabel.TextLabel:GetChildren() do
			if child.Name == "TextLabel" then
				table.insert(children, child)
			end
		end

		for _, descendant in finishHimTextLabel:GetDescendants() do
			if descendant:IsA("UIGradient") or descendant:IsA("UIStroke") then
				table.insert(descendants, descendant)
			end
		end

		self.Maid:GiveTask(task.spawn(function()
			while task.wait() do
				for _, v6 in children do
					v6.TextTransparency = (math.sin(os.clock() * 5) + 1) / 2 * 1
				end

				for _, uIGradient in descendants do
					if uIGradient:IsA("UIGradient") then
						uIGradient.Transparency = NumberSequence.new((math.sin(os.clock() * 5) + 1) / 2 * 1)
					else
						uIGradient.Transparency = (math.sin(os.clock() * 5) + 1) / 2 * 1
					end
				end
			end
		end))
	end

	clone.Bar.GreenZone.Size = UDim2.new(1, 0, p4 * 2, 0)
	clone.Parent = game.Players.LocalPlayer.PlayerGui
	clone:SetAttribute("IsLocal", p3 == game.Players.LocalPlayer)
	self.Gui = clone
	local maid = self.Maid
	local RunService = game:GetService("RunService")
	maid.UpdateBar = RunService.Heartbeat:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v6 = self
		local v7 = self
		local barpos = 0.02 + (serverTimeNow - p) % p2 * v4

		if not (barpos < 0.98) then
			barpos = 0.98 - (barpos - 0.98)
		end

		local greenpos

		if p6 then
			greenpos = 0.5
		else
			greenpos = 0.4 + (serverTimeNow - p) % (p2 * 3) * v5

			if not (greenpos < 0.6) then
				greenpos = 0.6 - (greenpos - 0.6)
			end
		end

		v6.barpos = barpos
		v7.greenpos = greenpos
		self:UpdateBarHeight(self.barpos, self.greenpos)
	end)
	self:setSlapText(value or "SLAP!")
	clone.SlapButton.Activated:Connect(function()
		self.Instance:FireServer("Jump", workspace:GetServerTimeNow())

		if self.Gui and self.Gui:GetAttribute("IsLocal") then
			self.Maid.UpdateBar = nil
			self.Maid.FinishText = nil
		end
	end)

	function self.Maid.Bar()
		clone:Destroy()
		self.Gui = nil
		self.Maid.UpdateBar = nil
	end
end

function v:Start()
	self.Maid = Maid.new()
	self.Maid:GiveTask(game.Players.LocalPlayer.Character.Humanoid.Jumping:Connect(function()
		self.Instance:FireServer("Jump", workspace:GetServerTimeNow())
	end))
	self.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, _)
		if input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.Space then
			self.Instance:FireServer("Jump", workspace:GetServerTimeNow())

			if self.Gui and self.Gui:GetAttribute("IsLocal") then
				self.Maid.UpdateBar = nil
				self.Maid.FinishText = nil
			end
		end
	end))
	local maid = self.Maid
	local UserInputService2 = game:GetService("UserInputService")
	maid:GiveTask(UserInputService2.JumpRequest:Connect(function()
		self.Instance:FireServer("Jump", workspace:GetServerTimeNow())

		if self.Gui and self.Gui:GetAttribute("IsLocal") then
			self.Maid.UpdateBar = nil
			self.Maid.FinishText = nil
		end
	end))
	self.Maid:GiveTask(self.Instance.OnClientEvent:Connect(function(p, p2, p3, p4, p5, p6, p7, p8)
		if p ~= "startBar" then
			return
		end

		self.Maid.ContinueScreen = nil
		self:startBar(p2, p3, p4, p5, p6, p7, p8)
	end))
	self.Maid:GiveTask(self.Instance.OnClientEvent:Connect(function(p, _, _, _)
		if p ~= "killBar" then
			return
		end

		self.Maid.Bar = nil
		self.Maid.ContinueScreen = nil
	end))
	self.Maid:GiveTask(self.Instance.OnClientEvent:Connect(function(p, p2)
		if p ~= "continueScreen" then
			return
		end

		self.Maid.Bar = nil
		local clone = script.ContinueScreen:Clone()
		self.Maid.ContinueScreen = clone
		self.Maid:GiveTask(clone.Continue.Activated:Connect(function()
			self.Maid.ContinueScreen = nil
			self.Instance:FireServer("continueScreen", "Continue")
		end))
		self.Maid:GiveTask(clone.Exit.Activated:Connect(function()
			self.Maid.ContinueScreen = nil
			self.Instance:FireServer("continueScreen", "Exit")
		end))
		local SharkmanMasterServiceClient = require(game.ReplicatedStorage.Controllers.MapServices.SharkmanMasterServiceClient)

		for _, image in clone.belts:GetChildren() do
			if not image:IsA("ImageLabel") then
				continue
			end

			local name = tonumber(image.Name)
			local beltStage = SharkmanMasterServiceClient.BeltStages[name]

			if name < p2 then
				image.UIGradient.Enabled = false
			elseif name == p2 then
				local v2 = image
				self.Maid:GiveTask(task.spawn(function()
					local lastTime = tick()
					local v3 = lastTime + 1

					repeat
						task.wait()
						local v4 = math.clamp((tick() - lastTime) / (v3 - lastTime), 0, 1)
						v2.UIGradient.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 100):Lerp(Color3.new(1, 1, 1), v4)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0):Lerp(Color3.new(1, 1, 1), v4))
						})
						v2.UIGradient.Rotation = v4 * 720 + 90
					until v4 >= 1
				end))
				local v3 = image
				local v4 = beltStage
				self.Maid:GiveTask(task.spawn(function()
					repeat
						task.wait()
					until v3.AbsolutePosition.X ~= 0

					pcall(function()
						local Sound = require(game.ReplicatedStorage.Util.Sound)
						Sound:Play("BF_GUI_Notification_02")
					end)
					clone.passedLabel.Position = UDim2.new(
						0,
						v3.AbsolutePosition.X + v3.AbsoluteSize.X / 2,
						0,
						v3.AbsolutePosition.Y - 20
					)
					clone.passedLabel.TextColor3 = v4.Color3
					clone.passedLabel.Text = `{v4.Color} Stage Cleared!`
					local TweenService = game:GetService("TweenService")
					TweenService:Create(clone.passedLabel, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
						TextTransparency = 0,
						TextStrokeTransparency = 0
					}):Play()
				end))
			end
		end

		clone.Parent = game.Players.LocalPlayer.PlayerGui
	end))
	self:DisableMovement()
	self.ArenaInstance = self.Instance:WaitForChild("ArenaPointer").Value
end

function v:DisableMovement()
	slappingArena:Append("movement disabled.")
	self.Maid.disabledMovement = nil
	local humanoid = game.Players.LocalPlayer.Character.Humanoid
	humanoid.AutoRotate = false
	local folder = Instance.new("Folder", game.Players.LocalPlayer.Character)
	folder.Name = "DisableMovement"
	ContextActionService:BindAction("freezeMovement_game", function()
		return Enum.ContextActionResult.Sink
	end, false, unpack(Enum.PlayerActions:GetEnumItems()))

	function self.Maid.disabledMovement()
		slappingArena:Append("movement enabled.")
		folder:Destroy()
		humanoid.AutoRotate = true
		ContextActionService:UnbindAction("freezeMovement_game")
	end
end

function v.Stop(p)
	p.Maid:Destroy()
end

return v