--!nolint
--!nocheck

local home = {}

local r = script.Parent.Parent
local gateway = r.connect.plugin_gateway

local cursors = require(script.Parent.cursors)
local nav = require(script.Parent.nav)
local loader = require(script.Parent.loader)
local wrapper = require(script.Parent.wrapper)
local notifs = require(r.modules.notifs)
local resolver = require(r.modules.resolver)

local players = game:GetService("Players")
local sts = game:GetService("StudioService")

local luid = sts:GetUserId()

local plugin_mouse = gateway:Invoke("get", "mouse")

local rbxasset_cursors = {
	arrow = "rbxasset://SystemCursors/Arrow";
	pointer = "rbxasset://SystemCursors/PointingHand";
	open_hand = "rbxasset://SystemCursors/OpenHand";
	closed_hand = "rbxasset://SystemCursors/ClosedHand";
	i_beam = "rbxasset://SystemCursors/IBeam";
	forbidden = "rbxasset://SystemCursors/Forbidden";
	_wait = "rbxasset://SystemCursors/Wait";
	busy = "rbxasset://SystemCursors/Busy";
}

local cursors = {
	default = rbxasset_cursors.arrow;
	hover = rbxasset_cursors.pointer;
	forbidden = rbxasset_cursors.forbidden;
	_wait = rbxasset_cursors._wait;
	busy = rbxasset_cursors.busy;
}

local function c(cursor:string)
	plugin_mouse.Icon = cursor
end

local last_loaded_db = gateway:Invoke("get", "setting", {setting_name="last_loaded_db"}) or {["655331725"] = 1720244444}
for i, v in pairs(last_loaded_db) do --[[print(i,v)]] if type(i) == "string" then continue end last_loaded_db[tostring(i)] = v; last_loaded_db[i] = nil end
----[[?!?!?!?!?]] for i, v in pairs(last_loaded_db) do if type(i) == "number" then continue end last_loaded_db[tonumber(i)] = v; last_loaded_db[i] = nil end


local init_load_failure = false


