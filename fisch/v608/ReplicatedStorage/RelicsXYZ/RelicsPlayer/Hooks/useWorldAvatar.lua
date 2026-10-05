local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local UserId = require(shared.UserId)
local Promise = require(shared.Promise)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local hooks = parent.Hooks
local useSignal = require(hooks.useSignal)
local v = nil
local v2 = nil

local function promiseCharacter(p: number)
	return Promise.new(function(callback)
		local humanoidModelFromDescription = Players:CreateHumanoidModelFromDescription(
			Players:GetHumanoidDescriptionFromUserId(p),
			Enum.HumanoidRigType.R15
		)
		local animate = humanoidModelFromDescription:FindFirstChild("Animate")

		if animate then
			animate:Destroy()
		end

		humanoidModelFromDescription:PivotTo(CFrame.identity)
		humanoidModelFromDescription.Name = "Player"
		callback(humanoidModelFromDescription)
	end)
end

local function getCharacterModel()
	local v3 = UserId.Get(localPlayer)
	local character = localPlayer and localPlayer.Character

	if character == v then
		if not v2 then
			v2 = Promise.new(function(callback)
				local humanoidModelFromDescription = Players:CreateHumanoidModelFromDescription(
					Players:GetHumanoidDescriptionFromUserId(v3),
					Enum.HumanoidRigType.R15
				)
				local animate = humanoidModelFromDescription:FindFirstChild("Animate")

				if animate then
					animate:Destroy()
				end

				humanoidModelFromDescription:PivotTo(CFrame.identity)
				humanoidModelFromDescription.Name = "Player"
				callback(humanoidModelFromDescription)
			end)
		end
	else
		v = character
		v2 = Promise.new(function(callback)
			local humanoidModelFromDescription = Players:CreateHumanoidModelFromDescription(
				Players:GetHumanoidDescriptionFromUserId(v3),
				Enum.HumanoidRigType.R15
			)
			local animate = humanoidModelFromDescription:FindFirstChild("Animate")

			if animate then
				animate:Destroy()
			end

			humanoidModelFromDescription:PivotTo(CFrame.identity)
			humanoidModelFromDescription.Name = "Player"
			callback(humanoidModelFromDescription)
		end)
	end

	return v2
end

local function useWorldAvatar(value: number?)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(function()
		return Instance.new("WorldModel")
	end)
	React.useEffect(function()
		Promise.retry(getCharacterModel, 5):andThen(function(p)
			setState(p)
		end)
	end, {})
	useSignal(localPlayer and localPlayer.CharacterAdded, function()
		Promise.retry(getCharacterModel, 5):andThen(function(p)
			setState(p)
		end)
	end, { localPlayer })
	React.useEffect(function()
		local thread

		if state then
			thread = task.delay(value or 0, function()
				local worldModel = Instance.new("WorldModel")
				state = state:Clone()
				state.Parent = worldModel
				worldModel.PrimaryPart = state.PrimaryPart
				state2:Destroy()
				setState2(worldModel)
			end)
		else
			thread = nil
		end

		return function()
			if thread then
				task.cancel(thread)
			end
		end
	end, { state })
	return state2
end

return useWorldAvatar