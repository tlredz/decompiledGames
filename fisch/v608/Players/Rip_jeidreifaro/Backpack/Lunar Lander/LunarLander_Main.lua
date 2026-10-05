local function Create_PrivImpl(className)
	if type(className) ~= "string" then
		error("Argument of Create must be a string", 2)
	end

	return function(options)
		local instance = Instance.new(className)
		local v = nil

		for k, v2 in pairs(options or {}) do
			if type(k) == "string" then
				instance[k] = v2
			elseif type(k) == "number" then
				if type(v2) ~= "userdata" then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: " .. type(v2), 2)
				end

				v2.Parent = instance
			elseif type(k) == "table" and k.__eventname then
				if type(v2) ~= "function" then
					error(
						"Bad entry in Create body: Key `[Create.E'" .. k.__eventname .. "']` must have a function value\n\t\t\t\t\t       got: " .. tostring(v2),
						2
					)
				end

				instance[k.__eventname]:connect(v2)
			elseif k == Create then
				if type(v2) == "function" then
					if v then
						error("Bad entry in Create body: Only one constructor function is allowed", 2)
					end
				else
					error([[
Bad entry in Create body: Key `[Create]` should be paired with a constructor function, 
					       got: ]] .. tostring(v2), 2)
				end

				v = v2
			else
				error("Bad entry (" .. tostring(k) .. " => " .. tostring(v2) .. ") in Create body", 2)
			end
		end

		if v then
			v(instance)
		end

		return instance
	end
end

Create = setmetatable({}, {
	__call = function(_, ...)
		local v = ...

		if type(v) ~= "string" then
			error("Argument of Create must be a string", 2)
		end

		return function(options)
			local instance = Instance.new(v)
			local v2 = nil

			for k, v3 in pairs(options or {}) do
				if type(k) == "string" then
					instance[k] = v3
				elseif type(k) == "number" then
					if type(v3) ~= "userdata" then
						error(
							"Bad entry in Create body: Numeric keys must be paired with children, got a: " .. type(v3),
							2
						)
					end

					v3.Parent = instance
				elseif type(k) == "table" and k.__eventname then
					if type(v3) ~= "function" then
						error(
							"Bad entry in Create body: Key `[Create.E'" .. k.__eventname .. "']` must have a function value\n\t\t\t\t\t       got: " .. tostring(v3),
							2
						)
					end

					instance[k.__eventname]:connect(v3)
				elseif k == Create then
					if type(v3) == "function" then
						if v2 then
							error("Bad entry in Create body: Only one constructor function is allowed", 2)
						end
					else
						error([[
Bad entry in Create body: Key `[Create]` should be paired with a constructor function, 
					       got: ]] .. tostring(v3), 2)
					end

					v2 = v3
				else
					error("Bad entry (" .. tostring(k) .. " => " .. tostring(v3) .. ") in Create body", 2)
				end
			end

			if v2 then
				v2(instance)
			end

			return instance
		end
	end
})

function Create.E(eventname)
	return {
		__eventname = eventname
	}
end

