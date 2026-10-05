local GreenTea = require(script.Parent.GreenTea)
local __highlightWrap = GreenTea.__highlightWrap
local __Cause = GreenTea.__Cause
local __Type = GreenTea.__Type
GreenTea = {}
setmetatable(GreenTea, {
	__call = function(_, className: string)
		local v = nil
		v = {
			kind = "InstanceIsA",
			instanceIsA = {
				class = className
			},
			_matches = function(instance, ...)
				if typeof(instance) == "Instance" and instance:IsA(className) then
					return __Cause.ok()
				end

				return __Cause.err(v, instance, (`expected an instance of {className}, got $input`))
			end,
			_format = function(p, _: number, _)
				return __highlightWrap(className, p[v])
			end
		}
		return (setmetatable(v, __Type))
	end
})
local class

class = function(className: string)
	return function()
		local v = nil
		v = {
			kind = "InstanceIsA",
			class = class,
			_matches = function(instance)
				if typeof(instance) ~= "Instance" then
					return __Cause.err(v, instance, (`expected {className}, got {typeof(instance)}`))
				end

				if instance:IsA(className) then
					return __Cause.ok()
				end

				return __Cause.err(v, instance, (`expected {className}, got {instance.ClassName}`))
			end,
			_format = function(p, _: number, _)
				return __highlightWrap(className, p[v])
			end
		}
		return (setmetatable(v, __Type))
	end
end

local v = "Instance"

function GreenTea.Instance()
	local v2 = nil
	v2 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v2, instance, (`expected {v}, got {typeof(instance)}`))
			end

			if instance:IsA(v) then
				return __Cause.ok()
			end

			return __Cause.err(v2, instance, (`expected {v}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v, p[v2])
		end
	}
	return (setmetatable(v2, __Type))
end

local v2 = "AccessoryDescription"

function GreenTea.AccessoryDescription()
	local v3 = nil
	v3 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v3, instance, (`expected {v2}, got {typeof(instance)}`))
			end

			if instance:IsA(v2) then
				return __Cause.ok()
			end

			return __Cause.err(v3, instance, (`expected {v2}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v2, p[v3])
		end
	}
	return (setmetatable(v3, __Type))
end

local v3 = "AccountService"

function GreenTea.AccountService()
	local v4 = nil
	v4 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v4, instance, (`expected {v3}, got {typeof(instance)}`))
			end

			if instance:IsA(v3) then
				return __Cause.ok()
			end

			return __Cause.err(v4, instance, (`expected {v3}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v3, p[v4])
		end
	}
	return (setmetatable(v4, __Type))
end

local v4 = "Accoutrement"

function GreenTea.Accoutrement()
	local v5 = nil
	v5 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v5, instance, (`expected {v4}, got {typeof(instance)}`))
			end

			if instance:IsA(v4) then
				return __Cause.ok()
			end

			return __Cause.err(v5, instance, (`expected {v4}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v4, p[v5])
		end
	}
	return (setmetatable(v5, __Type))
end

local v5 = "Accessory"

function GreenTea.Accessory()
	local v6 = nil
	v6 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v6, instance, (`expected {v5}, got {typeof(instance)}`))
			end

			if instance:IsA(v5) then
				return __Cause.ok()
			end

			return __Cause.err(v6, instance, (`expected {v5}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v5, p[v6])
		end
	}
	return (setmetatable(v6, __Type))
end

local v6 = "Hat"

function GreenTea.Hat()
	local v7 = nil
	v7 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v7, instance, (`expected {v6}, got {typeof(instance)}`))
			end

			if instance:IsA(v6) then
				return __Cause.ok()
			end

			return __Cause.err(v7, instance, (`expected {v6}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v6, p[v7])
		end
	}
	return (setmetatable(v7, __Type))
end

local v7 = "AdPortal"

function GreenTea.AdPortal()
	local v8 = nil
	v8 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v8, instance, (`expected {v7}, got {typeof(instance)}`))
			end

			if instance:IsA(v7) then
				return __Cause.ok()
			end

			return __Cause.err(v8, instance, (`expected {v7}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v7, p[v8])
		end
	}
	return (setmetatable(v8, __Type))
end

local v8 = "AdService"

function GreenTea.AdService()
	local v9 = nil
	v9 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v9, instance, (`expected {v8}, got {typeof(instance)}`))
			end

			if instance:IsA(v8) then
				return __Cause.ok()
			end

			return __Cause.err(v9, instance, (`expected {v8}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v8, p[v9])
		end
	}
	return (setmetatable(v9, __Type))
end

local v9 = "AdvancedDragger"

function GreenTea.AdvancedDragger()
	local v10 = nil
	v10 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v10, instance, (`expected {v9}, got {typeof(instance)}`))
			end

			if instance:IsA(v9) then
				return __Cause.ok()
			end

			return __Cause.err(v10, instance, (`expected {v9}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v9, p[v10])
		end
	}
	return (setmetatable(v10, __Type))
end

local v10 = "AnalyticsService"

function GreenTea.AnalyticsService()
	local v11 = nil
	v11 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v11, instance, (`expected {v10}, got {typeof(instance)}`))
			end

			if instance:IsA(v10) then
				return __Cause.ok()
			end

			return __Cause.err(v11, instance, (`expected {v10}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v10, p[v11])
		end
	}
	return (setmetatable(v11, __Type))
end

local v11 = "Animation"

function GreenTea.Animation()
	local v12 = nil
	v12 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v12, instance, (`expected {v11}, got {typeof(instance)}`))
			end

			if instance:IsA(v11) then
				return __Cause.ok()
			end

			return __Cause.err(v12, instance, (`expected {v11}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v11, p[v12])
		end
	}
	return (setmetatable(v12, __Type))
end

local v12 = "AnimationClip"

function GreenTea.AnimationClip()
	local v13 = nil
	v13 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v13, instance, (`expected {v12}, got {typeof(instance)}`))
			end

			if instance:IsA(v12) then
				return __Cause.ok()
			end

			return __Cause.err(v13, instance, (`expected {v12}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v12, p[v13])
		end
	}
	return (setmetatable(v13, __Type))
end

local v13 = "CurveAnimation"

function GreenTea.CurveAnimation()
	local v14 = nil
	v14 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v14, instance, (`expected {v13}, got {typeof(instance)}`))
			end

			if instance:IsA(v13) then
				return __Cause.ok()
			end

			return __Cause.err(v14, instance, (`expected {v13}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v13, p[v14])
		end
	}
	return (setmetatable(v14, __Type))
end

local v14 = "KeyframeSequence"

function GreenTea.KeyframeSequence()
	local v15 = nil
	v15 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v15, instance, (`expected {v14}, got {typeof(instance)}`))
			end

			if instance:IsA(v14) then
				return __Cause.ok()
			end

			return __Cause.err(v15, instance, (`expected {v14}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v14, p[v15])
		end
	}
	return (setmetatable(v15, __Type))
end

local v15 = "AnimationClipProvider"

function GreenTea.AnimationClipProvider()
	local v16 = nil
	v16 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v16, instance, (`expected {v15}, got {typeof(instance)}`))
			end

			if instance:IsA(v15) then
				return __Cause.ok()
			end

			return __Cause.err(v16, instance, (`expected {v15}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v15, p[v16])
		end
	}
	return (setmetatable(v16, __Type))
end

local v16 = "AnimationController"

function GreenTea.AnimationController()
	local v17 = nil
	v17 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v17, instance, (`expected {v16}, got {typeof(instance)}`))
			end

			if instance:IsA(v16) then
				return __Cause.ok()
			end

			return __Cause.err(v17, instance, (`expected {v16}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v16, p[v17])
		end
	}
	return (setmetatable(v17, __Type))
end

local v17 = "AnimationFromVideoCreatorService"

function GreenTea.AnimationFromVideoCreatorService()
	local v18 = nil
	v18 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v18, instance, (`expected {v17}, got {typeof(instance)}`))
			end

			if instance:IsA(v17) then
				return __Cause.ok()
			end

			return __Cause.err(v18, instance, (`expected {v17}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v17, p[v18])
		end
	}
	return (setmetatable(v18, __Type))
end

local v18 = "AnimationFromVideoCreatorStudioService"

function GreenTea.AnimationFromVideoCreatorStudioService()
	local v19 = nil
	v19 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v19, instance, (`expected {v18}, got {typeof(instance)}`))
			end

			if instance:IsA(v18) then
				return __Cause.ok()
			end

			return __Cause.err(v19, instance, (`expected {v18}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v18, p[v19])
		end
	}
	return (setmetatable(v19, __Type))
end

local v19 = "AnimationRigData"

function GreenTea.AnimationRigData()
	local v20 = nil
	v20 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v20, instance, (`expected {v19}, got {typeof(instance)}`))
			end

			if instance:IsA(v19) then
				return __Cause.ok()
			end

			return __Cause.err(v20, instance, (`expected {v19}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v19, p[v20])
		end
	}
	return (setmetatable(v20, __Type))
end

local v20 = "AnimationStreamTrack"

function GreenTea.AnimationStreamTrack()
	local v21 = nil
	v21 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v21, instance, (`expected {v20}, got {typeof(instance)}`))
			end

			if instance:IsA(v20) then
				return __Cause.ok()
			end

			return __Cause.err(v21, instance, (`expected {v20}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v20, p[v21])
		end
	}
	return (setmetatable(v21, __Type))
end

local v21 = "AnimationTrack"

function GreenTea.AnimationTrack()
	local v22 = nil
	v22 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v22, instance, (`expected {v21}, got {typeof(instance)}`))
			end

			if instance:IsA(v21) then
				return __Cause.ok()
			end

			return __Cause.err(v22, instance, (`expected {v21}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v21, p[v22])
		end
	}
	return (setmetatable(v22, __Type))
end

local v22 = "Animator"

function GreenTea.Animator()
	local v23 = nil
	v23 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v23, instance, (`expected {v22}, got {typeof(instance)}`))
			end

			if instance:IsA(v22) then
				return __Cause.ok()
			end

			return __Cause.err(v23, instance, (`expected {v22}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v22, p[v23])
		end
	}
	return (setmetatable(v23, __Type))
end

local v23 = "AppUpdateService"

function GreenTea.AppUpdateService()
	local v24 = nil
	v24 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v24, instance, (`expected {v23}, got {typeof(instance)}`))
			end

			if instance:IsA(v23) then
				return __Cause.ok()
			end

			return __Cause.err(v24, instance, (`expected {v23}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v23, p[v24])
		end
	}
	return (setmetatable(v24, __Type))
end

local v24 = "AssetCounterService"

function GreenTea.AssetCounterService()
	local v25 = nil
	v25 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v25, instance, (`expected {v24}, got {typeof(instance)}`))
			end

			if instance:IsA(v24) then
				return __Cause.ok()
			end

			return __Cause.err(v25, instance, (`expected {v24}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v24, p[v25])
		end
	}
	return (setmetatable(v25, __Type))
end

local v25 = "AssetDeliveryProxy"

function GreenTea.AssetDeliveryProxy()
	local v26 = nil
	v26 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v26, instance, (`expected {v25}, got {typeof(instance)}`))
			end

			if instance:IsA(v25) then
				return __Cause.ok()
			end

			return __Cause.err(v26, instance, (`expected {v25}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v25, p[v26])
		end
	}
	return (setmetatable(v26, __Type))
end

local v26 = "AssetImportService"

function GreenTea.AssetImportService()
	local v27 = nil
	v27 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v27, instance, (`expected {v26}, got {typeof(instance)}`))
			end

			if instance:IsA(v26) then
				return __Cause.ok()
			end

			return __Cause.err(v27, instance, (`expected {v26}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v26, p[v27])
		end
	}
	return (setmetatable(v27, __Type))
end

local v27 = "AssetImportSession"

function GreenTea.AssetImportSession()
	local v28 = nil
	v28 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v28, instance, (`expected {v27}, got {typeof(instance)}`))
			end

			if instance:IsA(v27) then
				return __Cause.ok()
			end

			return __Cause.err(v28, instance, (`expected {v27}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v27, p[v28])
		end
	}
	return (setmetatable(v28, __Type))
end

local v28 = "AssetManagerService"

function GreenTea.AssetManagerService()
	local v29 = nil
	v29 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v29, instance, (`expected {v28}, got {typeof(instance)}`))
			end

			if instance:IsA(v28) then
				return __Cause.ok()
			end

			return __Cause.err(v29, instance, (`expected {v28}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v28, p[v29])
		end
	}
	return (setmetatable(v29, __Type))
end

local v29 = "AssetPatchSettings"

function GreenTea.AssetPatchSettings()
	local v30 = nil
	v30 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v30, instance, (`expected {v29}, got {typeof(instance)}`))
			end

			if instance:IsA(v29) then
				return __Cause.ok()
			end

			return __Cause.err(v30, instance, (`expected {v29}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v29, p[v30])
		end
	}
	return (setmetatable(v30, __Type))
end

local v30 = "AssetService"

function GreenTea.AssetService()
	local v31 = nil
	v31 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v31, instance, (`expected {v30}, got {typeof(instance)}`))
			end

			if instance:IsA(v30) then
				return __Cause.ok()
			end

			return __Cause.err(v31, instance, (`expected {v30}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v30, p[v31])
		end
	}
	return (setmetatable(v31, __Type))
end

local v31 = "Atmosphere"

function GreenTea.Atmosphere()
	local v32 = nil
	v32 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v32, instance, (`expected {v31}, got {typeof(instance)}`))
			end

			if instance:IsA(v31) then
				return __Cause.ok()
			end

			return __Cause.err(v32, instance, (`expected {v31}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v31, p[v32])
		end
	}
	return (setmetatable(v32, __Type))
end

local v32 = "Attachment"

function GreenTea.Attachment()
	local v33 = nil
	v33 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v33, instance, (`expected {v32}, got {typeof(instance)}`))
			end

			if instance:IsA(v32) then
				return __Cause.ok()
			end

			return __Cause.err(v33, instance, (`expected {v32}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v32, p[v33])
		end
	}
	return (setmetatable(v33, __Type))
end

local v33 = "Bone"

function GreenTea.Bone()
	local v34 = nil
	v34 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v34, instance, (`expected {v33}, got {typeof(instance)}`))
			end

			if instance:IsA(v33) then
				return __Cause.ok()
			end

			return __Cause.err(v34, instance, (`expected {v33}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v33, p[v34])
		end
	}
	return (setmetatable(v34, __Type))
end

local v34 = "AudioAnalyzer"

function GreenTea.AudioAnalyzer()
	local v35 = nil
	v35 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v35, instance, (`expected {v34}, got {typeof(instance)}`))
			end

			if instance:IsA(v34) then
				return __Cause.ok()
			end

			return __Cause.err(v35, instance, (`expected {v34}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v34, p[v35])
		end
	}
	return (setmetatable(v35, __Type))
end

local v35 = "AudioChorus"

function GreenTea.AudioChorus()
	local v36 = nil
	v36 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v36, instance, (`expected {v35}, got {typeof(instance)}`))
			end

			if instance:IsA(v35) then
				return __Cause.ok()
			end

			return __Cause.err(v36, instance, (`expected {v35}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v35, p[v36])
		end
	}
	return (setmetatable(v36, __Type))
end

local v36 = "AudioCompressor"

function GreenTea.AudioCompressor()
	local v37 = nil
	v37 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v37, instance, (`expected {v36}, got {typeof(instance)}`))
			end

			if instance:IsA(v36) then
				return __Cause.ok()
			end

			return __Cause.err(v37, instance, (`expected {v36}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v36, p[v37])
		end
	}
	return (setmetatable(v37, __Type))
end

local v37 = "AudioDeviceInput"

function GreenTea.AudioDeviceInput()
	local v38 = nil
	v38 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v38, instance, (`expected {v37}, got {typeof(instance)}`))
			end

			if instance:IsA(v37) then
				return __Cause.ok()
			end

			return __Cause.err(v38, instance, (`expected {v37}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v37, p[v38])
		end
	}
	return (setmetatable(v38, __Type))
end

local v38 = "AudioDeviceOutput"

function GreenTea.AudioDeviceOutput()
	local v39 = nil
	v39 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v39, instance, (`expected {v38}, got {typeof(instance)}`))
			end

			if instance:IsA(v38) then
				return __Cause.ok()
			end

			return __Cause.err(v39, instance, (`expected {v38}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v38, p[v39])
		end
	}
	return (setmetatable(v39, __Type))
end

local v39 = "AudioDistortion"

function GreenTea.AudioDistortion()
	local v40 = nil
	v40 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v40, instance, (`expected {v39}, got {typeof(instance)}`))
			end

			if instance:IsA(v39) then
				return __Cause.ok()
			end

			return __Cause.err(v40, instance, (`expected {v39}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v39, p[v40])
		end
	}
	return (setmetatable(v40, __Type))
end

local v40 = "AudioEcho"

function GreenTea.AudioEcho()
	local v41 = nil
	v41 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v41, instance, (`expected {v40}, got {typeof(instance)}`))
			end

			if instance:IsA(v40) then
				return __Cause.ok()
			end

			return __Cause.err(v41, instance, (`expected {v40}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v40, p[v41])
		end
	}
	return (setmetatable(v41, __Type))
end

local v41 = "AudioEmitter"

function GreenTea.AudioEmitter()
	local v42 = nil
	v42 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v42, instance, (`expected {v41}, got {typeof(instance)}`))
			end

			if instance:IsA(v41) then
				return __Cause.ok()
			end

			return __Cause.err(v42, instance, (`expected {v41}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v41, p[v42])
		end
	}
	return (setmetatable(v42, __Type))
end

local v42 = "AudioEqualizer"

function GreenTea.AudioEqualizer()
	local v43 = nil
	v43 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v43, instance, (`expected {v42}, got {typeof(instance)}`))
			end

			if instance:IsA(v42) then
				return __Cause.ok()
			end

			return __Cause.err(v43, instance, (`expected {v42}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v42, p[v43])
		end
	}
	return (setmetatable(v43, __Type))
end

local v43 = "AudioFader"

function GreenTea.AudioFader()
	local v44 = nil
	v44 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v44, instance, (`expected {v43}, got {typeof(instance)}`))
			end

			if instance:IsA(v43) then
				return __Cause.ok()
			end

			return __Cause.err(v44, instance, (`expected {v43}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v43, p[v44])
		end
	}
	return (setmetatable(v44, __Type))
end

local v44 = "AudioFlanger"

function GreenTea.AudioFlanger()
	local v45 = nil
	v45 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v45, instance, (`expected {v44}, got {typeof(instance)}`))
			end

			if instance:IsA(v44) then
				return __Cause.ok()
			end

			return __Cause.err(v45, instance, (`expected {v44}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v44, p[v45])
		end
	}
	return (setmetatable(v45, __Type))
end

local v45 = "AudioListener"

function GreenTea.AudioListener()
	local v46 = nil
	v46 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v46, instance, (`expected {v45}, got {typeof(instance)}`))
			end

			if instance:IsA(v45) then
				return __Cause.ok()
			end

			return __Cause.err(v46, instance, (`expected {v45}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v45, p[v46])
		end
	}
	return (setmetatable(v46, __Type))
end

local v46 = "AudioPitchShifter"

function GreenTea.AudioPitchShifter()
	local v47 = nil
	v47 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v47, instance, (`expected {v46}, got {typeof(instance)}`))
			end

			if instance:IsA(v46) then
				return __Cause.ok()
			end

			return __Cause.err(v47, instance, (`expected {v46}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v46, p[v47])
		end
	}
	return (setmetatable(v47, __Type))
end

local v47 = "AudioPlayer"

function GreenTea.AudioPlayer()
	local v48 = nil
	v48 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v48, instance, (`expected {v47}, got {typeof(instance)}`))
			end

			if instance:IsA(v47) then
				return __Cause.ok()
			end

			return __Cause.err(v48, instance, (`expected {v47}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v47, p[v48])
		end
	}
	return (setmetatable(v48, __Type))
end

local v48 = "AudioReverb"

function GreenTea.AudioReverb()
	local v49 = nil
	v49 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v49, instance, (`expected {v48}, got {typeof(instance)}`))
			end

			if instance:IsA(v48) then
				return __Cause.ok()
			end

			return __Cause.err(v49, instance, (`expected {v48}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v48, p[v49])
		end
	}
	return (setmetatable(v49, __Type))
end

local v49 = "AudioSearchParams"

function GreenTea.AudioSearchParams()
	local v50 = nil
	v50 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v50, instance, (`expected {v49}, got {typeof(instance)}`))
			end

			if instance:IsA(v49) then
				return __Cause.ok()
			end

			return __Cause.err(v50, instance, (`expected {v49}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v49, p[v50])
		end
	}
	return (setmetatable(v50, __Type))
end

local v50 = "AvatarChatService"

function GreenTea.AvatarChatService()
	local v51 = nil
	v51 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v51, instance, (`expected {v50}, got {typeof(instance)}`))
			end

			if instance:IsA(v50) then
				return __Cause.ok()
			end

			return __Cause.err(v51, instance, (`expected {v50}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v50, p[v51])
		end
	}
	return (setmetatable(v51, __Type))
end

local v51 = "AvatarCreationService"

function GreenTea.AvatarCreationService()
	local v52 = nil
	v52 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v52, instance, (`expected {v51}, got {typeof(instance)}`))
			end

			if instance:IsA(v51) then
				return __Cause.ok()
			end

			return __Cause.err(v52, instance, (`expected {v51}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v51, p[v52])
		end
	}
	return (setmetatable(v52, __Type))
end

local v52 = "AvatarEditorService"

function GreenTea.AvatarEditorService()
	local v53 = nil
	v53 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v53, instance, (`expected {v52}, got {typeof(instance)}`))
			end

			if instance:IsA(v52) then
				return __Cause.ok()
			end

			return __Cause.err(v53, instance, (`expected {v52}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v52, p[v53])
		end
	}
	return (setmetatable(v53, __Type))
end

local v53 = "AvatarImportService"

function GreenTea.AvatarImportService()
	local v54 = nil
	v54 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v54, instance, (`expected {v53}, got {typeof(instance)}`))
			end

			if instance:IsA(v53) then
				return __Cause.ok()
			end

			return __Cause.err(v54, instance, (`expected {v53}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v53, p[v54])
		end
	}
	return (setmetatable(v54, __Type))
end

local v54 = "Backpack"

function GreenTea.Backpack()
	local v55 = nil
	v55 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v55, instance, (`expected {v54}, got {typeof(instance)}`))
			end

			if instance:IsA(v54) then
				return __Cause.ok()
			end

			return __Cause.err(v55, instance, (`expected {v54}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v54, p[v55])
		end
	}
	return (setmetatable(v55, __Type))
end

local v55 = "BadgeService"

function GreenTea.BadgeService()
	local v56 = nil
	v56 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v56, instance, (`expected {v55}, got {typeof(instance)}`))
			end

			if instance:IsA(v55) then
				return __Cause.ok()
			end

			return __Cause.err(v56, instance, (`expected {v55}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v55, p[v56])
		end
	}
	return (setmetatable(v56, __Type))
end

local v56 = "BaseImportData"

function GreenTea.BaseImportData()
	local v57 = nil
	v57 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v57, instance, (`expected {v56}, got {typeof(instance)}`))
			end

			if instance:IsA(v56) then
				return __Cause.ok()
			end

			return __Cause.err(v57, instance, (`expected {v56}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v56, p[v57])
		end
	}
	return (setmetatable(v57, __Type))
end

local v57 = "AnimationImportData"

function GreenTea.AnimationImportData()
	local v58 = nil
	v58 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v58, instance, (`expected {v57}, got {typeof(instance)}`))
			end

			if instance:IsA(v57) then
				return __Cause.ok()
			end

			return __Cause.err(v58, instance, (`expected {v57}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v57, p[v58])
		end
	}
	return (setmetatable(v58, __Type))
end

local v58 = "FacsImportData"

function GreenTea.FacsImportData()
	local v59 = nil
	v59 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v59, instance, (`expected {v58}, got {typeof(instance)}`))
			end

			if instance:IsA(v58) then
				return __Cause.ok()
			end

			return __Cause.err(v59, instance, (`expected {v58}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v58, p[v59])
		end
	}
	return (setmetatable(v59, __Type))
end

local v59 = "GroupImportData"

function GreenTea.GroupImportData()
	local v60 = nil
	v60 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v60, instance, (`expected {v59}, got {typeof(instance)}`))
			end

			if instance:IsA(v59) then
				return __Cause.ok()
			end

			return __Cause.err(v60, instance, (`expected {v59}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v59, p[v60])
		end
	}
	return (setmetatable(v60, __Type))
end

local v60 = "JointImportData"

function GreenTea.JointImportData()
	local v61 = nil
	v61 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v61, instance, (`expected {v60}, got {typeof(instance)}`))
			end

			if instance:IsA(v60) then
				return __Cause.ok()
			end

			return __Cause.err(v61, instance, (`expected {v60}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v60, p[v61])
		end
	}
	return (setmetatable(v61, __Type))
end

local v61 = "MaterialImportData"

function GreenTea.MaterialImportData()
	local v62 = nil
	v62 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v62, instance, (`expected {v61}, got {typeof(instance)}`))
			end

			if instance:IsA(v61) then
				return __Cause.ok()
			end

			return __Cause.err(v62, instance, (`expected {v61}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v61, p[v62])
		end
	}
	return (setmetatable(v62, __Type))
end

local v62 = "MeshImportData"

function GreenTea.MeshImportData()
	local v63 = nil
	v63 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v63, instance, (`expected {v62}, got {typeof(instance)}`))
			end

			if instance:IsA(v62) then
				return __Cause.ok()
			end

			return __Cause.err(v63, instance, (`expected {v62}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v62, p[v63])
		end
	}
	return (setmetatable(v63, __Type))
end

local v63 = "RootImportData"

function GreenTea.RootImportData()
	local v64 = nil
	v64 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v64, instance, (`expected {v63}, got {typeof(instance)}`))
			end

			if instance:IsA(v63) then
				return __Cause.ok()
			end

			return __Cause.err(v64, instance, (`expected {v63}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v63, p[v64])
		end
	}
	return (setmetatable(v64, __Type))
end

local v64 = "BasePlayerGui"

function GreenTea.BasePlayerGui()
	local v65 = nil
	v65 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v65, instance, (`expected {v64}, got {typeof(instance)}`))
			end

			if instance:IsA(v64) then
				return __Cause.ok()
			end

			return __Cause.err(v65, instance, (`expected {v64}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v64, p[v65])
		end
	}
	return (setmetatable(v65, __Type))
end

local v65 = "CoreGui"

function GreenTea.CoreGui()
	local v66 = nil
	v66 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v66, instance, (`expected {v65}, got {typeof(instance)}`))
			end

			if instance:IsA(v65) then
				return __Cause.ok()
			end

			return __Cause.err(v66, instance, (`expected {v65}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v65, p[v66])
		end
	}
	return (setmetatable(v66, __Type))
end

local v66 = "PlayerGui"

function GreenTea.PlayerGui()
	local v67 = nil
	v67 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v67, instance, (`expected {v66}, got {typeof(instance)}`))
			end

			if instance:IsA(v66) then
				return __Cause.ok()
			end

			return __Cause.err(v67, instance, (`expected {v66}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v66, p[v67])
		end
	}
	return (setmetatable(v67, __Type))
end

local v67 = "StarterGui"

function GreenTea.StarterGui()
	local v68 = nil
	v68 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v68, instance, (`expected {v67}, got {typeof(instance)}`))
			end

			if instance:IsA(v67) then
				return __Cause.ok()
			end

			return __Cause.err(v68, instance, (`expected {v67}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v67, p[v68])
		end
	}
	return (setmetatable(v68, __Type))
end

local v68 = "BaseRemoteEvent"

function GreenTea.BaseRemoteEvent()
	local v69 = nil
	v69 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v69, instance, (`expected {v68}, got {typeof(instance)}`))
			end

			if instance:IsA(v68) then
				return __Cause.ok()
			end

			return __Cause.err(v69, instance, (`expected {v68}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v68, p[v69])
		end
	}
	return (setmetatable(v69, __Type))
end

local v69 = "RemoteEvent"

function GreenTea.RemoteEvent()
	local v70 = nil
	v70 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v70, instance, (`expected {v69}, got {typeof(instance)}`))
			end

			if instance:IsA(v69) then
				return __Cause.ok()
			end

			return __Cause.err(v70, instance, (`expected {v69}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v69, p[v70])
		end
	}
	return (setmetatable(v70, __Type))
end

local v70 = "UnreliableRemoteEvent"

function GreenTea.UnreliableRemoteEvent()
	local v71 = nil
	v71 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v71, instance, (`expected {v70}, got {typeof(instance)}`))
			end

			if instance:IsA(v70) then
				return __Cause.ok()
			end

			return __Cause.err(v71, instance, (`expected {v70}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v70, p[v71])
		end
	}
	return (setmetatable(v71, __Type))
end

local v71 = "BaseWrap"

function GreenTea.BaseWrap()
	local v72 = nil
	v72 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v72, instance, (`expected {v71}, got {typeof(instance)}`))
			end

			if instance:IsA(v71) then
				return __Cause.ok()
			end

			return __Cause.err(v72, instance, (`expected {v71}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v71, p[v72])
		end
	}
	return (setmetatable(v72, __Type))
end

local v72 = "WrapLayer"

function GreenTea.WrapLayer()
	local v73 = nil
	v73 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v73, instance, (`expected {v72}, got {typeof(instance)}`))
			end

			if instance:IsA(v72) then
				return __Cause.ok()
			end

			return __Cause.err(v73, instance, (`expected {v72}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v72, p[v73])
		end
	}
	return (setmetatable(v73, __Type))
end

local v73 = "WrapTarget"

function GreenTea.WrapTarget()
	local v74 = nil
	v74 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v74, instance, (`expected {v73}, got {typeof(instance)}`))
			end

			if instance:IsA(v73) then
				return __Cause.ok()
			end

			return __Cause.err(v74, instance, (`expected {v73}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v73, p[v74])
		end
	}
	return (setmetatable(v74, __Type))
end

local v74 = "Beam"

function GreenTea.Beam()
	local v75 = nil
	v75 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v75, instance, (`expected {v74}, got {typeof(instance)}`))
			end

			if instance:IsA(v74) then
				return __Cause.ok()
			end

			return __Cause.err(v75, instance, (`expected {v74}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v74, p[v75])
		end
	}
	return (setmetatable(v75, __Type))
end

local v75 = "BindableEvent"

function GreenTea.BindableEvent()
	local v76 = nil
	v76 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v76, instance, (`expected {v75}, got {typeof(instance)}`))
			end

			if instance:IsA(v75) then
				return __Cause.ok()
			end

			return __Cause.err(v76, instance, (`expected {v75}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v75, p[v76])
		end
	}
	return (setmetatable(v76, __Type))
end

local v76 = "BindableFunction"

function GreenTea.BindableFunction()
	local v77 = nil
	v77 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v77, instance, (`expected {v76}, got {typeof(instance)}`))
			end

			if instance:IsA(v76) then
				return __Cause.ok()
			end

			return __Cause.err(v77, instance, (`expected {v76}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v76, p[v77])
		end
	}
	return (setmetatable(v77, __Type))
end

local v77 = "BodyMover"

function GreenTea.BodyMover()
	local v78 = nil
	v78 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v78, instance, (`expected {v77}, got {typeof(instance)}`))
			end

			if instance:IsA(v77) then
				return __Cause.ok()
			end

			return __Cause.err(v78, instance, (`expected {v77}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v77, p[v78])
		end
	}
	return (setmetatable(v78, __Type))
end

local v78 = "BodyAngularVelocity"

function GreenTea.BodyAngularVelocity()
	local v79 = nil
	v79 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v79, instance, (`expected {v78}, got {typeof(instance)}`))
			end

			if instance:IsA(v78) then
				return __Cause.ok()
			end

			return __Cause.err(v79, instance, (`expected {v78}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v78, p[v79])
		end
	}
	return (setmetatable(v79, __Type))
end

local v79 = "BodyForce"

function GreenTea.BodyForce()
	local v80 = nil
	v80 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v80, instance, (`expected {v79}, got {typeof(instance)}`))
			end

			if instance:IsA(v79) then
				return __Cause.ok()
			end

			return __Cause.err(v80, instance, (`expected {v79}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v79, p[v80])
		end
	}
	return (setmetatable(v80, __Type))
end

local v80 = "BodyGyro"

function GreenTea.BodyGyro()
	local v81 = nil
	v81 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v81, instance, (`expected {v80}, got {typeof(instance)}`))
			end

			if instance:IsA(v80) then
				return __Cause.ok()
			end

			return __Cause.err(v81, instance, (`expected {v80}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v80, p[v81])
		end
	}
	return (setmetatable(v81, __Type))
end

local v81 = "BodyPosition"

function GreenTea.BodyPosition()
	local v82 = nil
	v82 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v82, instance, (`expected {v81}, got {typeof(instance)}`))
			end

			if instance:IsA(v81) then
				return __Cause.ok()
			end

			return __Cause.err(v82, instance, (`expected {v81}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v81, p[v82])
		end
	}
	return (setmetatable(v82, __Type))
end

local v82 = "BodyThrust"

function GreenTea.BodyThrust()
	local v83 = nil
	v83 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v83, instance, (`expected {v82}, got {typeof(instance)}`))
			end

			if instance:IsA(v82) then
				return __Cause.ok()
			end

			return __Cause.err(v83, instance, (`expected {v82}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v82, p[v83])
		end
	}
	return (setmetatable(v83, __Type))
end

local v83 = "BodyVelocity"

function GreenTea.BodyVelocity()
	local v84 = nil
	v84 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v84, instance, (`expected {v83}, got {typeof(instance)}`))
			end

			if instance:IsA(v83) then
				return __Cause.ok()
			end

			return __Cause.err(v84, instance, (`expected {v83}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v83, p[v84])
		end
	}
	return (setmetatable(v84, __Type))
end

local v84 = "RocketPropulsion"

function GreenTea.RocketPropulsion()
	local v85 = nil
	v85 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v85, instance, (`expected {v84}, got {typeof(instance)}`))
			end

			if instance:IsA(v84) then
				return __Cause.ok()
			end

			return __Cause.err(v85, instance, (`expected {v84}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v84, p[v85])
		end
	}
	return (setmetatable(v85, __Type))
end

local v85 = "BodyPartDescription"

function GreenTea.BodyPartDescription()
	local v86 = nil
	v86 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v86, instance, (`expected {v85}, got {typeof(instance)}`))
			end

			if instance:IsA(v85) then
				return __Cause.ok()
			end

			return __Cause.err(v86, instance, (`expected {v85}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v85, p[v86])
		end
	}
	return (setmetatable(v86, __Type))
end

local v86 = "Breakpoint"

function GreenTea.Breakpoint()
	local v87 = nil
	v87 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v87, instance, (`expected {v86}, got {typeof(instance)}`))
			end

			if instance:IsA(v86) then
				return __Cause.ok()
			end

			return __Cause.err(v87, instance, (`expected {v86}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v86, p[v87])
		end
	}
	return (setmetatable(v87, __Type))
end

local v87 = "BrowserService"

