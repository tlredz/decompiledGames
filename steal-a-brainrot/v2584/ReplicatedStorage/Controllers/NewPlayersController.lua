local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local NewPlayers = require(ReplicatedStorage.Shared.NewPlayers)
local localPlayer = Players.LocalPlayer
local NewPlayersController = {
	IsNewPlayer = function(self)
		return localPlayer:GetAttribute(NewPlayers.SessionAttribute) == true
	end
}

function NewPlayersController.Start(_)
	if localPlayer:GetAttribute(NewPlayers.SessionAttribute) == nil then
		localPlayer:GetAttributeChangedSignal(NewPlayers.SessionAttribute):Wait()
	end

	local isNewPlayer = NewPlayersController:IsNewPlayer()
	Observers.observeTag("NewPlayersHidden", function(model)
		if not model:IsA("Model") then
			return
		end

		local maid = Trove.new()

		local function updateModelParent()
			local parent = isNewPlayer and ReplicatedStorage or Workspace

			if model.Parent ~= parent then
				model.Parent = parent
			end
		end

		task.spawn(updateModelParent)

		if model.Name == "RobuxShop" and isNewPlayer then
			local pivot = model:GetPivot()

			for _, v in ipairs({ "PhantomSpinWheel", "CrystalSpinWheel", "EclipseSpinWheel" }) do
				maid:Add(Observers.observeTag(v, function(model2)
					if not model2:IsA("Model") then
						return
					end

					local pivot2 = model2:GetPivot()
					model2:PivotTo(pivot2 + (pivot.Position - pivot2.Position) * createVector(1, 0, 1))
					return function()
						model2:PivotTo(pivot2)
					end
				end))
			end
		end

		return maid:WrapClean()
	end)
end

return NewPlayersController