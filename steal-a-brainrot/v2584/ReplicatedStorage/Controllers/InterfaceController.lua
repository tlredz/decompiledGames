local ReplicatedStorage = game:GetService("ReplicatedStorage")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InteractController = require(controllers.InteractController)
local classes = ReplicatedStorage:WaitForChild("Classes")
local Interface = require(classes.Interface)
require(classes.Interface.Styles)
local toggle = script.Toggle
local v = {}
local InterfaceController = {}

function InterfaceController.SetState(_, p: string, flag: boolean?, p2)
	local v2 = v[p]

	if not (v2 and v2:IsOpened() ~= flag) then
		return
	end

	InterfaceController:Toggle(p, flag, p2)
end

function InterfaceController:Toggle(p: string, flag: boolean?, list)
	local v2 = v[p]

	if not v2 then
		return
	end

	if flag == nil or not flag then
		flag = not v2:IsOpened()
	end

	local v3 = true

	for k, v4 in v do
		if k == p then
			v4:Toggle(flag)

			if v4:IsOpened() == false then
				v3 = false
			end
		elseif v4:IsOpened() then
			if list then
				if not table.find(list, k) then
					v4:Close()
				end
			else
				v4:Close()
			end
		end
	end

	if v3 == false and v.Hud then
		v.Hud:Toggle(true)
	end
end

function InterfaceController.GetInterfaces(_)
	return v
end

function InterfaceController.Get(_, p: string)
	return v[p]
end

function InterfaceController.Register(_, p: string, p2, p3)
	if v[p] then
		return warn((`Failed to create interface: {p}, already exist!`))
	end

	v[p] = Interface.new(p, p2, p3)
	return v[p]
end

function InterfaceController.Unregister(_, p: string, p2)
	local v2 = v[p]

	if not v2 or p2 and v2 ~= p2 then
		return
	end

	v[p] = nil
	v2:Destroy()
end

function InterfaceController.Start(_)
	toggle.Event:Connect(function(...)
		InterfaceController:Toggle(...)
	end)
	InteractController.OnInteractEnter:Connect(function(instance)
		if instance:GetAttribute("Interface") ~= true then
			return
		end

		if v[instance.Name] and not v[instance.Name]:IsOpened() then
			InterfaceController:Toggle(instance.Name, true)
		end
	end)
	InteractController.OnInteractLeave:Connect(function(instance)
		if instance:GetAttribute("Interface") ~= true then
			return
		end

		if v[instance.Name] and v[instance.Name]:IsOpened() then
			InterfaceController:Toggle(instance.Name, false)
		end
	end)
end

return InterfaceController