function GreenTea.BrowserService()
	local v88 = nil
	v88 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v88, instance, (`expected {v87}, got {typeof(instance)}`))
			end

			if instance:IsA(v87) then
				return __Cause.ok()
			end

			return __Cause.err(v88, instance, (`expected {v87}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v87, p[v88])
		end
	}
	return (setmetatable(v88, __Type))
end

local v88 = "BubbleChatMessageProperties"

function GreenTea.BubbleChatMessageProperties()
	local v89 = nil
	v89 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v89, instance, (`expected {v88}, got {typeof(instance)}`))
			end

			if instance:IsA(v88) then
				return __Cause.ok()
			end

			return __Cause.err(v89, instance, (`expected {v88}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v88, p[v89])
		end
	}
	return (setmetatable(v89, __Type))
end

local v89 = "BulkImportService"

function GreenTea.BulkImportService()
	local v90 = nil
	v90 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v90, instance, (`expected {v89}, got {typeof(instance)}`))
			end

			if instance:IsA(v89) then
				return __Cause.ok()
			end

			return __Cause.err(v90, instance, (`expected {v89}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v89, p[v90])
		end
	}
	return (setmetatable(v90, __Type))
end

local v90 = "CacheableContentProvider"

function GreenTea.CacheableContentProvider()
	local v91 = nil
	v91 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v91, instance, (`expected {v90}, got {typeof(instance)}`))
			end

			if instance:IsA(v90) then
				return __Cause.ok()
			end

			return __Cause.err(v91, instance, (`expected {v90}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v90, p[v91])
		end
	}
	return (setmetatable(v91, __Type))
end

local v91 = "HSRDataContentProvider"

function GreenTea.HSRDataContentProvider()
	local v92 = nil
	v92 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v92, instance, (`expected {v91}, got {typeof(instance)}`))
			end

			if instance:IsA(v91) then
				return __Cause.ok()
			end

			return __Cause.err(v92, instance, (`expected {v91}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v91, p[v92])
		end
	}
	return (setmetatable(v92, __Type))
end

local v92 = "MeshContentProvider"

function GreenTea.MeshContentProvider()
	local v93 = nil
	v93 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v93, instance, (`expected {v92}, got {typeof(instance)}`))
			end

			if instance:IsA(v92) then
				return __Cause.ok()
			end

			return __Cause.err(v93, instance, (`expected {v92}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v92, p[v93])
		end
	}
	return (setmetatable(v93, __Type))
end

local v93 = "SolidModelContentProvider"

function GreenTea.SolidModelContentProvider()
	local v94 = nil
	v94 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v94, instance, (`expected {v93}, got {typeof(instance)}`))
			end

			if instance:IsA(v93) then
				return __Cause.ok()
			end

			return __Cause.err(v94, instance, (`expected {v93}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v93, p[v94])
		end
	}
	return (setmetatable(v94, __Type))
end

local v94 = "CalloutService"

function GreenTea.CalloutService()
	local v95 = nil
	v95 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v95, instance, (`expected {v94}, got {typeof(instance)}`))
			end

			if instance:IsA(v94) then
				return __Cause.ok()
			end

			return __Cause.err(v95, instance, (`expected {v94}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v94, p[v95])
		end
	}
	return (setmetatable(v95, __Type))
end

local v95 = "Camera"

function GreenTea.Camera()
	local v96 = nil
	v96 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v96, instance, (`expected {v95}, got {typeof(instance)}`))
			end

			if instance:IsA(v95) then
				return __Cause.ok()
			end

			return __Cause.err(v96, instance, (`expected {v95}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v95, p[v96])
		end
	}
	return (setmetatable(v96, __Type))
end

local v96 = "CaptureService"

function GreenTea.CaptureService()
	local v97 = nil
	v97 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v97, instance, (`expected {v96}, got {typeof(instance)}`))
			end

			if instance:IsA(v96) then
				return __Cause.ok()
			end

			return __Cause.err(v97, instance, (`expected {v96}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v96, p[v97])
		end
	}
	return (setmetatable(v97, __Type))
end

local v97 = "ChangeHistoryService"

function GreenTea.ChangeHistoryService()
	local v98 = nil
	v98 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v98, instance, (`expected {v97}, got {typeof(instance)}`))
			end

			if instance:IsA(v97) then
				return __Cause.ok()
			end

			return __Cause.err(v98, instance, (`expected {v97}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v97, p[v98])
		end
	}
	return (setmetatable(v98, __Type))
end

local v98 = "CharacterAppearance"

function GreenTea.CharacterAppearance()
	local v99 = nil
	v99 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v99, instance, (`expected {v98}, got {typeof(instance)}`))
			end

			if instance:IsA(v98) then
				return __Cause.ok()
			end

			return __Cause.err(v99, instance, (`expected {v98}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v98, p[v99])
		end
	}
	return (setmetatable(v99, __Type))
end

local v99 = "BodyColors"

function GreenTea.BodyColors()
	local v100 = nil
	v100 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v100, instance, (`expected {v99}, got {typeof(instance)}`))
			end

			if instance:IsA(v99) then
				return __Cause.ok()
			end

			return __Cause.err(v100, instance, (`expected {v99}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v99, p[v100])
		end
	}
	return (setmetatable(v100, __Type))
end

local v100 = "CharacterMesh"

function GreenTea.CharacterMesh()
	local v101 = nil
	v101 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v101, instance, (`expected {v100}, got {typeof(instance)}`))
			end

			if instance:IsA(v100) then
				return __Cause.ok()
			end

			return __Cause.err(v101, instance, (`expected {v100}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v100, p[v101])
		end
	}
	return (setmetatable(v101, __Type))
end

local v101 = "Clothing"

function GreenTea.Clothing()
	local v102 = nil
	v102 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v102, instance, (`expected {v101}, got {typeof(instance)}`))
			end

			if instance:IsA(v101) then
				return __Cause.ok()
			end

			return __Cause.err(v102, instance, (`expected {v101}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v101, p[v102])
		end
	}
	return (setmetatable(v102, __Type))
end

local v102 = "Pants"

function GreenTea.Pants()
	local v103 = nil
	v103 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v103, instance, (`expected {v102}, got {typeof(instance)}`))
			end

			if instance:IsA(v102) then
				return __Cause.ok()
			end

			return __Cause.err(v103, instance, (`expected {v102}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v102, p[v103])
		end
	}
	return (setmetatable(v103, __Type))
end

local v103 = "Shirt"

function GreenTea.Shirt()
	local v104 = nil
	v104 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v104, instance, (`expected {v103}, got {typeof(instance)}`))
			end

			if instance:IsA(v103) then
				return __Cause.ok()
			end

			return __Cause.err(v104, instance, (`expected {v103}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v103, p[v104])
		end
	}
	return (setmetatable(v104, __Type))
end

local v104 = "ShirtGraphic"

function GreenTea.ShirtGraphic()
	local v105 = nil
	v105 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v105, instance, (`expected {v104}, got {typeof(instance)}`))
			end

			if instance:IsA(v104) then
				return __Cause.ok()
			end

			return __Cause.err(v105, instance, (`expected {v104}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v104, p[v105])
		end
	}
	return (setmetatable(v105, __Type))
end

local v105 = "Skin"

function GreenTea.Skin()
	local v106 = nil
	v106 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v106, instance, (`expected {v105}, got {typeof(instance)}`))
			end

			if instance:IsA(v105) then
				return __Cause.ok()
			end

			return __Cause.err(v106, instance, (`expected {v105}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v105, p[v106])
		end
	}
	return (setmetatable(v106, __Type))
end

local v106 = "Chat"

function GreenTea.Chat()
	local v107 = nil
	v107 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v107, instance, (`expected {v106}, got {typeof(instance)}`))
			end

			if instance:IsA(v106) then
				return __Cause.ok()
			end

			return __Cause.err(v107, instance, (`expected {v106}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v106, p[v107])
		end
	}
	return (setmetatable(v107, __Type))
end

local v107 = "ChatbotUIService"

function GreenTea.ChatbotUIService()
	local v108 = nil
	v108 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v108, instance, (`expected {v107}, got {typeof(instance)}`))
			end

			if instance:IsA(v107) then
				return __Cause.ok()
			end

			return __Cause.err(v108, instance, (`expected {v107}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v107, p[v108])
		end
	}
	return (setmetatable(v108, __Type))
end

local v108 = "ClickDetector"

function GreenTea.ClickDetector()
	local v109 = nil
	v109 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v109, instance, (`expected {v108}, got {typeof(instance)}`))
			end

			if instance:IsA(v108) then
				return __Cause.ok()
			end

			return __Cause.err(v109, instance, (`expected {v108}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v108, p[v109])
		end
	}
	return (setmetatable(v109, __Type))
end

local v109 = "DragDetector"

function GreenTea.DragDetector()
	local v110 = nil
	v110 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v110, instance, (`expected {v109}, got {typeof(instance)}`))
			end

			if instance:IsA(v109) then
				return __Cause.ok()
			end

			return __Cause.err(v110, instance, (`expected {v109}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v109, p[v110])
		end
	}
	return (setmetatable(v110, __Type))
end

local v110 = "Clouds"

function GreenTea.Clouds()
	local v111 = nil
	v111 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v111, instance, (`expected {v110}, got {typeof(instance)}`))
			end

			if instance:IsA(v110) then
				return __Cause.ok()
			end

			return __Cause.err(v111, instance, (`expected {v110}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v110, p[v111])
		end
	}
	return (setmetatable(v111, __Type))
end

local v111 = "ClusterPacketCache"

function GreenTea.ClusterPacketCache()
	local v112 = nil
	v112 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v112, instance, (`expected {v111}, got {typeof(instance)}`))
			end

			if instance:IsA(v111) then
				return __Cause.ok()
			end

			return __Cause.err(v112, instance, (`expected {v111}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v111, p[v112])
		end
	}
	return (setmetatable(v112, __Type))
end

local v112 = "Collaborator"

function GreenTea.Collaborator()
	local v113 = nil
	v113 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v113, instance, (`expected {v112}, got {typeof(instance)}`))
			end

			if instance:IsA(v112) then
				return __Cause.ok()
			end

			return __Cause.err(v113, instance, (`expected {v112}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v112, p[v113])
		end
	}
	return (setmetatable(v113, __Type))
end

local v113 = "CollaboratorsService"

function GreenTea.CollaboratorsService()
	local v114 = nil
	v114 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v114, instance, (`expected {v113}, got {typeof(instance)}`))
			end

			if instance:IsA(v113) then
				return __Cause.ok()
			end

			return __Cause.err(v114, instance, (`expected {v113}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v113, p[v114])
		end
	}
	return (setmetatable(v114, __Type))
end

local v114 = "CollectionService"

function GreenTea.CollectionService()
	local v115 = nil
	v115 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v115, instance, (`expected {v114}, got {typeof(instance)}`))
			end

			if instance:IsA(v114) then
				return __Cause.ok()
			end

			return __Cause.err(v115, instance, (`expected {v114}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v114, p[v115])
		end
	}
	return (setmetatable(v115, __Type))
end

local v115 = "CommandInstance"

function GreenTea.CommandInstance()
	local v116 = nil
	v116 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v116, instance, (`expected {v115}, got {typeof(instance)}`))
			end

			if instance:IsA(v115) then
				return __Cause.ok()
			end

			return __Cause.err(v116, instance, (`expected {v115}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v115, p[v116])
		end
	}
	return (setmetatable(v116, __Type))
end

local v116 = "CommandService"

function GreenTea.CommandService()
	local v117 = nil
	v117 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v117, instance, (`expected {v116}, got {typeof(instance)}`))
			end

			if instance:IsA(v116) then
				return __Cause.ok()
			end

			return __Cause.err(v117, instance, (`expected {v116}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v116, p[v117])
		end
	}
	return (setmetatable(v117, __Type))
end

local v117 = "Configuration"

function GreenTea.Configuration()
	local v118 = nil
	v118 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v118, instance, (`expected {v117}, got {typeof(instance)}`))
			end

			if instance:IsA(v117) then
				return __Cause.ok()
			end

			return __Cause.err(v118, instance, (`expected {v117}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v117, p[v118])
		end
	}
	return (setmetatable(v118, __Type))
end

local v118 = "ConfigureServerService"

function GreenTea.ConfigureServerService()
	local v119 = nil
	v119 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v119, instance, (`expected {v118}, got {typeof(instance)}`))
			end

			if instance:IsA(v118) then
				return __Cause.ok()
			end

			return __Cause.err(v119, instance, (`expected {v118}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v118, p[v119])
		end
	}
	return (setmetatable(v119, __Type))
end

local v119 = "Constraint"

function GreenTea.Constraint()
	local v120 = nil
	v120 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v120, instance, (`expected {v119}, got {typeof(instance)}`))
			end

			if instance:IsA(v119) then
				return __Cause.ok()
			end

			return __Cause.err(v120, instance, (`expected {v119}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v119, p[v120])
		end
	}
	return (setmetatable(v120, __Type))
end

local v120 = "AlignOrientation"

function GreenTea.AlignOrientation()
	local v121 = nil
	v121 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v121, instance, (`expected {v120}, got {typeof(instance)}`))
			end

			if instance:IsA(v120) then
				return __Cause.ok()
			end

			return __Cause.err(v121, instance, (`expected {v120}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v120, p[v121])
		end
	}
	return (setmetatable(v121, __Type))
end

local v121 = "AlignPosition"

function GreenTea.AlignPosition()
	local v122 = nil
	v122 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v122, instance, (`expected {v121}, got {typeof(instance)}`))
			end

			if instance:IsA(v121) then
				return __Cause.ok()
			end

			return __Cause.err(v122, instance, (`expected {v121}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v121, p[v122])
		end
	}
	return (setmetatable(v122, __Type))
end

local v122 = "AngularVelocity"

function GreenTea.AngularVelocity()
	local v123 = nil
	v123 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v123, instance, (`expected {v122}, got {typeof(instance)}`))
			end

			if instance:IsA(v122) then
				return __Cause.ok()
			end

			return __Cause.err(v123, instance, (`expected {v122}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v122, p[v123])
		end
	}
	return (setmetatable(v123, __Type))
end

local v123 = "AnimationConstraint"

function GreenTea.AnimationConstraint()
	local v124 = nil
	v124 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v124, instance, (`expected {v123}, got {typeof(instance)}`))
			end

			if instance:IsA(v123) then
				return __Cause.ok()
			end

			return __Cause.err(v124, instance, (`expected {v123}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v123, p[v124])
		end
	}
	return (setmetatable(v124, __Type))
end

local v124 = "BallSocketConstraint"

function GreenTea.BallSocketConstraint()
	local v125 = nil
	v125 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v125, instance, (`expected {v124}, got {typeof(instance)}`))
			end

			if instance:IsA(v124) then
				return __Cause.ok()
			end

			return __Cause.err(v125, instance, (`expected {v124}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v124, p[v125])
		end
	}
	return (setmetatable(v125, __Type))
end

local v125 = "HingeConstraint"

function GreenTea.HingeConstraint()
	local v126 = nil
	v126 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v126, instance, (`expected {v125}, got {typeof(instance)}`))
			end

			if instance:IsA(v125) then
				return __Cause.ok()
			end

			return __Cause.err(v126, instance, (`expected {v125}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v125, p[v126])
		end
	}
	return (setmetatable(v126, __Type))
end

local v126 = "LineForce"

function GreenTea.LineForce()
	local v127 = nil
	v127 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v127, instance, (`expected {v126}, got {typeof(instance)}`))
			end

			if instance:IsA(v126) then
				return __Cause.ok()
			end

			return __Cause.err(v127, instance, (`expected {v126}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v126, p[v127])
		end
	}
	return (setmetatable(v127, __Type))
end

local v127 = "LinearVelocity"

function GreenTea.LinearVelocity()
	local v128 = nil
	v128 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v128, instance, (`expected {v127}, got {typeof(instance)}`))
			end

			if instance:IsA(v127) then
				return __Cause.ok()
			end

			return __Cause.err(v128, instance, (`expected {v127}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v127, p[v128])
		end
	}
	return (setmetatable(v128, __Type))
end

local v128 = "PlaneConstraint"

function GreenTea.PlaneConstraint()
	local v129 = nil
	v129 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v129, instance, (`expected {v128}, got {typeof(instance)}`))
			end

			if instance:IsA(v128) then
				return __Cause.ok()
			end

			return __Cause.err(v129, instance, (`expected {v128}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v128, p[v129])
		end
	}
	return (setmetatable(v129, __Type))
end

local v129 = "Plane"

function GreenTea.Plane()
	local v130 = nil
	v130 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v130, instance, (`expected {v129}, got {typeof(instance)}`))
			end

			if instance:IsA(v129) then
				return __Cause.ok()
			end

			return __Cause.err(v130, instance, (`expected {v129}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v129, p[v130])
		end
	}
	return (setmetatable(v130, __Type))
end

local v130 = "RigidConstraint"

function GreenTea.RigidConstraint()
	local v131 = nil
	v131 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v131, instance, (`expected {v130}, got {typeof(instance)}`))
			end

			if instance:IsA(v130) then
				return __Cause.ok()
			end

			return __Cause.err(v131, instance, (`expected {v130}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v130, p[v131])
		end
	}
	return (setmetatable(v131, __Type))
end

local v131 = "RodConstraint"

function GreenTea.RodConstraint()
	local v132 = nil
	v132 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v132, instance, (`expected {v131}, got {typeof(instance)}`))
			end

			if instance:IsA(v131) then
				return __Cause.ok()
			end

			return __Cause.err(v132, instance, (`expected {v131}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v131, p[v132])
		end
	}
	return (setmetatable(v132, __Type))
end

local v132 = "RopeConstraint"

function GreenTea.RopeConstraint()
	local v133 = nil
	v133 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v133, instance, (`expected {v132}, got {typeof(instance)}`))
			end

			if instance:IsA(v132) then
				return __Cause.ok()
			end

			return __Cause.err(v133, instance, (`expected {v132}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v132, p[v133])
		end
	}
	return (setmetatable(v133, __Type))
end

local v133 = "SlidingBallConstraint"

function GreenTea.SlidingBallConstraint()
	local v134 = nil
	v134 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v134, instance, (`expected {v133}, got {typeof(instance)}`))
			end

			if instance:IsA(v133) then
				return __Cause.ok()
			end

			return __Cause.err(v134, instance, (`expected {v133}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v133, p[v134])
		end
	}
	return (setmetatable(v134, __Type))
end

local v134 = "CylindricalConstraint"

function GreenTea.CylindricalConstraint()
	local v135 = nil
	v135 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v135, instance, (`expected {v134}, got {typeof(instance)}`))
			end

			if instance:IsA(v134) then
				return __Cause.ok()
			end

			return __Cause.err(v135, instance, (`expected {v134}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v134, p[v135])
		end
	}
	return (setmetatable(v135, __Type))
end

local v135 = "PrismaticConstraint"

function GreenTea.PrismaticConstraint()
	local v136 = nil
	v136 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v136, instance, (`expected {v135}, got {typeof(instance)}`))
			end

			if instance:IsA(v135) then
				return __Cause.ok()
			end

			return __Cause.err(v136, instance, (`expected {v135}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v135, p[v136])
		end
	}
	return (setmetatable(v136, __Type))
end

local v136 = "SpringConstraint"

function GreenTea.SpringConstraint()
	local v137 = nil
	v137 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v137, instance, (`expected {v136}, got {typeof(instance)}`))
			end

			if instance:IsA(v136) then
				return __Cause.ok()
			end

			return __Cause.err(v137, instance, (`expected {v136}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v136, p[v137])
		end
	}
	return (setmetatable(v137, __Type))
end

local v137 = "Torque"

function GreenTea.Torque()
	local v138 = nil
	v138 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v138, instance, (`expected {v137}, got {typeof(instance)}`))
			end

			if instance:IsA(v137) then
				return __Cause.ok()
			end

			return __Cause.err(v138, instance, (`expected {v137}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v137, p[v138])
		end
	}
	return (setmetatable(v138, __Type))
end

local v138 = "TorsionSpringConstraint"

function GreenTea.TorsionSpringConstraint()
	local v139 = nil
	v139 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v139, instance, (`expected {v138}, got {typeof(instance)}`))
			end

			if instance:IsA(v138) then
				return __Cause.ok()
			end

			return __Cause.err(v139, instance, (`expected {v138}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v138, p[v139])
		end
	}
	return (setmetatable(v139, __Type))
end

local v139 = "UniversalConstraint"

function GreenTea.UniversalConstraint()
	local v140 = nil
	v140 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v140, instance, (`expected {v139}, got {typeof(instance)}`))
			end

			if instance:IsA(v139) then
				return __Cause.ok()
			end

			return __Cause.err(v140, instance, (`expected {v139}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v139, p[v140])
		end
	}
	return (setmetatable(v140, __Type))
end

local v140 = "VectorForce"

function GreenTea.VectorForce()
	local v141 = nil
	v141 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v141, instance, (`expected {v140}, got {typeof(instance)}`))
			end

			if instance:IsA(v140) then
				return __Cause.ok()
			end

			return __Cause.err(v141, instance, (`expected {v140}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v140, p[v141])
		end
	}
	return (setmetatable(v141, __Type))
end

local v141 = "ContentProvider"

function GreenTea.ContentProvider()
	local v142 = nil
	v142 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v142, instance, (`expected {v141}, got {typeof(instance)}`))
			end

			if instance:IsA(v141) then
				return __Cause.ok()
			end

			return __Cause.err(v142, instance, (`expected {v141}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v141, p[v142])
		end
	}
	return (setmetatable(v142, __Type))
end

local v142 = "ContextActionService"

function GreenTea.ContextActionService()
	local v143 = nil
	v143 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v143, instance, (`expected {v142}, got {typeof(instance)}`))
			end

			if instance:IsA(v142) then
				return __Cause.ok()
			end

			return __Cause.err(v143, instance, (`expected {v142}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v142, p[v143])
		end
	}
	return (setmetatable(v143, __Type))
end

local v143 = "Controller"

function GreenTea.Controller()
	local v144 = nil
	v144 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v144, instance, (`expected {v143}, got {typeof(instance)}`))
			end

			if instance:IsA(v143) then
				return __Cause.ok()
			end

			return __Cause.err(v144, instance, (`expected {v143}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v143, p[v144])
		end
	}
	return (setmetatable(v144, __Type))
end

local v144 = "HumanoidController"

function GreenTea.HumanoidController()
	local v145 = nil
	v145 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v145, instance, (`expected {v144}, got {typeof(instance)}`))
			end

			if instance:IsA(v144) then
				return __Cause.ok()
			end

			return __Cause.err(v145, instance, (`expected {v144}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v144, p[v145])
		end
	}
	return (setmetatable(v145, __Type))
end

local v145 = "SkateboardController"

function GreenTea.SkateboardController()
	local v146 = nil
	v146 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v146, instance, (`expected {v145}, got {typeof(instance)}`))
			end

			if instance:IsA(v145) then
				return __Cause.ok()
			end

			return __Cause.err(v146, instance, (`expected {v145}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v145, p[v146])
		end
	}
	return (setmetatable(v146, __Type))
end

local v146 = "VehicleController"

function GreenTea.VehicleController()
	local v147 = nil
	v147 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v147, instance, (`expected {v146}, got {typeof(instance)}`))
			end

			if instance:IsA(v146) then
				return __Cause.ok()
			end

			return __Cause.err(v147, instance, (`expected {v146}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v146, p[v147])
		end
	}
	return (setmetatable(v147, __Type))
end

local v147 = "ControllerBase"

function GreenTea.ControllerBase()
	local v148 = nil
	v148 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v148, instance, (`expected {v147}, got {typeof(instance)}`))
			end

			if instance:IsA(v147) then
				return __Cause.ok()
			end

			return __Cause.err(v148, instance, (`expected {v147}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v147, p[v148])
		end
	}
	return (setmetatable(v148, __Type))
end

local v148 = "AirController"

function GreenTea.AirController()
	local v149 = nil
	v149 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v149, instance, (`expected {v148}, got {typeof(instance)}`))
			end

			if instance:IsA(v148) then
				return __Cause.ok()
			end

			return __Cause.err(v149, instance, (`expected {v148}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v148, p[v149])
		end
	}
	return (setmetatable(v149, __Type))
end

local v149 = "ClimbController"

function GreenTea.ClimbController()
	local v150 = nil
	v150 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v150, instance, (`expected {v149}, got {typeof(instance)}`))
			end

			if instance:IsA(v149) then
				return __Cause.ok()
			end

			return __Cause.err(v150, instance, (`expected {v149}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v149, p[v150])
		end
	}
	return (setmetatable(v150, __Type))
end

local v150 = "GroundController"

function GreenTea.GroundController()
	local v151 = nil
	v151 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v151, instance, (`expected {v150}, got {typeof(instance)}`))
			end

			if instance:IsA(v150) then
				return __Cause.ok()
			end

			return __Cause.err(v151, instance, (`expected {v150}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v150, p[v151])
		end
	}
	return (setmetatable(v151, __Type))
end

local v151 = "SwimController"

function GreenTea.SwimController()
	local v152 = nil
	v152 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v152, instance, (`expected {v151}, got {typeof(instance)}`))
			end

			if instance:IsA(v151) then
				return __Cause.ok()
			end

			return __Cause.err(v152, instance, (`expected {v151}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v151, p[v152])
		end
	}
	return (setmetatable(v152, __Type))
end

local v152 = "ControllerManager"

function GreenTea.ControllerManager()
	local v153 = nil
	v153 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v153, instance, (`expected {v152}, got {typeof(instance)}`))
			end

			if instance:IsA(v152) then
				return __Cause.ok()
			end

			return __Cause.err(v153, instance, (`expected {v152}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v152, p[v153])
		end
	}
	return (setmetatable(v153, __Type))
end

local v153 = "ControllerService"

function GreenTea.ControllerService()
	local v154 = nil
	v154 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v154, instance, (`expected {v153}, got {typeof(instance)}`))
			end

			if instance:IsA(v153) then
				return __Cause.ok()
			end

			return __Cause.err(v154, instance, (`expected {v153}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v153, p[v154])
		end
	}
	return (setmetatable(v154, __Type))
end

local v154 = "CookiesService"

function GreenTea.CookiesService()
	local v155 = nil
	v155 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v155, instance, (`expected {v154}, got {typeof(instance)}`))
			end

			if instance:IsA(v154) then
				return __Cause.ok()
			end

			return __Cause.err(v155, instance, (`expected {v154}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v154, p[v155])
		end
	}
	return (setmetatable(v155, __Type))
end

local v155 = "CorePackages"

function GreenTea.CorePackages()
	local v156 = nil
	v156 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v156, instance, (`expected {v155}, got {typeof(instance)}`))
			end

			if instance:IsA(v155) then
				return __Cause.ok()
			end

			return __Cause.err(v156, instance, (`expected {v155}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v155, p[v156])
		end
	}
	return (setmetatable(v156, __Type))
end

local v156 = "CoreScriptDebuggingManagerHelper"

function GreenTea.CoreScriptDebuggingManagerHelper()
	local v157 = nil
	v157 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v157, instance, (`expected {v156}, got {typeof(instance)}`))
			end

			if instance:IsA(v156) then
				return __Cause.ok()
			end

			return __Cause.err(v157, instance, (`expected {v156}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v156, p[v157])
		end
	}
	return (setmetatable(v157, __Type))
end

local v157 = "CoreScriptSyncService"

function GreenTea.CoreScriptSyncService()
	local v158 = nil
	v158 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v158, instance, (`expected {v157}, got {typeof(instance)}`))
			end

			if instance:IsA(v157) then
				return __Cause.ok()
			end

			return __Cause.err(v158, instance, (`expected {v157}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v157, p[v158])
		end
	}
	return (setmetatable(v158, __Type))
end

local v158 = "CreationDBService"

function GreenTea.CreationDBService()
	local v159 = nil
	v159 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v159, instance, (`expected {v158}, got {typeof(instance)}`))
			end

			if instance:IsA(v158) then
				return __Cause.ok()
			end

			return __Cause.err(v159, instance, (`expected {v158}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v158, p[v159])
		end
	}
	return (setmetatable(v159, __Type))
end

local v159 = "CrossDMScriptChangeListener"

function GreenTea.CrossDMScriptChangeListener()
	local v160 = nil
	v160 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v160, instance, (`expected {v159}, got {typeof(instance)}`))
			end

			if instance:IsA(v159) then
				return __Cause.ok()
			end

			return __Cause.err(v160, instance, (`expected {v159}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v159, p[v160])
		end
	}
	return (setmetatable(v160, __Type))
end

local v160 = "CustomEvent"

function GreenTea.CustomEvent()
	local v161 = nil
	v161 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v161, instance, (`expected {v160}, got {typeof(instance)}`))
			end

			if instance:IsA(v160) then
				return __Cause.ok()
			end

			return __Cause.err(v161, instance, (`expected {v160}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v160, p[v161])
		end
	}
	return (setmetatable(v161, __Type))
end

local v161 = "CustomEventReceiver"

function GreenTea.CustomEventReceiver()
	local v162 = nil
	v162 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v162, instance, (`expected {v161}, got {typeof(instance)}`))
			end

			if instance:IsA(v161) then
				return __Cause.ok()
			end

			return __Cause.err(v162, instance, (`expected {v161}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v161, p[v162])
		end
	}
	return (setmetatable(v162, __Type))
end

local v162 = "DataModelMesh"

function GreenTea.DataModelMesh()
	local v163 = nil
	v163 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v163, instance, (`expected {v162}, got {typeof(instance)}`))
			end

			if instance:IsA(v162) then
				return __Cause.ok()
			end

			return __Cause.err(v163, instance, (`expected {v162}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v162, p[v163])
		end
	}
	return (setmetatable(v163, __Type))
end

local v163 = "BevelMesh"

function GreenTea.BevelMesh()
	local v164 = nil
	v164 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v164, instance, (`expected {v163}, got {typeof(instance)}`))
			end

			if instance:IsA(v163) then
				return __Cause.ok()
			end

			return __Cause.err(v164, instance, (`expected {v163}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v163, p[v164])
		end
	}
	return (setmetatable(v164, __Type))
end

local v164 = "CylinderMesh"

function GreenTea.CylinderMesh()
	local v165 = nil
	v165 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v165, instance, (`expected {v164}, got {typeof(instance)}`))
			end

			if instance:IsA(v164) then
				return __Cause.ok()
			end

			return __Cause.err(v165, instance, (`expected {v164}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v164, p[v165])
		end
	}
	return (setmetatable(v165, __Type))
end

local v165 = "EditableMesh"

function GreenTea.EditableMesh()
	local v166 = nil
	v166 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v166, instance, (`expected {v165}, got {typeof(instance)}`))
			end

			if instance:IsA(v165) then
				return __Cause.ok()
			end

			return __Cause.err(v166, instance, (`expected {v165}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v165, p[v166])
		end
	}
	return (setmetatable(v166, __Type))
end

local v166 = "FileMesh"

function GreenTea.FileMesh()
	local v167 = nil
	v167 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v167, instance, (`expected {v166}, got {typeof(instance)}`))
			end

			if instance:IsA(v166) then
				return __Cause.ok()
			end

			return __Cause.err(v167, instance, (`expected {v166}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v166, p[v167])
		end
	}
	return (setmetatable(v167, __Type))
end

local v167 = "SpecialMesh"

function GreenTea.SpecialMesh()
	local v168 = nil
	v168 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v168, instance, (`expected {v167}, got {typeof(instance)}`))
			end

			if instance:IsA(v167) then
				return __Cause.ok()
			end

			return __Cause.err(v168, instance, (`expected {v167}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v167, p[v168])
		end
	}
	return (setmetatable(v168, __Type))
end

local v168 = "DataModelPatchService"

function GreenTea.DataModelPatchService()
	local v169 = nil
	v169 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v169, instance, (`expected {v168}, got {typeof(instance)}`))
			end

			if instance:IsA(v168) then
				return __Cause.ok()
			end

			return __Cause.err(v169, instance, (`expected {v168}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v168, p[v169])
		end
	}
	return (setmetatable(v169, __Type))
end

local v169 = "DataModelSession"

function GreenTea.DataModelSession()
	local v170 = nil
	v170 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v170, instance, (`expected {v169}, got {typeof(instance)}`))
			end

			if instance:IsA(v169) then
				return __Cause.ok()
			end

			return __Cause.err(v170, instance, (`expected {v169}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v169, p[v170])
		end
	}
	return (setmetatable(v170, __Type))
end

local v170 = "DataStoreGetOptions"

function GreenTea.DataStoreGetOptions()
	local v171 = nil
	v171 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v171, instance, (`expected {v170}, got {typeof(instance)}`))
			end

			if instance:IsA(v170) then
				return __Cause.ok()
			end

			return __Cause.err(v171, instance, (`expected {v170}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v170, p[v171])
		end
	}
	return (setmetatable(v171, __Type))
end

local v171 = "DataStoreIncrementOptions"

function GreenTea.DataStoreIncrementOptions()
	local v172 = nil
	v172 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v172, instance, (`expected {v171}, got {typeof(instance)}`))
			end

			if instance:IsA(v171) then
				return __Cause.ok()
			end

			return __Cause.err(v172, instance, (`expected {v171}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v171, p[v172])
		end
	}
	return (setmetatable(v172, __Type))
end

local v172 = "DataStoreInfo"

function GreenTea.DataStoreInfo()
	local v173 = nil
	v173 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v173, instance, (`expected {v172}, got {typeof(instance)}`))
			end

			if instance:IsA(v172) then
				return __Cause.ok()
			end

			return __Cause.err(v173, instance, (`expected {v172}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v172, p[v173])
		end
	}
	return (setmetatable(v173, __Type))
end

local v173 = "DataStoreKey"

function GreenTea.DataStoreKey()
	local v174 = nil
	v174 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v174, instance, (`expected {v173}, got {typeof(instance)}`))
			end

			if instance:IsA(v173) then
				return __Cause.ok()
			end

			return __Cause.err(v174, instance, (`expected {v173}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v173, p[v174])
		end
	}
	return (setmetatable(v174, __Type))
end

local v174 = "DataStoreKeyInfo"

function GreenTea.DataStoreKeyInfo()
	local v175 = nil
	v175 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v175, instance, (`expected {v174}, got {typeof(instance)}`))
			end

			if instance:IsA(v174) then
				return __Cause.ok()
			end

			return __Cause.err(v175, instance, (`expected {v174}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v174, p[v175])
		end
	}
	return (setmetatable(v175, __Type))
end

local v175 = "DataStoreObjectVersionInfo"

function GreenTea.DataStoreObjectVersionInfo()
	local v176 = nil
	v176 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v176, instance, (`expected {v175}, got {typeof(instance)}`))
			end

			if instance:IsA(v175) then
				return __Cause.ok()
			end

			return __Cause.err(v176, instance, (`expected {v175}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v175, p[v176])
		end
	}
	return (setmetatable(v176, __Type))
end

local v176 = "DataStoreOptions"

function GreenTea.DataStoreOptions()
	local v177 = nil
	v177 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v177, instance, (`expected {v176}, got {typeof(instance)}`))
			end

			if instance:IsA(v176) then
				return __Cause.ok()
			end

			return __Cause.err(v177, instance, (`expected {v176}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v176, p[v177])
		end
	}
	return (setmetatable(v177, __Type))
