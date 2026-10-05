local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
return function(p)
	local cframe = CFrame.new(p.Origin)

	if (cframe.p - workspace.CurrentCamera.CFrame.p).Magnitude > 700 then
		return
	end

	Util.Sound:Play("GenesisFire", cframe)
	local folder = Instance.new("Folder", workspace._WorldOrigin)
	folder.Name = "effs"
	local clone = script.GravityBallShockwave:Clone()
	clone.Parent = folder
	clone.CFrame = cframe * CFrame.new(0, 10, 0)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(5, 110, 5),
		CFrame = cframe * CFrame.new(0, 60, 0)
	}):Play()
	wait()
	local clone2 = script.Gravity1BallShockwave:Clone()
	clone2.CFrame = cframe * CFrame.new(0, 7.5, 0)
	clone2.Parent = folder
	TweenService:Create(clone2, tweenInfo, {
		Size = createVector(18, 1.596, 18),
		CFrame = cframe * CFrame.new(0, 15, 0)
	}):Play()
	wait()
	local clone3 = script.Gravity2BallShockwave:Clone()
	clone3.CFrame = cframe * CFrame.new(0, 12.5, 0)
	clone3.Parent = folder
	TweenService:Create(clone3, tweenInfo, {
		Size = createVector(22.5, 1.9949999, 22.5),
		CFrame = cframe * CFrame.new(0, 25, 0)
	}):Play()
	wait()
	local clone4 = script.Gravity3BallShockwave:Clone()
	clone4.CFrame = cframe * CFrame.new(0, 17.5, 0)
	clone4.Parent = folder
	TweenService:Create(clone4, tweenInfo, {
		Size = createVector(27, 2.394, 27),
		CFrame = cframe * CFrame.new(0, 35, 0)
	}):Play()
	wait()
	local clone5 = script.Gravity4BallShockwave:Clone()
	clone5.CFrame = cframe * CFrame.new(0, 22.5, 0)
	clone5.Parent = folder
	TweenService:Create(clone5, tweenInfo, {
		Size = createVector(31.5, 2.793, 31.5),
		CFrame = cframe * CFrame.new(0, 45, 0)
	}):Play()
	task.delay(0.7, function()
		TweenService:Create(clone2, tweenInfo2, {
			Transparency = 1
		}):Play()
		wait()
		TweenService:Create(clone3, tweenInfo2, {
			Transparency = 1
		}):Play()
		wait()
		TweenService:Create(clone4, tweenInfo2, {
			Transparency = 1
		}):Play()
		wait()
		TweenService:Create(clone5, tweenInfo2, {
			Transparency = 1
		}):Play()
		wait()
		TweenService:Create(clone, tweenInfo2, {
			Size = clone.Size * createVector(0, 1, 0)
		}):Play()
		task.delay(0.5, function()
			folder:Destroy()
		end)
	end)
end