local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
return {
	setupAll = function()
		local gui = GameContext.Gui
		local menu = gui:WaitForChild("Menu")
		local floorNumber = menu:WaitForChild("FloorNumber")
		local backgroundFrame = menu:WaitForChild("BackgroundFrame")
		local generatorFrame = menu:WaitForChild("GeneratorFrame")
		local startNewRoom = gui:WaitForChild("StartNewRoom")
		local position = floorNumber.Position

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshFloorLabel()
			if workspace.Info:GetAttribute("InBreakRoom") == true then
				floorNumber.Text = "BREAK ROOM"
			else
				floorNumber.Text = "FLOOR " .. workspace.Info.Floor.Value
			end
		end

		local function onFloorChanged()
			refreshFloorLabel() -- equivalent call inferred; original call site unknown
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			floorNumber.Position = UDim2.new(0.246, 0, 0, 0)
			TweenService:Create(floorNumber, tweenInfo, {
				Position = position
			}):Play()
		end

		local function onFloorActiveChanged(p)
			local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

			if p == true then
				backgroundFrame.Visible = false
				startNewRoom:Play()
				local v = workspace.Info.GeneratorsCompleted.Value / workspace.Info.RequiredGenerators.Value
				generatorFrame.Message.Text = "Machines Completed: " .. workspace.Info.GeneratorsCompleted.Value .. "/" .. workspace.Info.RequiredGenerators.Value
				TweenService:Create(generatorFrame.CurrentAmount, tweenInfo, {
					Size = UDim2.new(math.clamp(v, 0, 1), 0, 1, 0)
				}):Play()
			else
				generatorFrame.Message.Text = "Intermission"
				TweenService:Create(generatorFrame.CurrentAmount, tweenInfo, {
					Size = UDim2.new(0, 0, 1, 0)
				}):Play()
			end
		end

		workspace.Info.Floor.Changed:Connect(onFloorChanged)
		workspace.Info.FloorActive.Changed:Connect(onFloorActiveChanged)
		workspace.Info:GetAttributeChangedSignal("InBreakRoom"):Connect(refreshFloorLabel)

		if workspace.Info.Floor.Value > 0 then
			onFloorChanged()
		end

		if workspace.Info.FloorActive.Value == true then
			onFloorActiveChanged(true)
		end
	end
}