end

local v177 = "DataStoreService"

function GreenTea.DataStoreService()
	local v178 = nil
	v178 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v178, instance, (`expected {v177}, got {typeof(instance)}`))
			end

			if instance:IsA(v177) then
				return __Cause.ok()
			end

			return __Cause.err(v178, instance, (`expected {v177}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v177, p[v178])
		end
	}
	return (setmetatable(v178, __Type))
end

local v178 = "DataStoreSetOptions"

function GreenTea.DataStoreSetOptions()
	local v179 = nil
	v179 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v179, instance, (`expected {v178}, got {typeof(instance)}`))
			end

			if instance:IsA(v178) then
				return __Cause.ok()
			end

			return __Cause.err(v179, instance, (`expected {v178}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v178, p[v179])
		end
	}
	return (setmetatable(v179, __Type))
end

local v179 = "Debris"

function GreenTea.Debris()
	local v180 = nil
	v180 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v180, instance, (`expected {v179}, got {typeof(instance)}`))
			end

			if instance:IsA(v179) then
				return __Cause.ok()
			end

			return __Cause.err(v180, instance, (`expected {v179}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v179, p[v180])
		end
	}
	return (setmetatable(v180, __Type))
end

local v180 = "DebugSettings"

function GreenTea.DebugSettings()
	local v181 = nil
	v181 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v181, instance, (`expected {v180}, got {typeof(instance)}`))
			end

			if instance:IsA(v180) then
				return __Cause.ok()
			end

			return __Cause.err(v181, instance, (`expected {v180}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v180, p[v181])
		end
	}
	return (setmetatable(v181, __Type))
end

local v181 = "DebuggablePluginWatcher"

function GreenTea.DebuggablePluginWatcher()
	local v182 = nil
	v182 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v182, instance, (`expected {v181}, got {typeof(instance)}`))
			end

			if instance:IsA(v181) then
				return __Cause.ok()
			end

			return __Cause.err(v182, instance, (`expected {v181}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v181, p[v182])
		end
	}
	return (setmetatable(v182, __Type))
end

local v182 = "DebuggerBreakpoint"

function GreenTea.DebuggerBreakpoint()
	local v183 = nil
	v183 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v183, instance, (`expected {v182}, got {typeof(instance)}`))
			end

			if instance:IsA(v182) then
				return __Cause.ok()
			end

			return __Cause.err(v183, instance, (`expected {v182}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v182, p[v183])
		end
	}
	return (setmetatable(v183, __Type))
end

local v183 = "DebuggerConnection"

function GreenTea.DebuggerConnection()
	local v184 = nil
	v184 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v184, instance, (`expected {v183}, got {typeof(instance)}`))
			end

			if instance:IsA(v183) then
				return __Cause.ok()
			end

			return __Cause.err(v184, instance, (`expected {v183}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v183, p[v184])
		end
	}
	return (setmetatable(v184, __Type))
end

local v184 = "LocalDebuggerConnection"

function GreenTea.LocalDebuggerConnection()
	local v185 = nil
	v185 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v185, instance, (`expected {v184}, got {typeof(instance)}`))
			end

			if instance:IsA(v184) then
				return __Cause.ok()
			end

			return __Cause.err(v185, instance, (`expected {v184}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v184, p[v185])
		end
	}
	return (setmetatable(v185, __Type))
end

local v185 = "DebuggerConnectionManager"

function GreenTea.DebuggerConnectionManager()
	local v186 = nil
	v186 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v186, instance, (`expected {v185}, got {typeof(instance)}`))
			end

			if instance:IsA(v185) then
				return __Cause.ok()
			end

			return __Cause.err(v186, instance, (`expected {v185}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v185, p[v186])
		end
	}
	return (setmetatable(v186, __Type))
end

local v186 = "DebuggerLuaResponse"

function GreenTea.DebuggerLuaResponse()
	local v187 = nil
	v187 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v187, instance, (`expected {v186}, got {typeof(instance)}`))
			end

			if instance:IsA(v186) then
				return __Cause.ok()
			end

			return __Cause.err(v187, instance, (`expected {v186}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v186, p[v187])
		end
	}
	return (setmetatable(v187, __Type))
end

local v187 = "DebuggerManager"

function GreenTea.DebuggerManager()
	local v188 = nil
	v188 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v188, instance, (`expected {v187}, got {typeof(instance)}`))
			end

			if instance:IsA(v187) then
				return __Cause.ok()
			end

			return __Cause.err(v188, instance, (`expected {v187}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v187, p[v188])
		end
	}
	return (setmetatable(v188, __Type))
end

local v188 = "DebuggerUIService"

function GreenTea.DebuggerUIService()
	local v189 = nil
	v189 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v189, instance, (`expected {v188}, got {typeof(instance)}`))
			end

			if instance:IsA(v188) then
				return __Cause.ok()
			end

			return __Cause.err(v189, instance, (`expected {v188}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v188, p[v189])
		end
	}
	return (setmetatable(v189, __Type))
end

local v189 = "DebuggerVariable"

function GreenTea.DebuggerVariable()
	local v190 = nil
	v190 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v190, instance, (`expected {v189}, got {typeof(instance)}`))
			end

			if instance:IsA(v189) then
				return __Cause.ok()
			end

			return __Cause.err(v190, instance, (`expected {v189}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v189, p[v190])
		end
	}
	return (setmetatable(v190, __Type))
end

local v190 = "DebuggerWatch"

function GreenTea.DebuggerWatch()
	local v191 = nil
	v191 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v191, instance, (`expected {v190}, got {typeof(instance)}`))
			end

			if instance:IsA(v190) then
				return __Cause.ok()
			end

			return __Cause.err(v191, instance, (`expected {v190}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v190, p[v191])
		end
	}
	return (setmetatable(v191, __Type))
end

local v191 = "DeviceIdService"

function GreenTea.DeviceIdService()
	local v192 = nil
	v192 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v192, instance, (`expected {v191}, got {typeof(instance)}`))
			end

			if instance:IsA(v191) then
				return __Cause.ok()
			end

			return __Cause.err(v192, instance, (`expected {v191}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v191, p[v192])
		end
	}
	return (setmetatable(v192, __Type))
end

local v192 = "Dialog"

function GreenTea.Dialog()
	local v193 = nil
	v193 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v193, instance, (`expected {v192}, got {typeof(instance)}`))
			end

			if instance:IsA(v192) then
				return __Cause.ok()
			end

			return __Cause.err(v193, instance, (`expected {v192}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v192, p[v193])
		end
	}
	return (setmetatable(v193, __Type))
end

local v193 = "DialogChoice"

function GreenTea.DialogChoice()
	local v194 = nil
	v194 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v194, instance, (`expected {v193}, got {typeof(instance)}`))
			end

			if instance:IsA(v193) then
				return __Cause.ok()
			end

			return __Cause.err(v194, instance, (`expected {v193}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v193, p[v194])
		end
	}
	return (setmetatable(v194, __Type))
end

local v194 = "DraftsService"

function GreenTea.DraftsService()
	local v195 = nil
	v195 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v195, instance, (`expected {v194}, got {typeof(instance)}`))
			end

			if instance:IsA(v194) then
				return __Cause.ok()
			end

			return __Cause.err(v195, instance, (`expected {v194}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v194, p[v195])
		end
	}
	return (setmetatable(v195, __Type))
end

local v195 = "Dragger"

function GreenTea.Dragger()
	local v196 = nil
	v196 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v196, instance, (`expected {v195}, got {typeof(instance)}`))
			end

			if instance:IsA(v195) then
				return __Cause.ok()
			end

			return __Cause.err(v196, instance, (`expected {v195}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v195, p[v196])
		end
	}
	return (setmetatable(v196, __Type))
end

local v196 = "DraggerService"

function GreenTea.DraggerService()
	local v197 = nil
	v197 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v197, instance, (`expected {v196}, got {typeof(instance)}`))
			end

			if instance:IsA(v196) then
				return __Cause.ok()
			end

			return __Cause.err(v197, instance, (`expected {v196}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v196, p[v197])
		end
	}
	return (setmetatable(v197, __Type))
end

local v197 = "EditableImage"

function GreenTea.EditableImage()
	local v198 = nil
	v198 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v198, instance, (`expected {v197}, got {typeof(instance)}`))
			end

			if instance:IsA(v197) then
				return __Cause.ok()
			end

			return __Cause.err(v198, instance, (`expected {v197}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v197, p[v198])
		end
	}
	return (setmetatable(v198, __Type))
end

local v198 = "EngineAPICloudProcessingService"

function GreenTea.EngineAPICloudProcessingService()
	local v199 = nil
	v199 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v199, instance, (`expected {v198}, got {typeof(instance)}`))
			end

			if instance:IsA(v198) then
				return __Cause.ok()
			end

			return __Cause.err(v199, instance, (`expected {v198}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v198, p[v199])
		end
	}
	return (setmetatable(v199, __Type))
end

local v199 = "EulerRotationCurve"

function GreenTea.EulerRotationCurve()
	local v200 = nil
	v200 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v200, instance, (`expected {v199}, got {typeof(instance)}`))
			end

			if instance:IsA(v199) then
				return __Cause.ok()
			end

			return __Cause.err(v200, instance, (`expected {v199}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v199, p[v200])
		end
	}
	return (setmetatable(v200, __Type))
end

local v200 = "EventIngestService"

function GreenTea.EventIngestService()
	local v201 = nil
	v201 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v201, instance, (`expected {v200}, got {typeof(instance)}`))
			end

			if instance:IsA(v200) then
				return __Cause.ok()
			end

			return __Cause.err(v201, instance, (`expected {v200}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v200, p[v201])
		end
	}
	return (setmetatable(v201, __Type))
end

local v201 = "ExperienceAuthService"

function GreenTea.ExperienceAuthService()
	local v202 = nil
	v202 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v202, instance, (`expected {v201}, got {typeof(instance)}`))
			end

			if instance:IsA(v201) then
				return __Cause.ok()
			end

			return __Cause.err(v202, instance, (`expected {v201}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v201, p[v202])
		end
	}
	return (setmetatable(v202, __Type))
end

local v202 = "ExperienceInviteOptions"

function GreenTea.ExperienceInviteOptions()
	local v203 = nil
	v203 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v203, instance, (`expected {v202}, got {typeof(instance)}`))
			end

			if instance:IsA(v202) then
				return __Cause.ok()
			end

			return __Cause.err(v203, instance, (`expected {v202}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v202, p[v203])
		end
	}
	return (setmetatable(v203, __Type))
end

local v203 = "ExperienceNotificationService"

function GreenTea.ExperienceNotificationService()
	local v204 = nil
	v204 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v204, instance, (`expected {v203}, got {typeof(instance)}`))
			end

			if instance:IsA(v203) then
				return __Cause.ok()
			end

			return __Cause.err(v204, instance, (`expected {v203}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v203, p[v204])
		end
	}
	return (setmetatable(v204, __Type))
end

local v204 = "ExperienceService"

function GreenTea.ExperienceService()
	local v205 = nil
	v205 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v205, instance, (`expected {v204}, got {typeof(instance)}`))
			end

			if instance:IsA(v204) then
				return __Cause.ok()
			end

			return __Cause.err(v205, instance, (`expected {v204}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v204, p[v205])
		end
	}
	return (setmetatable(v205, __Type))
end

local v205 = "ExperienceStateCaptureService"

function GreenTea.ExperienceStateCaptureService()
	local v206 = nil
	v206 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v206, instance, (`expected {v205}, got {typeof(instance)}`))
			end

			if instance:IsA(v205) then
				return __Cause.ok()
			end

			return __Cause.err(v206, instance, (`expected {v205}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v205, p[v206])
		end
	}
	return (setmetatable(v206, __Type))
end

local v206 = "Explosion"

function GreenTea.Explosion()
	local v207 = nil
	v207 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v207, instance, (`expected {v206}, got {typeof(instance)}`))
			end

			if instance:IsA(v206) then
				return __Cause.ok()
			end

			return __Cause.err(v207, instance, (`expected {v206}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v206, p[v207])
		end
	}
	return (setmetatable(v207, __Type))
end

local v207 = "FaceAnimatorService"

function GreenTea.FaceAnimatorService()
	local v208 = nil
	v208 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v208, instance, (`expected {v207}, got {typeof(instance)}`))
			end

			if instance:IsA(v207) then
				return __Cause.ok()
			end

			return __Cause.err(v208, instance, (`expected {v207}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v207, p[v208])
		end
	}
	return (setmetatable(v208, __Type))
end

local v208 = "FaceControls"

function GreenTea.FaceControls()
	local v209 = nil
	v209 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v209, instance, (`expected {v208}, got {typeof(instance)}`))
			end

			if instance:IsA(v208) then
				return __Cause.ok()
			end

			return __Cause.err(v209, instance, (`expected {v208}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v208, p[v209])
		end
	}
	return (setmetatable(v209, __Type))
end

local v209 = "FaceInstance"

function GreenTea.FaceInstance()
	local v210 = nil
	v210 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v210, instance, (`expected {v209}, got {typeof(instance)}`))
			end

			if instance:IsA(v209) then
				return __Cause.ok()
			end

			return __Cause.err(v210, instance, (`expected {v209}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v209, p[v210])
		end
	}
	return (setmetatable(v210, __Type))
end

local v210 = "Decal"

function GreenTea.Decal()
	local v211 = nil
	v211 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v211, instance, (`expected {v210}, got {typeof(instance)}`))
			end

			if instance:IsA(v210) then
				return __Cause.ok()
			end

			return __Cause.err(v211, instance, (`expected {v210}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v210, p[v211])
		end
	}
	return (setmetatable(v211, __Type))
end

local v211 = "Texture"

function GreenTea.Texture()
	local v212 = nil
	v212 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v212, instance, (`expected {v211}, got {typeof(instance)}`))
			end

			if instance:IsA(v211) then
				return __Cause.ok()
			end

			return __Cause.err(v212, instance, (`expected {v211}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v211, p[v212])
		end
	}
	return (setmetatable(v212, __Type))
end

local v212 = "FacialAnimationRecordingService"

function GreenTea.FacialAnimationRecordingService()
	local v213 = nil
	v213 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v213, instance, (`expected {v212}, got {typeof(instance)}`))
			end

			if instance:IsA(v212) then
				return __Cause.ok()
			end

			return __Cause.err(v213, instance, (`expected {v212}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v212, p[v213])
		end
	}
	return (setmetatable(v213, __Type))
end

local v213 = "FacialAnimationStreamingServiceStats"

function GreenTea.FacialAnimationStreamingServiceStats()
	local v214 = nil
	v214 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v214, instance, (`expected {v213}, got {typeof(instance)}`))
			end

			if instance:IsA(v213) then
				return __Cause.ok()
			end

			return __Cause.err(v214, instance, (`expected {v213}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v213, p[v214])
		end
	}
	return (setmetatable(v214, __Type))
end

local v214 = "FacialAnimationStreamingServiceV2"

function GreenTea.FacialAnimationStreamingServiceV2()
	local v215 = nil
	v215 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v215, instance, (`expected {v214}, got {typeof(instance)}`))
			end

			if instance:IsA(v214) then
				return __Cause.ok()
			end

			return __Cause.err(v215, instance, (`expected {v214}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v214, p[v215])
		end
	}
	return (setmetatable(v215, __Type))
end

local v215 = "FacialAnimationStreamingSubsessionStats"

function GreenTea.FacialAnimationStreamingSubsessionStats()
	local v216 = nil
	v216 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v216, instance, (`expected {v215}, got {typeof(instance)}`))
			end

			if instance:IsA(v215) then
				return __Cause.ok()
			end

			return __Cause.err(v216, instance, (`expected {v215}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v215, p[v216])
		end
	}
	return (setmetatable(v216, __Type))
end

local v216 = "Feature"

function GreenTea.Feature()
	local v217 = nil
	v217 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v217, instance, (`expected {v216}, got {typeof(instance)}`))
			end

			if instance:IsA(v216) then
				return __Cause.ok()
			end

			return __Cause.err(v217, instance, (`expected {v216}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v216, p[v217])
		end
	}
	return (setmetatable(v217, __Type))
end

local v217 = "Hole"

function GreenTea.Hole()
	local v218 = nil
	v218 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v218, instance, (`expected {v217}, got {typeof(instance)}`))
			end

			if instance:IsA(v217) then
				return __Cause.ok()
			end

			return __Cause.err(v218, instance, (`expected {v217}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v217, p[v218])
		end
	}
	return (setmetatable(v218, __Type))
end

local v218 = "MotorFeature"

function GreenTea.MotorFeature()
	local v219 = nil
	v219 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v219, instance, (`expected {v218}, got {typeof(instance)}`))
			end

			if instance:IsA(v218) then
				return __Cause.ok()
			end

			return __Cause.err(v219, instance, (`expected {v218}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v218, p[v219])
		end
	}
	return (setmetatable(v219, __Type))
end

local v219 = "File"

function GreenTea.File()
	local v220 = nil
	v220 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v220, instance, (`expected {v219}, got {typeof(instance)}`))
			end

			if instance:IsA(v219) then
				return __Cause.ok()
			end

			return __Cause.err(v220, instance, (`expected {v219}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v219, p[v220])
		end
	}
	return (setmetatable(v220, __Type))
end

local v220 = "Fire"

function GreenTea.Fire()
	local v221 = nil
	v221 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v221, instance, (`expected {v220}, got {typeof(instance)}`))
			end

			if instance:IsA(v220) then
				return __Cause.ok()
			end

			return __Cause.err(v221, instance, (`expected {v220}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v220, p[v221])
		end
	}
	return (setmetatable(v221, __Type))
end

local v221 = "FlagStandService"

function GreenTea.FlagStandService()
	local v222 = nil
	v222 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v222, instance, (`expected {v221}, got {typeof(instance)}`))
			end

			if instance:IsA(v221) then
				return __Cause.ok()
			end

			return __Cause.err(v222, instance, (`expected {v221}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v221, p[v222])
		end
	}
	return (setmetatable(v222, __Type))
end

local v222 = "FloatCurve"

function GreenTea.FloatCurve()
	local v223 = nil
	v223 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v223, instance, (`expected {v222}, got {typeof(instance)}`))
			end

			if instance:IsA(v222) then
				return __Cause.ok()
			end

			return __Cause.err(v223, instance, (`expected {v222}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v222, p[v223])
		end
	}
	return (setmetatable(v223, __Type))
end

local v223 = "FlyweightService"

function GreenTea.FlyweightService()
	local v224 = nil
	v224 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v224, instance, (`expected {v223}, got {typeof(instance)}`))
			end

			if instance:IsA(v223) then
				return __Cause.ok()
			end

			return __Cause.err(v224, instance, (`expected {v223}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v223, p[v224])
		end
	}
	return (setmetatable(v224, __Type))
end

local v224 = "CSGDictionaryService"

function GreenTea.CSGDictionaryService()
	local v225 = nil
	v225 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v225, instance, (`expected {v224}, got {typeof(instance)}`))
			end

			if instance:IsA(v224) then
				return __Cause.ok()
			end

			return __Cause.err(v225, instance, (`expected {v224}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v224, p[v225])
		end
	}
	return (setmetatable(v225, __Type))
end

local v225 = "NonReplicatedCSGDictionaryService"

function GreenTea.NonReplicatedCSGDictionaryService()
	local v226 = nil
	v226 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v226, instance, (`expected {v225}, got {typeof(instance)}`))
			end

			if instance:IsA(v225) then
				return __Cause.ok()
			end

			return __Cause.err(v226, instance, (`expected {v225}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v225, p[v226])
		end
	}
	return (setmetatable(v226, __Type))
end

local v226 = "Folder"

function GreenTea.Folder()
	local v227 = nil
	v227 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v227, instance, (`expected {v226}, got {typeof(instance)}`))
			end

			if instance:IsA(v226) then
				return __Cause.ok()
			end

			return __Cause.err(v227, instance, (`expected {v226}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v226, p[v227])
		end
	}
	return (setmetatable(v227, __Type))
end

local v227 = "ForceField"

function GreenTea.ForceField()
	local v228 = nil
	v228 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v228, instance, (`expected {v227}, got {typeof(instance)}`))
			end

			if instance:IsA(v227) then
				return __Cause.ok()
			end

			return __Cause.err(v228, instance, (`expected {v227}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v227, p[v228])
		end
	}
	return (setmetatable(v228, __Type))
end

local v228 = "FriendService"

function GreenTea.FriendService()
	local v229 = nil
	v229 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v229, instance, (`expected {v228}, got {typeof(instance)}`))
			end

			if instance:IsA(v228) then
				return __Cause.ok()
			end

			return __Cause.err(v229, instance, (`expected {v228}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v228, p[v229])
		end
	}
	return (setmetatable(v229, __Type))
end

local v229 = "FunctionalTest"

function GreenTea.FunctionalTest()
	local v230 = nil
	v230 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v230, instance, (`expected {v229}, got {typeof(instance)}`))
			end

			if instance:IsA(v229) then
				return __Cause.ok()
			end

			return __Cause.err(v230, instance, (`expected {v229}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v229, p[v230])
		end
	}
	return (setmetatable(v230, __Type))
end

local v230 = "GamePassService"

function GreenTea.GamePassService()
	local v231 = nil
	v231 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v231, instance, (`expected {v230}, got {typeof(instance)}`))
			end

			if instance:IsA(v230) then
				return __Cause.ok()
			end

			return __Cause.err(v231, instance, (`expected {v230}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v230, p[v231])
		end
	}
	return (setmetatable(v231, __Type))
end

local v231 = "GameSettings"

function GreenTea.GameSettings()
	local v232 = nil
	v232 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v232, instance, (`expected {v231}, got {typeof(instance)}`))
			end

			if instance:IsA(v231) then
				return __Cause.ok()
			end

			return __Cause.err(v232, instance, (`expected {v231}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v231, p[v232])
		end
	}
	return (setmetatable(v232, __Type))
end

local v232 = "GamepadService"

function GreenTea.GamepadService()
	local v233 = nil
	v233 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v233, instance, (`expected {v232}, got {typeof(instance)}`))
			end

			if instance:IsA(v232) then
				return __Cause.ok()
			end

			return __Cause.err(v233, instance, (`expected {v232}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v232, p[v233])
		end
	}
	return (setmetatable(v233, __Type))
end

local v233 = "Geometry"

function GreenTea.Geometry()
	local v234 = nil
	v234 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v234, instance, (`expected {v233}, got {typeof(instance)}`))
			end

			if instance:IsA(v233) then
				return __Cause.ok()
			end

			return __Cause.err(v234, instance, (`expected {v233}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v233, p[v234])
		end
	}
	return (setmetatable(v234, __Type))
end

local v234 = "GeometryService"

function GreenTea.GeometryService()
	local v235 = nil
	v235 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v235, instance, (`expected {v234}, got {typeof(instance)}`))
			end

			if instance:IsA(v234) then
				return __Cause.ok()
			end

			return __Cause.err(v235, instance, (`expected {v234}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v234, p[v235])
		end
	}
	return (setmetatable(v235, __Type))
end

local v235 = "GetTextBoundsParams"

function GreenTea.GetTextBoundsParams()
	local v236 = nil
	v236 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v236, instance, (`expected {v235}, got {typeof(instance)}`))
			end

			if instance:IsA(v235) then
				return __Cause.ok()
			end

			return __Cause.err(v236, instance, (`expected {v235}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v235, p[v236])
		end
	}
	return (setmetatable(v236, __Type))
end

local v236 = "GlobalDataStore"

function GreenTea.GlobalDataStore()
	local v237 = nil
	v237 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v237, instance, (`expected {v236}, got {typeof(instance)}`))
			end

			if instance:IsA(v236) then
				return __Cause.ok()
			end

			return __Cause.err(v237, instance, (`expected {v236}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v236, p[v237])
		end
	}
	return (setmetatable(v237, __Type))
end

local v237 = "DataStore"

function GreenTea.DataStore()
	local v238 = nil
	v238 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v238, instance, (`expected {v237}, got {typeof(instance)}`))
			end

			if instance:IsA(v237) then
				return __Cause.ok()
			end

			return __Cause.err(v238, instance, (`expected {v237}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v237, p[v238])
		end
	}
	return (setmetatable(v238, __Type))
end

local v238 = "OrderedDataStore"

function GreenTea.OrderedDataStore()
	local v239 = nil
	v239 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v239, instance, (`expected {v238}, got {typeof(instance)}`))
			end

			if instance:IsA(v238) then
				return __Cause.ok()
			end

			return __Cause.err(v239, instance, (`expected {v238}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v238, p[v239])
		end
	}
	return (setmetatable(v239, __Type))
end

local v239 = "GoogleAnalyticsConfiguration"

function GreenTea.GoogleAnalyticsConfiguration()
	local v240 = nil
	v240 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v240, instance, (`expected {v239}, got {typeof(instance)}`))
			end

			if instance:IsA(v239) then
				return __Cause.ok()
			end

			return __Cause.err(v240, instance, (`expected {v239}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v239, p[v240])
		end
	}
	return (setmetatable(v240, __Type))
end

local v240 = "GroupService"

function GreenTea.GroupService()
	local v241 = nil
	v241 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v241, instance, (`expected {v240}, got {typeof(instance)}`))
			end

			if instance:IsA(v240) then
				return __Cause.ok()
			end

			return __Cause.err(v241, instance, (`expected {v240}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v240, p[v241])
		end
	}
	return (setmetatable(v241, __Type))
end

local v241 = "GuiBase"

function GreenTea.GuiBase()
	local v242 = nil
	v242 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v242, instance, (`expected {v241}, got {typeof(instance)}`))
			end

			if instance:IsA(v241) then
				return __Cause.ok()
			end

			return __Cause.err(v242, instance, (`expected {v241}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v241, p[v242])
		end
	}
	return (setmetatable(v242, __Type))
end

local v242 = "GuiBase2d"

function GreenTea.GuiBase2d()
	local v243 = nil
	v243 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v243, instance, (`expected {v242}, got {typeof(instance)}`))
			end

			if instance:IsA(v242) then
				return __Cause.ok()
			end

			return __Cause.err(v243, instance, (`expected {v242}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v242, p[v243])
		end
	}
	return (setmetatable(v243, __Type))
end

local v243 = "GuiObject"

function GreenTea.GuiObject()
	local v244 = nil
	v244 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v244, instance, (`expected {v243}, got {typeof(instance)}`))
			end

			if instance:IsA(v243) then
				return __Cause.ok()
			end

			return __Cause.err(v244, instance, (`expected {v243}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v243, p[v244])
		end
	}
	return (setmetatable(v244, __Type))
end

local v244 = "CanvasGroup"

function GreenTea.CanvasGroup()
	local v245 = nil
	v245 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v245, instance, (`expected {v244}, got {typeof(instance)}`))
			end

			if instance:IsA(v244) then
				return __Cause.ok()
			end

			return __Cause.err(v245, instance, (`expected {v244}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v244, p[v245])
		end
	}
	return (setmetatable(v245, __Type))
end

local v245 = "Frame"

function GreenTea.Frame()
	local v246 = nil
	v246 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v246, instance, (`expected {v245}, got {typeof(instance)}`))
			end

			if instance:IsA(v245) then
				return __Cause.ok()
			end

			return __Cause.err(v246, instance, (`expected {v245}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v245, p[v246])
		end
	}
	return (setmetatable(v246, __Type))
end

local v246 = "GuiButton"

function GreenTea.GuiButton()
	local v247 = nil
	v247 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v247, instance, (`expected {v246}, got {typeof(instance)}`))
			end

			if instance:IsA(v246) then
				return __Cause.ok()
			end

			return __Cause.err(v247, instance, (`expected {v246}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v246, p[v247])
		end
	}
	return (setmetatable(v247, __Type))
end

local v247 = "ImageButton"

function GreenTea.ImageButton()
	local v248 = nil
	v248 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v248, instance, (`expected {v247}, got {typeof(instance)}`))
			end

			if instance:IsA(v247) then
				return __Cause.ok()
			end

			return __Cause.err(v248, instance, (`expected {v247}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v247, p[v248])
		end
	}
	return (setmetatable(v248, __Type))
end

local v248 = "TextButton"

function GreenTea.TextButton()
	local v249 = nil
	v249 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v249, instance, (`expected {v248}, got {typeof(instance)}`))
			end

			if instance:IsA(v248) then
				return __Cause.ok()
			end

			return __Cause.err(v249, instance, (`expected {v248}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v248, p[v249])
		end
	}
	return (setmetatable(v249, __Type))
end

local v249 = "GuiLabel"

function GreenTea.GuiLabel()
	local v250 = nil
	v250 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v250, instance, (`expected {v249}, got {typeof(instance)}`))
			end

			if instance:IsA(v249) then
				return __Cause.ok()
			end

			return __Cause.err(v250, instance, (`expected {v249}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v249, p[v250])
		end
	}
	return (setmetatable(v250, __Type))
end

local v250 = "ImageLabel"

function GreenTea.ImageLabel()
	local v251 = nil
	v251 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v251, instance, (`expected {v250}, got {typeof(instance)}`))
			end

			if instance:IsA(v250) then
				return __Cause.ok()
			end

			return __Cause.err(v251, instance, (`expected {v250}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v250, p[v251])
		end
	}
	return (setmetatable(v251, __Type))
end

local v251 = "TextLabel"

function GreenTea.TextLabel()
	local v252 = nil
	v252 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v252, instance, (`expected {v251}, got {typeof(instance)}`))
			end

			if instance:IsA(v251) then
				return __Cause.ok()
			end

			return __Cause.err(v252, instance, (`expected {v251}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v251, p[v252])
		end
	}
	return (setmetatable(v252, __Type))
end

local v252 = "ScrollingFrame"

function GreenTea.ScrollingFrame()
	local v253 = nil
	v253 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v253, instance, (`expected {v252}, got {typeof(instance)}`))
			end

			if instance:IsA(v252) then
				return __Cause.ok()
			end

			return __Cause.err(v253, instance, (`expected {v252}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v252, p[v253])
		end
	}
	return (setmetatable(v253, __Type))
end

local v253 = "TextBox"

function GreenTea.TextBox()
	local v254 = nil
	v254 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v254, instance, (`expected {v253}, got {typeof(instance)}`))
			end

			if instance:IsA(v253) then
				return __Cause.ok()
			end

			return __Cause.err(v254, instance, (`expected {v253}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v253, p[v254])
		end
	}
	return (setmetatable(v254, __Type))
end

local v254 = "VideoFrame"

function GreenTea.VideoFrame()
	local v255 = nil
	v255 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v255, instance, (`expected {v254}, got {typeof(instance)}`))
			end

			if instance:IsA(v254) then
				return __Cause.ok()
			end

			return __Cause.err(v255, instance, (`expected {v254}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v254, p[v255])
		end
	}
	return (setmetatable(v255, __Type))
end

local v255 = "ViewportFrame"

function GreenTea.ViewportFrame()
	local v256 = nil
	v256 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v256, instance, (`expected {v255}, got {typeof(instance)}`))
			end

			if instance:IsA(v255) then
				return __Cause.ok()
			end

			return __Cause.err(v256, instance, (`expected {v255}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v255, p[v256])
		end
	}
	return (setmetatable(v256, __Type))
end

local v256 = "LayerCollector"

function GreenTea.LayerCollector()
	local v257 = nil
	v257 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v257, instance, (`expected {v256}, got {typeof(instance)}`))
			end

			if instance:IsA(v256) then
				return __Cause.ok()
			end

			return __Cause.err(v257, instance, (`expected {v256}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v256, p[v257])
		end
	}
	return (setmetatable(v257, __Type))
end

local v257 = "BillboardGui"

function GreenTea.BillboardGui()
	local v258 = nil
	v258 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v258, instance, (`expected {v257}, got {typeof(instance)}`))
			end

			if instance:IsA(v257) then
				return __Cause.ok()
			end

			return __Cause.err(v258, instance, (`expected {v257}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v257, p[v258])
		end
	}
	return (setmetatable(v258, __Type))
end

local v258 = "PluginGui"

function GreenTea.PluginGui()
	local v259 = nil
	v259 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v259, instance, (`expected {v258}, got {typeof(instance)}`))
			end

			if instance:IsA(v258) then
				return __Cause.ok()
			end

			return __Cause.err(v259, instance, (`expected {v258}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v258, p[v259])
		end
	}
	return (setmetatable(v259, __Type))
end

local v259 = "DockWidgetPluginGui"

function GreenTea.DockWidgetPluginGui()
	local v260 = nil
	v260 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v260, instance, (`expected {v259}, got {typeof(instance)}`))
			end

			if instance:IsA(v259) then
				return __Cause.ok()
			end

			return __Cause.err(v260, instance, (`expected {v259}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v259, p[v260])
		end
	}
	return (setmetatable(v260, __Type))
end

local v260 = "QWidgetPluginGui"

function GreenTea.QWidgetPluginGui()
	local v261 = nil
	v261 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v261, instance, (`expected {v260}, got {typeof(instance)}`))
			end

			if instance:IsA(v260) then
				return __Cause.ok()
			end

			return __Cause.err(v261, instance, (`expected {v260}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v260, p[v261])
		end
	}
	return (setmetatable(v261, __Type))
end

local v261 = "ScreenGui"

function GreenTea.ScreenGui()
	local v262 = nil
	v262 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v262, instance, (`expected {v261}, got {typeof(instance)}`))
			end

			if instance:IsA(v261) then
				return __Cause.ok()
			end

			return __Cause.err(v262, instance, (`expected {v261}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v261, p[v262])
		end
	}
	return (setmetatable(v262, __Type))
end

local v262 = "GuiMain"

function GreenTea.GuiMain()
	local v263 = nil
	v263 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v263, instance, (`expected {v262}, got {typeof(instance)}`))
			end

			if instance:IsA(v262) then
				return __Cause.ok()
			end

			return __Cause.err(v263, instance, (`expected {v262}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v262, p[v263])
		end
	}
	return (setmetatable(v263, __Type))
end

local v263 = "SurfaceGuiBase"

function GreenTea.SurfaceGuiBase()
	local v264 = nil
	v264 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v264, instance, (`expected {v263}, got {typeof(instance)}`))
			end

			if instance:IsA(v263) then
				return __Cause.ok()
			end

			return __Cause.err(v264, instance, (`expected {v263}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v263, p[v264])
		end
	}
	return (setmetatable(v264, __Type))
end

local v264 = "AdGui"

function GreenTea.AdGui()
	local v265 = nil
	v265 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v265, instance, (`expected {v264}, got {typeof(instance)}`))
			end

			if instance:IsA(v264) then
				return __Cause.ok()
			end

			return __Cause.err(v265, instance, (`expected {v264}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v264, p[v265])
		end
	}
	return (setmetatable(v265, __Type))
end

local v265 = "SurfaceGui"

