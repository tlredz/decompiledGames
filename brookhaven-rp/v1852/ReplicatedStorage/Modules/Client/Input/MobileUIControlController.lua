local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MobileControlUI = require(ReplicatedStorage.Modules.Client.Components.UI.Input.MobileControlUI)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local MobileUIControlController = {}
local v = {}

function MobileUIControlController.FrameworkInit() end

function MobileUIControlController.FrameworkStart()
	Platform.PlatformChangedSignal:Connect(function(_)
		MobileUIControlController.UpdateVisibility()
	end)

	local function moveControlUICreated(data)
		data.MoveVectorUpdated:Connect(function(p)
			local v2 = v[1]

			if v2 then
				v2.object.MoveVectorUpdated:Fire((Vector3.new(p.X, 0, -p.Z)))
			end
		end)
		data.OnJumpStarted:Connect(function()
			local v2 = v[1]

			if v2 then
				v2.object.OnJumpStarted:Fire()
			end
		end)
		data.OnJumpEnded:Connect(function()
			local v2 = v[1]

			if v2 then
				v2.object.OnJumpEnded:Fire()
			end
		end)
	end

	MobileControlUI.Started:Connect(moveControlUICreated)

	for _, v2 in MobileControlUI:GetAll() do
		moveControlUICreated(v2)
	end
end

function MobileUIControlController.UpdateVisibility()
	if not UserInputService.TouchEnabled then
		return
	end

	if #v > 0 then
		PanelController.OpenPanelByContext("MobileControlUI", "MobileControlUI")
	else
		PanelController.Close("MobileControlUI", "MobileControlUI")
	end
end

function MobileUIControlController.NewContext(id: string)
	local maid = Janitor.new()
	local object = {
		MoveVectorUpdated = maid:Add(Signal.new()),
		OnJumpStarted = maid:Add(Signal.new()),
		OnJumpEnded = maid:Add(Signal.new()),
		Destroy = function()
			maid:Destroy()

			for i, v3 in ipairs(v) do
				if v3.id ~= id then
					continue
				end

				table.remove(v, i)
				break
			end

			MobileUIControlController.UpdateVisibility()
		end
	}
	table.insert(v, {
		id = id,
		object = object
	})
	MobileUIControlController.UpdateVisibility()
	return object
end

return MobileUIControlController