local function construct_user_item_large(uid, parent, widget)
	--print(last_loaded_db)
	local t = r.ui.item__uid:Clone()
	t.burst.frame.img.Image = players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size180x180)
	
	local usr_info-- = wrapper:get_user_info_for_individual(uid)
	
	local s, err = pcall(function()
		usr_info = wrapper:get_user_info_for_individual(uid)
	end)
	
	if not s then
		init_load_failure = true
		resolver:network_error(widget)
		task.spawn(function()
			notifs:banner(widget, "Error when loading home: ".. tostring(err), "error", 6)
		end)
		return
	end
	
	if not usr_info then t:Destroy() return end -- abort in case user is terminated
	
	t.display.Text = usr_info.DisplayName.. if usr_info.HasVerifiedBadge --[[or uid==655331725]] then utf8.char(0xE000) else ""
	t.username.Text = "@".. usr_info.Username
	
	if last_loaded_db[tostring(uid)] ~= nil then
		local formatted = os.date("*t", last_loaded_db[tostring(uid)])
		t.last_loaded.Text = `Last loaded {if tostring(formatted.day):len() == 1 then "0" else ""}{formatted.day}/{if tostring(formatted.month):len() == 1 then "0" else ""}{formatted.month}/{tostring(formatted.year):sub(3,4) or ".."}`
	else
		--t.last_loaded.Text = "Last loaded ../../.." -- 24/02/24
		t.last_loaded.Text = ""
		t.last_loaded.Visible = false
	end
	
	t.Name = "item__".. tostring(uid)
	t.Parent = parent
	local size = t.last_loaded.Position.X.Offset+12
		
	if t.last_loaded.TextBounds.X >= (t.display.TextBounds.X >= t.username.TextBounds.X and t.display.TextBounds.X or t.username.TextBounds.X) then
		size += t.last_loaded.TextBounds.X
	else
		if t.display.TextBounds.X >= t.username.TextBounds.X then
			size += t.display.TextBounds.X
		else
			size += t.username.TextBounds.X	
		end
	end
	
	t.Size = UDim2.new(0,size,1,0)
	
	t.hitbox.MouseButton1Click:Connect(function()
		loader:open(widget, uid)
	end)
	
	if parent.Name == "carousel__bookmarks" then
		t.hitbox.MouseButton2Click:Connect(function()
			local res = gateway:Invoke("get", "bookmark_delete_context_menu")
			
			if 
				(res == "user_LRC4.rbxmx_lrc4-bdcm-del")
				or
				(res == "lrc4-bdcm-del")
				or
				(res:find('lrc4%-bdcm%-del'))
			then
				local alt = gateway:Invoke("get", "setting", {setting_name="bookmarked"})
				
				if table.find(alt, uid) then
					table.remove(alt, table.find(alt, uid))
				end
				
				c(cursors._wait)
				gateway:Invoke("post", "setting", {setting_name="bookmarked", target=alt})
				task.wait()
				script.__content_sync:Fire("bookmarked")
				c(cursors.default)
			elseif 
				(res == "user_LRC4.rbxmx_lrc4-bdcm-oid")
				or
				(res == "lrc4-bdcm-oid")
				or
				(res:find('lrc4%-bdcm%-oid'))
			then
				loader:open(widget, uid)
			elseif (res == "user_LRC4.rbxmx_lrc4-bdcm-adv-cc") or (res == "lrc4-bdcm-adv-cc") or (res:find('lrc4%-bdcm%-adv%-cc')) then
				wrapper:clear_user_info_for_individual(uid)
				wrapper:clear_outfits_for_individual(uid)
			elseif (res == "user_LRC4.rbxmx_lrc4-bdcm-adv-cld") or (res == "lrc4-bdcm-adv-cld") or (res:find('lrc4%-bdcm%-adv%-cld')) then
				wrapper:clear_local_plugin_data_for_individual(uid) 
			end
		end)
	elseif parent.Name == "carousel__recent" then
		t.hitbox.MouseButton2Click:Connect(function()
			local res = gateway:Invoke("get", "recent_delete_context_menu")

			if 
				(res == "user_LRC4.rbxmx_lrc4-rdcm-del")
				or
				(res == "lrc4-rdcm-del")
				or
				(res:find('lrc4%-rdcm%-del'))
			then
				local alt = gateway:Invoke("get", "setting", {setting_name="recent"})

				--if table.find(alt, tostring(uid)) then
				--	table.remove(alt, table.find(alt, tostring(uid)))
				--end
				
				--print("rdcm", alt, uid, typeof(tostring(uid)), table.find(alt, tostring(uid)), typeof(alt and alt[2] and typeof(alt) or 'n'))
				--k, fine ig
				
				local f
				for i, v in pairs(alt) do
					if tonumber(v) == uid then
						f = i
						break
					end
				end
				
				if f then
					table.remove(alt, f)
				else
					warn("LRC4 | User requested removal for a UID that wasn't found")
				end

				c(cursors._wait)
				gateway:Invoke("post", "setting", {setting_name="recent", target=alt})
				task.wait()
				script.__content_sync:Fire("recent")
				c(cursors.default)
			elseif 
				(res == "user_LRC4.rbxmx_lrc4-rdcm-oid")
				or
				(res == "lrc4-rdcm-oid")
				or
				(res:find('lrc4%-rdcm%-oid'))
			then
				loader:open(widget, uid)
			elseif (res:find('lrc4%-rdcm%-adv%-cc')) or (res == "user_LRC4.rbxmx_lrc4-rdcm-adv-cc") or (res == "lrc4-rdcm-adv-cc") then
				wrapper:clear_user_info_for_individual(uid)
				wrapper:clear_outfits_for_individual(uid)
			elseif (res:find('lrc4%-rdcm%-adv%-cld')) or (res == "user_LRC4.rbxmx_lrc4-rdcm-adv-cld") or (res == "lrc4-rdcm-adv-cld") then
				wrapper:clear_local_plugin_data_for_individual(uid) 
			end
		end)
	else
		t.hitbox.MouseButton2Click:Connect(function()
			local res = gateway:Invoke("get", "character_context_menu")
			--print(res)
			
			-- fancy if statement
			if 
				(res:find('lrc4%-mcm%-oid'))
				or
				(res == "user_LRC4.rbxmx_lrc4-mcm-oid")
				or
				(res == "lrc4-mcm-oid")
			then
				loader:open(widget, uid)
			elseif (res:find('lrc4%-mcm%-adv%-cc')) or (res == "user_LRC4.rbxmx_lrc4-mcm-adv-cc") or (res == "lrc4-mcm-adv-cc") then
				wrapper:clear_user_info_for_individual(uid)
				wrapper:clear_outfits_for_individual(uid)
			elseif (res:find('lrc4%-mcm%-adv%-cld')) or (res == "user_LRC4.rbxmx_lrc4-mcm-adv-cld") or (res == "lrc4-mcm-adv-cld") then
				wrapper:clear_local_plugin_data_for_individual(uid)
			end
		end)
	end
	
	t.MouseEnter:Connect(function()
		c(cursors.hover)
	end)
	
	t.MouseLeave:Connect(function()
		c(cursors.default)
	end)
	
	t:SetAttribute("tooltip_text", "@".. usr_info.Username)
	t:SetAttribute("tooltip_is_hint", true)
	t:SetAttribute("uid", uid)
	
	r.modules.components.__apply_scan:Fire(t)