function GreenTea.SurfaceGui()
	local v266 = nil
	v266 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v266, instance, (`expected {v265}, got {typeof(instance)}`))
			end

			if instance:IsA(v265) then
				return __Cause.ok()
			end

			return __Cause.err(v266, instance, (`expected {v265}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v265, p[v266])
		end
	}
	return (setmetatable(v266, __Type))
end

local v266 = "GuiBase3d"

function GreenTea.GuiBase3d()
	local v267 = nil
	v267 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v267, instance, (`expected {v266}, got {typeof(instance)}`))
			end

			if instance:IsA(v266) then
				return __Cause.ok()
			end

			return __Cause.err(v267, instance, (`expected {v266}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v266, p[v267])
		end
	}
	return (setmetatable(v267, __Type))
end

local v267 = "FloorWire"

function GreenTea.FloorWire()
	local v268 = nil
	v268 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v268, instance, (`expected {v267}, got {typeof(instance)}`))
			end

			if instance:IsA(v267) then
				return __Cause.ok()
			end

			return __Cause.err(v268, instance, (`expected {v267}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v267, p[v268])
		end
	}
	return (setmetatable(v268, __Type))
end

local v268 = "InstanceAdornment"

function GreenTea.InstanceAdornment()
	local v269 = nil
	v269 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v269, instance, (`expected {v268}, got {typeof(instance)}`))
			end

			if instance:IsA(v268) then
				return __Cause.ok()
			end

			return __Cause.err(v269, instance, (`expected {v268}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v268, p[v269])
		end
	}
	return (setmetatable(v269, __Type))
end

local v269 = "SelectionBox"

function GreenTea.SelectionBox()
	local v270 = nil
	v270 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v270, instance, (`expected {v269}, got {typeof(instance)}`))
			end

			if instance:IsA(v269) then
				return __Cause.ok()
			end

			return __Cause.err(v270, instance, (`expected {v269}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v269, p[v270])
		end
	}
	return (setmetatable(v270, __Type))
end

local v270 = "PVAdornment"

function GreenTea.PVAdornment()
	local v271 = nil
	v271 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v271, instance, (`expected {v270}, got {typeof(instance)}`))
			end

			if instance:IsA(v270) then
				return __Cause.ok()
			end

			return __Cause.err(v271, instance, (`expected {v270}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v270, p[v271])
		end
	}
	return (setmetatable(v271, __Type))
end

local v271 = "HandleAdornment"

function GreenTea.HandleAdornment()
	local v272 = nil
	v272 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v272, instance, (`expected {v271}, got {typeof(instance)}`))
			end

			if instance:IsA(v271) then
				return __Cause.ok()
			end

			return __Cause.err(v272, instance, (`expected {v271}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v271, p[v272])
		end
	}
	return (setmetatable(v272, __Type))
end

local v272 = "BoxHandleAdornment"

function GreenTea.BoxHandleAdornment()
	local v273 = nil
	v273 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v273, instance, (`expected {v272}, got {typeof(instance)}`))
			end

			if instance:IsA(v272) then
				return __Cause.ok()
			end

			return __Cause.err(v273, instance, (`expected {v272}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v272, p[v273])
		end
	}
	return (setmetatable(v273, __Type))
end

local v273 = "ConeHandleAdornment"

function GreenTea.ConeHandleAdornment()
	local v274 = nil
	v274 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v274, instance, (`expected {v273}, got {typeof(instance)}`))
			end

			if instance:IsA(v273) then
				return __Cause.ok()
			end

			return __Cause.err(v274, instance, (`expected {v273}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v273, p[v274])
		end
	}
	return (setmetatable(v274, __Type))
end

local v274 = "CylinderHandleAdornment"

function GreenTea.CylinderHandleAdornment()
	local v275 = nil
	v275 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v275, instance, (`expected {v274}, got {typeof(instance)}`))
			end

			if instance:IsA(v274) then
				return __Cause.ok()
			end

			return __Cause.err(v275, instance, (`expected {v274}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v274, p[v275])
		end
	}
	return (setmetatable(v275, __Type))
end

local v275 = "ImageHandleAdornment"

function GreenTea.ImageHandleAdornment()
	local v276 = nil
	v276 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v276, instance, (`expected {v275}, got {typeof(instance)}`))
			end

			if instance:IsA(v275) then
				return __Cause.ok()
			end

			return __Cause.err(v276, instance, (`expected {v275}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v275, p[v276])
		end
	}
	return (setmetatable(v276, __Type))
end

local v276 = "LineHandleAdornment"

function GreenTea.LineHandleAdornment()
	local v277 = nil
	v277 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v277, instance, (`expected {v276}, got {typeof(instance)}`))
			end

			if instance:IsA(v276) then
				return __Cause.ok()
			end

			return __Cause.err(v277, instance, (`expected {v276}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v276, p[v277])
		end
	}
	return (setmetatable(v277, __Type))
end

local v277 = "SphereHandleAdornment"

function GreenTea.SphereHandleAdornment()
	local v278 = nil
	v278 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v278, instance, (`expected {v277}, got {typeof(instance)}`))
			end

			if instance:IsA(v277) then
				return __Cause.ok()
			end

			return __Cause.err(v278, instance, (`expected {v277}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v277, p[v278])
		end
	}
	return (setmetatable(v278, __Type))
end

local v278 = "WireframeHandleAdornment"

function GreenTea.WireframeHandleAdornment()
	local v279 = nil
	v279 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v279, instance, (`expected {v278}, got {typeof(instance)}`))
			end

			if instance:IsA(v278) then
				return __Cause.ok()
			end

			return __Cause.err(v279, instance, (`expected {v278}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v278, p[v279])
		end
	}
	return (setmetatable(v279, __Type))
end

local v279 = "ParabolaAdornment"

function GreenTea.ParabolaAdornment()
	local v280 = nil
	v280 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v280, instance, (`expected {v279}, got {typeof(instance)}`))
			end

			if instance:IsA(v279) then
				return __Cause.ok()
			end

			return __Cause.err(v280, instance, (`expected {v279}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v279, p[v280])
		end
	}
	return (setmetatable(v280, __Type))
end

local v280 = "SelectionSphere"

function GreenTea.SelectionSphere()
	local v281 = nil
	v281 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v281, instance, (`expected {v280}, got {typeof(instance)}`))
			end

			if instance:IsA(v280) then
				return __Cause.ok()
			end

			return __Cause.err(v281, instance, (`expected {v280}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v280, p[v281])
		end
	}
	return (setmetatable(v281, __Type))
end

local v281 = "PartAdornment"

function GreenTea.PartAdornment()
	local v282 = nil
	v282 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v282, instance, (`expected {v281}, got {typeof(instance)}`))
			end

			if instance:IsA(v281) then
				return __Cause.ok()
			end

			return __Cause.err(v282, instance, (`expected {v281}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v281, p[v282])
		end
	}
	return (setmetatable(v282, __Type))
end

local v282 = "HandlesBase"

function GreenTea.HandlesBase()
	local v283 = nil
	v283 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v283, instance, (`expected {v282}, got {typeof(instance)}`))
			end

			if instance:IsA(v282) then
				return __Cause.ok()
			end

			return __Cause.err(v283, instance, (`expected {v282}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v282, p[v283])
		end
	}
	return (setmetatable(v283, __Type))
end

local v283 = "ArcHandles"

function GreenTea.ArcHandles()
	local v284 = nil
	v284 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v284, instance, (`expected {v283}, got {typeof(instance)}`))
			end

			if instance:IsA(v283) then
				return __Cause.ok()
			end

			return __Cause.err(v284, instance, (`expected {v283}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v283, p[v284])
		end
	}
	return (setmetatable(v284, __Type))
end

local v284 = "Handles"

function GreenTea.Handles()
	local v285 = nil
	v285 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v285, instance, (`expected {v284}, got {typeof(instance)}`))
			end

			if instance:IsA(v284) then
				return __Cause.ok()
			end

			return __Cause.err(v285, instance, (`expected {v284}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v284, p[v285])
		end
	}
	return (setmetatable(v285, __Type))
end

local v285 = "SurfaceSelection"

function GreenTea.SurfaceSelection()
	local v286 = nil
	v286 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v286, instance, (`expected {v285}, got {typeof(instance)}`))
			end

			if instance:IsA(v285) then
				return __Cause.ok()
			end

			return __Cause.err(v286, instance, (`expected {v285}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v285, p[v286])
		end
	}
	return (setmetatable(v286, __Type))
end

local v286 = "SelectionLasso"

function GreenTea.SelectionLasso()
	local v287 = nil
	v287 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v287, instance, (`expected {v286}, got {typeof(instance)}`))
			end

			if instance:IsA(v286) then
				return __Cause.ok()
			end

			return __Cause.err(v287, instance, (`expected {v286}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v286, p[v287])
		end
	}
	return (setmetatable(v287, __Type))
end

local v287 = "SelectionPartLasso"

function GreenTea.SelectionPartLasso()
	local v288 = nil
	v288 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v288, instance, (`expected {v287}, got {typeof(instance)}`))
			end

			if instance:IsA(v287) then
				return __Cause.ok()
			end

			return __Cause.err(v288, instance, (`expected {v287}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v287, p[v288])
		end
	}
	return (setmetatable(v288, __Type))
end

local v288 = "SelectionPointLasso"

function GreenTea.SelectionPointLasso()
	local v289 = nil
	v289 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v289, instance, (`expected {v288}, got {typeof(instance)}`))
			end

			if instance:IsA(v288) then
				return __Cause.ok()
			end

			return __Cause.err(v289, instance, (`expected {v288}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v288, p[v289])
		end
	}
	return (setmetatable(v289, __Type))
end

local v289 = "Path2D"

function GreenTea.Path2D()
	local v290 = nil
	v290 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v290, instance, (`expected {v289}, got {typeof(instance)}`))
			end

			if instance:IsA(v289) then
				return __Cause.ok()
			end

			return __Cause.err(v290, instance, (`expected {v289}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v289, p[v290])
		end
	}
	return (setmetatable(v290, __Type))
end

local v290 = "GuiService"

function GreenTea.GuiService()
	local v291 = nil
	v291 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v291, instance, (`expected {v290}, got {typeof(instance)}`))
			end

			if instance:IsA(v290) then
				return __Cause.ok()
			end

			return __Cause.err(v291, instance, (`expected {v290}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v290, p[v291])
		end
	}
	return (setmetatable(v291, __Type))
end

local v291 = "GuidRegistryService"

function GreenTea.GuidRegistryService()
	local v292 = nil
	v292 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v292, instance, (`expected {v291}, got {typeof(instance)}`))
			end

			if instance:IsA(v291) then
				return __Cause.ok()
			end

			return __Cause.err(v292, instance, (`expected {v291}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v291, p[v292])
		end
	}
	return (setmetatable(v292, __Type))
end

local v292 = "HapticService"

function GreenTea.HapticService()
	local v293 = nil
	v293 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v293, instance, (`expected {v292}, got {typeof(instance)}`))
			end

			if instance:IsA(v292) then
				return __Cause.ok()
			end

			return __Cause.err(v293, instance, (`expected {v292}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v292, p[v293])
		end
	}
	return (setmetatable(v293, __Type))
end

local v293 = "HeightmapImporterService"

function GreenTea.HeightmapImporterService()
	local v294 = nil
	v294 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v294, instance, (`expected {v293}, got {typeof(instance)}`))
			end

			if instance:IsA(v293) then
				return __Cause.ok()
			end

			return __Cause.err(v294, instance, (`expected {v293}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v293, p[v294])
		end
	}
	return (setmetatable(v294, __Type))
end

local v294 = "HiddenSurfaceRemovalAsset"

function GreenTea.HiddenSurfaceRemovalAsset()
	local v295 = nil
	v295 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v295, instance, (`expected {v294}, got {typeof(instance)}`))
			end

			if instance:IsA(v294) then
				return __Cause.ok()
			end

			return __Cause.err(v295, instance, (`expected {v294}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v294, p[v295])
		end
	}
	return (setmetatable(v295, __Type))
end

local v295 = "Highlight"

function GreenTea.Highlight()
	local v296 = nil
	v296 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v296, instance, (`expected {v295}, got {typeof(instance)}`))
			end

			if instance:IsA(v295) then
				return __Cause.ok()
			end

			return __Cause.err(v296, instance, (`expected {v295}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v295, p[v296])
		end
	}
	return (setmetatable(v296, __Type))
end

local v296 = "Hopper"

function GreenTea.Hopper()
	local v297 = nil
	v297 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v297, instance, (`expected {v296}, got {typeof(instance)}`))
			end

			if instance:IsA(v296) then
				return __Cause.ok()
			end

			return __Cause.err(v297, instance, (`expected {v296}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v296, p[v297])
		end
	}
	return (setmetatable(v297, __Type))
end

local v297 = "HttpRbxApiService"

function GreenTea.HttpRbxApiService()
	local v298 = nil
	v298 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v298, instance, (`expected {v297}, got {typeof(instance)}`))
			end

			if instance:IsA(v297) then
				return __Cause.ok()
			end

			return __Cause.err(v298, instance, (`expected {v297}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v297, p[v298])
		end
	}
	return (setmetatable(v298, __Type))
end

local v298 = "HttpRequest"

function GreenTea.HttpRequest()
	local v299 = nil
	v299 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v299, instance, (`expected {v298}, got {typeof(instance)}`))
			end

			if instance:IsA(v298) then
				return __Cause.ok()
			end

			return __Cause.err(v299, instance, (`expected {v298}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v298, p[v299])
		end
	}
	return (setmetatable(v299, __Type))
end

local v299 = "HttpService"

function GreenTea.HttpService()
	local v300 = nil
	v300 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v300, instance, (`expected {v299}, got {typeof(instance)}`))
			end

			if instance:IsA(v299) then
				return __Cause.ok()
			end

			return __Cause.err(v300, instance, (`expected {v299}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v299, p[v300])
		end
	}
	return (setmetatable(v300, __Type))
end

local v300 = "Humanoid"

function GreenTea.Humanoid()
	local v301 = nil
	v301 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v301, instance, (`expected {v300}, got {typeof(instance)}`))
			end

			if instance:IsA(v300) then
				return __Cause.ok()
			end

			return __Cause.err(v301, instance, (`expected {v300}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v300, p[v301])
		end
	}
	return (setmetatable(v301, __Type))
end

local v301 = "HumanoidDescription"

function GreenTea.HumanoidDescription()
	local v302 = nil
	v302 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v302, instance, (`expected {v301}, got {typeof(instance)}`))
			end

			if instance:IsA(v301) then
				return __Cause.ok()
			end

			return __Cause.err(v302, instance, (`expected {v301}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v301, p[v302])
		end
	}
	return (setmetatable(v302, __Type))
end

local v302 = "IKControl"

function GreenTea.IKControl()
	local v303 = nil
	v303 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v303, instance, (`expected {v302}, got {typeof(instance)}`))
			end

			if instance:IsA(v302) then
				return __Cause.ok()
			end

			return __Cause.err(v303, instance, (`expected {v302}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v302, p[v303])
		end
	}
	return (setmetatable(v303, __Type))
end

local v303 = "ILegacyStudioBridge"

function GreenTea.ILegacyStudioBridge()
	local v304 = nil
	v304 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v304, instance, (`expected {v303}, got {typeof(instance)}`))
			end

			if instance:IsA(v303) then
				return __Cause.ok()
			end

			return __Cause.err(v304, instance, (`expected {v303}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v303, p[v304])
		end
	}
	return (setmetatable(v304, __Type))
end

local v304 = "LegacyStudioBridge"

function GreenTea.LegacyStudioBridge()
	local v305 = nil
	v305 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v305, instance, (`expected {v304}, got {typeof(instance)}`))
			end

			if instance:IsA(v304) then
				return __Cause.ok()
			end

			return __Cause.err(v305, instance, (`expected {v304}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v304, p[v305])
		end
	}
	return (setmetatable(v305, __Type))
end

local v305 = "IXPService"

function GreenTea.IXPService()
	local v306 = nil
	v306 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v306, instance, (`expected {v305}, got {typeof(instance)}`))
			end

			if instance:IsA(v305) then
				return __Cause.ok()
			end

			return __Cause.err(v306, instance, (`expected {v305}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v305, p[v306])
		end
	}
	return (setmetatable(v306, __Type))
end

local v306 = "IncrementalPatchBuilder"

function GreenTea.IncrementalPatchBuilder()
	local v307 = nil
	v307 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v307, instance, (`expected {v306}, got {typeof(instance)}`))
			end

			if instance:IsA(v306) then
				return __Cause.ok()
			end

			return __Cause.err(v307, instance, (`expected {v306}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v306, p[v307])
		end
	}
	return (setmetatable(v307, __Type))
end

local v307 = "InputObject"

function GreenTea.InputObject()
	local v308 = nil
	v308 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v308, instance, (`expected {v307}, got {typeof(instance)}`))
			end

			if instance:IsA(v307) then
				return __Cause.ok()
			end

			return __Cause.err(v308, instance, (`expected {v307}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v307, p[v308])
		end
	}
	return (setmetatable(v308, __Type))
end

local v308 = "InsertService"

function GreenTea.InsertService()
	local v309 = nil
	v309 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v309, instance, (`expected {v308}, got {typeof(instance)}`))
			end

			if instance:IsA(v308) then
				return __Cause.ok()
			end

			return __Cause.err(v309, instance, (`expected {v308}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v308, p[v309])
		end
	}
	return (setmetatable(v309, __Type))
end

local v309 = "JointInstance"

function GreenTea.JointInstance()
	local v310 = nil
	v310 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v310, instance, (`expected {v309}, got {typeof(instance)}`))
			end

			if instance:IsA(v309) then
				return __Cause.ok()
			end

			return __Cause.err(v310, instance, (`expected {v309}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v309, p[v310])
		end
	}
	return (setmetatable(v310, __Type))
end

local v310 = "DynamicRotate"

function GreenTea.DynamicRotate()
	local v311 = nil
	v311 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v311, instance, (`expected {v310}, got {typeof(instance)}`))
			end

			if instance:IsA(v310) then
				return __Cause.ok()
			end

			return __Cause.err(v311, instance, (`expected {v310}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v310, p[v311])
		end
	}
	return (setmetatable(v311, __Type))
end

local v311 = "RotateP"

function GreenTea.RotateP()
	local v312 = nil
	v312 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v312, instance, (`expected {v311}, got {typeof(instance)}`))
			end

			if instance:IsA(v311) then
				return __Cause.ok()
			end

			return __Cause.err(v312, instance, (`expected {v311}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v311, p[v312])
		end
	}
	return (setmetatable(v312, __Type))
end

local v312 = "RotateV"

function GreenTea.RotateV()
	local v313 = nil
	v313 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v313, instance, (`expected {v312}, got {typeof(instance)}`))
			end

			if instance:IsA(v312) then
				return __Cause.ok()
			end

			return __Cause.err(v313, instance, (`expected {v312}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v312, p[v313])
		end
	}
	return (setmetatable(v313, __Type))
end

local v313 = "Glue"

function GreenTea.Glue()
	local v314 = nil
	v314 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v314, instance, (`expected {v313}, got {typeof(instance)}`))
			end

			if instance:IsA(v313) then
				return __Cause.ok()
			end

			return __Cause.err(v314, instance, (`expected {v313}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v313, p[v314])
		end
	}
	return (setmetatable(v314, __Type))
end

local v314 = "ManualSurfaceJointInstance"

function GreenTea.ManualSurfaceJointInstance()
	local v315 = nil
	v315 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v315, instance, (`expected {v314}, got {typeof(instance)}`))
			end

			if instance:IsA(v314) then
				return __Cause.ok()
			end

			return __Cause.err(v315, instance, (`expected {v314}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v314, p[v315])
		end
	}
	return (setmetatable(v315, __Type))
end

local v315 = "ManualGlue"

function GreenTea.ManualGlue()
	local v316 = nil
	v316 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v316, instance, (`expected {v315}, got {typeof(instance)}`))
			end

			if instance:IsA(v315) then
				return __Cause.ok()
			end

			return __Cause.err(v316, instance, (`expected {v315}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v315, p[v316])
		end
	}
	return (setmetatable(v316, __Type))
end

local v316 = "ManualWeld"

function GreenTea.ManualWeld()
	local v317 = nil
	v317 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v317, instance, (`expected {v316}, got {typeof(instance)}`))
			end

			if instance:IsA(v316) then
				return __Cause.ok()
			end

			return __Cause.err(v317, instance, (`expected {v316}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v316, p[v317])
		end
	}
	return (setmetatable(v317, __Type))
end

local v317 = "Motor"

function GreenTea.Motor()
	local v318 = nil
	v318 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v318, instance, (`expected {v317}, got {typeof(instance)}`))
			end

			if instance:IsA(v317) then
				return __Cause.ok()
			end

			return __Cause.err(v318, instance, (`expected {v317}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v317, p[v318])
		end
	}
	return (setmetatable(v318, __Type))
end

local v318 = "Motor6D"

function GreenTea.Motor6D()
	local v319 = nil
	v319 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v319, instance, (`expected {v318}, got {typeof(instance)}`))
			end

			if instance:IsA(v318) then
				return __Cause.ok()
			end

			return __Cause.err(v319, instance, (`expected {v318}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v318, p[v319])
		end
	}
	return (setmetatable(v319, __Type))
end

local v319 = "Rotate"

function GreenTea.Rotate()
	local v320 = nil
	v320 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v320, instance, (`expected {v319}, got {typeof(instance)}`))
			end

			if instance:IsA(v319) then
				return __Cause.ok()
			end

			return __Cause.err(v320, instance, (`expected {v319}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v319, p[v320])
		end
	}
	return (setmetatable(v320, __Type))
end

local v320 = "Snap"

function GreenTea.Snap()
	local v321 = nil
	v321 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v321, instance, (`expected {v320}, got {typeof(instance)}`))
			end

			if instance:IsA(v320) then
				return __Cause.ok()
			end

			return __Cause.err(v321, instance, (`expected {v320}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v320, p[v321])
		end
	}
	return (setmetatable(v321, __Type))
end

local v321 = "VelocityMotor"

function GreenTea.VelocityMotor()
	local v322 = nil
	v322 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v322, instance, (`expected {v321}, got {typeof(instance)}`))
			end

			if instance:IsA(v321) then
				return __Cause.ok()
			end

			return __Cause.err(v322, instance, (`expected {v321}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v321, p[v322])
		end
	}
	return (setmetatable(v322, __Type))
end

local v322 = "Weld"

function GreenTea.Weld()
	local v323 = nil
	v323 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v323, instance, (`expected {v322}, got {typeof(instance)}`))
			end

			if instance:IsA(v322) then
				return __Cause.ok()
			end

			return __Cause.err(v323, instance, (`expected {v322}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v322, p[v323])
		end
	}
	return (setmetatable(v323, __Type))
end

local v323 = "JointsService"

function GreenTea.JointsService()
	local v324 = nil
	v324 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v324, instance, (`expected {v323}, got {typeof(instance)}`))
			end

			if instance:IsA(v323) then
				return __Cause.ok()
			end

			return __Cause.err(v324, instance, (`expected {v323}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v323, p[v324])
		end
	}
	return (setmetatable(v324, __Type))
end

local v324 = "KeyboardService"

function GreenTea.KeyboardService()
	local v325 = nil
	v325 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v325, instance, (`expected {v324}, got {typeof(instance)}`))
			end

			if instance:IsA(v324) then
				return __Cause.ok()
			end

			return __Cause.err(v325, instance, (`expected {v324}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v324, p[v325])
		end
	}
	return (setmetatable(v325, __Type))
end

local v325 = "Keyframe"

function GreenTea.Keyframe()
	local v326 = nil
	v326 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v326, instance, (`expected {v325}, got {typeof(instance)}`))
			end

			if instance:IsA(v325) then
				return __Cause.ok()
			end

			return __Cause.err(v326, instance, (`expected {v325}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v325, p[v326])
		end
	}
	return (setmetatable(v326, __Type))
end

local v326 = "KeyframeMarker"

function GreenTea.KeyframeMarker()
	local v327 = nil
	v327 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v327, instance, (`expected {v326}, got {typeof(instance)}`))
			end

			if instance:IsA(v326) then
				return __Cause.ok()
			end

			return __Cause.err(v327, instance, (`expected {v326}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v326, p[v327])
		end
	}
	return (setmetatable(v327, __Type))
end

local v327 = "KeyframeSequenceProvider"

function GreenTea.KeyframeSequenceProvider()
	local v328 = nil
	v328 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v328, instance, (`expected {v327}, got {typeof(instance)}`))
			end

			if instance:IsA(v327) then
				return __Cause.ok()
			end

			return __Cause.err(v328, instance, (`expected {v327}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v327, p[v328])
		end
	}
	return (setmetatable(v328, __Type))
end

local v328 = "LSPFileSyncService"

function GreenTea.LSPFileSyncService()
	local v329 = nil
	v329 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v329, instance, (`expected {v328}, got {typeof(instance)}`))
			end

			if instance:IsA(v328) then
				return __Cause.ok()
			end

			return __Cause.err(v329, instance, (`expected {v328}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v328, p[v329])
		end
	}
	return (setmetatable(v329, __Type))
end

local v329 = "LanguageService"

function GreenTea.LanguageService()
	local v330 = nil
	v330 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v330, instance, (`expected {v329}, got {typeof(instance)}`))
			end

			if instance:IsA(v329) then
				return __Cause.ok()
			end

			return __Cause.err(v330, instance, (`expected {v329}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v329, p[v330])
		end
	}
	return (setmetatable(v330, __Type))
end

local v330 = "Light"

function GreenTea.Light()
	local v331 = nil
	v331 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v331, instance, (`expected {v330}, got {typeof(instance)}`))
			end

			if instance:IsA(v330) then
				return __Cause.ok()
			end

			return __Cause.err(v331, instance, (`expected {v330}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v330, p[v331])
		end
	}
	return (setmetatable(v331, __Type))
end

local v331 = "PointLight"

function GreenTea.PointLight()
	local v332 = nil
	v332 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v332, instance, (`expected {v331}, got {typeof(instance)}`))
			end

			if instance:IsA(v331) then
				return __Cause.ok()
			end

			return __Cause.err(v332, instance, (`expected {v331}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v331, p[v332])
		end
	}
	return (setmetatable(v332, __Type))
end

local v332 = "SpotLight"

function GreenTea.SpotLight()
	local v333 = nil
	v333 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v333, instance, (`expected {v332}, got {typeof(instance)}`))
			end

			if instance:IsA(v332) then
				return __Cause.ok()
			end

			return __Cause.err(v333, instance, (`expected {v332}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v332, p[v333])
		end
	}
	return (setmetatable(v333, __Type))
end

local v333 = "SurfaceLight"

function GreenTea.SurfaceLight()
	local v334 = nil
	v334 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v334, instance, (`expected {v333}, got {typeof(instance)}`))
			end

			if instance:IsA(v333) then
				return __Cause.ok()
			end

			return __Cause.err(v334, instance, (`expected {v333}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v333, p[v334])
		end
	}
	return (setmetatable(v334, __Type))
end

local v334 = "Lighting"

function GreenTea.Lighting()
	local v335 = nil
	v335 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v335, instance, (`expected {v334}, got {typeof(instance)}`))
			end

			if instance:IsA(v334) then
				return __Cause.ok()
			end

			return __Cause.err(v335, instance, (`expected {v334}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v334, p[v335])
		end
	}
	return (setmetatable(v335, __Type))
end

local v335 = "LiveScriptingService"

function GreenTea.LiveScriptingService()
	local v336 = nil
	v336 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v336, instance, (`expected {v335}, got {typeof(instance)}`))
			end

			if instance:IsA(v335) then
				return __Cause.ok()
			end

			return __Cause.err(v336, instance, (`expected {v335}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v335, p[v336])
		end
	}
	return (setmetatable(v336, __Type))
end

local v336 = "LocalStorageService"

function GreenTea.LocalStorageService()
	local v337 = nil
	v337 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v337, instance, (`expected {v336}, got {typeof(instance)}`))
			end

			if instance:IsA(v336) then
				return __Cause.ok()
			end

			return __Cause.err(v337, instance, (`expected {v336}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v336, p[v337])
		end
	}
	return (setmetatable(v337, __Type))
end

local v337 = "AppStorageService"

function GreenTea.AppStorageService()
	local v338 = nil
	v338 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v338, instance, (`expected {v337}, got {typeof(instance)}`))
			end

			if instance:IsA(v337) then
				return __Cause.ok()
			end

			return __Cause.err(v338, instance, (`expected {v337}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v337, p[v338])
		end
	}
	return (setmetatable(v338, __Type))
end

local v338 = "UserStorageService"

function GreenTea.UserStorageService()
	local v339 = nil
	v339 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v339, instance, (`expected {v338}, got {typeof(instance)}`))
			end

			if instance:IsA(v338) then
				return __Cause.ok()
			end

			return __Cause.err(v339, instance, (`expected {v338}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v338, p[v339])
		end
	}
	return (setmetatable(v339, __Type))
end

local v339 = "LocalizationService"

function GreenTea.LocalizationService()
	local v340 = nil
	v340 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v340, instance, (`expected {v339}, got {typeof(instance)}`))
			end

			if instance:IsA(v339) then
				return __Cause.ok()
			end

			return __Cause.err(v340, instance, (`expected {v339}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v339, p[v340])
		end
	}
	return (setmetatable(v340, __Type))
end

local v340 = "LocalizationTable"

function GreenTea.LocalizationTable()
	local v341 = nil
	v341 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v341, instance, (`expected {v340}, got {typeof(instance)}`))
			end

			if instance:IsA(v340) then
				return __Cause.ok()
			end

			return __Cause.err(v341, instance, (`expected {v340}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v340, p[v341])
		end
	}
	return (setmetatable(v341, __Type))
end

local v341 = "CloudLocalizationTable"

function GreenTea.CloudLocalizationTable()
	local v342 = nil
	v342 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v342, instance, (`expected {v341}, got {typeof(instance)}`))
			end

			if instance:IsA(v341) then
				return __Cause.ok()
			end

			return __Cause.err(v342, instance, (`expected {v341}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v341, p[v342])
		end
	}
	return (setmetatable(v342, __Type))
end

local v342 = "LodDataEntity"

function GreenTea.LodDataEntity()
	local v343 = nil
	v343 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v343, instance, (`expected {v342}, got {typeof(instance)}`))
			end

			if instance:IsA(v342) then
				return __Cause.ok()
			end

			return __Cause.err(v343, instance, (`expected {v342}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v342, p[v343])
		end
	}
	return (setmetatable(v343, __Type))
end

local v343 = "LodDataService"

function GreenTea.LodDataService()
	local v344 = nil
	v344 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v344, instance, (`expected {v343}, got {typeof(instance)}`))
			end

			if instance:IsA(v343) then
				return __Cause.ok()
			end

			return __Cause.err(v344, instance, (`expected {v343}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v343, p[v344])
		end
	}
	return (setmetatable(v344, __Type))
end

local v344 = "LogReporterService"

function GreenTea.LogReporterService()
	local v345 = nil
	v345 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v345, instance, (`expected {v344}, got {typeof(instance)}`))
			end

			if instance:IsA(v344) then
				return __Cause.ok()
			end

			return __Cause.err(v345, instance, (`expected {v344}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v344, p[v345])
		end
	}
	return (setmetatable(v345, __Type))
end

local v345 = "LogService"

function GreenTea.LogService()
	local v346 = nil
	v346 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v346, instance, (`expected {v345}, got {typeof(instance)}`))
			end

			if instance:IsA(v345) then
				return __Cause.ok()
			end

			return __Cause.err(v346, instance, (`expected {v345}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v345, p[v346])
		end
	}
	return (setmetatable(v346, __Type))
end

local v346 = "LoginService"

function GreenTea.LoginService()
	local v347 = nil
	v347 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v347, instance, (`expected {v346}, got {typeof(instance)}`))
			end

			if instance:IsA(v346) then
				return __Cause.ok()
			end

			return __Cause.err(v347, instance, (`expected {v346}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v346, p[v347])
		end
	}
	return (setmetatable(v347, __Type))
end

local v347 = "LuaSettings"

function GreenTea.LuaSettings()
	local v348 = nil
	v348 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v348, instance, (`expected {v347}, got {typeof(instance)}`))
			end

			if instance:IsA(v347) then
				return __Cause.ok()
			end

			return __Cause.err(v348, instance, (`expected {v347}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v347, p[v348])
		end
	}
	return (setmetatable(v348, __Type))
end

local v348 = "LuaSourceContainer"

function GreenTea.LuaSourceContainer()
	local v349 = nil
	v349 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v349, instance, (`expected {v348}, got {typeof(instance)}`))
			end

			if instance:IsA(v348) then
				return __Cause.ok()
			end

			return __Cause.err(v349, instance, (`expected {v348}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v348, p[v349])
		end
	}
	return (setmetatable(v349, __Type))
end

local v349 = "BaseScript"

function GreenTea.BaseScript()
	local v350 = nil
	v350 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v350, instance, (`expected {v349}, got {typeof(instance)}`))
			end

			if instance:IsA(v349) then
				return __Cause.ok()
			end

			return __Cause.err(v350, instance, (`expected {v349}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v349, p[v350])
		end
	}
	return (setmetatable(v350, __Type))
end

local v350 = "CoreScript"

function GreenTea.CoreScript()
	local v351 = nil
	v351 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v351, instance, (`expected {v350}, got {typeof(instance)}`))
			end

			if instance:IsA(v350) then
				return __Cause.ok()
			end

			return __Cause.err(v351, instance, (`expected {v350}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v350, p[v351])
		end
	}
	return (setmetatable(v351, __Type))
end

local v351 = "Script"

function GreenTea.Script()
	local v352 = nil
	v352 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v352, instance, (`expected {v351}, got {typeof(instance)}`))
			end

			if instance:IsA(v351) then
				return __Cause.ok()
			end

			return __Cause.err(v352, instance, (`expected {v351}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v351, p[v352])
		end
	}
	return (setmetatable(v352, __Type))
end

local v352 = "LocalScript"

function GreenTea.LocalScript()
	local v353 = nil
	v353 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v353, instance, (`expected {v352}, got {typeof(instance)}`))
			end

			if instance:IsA(v352) then
				return __Cause.ok()
			end

			return __Cause.err(v353, instance, (`expected {v352}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v352, p[v353])
		end
	}
	return (setmetatable(v353, __Type))
end

local v353 = "ModuleScript"

function GreenTea.ModuleScript()
	local v354 = nil
	v354 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v354, instance, (`expected {v353}, got {typeof(instance)}`))
			end

			if instance:IsA(v353) then
				return __Cause.ok()
			end

			return __Cause.err(v354, instance, (`expected {v353}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v353, p[v354])
		end
	}
	return (setmetatable(v354, __Type))
end

local v354 = "LuaWebService"

function GreenTea.LuaWebService()
	local v355 = nil
	v355 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v355, instance, (`expected {v354}, got {typeof(instance)}`))
			end

			if instance:IsA(v354) then
				return __Cause.ok()
			end

			return __Cause.err(v355, instance, (`expected {v354}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v354, p[v355])
		end
	}
	return (setmetatable(v355, __Type))
end

local v355 = "LuauScriptAnalyzerService"

