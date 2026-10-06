local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
return function(p, _)
	local _ = game.Players.LocalPlayer
	local cFrame = CFrame.new(p.cf.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	local name = p.name

	if game.Players.LocalPlayer.Name == name then
		_G.shake("SmallBump")
	end

	local function getcurrentamount()
		local count = 0

		for _, folder in pairs(workspace.Effects:GetChildren()) do
			if not (folder:IsA("Folder") and string.find(folder.Name, "apollos_" .. name)) then
				continue
			end

			count += 1
		end

		return count
	end

	if getcurrentamount() > 5 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "apollos_" .. name .. getcurrentamount()
	folder.Parent = workspace.Effects
	_G.PU:Dust(folder, 2)
	local clone = replicatedStorage.Chest.SwordEffect.Apollos.slice:Clone()
	clone.Parent = folder
	clone.CFrame = cFrame * CFrame.new(0, 0, 10)
	task.spawn(function()
		local Animate = require(clone.Animate)
		Animate()
		game.TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
	end)
	local clone2 = replicatedStorage.Chest.SwordEffect.Apollos.nebula_slice:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.CFrame = cFrame
	clone2.Parent = folder
	local Animate = require(clone2.Animate)
	Animate()
	clone2.Attachment2.Lines:Emit(8)
	clone2.Attachment.Lines1:Emit(12)
	clone2.Attachment.Lines2:Emit(12)
	clone2.Attachment.star:Emit(1)
	clone2.Attachment.star2:Emit(1)
	clone2.Attachment.Lines:Emit(20)
	clone2.Attachment.note:Emit(2)
	clone2.Attachment.note2:Emit(2)
	clone2.big:Emit(2)
	local pointLight = clone2.PointLight
	pointLight.Brightness = 0
	pointLight.Range = 0
	TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Range = 20,
		Brightness = 1.5
	}):Play()
	task.spawn(function()
		wait(0.5)
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 0,
			Brightness = 0
		}):Play()
	end)
	task.spawn(function()
		local clone3 = replicatedStorage.Chest.SwordEffect.Apollos.symbol:Clone()
		clone3.Parent = folder
		clone3.CFrame = cFrame * CFrame.new(5, 0, 0)
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
		TweenService:Create(clone3, TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.new(2, 0, 0)
		}):Play()
		_G.PU:Dust(clone3, 2)
	end)
	task.spawn(function()
		local clone3 = replicatedStorage.Chest.SwordEffect.Apollos.symbol:Clone()
		clone3.Parent = folder
		clone3.CFrame = cFrame * CFrame.new(-5, 0, 0)
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
		TweenService:Create(clone3, TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.new(-2, 0, 0)
		}):Play()
		_G.PU:Dust(clone3, 2)
	end)
end