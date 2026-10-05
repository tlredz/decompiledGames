local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
return function(flag: boolean?, flag2: boolean?)
	local v = useMockState("CameraCFrame", CFrame.new())
	local state, setState = React.useState(workspace.CurrentCamera.CFrame)
	local v2 = state or CFrame.new()
	useOnScreenEffect(function()
		if flag == false then
			return function() end
		end

		local cFrameChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
			if flag2 or not RunService:IsRunning() then
				setState(workspace.CurrentCamera.CFrame)
				return
			end

			local character = game.Players.LocalPlayer.Character
			local primaryPart = character and character.PrimaryPart

			if primaryPart then
				setState(CFrame.fromMatrix(
					primaryPart.Position,
					workspace.CurrentCamera.CFrame.XVector,
					workspace.CurrentCamera.CFrame.YVector,
					workspace.CurrentCamera.CFrame.ZVector
				))
			end
		end)
		return function()
			cFrameChangedConnection:Disconnect()
		end
	end, { flag, flag2 })

	if v then
		return v:get() or CFrame.new()
	end

	return v2
end