function GreenTea.LuauScriptAnalyzerService()
	local v356 = nil
	v356 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v356, instance, (`expected {v355}, got {typeof(instance)}`))
			end

			if instance:IsA(v355) then
				return __Cause.ok()
			end

			return __Cause.err(v356, instance, (`expected {v355}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v355, p[v356])
		end
	}
	return (setmetatable(v356, __Type))
end

local v356 = "MarkerCurve"

function GreenTea.MarkerCurve()
	local v357 = nil
	v357 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v357, instance, (`expected {v356}, got {typeof(instance)}`))
			end

			if instance:IsA(v356) then
				return __Cause.ok()
			end

			return __Cause.err(v357, instance, (`expected {v356}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v356, p[v357])
		end
	}
	return (setmetatable(v357, __Type))
end

local v357 = "MarketplaceService"

function GreenTea.MarketplaceService()
	local v358 = nil
	v358 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v358, instance, (`expected {v357}, got {typeof(instance)}`))
			end

			if instance:IsA(v357) then
				return __Cause.ok()
			end

			return __Cause.err(v358, instance, (`expected {v357}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v357, p[v358])
		end
	}
	return (setmetatable(v358, __Type))
end

local v358 = "MaterialGenerationService"

function GreenTea.MaterialGenerationService()
	local v359 = nil
	v359 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v359, instance, (`expected {v358}, got {typeof(instance)}`))
			end

			if instance:IsA(v358) then
				return __Cause.ok()
			end

			return __Cause.err(v359, instance, (`expected {v358}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v358, p[v359])
		end
	}
	return (setmetatable(v359, __Type))
end

local v359 = "MaterialGenerationSession"

function GreenTea.MaterialGenerationSession()
	local v360 = nil
	v360 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v360, instance, (`expected {v359}, got {typeof(instance)}`))
			end

			if instance:IsA(v359) then
				return __Cause.ok()
			end

			return __Cause.err(v360, instance, (`expected {v359}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v359, p[v360])
		end
	}
	return (setmetatable(v360, __Type))
end

local v360 = "MaterialService"

function GreenTea.MaterialService()
	local v361 = nil
	v361 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v361, instance, (`expected {v360}, got {typeof(instance)}`))
			end

			if instance:IsA(v360) then
				return __Cause.ok()
			end

			return __Cause.err(v361, instance, (`expected {v360}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v360, p[v361])
		end
	}
	return (setmetatable(v361, __Type))
end

local v361 = "MaterialVariant"

function GreenTea.MaterialVariant()
	local v362 = nil
	v362 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v362, instance, (`expected {v361}, got {typeof(instance)}`))
			end

			if instance:IsA(v361) then
				return __Cause.ok()
			end

			return __Cause.err(v362, instance, (`expected {v361}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v361, p[v362])
		end
	}
	return (setmetatable(v362, __Type))
end

local v362 = "MemStorageConnection"

function GreenTea.MemStorageConnection()
	local v363 = nil
	v363 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v363, instance, (`expected {v362}, got {typeof(instance)}`))
			end

			if instance:IsA(v362) then
				return __Cause.ok()
			end

			return __Cause.err(v363, instance, (`expected {v362}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v362, p[v363])
		end
	}
	return (setmetatable(v363, __Type))
end

local v363 = "MemStorageService"

function GreenTea.MemStorageService()
	local v364 = nil
	v364 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v364, instance, (`expected {v363}, got {typeof(instance)}`))
			end

			if instance:IsA(v363) then
				return __Cause.ok()
			end

			return __Cause.err(v364, instance, (`expected {v363}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v363, p[v364])
		end
	}
	return (setmetatable(v364, __Type))
end

local v364 = "MemoryStoreHashMap"

function GreenTea.MemoryStoreHashMap()
	local v365 = nil
	v365 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v365, instance, (`expected {v364}, got {typeof(instance)}`))
			end

			if instance:IsA(v364) then
				return __Cause.ok()
			end

			return __Cause.err(v365, instance, (`expected {v364}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v364, p[v365])
		end
	}
	return (setmetatable(v365, __Type))
end

local v365 = "MemoryStoreQueue"

function GreenTea.MemoryStoreQueue()
	local v366 = nil
	v366 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v366, instance, (`expected {v365}, got {typeof(instance)}`))
			end

			if instance:IsA(v365) then
				return __Cause.ok()
			end

			return __Cause.err(v366, instance, (`expected {v365}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v365, p[v366])
		end
	}
	return (setmetatable(v366, __Type))
end

local v366 = "MemoryStoreService"

function GreenTea.MemoryStoreService()
	local v367 = nil
	v367 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v367, instance, (`expected {v366}, got {typeof(instance)}`))
			end

			if instance:IsA(v366) then
				return __Cause.ok()
			end

			return __Cause.err(v367, instance, (`expected {v366}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v366, p[v367])
		end
	}
	return (setmetatable(v367, __Type))
end

local v367 = "MemoryStoreSortedMap"

function GreenTea.MemoryStoreSortedMap()
	local v368 = nil
	v368 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v368, instance, (`expected {v367}, got {typeof(instance)}`))
			end

			if instance:IsA(v367) then
				return __Cause.ok()
			end

			return __Cause.err(v368, instance, (`expected {v367}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v367, p[v368])
		end
	}
	return (setmetatable(v368, __Type))
end

local v368 = "Message"

function GreenTea.Message()
	local v369 = nil
	v369 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v369, instance, (`expected {v368}, got {typeof(instance)}`))
			end

			if instance:IsA(v368) then
				return __Cause.ok()
			end

			return __Cause.err(v369, instance, (`expected {v368}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v368, p[v369])
		end
	}
	return (setmetatable(v369, __Type))
end

local v369 = "Hint"

function GreenTea.Hint()
	local v370 = nil
	v370 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v370, instance, (`expected {v369}, got {typeof(instance)}`))
			end

			if instance:IsA(v369) then
				return __Cause.ok()
			end

			return __Cause.err(v370, instance, (`expected {v369}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v369, p[v370])
		end
	}
	return (setmetatable(v370, __Type))
end

local v370 = "MessageBusConnection"

function GreenTea.MessageBusConnection()
	local v371 = nil
	v371 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v371, instance, (`expected {v370}, got {typeof(instance)}`))
			end

			if instance:IsA(v370) then
				return __Cause.ok()
			end

			return __Cause.err(v371, instance, (`expected {v370}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v370, p[v371])
		end
	}
	return (setmetatable(v371, __Type))
end

local v371 = "MessageBusService"

function GreenTea.MessageBusService()
	local v372 = nil
	v372 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v372, instance, (`expected {v371}, got {typeof(instance)}`))
			end

			if instance:IsA(v371) then
				return __Cause.ok()
			end

			return __Cause.err(v372, instance, (`expected {v371}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v371, p[v372])
		end
	}
	return (setmetatable(v372, __Type))
end

local v372 = "MessagingService"

function GreenTea.MessagingService()
	local v373 = nil
	v373 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v373, instance, (`expected {v372}, got {typeof(instance)}`))
			end

			if instance:IsA(v372) then
				return __Cause.ok()
			end

			return __Cause.err(v373, instance, (`expected {v372}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v372, p[v373])
		end
	}
	return (setmetatable(v373, __Type))
end

local v373 = "MetaBreakpoint"

function GreenTea.MetaBreakpoint()
	local v374 = nil
	v374 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v374, instance, (`expected {v373}, got {typeof(instance)}`))
			end

			if instance:IsA(v373) then
				return __Cause.ok()
			end

			return __Cause.err(v374, instance, (`expected {v373}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v373, p[v374])
		end
	}
	return (setmetatable(v374, __Type))
end

local v374 = "MetaBreakpointContext"

function GreenTea.MetaBreakpointContext()
	local v375 = nil
	v375 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v375, instance, (`expected {v374}, got {typeof(instance)}`))
			end

			if instance:IsA(v374) then
				return __Cause.ok()
			end

			return __Cause.err(v375, instance, (`expected {v374}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v374, p[v375])
		end
	}
	return (setmetatable(v375, __Type))
end

local v375 = "MetaBreakpointManager"

function GreenTea.MetaBreakpointManager()
	local v376 = nil
	v376 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v376, instance, (`expected {v375}, got {typeof(instance)}`))
			end

			if instance:IsA(v375) then
				return __Cause.ok()
			end

			return __Cause.err(v376, instance, (`expected {v375}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v375, p[v376])
		end
	}
	return (setmetatable(v376, __Type))
end

local v376 = "Mouse"

function GreenTea.Mouse()
	local v377 = nil
	v377 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v377, instance, (`expected {v376}, got {typeof(instance)}`))
			end

			if instance:IsA(v376) then
				return __Cause.ok()
			end

			return __Cause.err(v377, instance, (`expected {v376}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v376, p[v377])
		end
	}
	return (setmetatable(v377, __Type))
end

local v377 = "PlayerMouse"

function GreenTea.PlayerMouse()
	local v378 = nil
	v378 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v378, instance, (`expected {v377}, got {typeof(instance)}`))
			end

			if instance:IsA(v377) then
				return __Cause.ok()
			end

			return __Cause.err(v378, instance, (`expected {v377}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v377, p[v378])
		end
	}
	return (setmetatable(v378, __Type))
end

local v378 = "PluginMouse"

function GreenTea.PluginMouse()
	local v379 = nil
	v379 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v379, instance, (`expected {v378}, got {typeof(instance)}`))
			end

			if instance:IsA(v378) then
				return __Cause.ok()
			end

			return __Cause.err(v379, instance, (`expected {v378}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v378, p[v379])
		end
	}
	return (setmetatable(v379, __Type))
end

local v379 = "MouseService"

function GreenTea.MouseService()
	local v380 = nil
	v380 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v380, instance, (`expected {v379}, got {typeof(instance)}`))
			end

			if instance:IsA(v379) then
				return __Cause.ok()
			end

			return __Cause.err(v380, instance, (`expected {v379}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v379, p[v380])
		end
	}
	return (setmetatable(v380, __Type))
end

local v380 = "MultipleDocumentInterfaceInstance"

function GreenTea.MultipleDocumentInterfaceInstance()
	local v381 = nil
	v381 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v381, instance, (`expected {v380}, got {typeof(instance)}`))
			end

			if instance:IsA(v380) then
				return __Cause.ok()
			end

			return __Cause.err(v381, instance, (`expected {v380}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v380, p[v381])
		end
	}
	return (setmetatable(v381, __Type))
end

local v381 = "NetworkMarker"

function GreenTea.NetworkMarker()
	local v382 = nil
	v382 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v382, instance, (`expected {v381}, got {typeof(instance)}`))
			end

			if instance:IsA(v381) then
				return __Cause.ok()
			end

			return __Cause.err(v382, instance, (`expected {v381}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v381, p[v382])
		end
	}
	return (setmetatable(v382, __Type))
end

local v382 = "NetworkPeer"

function GreenTea.NetworkPeer()
	local v383 = nil
	v383 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v383, instance, (`expected {v382}, got {typeof(instance)}`))
			end

			if instance:IsA(v382) then
				return __Cause.ok()
			end

			return __Cause.err(v383, instance, (`expected {v382}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v382, p[v383])
		end
	}
	return (setmetatable(v383, __Type))
end

local v383 = "NetworkClient"

function GreenTea.NetworkClient()
	local v384 = nil
	v384 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v384, instance, (`expected {v383}, got {typeof(instance)}`))
			end

			if instance:IsA(v383) then
				return __Cause.ok()
			end

			return __Cause.err(v384, instance, (`expected {v383}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v383, p[v384])
		end
	}
	return (setmetatable(v384, __Type))
end

local v384 = "NetworkServer"

function GreenTea.NetworkServer()
	local v385 = nil
	v385 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v385, instance, (`expected {v384}, got {typeof(instance)}`))
			end

			if instance:IsA(v384) then
				return __Cause.ok()
			end

			return __Cause.err(v385, instance, (`expected {v384}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v384, p[v385])
		end
	}
	return (setmetatable(v385, __Type))
end

local v385 = "NetworkReplicator"

function GreenTea.NetworkReplicator()
	local v386 = nil
	v386 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v386, instance, (`expected {v385}, got {typeof(instance)}`))
			end

			if instance:IsA(v385) then
				return __Cause.ok()
			end

			return __Cause.err(v386, instance, (`expected {v385}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v385, p[v386])
		end
	}
	return (setmetatable(v386, __Type))
end

local v386 = "ClientReplicator"

function GreenTea.ClientReplicator()
	local v387 = nil
	v387 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v387, instance, (`expected {v386}, got {typeof(instance)}`))
			end

			if instance:IsA(v386) then
				return __Cause.ok()
			end

			return __Cause.err(v387, instance, (`expected {v386}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v386, p[v387])
		end
	}
	return (setmetatable(v387, __Type))
end

local v387 = "ServerReplicator"

function GreenTea.ServerReplicator()
	local v388 = nil
	v388 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v388, instance, (`expected {v387}, got {typeof(instance)}`))
			end

			if instance:IsA(v387) then
				return __Cause.ok()
			end

			return __Cause.err(v388, instance, (`expected {v387}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v387, p[v388])
		end
	}
	return (setmetatable(v388, __Type))
end

local v388 = "NetworkSettings"

function GreenTea.NetworkSettings()
	local v389 = nil
	v389 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v389, instance, (`expected {v388}, got {typeof(instance)}`))
			end

			if instance:IsA(v388) then
				return __Cause.ok()
			end

			return __Cause.err(v389, instance, (`expected {v388}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v388, p[v389])
		end
	}
	return (setmetatable(v389, __Type))
end

local v389 = "NoCollisionConstraint"

function GreenTea.NoCollisionConstraint()
	local v390 = nil
	v390 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v390, instance, (`expected {v389}, got {typeof(instance)}`))
			end

			if instance:IsA(v389) then
				return __Cause.ok()
			end

			return __Cause.err(v390, instance, (`expected {v389}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v389, p[v390])
		end
	}
	return (setmetatable(v390, __Type))
end

local v390 = "NotificationService"

function GreenTea.NotificationService()
	local v391 = nil
	v391 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v391, instance, (`expected {v390}, got {typeof(instance)}`))
			end

			if instance:IsA(v390) then
				return __Cause.ok()
			end

			return __Cause.err(v391, instance, (`expected {v390}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v390, p[v391])
		end
	}
	return (setmetatable(v391, __Type))
end

local v391 = "OmniRecommendationsService"

function GreenTea.OmniRecommendationsService()
	local v392 = nil
	v392 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v392, instance, (`expected {v391}, got {typeof(instance)}`))
			end

			if instance:IsA(v391) then
				return __Cause.ok()
			end

			return __Cause.err(v392, instance, (`expected {v391}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v391, p[v392])
		end
	}
	return (setmetatable(v392, __Type))
end

local v392 = "OpenCloudApiV1"

function GreenTea.OpenCloudApiV1()
	local v393 = nil
	v393 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v393, instance, (`expected {v392}, got {typeof(instance)}`))
			end

			if instance:IsA(v392) then
				return __Cause.ok()
			end

			return __Cause.err(v393, instance, (`expected {v392}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v392, p[v393])
		end
	}
	return (setmetatable(v393, __Type))
end

local v393 = "OpenCloudService"

function GreenTea.OpenCloudService()
	local v394 = nil
	v394 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v394, instance, (`expected {v393}, got {typeof(instance)}`))
			end

			if instance:IsA(v393) then
				return __Cause.ok()
			end

			return __Cause.err(v394, instance, (`expected {v393}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v393, p[v394])
		end
	}
	return (setmetatable(v394, __Type))
end

local v394 = "OperationGraph"

function GreenTea.OperationGraph()
	local v395 = nil
	v395 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v395, instance, (`expected {v394}, got {typeof(instance)}`))
			end

			if instance:IsA(v394) then
				return __Cause.ok()
			end

			return __Cause.err(v395, instance, (`expected {v394}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v394, p[v395])
		end
	}
	return (setmetatable(v395, __Type))
end

local v395 = "PVInstance"

function GreenTea.PVInstance()
	local v396 = nil
	v396 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v396, instance, (`expected {v395}, got {typeof(instance)}`))
			end

			if instance:IsA(v395) then
				return __Cause.ok()
			end

			return __Cause.err(v396, instance, (`expected {v395}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v395, p[v396])
		end
	}
	return (setmetatable(v396, __Type))
end

local v396 = "BasePart"

function GreenTea.BasePart()
	local v397 = nil
	v397 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v397, instance, (`expected {v396}, got {typeof(instance)}`))
			end

			if instance:IsA(v396) then
				return __Cause.ok()
			end

			return __Cause.err(v397, instance, (`expected {v396}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v396, p[v397])
		end
	}
	return (setmetatable(v397, __Type))
end

local v397 = "CornerWedgePart"

function GreenTea.CornerWedgePart()
	local v398 = nil
	v398 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v398, instance, (`expected {v397}, got {typeof(instance)}`))
			end

			if instance:IsA(v397) then
				return __Cause.ok()
			end

			return __Cause.err(v398, instance, (`expected {v397}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v397, p[v398])
		end
	}
	return (setmetatable(v398, __Type))
end

local v398 = "FormFactorPart"

function GreenTea.FormFactorPart()
	local v399 = nil
	v399 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v399, instance, (`expected {v398}, got {typeof(instance)}`))
			end

			if instance:IsA(v398) then
				return __Cause.ok()
			end

			return __Cause.err(v399, instance, (`expected {v398}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v398, p[v399])
		end
	}
	return (setmetatable(v399, __Type))
end

local v399 = "Part"

function GreenTea.Part()
	local v400 = nil
	v400 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v400, instance, (`expected {v399}, got {typeof(instance)}`))
			end

			if instance:IsA(v399) then
				return __Cause.ok()
			end

			return __Cause.err(v400, instance, (`expected {v399}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v399, p[v400])
		end
	}
	return (setmetatable(v400, __Type))
end

local v400 = "FlagStand"

function GreenTea.FlagStand()
	local v401 = nil
	v401 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v401, instance, (`expected {v400}, got {typeof(instance)}`))
			end

			if instance:IsA(v400) then
				return __Cause.ok()
			end

			return __Cause.err(v401, instance, (`expected {v400}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v400, p[v401])
		end
	}
	return (setmetatable(v401, __Type))
end

local v401 = "Platform"

function GreenTea.Platform()
	local v402 = nil
	v402 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v402, instance, (`expected {v401}, got {typeof(instance)}`))
			end

			if instance:IsA(v401) then
				return __Cause.ok()
			end

			return __Cause.err(v402, instance, (`expected {v401}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v401, p[v402])
		end
	}
	return (setmetatable(v402, __Type))
end

local v402 = "Seat"

function GreenTea.Seat()
	local v403 = nil
	v403 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v403, instance, (`expected {v402}, got {typeof(instance)}`))
			end

			if instance:IsA(v402) then
				return __Cause.ok()
			end

			return __Cause.err(v403, instance, (`expected {v402}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v402, p[v403])
		end
	}
	return (setmetatable(v403, __Type))
end

local v403 = "SkateboardPlatform"

function GreenTea.SkateboardPlatform()
	local v404 = nil
	v404 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v404, instance, (`expected {v403}, got {typeof(instance)}`))
			end

			if instance:IsA(v403) then
				return __Cause.ok()
			end

			return __Cause.err(v404, instance, (`expected {v403}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v403, p[v404])
		end
	}
	return (setmetatable(v404, __Type))
end

local v404 = "SpawnLocation"

function GreenTea.SpawnLocation()
	local v405 = nil
	v405 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v405, instance, (`expected {v404}, got {typeof(instance)}`))
			end

			if instance:IsA(v404) then
				return __Cause.ok()
			end

			return __Cause.err(v405, instance, (`expected {v404}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v404, p[v405])
		end
	}
	return (setmetatable(v405, __Type))
end

local v405 = "WedgePart"

function GreenTea.WedgePart()
	local v406 = nil
	v406 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v406, instance, (`expected {v405}, got {typeof(instance)}`))
			end

			if instance:IsA(v405) then
				return __Cause.ok()
			end

			return __Cause.err(v406, instance, (`expected {v405}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v405, p[v406])
		end
	}
	return (setmetatable(v406, __Type))
end

local v406 = "Terrain"

function GreenTea.Terrain()
	local v407 = nil
	v407 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v407, instance, (`expected {v406}, got {typeof(instance)}`))
			end

			if instance:IsA(v406) then
				return __Cause.ok()
			end

			return __Cause.err(v407, instance, (`expected {v406}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v406, p[v407])
		end
	}
	return (setmetatable(v407, __Type))
end

local v407 = "TriangleMeshPart"

function GreenTea.TriangleMeshPart()
	local v408 = nil
	v408 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v408, instance, (`expected {v407}, got {typeof(instance)}`))
			end

			if instance:IsA(v407) then
				return __Cause.ok()
			end

			return __Cause.err(v408, instance, (`expected {v407}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v407, p[v408])
		end
	}
	return (setmetatable(v408, __Type))
end

local v408 = "MeshPart"

function GreenTea.MeshPart()
	local v409 = nil
	v409 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v409, instance, (`expected {v408}, got {typeof(instance)}`))
			end

			if instance:IsA(v408) then
				return __Cause.ok()
			end

			return __Cause.err(v409, instance, (`expected {v408}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v408, p[v409])
		end
	}
	return (setmetatable(v409, __Type))
end

local v409 = "PartOperation"

function GreenTea.PartOperation()
	local v410 = nil
	v410 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v410, instance, (`expected {v409}, got {typeof(instance)}`))
			end

			if instance:IsA(v409) then
				return __Cause.ok()
			end

			return __Cause.err(v410, instance, (`expected {v409}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v409, p[v410])
		end
	}
	return (setmetatable(v410, __Type))
end

local v410 = "IntersectOperation"

function GreenTea.IntersectOperation()
	local v411 = nil
	v411 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v411, instance, (`expected {v410}, got {typeof(instance)}`))
			end

			if instance:IsA(v410) then
				return __Cause.ok()
			end

			return __Cause.err(v411, instance, (`expected {v410}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v410, p[v411])
		end
	}
	return (setmetatable(v411, __Type))
end

local v411 = "NegateOperation"

function GreenTea.NegateOperation()
	local v412 = nil
	v412 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v412, instance, (`expected {v411}, got {typeof(instance)}`))
			end

			if instance:IsA(v411) then
				return __Cause.ok()
			end

			return __Cause.err(v412, instance, (`expected {v411}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v411, p[v412])
		end
	}
	return (setmetatable(v412, __Type))
end

local v412 = "UnionOperation"

function GreenTea.UnionOperation()
	local v413 = nil
	v413 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v413, instance, (`expected {v412}, got {typeof(instance)}`))
			end

			if instance:IsA(v412) then
				return __Cause.ok()
			end

			return __Cause.err(v413, instance, (`expected {v412}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v412, p[v413])
		end
	}
	return (setmetatable(v413, __Type))
end

local v413 = "TrussPart"

function GreenTea.TrussPart()
	local v414 = nil
	v414 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v414, instance, (`expected {v413}, got {typeof(instance)}`))
			end

			if instance:IsA(v413) then
				return __Cause.ok()
			end

			return __Cause.err(v414, instance, (`expected {v413}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v413, p[v414])
		end
	}
	return (setmetatable(v414, __Type))
end

local v414 = "VehicleSeat"

function GreenTea.VehicleSeat()
	local v415 = nil
	v415 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v415, instance, (`expected {v414}, got {typeof(instance)}`))
			end

			if instance:IsA(v414) then
				return __Cause.ok()
			end

			return __Cause.err(v415, instance, (`expected {v414}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v414, p[v415])
		end
	}
	return (setmetatable(v415, __Type))
end

local v415 = "Model"

function GreenTea.Model()
	local v416 = nil
	v416 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v416, instance, (`expected {v415}, got {typeof(instance)}`))
			end

			if instance:IsA(v415) then
				return __Cause.ok()
			end

			return __Cause.err(v416, instance, (`expected {v415}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v415, p[v416])
		end
	}
	return (setmetatable(v416, __Type))
end

local v416 = "Actor"

function GreenTea.Actor()
	local v417 = nil
	v417 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v417, instance, (`expected {v416}, got {typeof(instance)}`))
			end

			if instance:IsA(v416) then
				return __Cause.ok()
			end

			return __Cause.err(v417, instance, (`expected {v416}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v416, p[v417])
		end
	}
	return (setmetatable(v417, __Type))
end

local v417 = "BackpackItem"

function GreenTea.BackpackItem()
	local v418 = nil
	v418 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v418, instance, (`expected {v417}, got {typeof(instance)}`))
			end

			if instance:IsA(v417) then
				return __Cause.ok()
			end

			return __Cause.err(v418, instance, (`expected {v417}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v417, p[v418])
		end
	}
	return (setmetatable(v418, __Type))
end

local v418 = "HopperBin"

function GreenTea.HopperBin()
	local v419 = nil
	v419 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v419, instance, (`expected {v418}, got {typeof(instance)}`))
			end

			if instance:IsA(v418) then
				return __Cause.ok()
			end

			return __Cause.err(v419, instance, (`expected {v418}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v418, p[v419])
		end
	}
	return (setmetatable(v419, __Type))
end

local v419 = "Tool"

function GreenTea.Tool()
	local v420 = nil
	v420 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v420, instance, (`expected {v419}, got {typeof(instance)}`))
			end

			if instance:IsA(v419) then
				return __Cause.ok()
			end

			return __Cause.err(v420, instance, (`expected {v419}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v419, p[v420])
		end
	}
	return (setmetatable(v420, __Type))
end

local v420 = "Flag"

function GreenTea.Flag()
	local v421 = nil
	v421 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v421, instance, (`expected {v420}, got {typeof(instance)}`))
			end

			if instance:IsA(v420) then
				return __Cause.ok()
			end

			return __Cause.err(v421, instance, (`expected {v420}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v420, p[v421])
		end
	}
	return (setmetatable(v421, __Type))
end

local v421 = "Status"

function GreenTea.Status()
	local v422 = nil
	v422 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v422, instance, (`expected {v421}, got {typeof(instance)}`))
			end

			if instance:IsA(v421) then
				return __Cause.ok()
			end

			return __Cause.err(v422, instance, (`expected {v421}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v421, p[v422])
		end
	}
	return (setmetatable(v422, __Type))
end

local v422 = "WorldRoot"

function GreenTea.WorldRoot()
	local v423 = nil
	v423 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v423, instance, (`expected {v422}, got {typeof(instance)}`))
			end

			if instance:IsA(v422) then
				return __Cause.ok()
			end

			return __Cause.err(v423, instance, (`expected {v422}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v422, p[v423])
		end
	}
	return (setmetatable(v423, __Type))
end

local v423 = "Workspace"

function GreenTea.Workspace()
	local v424 = nil
	v424 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v424, instance, (`expected {v423}, got {typeof(instance)}`))
			end

			if instance:IsA(v423) then
				return __Cause.ok()
			end

			return __Cause.err(v424, instance, (`expected {v423}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v423, p[v424])
		end
	}
	return (setmetatable(v424, __Type))
end

local v424 = "WorldModel"

function GreenTea.WorldModel()
	local v425 = nil
	v425 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v425, instance, (`expected {v424}, got {typeof(instance)}`))
			end

			if instance:IsA(v424) then
				return __Cause.ok()
			end

			return __Cause.err(v425, instance, (`expected {v424}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v424, p[v425])
		end
	}
	return (setmetatable(v425, __Type))
end

local v425 = "PackageLink"

function GreenTea.PackageLink()
	local v426 = nil
	v426 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v426, instance, (`expected {v425}, got {typeof(instance)}`))
			end

			if instance:IsA(v425) then
				return __Cause.ok()
			end

			return __Cause.err(v426, instance, (`expected {v425}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v425, p[v426])
		end
	}
	return (setmetatable(v426, __Type))
end

local v426 = "PackageService"

function GreenTea.PackageService()
	local v427 = nil
	v427 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v427, instance, (`expected {v426}, got {typeof(instance)}`))
			end

			if instance:IsA(v426) then
				return __Cause.ok()
			end

			return __Cause.err(v427, instance, (`expected {v426}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v426, p[v427])
		end
	}
	return (setmetatable(v427, __Type))
end

local v427 = "PackageUIService"

function GreenTea.PackageUIService()
	local v428 = nil
	v428 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v428, instance, (`expected {v427}, got {typeof(instance)}`))
			end

			if instance:IsA(v427) then
				return __Cause.ok()
			end

			return __Cause.err(v428, instance, (`expected {v427}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v427, p[v428])
		end
	}
	return (setmetatable(v428, __Type))
end

local v428 = "Pages"

function GreenTea.Pages()
	local v429 = nil
	v429 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v429, instance, (`expected {v428}, got {typeof(instance)}`))
			end

			if instance:IsA(v428) then
				return __Cause.ok()
			end

			return __Cause.err(v429, instance, (`expected {v428}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v428, p[v429])
		end
	}
	return (setmetatable(v429, __Type))
end

local v429 = "AudioPages"

function GreenTea.AudioPages()
	local v430 = nil
	v430 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v430, instance, (`expected {v429}, got {typeof(instance)}`))
			end

			if instance:IsA(v429) then
				return __Cause.ok()
			end

			return __Cause.err(v430, instance, (`expected {v429}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v429, p[v430])
		end
	}
	return (setmetatable(v430, __Type))
end

local v430 = "CatalogPages"

function GreenTea.CatalogPages()
	local v431 = nil
	v431 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v431, instance, (`expected {v430}, got {typeof(instance)}`))
			end

			if instance:IsA(v430) then
				return __Cause.ok()
			end

			return __Cause.err(v431, instance, (`expected {v430}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v430, p[v431])
		end
	}
	return (setmetatable(v431, __Type))
end

local v431 = "DataStoreKeyPages"

function GreenTea.DataStoreKeyPages()
	local v432 = nil
	v432 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v432, instance, (`expected {v431}, got {typeof(instance)}`))
			end

			if instance:IsA(v431) then
				return __Cause.ok()
			end

			return __Cause.err(v432, instance, (`expected {v431}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v431, p[v432])
		end
	}
	return (setmetatable(v432, __Type))
end

local v432 = "DataStoreListingPages"

function GreenTea.DataStoreListingPages()
	local v433 = nil
	v433 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v433, instance, (`expected {v432}, got {typeof(instance)}`))
			end

			if instance:IsA(v432) then
				return __Cause.ok()
			end

			return __Cause.err(v433, instance, (`expected {v432}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v432, p[v433])
		end
	}
	return (setmetatable(v433, __Type))
end

local v433 = "DataStorePages"

function GreenTea.DataStorePages()
	local v434 = nil
	v434 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v434, instance, (`expected {v433}, got {typeof(instance)}`))
			end

			if instance:IsA(v433) then
				return __Cause.ok()
			end

			return __Cause.err(v434, instance, (`expected {v433}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v433, p[v434])
		end
	}
	return (setmetatable(v434, __Type))
end

local v434 = "DataStoreVersionPages"

function GreenTea.DataStoreVersionPages()
	local v435 = nil
	v435 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v435, instance, (`expected {v434}, got {typeof(instance)}`))
			end

			if instance:IsA(v434) then
				return __Cause.ok()
			end

			return __Cause.err(v435, instance, (`expected {v434}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v434, p[v435])
		end
	}
	return (setmetatable(v435, __Type))
end

local v435 = "FriendPages"

function GreenTea.FriendPages()
	local v436 = nil
	v436 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v436, instance, (`expected {v435}, got {typeof(instance)}`))
			end

			if instance:IsA(v435) then
				return __Cause.ok()
			end

			return __Cause.err(v436, instance, (`expected {v435}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v435, p[v436])
		end
	}
	return (setmetatable(v436, __Type))
end

local v436 = "InventoryPages"

function GreenTea.InventoryPages()
	local v437 = nil
	v437 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v437, instance, (`expected {v436}, got {typeof(instance)}`))
			end

			if instance:IsA(v436) then
				return __Cause.ok()
			end

			return __Cause.err(v437, instance, (`expected {v436}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v436, p[v437])
		end
	}
	return (setmetatable(v437, __Type))
end

local v437 = "EmotesPages"

function GreenTea.EmotesPages()
	local v438 = nil
	v438 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v438, instance, (`expected {v437}, got {typeof(instance)}`))
			end

			if instance:IsA(v437) then
				return __Cause.ok()
			end

			return __Cause.err(v438, instance, (`expected {v437}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v437, p[v438])
		end
	}
	return (setmetatable(v438, __Type))
end

local v438 = "MemoryStoreHashMapPages"

function GreenTea.MemoryStoreHashMapPages()
	local v439 = nil
	v439 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v439, instance, (`expected {v438}, got {typeof(instance)}`))
			end

			if instance:IsA(v438) then
				return __Cause.ok()
			end

			return __Cause.err(v439, instance, (`expected {v438}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v438, p[v439])
		end
	}
	return (setmetatable(v439, __Type))
end

local v439 = "OutfitPages"

function GreenTea.OutfitPages()
	local v440 = nil
	v440 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v440, instance, (`expected {v439}, got {typeof(instance)}`))
			end

			if instance:IsA(v439) then
				return __Cause.ok()
			end

			return __Cause.err(v440, instance, (`expected {v439}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v439, p[v440])
		end
	}
	return (setmetatable(v440, __Type))
end

local v440 = "StandardPages"

function GreenTea.StandardPages()
	local v441 = nil
	v441 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v441, instance, (`expected {v440}, got {typeof(instance)}`))
			end

			if instance:IsA(v440) then
				return __Cause.ok()
			end

			return __Cause.err(v441, instance, (`expected {v440}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v440, p[v441])
		end
	}
	return (setmetatable(v441, __Type))
end

local v441 = "PartOperationAsset"

function GreenTea.PartOperationAsset()
	local v442 = nil
	v442 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v442, instance, (`expected {v441}, got {typeof(instance)}`))
			end

			if instance:IsA(v441) then
				return __Cause.ok()
			end

			return __Cause.err(v442, instance, (`expected {v441}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v441, p[v442])
		end
	}
	return (setmetatable(v442, __Type))
end

local v442 = "ParticleEmitter"

function GreenTea.ParticleEmitter()
	local v443 = nil
	v443 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v443, instance, (`expected {v442}, got {typeof(instance)}`))
			end

			if instance:IsA(v442) then
				return __Cause.ok()
			end

			return __Cause.err(v443, instance, (`expected {v442}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v442, p[v443])
		end
	}
	return (setmetatable(v443, __Type))
end

local v443 = "PatchBundlerFileWatch"

function GreenTea.PatchBundlerFileWatch()
	local v444 = nil
	v444 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v444, instance, (`expected {v443}, got {typeof(instance)}`))
			end

			if instance:IsA(v443) then
				return __Cause.ok()
			end

			return __Cause.err(v444, instance, (`expected {v443}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v443, p[v444])
		end
	}
	return (setmetatable(v444, __Type))
end

local v444 = "PatchMapping"

function GreenTea.PatchMapping()
	local v445 = nil
	v445 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v445, instance, (`expected {v444}, got {typeof(instance)}`))
			end

			if instance:IsA(v444) then
				return __Cause.ok()
			end

			return __Cause.err(v445, instance, (`expected {v444}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v444, p[v445])
		end
	}
	return (setmetatable(v445, __Type))
end

local v445 = "Path"