local v = {
	Model_Rock1 = {
		Name = "Rock1",
		Image = "http://www.roblox.com/asset/?id=84811980",
		{ 0.748, 0.007 },
		{ 0.902, 0.05 },
		{ 0.988, 0.183 },
		{ 0.98, 0.335 },
		{ 0.838, 0.535 },
		{ 0.52, 0.815 },
		{ 0.195, 0.978 },
		{ 0.083, 0.95 },
		{ 0.01, 0.815 },
		{ 0.058, 0.642 },
		{ 0.193, 0.453 },
		{ 0.512, 0.117 }
	},
	Model_Rock2 = {
		Name = "Rock2",
		Image = "http://www.roblox.com/asset/?id=84811991",
		{ 0.065, 0.328 },
		{ 0.215, 0.212 },
		{ 0.373, 0.077 },
		{ 0.552, 0.01 },
		{ 0.772, 0.028 },
		{ 0.92, 0.1 },
		{ 0.99, 0.215 },
		{ 0.98, 0.352 },
		{ 0.95, 0.482 },
		{ 0.848, 0.662 },
		{ 0.767, 0.833 },
		{ 0.59, 0.953 },
		{ 0.415, 0.968 },
		{ 0.297, 0.892 },
		{ 0.23, 0.83 },
		{ 0.147, 0.81 },
		{ 0.03, 0.675 },
		{ 0.015, 0.522 }
	},
	Model_Rock3 = {
		Name = "Rock3",
		Image = "http://www.roblox.com/asset/?id=84812013",
		{ 0.125, 0.265 },
		{ 0.33, 0.087 },
		{ 0.645, 0.035 },
		{ 0.873, 0.128 },
		{ 0.912, 0.175 },
		{ 0.925, 0.41 },
		{ 0.993, 0.698 },
		{ 0.988, 0.825 },
		{ 0.9, 0.925 },
		{ 0.743, 0.983 },
		{ 0.482, 0.983 },
		{ 0.203, 0.917 },
		{ 0.06, 0.815 },
		{ 0.003, 0.68 },
		{ 0.015, 0.532 },
		{ 0.06, 0.383 }
	},
	Model_Rock4 = {
		Name = "Rock4",
		Image = "http://www.roblox.com/asset/?id=84812033",
		{ 0.185, 0.25 },
		{ 0.335, 0.1 },
		{ 0.412, 0.063 },
		{ 0.555, 0.01 },
		{ 0.748, 0.03 },
		{ 0.892, 0.19 },
		{ 0.948, 0.37 },
		{ 0.927, 0.568 },
		{ 0.77, 0.823 },
		{ 0.655, 0.93 },
		{ 0.487, 0.973 },
		{ 0.265, 0.958 },
		{ 0.108, 0.838 },
		{ 0.028, 0.677 },
		{ 0.048, 0.487 }
	},
	Model_Rock5 = {
		Name = "Rock5",
		Image = "http://www.roblox.com/asset/?id=84812047",
		{ 0.517, 0.095 },
		{ 0.795, 0.328 },
		{ 0.99, 0.637 },
		{ 0.995, 0.78 },
		{ 0.95, 0.927 },
		{ 0.833, 0.97 },
		{ 0.635, 0.95 },
		{ 0.388, 0.813 },
		{ 0.185, 0.652 },
		{ 0.028, 0.417 },
		{ 0.015, 0.282 },
		{ 0.022, 0.145 },
		{ 0.09, 0.043 },
		{ 0.177, 0.003 },
		{ 0.375, 0.013 }
	}
}
local v2 = {
	Level1 = {
		{
			{ 0.0029, 0.16 },
			{ 0.1821, 0.1233 },
			{ 0.3013, 0.2256 },
			{ 0.3187, 0.3178 },
			{ 0.2529, 0.4022 },
			{ 0.0063, 0.3911 }
		},
		{
			{ 0.2512, 0.4033 },
			{ 0.2429, 0.4878 },
			{ 0.2129, 0.6089 },
			{ 0.0429, 0.4167 }
		},
		{
			{ 0.2179, 0.5922 },
			{ 0.2571, 0.7322 },
			{ 0.0921, 0.7278 }
		},
		{
			{ 0.2562, 0.7322 },
			{ 0.4479, 0.7922 },
			{ 0.3121, 0.89 }
		},
		{
			{ 0.4496, 0.7944 },
			{ 0.5938, 0.6922 },
			{ 0.5938, 0.9167 }
		},
		{
			{ 0.5879, 0.6978 },
			{ 0.6288, 0.6289 },
			{ 0.7021, 0.6144 },
			{ 0.7754, 0.7222 },
			{ 0.6754, 0.9256 }
		},
		{
			{ 0.7771, 0.7244 },
			{ 0.8812, 0.6544 },
			{ 0.8854, 0.8478 }
		},
		{
			{ 0.8554, 0.6933 },
			{ 0.8996, 0.42 },
			{ 0.9654, 0.6189 }
		},
		{
			{ 0.9046, 0.4733 },
			{ 0.7996, 0.2233 },
			{ 0.9429, 0.2989 }
		},
		{
			{ 0.8129, 0.2578 },
			{ 0.7204, 0.34 },
			{ 0.5904, 0.4 },
			{ 0.4571, 0.3422 },
			{ 0.4688, 0.2067 },
			{ 0.5554, 0.1378 },
			{ 0.6671, 0.1744 }
		},
		{
			{ 0.6679, 0.1744 },
			{ 0.8296, 0.1311 },
			{ 0.9971, 0.1789 },
			{ 0.8329, 0.2522 }
		}
	},
	Level2 = {
		{
			{ 0.0037, 0.0811 },
			{ 0.2188, 0.0478 },
			{ 0.3063, 0.0733 },
			{ 0.3362, 0.2844 }
		},
		{
			{ 0.3196, 0.2333 },
			{ 0.4404, 0.3611 },
			{ 0.2746, 0.4233 }
		},
		{
			{ 0.3854, 0.3389 },
			{ 0.5863, 0.3844 },
			{ 0.6821, 0.5011 },
			{ 0.6679, 0.6611 }
		},
		{
			{ 0.6646, 0.5944 },
			{ 0.7154, 0.7544 },
			{ 0.5737, 0.72 }
		},
		{
			{ 0.6787, 0.7111 },
			{ 0.8271, 0.7811 },
			{ 0.7279, 0.8444 }
		},
		{
			{ 0.7871, 0.7733 },
			{ 0.8388, 0.7533 },
			{ 0.8829, 0.7567 },
			{ 0.8496, 0.83 }
		},
		{
			{ 0.8529, 0.7822 },
			{ 0.8612, 0.7467 },
			{ 0.8854, 0.7389 },
			{ 0.8962, 0.7944 }
		},
		{
			{ 0.8562, 0.5856 },
			{ 0.8779, 0.76 },
			{ 0.9121, 0.4044 }
		},
		{
			{ 0.7146, 0.3378 },
			{ 0.8779, 0.3344 },
			{ 0.6004, 0.2267 }
		},
		{
			{ 0.4229, 0.1478 },
			{ 0.4846, 0.2356 },
			{ 0.6288, 0.2533 },
			{ 0.9979, 0.1456 },
			{ 0.7346, 0.0822 },
			{ 0.4537, 0.1089 }
		}
	},
	Level3 = {
		{
			{ 0.0013, 0.1028 },
			{ 0.1729, 0.1483 },
			{ 0.2046, 0.2906 },
			{ 0.1854, 0.4728 },
			{ 0.1354, 0.6194 }
		},
		{
			{ 0.1371, 0.595 },
			{ 0.1271, 0.7817 },
			{ 0.0254, 0.6572 }
		},
		{
			{ 0.1121, 0.7406 },
			{ 0.2321, 0.8683 },
			{ 0.0996, 0.9039 }
		},
		{
			{ 0.2004, 0.8639 },
			{ 0.3388, 0.785 },
			{ 0.4612, 0.8406 }
		},
		{
			{ 0.4238, 0.8361 },
			{ 0.5096, 0.8083 },
			{ 0.4813, 0.8894 }
		},
		{
			{ 0.4846, 0.8572 },
			{ 0.5246, 0.6183 },
			{ 0.5837, 0.5694 },
			{ 0.6704, 0.5683 },
			{ 0.7779, 0.6183 }
		},
		{
			{ 0.7638, 0.6317 },
			{ 0.7204, 0.3839 },
			{ 0.8512, 0.5172 }
		},
		{
			{ 0.7488, 0.4383 },
			{ 0.5837, 0.3083 },
			{ 0.7113, 0.2372 }
		},
		{
			{ 0.6496, 0.315 },
			{ 0.4562, 0.3506 },
			{ 0.5363, 0.1939 }
		},
		{
			{ 0.4113, 0.1328 },
			{ 0.4946, 0.3417 },
			{ 0.4796, 0.5394 },
			{ 0.4046, 0.6683 },
			{ 0.3196, 0.6372 },
			{ 0.2971, 0.4839 },
			{ 0.3287, 0.2939 }
		},
		{
			{ 0.4113, 0.1339 },
			{ 0.6763, 0.1794 },
			{ 0.5096, 0.3083 }
		},
		{
			{ 0.6454, 0.1917 },
			{ 0.9096, 0.1306 },
			{ 0.9979, 0.1506 },
			{ 0.8712, 0.275 }
		}
	},
	Level4 = {
		{
			{ 0.0013, 0.1028 },
			{ 0.1729, 0.1483 },
			{ 0.2046, 0.2906 },
			{ 0.1854, 0.4728 },
			{ 0.1354, 0.6194 }
		},
		{
			{ 0.1371, 0.595 },
			{ 0.1271, 0.7817 },
			{ 0.0254, 0.6572 }
		},
		{
			{ 0.1121, 0.7406 },
			{ 0.2321, 0.8683 },
			{ 0.0996, 0.9039 }
		},
		{
			{ 0.2004, 0.8639 },
			{ 0.3388, 0.785 },
			{ 0.4612, 0.8406 }
		},
		{
			{ 0.4238, 0.8361 },
			{ 0.5096, 0.8083 },
			{ 0.4813, 0.8894 }
		},
		{
			{ 0.4846, 0.8572 },
			{ 0.5246, 0.6183 },
			{ 0.5837, 0.5694 },
			{ 0.6704, 0.5683 },
			{ 0.7779, 0.6183 }
		},
		{
			{ 0.7638, 0.6317 },
			{ 0.7204, 0.3839 },
			{ 0.8512, 0.5172 }
		},
		{
			{ 0.7488, 0.4383 },
			{ 0.5837, 0.3083 },
			{ 0.7113, 0.2372 }
		},
		{
			{ 0.6496, 0.315 },
			{ 0.4562, 0.3506 },
			{ 0.5363, 0.1939 }
		},
		{
			{ 0.4113, 0.1328 },
			{ 0.4946, 0.3417 },
			{ 0.4796, 0.5394 },
			{ 0.4046, 0.6683 },
			{ 0.3196, 0.6372 },
			{ 0.2971, 0.4839 },
			{ 0.3287, 0.2939 }
		},
		{
			{ 0.4113, 0.1339 },
			{ 0.6763, 0.1794 },
			{ 0.5096, 0.3083 }
		},
		{
			{ 0.6454, 0.1917 },
			{ 0.9096, 0.1306 },
			{ 0.9979, 0.1506 },
			{ 0.8712, 0.275 }
		},
		{
			{ 0.3329, 0.7017 },
			{ 0.4071, 0.7172 },
			{ 0.4046, 0.7361 },
			{ 0.3312, 0.7183 }
		}
	},
	Level5 = {
		{
			{ 0.0021, 0.0728 },
			{ 0.1279, 0.1083 },
			{ 0.1646, 0.2228 },
			{ 0.1479, 0.3206 },
			{ 0.0862, 0.4083 }
		},
		{
			{ 0.0938, 0.3839 },
			{ 0.1238, 0.565 },
			{ 0.0179, 0.4906 }
		},
		{
			{ 0.1071, 0.5472 },
			{ 0.1729, 0.5617 },
			{ 0.2121, 0.6872 },
			{ 0.1479, 0.8317 }
		},
		{
			{ 0.1621, 0.785 },
			{ 0.1487, 0.955 },
			{ 0.0887, 0.8294 }
		},
		{
			{ 0.1354, 0.8994 },
			{ 0.1904, 0.9806 },
			{ 0.1088, 0.9739 }
		},
		{
			{ 0.1688, 0.9772 },
			{ 0.2537, 0.9106 },
			{ 0.2479, 0.9772 }
		},
		{
			{ 0.2463, 0.955 },
			{ 0.2221, 0.8706 },
			{ 0.2788, 0.6928 }
		},
		{
			{ 0.2621, 0.7583 },
			{ 0.2754, 0.615 },
			{ 0.3479, 0.5772 },
			{ 0.4279, 0.6594 }
		},
		{
			{ 0.3937, 0.6517 },
			{ 0.4663, 0.5539 },
			{ 0.5396, 0.5617 },
			{ 0.5546, 0.8606 }
		},
		{
			{ 0.5337, 0.8161 },
			{ 0.7321, 0.8383 },
			{ 0.6188, 0.9294 }
		},
		{
			{ 0.6763, 0.8517 },
			{ 0.8538, 0.7728 },
			{ 0.7763, 0.905 }
		},
		{
			{ 0.8046, 0.8106 },
			{ 0.9287, 0.635 },
			{ 0.9296, 0.8128 }
		},
		{
			{ 0.9196, 0.7006 },
			{ 0.9021, 0.5339 },
			{ 0.9596, 0.3261 },
			{ 0.9971, 0.2739 }
		},
		{
			{ 0.5879, 0.755 },
			{ 0.5871, 0.7761 },
			{ 0.7171, 0.7561 }
		},
		{
			{ 0.6388, 0.2128 },
			{ 0.7937, 0.405 },
			{ 0.8263, 0.5683 },
			{ 0.7846, 0.6628 },
			{ 0.6863, 0.7183 },
			{ 0.5863, 0.7161 },
			{ 0.5813, 0.4906 }
		},
		{
			{ 0.5804, 0.4872 },
			{ 0.6404, 0.2128 },
			{ 0.4704, 0.2128 },
			{ 0.5537, 0.3983 }
		},
		{
			{ 0.4521, 0.4028 },
			{ 0.5212, 0.2928 },
			{ 0.5537, 0.3961 }
		},
		{
			{ 0.1863, 0.345 },
			{ 0.1412, 0.4239 },
			{ 0.1554, 0.5039 },
			{ 0.2321, 0.4806 }
		},
		{
			{ 0.1821, 0.3517 },
			{ 0.2304, 0.4817 },
			{ 0.3329, 0.5083 },
			{ 0.4079, 0.475 },
			{ 0.4529, 0.4028 },
			{ 0.4713, 0.2128 },
			{ 0.2737, 0.105 }
		}
	},
	Level6 = {
		{
			{ 0.0037, 0.1228 },
			{ 0.2871, 0.1639 },
			{ 0.3821, 0.2539 },
			{ 0.3787, 0.3106 },
			{ 0.3454, 0.3928 },
			{ 0.2479, 0.4283 }
		},
		{
			{ 0.2721, 0.4083 },
			{ 0.1779, 0.5372 },
			{ 0.1821, 0.4017 }
		},
		{
			{ 0.1863, 0.4928 },
			{ 0.2037, 0.6861 },
			{ 0.0838, 0.5906 }
		},
		{
			{ 0.1812, 0.6294 },
			{ 0.2646, 0.7883 },
			{ 0.1412, 0.7539 }
		},
		{
			{ 0.2271, 0.7694 },
			{ 0.4437, 0.7206 },
			{ 0.3563, 0.8817 }
		},
		{
			{ 0.4004, 0.7517 },
			{ 0.4804, 0.6194 },
			{ 0.5496, 0.7506 }
		},
		{
			{ 0.5212, 0.7139 },
			{ 0.6054, 0.7406 },
			{ 0.5396, 0.8061 }
		},
		{
			{ 0.5687, 0.7539 },
			{ 0.6196, 0.6839 },
			{ 0.7221, 0.6817 }
		},
		{
			{ 0.6863, 0.7039 },
			{ 0.7196, 0.5661 },
			{ 0.7504, 0.6739 }
		},
		{
			{ 0.7146, 0.6094 },
			{ 0.7037, 0.4472 },
			{ 0.7763, 0.5361 }
		},
		{
			{ 0.7254, 0.485 },
			{ 0.5837, 0.4517 },
			{ 0.5521, 0.2972 },
			{ 0.6613, 0.2161 },
			{ 0.7771, 0.3228 }
		},
		{
			{ 0.6146, 0.4572 },
			{ 0.4929, 0.5039 },
			{ 0.3787, 0.4183 },
			{ 0.3979, 0.3639 }
		},
		{
			{ 0.4071, 0.2594 },
			{ 0.5504, 0.295 },
			{ 0.3996, 0.3594 }
		},
		{
			{ 0.3779, 0.4206 },
			{ 0.4921, 0.5028 },
			{ 0.4821, 0.565 }
		},
		{
			{ 0.4612, 0.5228 },
			{ 0.4804, 0.5794 },
			{ 0.4946, 0.4928 }
		},
		{
			{ 0.7588, 0.3228 },
			{ 0.9179, 0.3006 },
			{ 0.8354, 0.4006 }
		},
		{
			{ 0.8812, 0.3228 },
			{ 0.9971, 0.1894 },
			{ 0.9921, 0.3861 }
		}
	},
	Level7 = {
		{
			{ 0.0029, 0.0761 },
			{ 0.1154, 0.1117 },
			{ 0.2079, 0.215 },
			{ 0.2496, 0.3683 },
			{ 0.2296, 0.5283 }
		},
		{
			{ 0.2254, 0.5039 },
			{ 0.2371, 0.7139 },
			{ 0.1563, 0.7794 }
		},
		{
			{ 0.1821, 0.7383 },
			{ 0.1513, 0.895 },
			{ 0.0529, 0.7783 }
		},
		{
			{ 0.1354, 0.8661 },
			{ 0.3371, 0.9461 },
			{ 0.1871, 0.9661 }
		},
		{
			{ 0.3029, 0.9506 },
			{ 0.4854, 0.8161 },
			{ 0.4354, 0.9628 }
		},
		{
			{ 0.4604, 0.8672 },
			{ 0.4629, 0.6306 },
			{ 0.4954, 0.545 },
			{ 0.5863, 0.5494 }
		},
		{
			{ 0.5671, 0.5594 },
			{ 0.6062, 0.4872 },
			{ 0.6613, 0.4883 }
		},
		{
			{ 0.6563, 0.4994 },
			{ 0.6504, 0.4461 },
			{ 0.7004, 0.4761 }
		},
		{
			{ 0.6671, 0.4639 },
			{ 0.6296, 0.4639 },
			{ 0.5946, 0.3783 }
		},
		{
			{ 0.6254, 0.3883 },
			{ 0.4654, 0.4306 },
			{ 0.5279, 0.3217 }
		},
		{
			{ 0.5079, 0.4006 },
			{ 0.4254, 0.6506 },
			{ 0.2771, 0.7339 },
			{ 0.2637, 0.5328 }
		},
		{
			{ 0.4396, 0.6083 },
			{ 0.4346, 0.7828 },
			{ 0.3204, 0.8539 },
			{ 0.2321, 0.8006 },
			{ 0.2779, 0.7306 }
		},
		{
			{ 0.2637, 0.5317 },
			{ 0.2938, 0.3394 },
			{ 0.3696, 0.475 }
		},
		{
			{ 0.2863, 0.3917 },
			{ 0.2938, 0.2272 },
			{ 0.4788, 0.2661 }
		},
		{
			{ 0.4379, 0.2683 },
			{ 0.6721, 0.2339 },
			{ 0.5587, 0.3294 }
		},
		{
			{ 0.6713, 0.2328 },
			{ 0.9962, 0.2717 },
			{ 0.8104, 0.3961 }
		}
	},
	Level8 = {
		{
			{ 0.0021, 0.1139 },
			{ 0.1971, 0.1183 },
			{ 0.2712, 0.1739 },
			{ 0.2729, 0.4728 }
		},
		{
			{ 0.2671, 0.4228 },
			{ 0.3613, 0.6217 },
			{ 0.2171, 0.5772 }
		},
		{
			{ 0.3379, 0.6083 },
			{ 0.4113, 0.6106 },
			{ 0.4113, 0.7894 },
			{ 0.3654, 0.8694 }
		},
		{
			{ 0.3513, 0.8628 },
			{ 0.4946, 0.8628 },
			{ 0.4163, 0.9306 }
		},
		{
			{ 0.4338, 0.5161 },
			{ 0.4988, 0.5861 },
			{ 0.4829, 0.8739 },
			{ 0.4329, 0.7906 }
		},
		{
			{ 0.4104, 0.5739 },
			{ 0.3638, 0.5728 },
			{ 0.2954, 0.4217 },
			{ 0.2929, 0.1717 },
			{ 0.3921, 0.0872 },
			{ 0.4113, 0.4028 }
		},
		{
			{ 0.3921, 0.0861 },
			{ 0.5371, 0.0806 },
			{ 0.4696, 0.4039 },
			{ 0.4104, 0.4028 }
		},
		{
			{ 0.4871, 0.5894 },
			{ 0.5096, 0.5272 },
			{ 0.5421, 0.5839 }
		},
		{
			{ 0.5363, 0.5806 },
			{ 0.5721, 0.525 },
			{ 0.6138, 0.5861 }
		},
		{
			{ 0.5896, 0.5761 },
			{ 0.6679, 0.575 },
			{ 0.6671, 0.865 }
		},
		{
			{ 0.5329, 0.0806 },
			{ 0.6088, 0.4028 },
			{ 0.6887, 0.3983 },
			{ 0.7446, 0.1128 }
		},
		{
			{ 0.4629, 0.3872 },
			{ 0.5104, 0.4828 },
			{ 0.5437, 0.4183 }
		},
		{
			{ 0.5329, 0.4094 },
			{ 0.5704, 0.4839 },
			{ 0.6146, 0.3894 }
		},
		{
			{ 0.7462, 0.1117 },
			{ 0.7454, 0.7728 },
			{ 0.6896, 0.7694 },
			{ 0.6896, 0.3994 }
		},
		{
			{ 0.6554, 0.845 },
			{ 0.7829, 0.8461 },
			{ 0.7196, 0.925 }
		},
		{
			{ 0.7671, 0.8661 },
			{ 0.7671, 0.0828 },
			{ 0.9971, 0.0628 }
		}
	}
}

