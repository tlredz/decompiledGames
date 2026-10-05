local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
require(game.ReplicatedStorage.Controllers.UI.Spinner.SpinnerTypes)
local PreviewModel = require(game.ReplicatedStorage.Controllers.UI.Spinner.Components.PreviewModel)
return function()
	local child = localPlayer.PlayerGui:FindFirstChild(PreviewModel.HOLDER_NAME)
	local v = nil
	local clones = {}
	local v2 = {}
	local bindableEvent = Instance.new("BindableEvent")
	local maid = nil
	local maid2 = Trove.new()
	maid2:Add(function()
		for _, v3 in pairs(clones) do
			local v4 = v3
			local success, result = pcall(function(...)
				v4:Destroy()
			end)

			if not success then
				warn(result)
			end
		end

		table.clear(clones)
		bindableEvent:Destroy()
	end)
	local update

	update = function(items)
		if items then
			for _, item in pairs(items) do
				if not table.find(v2, item) then
					table.insert(v2, item)
				end
			end
		end

		child = localPlayer.PlayerGui:FindFirstChild(PreviewModel.HOLDER_NAME)

		if child then
			if maid then
				maid:Destroy()
			end

			local v3 = {}

			for _, v4 in pairs(v2) do
				if not (clones[v4] or table.find(v3, v4)) then
					table.insert(v3, v4)
				end
			end

			if #v3 > 0 then
				for i = #v3, 1, -1 do
					local v4 = v3[i]
					local instance = PreviewModel.TryFindById(child, v4)

					if not instance then
						continue
					end

					if instance:IsA("Model") or instance:IsA("Tool") then
						table.remove(v3, i)
						local clone = instance:Clone()
						clones[v4] = clone

						if clone.PrimaryPart then
							clone.PrimaryPart.Anchored = true
						end

						bindableEvent:Fire(instance)
					else
						warn("unknown instance class", typeof(instance), v4)
					end
				end

				if #v3 > 0 then
					maid = maid2:Extend()
					assert(maid):Add(function()
						maid = nil
					end)
					maid:Add(child.ChildAdded:Connect(function(child2)
						local itemId = child2:GetAttribute("ItemId")

						if itemId and tonumber(itemId) then
							if table.find(v3, itemId) then
								update()
							end
						else
							warn((`added item without itemId attribute={child2.Name}`))
						end
					end))
				end
			end
		end
	end

	local v3 = nil
	local flag = false
	local flag2 = false
	v = {
		OnItemAdded = function(onEvent)
			return bindableEvent.Event:Connect(onEvent)
		end,
		GetAllItems = function()
			if flag then
				return {}
			end

			return clones
		end,
		Destroy = function()
			if not flag then
				flag = true
				maid2:Destroy()
			end
		end,
		Update = function(p)
			if not flag then
				update(p)

				if not flag2 then
					flag2 = true

					if child == nil then
						v3 = maid2:Add(localPlayer.PlayerGui.ChildAdded:Connect(function(child2)
							if child2.Name == PreviewModel.HOLDER_NAME then
								if child then
									assert(v3):Disconnect()
								end

								v.Update()
							end
						end))
					end
				end
			end
		end
	}
	return v
end