function GreenTea.Path()
	local v446 = nil
	v446 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v446, instance, (`expected {v445}, got {typeof(instance)}`))
			end

			if instance:IsA(v445) then
				return __Cause.ok()
			end

			return __Cause.err(v446, instance, (`expected {v445}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v445, p[v446])
		end
	}
	return (setmetatable(v446, __Type))
end

local v446 = "PathfindingLink"

function GreenTea.PathfindingLink()
	local v447 = nil
	v447 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v447, instance, (`expected {v446}, got {typeof(instance)}`))
			end

			if instance:IsA(v446) then
				return __Cause.ok()
			end

			return __Cause.err(v447, instance, (`expected {v446}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v446, p[v447])
		end
	}
	return (setmetatable(v447, __Type))
end

local v447 = "PathfindingModifier"

function GreenTea.PathfindingModifier()
	local v448 = nil
	v448 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v448, instance, (`expected {v447}, got {typeof(instance)}`))
			end

			if instance:IsA(v447) then
				return __Cause.ok()
			end

			return __Cause.err(v448, instance, (`expected {v447}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v447, p[v448])
		end
	}
	return (setmetatable(v448, __Type))
end

local v448 = "PathfindingService"

function GreenTea.PathfindingService()
	local v449 = nil
	v449 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v449, instance, (`expected {v448}, got {typeof(instance)}`))
			end

			if instance:IsA(v448) then
				return __Cause.ok()
			end

			return __Cause.err(v449, instance, (`expected {v448}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v448, p[v449])
		end
	}
	return (setmetatable(v449, __Type))
end

local v449 = "PausedState"

function GreenTea.PausedState()
	local v450 = nil
	v450 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v450, instance, (`expected {v449}, got {typeof(instance)}`))
			end

			if instance:IsA(v449) then
				return __Cause.ok()
			end

			return __Cause.err(v450, instance, (`expected {v449}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v449, p[v450])
		end
	}
	return (setmetatable(v450, __Type))
end

local v450 = "PausedStateBreakpoint"

function GreenTea.PausedStateBreakpoint()
	local v451 = nil
	v451 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v451, instance, (`expected {v450}, got {typeof(instance)}`))
			end

			if instance:IsA(v450) then
				return __Cause.ok()
			end

			return __Cause.err(v451, instance, (`expected {v450}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v450, p[v451])
		end
	}
	return (setmetatable(v451, __Type))
end

local v451 = "PausedStateException"

function GreenTea.PausedStateException()
	local v452 = nil
	v452 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v452, instance, (`expected {v451}, got {typeof(instance)}`))
			end

			if instance:IsA(v451) then
				return __Cause.ok()
			end

			return __Cause.err(v452, instance, (`expected {v451}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v451, p[v452])
		end
	}
	return (setmetatable(v452, __Type))
end

local v452 = "PermissionsService"

function GreenTea.PermissionsService()
	local v453 = nil
	v453 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v453, instance, (`expected {v452}, got {typeof(instance)}`))
			end

			if instance:IsA(v452) then
				return __Cause.ok()
			end

			return __Cause.err(v453, instance, (`expected {v452}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v452, p[v453])
		end
	}
	return (setmetatable(v453, __Type))
end

local v453 = "PhysicsService"

function GreenTea.PhysicsService()
	local v454 = nil
	v454 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v454, instance, (`expected {v453}, got {typeof(instance)}`))
			end

			if instance:IsA(v453) then
				return __Cause.ok()
			end

			return __Cause.err(v454, instance, (`expected {v453}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v453, p[v454])
		end
	}
	return (setmetatable(v454, __Type))
end

local v454 = "PhysicsSettings"

function GreenTea.PhysicsSettings()
	local v455 = nil
	v455 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v455, instance, (`expected {v454}, got {typeof(instance)}`))
			end

			if instance:IsA(v454) then
				return __Cause.ok()
			end

			return __Cause.err(v455, instance, (`expected {v454}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v454, p[v455])
		end
	}
	return (setmetatable(v455, __Type))
end

local v455 = "PlaceStatsService"

function GreenTea.PlaceStatsService()
	local v456 = nil
	v456 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v456, instance, (`expected {v455}, got {typeof(instance)}`))
			end

			if instance:IsA(v455) then
				return __Cause.ok()
			end

			return __Cause.err(v456, instance, (`expected {v455}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v455, p[v456])
		end
	}
	return (setmetatable(v456, __Type))
end

local v456 = "PlacesService"

function GreenTea.PlacesService()
	local v457 = nil
	v457 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v457, instance, (`expected {v456}, got {typeof(instance)}`))
			end

			if instance:IsA(v456) then
				return __Cause.ok()
			end

			return __Cause.err(v457, instance, (`expected {v456}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v456, p[v457])
		end
	}
	return (setmetatable(v457, __Type))
end

local v457 = "PlatformCloudStorageService"

function GreenTea.PlatformCloudStorageService()
	local v458 = nil
	v458 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v458, instance, (`expected {v457}, got {typeof(instance)}`))
			end

			if instance:IsA(v457) then
				return __Cause.ok()
			end

			return __Cause.err(v458, instance, (`expected {v457}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v457, p[v458])
		end
	}
	return (setmetatable(v458, __Type))
end

local v458 = "PlatformFriendsService"

function GreenTea.PlatformFriendsService()
	local v459 = nil
	v459 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v459, instance, (`expected {v458}, got {typeof(instance)}`))
			end

			if instance:IsA(v458) then
				return __Cause.ok()
			end

			return __Cause.err(v459, instance, (`expected {v458}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v458, p[v459])
		end
	}
	return (setmetatable(v459, __Type))
end

local v459 = "Player"

function GreenTea.Player()
	local v460 = nil
	v460 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v460, instance, (`expected {v459}, got {typeof(instance)}`))
			end

			if instance:IsA(v459) then
				return __Cause.ok()
			end

			return __Cause.err(v460, instance, (`expected {v459}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v459, p[v460])
		end
	}
	return (setmetatable(v460, __Type))
end

local v460 = "PlayerEmulatorService"

function GreenTea.PlayerEmulatorService()
	local v461 = nil
	v461 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v461, instance, (`expected {v460}, got {typeof(instance)}`))
			end

			if instance:IsA(v460) then
				return __Cause.ok()
			end

			return __Cause.err(v461, instance, (`expected {v460}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v460, p[v461])
		end
	}
	return (setmetatable(v461, __Type))
end

local v461 = "PlayerScripts"

function GreenTea.PlayerScripts()
	local v462 = nil
	v462 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v462, instance, (`expected {v461}, got {typeof(instance)}`))
			end

			if instance:IsA(v461) then
				return __Cause.ok()
			end

			return __Cause.err(v462, instance, (`expected {v461}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v461, p[v462])
		end
	}
	return (setmetatable(v462, __Type))
end

local v462 = "PlayerViewService"

function GreenTea.PlayerViewService()
	local v463 = nil
	v463 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v463, instance, (`expected {v462}, got {typeof(instance)}`))
			end

			if instance:IsA(v462) then
				return __Cause.ok()
			end

			return __Cause.err(v463, instance, (`expected {v462}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v462, p[v463])
		end
	}
	return (setmetatable(v463, __Type))
end

local v463 = "Players"

function GreenTea.Players()
	local v464 = nil
	v464 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v464, instance, (`expected {v463}, got {typeof(instance)}`))
			end

			if instance:IsA(v463) then
				return __Cause.ok()
			end

			return __Cause.err(v464, instance, (`expected {v463}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v463, p[v464])
		end
	}
	return (setmetatable(v464, __Type))
end

local v464 = "Plugin"

function GreenTea.Plugin()
	local v465 = nil
	v465 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v465, instance, (`expected {v464}, got {typeof(instance)}`))
			end

			if instance:IsA(v464) then
				return __Cause.ok()
			end

			return __Cause.err(v465, instance, (`expected {v464}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v464, p[v465])
		end
	}
	return (setmetatable(v465, __Type))
end

local v465 = "PluginAction"

function GreenTea.PluginAction()
	local v466 = nil
	v466 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v466, instance, (`expected {v465}, got {typeof(instance)}`))
			end

			if instance:IsA(v465) then
				return __Cause.ok()
			end

			return __Cause.err(v466, instance, (`expected {v465}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v465, p[v466])
		end
	}
	return (setmetatable(v466, __Type))
end

local v466 = "PluginCapabilities"

function GreenTea.PluginCapabilities()
	local v467 = nil
	v467 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v467, instance, (`expected {v466}, got {typeof(instance)}`))
			end

			if instance:IsA(v466) then
				return __Cause.ok()
			end

			return __Cause.err(v467, instance, (`expected {v466}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v466, p[v467])
		end
	}
	return (setmetatable(v467, __Type))
end

local v467 = "PluginDebugService"

function GreenTea.PluginDebugService()
	local v468 = nil
	v468 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v468, instance, (`expected {v467}, got {typeof(instance)}`))
			end

			if instance:IsA(v467) then
				return __Cause.ok()
			end

			return __Cause.err(v468, instance, (`expected {v467}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v467, p[v468])
		end
	}
	return (setmetatable(v468, __Type))
end

local v468 = "PluginDragEvent"

function GreenTea.PluginDragEvent()
	local v469 = nil
	v469 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v469, instance, (`expected {v468}, got {typeof(instance)}`))
			end

			if instance:IsA(v468) then
				return __Cause.ok()
			end

			return __Cause.err(v469, instance, (`expected {v468}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v468, p[v469])
		end
	}
	return (setmetatable(v469, __Type))
end

local v469 = "PluginGuiService"

function GreenTea.PluginGuiService()
	local v470 = nil
	v470 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v470, instance, (`expected {v469}, got {typeof(instance)}`))
			end

			if instance:IsA(v469) then
				return __Cause.ok()
			end

			return __Cause.err(v470, instance, (`expected {v469}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v469, p[v470])
		end
	}
	return (setmetatable(v470, __Type))
end

local v470 = "PluginManagementService"

function GreenTea.PluginManagementService()
	local v471 = nil
	v471 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v471, instance, (`expected {v470}, got {typeof(instance)}`))
			end

			if instance:IsA(v470) then
				return __Cause.ok()
			end

			return __Cause.err(v471, instance, (`expected {v470}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v470, p[v471])
		end
	}
	return (setmetatable(v471, __Type))
end

local v471 = "PluginManager"

function GreenTea.PluginManager()
	local v472 = nil
	v472 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v472, instance, (`expected {v471}, got {typeof(instance)}`))
			end

			if instance:IsA(v471) then
				return __Cause.ok()
			end

			return __Cause.err(v472, instance, (`expected {v471}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v471, p[v472])
		end
	}
	return (setmetatable(v472, __Type))
end

local v472 = "PluginManagerInterface"

function GreenTea.PluginManagerInterface()
	local v473 = nil
	v473 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v473, instance, (`expected {v472}, got {typeof(instance)}`))
			end

			if instance:IsA(v472) then
				return __Cause.ok()
			end

			return __Cause.err(v473, instance, (`expected {v472}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v472, p[v473])
		end
	}
	return (setmetatable(v473, __Type))
end

local v473 = "PluginMenu"

function GreenTea.PluginMenu()
	local v474 = nil
	v474 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v474, instance, (`expected {v473}, got {typeof(instance)}`))
			end

			if instance:IsA(v473) then
				return __Cause.ok()
			end

			return __Cause.err(v474, instance, (`expected {v473}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v473, p[v474])
		end
	}
	return (setmetatable(v474, __Type))
end

local v474 = "PluginPolicyService"

function GreenTea.PluginPolicyService()
	local v475 = nil
	v475 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v475, instance, (`expected {v474}, got {typeof(instance)}`))
			end

			if instance:IsA(v474) then
				return __Cause.ok()
			end

			return __Cause.err(v475, instance, (`expected {v474}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v474, p[v475])
		end
	}
	return (setmetatable(v475, __Type))
end

local v475 = "PluginToolbar"

function GreenTea.PluginToolbar()
	local v476 = nil
	v476 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v476, instance, (`expected {v475}, got {typeof(instance)}`))
			end

			if instance:IsA(v475) then
				return __Cause.ok()
			end

			return __Cause.err(v476, instance, (`expected {v475}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v475, p[v476])
		end
	}
	return (setmetatable(v476, __Type))
end

local v476 = "PluginToolbarButton"

function GreenTea.PluginToolbarButton()
	local v477 = nil
	v477 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v477, instance, (`expected {v476}, got {typeof(instance)}`))
			end

			if instance:IsA(v476) then
				return __Cause.ok()
			end

			return __Cause.err(v477, instance, (`expected {v476}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v476, p[v477])
		end
	}
	return (setmetatable(v477, __Type))
end

local v477 = "PointsService"

function GreenTea.PointsService()
	local v478 = nil
	v478 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v478, instance, (`expected {v477}, got {typeof(instance)}`))
			end

			if instance:IsA(v477) then
				return __Cause.ok()
			end

			return __Cause.err(v478, instance, (`expected {v477}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v477, p[v478])
		end
	}
	return (setmetatable(v478, __Type))
end

local v478 = "PolicyService"

function GreenTea.PolicyService()
	local v479 = nil
	v479 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v479, instance, (`expected {v478}, got {typeof(instance)}`))
			end

			if instance:IsA(v478) then
				return __Cause.ok()
			end

			return __Cause.err(v479, instance, (`expected {v478}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v478, p[v479])
		end
	}
	return (setmetatable(v479, __Type))
end

local v479 = "PoseBase"

function GreenTea.PoseBase()
	local v480 = nil
	v480 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v480, instance, (`expected {v479}, got {typeof(instance)}`))
			end

			if instance:IsA(v479) then
				return __Cause.ok()
			end

			return __Cause.err(v480, instance, (`expected {v479}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v479, p[v480])
		end
	}
	return (setmetatable(v480, __Type))
end

local v480 = "NumberPose"

function GreenTea.NumberPose()
	local v481 = nil
	v481 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v481, instance, (`expected {v480}, got {typeof(instance)}`))
			end

			if instance:IsA(v480) then
				return __Cause.ok()
			end

			return __Cause.err(v481, instance, (`expected {v480}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v480, p[v481])
		end
	}
	return (setmetatable(v481, __Type))
end

local v481 = "Pose"

function GreenTea.Pose()
	local v482 = nil
	v482 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v482, instance, (`expected {v481}, got {typeof(instance)}`))
			end

			if instance:IsA(v481) then
				return __Cause.ok()
			end

			return __Cause.err(v482, instance, (`expected {v481}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v481, p[v482])
		end
	}
	return (setmetatable(v482, __Type))
end

local v482 = "PostEffect"

function GreenTea.PostEffect()
	local v483 = nil
	v483 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v483, instance, (`expected {v482}, got {typeof(instance)}`))
			end

			if instance:IsA(v482) then
				return __Cause.ok()
			end

			return __Cause.err(v483, instance, (`expected {v482}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v482, p[v483])
		end
	}
	return (setmetatable(v483, __Type))
end

local v483 = "BloomEffect"

function GreenTea.BloomEffect()
	local v484 = nil
	v484 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v484, instance, (`expected {v483}, got {typeof(instance)}`))
			end

			if instance:IsA(v483) then
				return __Cause.ok()
			end

			return __Cause.err(v484, instance, (`expected {v483}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v483, p[v484])
		end
	}
	return (setmetatable(v484, __Type))
end

local v484 = "BlurEffect"

function GreenTea.BlurEffect()
	local v485 = nil
	v485 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v485, instance, (`expected {v484}, got {typeof(instance)}`))
			end

			if instance:IsA(v484) then
				return __Cause.ok()
			end

			return __Cause.err(v485, instance, (`expected {v484}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v484, p[v485])
		end
	}
	return (setmetatable(v485, __Type))
end

local v485 = "ColorCorrectionEffect"

function GreenTea.ColorCorrectionEffect()
	local v486 = nil
	v486 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v486, instance, (`expected {v485}, got {typeof(instance)}`))
			end

			if instance:IsA(v485) then
				return __Cause.ok()
			end

			return __Cause.err(v486, instance, (`expected {v485}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v485, p[v486])
		end
	}
	return (setmetatable(v486, __Type))
end

local v486 = "DepthOfFieldEffect"

function GreenTea.DepthOfFieldEffect()
	local v487 = nil
	v487 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v487, instance, (`expected {v486}, got {typeof(instance)}`))
			end

			if instance:IsA(v486) then
				return __Cause.ok()
			end

			return __Cause.err(v487, instance, (`expected {v486}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v486, p[v487])
		end
	}
	return (setmetatable(v487, __Type))
end

local v487 = "SunRaysEffect"

function GreenTea.SunRaysEffect()
	local v488 = nil
	v488 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v488, instance, (`expected {v487}, got {typeof(instance)}`))
			end

			if instance:IsA(v487) then
				return __Cause.ok()
			end

			return __Cause.err(v488, instance, (`expected {v487}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v487, p[v488])
		end
	}
	return (setmetatable(v488, __Type))
end

local v488 = "ProcessInstancePhysicsService"

function GreenTea.ProcessInstancePhysicsService()
	local v489 = nil
	v489 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v489, instance, (`expected {v488}, got {typeof(instance)}`))
			end

			if instance:IsA(v488) then
				return __Cause.ok()
			end

			return __Cause.err(v489, instance, (`expected {v488}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v488, p[v489])
		end
	}
	return (setmetatable(v489, __Type))
end

local v489 = "ProximityPrompt"

function GreenTea.ProximityPrompt()
	local v490 = nil
	v490 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v490, instance, (`expected {v489}, got {typeof(instance)}`))
			end

			if instance:IsA(v489) then
				return __Cause.ok()
			end

			return __Cause.err(v490, instance, (`expected {v489}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v489, p[v490])
		end
	}
	return (setmetatable(v490, __Type))
end

local v490 = "ProximityPromptService"

function GreenTea.ProximityPromptService()
	local v491 = nil
	v491 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v491, instance, (`expected {v490}, got {typeof(instance)}`))
			end

			if instance:IsA(v490) then
				return __Cause.ok()
			end

			return __Cause.err(v491, instance, (`expected {v490}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v490, p[v491])
		end
	}
	return (setmetatable(v491, __Type))
end

local v491 = "PublishService"

function GreenTea.PublishService()
	local v492 = nil
	v492 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v492, instance, (`expected {v491}, got {typeof(instance)}`))
			end

			if instance:IsA(v491) then
				return __Cause.ok()
			end

			return __Cause.err(v492, instance, (`expected {v491}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v491, p[v492])
		end
	}
	return (setmetatable(v492, __Type))
end

local v492 = "RbxAnalyticsService"

function GreenTea.RbxAnalyticsService()
	local v493 = nil
	v493 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v493, instance, (`expected {v492}, got {typeof(instance)}`))
			end

			if instance:IsA(v492) then
				return __Cause.ok()
			end

			return __Cause.err(v493, instance, (`expected {v492}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v492, p[v493])
		end
	}
	return (setmetatable(v493, __Type))
end

local v493 = "ReflectionMetadata"

function GreenTea.ReflectionMetadata()
	local v494 = nil
	v494 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v494, instance, (`expected {v493}, got {typeof(instance)}`))
			end

			if instance:IsA(v493) then
				return __Cause.ok()
			end

			return __Cause.err(v494, instance, (`expected {v493}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v493, p[v494])
		end
	}
	return (setmetatable(v494, __Type))
end

local v494 = "ReflectionMetadataCallbacks"

function GreenTea.ReflectionMetadataCallbacks()
	local v495 = nil
	v495 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v495, instance, (`expected {v494}, got {typeof(instance)}`))
			end

			if instance:IsA(v494) then
				return __Cause.ok()
			end

			return __Cause.err(v495, instance, (`expected {v494}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v494, p[v495])
		end
	}
	return (setmetatable(v495, __Type))
end

local v495 = "ReflectionMetadataClasses"

function GreenTea.ReflectionMetadataClasses()
	local v496 = nil
	v496 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v496, instance, (`expected {v495}, got {typeof(instance)}`))
			end

			if instance:IsA(v495) then
				return __Cause.ok()
			end

			return __Cause.err(v496, instance, (`expected {v495}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v495, p[v496])
		end
	}
	return (setmetatable(v496, __Type))
end

local v496 = "ReflectionMetadataEnums"

function GreenTea.ReflectionMetadataEnums()
	local v497 = nil
	v497 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v497, instance, (`expected {v496}, got {typeof(instance)}`))
			end

			if instance:IsA(v496) then
				return __Cause.ok()
			end

			return __Cause.err(v497, instance, (`expected {v496}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v496, p[v497])
		end
	}
	return (setmetatable(v497, __Type))
end

local v497 = "ReflectionMetadataEvents"

function GreenTea.ReflectionMetadataEvents()
	local v498 = nil
	v498 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v498, instance, (`expected {v497}, got {typeof(instance)}`))
			end

			if instance:IsA(v497) then
				return __Cause.ok()
			end

			return __Cause.err(v498, instance, (`expected {v497}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v497, p[v498])
		end
	}
	return (setmetatable(v498, __Type))
end

local v498 = "ReflectionMetadataFunctions"

function GreenTea.ReflectionMetadataFunctions()
	local v499 = nil
	v499 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v499, instance, (`expected {v498}, got {typeof(instance)}`))
			end

			if instance:IsA(v498) then
				return __Cause.ok()
			end

			return __Cause.err(v499, instance, (`expected {v498}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v498, p[v499])
		end
	}
	return (setmetatable(v499, __Type))
end

local v499 = "ReflectionMetadataItem"

function GreenTea.ReflectionMetadataItem()
	local v500 = nil
	v500 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v500, instance, (`expected {v499}, got {typeof(instance)}`))
			end

			if instance:IsA(v499) then
				return __Cause.ok()
			end

			return __Cause.err(v500, instance, (`expected {v499}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v499, p[v500])
		end
	}
	return (setmetatable(v500, __Type))
end

local v500 = "ReflectionMetadataClass"

function GreenTea.ReflectionMetadataClass()
	local v501 = nil
	v501 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v501, instance, (`expected {v500}, got {typeof(instance)}`))
			end

			if instance:IsA(v500) then
				return __Cause.ok()
			end

			return __Cause.err(v501, instance, (`expected {v500}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v500, p[v501])
		end
	}
	return (setmetatable(v501, __Type))
end

local v501 = "ReflectionMetadataEnum"

function GreenTea.ReflectionMetadataEnum()
	local v502 = nil
	v502 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v502, instance, (`expected {v501}, got {typeof(instance)}`))
			end

			if instance:IsA(v501) then
				return __Cause.ok()
			end

			return __Cause.err(v502, instance, (`expected {v501}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v501, p[v502])
		end
	}
	return (setmetatable(v502, __Type))
end

local v502 = "ReflectionMetadataEnumItem"

function GreenTea.ReflectionMetadataEnumItem()
	local v503 = nil
	v503 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v503, instance, (`expected {v502}, got {typeof(instance)}`))
			end

			if instance:IsA(v502) then
				return __Cause.ok()
			end

			return __Cause.err(v503, instance, (`expected {v502}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v502, p[v503])
		end
	}
	return (setmetatable(v503, __Type))
end

local v503 = "ReflectionMetadataMember"

function GreenTea.ReflectionMetadataMember()
	local v504 = nil
	v504 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v504, instance, (`expected {v503}, got {typeof(instance)}`))
			end

			if instance:IsA(v503) then
				return __Cause.ok()
			end

			return __Cause.err(v504, instance, (`expected {v503}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v503, p[v504])
		end
	}
	return (setmetatable(v504, __Type))
end

local v504 = "ReflectionMetadataProperties"

function GreenTea.ReflectionMetadataProperties()
	local v505 = nil
	v505 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v505, instance, (`expected {v504}, got {typeof(instance)}`))
			end

			if instance:IsA(v504) then
				return __Cause.ok()
			end

			return __Cause.err(v505, instance, (`expected {v504}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v504, p[v505])
		end
	}
	return (setmetatable(v505, __Type))
end

local v505 = "ReflectionMetadataYieldFunctions"

function GreenTea.ReflectionMetadataYieldFunctions()
	local v506 = nil
	v506 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v506, instance, (`expected {v505}, got {typeof(instance)}`))
			end

			if instance:IsA(v505) then
				return __Cause.ok()
			end

			return __Cause.err(v506, instance, (`expected {v505}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v505, p[v506])
		end
	}
	return (setmetatable(v506, __Type))
end

local v506 = "ReflectionService"

function GreenTea.ReflectionService()
	local v507 = nil
	v507 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v507, instance, (`expected {v506}, got {typeof(instance)}`))
			end

			if instance:IsA(v506) then
				return __Cause.ok()
			end

			return __Cause.err(v507, instance, (`expected {v506}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v506, p[v507])
		end
	}
	return (setmetatable(v507, __Type))
end

local v507 = "RemoteCursorService"

function GreenTea.RemoteCursorService()
	local v508 = nil
	v508 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v508, instance, (`expected {v507}, got {typeof(instance)}`))
			end

			if instance:IsA(v507) then
				return __Cause.ok()
			end

			return __Cause.err(v508, instance, (`expected {v507}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v507, p[v508])
		end
	}
	return (setmetatable(v508, __Type))
end

local v508 = "RemoteDebuggerServer"

function GreenTea.RemoteDebuggerServer()
	local v509 = nil
	v509 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v509, instance, (`expected {v508}, got {typeof(instance)}`))
			end

			if instance:IsA(v508) then
				return __Cause.ok()
			end

			return __Cause.err(v509, instance, (`expected {v508}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v508, p[v509])
		end
	}
	return (setmetatable(v509, __Type))
end

local v509 = "RemoteFunction"

function GreenTea.RemoteFunction()
	local v510 = nil
	v510 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v510, instance, (`expected {v509}, got {typeof(instance)}`))
			end

			if instance:IsA(v509) then
				return __Cause.ok()
			end

			return __Cause.err(v510, instance, (`expected {v509}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v509, p[v510])
		end
	}
	return (setmetatable(v510, __Type))
end

local v510 = "RenderSettings"

function GreenTea.RenderSettings()
	local v511 = nil
	v511 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v511, instance, (`expected {v510}, got {typeof(instance)}`))
			end

			if instance:IsA(v510) then
				return __Cause.ok()
			end

			return __Cause.err(v511, instance, (`expected {v510}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v510, p[v511])
		end
	}
	return (setmetatable(v511, __Type))
end

local v511 = "RenderingTest"

function GreenTea.RenderingTest()
	local v512 = nil
	v512 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v512, instance, (`expected {v511}, got {typeof(instance)}`))
			end

			if instance:IsA(v511) then
				return __Cause.ok()
			end

			return __Cause.err(v512, instance, (`expected {v511}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v511, p[v512])
		end
	}
	return (setmetatable(v512, __Type))
end

local v512 = "ReplicatedFirst"

function GreenTea.ReplicatedFirst()
	local v513 = nil
	v513 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v513, instance, (`expected {v512}, got {typeof(instance)}`))
			end

			if instance:IsA(v512) then
				return __Cause.ok()
			end

			return __Cause.err(v513, instance, (`expected {v512}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v512, p[v513])
		end
	}
	return (setmetatable(v513, __Type))
end

local v513 = "ReplicatedStorage"

function GreenTea.ReplicatedStorage()
	local v514 = nil
	v514 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v514, instance, (`expected {v513}, got {typeof(instance)}`))
			end

			if instance:IsA(v513) then
				return __Cause.ok()
			end

			return __Cause.err(v514, instance, (`expected {v513}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v513, p[v514])
		end
	}
	return (setmetatable(v514, __Type))
end

local v514 = "RibbonNotificationService"

function GreenTea.RibbonNotificationService()
	local v515 = nil
	v515 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v515, instance, (`expected {v514}, got {typeof(instance)}`))
			end

			if instance:IsA(v514) then
				return __Cause.ok()
			end

			return __Cause.err(v515, instance, (`expected {v514}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v514, p[v515])
		end
	}
	return (setmetatable(v515, __Type))
end

local v515 = "RobloxPluginGuiService"

function GreenTea.RobloxPluginGuiService()
	local v516 = nil
	v516 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v516, instance, (`expected {v515}, got {typeof(instance)}`))
			end

			if instance:IsA(v515) then
				return __Cause.ok()
			end

			return __Cause.err(v516, instance, (`expected {v515}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v515, p[v516])
		end
	}
	return (setmetatable(v516, __Type))
end

local v516 = "RobloxReplicatedStorage"

function GreenTea.RobloxReplicatedStorage()
	local v517 = nil
	v517 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v517, instance, (`expected {v516}, got {typeof(instance)}`))
			end

			if instance:IsA(v516) then
				return __Cause.ok()
			end

			return __Cause.err(v517, instance, (`expected {v516}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v516, p[v517])
		end
	}
	return (setmetatable(v517, __Type))
end

local v517 = "RobloxServerStorage"

function GreenTea.RobloxServerStorage()
	local v518 = nil
	v518 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v518, instance, (`expected {v517}, got {typeof(instance)}`))
			end

			if instance:IsA(v517) then
				return __Cause.ok()
			end

			return __Cause.err(v518, instance, (`expected {v517}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v517, p[v518])
		end
	}
	return (setmetatable(v518, __Type))
end

local v518 = "RomarkService"

function GreenTea.RomarkService()
	local v519 = nil
	v519 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v519, instance, (`expected {v518}, got {typeof(instance)}`))
			end

			if instance:IsA(v518) then
				return __Cause.ok()
			end

			return __Cause.err(v519, instance, (`expected {v518}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v518, p[v519])
		end
	}
	return (setmetatable(v519, __Type))
end

local v519 = "RotationCurve"

function GreenTea.RotationCurve()
	local v520 = nil
	v520 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v520, instance, (`expected {v519}, got {typeof(instance)}`))
			end

			if instance:IsA(v519) then
				return __Cause.ok()
			end

			return __Cause.err(v520, instance, (`expected {v519}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v519, p[v520])
		end
	}
	return (setmetatable(v520, __Type))
end

local v520 = "RtMessagingService"

function GreenTea.RtMessagingService()
	local v521 = nil
	v521 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v521, instance, (`expected {v520}, got {typeof(instance)}`))
			end

			if instance:IsA(v520) then
				return __Cause.ok()
			end

			return __Cause.err(v521, instance, (`expected {v520}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v520, p[v521])
		end
	}
	return (setmetatable(v521, __Type))
end

local v521 = "RunService"

function GreenTea.RunService()
	local v522 = nil
	v522 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v522, instance, (`expected {v521}, got {typeof(instance)}`))
			end

			if instance:IsA(v521) then
				return __Cause.ok()
			end

			return __Cause.err(v522, instance, (`expected {v521}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v521, p[v522])
		end
	}
	return (setmetatable(v522, __Type))
end

local v522 = "RuntimeScriptService"

function GreenTea.RuntimeScriptService()
	local v523 = nil
	v523 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v523, instance, (`expected {v522}, got {typeof(instance)}`))
			end

			if instance:IsA(v522) then
				return __Cause.ok()
			end

			return __Cause.err(v523, instance, (`expected {v522}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v522, p[v523])
		end
	}
	return (setmetatable(v523, __Type))
end

local v523 = "SafetyService"

function GreenTea.SafetyService()
	local v524 = nil
	v524 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v524, instance, (`expected {v523}, got {typeof(instance)}`))
			end

			if instance:IsA(v523) then
				return __Cause.ok()
			end

			return __Cause.err(v524, instance, (`expected {v523}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v523, p[v524])
		end
	}
	return (setmetatable(v524, __Type))
end

local v524 = "ScreenshotHud"

function GreenTea.ScreenshotHud()
	local v525 = nil
	v525 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v525, instance, (`expected {v524}, got {typeof(instance)}`))
			end

			if instance:IsA(v524) then
				return __Cause.ok()
			end

			return __Cause.err(v525, instance, (`expected {v524}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v524, p[v525])
		end
	}
	return (setmetatable(v525, __Type))
end

local v525 = "ScriptBuilder"

function GreenTea.ScriptBuilder()
	local v526 = nil
	v526 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v526, instance, (`expected {v525}, got {typeof(instance)}`))
			end

			if instance:IsA(v525) then
				return __Cause.ok()
			end

			return __Cause.err(v526, instance, (`expected {v525}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v525, p[v526])
		end
	}
	return (setmetatable(v526, __Type))
end

local v526 = "SyncScriptBuilder"

function GreenTea.SyncScriptBuilder()
	local v527 = nil
	v527 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v527, instance, (`expected {v526}, got {typeof(instance)}`))
			end

			if instance:IsA(v526) then
				return __Cause.ok()
			end

			return __Cause.err(v527, instance, (`expected {v526}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v526, p[v527])
		end
	}
	return (setmetatable(v527, __Type))
end

local v527 = "ScriptChangeService"

function GreenTea.ScriptChangeService()
	local v528 = nil
	v528 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v528, instance, (`expected {v527}, got {typeof(instance)}`))
			end

			if instance:IsA(v527) then
				return __Cause.ok()
			end

			return __Cause.err(v528, instance, (`expected {v527}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v527, p[v528])
		end
	}
	return (setmetatable(v528, __Type))
end

local v528 = "ScriptCloneWatcher"

function GreenTea.ScriptCloneWatcher()
	local v529 = nil
	v529 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v529, instance, (`expected {v528}, got {typeof(instance)}`))
			end

			if instance:IsA(v528) then
				return __Cause.ok()
			end

			return __Cause.err(v529, instance, (`expected {v528}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v528, p[v529])
		end
	}
	return (setmetatable(v529, __Type))
end

local v529 = "ScriptCloneWatcherHelper"

function GreenTea.ScriptCloneWatcherHelper()
	local v530 = nil
	v530 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v530, instance, (`expected {v529}, got {typeof(instance)}`))
			end

			if instance:IsA(v529) then
				return __Cause.ok()
			end

			return __Cause.err(v530, instance, (`expected {v529}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v529, p[v530])
		end
	}
	return (setmetatable(v530, __Type))
end

local v530 = "ScriptCommitService"

function GreenTea.ScriptCommitService()
	local v531 = nil
	v531 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v531, instance, (`expected {v530}, got {typeof(instance)}`))
			end

			if instance:IsA(v530) then
				return __Cause.ok()
			end

			return __Cause.err(v531, instance, (`expected {v530}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v530, p[v531])
		end
	}
	return (setmetatable(v531, __Type))
end

local v531 = "ScriptContext"

function GreenTea.ScriptContext()
	local v532 = nil
	v532 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v532, instance, (`expected {v531}, got {typeof(instance)}`))
			end

			if instance:IsA(v531) then
				return __Cause.ok()
			end

			return __Cause.err(v532, instance, (`expected {v531}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v531, p[v532])
		end
	}
	return (setmetatable(v532, __Type))
end

local v532 = "ScriptDebugger"

function GreenTea.ScriptDebugger()
	local v533 = nil
	v533 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v533, instance, (`expected {v532}, got {typeof(instance)}`))
			end

			if instance:IsA(v532) then
				return __Cause.ok()
			end

			return __Cause.err(v533, instance, (`expected {v532}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v532, p[v533])
		end
	}
	return (setmetatable(v533, __Type))
end

local v533 = "ScriptDocument"

