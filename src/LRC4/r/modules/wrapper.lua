local us = game:GetService("UserService")
local http = game:GetService("HttpService")

local r = script.Parent.Parent
local gateway = r.connect.plugin_gateway

local notifs = require(r.modules.notifs)

local ui_cache = {}
local outfits_cache = {}
local outfit_details_cache = {}

local wrapper = {}

function wrapper:get_user_info_for_individual(uid)
	--error('TEST ERROR',0)
	-- do not pcall, leave it to the individual thread to handle any errors
	
	if typeof(ui_cache[uid]) ~= "table" then
		if game.TestService:GetAttribute('lrc4__error_usi_requests') then error('TestService error usi requests flag is enabled', 0) end
		ui_cache[uid] = us:GetUserInfosByUserIdsAsync({uid})[1]
	end
	
	return ui_cache[uid]
end

function wrapper:clear_user_info_for_individual(uid)
	if typeof(ui_cache[uid]) == "table" then
		ui_cache[uid] = nil
	end

	return ui_cache[uid]
end

function wrapper:get_outfits(uid, widget)
	local res
	
	local s, err = pcall(function()
		--if true then error('test error') end
		if game.TestService:GetAttribute('lrc4__error_http_permission_denied') then error('HttpService permission denied on domain oxalyl.apis.wolf1te.com for plugin 8867876284.', 0) end
		
		if outfits_cache[uid] ~= nil then
			res = http:JSONDecode(outfits_cache[uid])
		else
			--local url = `https://oxalyl.apis.wolf1te.com/roblox.com/avatar/v1/users/{tostring(uid)}/outfits?isEditable=true&itemsPerPage=50&outfitType=Avatar&page=1` --`https://hydrogen.wolfite.dev/roblox/avatar/v1/users/{tostring(user_id)}/outfits?isEditable=true&itemsPerPage=50&outfitType=Avatar&page=1`
			local url = `https://oxalyl.apis.wolf1te.com/roblox.com/avatar/v2/avatar/users/{tostring(uid)}/outfits?isEditable=true&itemsPerPage=150&outfitType=Avatar&page=1`
			local outfits = http:GetAsync(url, false, {
				["wlft-auth"]="public-key-lrc4-23-01-25-UVa4S2RQvLKSK6PuSXmBPp55AqhQFYcUMqHmDj23dAn9eppmd3heWN7h22hm7SqNJUB8G0eDHhnhQri4XwXN67ZnvBnbnAY69K9Vj6zKCYZBnDm0Crk5mR0G7SmW5aL8FnStx5HS8Z7tJJmmYjijvhbqGeK4MtDLvjiBe1SynUSKMYRxDjxVet7aLHx3GaX4PaEvJfy4e9g30phvBXJ71R56zQdCCUR3Ef8796qCQi6CyTEvzMyDkXMQbp4cYUfK";
				--either roblox or oxalyl should add correct accept headers
			})

			if outfits["errors"] == nil then
				outfits_cache[uid] = outfits
			else
				error("[handled]".. tostring(outfits["errors"]))
			end
			

			res = http:JSONDecode(outfits)
		end
	end)
	
	if not s then
		if err == "HTTP 401 (Unauthorized)" then
			notifs:banner(widget, "Oxalyl Proxy responded with a 401 Unauthorizated error. You may need to update this plugin.", "error", 0)
		elseif err == "HTTP 429 (TOO MANY REQUESTS)" then
			notifs:banner(widget, "You are sending requests too fast. Please wait and try again later.", "error", 0)
		elseif err == "HTTP 429 (Too Many Requests)" then
			notifs:banner(widget, "You are sending requests too fast. Please wait and try again later.", "error", 0)
		elseif typeof(err) == 'string' and err:find('permission denied') then
			notifs:banner(widget, "Required plugin permissions were denied. Please enable them. <u>Click to learn more</u>.", "error", 0, 'enable_http')
		else
			warn(err)
			notifs:banner(widget, "Error when querying proxy: "..err:gsub("%[handled%]",""), "error", 0)
		end
		
		return 'error'
	else
		return res or {}
	end
end

function wrapper:get_outfits_details(oid, widget)
	local res

	local s, err = pcall(function()
		--if true then error('test error') end
		
		if outfit_details_cache[oid] ~= nil then
			--print("cached")
			res = http:JSONDecode(outfit_details_cache[oid])
		else
			local url = `https://oxalyl.apis.wolf1te.com/roblox.com/avatar/v3/outfits/{tostring(oid)}/details` --`https://hydrogen.wolfite.dev/roblox/avatar/v1/users/{tostring(user_id)}/outfits?isEditable=true&itemsPerPage=50&outfitType=Avatar&page=1`
			--print(url)
			local outfits = http:GetAsync(url, false, {
				["wlft-auth"]="public-key-lrc4-23-01-25-UVa4S2RQvLKSK6PuSXmBPp55AqhQFYcUMqHmDj23dAn9eppmd3heWN7h22hm7SqNJUB8G0eDHhnhQri4XwXN67ZnvBnbnAY69K9Vj6zKCYZBnDm0Crk5mR0G7SmW5aL8FnStx5HS8Z7tJJmmYjijvhbqGeK4MtDLvjiBe1SynUSKMYRxDjxVet7aLHx3GaX4PaEvJfy4e9g30phvBXJ71R56zQdCCUR3Ef8796qCQi6CyTEvzMyDkXMQbp4cYUfK";
				--either roblox or oxalyl should add correct accept headers
			})

			if outfits["errors"] == nil then
				outfit_details_cache[oid] = outfits
			else
				error("[handled]".. tostring(outfits["errors"]))
			end

			res = http:JSONDecode(outfits)
		end
		
		
	end)

	if not s then
		if err == "HTTP 401 (Unauthorized)" then
			notifs:banner(widget, "Oxalyl Proxy responded with 401 Unauthorizated error. You may need to update this plugin.", "error", 0)
		elseif err == "HTTP 429 (TOO MANY REQUESTS)" then
			notifs:banner(widget, "You are sending requests too fast. Please wait and try again later.", "error", 0)
		elseif err == "HTTP 429 (Too Many Requests)" then
			notifs:banner(widget, "You are sending requests too fast. Please wait and try again later.", "error", 0)
		else
			warn(err)
			notifs:banner(widget, "Error when querying proxy: "..err:gsub("%[handled%]",""), "error", 0)
		end
	else
		return res or {}
	end
end

function wrapper:clear_outfits_for_individual(uid)
	if typeof(outfits_cache[uid]) == "string" then
		outfits_cache[uid] = nil
	end

	return outfits_cache[uid]
end

function wrapper:clear_local_plugin_data_for_individual(uid)
	local last_loaded_db = gateway:Invoke("get","setting",{setting_name="last_loaded_db"}) or {}
	last_loaded_db[tostring(uid)] = nil
	gateway:Invoke("post","setting",{setting_name="last_loaded_db", target=last_loaded_db})
	r.modules.home.__content_sync:Fire("lldbupd")
end

return wrapper