end

local function construct_user_grid_item_small(uid, parent, widget, info)
	local t = r.ui.grid__uid:Clone()
	t.burst.frame.img.Image = players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size180x180)
	t.Name = "grid__".. (info and info.Username and info.Username..'__' or '') .. tostring(uid)
	t.Parent = parent
	
	t.hitbox.MouseButton1Click:Connect(function()
		loader:open(widget, uid)
	end)
	
	t.MouseEnter:Connect(function()
		c(cursors.hover)
	end)

	t.MouseLeave:Connect(function()
		c(cursors.default)
	end)
	
	t.hitbox.MouseButton2Click:Connect(function()
		local res = gateway:Invoke("get", "character_context_menu")
		--print(res)

		-- fancy if statement
		--if 
		--	(res == "user_LRC4.rbxmx_lrc4-mcm-oid")
		--	or
		--	(res == "lrc4-mcm-oid")
		--then
		--	loader:open(widget, uid)
		--elseif (res == "user_LRC4.rbxmx_lrc4-mcm-adv-cc") or (res == "lrc4-mcm-adv-cc") then
		--	wrapper:clear_user_info_for_individual(uid)
		--elseif (res == "user_LRC4.rbxmx_lrc4-mcm-adv-cld") or (res == "lrc4-mcm-adv-cld") then
		--	wrapper:clear_local_plugin_data_for_individual(uid)
		--end
		
		if res:find('lrc4%-mcm%-oid') then
			loader:open(widget, uid)
		elseif res:find('lrc4%-mcm%-adv%-cc') then
			wrapper:clear_user_info_for_individual(uid)
		elseif res:find('lrc4%-mcm%-adv%-cld') then
			wrapper:clear_local_plugin_data_for_individual(uid)
		end
	end)
	
	--t:SetAttribute("tooltip_text", "@".. players:GetNameFromUserIdAsync(uid)) --TODO: req per hover
	t:SetAttribute("tooltip_text", info and info.Username and '@'.. info.Username or `usn:{tostring(uid)}`)
	t:SetAttribute("tooltip_is_hint", true)
	r.modules.components.__apply_scan:Fire(t)
end