function GreenTea.ScriptDocument()
	local v534 = nil
	v534 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v534, instance, (`expected {v533}, got {typeof(instance)}`))
			end

			if instance:IsA(v533) then
				return __Cause.ok()
			end

			return __Cause.err(v534, instance, (`expected {v533}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v533, p[v534])
		end
	}
	return (setmetatable(v534, __Type))
end

local v534 = "ScriptEditorService"

function GreenTea.ScriptEditorService()
	local v535 = nil
	v535 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v535, instance, (`expected {v534}, got {typeof(instance)}`))
			end

			if instance:IsA(v534) then
				return __Cause.ok()
			end

			return __Cause.err(v535, instance, (`expected {v534}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v534, p[v535])
		end
	}
	return (setmetatable(v535, __Type))
end

local v535 = "ScriptRegistrationService"

function GreenTea.ScriptRegistrationService()
	local v536 = nil
	v536 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v536, instance, (`expected {v535}, got {typeof(instance)}`))
			end

			if instance:IsA(v535) then
				return __Cause.ok()
			end

			return __Cause.err(v536, instance, (`expected {v535}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v535, p[v536])
		end
	}
	return (setmetatable(v536, __Type))
end

local v536 = "ScriptRuntime"

function GreenTea.ScriptRuntime()
	local v537 = nil
	v537 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v537, instance, (`expected {v536}, got {typeof(instance)}`))
			end

			if instance:IsA(v536) then
				return __Cause.ok()
			end

			return __Cause.err(v537, instance, (`expected {v536}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v536, p[v537])
		end
	}
	return (setmetatable(v537, __Type))
end

local v537 = "ScriptService"

function GreenTea.ScriptService()
	local v538 = nil
	v538 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v538, instance, (`expected {v537}, got {typeof(instance)}`))
			end

			if instance:IsA(v537) then
				return __Cause.ok()
			end

			return __Cause.err(v538, instance, (`expected {v537}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v537, p[v538])
		end
	}
	return (setmetatable(v538, __Type))
end

local v538 = "Selection"

function GreenTea.Selection()
	local v539 = nil
	v539 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v539, instance, (`expected {v538}, got {typeof(instance)}`))
			end

			if instance:IsA(v538) then
				return __Cause.ok()
			end

			return __Cause.err(v539, instance, (`expected {v538}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v538, p[v539])
		end
	}
	return (setmetatable(v539, __Type))
end

local v539 = "SelectionHighlightManager"

function GreenTea.SelectionHighlightManager()
	local v540 = nil
	v540 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v540, instance, (`expected {v539}, got {typeof(instance)}`))
			end

			if instance:IsA(v539) then
				return __Cause.ok()
			end

			return __Cause.err(v540, instance, (`expected {v539}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v539, p[v540])
		end
	}
	return (setmetatable(v540, __Type))
end

local v540 = "SensorBase"

function GreenTea.SensorBase()
	local v541 = nil
	v541 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v541, instance, (`expected {v540}, got {typeof(instance)}`))
			end

			if instance:IsA(v540) then
				return __Cause.ok()
			end

			return __Cause.err(v541, instance, (`expected {v540}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v540, p[v541])
		end
	}
	return (setmetatable(v541, __Type))
end

local v541 = "BuoyancySensor"

function GreenTea.BuoyancySensor()
	local v542 = nil
	v542 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v542, instance, (`expected {v541}, got {typeof(instance)}`))
			end

			if instance:IsA(v541) then
				return __Cause.ok()
			end

			return __Cause.err(v542, instance, (`expected {v541}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v541, p[v542])
		end
	}
	return (setmetatable(v542, __Type))
end

local v542 = "ControllerSensor"

function GreenTea.ControllerSensor()
	local v543 = nil
	v543 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v543, instance, (`expected {v542}, got {typeof(instance)}`))
			end

			if instance:IsA(v542) then
				return __Cause.ok()
			end

			return __Cause.err(v543, instance, (`expected {v542}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v542, p[v543])
		end
	}
	return (setmetatable(v543, __Type))
end

local v543 = "ControllerPartSensor"

function GreenTea.ControllerPartSensor()
	local v544 = nil
	v544 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v544, instance, (`expected {v543}, got {typeof(instance)}`))
			end

			if instance:IsA(v543) then
				return __Cause.ok()
			end

			return __Cause.err(v544, instance, (`expected {v543}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v543, p[v544])
		end
	}
	return (setmetatable(v544, __Type))
end

local v544 = "ServerScriptService"

function GreenTea.ServerScriptService()
	local v545 = nil
	v545 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v545, instance, (`expected {v544}, got {typeof(instance)}`))
			end

			if instance:IsA(v544) then
				return __Cause.ok()
			end

			return __Cause.err(v545, instance, (`expected {v544}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v544, p[v545])
		end
	}
	return (setmetatable(v545, __Type))
end

local v545 = "ServerStorage"

function GreenTea.ServerStorage()
	local v546 = nil
	v546 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v546, instance, (`expected {v545}, got {typeof(instance)}`))
			end

			if instance:IsA(v545) then
				return __Cause.ok()
			end

			return __Cause.err(v546, instance, (`expected {v545}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v545, p[v546])
		end
	}
	return (setmetatable(v546, __Type))
end

local v546 = "ServiceProvider"

function GreenTea.ServiceProvider()
	local v547 = nil
	v547 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v547, instance, (`expected {v546}, got {typeof(instance)}`))
			end

			if instance:IsA(v546) then
				return __Cause.ok()
			end

			return __Cause.err(v547, instance, (`expected {v546}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v546, p[v547])
		end
	}
	return (setmetatable(v547, __Type))
end

local v547 = "DataModel"

function GreenTea.DataModel()
	local v548 = nil
	v548 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v548, instance, (`expected {v547}, got {typeof(instance)}`))
			end

			if instance:IsA(v547) then
				return __Cause.ok()
			end

			return __Cause.err(v548, instance, (`expected {v547}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v547, p[v548])
		end
	}
	return (setmetatable(v548, __Type))
end

local v548 = "GenericSettings"

function GreenTea.GenericSettings()
	local v549 = nil
	v549 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v549, instance, (`expected {v548}, got {typeof(instance)}`))
			end

			if instance:IsA(v548) then
				return __Cause.ok()
			end

			return __Cause.err(v549, instance, (`expected {v548}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v548, p[v549])
		end
	}
	return (setmetatable(v549, __Type))
end

local v549 = "AnalysticsSettings"

function GreenTea.AnalysticsSettings()
	local v550 = nil
	v550 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v550, instance, (`expected {v549}, got {typeof(instance)}`))
			end

			if instance:IsA(v549) then
				return __Cause.ok()
			end

			return __Cause.err(v550, instance, (`expected {v549}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v549, p[v550])
		end
	}
	return (setmetatable(v550, __Type))
end

local v550 = "GlobalSettings"

function GreenTea.GlobalSettings()
	local v551 = nil
	v551 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v551, instance, (`expected {v550}, got {typeof(instance)}`))
			end

			if instance:IsA(v550) then
				return __Cause.ok()
			end

			return __Cause.err(v551, instance, (`expected {v550}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v550, p[v551])
		end
	}
	return (setmetatable(v551, __Type))
end

local v551 = "UserSettings"

function GreenTea.UserSettings()
	local v552 = nil
	v552 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v552, instance, (`expected {v551}, got {typeof(instance)}`))
			end

			if instance:IsA(v551) then
				return __Cause.ok()
			end

			return __Cause.err(v552, instance, (`expected {v551}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v551, p[v552])
		end
	}
	return (setmetatable(v552, __Type))
end

local v552 = "ServiceVisibilityService"

function GreenTea.ServiceVisibilityService()
	local v553 = nil
	v553 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v553, instance, (`expected {v552}, got {typeof(instance)}`))
			end

			if instance:IsA(v552) then
				return __Cause.ok()
			end

			return __Cause.err(v553, instance, (`expected {v552}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v552, p[v553])
		end
	}
	return (setmetatable(v553, __Type))
end

local v553 = "SessionService"

function GreenTea.SessionService()
	local v554 = nil
	v554 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v554, instance, (`expected {v553}, got {typeof(instance)}`))
			end

			if instance:IsA(v553) then
				return __Cause.ok()
			end

			return __Cause.err(v554, instance, (`expected {v553}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v553, p[v554])
		end
	}
	return (setmetatable(v554, __Type))
end

local v554 = "SharedTableRegistry"

function GreenTea.SharedTableRegistry()
	local v555 = nil
	v555 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v555, instance, (`expected {v554}, got {typeof(instance)}`))
			end

			if instance:IsA(v554) then
				return __Cause.ok()
			end

			return __Cause.err(v555, instance, (`expected {v554}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v554, p[v555])
		end
	}
	return (setmetatable(v555, __Type))
end

local v555 = "ShorelineUpgraderService"

function GreenTea.ShorelineUpgraderService()
	local v556 = nil
	v556 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v556, instance, (`expected {v555}, got {typeof(instance)}`))
			end

			if instance:IsA(v555) then
				return __Cause.ok()
			end

			return __Cause.err(v556, instance, (`expected {v555}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v555, p[v556])
		end
	}
	return (setmetatable(v556, __Type))
end

local v556 = "Sky"

function GreenTea.Sky()
	local v557 = nil
	v557 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v557, instance, (`expected {v556}, got {typeof(instance)}`))
			end

			if instance:IsA(v556) then
				return __Cause.ok()
			end

			return __Cause.err(v557, instance, (`expected {v556}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v556, p[v557])
		end
	}
	return (setmetatable(v557, __Type))
end

local v557 = "Smoke"

function GreenTea.Smoke()
	local v558 = nil
	v558 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v558, instance, (`expected {v557}, got {typeof(instance)}`))
			end

			if instance:IsA(v557) then
				return __Cause.ok()
			end

			return __Cause.err(v558, instance, (`expected {v557}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v557, p[v558])
		end
	}
	return (setmetatable(v558, __Type))
end

local v558 = "SmoothVoxelsUpgraderService"

function GreenTea.SmoothVoxelsUpgraderService()
	local v559 = nil
	v559 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v559, instance, (`expected {v558}, got {typeof(instance)}`))
			end

			if instance:IsA(v558) then
				return __Cause.ok()
			end

			return __Cause.err(v559, instance, (`expected {v558}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v558, p[v559])
		end
	}
	return (setmetatable(v559, __Type))
end

local v559 = "SnippetService"

function GreenTea.SnippetService()
	local v560 = nil
	v560 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v560, instance, (`expected {v559}, got {typeof(instance)}`))
			end

			if instance:IsA(v559) then
				return __Cause.ok()
			end

			return __Cause.err(v560, instance, (`expected {v559}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v559, p[v560])
		end
	}
	return (setmetatable(v560, __Type))
end

local v560 = "SocialService"

function GreenTea.SocialService()
	local v561 = nil
	v561 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v561, instance, (`expected {v560}, got {typeof(instance)}`))
			end

			if instance:IsA(v560) then
				return __Cause.ok()
			end

			return __Cause.err(v561, instance, (`expected {v560}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v560, p[v561])
		end
	}
	return (setmetatable(v561, __Type))
end

local v561 = "Sound"

function GreenTea.Sound()
	local v562 = nil
	v562 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v562, instance, (`expected {v561}, got {typeof(instance)}`))
			end

			if instance:IsA(v561) then
				return __Cause.ok()
			end

			return __Cause.err(v562, instance, (`expected {v561}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v561, p[v562])
		end
	}
	return (setmetatable(v562, __Type))
end

local v562 = "SoundEffect"

function GreenTea.SoundEffect()
	local v563 = nil
	v563 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v563, instance, (`expected {v562}, got {typeof(instance)}`))
			end

			if instance:IsA(v562) then
				return __Cause.ok()
			end

			return __Cause.err(v563, instance, (`expected {v562}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v562, p[v563])
		end
	}
	return (setmetatable(v563, __Type))
end

local v563 = "ChorusSoundEffect"

function GreenTea.ChorusSoundEffect()
	local v564 = nil
	v564 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v564, instance, (`expected {v563}, got {typeof(instance)}`))
			end

			if instance:IsA(v563) then
				return __Cause.ok()
			end

			return __Cause.err(v564, instance, (`expected {v563}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v563, p[v564])
		end
	}
	return (setmetatable(v564, __Type))
end

local v564 = "CompressorSoundEffect"

function GreenTea.CompressorSoundEffect()
	local v565 = nil
	v565 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v565, instance, (`expected {v564}, got {typeof(instance)}`))
			end

			if instance:IsA(v564) then
				return __Cause.ok()
			end

			return __Cause.err(v565, instance, (`expected {v564}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v564, p[v565])
		end
	}
	return (setmetatable(v565, __Type))
end

local v565 = "CustomSoundEffect"

function GreenTea.CustomSoundEffect()
	local v566 = nil
	v566 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v566, instance, (`expected {v565}, got {typeof(instance)}`))
			end

			if instance:IsA(v565) then
				return __Cause.ok()
			end

			return __Cause.err(v566, instance, (`expected {v565}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v565, p[v566])
		end
	}
	return (setmetatable(v566, __Type))
end

local v566 = "AssetSoundEffect"

function GreenTea.AssetSoundEffect()
	local v567 = nil
	v567 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v567, instance, (`expected {v566}, got {typeof(instance)}`))
			end

			if instance:IsA(v566) then
				return __Cause.ok()
			end

			return __Cause.err(v567, instance, (`expected {v566}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v566, p[v567])
		end
	}
	return (setmetatable(v567, __Type))
end

local v567 = "ChannelSelectorSoundEffect"

function GreenTea.ChannelSelectorSoundEffect()
	local v568 = nil
	v568 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v568, instance, (`expected {v567}, got {typeof(instance)}`))
			end

			if instance:IsA(v567) then
				return __Cause.ok()
			end

			return __Cause.err(v568, instance, (`expected {v567}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v567, p[v568])
		end
	}
	return (setmetatable(v568, __Type))
end

local v568 = "DistortionSoundEffect"

function GreenTea.DistortionSoundEffect()
	local v569 = nil
	v569 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v569, instance, (`expected {v568}, got {typeof(instance)}`))
			end

			if instance:IsA(v568) then
				return __Cause.ok()
			end

			return __Cause.err(v569, instance, (`expected {v568}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v568, p[v569])
		end
	}
	return (setmetatable(v569, __Type))
end

local v569 = "EchoSoundEffect"

function GreenTea.EchoSoundEffect()
	local v570 = nil
	v570 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v570, instance, (`expected {v569}, got {typeof(instance)}`))
			end

			if instance:IsA(v569) then
				return __Cause.ok()
			end

			return __Cause.err(v570, instance, (`expected {v569}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v569, p[v570])
		end
	}
	return (setmetatable(v570, __Type))
end

local v570 = "EqualizerSoundEffect"

function GreenTea.EqualizerSoundEffect()
	local v571 = nil
	v571 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v571, instance, (`expected {v570}, got {typeof(instance)}`))
			end

			if instance:IsA(v570) then
				return __Cause.ok()
			end

			return __Cause.err(v571, instance, (`expected {v570}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v570, p[v571])
		end
	}
	return (setmetatable(v571, __Type))
end

local v571 = "FlangeSoundEffect"

function GreenTea.FlangeSoundEffect()
	local v572 = nil
	v572 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v572, instance, (`expected {v571}, got {typeof(instance)}`))
			end

			if instance:IsA(v571) then
				return __Cause.ok()
			end

			return __Cause.err(v572, instance, (`expected {v571}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v571, p[v572])
		end
	}
	return (setmetatable(v572, __Type))
end

local v572 = "PitchShiftSoundEffect"

function GreenTea.PitchShiftSoundEffect()
	local v573 = nil
	v573 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v573, instance, (`expected {v572}, got {typeof(instance)}`))
			end

			if instance:IsA(v572) then
				return __Cause.ok()
			end

			return __Cause.err(v573, instance, (`expected {v572}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v572, p[v573])
		end
	}
	return (setmetatable(v573, __Type))
end

local v573 = "ReverbSoundEffect"

function GreenTea.ReverbSoundEffect()
	local v574 = nil
	v574 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v574, instance, (`expected {v573}, got {typeof(instance)}`))
			end

			if instance:IsA(v573) then
				return __Cause.ok()
			end

			return __Cause.err(v574, instance, (`expected {v573}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v573, p[v574])
		end
	}
	return (setmetatable(v574, __Type))
end

local v574 = "TremoloSoundEffect"

function GreenTea.TremoloSoundEffect()
	local v575 = nil
	v575 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v575, instance, (`expected {v574}, got {typeof(instance)}`))
			end

			if instance:IsA(v574) then
				return __Cause.ok()
			end

			return __Cause.err(v575, instance, (`expected {v574}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v574, p[v575])
		end
	}
	return (setmetatable(v575, __Type))
end

local v575 = "SoundGroup"

function GreenTea.SoundGroup()
	local v576 = nil
	v576 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v576, instance, (`expected {v575}, got {typeof(instance)}`))
			end

			if instance:IsA(v575) then
				return __Cause.ok()
			end

			return __Cause.err(v576, instance, (`expected {v575}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v575, p[v576])
		end
	}
	return (setmetatable(v576, __Type))
end

local v576 = "SoundService"

function GreenTea.SoundService()
	local v577 = nil
	v577 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v577, instance, (`expected {v576}, got {typeof(instance)}`))
			end

			if instance:IsA(v576) then
				return __Cause.ok()
			end

			return __Cause.err(v577, instance, (`expected {v576}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v576, p[v577])
		end
	}
	return (setmetatable(v577, __Type))
end

local v577 = "Sparkles"

function GreenTea.Sparkles()
	local v578 = nil
	v578 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v578, instance, (`expected {v577}, got {typeof(instance)}`))
			end

			if instance:IsA(v577) then
				return __Cause.ok()
			end

			return __Cause.err(v578, instance, (`expected {v577}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v577, p[v578])
		end
	}
	return (setmetatable(v578, __Type))
end

local v578 = "SpawnerService"

function GreenTea.SpawnerService()
	local v579 = nil
	v579 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v579, instance, (`expected {v578}, got {typeof(instance)}`))
			end

			if instance:IsA(v578) then
				return __Cause.ok()
			end

			return __Cause.err(v579, instance, (`expected {v578}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v578, p[v579])
		end
	}
	return (setmetatable(v579, __Type))
end

local v579 = "StackFrame"

function GreenTea.StackFrame()
	local v580 = nil
	v580 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v580, instance, (`expected {v579}, got {typeof(instance)}`))
			end

			if instance:IsA(v579) then
				return __Cause.ok()
			end

			return __Cause.err(v580, instance, (`expected {v579}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v579, p[v580])
		end
	}
	return (setmetatable(v580, __Type))
end

local v580 = "StandalonePluginScripts"

function GreenTea.StandalonePluginScripts()
	local v581 = nil
	v581 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v581, instance, (`expected {v580}, got {typeof(instance)}`))
			end

			if instance:IsA(v580) then
				return __Cause.ok()
			end

			return __Cause.err(v581, instance, (`expected {v580}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v580, p[v581])
		end
	}
	return (setmetatable(v581, __Type))
end

local v581 = "StarterGear"

function GreenTea.StarterGear()
	local v582 = nil
	v582 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v582, instance, (`expected {v581}, got {typeof(instance)}`))
			end

			if instance:IsA(v581) then
				return __Cause.ok()
			end

			return __Cause.err(v582, instance, (`expected {v581}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v581, p[v582])
		end
	}
	return (setmetatable(v582, __Type))
end

local v582 = "StarterPack"

function GreenTea.StarterPack()
	local v583 = nil
	v583 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v583, instance, (`expected {v582}, got {typeof(instance)}`))
			end

			if instance:IsA(v582) then
				return __Cause.ok()
			end

			return __Cause.err(v583, instance, (`expected {v582}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v582, p[v583])
		end
	}
	return (setmetatable(v583, __Type))
end

local v583 = "StarterPlayer"

function GreenTea.StarterPlayer()
	local v584 = nil
	v584 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v584, instance, (`expected {v583}, got {typeof(instance)}`))
			end

			if instance:IsA(v583) then
				return __Cause.ok()
			end

			return __Cause.err(v584, instance, (`expected {v583}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v583, p[v584])
		end
	}
	return (setmetatable(v584, __Type))
end

local v584 = "StarterPlayerScripts"

function GreenTea.StarterPlayerScripts()
	local v585 = nil
	v585 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v585, instance, (`expected {v584}, got {typeof(instance)}`))
			end

			if instance:IsA(v584) then
				return __Cause.ok()
			end

			return __Cause.err(v585, instance, (`expected {v584}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v584, p[v585])
		end
	}
	return (setmetatable(v585, __Type))
end

local v585 = "StarterCharacterScripts"

function GreenTea.StarterCharacterScripts()
	local v586 = nil
	v586 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v586, instance, (`expected {v585}, got {typeof(instance)}`))
			end

			if instance:IsA(v585) then
				return __Cause.ok()
			end

			return __Cause.err(v586, instance, (`expected {v585}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v585, p[v586])
		end
	}
	return (setmetatable(v586, __Type))
end

local v586 = "Stats"

function GreenTea.Stats()
	local v587 = nil
	v587 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v587, instance, (`expected {v586}, got {typeof(instance)}`))
			end

			if instance:IsA(v586) then
				return __Cause.ok()
			end

			return __Cause.err(v587, instance, (`expected {v586}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v586, p[v587])
		end
	}
	return (setmetatable(v587, __Type))
end

local v587 = "StatsItem"

function GreenTea.StatsItem()
	local v588 = nil
	v588 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v588, instance, (`expected {v587}, got {typeof(instance)}`))
			end

			if instance:IsA(v587) then
				return __Cause.ok()
			end

			return __Cause.err(v588, instance, (`expected {v587}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v587, p[v588])
		end
	}
	return (setmetatable(v588, __Type))
end

local v588 = "RunningAverageItemDouble"

function GreenTea.RunningAverageItemDouble()
	local v589 = nil
	v589 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v589, instance, (`expected {v588}, got {typeof(instance)}`))
			end

			if instance:IsA(v588) then
				return __Cause.ok()
			end

			return __Cause.err(v589, instance, (`expected {v588}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v588, p[v589])
		end
	}
	return (setmetatable(v589, __Type))
end

local v589 = "RunningAverageItemInt"

function GreenTea.RunningAverageItemInt()
	local v590 = nil
	v590 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v590, instance, (`expected {v589}, got {typeof(instance)}`))
			end

			if instance:IsA(v589) then
				return __Cause.ok()
			end

			return __Cause.err(v590, instance, (`expected {v589}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v589, p[v590])
		end
	}
	return (setmetatable(v590, __Type))
end

local v590 = "RunningAverageTimeIntervalItem"

function GreenTea.RunningAverageTimeIntervalItem()
	local v591 = nil
	v591 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v591, instance, (`expected {v590}, got {typeof(instance)}`))
			end

			if instance:IsA(v590) then
				return __Cause.ok()
			end

			return __Cause.err(v591, instance, (`expected {v590}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v590, p[v591])
		end
	}
	return (setmetatable(v591, __Type))
end

local v591 = "TotalCountTimeIntervalItem"

function GreenTea.TotalCountTimeIntervalItem()
	local v592 = nil
	v592 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v592, instance, (`expected {v591}, got {typeof(instance)}`))
			end

			if instance:IsA(v591) then
				return __Cause.ok()
			end

			return __Cause.err(v592, instance, (`expected {v591}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v591, p[v592])
		end
	}
	return (setmetatable(v592, __Type))
end

local v592 = "StopWatchReporter"

function GreenTea.StopWatchReporter()
	local v593 = nil
	v593 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v593, instance, (`expected {v592}, got {typeof(instance)}`))
			end

			if instance:IsA(v592) then
				return __Cause.ok()
			end

			return __Cause.err(v593, instance, (`expected {v592}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v592, p[v593])
		end
	}
	return (setmetatable(v593, __Type))
end

local v593 = "StreamingService"

function GreenTea.StreamingService()
	local v594 = nil
	v594 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v594, instance, (`expected {v593}, got {typeof(instance)}`))
			end

			if instance:IsA(v593) then
				return __Cause.ok()
			end

			return __Cause.err(v594, instance, (`expected {v593}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v593, p[v594])
		end
	}
	return (setmetatable(v594, __Type))
end

local v594 = "Studio"

function GreenTea.Studio()
	local v595 = nil
	v595 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v595, instance, (`expected {v594}, got {typeof(instance)}`))
			end

			if instance:IsA(v594) then
				return __Cause.ok()
			end

			return __Cause.err(v595, instance, (`expected {v594}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v594, p[v595])
		end
	}
	return (setmetatable(v595, __Type))
end

local v595 = "StudioAssetService"

function GreenTea.StudioAssetService()
	local v596 = nil
	v596 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v596, instance, (`expected {v595}, got {typeof(instance)}`))
			end

			if instance:IsA(v595) then
				return __Cause.ok()
			end

			return __Cause.err(v596, instance, (`expected {v595}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v595, p[v596])
		end
	}
	return (setmetatable(v596, __Type))
end

local v596 = "StudioAttachment"

function GreenTea.StudioAttachment()
	local v597 = nil
	v597 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v597, instance, (`expected {v596}, got {typeof(instance)}`))
			end

			if instance:IsA(v596) then
				return __Cause.ok()
			end

			return __Cause.err(v597, instance, (`expected {v596}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v596, p[v597])
		end
	}
	return (setmetatable(v597, __Type))
end

local v597 = "StudioCallout"

function GreenTea.StudioCallout()
	local v598 = nil
	v598 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v598, instance, (`expected {v597}, got {typeof(instance)}`))
			end

			if instance:IsA(v597) then
				return __Cause.ok()
			end

			return __Cause.err(v598, instance, (`expected {v597}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v597, p[v598])
		end
	}
	return (setmetatable(v598, __Type))
end

local v598 = "StudioData"

function GreenTea.StudioData()
	local v599 = nil
	v599 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v599, instance, (`expected {v598}, got {typeof(instance)}`))
			end

			if instance:IsA(v598) then
				return __Cause.ok()
			end

			return __Cause.err(v599, instance, (`expected {v598}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v598, p[v599])
		end
	}
	return (setmetatable(v599, __Type))
end

local v599 = "StudioDeviceEmulatorService"

function GreenTea.StudioDeviceEmulatorService()
	local v600 = nil
	v600 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v600, instance, (`expected {v599}, got {typeof(instance)}`))
			end

			if instance:IsA(v599) then
				return __Cause.ok()
			end

			return __Cause.err(v600, instance, (`expected {v599}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v599, p[v600])
		end
	}
	return (setmetatable(v600, __Type))
end

local v600 = "StudioObjectBase"

function GreenTea.StudioObjectBase()
	local v601 = nil
	v601 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v601, instance, (`expected {v600}, got {typeof(instance)}`))
			end

			if instance:IsA(v600) then
				return __Cause.ok()
			end

			return __Cause.err(v601, instance, (`expected {v600}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v600, p[v601])
		end
	}
	return (setmetatable(v601, __Type))
end

local v601 = "StudioWidget"

function GreenTea.StudioWidget()
	local v602 = nil
	v602 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v602, instance, (`expected {v601}, got {typeof(instance)}`))
			end

			if instance:IsA(v601) then
				return __Cause.ok()
			end

			return __Cause.err(v602, instance, (`expected {v601}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v601, p[v602])
		end
	}
	return (setmetatable(v602, __Type))
end

local v602 = "StudioPublishService"

function GreenTea.StudioPublishService()
	local v603 = nil
	v603 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v603, instance, (`expected {v602}, got {typeof(instance)}`))
			end

			if instance:IsA(v602) then
				return __Cause.ok()
			end

			return __Cause.err(v603, instance, (`expected {v602}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v602, p[v603])
		end
	}
	return (setmetatable(v603, __Type))
end

local v603 = "StudioScriptDebugEventListener"

function GreenTea.StudioScriptDebugEventListener()
	local v604 = nil
	v604 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v604, instance, (`expected {v603}, got {typeof(instance)}`))
			end

			if instance:IsA(v603) then
				return __Cause.ok()
			end

			return __Cause.err(v604, instance, (`expected {v603}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v603, p[v604])
		end
	}
	return (setmetatable(v604, __Type))
end

local v604 = "StudioSdkService"

function GreenTea.StudioSdkService()
	local v605 = nil
	v605 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v605, instance, (`expected {v604}, got {typeof(instance)}`))
			end

			if instance:IsA(v604) then
				return __Cause.ok()
			end

			return __Cause.err(v605, instance, (`expected {v604}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v604, p[v605])
		end
	}
	return (setmetatable(v605, __Type))
end

local v605 = "StudioService"

function GreenTea.StudioService()
	local v606 = nil
	v606 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v606, instance, (`expected {v605}, got {typeof(instance)}`))
			end

			if instance:IsA(v605) then
				return __Cause.ok()
			end

			return __Cause.err(v606, instance, (`expected {v605}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v605, p[v606])
		end
	}
	return (setmetatable(v606, __Type))
end

local v606 = "StudioTheme"

function GreenTea.StudioTheme()
	local v607 = nil
	v607 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v607, instance, (`expected {v606}, got {typeof(instance)}`))
			end

			if instance:IsA(v606) then
				return __Cause.ok()
			end

			return __Cause.err(v607, instance, (`expected {v606}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v606, p[v607])
		end
	}
	return (setmetatable(v607, __Type))
end

local v607 = "StudioWidgetsService"

function GreenTea.StudioWidgetsService()
	local v608 = nil
	v608 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v608, instance, (`expected {v607}, got {typeof(instance)}`))
			end

			if instance:IsA(v607) then
				return __Cause.ok()
			end

			return __Cause.err(v608, instance, (`expected {v607}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v607, p[v608])
		end
	}
	return (setmetatable(v608, __Type))
end

local v608 = "StyleBase"

function GreenTea.StyleBase()
	local v609 = nil
	v609 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v609, instance, (`expected {v608}, got {typeof(instance)}`))
			end

			if instance:IsA(v608) then
				return __Cause.ok()
			end

			return __Cause.err(v609, instance, (`expected {v608}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v608, p[v609])
		end
	}
	return (setmetatable(v609, __Type))
end

local v609 = "StyleRule"

function GreenTea.StyleRule()
	local v610 = nil
	v610 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v610, instance, (`expected {v609}, got {typeof(instance)}`))
			end

			if instance:IsA(v609) then
				return __Cause.ok()
			end

			return __Cause.err(v610, instance, (`expected {v609}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v609, p[v610])
		end
	}
	return (setmetatable(v610, __Type))
end

local v610 = "StyleSheet"

function GreenTea.StyleSheet()
	local v611 = nil
	v611 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v611, instance, (`expected {v610}, got {typeof(instance)}`))
			end

			if instance:IsA(v610) then
				return __Cause.ok()
			end

			return __Cause.err(v611, instance, (`expected {v610}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v610, p[v611])
		end
	}
	return (setmetatable(v611, __Type))
end

local v611 = "StyleDerive"

function GreenTea.StyleDerive()
	local v612 = nil
	v612 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v612, instance, (`expected {v611}, got {typeof(instance)}`))
			end

			if instance:IsA(v611) then
				return __Cause.ok()
			end

			return __Cause.err(v612, instance, (`expected {v611}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v611, p[v612])
		end
	}
	return (setmetatable(v612, __Type))
end

local v612 = "StyleLink"

function GreenTea.StyleLink()
	local v613 = nil
	v613 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v613, instance, (`expected {v612}, got {typeof(instance)}`))
			end

			if instance:IsA(v612) then
				return __Cause.ok()
			end

			return __Cause.err(v613, instance, (`expected {v612}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v612, p[v613])
		end
	}
	return (setmetatable(v613, __Type))
end

local v613 = "StylingService"

function GreenTea.StylingService()
	local v614 = nil
	v614 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v614, instance, (`expected {v613}, got {typeof(instance)}`))
			end

			if instance:IsA(v613) then
				return __Cause.ok()
			end

			return __Cause.err(v614, instance, (`expected {v613}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v613, p[v614])
		end
	}
	return (setmetatable(v614, __Type))
end

local v614 = "SurfaceAppearance"

function GreenTea.SurfaceAppearance()
	local v615 = nil
	v615 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v615, instance, (`expected {v614}, got {typeof(instance)}`))
			end

			if instance:IsA(v614) then
				return __Cause.ok()
			end

			return __Cause.err(v615, instance, (`expected {v614}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v614, p[v615])
		end
	}
	return (setmetatable(v615, __Type))
end

local v615 = "TaskScheduler"

function GreenTea.TaskScheduler()
	local v616 = nil
	v616 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v616, instance, (`expected {v615}, got {typeof(instance)}`))
			end

			if instance:IsA(v615) then
				return __Cause.ok()
			end

			return __Cause.err(v616, instance, (`expected {v615}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v615, p[v616])
		end
	}
	return (setmetatable(v616, __Type))
end

local v616 = "Team"

function GreenTea.Team()
	local v617 = nil
	v617 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v617, instance, (`expected {v616}, got {typeof(instance)}`))
			end

			if instance:IsA(v616) then
				return __Cause.ok()
			end

			return __Cause.err(v617, instance, (`expected {v616}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v616, p[v617])
		end
	}
	return (setmetatable(v617, __Type))
end

local v617 = "TeamCreateData"

function GreenTea.TeamCreateData()
	local v618 = nil
	v618 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v618, instance, (`expected {v617}, got {typeof(instance)}`))
			end

			if instance:IsA(v617) then
				return __Cause.ok()
			end

			return __Cause.err(v618, instance, (`expected {v617}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v617, p[v618])
		end
	}
	return (setmetatable(v618, __Type))
end

local v618 = "TeamCreatePublishService"

function GreenTea.TeamCreatePublishService()
	local v619 = nil
	v619 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v619, instance, (`expected {v618}, got {typeof(instance)}`))
			end

			if instance:IsA(v618) then
				return __Cause.ok()
			end

			return __Cause.err(v619, instance, (`expected {v618}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v618, p[v619])
		end
	}
	return (setmetatable(v619, __Type))
end

local v619 = "TeamCreateService"

function GreenTea.TeamCreateService()
	local v620 = nil
	v620 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v620, instance, (`expected {v619}, got {typeof(instance)}`))
			end

			if instance:IsA(v619) then
				return __Cause.ok()
			end

			return __Cause.err(v620, instance, (`expected {v619}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v619, p[v620])
		end
	}
	return (setmetatable(v620, __Type))
end

local v620 = "Teams"

function GreenTea.Teams()
	local v621 = nil
	v621 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v621, instance, (`expected {v620}, got {typeof(instance)}`))
			end

			if instance:IsA(v620) then
				return __Cause.ok()
			end

			return __Cause.err(v621, instance, (`expected {v620}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v620, p[v621])
		end
	}
	return (setmetatable(v621, __Type))
end

local v621 = "TeleportAsyncResult"

