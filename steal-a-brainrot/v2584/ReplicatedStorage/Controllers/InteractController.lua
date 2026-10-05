local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local CharacterController = require(controllers.CharacterController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(packages.Signal)
local v = nil
local InteractController = {
	OnInteractEnter = Signal.new(),
	OnInteractLeave = Signal.new()
}

function InteractController.Start(_)
	task.spawn(function()
		while wait(0.05) do
			local character, _, v2 = CharacterController:GetCharacter()

			if character then
				local v3 = nil
				local v4 = nil

				for _, v5 in CollectionService:GetTagged("Interact") do
					local magnitude = (v2.Position - v5.Position).Magnitude

					if not (magnitude <= (v5:GetAttribute("Distance") or 10)) then
						continue
					end

					if v3 == nil then
						v4 = v5
						v3 = magnitude
					elseif magnitude <= v3 then
						v4 = v5
						v3 = magnitude
					end
				end

				if v4 then
					if v4 ~= v then
						if v ~= nil then
							InteractController.OnInteractLeave:Fire(v)
						end

						v = v4
						InteractController.OnInteractEnter:Fire(v)
					end
				elseif v then
					InteractController.OnInteractLeave:Fire(v)
					v = nil
				end
			else
				if v then
					InteractController.OnInteractLeave:Fire(v)
					v = nil
				end

				break
			end
		end
	end)
end

return InteractController