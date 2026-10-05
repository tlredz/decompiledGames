local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local v = nil
local v2 = nil
local localPlayer = game.Players.LocalPlayer
local repairProgressBar = nil
local repairMiniGame = nil
local random = Random.new()
local uDim = UDim2.fromScale(0.6, 0.5)
local numberRange = NumberRange.new(0.3, 1)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.12)
local repairButton = nil
local repairButton2 = nil
local backgroundColor3 = nil
local RepairShip = {
	mode = "Default",
	fillTween = nil,
	goalTween = nil,
	gui = nil,
	fillSpeed = 0,
	miniGameSpeed = 0,
	repairSpeed = 0
}

function RepairShip.new(p)
	local miniGameSpeed = p.Instance:GetAttribute("MiniGameSpeed")
	local repairSpeed = p.Instance:GetAttribute("RepairSpeed")
	local fillSpeed = p.mode == "Minigame" and miniGameSpeed or repairSpeed

	if RepairShip.mode ~= p.mode then
		RepairShip:Close()
	end

	local gui

	if p.mode == "Minigame" then
		gui = repairMiniGame
	else
		gui = repairProgressBar
	end

	RepairShip.gui = gui
	RepairShip.bar = gui.ProgressBar
	RepairShip.mode = p.mode
	RepairShip.instance = p.Instance
	RepairShip.miniGameSpeed = miniGameSpeed
	RepairShip.repairSpeed = repairSpeed
	RepairShip.fillSpeed = fillSpeed
	return RepairShip
end

function RepairShip:Start()
	self:Cancel()
	self:Open()

	if self.mode == "Minigame" then
		local TweenService2 = game:GetService("TweenService")
		self.fillTween = TweenService2:Create(
			self.bar.Fill,
			TweenInfo.new(self.fillSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 0),
			{
				Size = UDim2.fromScale(1, 1)
			}
		)
		self.fillTween:Play()
	else
		self.fillTween = TweenService:Create(self.bar.Fill, TweenInfo.new(self.fillSpeed, Enum.EasingStyle.Linear), {
			Size = UDim2.fromScale(1, 1)
		})
		self.fillTween:Play()
	end
end

function RepairShip:Open()
	self.bar.Fill.Size = UDim2.fromScale(0, 1)
	self.gui.Visible = true
end

function RepairShip:Close()
	self:Cancel()
	self.gui.Label.Text = self.mode == "Minigame" and "Release when in green for extra HP." or "Repairing.."
	self.gui.Visible = false
	self.bar.Fill.Size = UDim2.fromScale(0, 1)
end

function RepairShip:M1Up()
	self:Cancel()
	local instance = self.instance

	if not (instance and instance.Parent) then
		return
	end

	if self.mode ~= "Minigame" then
		instance.M1UP:FireServer()
		return
	end

	local v3 = self.bar.Goal.Size.X.Scale + 0.015
	local scale = self.bar.Goal.Position.X.Scale
	local scale2 = self.bar.Fill.Size.X.Scale
	local v4 = scale - v3 * 0.5
	local v5 = scale + v3 * 0.5
	local success

	if v4 <= scale2 then
		success = scale2 <= v5
	else
		success = false
	end

	local number = random:NextNumber(numberRange.Min, numberRange.Max)
	local TweenService2 = game:GetService("TweenService")
	self.goalTween = TweenService2:Create(self.bar.Goal, tweenInfo, {
		Position = UDim2.fromScale(number, 0.5)
	})
	self.goalTween:Play()
	instance.M1UP:FireServer({
		success = success
	})
end

function RepairShip:Cancel()
	if self.fillTween then
		self.fillTween:Cancel()
		self.fillTween = nil
	end

	if self.goalTween then
		self.goalTween:Cancel()
		self.goalTween = nil
	end
end

function RepairShip:Cleanup()
	self:Close()
	self.instance = nil
end

function RepairShip:SetButtonColor(color: Color3?)
	repairButton.BackgroundColor3 = color or backgroundColor3

	if repairButton2 then
		repairButton2.BackgroundColor3 = color or backgroundColor3
	end
end

function RepairShip.OnStart(_)
	local Flags = require(game.ReplicatedStorage.Modules.Flags)
	v = Flags
	local SubclassController = require(game.ReplicatedStorage.Controllers.SubclassController)
	v2 = SubclassController
	local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
	PlayerUtil.ScreenReady({ "Main" }, function(p)
		local v3 = assert(p.Main, "bad package.Main")
		local bottomHUDList = v3:WaitForChild("BottomHUDList")

		if LastInput:IsMobile() then
			repairButton2 = v3:WaitForChild("MobileShipHealthBar"):WaitForChild("RepairButton")
		end

		repairButton = bottomHUDList:WaitForChild("ShipHealthBar"):WaitForChild("RepairButton")

		if v.SUBCLASSES_ENABLED and v.SUBCLASSES.Shipwright then
			backgroundColor3 = repairButton.BackgroundColor3
			repairProgressBar = bottomHUDList:WaitForChild("RepairProgressBar")
			repairMiniGame = bottomHUDList:WaitForChild("RepairMiniGame")
			repairMiniGame.ProgressBar.Goal.Position = uDim
			repairMiniGame.ProgressBar.Goal.Size = UDim2.fromScale(LastInput:IsMobile() and 0.12 or 0.08, 1)
			RepairShip.gui = repairProgressBar
			RepairShip.bar = repairProgressBar.ProgressBar
			local color = Color3.fromRGB(40, 218, 0)
			local maid = nil
			local flag = false

			local function equipClassChanged()
				flag = false
				local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
				local v4 = not humanoid or humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated) == true
				local subclassData = v2:GetSubclassData()
				local visible = subclassData and v4 and subclassData.Equipped == "Shipwright"
				repairButton.Visible = visible

				if repairButton2 then
					repairButton2.Visible = visible
				end

				if visible then
					if not maid then
						local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
						maid = Trove.new()

						local function clicked()
							if flag then
								return
							end

							flag = true
							RepairShip:SetButtonColor(color)

							if not v2:UseSubclass({
								Action = "RequestHammer"
							}) then
								RepairShip:SetButtonColor()
							end

							flag = false
						end

						maid:Add(repairButton.Activated:Connect(clicked))

						if repairButton2 then
							maid:Add(repairButton2.Activated:Connect(clicked))
						end
					end
				elseif maid then
					maid:Destroy()
					maid = nil
				end
			end

			local function characterAdded(instance)
				instance:WaitForChild("Humanoid").StateEnabledChanged:Connect(function(p2, _)
					if p2 == Enum.HumanoidStateType.Seated then
						equipClassChanged()
					end
				end)
				equipClassChanged()
			end

			v2:Connect("Equipped", equipClassChanged)

			if localPlayer.Character then
				task.spawn(characterAdded, localPlayer.Character)
			end

			localPlayer.CharacterAdded:Connect(characterAdded)
			return
		end

		repairButton.Visible = false

		if repairButton2 then
			repairButton2.Visible = false
		end
	end, (`Init {script.Name}`))
end

return RepairShip