function GreenTea.TeleportAsyncResult()
	local v622 = nil
	v622 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v622, instance, (`expected {v621}, got {typeof(instance)}`))
			end

			if instance:IsA(v621) then
				return __Cause.ok()
			end

			return __Cause.err(v622, instance, (`expected {v621}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v621, p[v622])
		end
	}
	return (setmetatable(v622, __Type))
end

local v622 = "TeleportOptions"

function GreenTea.TeleportOptions()
	local v623 = nil
	v623 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v623, instance, (`expected {v622}, got {typeof(instance)}`))
			end

			if instance:IsA(v622) then
				return __Cause.ok()
			end

			return __Cause.err(v623, instance, (`expected {v622}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v622, p[v623])
		end
	}
	return (setmetatable(v623, __Type))
end

local v623 = "TeleportService"

function GreenTea.TeleportService()
	local v624 = nil
	v624 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v624, instance, (`expected {v623}, got {typeof(instance)}`))
			end

			if instance:IsA(v623) then
				return __Cause.ok()
			end

			return __Cause.err(v624, instance, (`expected {v623}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v623, p[v624])
		end
	}
	return (setmetatable(v624, __Type))
end

local v624 = "TemporaryCageMeshProvider"

function GreenTea.TemporaryCageMeshProvider()
	local v625 = nil
	v625 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v625, instance, (`expected {v624}, got {typeof(instance)}`))
			end

			if instance:IsA(v624) then
				return __Cause.ok()
			end

			return __Cause.err(v625, instance, (`expected {v624}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v624, p[v625])
		end
	}
	return (setmetatable(v625, __Type))
end

local v625 = "TemporaryScriptService"

function GreenTea.TemporaryScriptService()
	local v626 = nil
	v626 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v626, instance, (`expected {v625}, got {typeof(instance)}`))
			end

			if instance:IsA(v625) then
				return __Cause.ok()
			end

			return __Cause.err(v626, instance, (`expected {v625}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v625, p[v626])
		end
	}
	return (setmetatable(v626, __Type))
end

local v626 = "TerrainDetail"

function GreenTea.TerrainDetail()
	local v627 = nil
	v627 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v627, instance, (`expected {v626}, got {typeof(instance)}`))
			end

			if instance:IsA(v626) then
				return __Cause.ok()
			end

			return __Cause.err(v627, instance, (`expected {v626}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v626, p[v627])
		end
	}
	return (setmetatable(v627, __Type))
end

local v627 = "TerrainRegion"

function GreenTea.TerrainRegion()
	local v628 = nil
	v628 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v628, instance, (`expected {v627}, got {typeof(instance)}`))
			end

			if instance:IsA(v627) then
				return __Cause.ok()
			end

			return __Cause.err(v628, instance, (`expected {v627}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v627, p[v628])
		end
	}
	return (setmetatable(v628, __Type))
end

local v628 = "TestService"

function GreenTea.TestService()
	local v629 = nil
	v629 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v629, instance, (`expected {v628}, got {typeof(instance)}`))
			end

			if instance:IsA(v628) then
				return __Cause.ok()
			end

			return __Cause.err(v629, instance, (`expected {v628}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v628, p[v629])
		end
	}
	return (setmetatable(v629, __Type))
end

local v629 = "TextBoxService"

function GreenTea.TextBoxService()
	local v630 = nil
	v630 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v630, instance, (`expected {v629}, got {typeof(instance)}`))
			end

			if instance:IsA(v629) then
				return __Cause.ok()
			end

			return __Cause.err(v630, instance, (`expected {v629}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v629, p[v630])
		end
	}
	return (setmetatable(v630, __Type))
end

local v630 = "TextChannel"

function GreenTea.TextChannel()
	local v631 = nil
	v631 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v631, instance, (`expected {v630}, got {typeof(instance)}`))
			end

			if instance:IsA(v630) then
				return __Cause.ok()
			end

			return __Cause.err(v631, instance, (`expected {v630}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v630, p[v631])
		end
	}
	return (setmetatable(v631, __Type))
end

local v631 = "TextChatCommand"

function GreenTea.TextChatCommand()
	local v632 = nil
	v632 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v632, instance, (`expected {v631}, got {typeof(instance)}`))
			end

			if instance:IsA(v631) then
				return __Cause.ok()
			end

			return __Cause.err(v632, instance, (`expected {v631}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v631, p[v632])
		end
	}
	return (setmetatable(v632, __Type))
end

local v632 = "TextChatConfigurations"

function GreenTea.TextChatConfigurations()
	local v633 = nil
	v633 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v633, instance, (`expected {v632}, got {typeof(instance)}`))
			end

			if instance:IsA(v632) then
				return __Cause.ok()
			end

			return __Cause.err(v633, instance, (`expected {v632}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v632, p[v633])
		end
	}
	return (setmetatable(v633, __Type))
end

local v633 = "BubbleChatConfiguration"

function GreenTea.BubbleChatConfiguration()
	local v634 = nil
	v634 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v634, instance, (`expected {v633}, got {typeof(instance)}`))
			end

			if instance:IsA(v633) then
				return __Cause.ok()
			end

			return __Cause.err(v634, instance, (`expected {v633}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v633, p[v634])
		end
	}
	return (setmetatable(v634, __Type))
end

local v634 = "ChatInputBarConfiguration"

function GreenTea.ChatInputBarConfiguration()
	local v635 = nil
	v635 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v635, instance, (`expected {v634}, got {typeof(instance)}`))
			end

			if instance:IsA(v634) then
				return __Cause.ok()
			end

			return __Cause.err(v635, instance, (`expected {v634}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v634, p[v635])
		end
	}
	return (setmetatable(v635, __Type))
end

local v635 = "ChatWindowConfiguration"

function GreenTea.ChatWindowConfiguration()
	local v636 = nil
	v636 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v636, instance, (`expected {v635}, got {typeof(instance)}`))
			end

			if instance:IsA(v635) then
				return __Cause.ok()
			end

			return __Cause.err(v636, instance, (`expected {v635}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v635, p[v636])
		end
	}
	return (setmetatable(v636, __Type))
end

local v636 = "TextChatMessage"

function GreenTea.TextChatMessage()
	local v637 = nil
	v637 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v637, instance, (`expected {v636}, got {typeof(instance)}`))
			end

			if instance:IsA(v636) then
				return __Cause.ok()
			end

			return __Cause.err(v637, instance, (`expected {v636}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v636, p[v637])
		end
	}
	return (setmetatable(v637, __Type))
end

local v637 = "TextChatMessageProperties"

function GreenTea.TextChatMessageProperties()
	local v638 = nil
	v638 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v638, instance, (`expected {v637}, got {typeof(instance)}`))
			end

			if instance:IsA(v637) then
				return __Cause.ok()
			end

			return __Cause.err(v638, instance, (`expected {v637}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v637, p[v638])
		end
	}
	return (setmetatable(v638, __Type))
end

local v638 = "TextChatService"

function GreenTea.TextChatService()
	local v639 = nil
	v639 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v639, instance, (`expected {v638}, got {typeof(instance)}`))
			end

			if instance:IsA(v638) then
				return __Cause.ok()
			end

			return __Cause.err(v639, instance, (`expected {v638}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v638, p[v639])
		end
	}
	return (setmetatable(v639, __Type))
end

local v639 = "TextFilterResult"

function GreenTea.TextFilterResult()
	local v640 = nil
	v640 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v640, instance, (`expected {v639}, got {typeof(instance)}`))
			end

			if instance:IsA(v639) then
				return __Cause.ok()
			end

			return __Cause.err(v640, instance, (`expected {v639}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v639, p[v640])
		end
	}
	return (setmetatable(v640, __Type))
end

local v640 = "TextFilterTranslatedResult"

function GreenTea.TextFilterTranslatedResult()
	local v641 = nil
	v641 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v641, instance, (`expected {v640}, got {typeof(instance)}`))
			end

			if instance:IsA(v640) then
				return __Cause.ok()
			end

			return __Cause.err(v641, instance, (`expected {v640}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v640, p[v641])
		end
	}
	return (setmetatable(v641, __Type))
end

local v641 = "TextService"

function GreenTea.TextService()
	local v642 = nil
	v642 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v642, instance, (`expected {v641}, got {typeof(instance)}`))
			end

			if instance:IsA(v641) then
				return __Cause.ok()
			end

			return __Cause.err(v642, instance, (`expected {v641}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v641, p[v642])
		end
	}
	return (setmetatable(v642, __Type))
end

local v642 = "TextSource"

function GreenTea.TextSource()
	local v643 = nil
	v643 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v643, instance, (`expected {v642}, got {typeof(instance)}`))
			end

			if instance:IsA(v642) then
				return __Cause.ok()
			end

			return __Cause.err(v643, instance, (`expected {v642}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v642, p[v643])
		end
	}
	return (setmetatable(v643, __Type))
end

local v643 = "ThirdPartyUserService"

function GreenTea.ThirdPartyUserService()
	local v644 = nil
	v644 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v644, instance, (`expected {v643}, got {typeof(instance)}`))
			end

			if instance:IsA(v643) then
				return __Cause.ok()
			end

			return __Cause.err(v644, instance, (`expected {v643}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v643, p[v644])
		end
	}
	return (setmetatable(v644, __Type))
end

local v644 = "ThreadState"

function GreenTea.ThreadState()
	local v645 = nil
	v645 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v645, instance, (`expected {v644}, got {typeof(instance)}`))
			end

			if instance:IsA(v644) then
				return __Cause.ok()
			end

			return __Cause.err(v645, instance, (`expected {v644}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v644, p[v645])
		end
	}
	return (setmetatable(v645, __Type))
end

local v645 = "TimerService"

function GreenTea.TimerService()
	local v646 = nil
	v646 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v646, instance, (`expected {v645}, got {typeof(instance)}`))
			end

			if instance:IsA(v645) then
				return __Cause.ok()
			end

			return __Cause.err(v646, instance, (`expected {v645}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v645, p[v646])
		end
	}
	return (setmetatable(v646, __Type))
end

local v646 = "ToastNotificationService"

function GreenTea.ToastNotificationService()
	local v647 = nil
	v647 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v647, instance, (`expected {v646}, got {typeof(instance)}`))
			end

			if instance:IsA(v646) then
				return __Cause.ok()
			end

			return __Cause.err(v647, instance, (`expected {v646}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v646, p[v647])
		end
	}
	return (setmetatable(v647, __Type))
end

local v647 = "TouchInputService"

function GreenTea.TouchInputService()
	local v648 = nil
	v648 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v648, instance, (`expected {v647}, got {typeof(instance)}`))
			end

			if instance:IsA(v647) then
				return __Cause.ok()
			end

			return __Cause.err(v648, instance, (`expected {v647}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v647, p[v648])
		end
	}
	return (setmetatable(v648, __Type))
end

local v648 = "TouchTransmitter"

function GreenTea.TouchTransmitter()
	local v649 = nil
	v649 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v649, instance, (`expected {v648}, got {typeof(instance)}`))
			end

			if instance:IsA(v648) then
				return __Cause.ok()
			end

			return __Cause.err(v649, instance, (`expected {v648}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v648, p[v649])
		end
	}
	return (setmetatable(v649, __Type))
end

local v649 = "TracerService"

function GreenTea.TracerService()
	local v650 = nil
	v650 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v650, instance, (`expected {v649}, got {typeof(instance)}`))
			end

			if instance:IsA(v649) then
				return __Cause.ok()
			end

			return __Cause.err(v650, instance, (`expected {v649}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v649, p[v650])
		end
	}
	return (setmetatable(v650, __Type))
end

local v650 = "TrackerLodController"

function GreenTea.TrackerLodController()
	local v651 = nil
	v651 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v651, instance, (`expected {v650}, got {typeof(instance)}`))
			end

			if instance:IsA(v650) then
				return __Cause.ok()
			end

			return __Cause.err(v651, instance, (`expected {v650}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v650, p[v651])
		end
	}
	return (setmetatable(v651, __Type))
end

local v651 = "TrackerStreamAnimation"

function GreenTea.TrackerStreamAnimation()
	local v652 = nil
	v652 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v652, instance, (`expected {v651}, got {typeof(instance)}`))
			end

			if instance:IsA(v651) then
				return __Cause.ok()
			end

			return __Cause.err(v652, instance, (`expected {v651}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v651, p[v652])
		end
	}
	return (setmetatable(v652, __Type))
end

local v652 = "Trail"

function GreenTea.Trail()
	local v653 = nil
	v653 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v653, instance, (`expected {v652}, got {typeof(instance)}`))
			end

			if instance:IsA(v652) then
				return __Cause.ok()
			end

			return __Cause.err(v653, instance, (`expected {v652}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v652, p[v653])
		end
	}
	return (setmetatable(v653, __Type))
end

local v653 = "Translator"

function GreenTea.Translator()
	local v654 = nil
	v654 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v654, instance, (`expected {v653}, got {typeof(instance)}`))
			end

			if instance:IsA(v653) then
				return __Cause.ok()
			end

			return __Cause.err(v654, instance, (`expected {v653}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v653, p[v654])
		end
	}
	return (setmetatable(v654, __Type))
end

local v654 = "TutorialService"

function GreenTea.TutorialService()
	local v655 = nil
	v655 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v655, instance, (`expected {v654}, got {typeof(instance)}`))
			end

			if instance:IsA(v654) then
				return __Cause.ok()
			end

			return __Cause.err(v655, instance, (`expected {v654}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v654, p[v655])
		end
	}
	return (setmetatable(v655, __Type))
end

local v655 = "TweenBase"

function GreenTea.TweenBase()
	local v656 = nil
	v656 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v656, instance, (`expected {v655}, got {typeof(instance)}`))
			end

			if instance:IsA(v655) then
				return __Cause.ok()
			end

			return __Cause.err(v656, instance, (`expected {v655}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v655, p[v656])
		end
	}
	return (setmetatable(v656, __Type))
end

local v656 = "Tween"

function GreenTea.Tween()
	local v657 = nil
	v657 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v657, instance, (`expected {v656}, got {typeof(instance)}`))
			end

			if instance:IsA(v656) then
				return __Cause.ok()
			end

			return __Cause.err(v657, instance, (`expected {v656}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v656, p[v657])
		end
	}
	return (setmetatable(v657, __Type))
end

local v657 = "TweenService"

function GreenTea.TweenService()
	local v658 = nil
	v658 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v658, instance, (`expected {v657}, got {typeof(instance)}`))
			end

			if instance:IsA(v657) then
				return __Cause.ok()
			end

			return __Cause.err(v658, instance, (`expected {v657}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v657, p[v658])
		end
	}
	return (setmetatable(v658, __Type))
end

local v658 = "UGCAvatarService"

function GreenTea.UGCAvatarService()
	local v659 = nil
	v659 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v659, instance, (`expected {v658}, got {typeof(instance)}`))
			end

			if instance:IsA(v658) then
				return __Cause.ok()
			end

			return __Cause.err(v659, instance, (`expected {v658}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v658, p[v659])
		end
	}
	return (setmetatable(v659, __Type))
end

local v659 = "UGCValidationService"

function GreenTea.UGCValidationService()
	local v660 = nil
	v660 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v660, instance, (`expected {v659}, got {typeof(instance)}`))
			end

			if instance:IsA(v659) then
				return __Cause.ok()
			end

			return __Cause.err(v660, instance, (`expected {v659}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v659, p[v660])
		end
	}
	return (setmetatable(v660, __Type))
end

local v660 = "UIBase"

function GreenTea.UIBase()
	local v661 = nil
	v661 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v661, instance, (`expected {v660}, got {typeof(instance)}`))
			end

			if instance:IsA(v660) then
				return __Cause.ok()
			end

			return __Cause.err(v661, instance, (`expected {v660}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v660, p[v661])
		end
	}
	return (setmetatable(v661, __Type))
end

local v661 = "UIComponent"

function GreenTea.UIComponent()
	local v662 = nil
	v662 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v662, instance, (`expected {v661}, got {typeof(instance)}`))
			end

			if instance:IsA(v661) then
				return __Cause.ok()
			end

			return __Cause.err(v662, instance, (`expected {v661}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v661, p[v662])
		end
	}
	return (setmetatable(v662, __Type))
end

local v662 = "UIConstraint"

function GreenTea.UIConstraint()
	local v663 = nil
	v663 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v663, instance, (`expected {v662}, got {typeof(instance)}`))
			end

			if instance:IsA(v662) then
				return __Cause.ok()
			end

			return __Cause.err(v663, instance, (`expected {v662}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v662, p[v663])
		end
	}
	return (setmetatable(v663, __Type))
end

local v663 = "UIAspectRatioConstraint"

function GreenTea.UIAspectRatioConstraint()
	local v664 = nil
	v664 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v664, instance, (`expected {v663}, got {typeof(instance)}`))
			end

			if instance:IsA(v663) then
				return __Cause.ok()
			end

			return __Cause.err(v664, instance, (`expected {v663}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v663, p[v664])
		end
	}
	return (setmetatable(v664, __Type))
end

local v664 = "UISizeConstraint"

function GreenTea.UISizeConstraint()
	local v665 = nil
	v665 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v665, instance, (`expected {v664}, got {typeof(instance)}`))
			end

			if instance:IsA(v664) then
				return __Cause.ok()
			end

			return __Cause.err(v665, instance, (`expected {v664}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v664, p[v665])
		end
	}
	return (setmetatable(v665, __Type))
end

local v665 = "UITextSizeConstraint"

function GreenTea.UITextSizeConstraint()
	local v666 = nil
	v666 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v666, instance, (`expected {v665}, got {typeof(instance)}`))
			end

			if instance:IsA(v665) then
				return __Cause.ok()
			end

			return __Cause.err(v666, instance, (`expected {v665}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v665, p[v666])
		end
	}
	return (setmetatable(v666, __Type))
end

local v666 = "UICorner"

function GreenTea.UICorner()
	local v667 = nil
	v667 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v667, instance, (`expected {v666}, got {typeof(instance)}`))
			end

			if instance:IsA(v666) then
				return __Cause.ok()
			end

			return __Cause.err(v667, instance, (`expected {v666}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v666, p[v667])
		end
	}
	return (setmetatable(v667, __Type))
end

local v667 = "UIFlexItem"

function GreenTea.UIFlexItem()
	local v668 = nil
	v668 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v668, instance, (`expected {v667}, got {typeof(instance)}`))
			end

			if instance:IsA(v667) then
				return __Cause.ok()
			end

			return __Cause.err(v668, instance, (`expected {v667}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v667, p[v668])
		end
	}
	return (setmetatable(v668, __Type))
end

local v668 = "UIGradient"

function GreenTea.UIGradient()
	local v669 = nil
	v669 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v669, instance, (`expected {v668}, got {typeof(instance)}`))
			end

			if instance:IsA(v668) then
				return __Cause.ok()
			end

			return __Cause.err(v669, instance, (`expected {v668}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v668, p[v669])
		end
	}
	return (setmetatable(v669, __Type))
end

local v669 = "UILayout"

function GreenTea.UILayout()
	local v670 = nil
	v670 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v670, instance, (`expected {v669}, got {typeof(instance)}`))
			end

			if instance:IsA(v669) then
				return __Cause.ok()
			end

			return __Cause.err(v670, instance, (`expected {v669}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v669, p[v670])
		end
	}
	return (setmetatable(v670, __Type))
end

local v670 = "UIGridStyleLayout"

function GreenTea.UIGridStyleLayout()
	local v671 = nil
	v671 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v671, instance, (`expected {v670}, got {typeof(instance)}`))
			end

			if instance:IsA(v670) then
				return __Cause.ok()
			end

			return __Cause.err(v671, instance, (`expected {v670}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v670, p[v671])
		end
	}
	return (setmetatable(v671, __Type))
end

local v671 = "UIGridLayout"

function GreenTea.UIGridLayout()
	local v672 = nil
	v672 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v672, instance, (`expected {v671}, got {typeof(instance)}`))
			end

			if instance:IsA(v671) then
				return __Cause.ok()
			end

			return __Cause.err(v672, instance, (`expected {v671}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v671, p[v672])
		end
	}
	return (setmetatable(v672, __Type))
end

local v672 = "UIListLayout"

function GreenTea.UIListLayout()
	local v673 = nil
	v673 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v673, instance, (`expected {v672}, got {typeof(instance)}`))
			end

			if instance:IsA(v672) then
				return __Cause.ok()
			end

			return __Cause.err(v673, instance, (`expected {v672}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v672, p[v673])
		end
	}
	return (setmetatable(v673, __Type))
end

local v673 = "UIPageLayout"

function GreenTea.UIPageLayout()
	local v674 = nil
	v674 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v674, instance, (`expected {v673}, got {typeof(instance)}`))
			end

			if instance:IsA(v673) then
				return __Cause.ok()
			end

			return __Cause.err(v674, instance, (`expected {v673}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v673, p[v674])
		end
	}
	return (setmetatable(v674, __Type))
end

local v674 = "UITableLayout"

function GreenTea.UITableLayout()
	local v675 = nil
	v675 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v675, instance, (`expected {v674}, got {typeof(instance)}`))
			end

			if instance:IsA(v674) then
				return __Cause.ok()
			end

			return __Cause.err(v675, instance, (`expected {v674}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v674, p[v675])
		end
	}
	return (setmetatable(v675, __Type))
end

local v675 = "UIPadding"

function GreenTea.UIPadding()
	local v676 = nil
	v676 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v676, instance, (`expected {v675}, got {typeof(instance)}`))
			end

			if instance:IsA(v675) then
				return __Cause.ok()
			end

			return __Cause.err(v676, instance, (`expected {v675}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v675, p[v676])
		end
	}
	return (setmetatable(v676, __Type))
end

local v676 = "UIScale"

function GreenTea.UIScale()
	local v677 = nil
	v677 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v677, instance, (`expected {v676}, got {typeof(instance)}`))
			end

			if instance:IsA(v676) then
				return __Cause.ok()
			end

			return __Cause.err(v677, instance, (`expected {v676}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v676, p[v677])
		end
	}
	return (setmetatable(v677, __Type))
end

local v677 = "UIStroke"

function GreenTea.UIStroke()
	local v678 = nil
	v678 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v678, instance, (`expected {v677}, got {typeof(instance)}`))
			end

			if instance:IsA(v677) then
				return __Cause.ok()
			end

			return __Cause.err(v678, instance, (`expected {v677}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v677, p[v678])
		end
	}
	return (setmetatable(v678, __Type))
end

local v678 = "UnvalidatedAssetService"

function GreenTea.UnvalidatedAssetService()
	local v679 = nil
	v679 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v679, instance, (`expected {v678}, got {typeof(instance)}`))
			end

			if instance:IsA(v678) then
				return __Cause.ok()
			end

			return __Cause.err(v679, instance, (`expected {v678}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v678, p[v679])
		end
	}
	return (setmetatable(v679, __Type))
end

local v679 = "UserGameSettings"

function GreenTea.UserGameSettings()
	local v680 = nil
	v680 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v680, instance, (`expected {v679}, got {typeof(instance)}`))
			end

			if instance:IsA(v679) then
				return __Cause.ok()
			end

			return __Cause.err(v680, instance, (`expected {v679}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v679, p[v680])
		end
	}
	return (setmetatable(v680, __Type))
end

local v680 = "UserInputService"

function GreenTea.UserInputService()
	local v681 = nil
	v681 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v681, instance, (`expected {v680}, got {typeof(instance)}`))
			end

			if instance:IsA(v680) then
				return __Cause.ok()
			end

			return __Cause.err(v681, instance, (`expected {v680}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v680, p[v681])
		end
	}
	return (setmetatable(v681, __Type))
end

local v681 = "UserService"

function GreenTea.UserService()
	local v682 = nil
	v682 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v682, instance, (`expected {v681}, got {typeof(instance)}`))
			end

			if instance:IsA(v681) then
				return __Cause.ok()
			end

			return __Cause.err(v682, instance, (`expected {v681}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v681, p[v682])
		end
	}
	return (setmetatable(v682, __Type))
end

local v682 = "VRService"

function GreenTea.VRService()
	local v683 = nil
	v683 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v683, instance, (`expected {v682}, got {typeof(instance)}`))
			end

			if instance:IsA(v682) then
				return __Cause.ok()
			end

			return __Cause.err(v683, instance, (`expected {v682}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v682, p[v683])
		end
	}
	return (setmetatable(v683, __Type))
end

local v683 = "VRStatusService"

function GreenTea.VRStatusService()
	local v684 = nil
	v684 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v684, instance, (`expected {v683}, got {typeof(instance)}`))
			end

			if instance:IsA(v683) then
				return __Cause.ok()
			end

			return __Cause.err(v684, instance, (`expected {v683}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v683, p[v684])
		end
	}
	return (setmetatable(v684, __Type))
end

local v684 = "ValueBase"

function GreenTea.ValueBase()
	local v685 = nil
	v685 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v685, instance, (`expected {v684}, got {typeof(instance)}`))
			end

			if instance:IsA(v684) then
				return __Cause.ok()
			end

			return __Cause.err(v685, instance, (`expected {v684}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v684, p[v685])
		end
	}
	return (setmetatable(v685, __Type))
end

local v685 = "BinaryStringValue"

function GreenTea.BinaryStringValue()
	local v686 = nil
	v686 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v686, instance, (`expected {v685}, got {typeof(instance)}`))
			end

			if instance:IsA(v685) then
				return __Cause.ok()
			end

			return __Cause.err(v686, instance, (`expected {v685}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v685, p[v686])
		end
	}
	return (setmetatable(v686, __Type))
end

local v686 = "BoolValue"

function GreenTea.BoolValue()
	local v687 = nil
	v687 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v687, instance, (`expected {v686}, got {typeof(instance)}`))
			end

			if instance:IsA(v686) then
				return __Cause.ok()
			end

			return __Cause.err(v687, instance, (`expected {v686}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v686, p[v687])
		end
	}
	return (setmetatable(v687, __Type))
end

local v687 = "BrickColorValue"

function GreenTea.BrickColorValue()
	local v688 = nil
	v688 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v688, instance, (`expected {v687}, got {typeof(instance)}`))
			end

			if instance:IsA(v687) then
				return __Cause.ok()
			end

			return __Cause.err(v688, instance, (`expected {v687}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v687, p[v688])
		end
	}
	return (setmetatable(v688, __Type))
end

local v688 = "CFrameValue"

function GreenTea.CFrameValue()
	local v689 = nil
	v689 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v689, instance, (`expected {v688}, got {typeof(instance)}`))
			end

			if instance:IsA(v688) then
				return __Cause.ok()
			end

			return __Cause.err(v689, instance, (`expected {v688}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v688, p[v689])
		end
	}
	return (setmetatable(v689, __Type))
end

local v689 = "Color3Value"

function GreenTea.Color3Value()
	local v690 = nil
	v690 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v690, instance, (`expected {v689}, got {typeof(instance)}`))
			end

			if instance:IsA(v689) then
				return __Cause.ok()
			end

			return __Cause.err(v690, instance, (`expected {v689}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v689, p[v690])
		end
	}
	return (setmetatable(v690, __Type))
end

local v690 = "DoubleConstrainedValue"

function GreenTea.DoubleConstrainedValue()
	local v691 = nil
	v691 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v691, instance, (`expected {v690}, got {typeof(instance)}`))
			end

			if instance:IsA(v690) then
				return __Cause.ok()
			end

			return __Cause.err(v691, instance, (`expected {v690}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v690, p[v691])
		end
	}
	return (setmetatable(v691, __Type))
end

local v691 = "IntConstrainedValue"

function GreenTea.IntConstrainedValue()
	local v692 = nil
	v692 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v692, instance, (`expected {v691}, got {typeof(instance)}`))
			end

			if instance:IsA(v691) then
				return __Cause.ok()
			end

			return __Cause.err(v692, instance, (`expected {v691}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v691, p[v692])
		end
	}
	return (setmetatable(v692, __Type))
end

local v692 = "IntValue"

function GreenTea.IntValue()
	local v693 = nil
	v693 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v693, instance, (`expected {v692}, got {typeof(instance)}`))
			end

			if instance:IsA(v692) then
				return __Cause.ok()
			end

			return __Cause.err(v693, instance, (`expected {v692}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v692, p[v693])
		end
	}
	return (setmetatable(v693, __Type))
end

local v693 = "NumberValue"

function GreenTea.NumberValue()
	local v694 = nil
	v694 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v694, instance, (`expected {v693}, got {typeof(instance)}`))
			end

			if instance:IsA(v693) then
				return __Cause.ok()
			end

			return __Cause.err(v694, instance, (`expected {v693}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v693, p[v694])
		end
	}
	return (setmetatable(v694, __Type))
end

local v694 = "ObjectValue"

function GreenTea.ObjectValue()
	local v695 = nil
	v695 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v695, instance, (`expected {v694}, got {typeof(instance)}`))
			end

			if instance:IsA(v694) then
				return __Cause.ok()
			end

			return __Cause.err(v695, instance, (`expected {v694}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v694, p[v695])
		end
	}
	return (setmetatable(v695, __Type))
end

local v695 = "RayValue"

function GreenTea.RayValue()
	local v696 = nil
	v696 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v696, instance, (`expected {v695}, got {typeof(instance)}`))
			end

			if instance:IsA(v695) then
				return __Cause.ok()
			end

			return __Cause.err(v696, instance, (`expected {v695}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v695, p[v696])
		end
	}
	return (setmetatable(v696, __Type))
end

local v696 = "StringValue"

function GreenTea.StringValue()
	local v697 = nil
	v697 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v697, instance, (`expected {v696}, got {typeof(instance)}`))
			end

			if instance:IsA(v696) then
				return __Cause.ok()
			end

			return __Cause.err(v697, instance, (`expected {v696}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v696, p[v697])
		end
	}
	return (setmetatable(v697, __Type))
end

local v697 = "Vector3Value"

function GreenTea.Vector3Value()
	local v698 = nil
	v698 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v698, instance, (`expected {v697}, got {typeof(instance)}`))
			end

			if instance:IsA(v697) then
				return __Cause.ok()
			end

			return __Cause.err(v698, instance, (`expected {v697}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v697, p[v698])
		end
	}
	return (setmetatable(v698, __Type))
end

local v698 = "Vector3Curve"

function GreenTea.Vector3Curve()
	local v699 = nil
	v699 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v699, instance, (`expected {v698}, got {typeof(instance)}`))
			end

			if instance:IsA(v698) then
				return __Cause.ok()
			end

			return __Cause.err(v699, instance, (`expected {v698}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v698, p[v699])
		end
	}
	return (setmetatable(v699, __Type))
end

local v699 = "VersionControlService"

function GreenTea.VersionControlService()
	local v700 = nil
	v700 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v700, instance, (`expected {v699}, got {typeof(instance)}`))
			end

			if instance:IsA(v699) then
				return __Cause.ok()
			end

			return __Cause.err(v700, instance, (`expected {v699}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v699, p[v700])
		end
	}
	return (setmetatable(v700, __Type))
end

local v700 = "VideoCaptureService"

function GreenTea.VideoCaptureService()
	local v701 = nil
	v701 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v701, instance, (`expected {v700}, got {typeof(instance)}`))
			end

			if instance:IsA(v700) then
				return __Cause.ok()
			end

			return __Cause.err(v701, instance, (`expected {v700}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v700, p[v701])
		end
	}
	return (setmetatable(v701, __Type))
end

local v701 = "VideoService"

function GreenTea.VideoService()
	local v702 = nil
	v702 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v702, instance, (`expected {v701}, got {typeof(instance)}`))
			end

			if instance:IsA(v701) then
				return __Cause.ok()
			end

			return __Cause.err(v702, instance, (`expected {v701}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v701, p[v702])
		end
	}
	return (setmetatable(v702, __Type))
end

local v702 = "VirtualInputManager"

function GreenTea.VirtualInputManager()
	local v703 = nil
	v703 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v703, instance, (`expected {v702}, got {typeof(instance)}`))
			end

			if instance:IsA(v702) then
				return __Cause.ok()
			end

			return __Cause.err(v703, instance, (`expected {v702}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v702, p[v703])
		end
	}
	return (setmetatable(v703, __Type))
end

local v703 = "VirtualUser"

function GreenTea.VirtualUser()
	local v704 = nil
	v704 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v704, instance, (`expected {v703}, got {typeof(instance)}`))
			end

			if instance:IsA(v703) then
				return __Cause.ok()
			end

			return __Cause.err(v704, instance, (`expected {v703}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v703, p[v704])
		end
	}
	return (setmetatable(v704, __Type))
end

local v704 = "VisibilityCheckDispatcher"

function GreenTea.VisibilityCheckDispatcher()
	local v705 = nil
	v705 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v705, instance, (`expected {v704}, got {typeof(instance)}`))
			end

			if instance:IsA(v704) then
				return __Cause.ok()
			end

			return __Cause.err(v705, instance, (`expected {v704}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v704, p[v705])
		end
	}
	return (setmetatable(v705, __Type))
end

local v705 = "Visit"

function GreenTea.Visit()
	local v706 = nil
	v706 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v706, instance, (`expected {v705}, got {typeof(instance)}`))
			end

			if instance:IsA(v705) then
				return __Cause.ok()
			end

			return __Cause.err(v706, instance, (`expected {v705}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v705, p[v706])
		end
	}
	return (setmetatable(v706, __Type))
end

local v706 = "VoiceChatInternal"

function GreenTea.VoiceChatInternal()
	local v707 = nil
	v707 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v707, instance, (`expected {v706}, got {typeof(instance)}`))
			end

			if instance:IsA(v706) then
				return __Cause.ok()
			end

			return __Cause.err(v707, instance, (`expected {v706}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v706, p[v707])
		end
	}
	return (setmetatable(v707, __Type))
end

local v707 = "VoiceChatService"

function GreenTea.VoiceChatService()
	local v708 = nil
	v708 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v708, instance, (`expected {v707}, got {typeof(instance)}`))
			end

			if instance:IsA(v707) then
				return __Cause.ok()
			end

			return __Cause.err(v708, instance, (`expected {v707}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v707, p[v708])
		end
	}
	return (setmetatable(v708, __Type))
end

local v708 = "WeldConstraint"

function GreenTea.WeldConstraint()
	local v709 = nil
	v709 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v709, instance, (`expected {v708}, got {typeof(instance)}`))
			end

			if instance:IsA(v708) then
				return __Cause.ok()
			end

			return __Cause.err(v709, instance, (`expected {v708}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v708, p[v709])
		end
	}
	return (setmetatable(v709, __Type))
end

local v709 = "Wire"

function GreenTea.Wire()
	local v710 = nil
	v710 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v710, instance, (`expected {v709}, got {typeof(instance)}`))
			end

			if instance:IsA(v709) then
				return __Cause.ok()
			end

			return __Cause.err(v710, instance, (`expected {v709}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v709, p[v710])
		end
	}
	return (setmetatable(v710, __Type))
end

local v710 = "PathWaypoint"

function GreenTea.PathWaypoint()
	local v711 = nil
	v711 = {
		kind = "InstanceIsA",
		class = class,
		_matches = function(instance)
			if typeof(instance) ~= "Instance" then
				return __Cause.err(v711, instance, (`expected {v710}, got {typeof(instance)}`))
			end

			if instance:IsA(v710) then
				return __Cause.ok()
			end

			return __Cause.err(v711, instance, (`expected {v710}, got {instance.ClassName}`))
		end,
		_format = function(p, _: number, _)
			return __highlightWrap(v710, p[v711])
		end
	}
	return (setmetatable(v711, __Type))
end

return GreenTea