function home:init(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	
	app.home.content.Visible = false
	app.home.search.Visible = false
	app.home.preload.Visible = true
	
	local function state_search()
		local q = app.home.search.input.Text
		local qo = app.home.search.input.Text
		local q_incl_at = q:find("@")
		q = q:gsub(" ", ""); q = q:gsub("[^%w%s_]+", "");
		
		if q == "" then return end
		
		if qo == '/i/ud' then
			--loader:open(widget, -444  , nil, false, {cai = {assets = {}; bodyColor3s = {}; bodyColors = {}; emotes = {}; playerAvatarType = "R6"; scales = {bodyType = 0; depth = 0; head = 1; height = 1; proportion = 0; width = 1;};}; is_local = true; humanoid_desc = Instance.new('HumanoidDescription')})
			loader:open(widget, -444  , nil, false, {cai = players:GetCharacterAppearanceInfoAsync(655331725); is_local = true; humanoid_desc = players:GetHumanoidDescriptionFromUserId(655331725)})
			return
		end
		
		local uid
		
		if tonumber(q) ~= nil and not q_incl_at then
			uid = tonumber(q)
		else
			if not (pcall(function() uid = players:GetUserIdFromNameAsync(q) end)) then
				notifs:banner(widget, "That user does not exist.", "error")
			end
		end
		
		if uid ~= nil and typeof(uid) == "number" and uid > 0 and uid < 10_000_000_000 then
			loader:open(widget, uid)
		end
		
	end
	
	for _, v in pairs(app.home.content.carousel__suggested:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
	for _, v in pairs(app.home.content.carousel__recent:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
	for _, v in pairs(app.home.content.carousel__bookmarks:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
	for _, v in pairs(app.home.content.grid__friends:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
	
	construct_user_item_large(luid, app.home.content.carousel__suggested, widget)
	
	if not init_load_failure then
		for _, v in pairs(players:GetPlayers()) do
			if v.UserId ~= luid then
				construct_user_item_large(v.UserId, app.home.content.carousel__suggested, widget)
			end
		end

		local recent = gateway:Invoke("get", "setting", {setting_name="recent"}) or {}

		for _, v in pairs(recent) do
			construct_user_item_large(v, app.home.content.carousel__recent, widget)
		end

		local bookmarked = gateway:Invoke("get", "setting", {setting_name="bookmarked"})
		for _, v in pairs(bookmarked or {}) do construct_user_item_large(v, app.home.content.carousel__bookmarks, widget) end
		
		local save_recents = gateway:Invoke("get","setting",{setting_name="save_recents"}) ~= false

		if #(bookmarked or {}) == 0 then
			app.home.content.header_bookmarks.Visible = false
			app.home.content.carousel__bookmarks.Visible = false
		else
			app.home.content.header_bookmarks.Visible = true
			app.home.content.carousel__bookmarks.Visible = true
		end

		if #(recent) == 0 then
			app.home.content.header_recent.Visible = false
			app.home.content.carousel__recent.Visible = false
		else
			if save_recents then
				app.home.content.header_recent.Visible = true
				app.home.content.carousel__recent.Visible = true
			end
		end
	end
	
	script.__content_sync.Event:Connect(function(id)
		if id == "recent" then
			local recent = gateway:Invoke("get", "setting", {setting_name="recent"}) or {}
			last_loaded_db = gateway:Invoke("get", "setting", {setting_name="last_loaded_db"}) or {}
			--[[idk]] for i, v in pairs(last_loaded_db) do --[[print(i,v)]] if type(i) == "string" then continue end last_loaded_db[tostring(i)] = v; last_loaded_db[i] = nil end
			
			app.home.content.header_recent.title.label.__quantum_spinner.Visible = true
			for _, v in pairs(app.home.content.carousel__recent:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
			for _, v in pairs(recent) do construct_user_item_large(v, app.home.content.carousel__recent, widget) end
			app.home.content.header_recent.title.label.__quantum_spinner.Visible = false
			local save_recents = gateway:Invoke("get","setting",{setting_name="save_recents"}) ~= false
			
			if #(recent) == 0 then
				app.home.content.header_recent.Visible = false
				app.home.content.carousel__recent.Visible = false
			else
				if save_recents then
					app.home.content.header_recent.Visible = true
					app.home.content.carousel__recent.Visible = true
				end
			end
		elseif id == "bookmarked" or id == "bookmarks" then
			--last_loaded_db = gateway:Invoke("get", "setting", {setting_name="last_loaded_db"}) or {}
			----[[idk]] for i, v in pairs(last_loaded_db) do if type(i) == "number" then continue end last_loaded_db[tonumber(i)] = v; last_loaded_db[i] = nil end -- apparently, no
			last_loaded_db = gateway:Invoke("get", "setting", {setting_name="last_loaded_db"}) or {}
			--[[idk]] for i, v in pairs(last_loaded_db) do --[[print(i,v)]] if type(i) == "string" then continue end last_loaded_db[tostring(i)] = v; last_loaded_db[i] = nil end
			
			for _, v in pairs(app.home.content.carousel__bookmarks:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
			
			local bookmarked = gateway:Invoke("get", "setting", {setting_name="bookmarked"})
			for _, v in pairs(bookmarked or {}) do construct_user_item_large(v, app.home.content.carousel__bookmarks, widget) end
			
			if #(bookmarked or {}) == 0 then
				app.home.content.header_bookmarks.Visible = false
				app.home.content.carousel__bookmarks.Visible = false
			else
				app.home.content.header_bookmarks.Visible = true
				app.home.content.carousel__bookmarks.Visible = true
			end
		elseif id == "lldbupd" then
			local lldbu = gateway:Invoke("get", "setting", {setting_name="last_loaded_db"})
			--print(lldbu)
			--for _, v in pairs(gateway:Invoke("get", "setting", {setting_name="last_loaded_db"}) or {}) do
			--	print(_,v)
			--end
			
			-- cleanest code ive written yet
			
			local function updflldb(t)
				if t:IsA("Frame") then if t:GetAttribute("uid") then if lldbu[tostring(t:GetAttribute("uid"))] then local formatted = os.date("*t", last_loaded_db[tostring(tostring(t:GetAttribute("uid")))]) t.last_loaded.Text = `Last loaded {if tostring(formatted.day):len() == 1 then "0" else ""}{formatted.day}/{if tostring(formatted.month):len() == 1 then "0" else ""}{formatted.month}/{tostring(formatted.year):sub(3,4) or ".."}` t.last_loaded.Visible = true
							t.Size = UDim2.new(0,400,1,0)
							local size = t.last_loaded.Position.X.Offset+12
							if t.last_loaded.TextBounds.X >= (t.display.TextBounds.X >= t.username.TextBounds.X and t.display.TextBounds.X or t.username.TextBounds.X) then
								size += t.last_loaded.TextBounds.X
							else
								if t.display.TextBounds.X >= t.username.TextBounds.X then
									size += t.display.TextBounds.X
								else
									size += t.username.TextBounds.X	
								end
							end
							t.Size = UDim2.new(0,size,1,0)
							--print(size)
						else
							--print('not loaded i think', t)
							t.last_loaded.Text = ""
							t.Size = UDim2.new(0,400,1,0)
							local size = t.last_loaded.Position.X.Offset+12
							if t.last_loaded.TextBounds.X >= (t.display.TextBounds.X >= t.username.TextBounds.X and t.display.TextBounds.X or t.username.TextBounds.X) then
								size += t.last_loaded.TextBounds.X
							else
								if t.display.TextBounds.X >= t.username.TextBounds.X then
									size += t.display.TextBounds.X
								else
									size += t.username.TextBounds.X	
								end
							end
							t.Size = UDim2.new(0,size,1,0)
						end end end
			end
			
			for _, t in pairs(app.home.content.carousel__suggested:GetChildren()) do updflldb(t) end
			for _, t in pairs(app.home.content.carousel__recent:GetChildren()) do updflldb(t) end
			for _, t in pairs(app.home.content.carousel__bookmarks:GetChildren()) do updflldb(t) end
		end
	end)
	
	script.__reset.Event:Connect(function()
		app.home.content.softcrash.Visible = true
		
		script.__content_sync:Fire('recent')
		script.__content_sync:Fire('bookmarked')
		script.__content_sync:Fire('lldbupd')
		
		
		if app.home.content.header_friends.title.label.__quantum_spinner.Visible then return end
		app.home.content.header_friends.title.label.__quantum_spinner.Visible = true
		
		local fpages = players:GetFriendsAsync(luid)

		for _, v in pairs(fpages:GetCurrentPage()) do
			construct_user_grid_item_small(v.Id, app.home.content.grid__friends, widget)
		end

		if not fpages.IsFinished then
			repeat 
				task.wait()
				fpages:AdvanceToNextPageAsync()
				for _, v in pairs(fpages:GetCurrentPage()) do
					construct_user_grid_item_small(v.Id, app.home.content.grid__friends, widget)
				end
			until fpages.IsFinished
		end
		
		app.home.content.header_friends.title.label.__quantum_spinner.Visible = false
	end)
	
	app.home.content.grid__friends.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		app.home.content.grid__friends.Size = UDim2.new(1,0,0,app.home.content.grid__friends.UIListLayout.AbsoluteContentSize.Y+20)
	end)
	
	app.home.search.input.FocusLost:Connect(function(ent)
		if ent then
			state_search()
		end
	end)
	
	app.home.content.Visible = true
	app.home.search.Visible = true
	app.home.preload.Visible = false
	
	app.home.content.header_friends.title.label.__quantum_spinner.Visible = true
	app.home.content.header_friends.title.label.__quantum_spinner.Position = UDim2.new(0,app.home.content.header_friends.title.label.TextBounds.X+4,0.5,0)
	app.home.content.header_recent.title.label.__quantum_spinner.Position = UDim2.new(0,app.home.content.header_recent.title.label.TextBounds.X+4,0.5,0)
	
	--if gateway:Invoke("get", "is_outdated") then
	--	app.update_available.Visible = true
	--	local pn_:string = gateway:Invoke("get", "plugin_name")
	--	if pn_ and (pn_:gmatch('(%.rbxm%a?)$')() or pn_:gmatch('(%.luau?)$')()) then
	--		app.dev_build.Visible = true
	--		app.update_available.Visible = false
	--		app.dev_build.title.Position = UDim2.new(0,12,0.45,0)
	--	end
	--end
	
	local mtd_enabled = gateway:Invoke("get", "setting", {setting_name="use_multithreading"}) or false
	
	local fpages = players:GetFriendsAsync(luid)
	
	for i, v in pairs(fpages:GetCurrentPage()) do
		if mtd_enabled then
			task.spawn(function() construct_user_grid_item_small(v.Id, app.home.content.grid__friends, widget, v) end)
		else
			construct_user_grid_item_small(v.Id, app.home.content.grid__friends, widget, v)
		end
	end
	
	if not fpages.IsFinished then
		repeat 
			task.wait()
			fpages:AdvanceToNextPageAsync()
			
			for i, v in pairs(fpages:GetCurrentPage()) do
				if mtd_enabled then
					task.spawn(function() construct_user_grid_item_small(v.Id, app.home.content.grid__friends, widget, v) end)
				else
					construct_user_grid_item_small(v.Id, app.home.content.grid__friends, widget, v)
				end
			end
		until fpages.IsFinished
	end
	
	
	app.home.content.header_friends.title.label.__quantum_spinner.Visible = false
end

return home