local function norm(p, p2)
	local v3 = math.sqrt(p * p + p2 * p2)
	return p / v3, p2 / v3
end

local function sub(p, p2, p3, p4)
	return p - p3, p2 - p4
end

local function add(p, p2, p3, p4)
	return p + p3, p2 + p4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function len(p, p2)
	return (math.sqrt(p * p + p2 * p2))
end

local function unit(p, p2)
	local v3 = len(p, p2) -- equivalent call inferred; original call site unknown
	return p / v3, p2 / v3
end

local function dot(p, p2, p3, p4)
	return p * p3 + p2 * p4
end

local function removeValue(list, p)
	for i = 1, #list do
		if list[i] ~= p then
			continue
		end

		table.remove(list, i)
		break
	end
end

local function waitForAny(...)
	local intValue = Instance.new("IntValue")
	local v3 = nil
	local connections = {}

	for k, v4 in pairs({ ... }) do
		local v5 = k
		connections[k] = v4:connect(function(...)
			v3 = { ... }
			intValue.Value = v5
		end)
	end

	while intValue.Value == 0 do
		intValue.Changed:wait()
	end

	for _, connection in pairs(connections) do
		connection:disconnect()
	end

	return intValue.Value, unpack(v3)
end

function InstanceModel(p, p2, p3, p4, p5, p6)
	local v3 = {
		Gui = Create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = p.Image or "",
			Position = UDim2.new(0, p2, 0, p3),
			Size = UDim2.new(0, p4, 0, p5)
		}),
		Name = p.Name or ""
	}

	if not p6 then
		return v3
	end

	local v4 = -1e999
	local v5 = 1e999
	local v6 = -1e999
	local v7 = 1e999
	local axis = {}

	local function AddAxisFromSeg(list, list2)
		local v9 = p2 + list[1] * p4
		local v10 = p3 + list[2] * p5
		local v11 = p2 + list2[1] * p4
		local v12 = p3 + list2[2] * p5

		if v4 < v9 then
			v4 = v9
		end

		if v9 < v5 then
			v5 = v9
		end

		if v6 < v10 then
			v6 = v10
		end

		if v10 < v7 then
			v7 = v10
		end

		local v14 = v11 - v9
		local v15 = v12 - v10
		local v16 = len(v14, v15) -- equivalent call inferred; original call site unknown
		local dirY = v14 / v16
		local dirX = -(v15 / v16)
		local v13 = {
			DirX = dirX,
			DirY = dirY
		}
		local min = 1e999
		local max = -1e999

		for i = 1, #p do
			local v21 = p[i]
			local v22 = p2 + v21[1] * p4
			local v23 = p3 + v21[2] * p5
			local v24 = v22 * dirX + v23 * dirY

			if v24 < min then
				min = v24
			end

			if max < v24 then
				max = v24
			end
		end

		v13.Min = min
		v13.Max = max
		axis[#axis + 1] = v13
	end

	v3.Axis = axis

	for i = 1, #p - 1 do
		AddAxisFromSeg(p[i], p[i + 1])
	end

	AddAxisFromSeg(p[#p], p[1])
	v3.CenterX = (v5 + v4) / 2
	v3.CenterY = (v7 + v6) / 2
	v3.RadiusSq = ((v4 - v5) / 2) ^ 2 + ((v6 - v7) / 2) ^ 2
	v3.Radius = math.sqrt(v3.RadiusSq)
	return v3
end

function CreateLevel_FromGui(parent)
	local v3 = {
		Terrain = {}
	}

	for _, child in pairs(parent:GetChildren()) do
		child:Destroy()
		local v4 = v[child.Name]

		if not v4 then
			continue
		end

		local position = child.Position
		local size = child.Size
		local v5 = InstanceModel(v4, position.X.Offset, position.Y.Offset, size.X.Offset, size.Y.Offset, true)
		v3.Terrain[#v3.Terrain + 1] = v5
		v5.Gui.Parent = parent
	end

	return v3
end

function CreateLevel_FromData(parent)
	local v3 = {
		Terrain = {}
	}

	for _, v4 in pairs(v2[parent.Parent.Name]) do
		local v5 = InstanceModel(v4, 0, 0, parent.Size.X.Offset, parent.Size.Y.Offset, true)
		v3.Terrain[#v3.Terrain + 1] = v5
		v5.Gui.Parent = parent
	end

	return v3
end

local v3 = {
	{ 0, 1.5 },
	{ 1, -0.5 },
	{ 1, -1.5 },
	{ 0, -0.5 },
	{ -1, -1.5 },
	{ -1, -0.5 }
}
local v4 = {
	{ 1, 1 },
	{ -1, 1 },
	{ -1, -1 },
	{ 1, -1 }
}

function CreateBody(list, p)
	local result = {
		X = 0,
		Y = 0,
		VX = 0,
		VY = 0,
		Radius = 0,
		Rotation = 0,
		Restitution = 1,
		NumPoints = #list
	}
	local v5 = {}

	for k, v6 in pairs(list) do
		v5[k] = { v6[1] * p, v6[2] * p }
		local radius = math.sqrt(v5[k][1] ^ 2 + v5[k][2] ^ 2)

		if result.Radius < radius then
			result.Radius = radius
		end
	end

	result.RadiusSq = result.Radius * result.Radius

	function result:GetPoints()
		local result2 = {}

		for k, v7 in pairs(v5) do
			local v8 = math.sin(result.Rotation)
			local v9 = math.cos(result.Rotation)
			result2[k] = { result.X + v7[1] * v9 - v7[2] * v8, result.Y + v7[2] * v9 + v7[1] * v8 }
		end

		return result2
	end

	return result
end

function CreateLine(parent2, backgroundColor)
	local v6 = {}
	return {
		Show = function(self, p3, p4, p5, p6)
			local v7 = p5 - p3
			local v8 = p6 - p4
			local v9 = len(v7, v8) -- equivalent call inferred; original call site unknown
			local v10 = v7 / v9
			local v11 = v8 / v9
			local count = 0

			for i = 0, math.sqrt(v7 * v7 + v8 * v8) do
				count += 1
				local v12

				if v6[count] then
					v12 = v6[count]
				else
					v12 = Create("Frame")({
						Parent = parent2,
						BorderSizePixel = 0,
						BackgroundColor3 = backgroundColor,
						Size = UDim2.new(0, 3, 0, 3),
						BackgroundTransparency = 0.7,
						Create("Frame")({
							BorderSizePixel = 0,
							BackgroundColor3 = backgroundColor,
							Size = UDim2.new(0, 1, 0, 1),
							Position = UDim2.new(0, 1, 0, 1)
						})
					})
					v6[count] = v12
				end

				v12.Position = UDim2.new(0, p3 + v10 * i, 0, p4 + v11 * i)
			end

			for i = count + 1, #v6 do
				v6[i]:Destroy()
				v6[i] = nil
			end
		end,
		Hide = function(self)
			for i = 1, #v6 do
				v6[i]:Destroy()
				v6[i] = nil
			end
		end
	}
end

function CreateBodyView(object, p, p2)
	local v5 = {}
	local v6 = {}

	for i = 1, object.NumPoints do
		v5[i] = CreateLine(p, p2)
	end

	function v6:Show()
		local points = object:GetPoints()

		for i = 1, #points - 1 do
			local point = points[i]
			local point2 = points[i + 1]
			v5[i]:Show(point[1], point[2], point2[1], point2[2])
		end

		local point = points[#points]
		local point2 = points[1]
		v5[#v5]:Show(point[1], point[2], point2[1], point2[2])
	end

	function v6:Hide()
		for i = 1, #v5 do
			v5[i]:Hide()
		end
	end

	return v6
end

function CollidePointWithLevel(p, p2, p3, p4)
	local v5 = {}
	local v6 = {}

	for _, v7 in pairs(p.Terrain) do
		if not (not p4 or p4[v7]) then
			continue
		end

		local v8 = p2 - v7.CenterX
		local v9 = p3 - v7.CenterY

		if not (v8 * v8 + v9 * v9 < v7.RadiusSq) then
			continue
		end

		local v10 = 1e999
		local v11 = nil
		local v12 = 1

		for _, v13 in pairs(v7.Axis) do
			local v14 = p2 * v13.DirX + p3 * v13.DirY

			if v14 < v13.Min or v13.Max < v14 then
				v11 = v13
				v10 = 0
			else
				local v15 = v13.Max - v14
				local v16 = v14 - v13.Min

				if math.min(v15, v16) < v10 then
					if v15 < v16 then
						v11 = v13
						v10 = v15
						v12 = 1
					else
						v11 = v13
						v10 = v16
						v12 = -1
					end
				end
			end
		end

		if not (v10 > 0) then
			continue
		end

		local v13 = #v5 + 1
		v5[v13] = v11
		v6[v13] = v10 * v12
	end

	if not (#v5 > 0) then
		return nil
	end

	local total = 0
	local total2 = 0

	for i = 1, #v5 do
		local v7 = v5[i]
		local v8 = v6[i]
		total += v7.DirX * v8
		total2 += v7.DirY * v8
	end

	return total, total2
end

function CollideBodyWithLevel(p, object)
	local v5 = {}

	for _, v6 in pairs(p.Terrain) do
		local v7 = v6.CenterX - object.X
		local v8 = v6.CenterY - object.Y

		if v7 * v7 + v8 * v8 < (v6.Radius + object.Radius) ^ 2 then
			v5[v6] = true
		end
	end

	if not next(v5) then
		return nil
	end

	local points = object:GetPoints()
	local total = 0
	local total2 = 0
	local flag = false

	for _, point in pairs(points) do
		local v6, v7 = CollidePointWithLevel(p, point[1] + total, point[2] + total2)

		if not v6 then
			continue
		end

		total += v6
		total2 += v7
		flag = true
	end

	if flag then
		return total, total2
	end

	return nil
end

function PlayLevel(p, instance, data, instance2, object)
	local clone = instance2:Clone()
	clone.Parent = instance2.Parent
	local v5 = CreateBody(v3, 7)
	local x = instance.Parent.StartAt.Value.x
	local y = instance.Parent.StartAt.Value.y
	v5.X = x
	v5.Y = y
	v5.Restitution = 0.1
	v5.Rotation = 3.141592653589793
	local v6 = CreateBodyView(v5, instance, Color3.new(0, 1, 0))
	local v7 = CreateBody(v4, 6)
	local x2 = instance.Parent.CrateAt.Value.x
	local y2 = instance.Parent.CrateAt.Value.y
	v7.X = x2
	v7.Y = y2
	v7.Restitution = 0.2
	local v8 = CreateBodyView(v7, instance, Color3.new(0.6, 0.6, 0.6))
	local v9 = { v5, v7 }
	local v10 = { v6, v8 }
	local v11 = {}

	local function addJetParticle(data2)
		local v12 = {}

		if data2 then
			local v13 = math.random() * 3.141592653589793 * 2
			local v14 = data2.X + (math.random() - 0.5) * 5
			local v15 = data2.Y + (math.random() - 0.5) * 5
			v12.X = v14
			v12.Y = v15
			local VX = data2.VX + math.cos(v13) * 30
			local VY = data2.VY + math.sin(v13) * 30
			v12.VX = VX
			v12.VY = VY
		else
			v12.X = v5.X + math.sin(v5.Rotation) * 7
			v12.Y = v5.Y - math.cos(v5.Rotation) * 7
			local v13 = 0.6 * (math.random() - 0.5) ^ 2
			local v14 = v5.Rotation + v13
			local v15 = 50 + math.random() * 5
			v12.VX = math.sin(v14) * v15 + v5.VX
			v12.VY = -math.cos(v14) * v15 + v5.VY
			local VX = v12.VX
			local VY = v12.VY
			local v16 = len(VX, VY) -- equivalent call inferred; original call site unknown
			local v17 = VX / v16
			local v18 = VY / v16
			local VX2 = v12.VX - v17 * 10 * v13
			local VY2 = v12.VY - v18 * 10 * v13
			v12.VX = VX2
			v12.VY = VY2
		end

		v12.Timestamp = tick()
		v12.Gui = Create("Frame")({
			Parent = instance,
			Position = UDim2.new(0, v12.X - 2, 0, v12.Y - 2),
			Size = UDim2.new(0, 3, 0, 3),
			BackgroundColor3 = Color3.new(1, math.random(), 0),
			BorderSizePixel = 0
		})
		v11[#v11 + 1] = v12
		return v12
	end

	local flag = false
	local v12 = false
	local v13 = CreateLine(instance, Color3.new(1, 1, 1))
	local v14 = "play"
	local now = 0
	local v15 = ""

	function v5.Touched(p2, p3)
		local v16 = -math.sin(v5.Rotation)
		local v17 = math.cos(v5.Rotation)
		local v18 = math.acos(p2 * v16 + p3 * v17)
		local v19 = len(v5.VX, v5.VY) -- equivalent call inferred; original call site unknown

		if v18 > 0.7853981633974483 and v19 > 35 or v19 > 60 then
			v14 = "loss"
			now = tick()

			if v19 > 60 then
				v15 = "Hey man, easy on the gas!"
			elseif v18 < 0.7853981633974483 and p3 < -0.5 then
				v15 = "Bit rough on the landing there, don't you think?"
			else
				v15 = "Oops! Mind the rocks."
			end

			removeValue(v9, v5)
			removeValue(v10, v6)
			v6:Hide()
			v13:Hide()
			flag = false
			object:Play()

			for _ = 1, 20 do
				addJetParticle(v5)
			end
		end
	end

	function v7.Touched(_, _)
		if flag then
			local VX = v7.VX
			local VY = v7.VY

			if math.sqrt(VX * VX + VY * VY) > 15 then
				v14 = "loss"
				now = tick()
				v15 = "That's expensive equipment you're hauling, careful with it!"
				removeValue(v9, v7)
				removeValue(v10, v8)
				v8:Hide()
				v13:Hide()
				flag = false
				object:Play()

				for _ = 1, 20 do
					addJetParticle(v7)
				end
			end
		end
	end

	local now2 = tick()
	local flag2 = false

	while v14 == "play" or v14 == "loss" and tick() - now < 1.6 do
		wait()
		local now3 = tick()
		local v16 = now3 - now2

		if v14 == "play" then
			if data.a then
				v5.Rotation -= v16 * 2
			end

			local _ = data.s

			if data.d then
				v5.Rotation += v16 * 2
			end

			if data.w then
				local v17 = -math.sin(v5.Rotation)
				local v18 = math.cos(v5.Rotation)
				v5.VX += v16 * v17 * 70
				v5.VY += v16 * v18 * 70
				addJetParticle()
				addJetParticle()

				if not flag2 then
					flag2 = true
					instance2:Play()
					Delay(0.5, function()
						if flag2 then
							clone:Play()
						end
					end)
				end
			elseif flag2 then
				flag2 = false
				instance2:Stop()
				clone:Stop()
			end
		else
			instance2:Stop()
			clone:Stop()
		end

		now2 = now3

		for _, v17 in pairs(v9) do
			v17.VY += v16 * 20
			v17.X += v17.VX * v16
			v17.Y += v17.VY * v16
			local v18, v19 = CollideBodyWithLevel(p, v17)

			if not v18 then
				continue
			end

			if v17.Touched then
				v17.Touched(unit(v18, v19))
			end

			v17.X += v18
			v17.Y += v19
			local VX = v17.VX
			local VY = v17.VY

			if not (VX * v18 + VY * v19 < 0) then
				continue
			end

			local v20 = len(v18, v19) -- equivalent call inferred; original call site unknown
			local v21 = v18 / v20
			local v22 = v19 / v20
			local VX2 = v17.VX
			local VY2 = v17.VY
			local v23 = v21 * VX2 + v22 * VY2
			v17.VX -= (1 + v17.Restitution) * v21 * v23
			v17.VY -= (1 + v17.Restitution) * v22 * v23
			local v24 = -v22
			local VX3 = v17.VX
			local VY3 = v17.VY
			local v25 = v24 * VX3 + v21 * VY3

			if v25 > 1 then
				v17.VX -= 0.5 * v24 * v25
				v17.VY -= 0.5 * v21 * v25
			else
				v17.VX -= 1 * v24 * v25
				v17.VY -= 1 * v21 * v25
			end
		end

		if v14 == "play" then
			if flag then
				if v12 then
					local X = v7.X
					local Y = v7.Y
					local X2 = v5.X
					local Y2 = v5.Y
					local v17 = X - X2
					local v18 = Y - Y2
					local v19 = len(v17, v18) -- equivalent call inferred; original call site unknown
					local v20 = v17 / v19
					local v21 = v18 / v19
					local v22 = math.sqrt(v17 * v17 + v18 * v18) - 40
					v7.X = v5.X + v20 * 40
					v7.Y = v5.Y + v21 * 40
					v5.VX += v22 * v20 * v16 * 10
					v5.VY += v22 * v21 * v16 * 10
					v7.VX -= v22 * v20 * v16 * 22
					v7.VY -= v22 * v21 * v16 * 22
				else
					local X = v5.X
					local Y = v5.Y
					local X2 = v7.X
					local Y2 = v7.Y
					local v17 = X - X2
					local v18 = Y - Y2
					v12 = math.sqrt(v17 * v17 + v18 * v18) > 40 or v12
				end
			else
				local X = v5.X
				local Y = v5.Y
				local X2 = v7.X
				local Y2 = v7.Y
				local v17 = X - X2
				local v18 = Y - Y2

				if math.sqrt(v17 * v17 + v18 * v18) < 40 then
					local VX = v5.VX
					local VY = v5.VY

					if math.sqrt(VX * VX + VY * VY) < 5 then
						local VX2 = v7.VX
						local VY2 = v7.VY

						if math.sqrt(VX2 * VX2 + VY2 * VY2) < 5 then
							flag = true
						end
					end
				end
			end
		end

		if flag and v5.Y < 0 then
			v14 = "win"
			v15 = "Well done, you saved the equipment!"
		end

		local size = instance.Parent.Size
		local _ = instance.Size
		instance.Position = UDim2.new(0, size.X.Offset / 2 - v5.X, 0, size.Y.Offset / 2 - v5.Y)

		if v14 == "play" then
			if flag then
				v13:Show(v5.X, v5.Y, v7.X, v7.Y)
			else
				v13:Hide()
			end
		end

		for _, v17 in pairs(v10) do
			v17:Show()
		end

		local v17 = {}

		for _, v18 in pairs(v11) do
			local v19 = v18.X + v18.VX * v16
			local v20 = v18.Y + v18.VY * v16
			v18.X = v19
			v18.Y = v20
			local v21, v22 = CollidePointWithLevel(p, v18.X, v18.Y)
			local v23 = tick() - v18.Timestamp

			if v23 > 1.2 then
				v17[#v17 + 1] = v18
			end

			v18.Gui.Position = UDim2.new(0, v18.X - 1, 0, v18.Y - 1)
			v18.Gui.BackgroundTransparency = math.min(1, v23 / 1.2) ^ 2

			if not v21 then
				continue
			end

			local v24 = v18.X + v21
			local v25 = v18.Y + v22
			v18.X = v24
			v18.Y = v25
			local VX = v18.VX
			local VY = v18.VY

			if not (VX * v21 + VY * v22 < 0) then
				continue
			end

			local v26 = len(v21, v22) -- equivalent call inferred; original call site unknown
			local v27 = v21 / v26
			local v28 = v22 / v26
			local VX2 = v18.VX
			local VY2 = v18.VY
			local v29 = v27 * VX2 + v28 * VY2
			v18.VX -= 1.2 * v27 * v29
			v18.VY -= 1.2 * v28 * v29
		end

		for _, v18 in pairs(v17) do
			removeValue(v11, v18)
			v18.Gui:Destroy()
		end
	end

	instance2:Stop()
	clone:Destroy()
	return v14, v15
end

local parent = script.Parent
local clone = nil
local playerFromCharacter = nil
local clone2 = nil
local clone3 = nil
parent.Equipped:connect(function(p)
	playerFromCharacter = game.Players:GetPlayerFromCharacter(parent.Parent)
	local playerGui = playerFromCharacter.PlayerGui
	local v5 = {}
	clone2 = parent.RocketSound:Clone()
	clone2.Parent = game.Workspace.CurrentCamera
	clone3 = parent.ExplodeSound:Clone()
	clone3.Parent = game.Workspace.CurrentCamera
	playerFromCharacter.Character:SetAttribute("PlayingLunarLander", 0.11)
	p.KeyDown:connect(function(p2)
		v5[p2] = true
	end)
	p.KeyUp:connect(function(p2)
		v5[p2] = nil
	end)
	clone = parent.Gui:Clone()
	clone.Parent = playerGui
	clone.MainContainer.Visible = true
	local DoLevel

	DoLevel = function(instance)
		clone.MainContainer.Visible = false
		local clone4 = instance:Clone()
		clone4.Parent = clone
		clone4.Visible = true
		local v6 = CreateLevel_FromData(clone4.Level)
		local v7, text = PlayLevel(v6, clone4.Level, v5, clone2, clone3)
		local clone5 = clone.WinLossMessage:Clone()
		clone5.Visible = true
		clone5.Parent = clone4
		clone5.TitleLabel.Text = text
		clone5.TitleLabel.TitleLabel.Text = text

		if v7 == "win" then
			if instance.NextLevel.Value == "" then
				clone5.TitleLabel.Text = "You beat the game!"
				clone5.TitleLabel.TitleLabel.Text = "You beat the game!"
				clone5.Button1.Button.Text = "Exit"
				clone5.Button1.Button.Button.Text = "Exit"
				clone5.Button1.Position = UDim2.new(0.5, -60, 0, 80)
				clone5.Button2.Visible = false
				clone5.Button1.MouseButton1Down:wait()
				clone4:Destroy()
				clone.MainContainer.Visible = true
			else
				clone5.Button1.Button.Text = "Next Level"
				clone5.Button1.Button.Button.Text = "Next Level"
				clone5.Button2.Button.Text = "Exit"
				clone5.Button2.Button.Button.Text = "Exit"
				local v9 = waitForAny(clone5.Button1.Button.MouseButton1Down, clone5.Button2.Button.MouseButton1Down)
				clone4:Destroy()

				if v9 == 1 then
					return DoLevel(parent.Levels:FindFirstChild(instance.NextLevel.Value))
				end

				if v9 == 2 then
					clone.MainContainer.Visible = true
				end
			end
		else
			clone5.Button1.Button.Text = "Retry"
			clone5.Button1.Button.Button.Text = "Retry"
			clone5.Button2.Button.Text = "Exit"
			clone5.Button2.Button.Button.Text = "Exit"
			local v9 = waitForAny(clone5.Button1.Button.MouseButton1Down, clone5.Button2.Button.MouseButton1Down)
			clone4:Destroy()

			if v9 == 1 then
				return DoLevel(instance)
			end

			if v9 == 2 then
				clone.MainContainer.Visible = true
			end
		end
	end

	for _, child in pairs(clone.MainContainer:GetChildren()) do
		local child2 = parent.Levels:FindFirstChild(child.Name)

		if not child2 then
			continue
		end

		local v6 = child2
		child.Button.MouseButton1Down:connect(function()
			DoLevel(v6)
		end)
	end
end)
parent.Unequipped:connect(function()
	if playerFromCharacter then
		playerFromCharacter.Character:SetAttribute("PlayingLunarLander", nil)
	end

	if clone then
		clone:Destroy()
		clone = nil
	end

	if clone2 then
		clone3:Destroy()
		clone3 = nil
		clone2:Destroy()
		clone2 = nil
	end
end)