--!nolint
--!nocheck

local players = game:GetService("Players")
local ts = game:GetService("TweenService")
local ps = game:GetService("PolicyService")
local sts = game:GetService("StudioService")
local selection = game:GetService('Selection')
local http = game:GetService('HttpService')
local ss = game:GetService('StudioService')

local r = script.Parent.Parent
local gateway = r.connect.plugin_gateway

local notifs = require(script.Parent.notifs)

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

return function(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	local lver = gateway:Invoke('get', 'live_version')
	local cver = gateway:Invoke('get', 'current_version')
	local pn_ = gateway:Invoke('get', 'plugin_name')
	local should_update, really_should_update, update_lock = false, false, false
	
	if lver ~= cver then
		local lvstring = lver:gmatch('%d+%.%d+%.%d+')()
		local cvstring = cver:gmatch('%d+%.%d+%.%d+')()
		
		local lvmstring = lver:gmatch('%d+%.(%d+)%.%d+')()
		local cvmstring = cver:gmatch('%d+%.(%d+)%.%d+')()
		
		local lvmjrstring = lver:gmatch('(%d+)%.%d+%.%d+')()
		local cvmjrstring = cver:gmatch('(%d+)%.%d+%.%d+')()
		
		if lvstring and cvstring then
			local lvp = string.split(lvstring, '.')
			local cvp = string.split(cvstring, '.')
			
			if #lvp == 3 and #cvp == 3 then
				for i = 1, 3 do
					local lvi = tonumber(lvp[i])
					local cvi = tonumber(cvp[i])
					
					if lvi < cvi then
						should_update, really_should_update, update_lock = true, tonumber(lvmstring)+3 < tonumber(cvmstring), tonumber(lvmjrstring)+1 <= tonumber(cvmjrstring)
						break
					elseif lvi > cvi then
						break
					end
				end
			end
			
			if not should_update and lvstring ~= cvstring then
				app.settings.content.update.notice.Text = 'You\'re above the currently distributed version!'
				app.settings.content.update.m.live_version.ver_string.TextColor3 = Color3.fromRGB(85, 170, 255)
				app.settings.content.update.m.live_version.crc.ImageColor3 = Color3.fromRGB(85, 170, 255)
				app.settings.content.update.m.current_version.ver_string.TextColor3 = Color3.fromRGB(51, 255, 102)
				app.settings.content.update.m.current_version.crc.ImageColor3 = Color3.fromRGB(51, 255, 102)
				app.settings.content.update.m.to.Text = ':'
			elseif should_update then
				app.update_available.Visible = true
				
				app.update_available.hitbox.MouseButton1Click:Connect(function()
					gateway:Invoke('post', 'cclick', {id = 'how_to_update'})
				end)
			end
			
			app.settings.content.update.m.live_version.ver_string.Text = lvstring
			app.settings.content.update.m.current_version.ver_string.Text = cvstring
		else
			app.settings.content.update.m.live_version.ver_string.Text = '4.x.x'
			app.settings.content.update.m.current_version.ver_string.Text = '4.x.x'
		end
		
		app.settings.content.update.Visible = true
	else
		app.settings.content.update.Visible = false
	end
	
	if pn_ and (pn_:gmatch('(%.rbxm%a?)$')() or pn_:gmatch('(%.luau?)$')()) then
		if not really_should_update then
			app.dev_build.Visible = true
			app.update_available.Visible = false
			app.dev_build.title.Position = UDim2.new(0,12,0.45,0)
			app.settings.content.opt3_dbg.Visible = true
		end
	else
		--app.settings.content.opt2.Visible = false -- !!
		app.settings.content.opt3_dbg.Visible = false
	end
	
	if really_should_update then
		notifs:banner(widget, 'There are multiple updates available for the plugin. Please update.', 'default', 0)
		app.update_available.crc.ImageColor3 = Color3.fromRGB(255, 0, 0)
		app.update_available.title.TextColor3 = Color3.fromRGB(255, 0, 0)
		app.update_available.title.Text = 'Please update'
	end
	
	if update_lock then
		app:SetAttribute('nav_locked', true)
		app.major_out_of_date.modal.info.subtext.Text = 'Your current installation is too outdated,'
		app.major_out_of_date.modal.info.text.Text = 'please update for the best experience.'
		app.major_out_of_date.modal.info.update.Size = UDim2.new(0,1,0,40)
		app.major_out_of_date.modal.info.update.c.hitbox.MouseButton1Click:Connect(function()
			gateway:Invoke('post', 'cclick', {id = 'how_to_update'})
		end)
		app.major_out_of_date.Visible = true
		app.home.Visible = false
		app.loader.Visible = false
		app.settings.Visible = false
		app.nav.Visible = false
	end
	
	local function refresh()
		app.settings.content.options.option__pdn.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "prioritise_display_names"}) ~= false)
		app.settings.content.options.option__ct.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "compact_title"}) ~= false)
		app.settings.content.options.option__sa.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "show_actions"}) ~= false)
		app.settings.content.options.option__im.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "include_metadata"}) ~= false)
		app.settings.content.options.option__iac.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "insert_at_camera"}) ~= false)
		app.settings.content.options.option__cns.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "simplified_model_names"}) ~= false)
		app.settings.content.options.option__cin.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "compact_identical_names"}) ~= false)
		app.settings.content.options.option__mtd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "use_multithreading"}) ~= false)
		app.settings.content.options.option__vbd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "use_3d_preview"}) ~= false)
	end
	
	app.settings.content.info.title.Text = app.settings.content.info.title.Text:gsub('{live_version}', lver) 
	
	
	app.settings.content.opt.ads.MouseButton1Click:Connect(function()
		 
	end)
	
	app.settings.content.opt2.import.MouseEnter:Connect(function()
		ts:Create(app.settings.content.opt2.import, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.2}):Play()
		app.settings.content.opt2.import.Text = "<u>Import local data</u>"
	end)
	
	app.settings.content.opt2.import.MouseLeave:Connect(function()
		ts:Create(app.settings.content.opt2.import, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.5}):Play()
		app.settings.content.opt2.import.Text = "Import local data"
	end)
	
	app.settings.content.opt2['export'].MouseEnter:Connect(function()
		ts:Create(app.settings.content.opt2['export'], TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.2}):Play()
		app.settings.content.opt2['export'].Text = "<u>Export local data</u>"
	end)

	app.settings.content.opt2['export'].MouseLeave:Connect(function()
		ts:Create(app.settings.content.opt2['export'], TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.5}):Play()
		app.settings.content.opt2['export'].Text = "Export local data"
	end)
	
	app.settings.content.opt2['export'].MouseButton1Click:Connect(function()
		local s, err = pcall(function()
			local t = Instance.new('ModuleScript', workspace)
			t.Name = 'lrc4-ld-export-temp'
			t.Source = 
[[--|LRC|4.4.3|LD|JSON

--<<BEGIN>>--
]]

			local data = {
				settings = {};
				storage = {};
			}

			local targets__settings = {'prioritise_display_names','compact_title','show_actions','include_metadata','insert_at_camera','simplified_model_names','compact_identical_names','use_multithreading','use_3d_preview','recently_loaded'}
			local targets__storage = {'pinned','bookmarked','recent','last_loaded_db','dont_show_again','recently_viewed'}

			notifs:banner(widget, 'Collecting...', 'default', 1)

			for _, v in pairs(targets__settings) do
				data.settings[v] = r.connect.plugin_gateway:Invoke("get","setting", {setting_name = v}) or false
			end

			for _, v in pairs(targets__storage) do
				data.storage[v] = r.connect.plugin_gateway:Invoke("get","setting", {setting_name = v}) or {}
			end

			t.Source ..= http:JSONEncode(data)

			t.Source ..= 
[[

--<<END>>--]]

			selection:Set({t})
			gateway:Invoke('post', 'prompt_save_selection', {file_name = 'lrc4-ld-json-'..tostring(DateTime.now().UnixTimestampMillis)})

			t:Destroy()
		end)
		
		if not s then
			notifs:banner(widget, 'An error occurred while using script(s), please make sure LRC4 can modify scripts and try again.', 'error')
		end
	end)
	
	app.settings.content.opt2.import.MouseButton1Click:Connect(function()
		local s, err = pcall(function()
			local configfile:File = ss:PromptImportFile({'lua'})
			if not configfile then notifs:banner(widget, 'Please select a file to import', 'default', 3) return end
			local contents = configfile:GetBinaryContents()

			--print(configfile:GetBinaryContents())

			if not contents:gmatch('%-%-|LRC|4%.%d+%.%d+[%-%a+%.%d]*|LD|JSON%s+%-%-<<BEGIN>>%-%-%s.*%s%-%-<<END>>%-%-')() then
				warn('invalid format')
				notifs:banner(widget, 'Failed to import: file provided was in an invalid format', 'error', 3)
				return
			end

			task.spawn(function() notifs:banner(widget, 'File passed format validation check, attempting to import...', 'default', 1) end)

			local str = contents:match('%-%-|LRC|4%.%d+%.%d+[%-%a+%.%d]*|LD|JSON%s+%-%-<<BEGIN>>%-%-%s(.*)%s%-%-<<END>>%-%-')
			local data = http:JSONDecode(str)

				if not data then
				notifs:banner(widget, 'Failed to import: could not parse JSON', 'error', 3)
				return
			end

			task.spawn(function() notifs:banner(widget, 'JSON extracted from file and successfully parsed', 'default', 1) end)

			local targets__settings = data.settings
			local targets__storage = data.storage

			for i, v in pairs(targets__settings) do
				r.connect.plugin_gateway:Invoke("post","setting", {setting_name = i, target = v})
			end

			for i, v in pairs(targets__storage) do
				r.connect.plugin_gateway:Invoke("post","setting", {setting_name = i, target = v})
			end

			--print(str)

			refresh()
			script.Parent.home.__content_sync:Fire('lldbupd')
			script.Parent.home.__content_sync:Fire('bookmarked')
			script.Parent.home.__content_sync:Fire('recent')

			task.spawn(function() notifs:banner(widget, 'Success!', 'default', 1) end)
		end)
		
		if not s then
			notifs:banner(widget, 'An unknown error occurred. Check the console for more information.', 'error')
			warn('(lrc4 error trace: ', debug.traceback(), ' : ', err, ')')
			--warn('LRC 4 |', err)
		end
	end)
	
	app.settings.content.opt.ads.MouseEnter:Connect(function()
		ts:Create(app.settings.content.opt.ads, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.2}):Play()
		app.settings.content.opt.ads.Text = "<u>Apply default settings</u>"
	end)
	
	app.settings.content.opt.ads.MouseLeave:Connect(function()
		ts:Create(app.settings.content.opt.ads, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.5}):Play()
		app.settings.content.opt.ads.Text = "Apply default settings"
	end)
	
	app.settings.content.opt.rad.MouseEnter:Connect(function()
		ts:Create(app.settings.content.opt.rad, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.2}):Play()
		app.settings.content.opt.rad.Text = "<u>Reset all data</u>"
	end)

	app.settings.content.opt.rad.MouseLeave:Connect(function()
		ts:Create(app.settings.content.opt.rad, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextTransparency = 0.5}):Play()
		app.settings.content.opt.rad.Text = "Reset all data"
	end)
	
	r.connect.slider_opt.Event:Connect(function(sn, val)
		--print(sn,val)
		if sn == "option__pdn" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "prioritise_display_names", target = val})
		elseif sn == "option__ct" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "compact_title", target = val})
			if val then widget.Title = "LRC4" else widget.Title = "Load Roblox Characters" end
		elseif sn == "option__sa" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "show_actions", target = val})
		elseif sn == "option__im" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "include_metadata", target = val})
		elseif sn == "option__iac" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "insert_at_camera", target = val})
		elseif sn == "option__cns" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "simplified_model_names", target = val})
		elseif sn == "option__cin" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "compact_identical_names", target = val})
		elseif sn == "option__mtd" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "use_multithreading", target = val})
		elseif sn == "option__vbd" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "use_3d_preview", target = val})
		elseif sn == "option__svr" then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "save_recents", target = val})
			if val then app.home.content.carousel__recent.Visible = true app.home.content.header_recent.Visible = true else app.home.content.carousel__recent.Visible = false app.home.content.header_recent.Visible = false end
		end
	end)
	
	refresh()
	
	app.settings.content.opt.ads.MouseButton1Click:Connect(function()
		local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "Are you sure you want to reset your settings?"; prompt_desc = "Click continue to confirm this action."; prompt_id = "ADSCONF"})
		
		if res == true then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "prioritise_display_names", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "compact_title", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "show_actions", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "include_metadata", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "insert_at_camera", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "simplified_model_names", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "compact_identical_names", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "use_multithreading", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "use_3d_preview", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "save_recents", target = true})
			
			app.settings.content.options.option__pdn.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "prioritise_display_names"}) or false)
			app.settings.content.options.option__ct.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "compact_title"}) or false)
			app.settings.content.options.option__sa.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "show_actions"}) or false)
			app.settings.content.options.option__im.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "include_metadata"}) or false)
			app.settings.content.options.option__iac.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "insert_at_camera"}) or true)
			app.settings.content.options.option__cns.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "simplified_model_names"}) or false)
			app.settings.content.options.option__cin.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "compact_identical_names"}) or false)
			app.settings.content.options.option__mtd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "use_multithreading"}) or false)
			app.settings.content.options.option__vbd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "use_3d_preview"}) or false)
			app.settings.content.options.option__vbd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "save_recents"}) or false)
		end
	end)
	
	app.settings.content.opt.rad.MouseButton1Click:Connect(function()
		local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "CLEAR ALL PLUGIN DATA"; prompt_desc = "Are you sure you want remove all the plugin data (including settings) from your local computer permanently?"; prompt_id = "RADCONF"; force_show = true;})

		if res == true then
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "pinned", target = {}})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "bookmarked", target = {}})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "recent", target = {}})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "last_loaded_db", target = {}})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "dont_show_again", target = {}})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "simplified_model_names", target = false})
			
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "prioritise_display_names", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "compact_title", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "show_actions", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "include_metadata", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "insert_at_camera", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "compact_identical_names", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "use_multithreading", target = false})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "use_3d_preview", target = true})
			r.connect.plugin_gateway:Invoke("post", "setting", {setting_name = "save_recents", target = true})
			
			
			app.settings.content.options.option__pdn.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "prioritise_display_names"}) or false)
			app.settings.content.options.option__ct.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "compact_title"}) or false)
			app.settings.content.options.option__sa.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "show_actions"}) or false)
			app.settings.content.options.option__im.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "include_metadata"}) or false)
			app.settings.content.options.option__iac.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "insert_at_camera"}) or true)
			app.settings.content.options.option__cns.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "simplified_model_names"}) or false)
			app.settings.content.options.option__cin.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "compact_identical_names"}) or false)
			app.settings.content.options.option__mtd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "use_multithreading"}) or false)
			app.settings.content.options.option__vbd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "use_3d_preview"}) or false)
			app.settings.content.options.option__vbd.__slider:SetAttribute("state", r.connect.plugin_gateway:Invoke("get","setting", {setting_name = "save_recents"}) or false)
			
			r.connect.plugin_gateway:Invoke("post", "restart")
		end
	end)
	
	--app.settings.content.opt3_dbg.void.MouseButton1Click:Connect(function()
	--	local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "[DEBUG]"; prompt_desc = "CONFIRM: VOID ALL LOCAL DATA"; prompt_id = "DEBUG__CONFVOID"; force_show = true;})

	--	if res == true then
	--		local targets__settings = {'prioritise_display_names','compact_title','show_actions','include_metadata','insert_at_camera','simplified_model_names','compact_identical_names','use_multithreading','use_3d_preview'}
	--		local targets__storage = {'pinned','bookmarked','recent','last_loaded_db','dont_show_again','recently_viewed'}

	--		for _, v in pairs(targets__settings) do
	--			r.connect.plugin_gateway:Invoke("post","setting", {setting_name = i, target = nil})
	--		end

	--		for _, v in pairs(targets__storage) do
	--			r.connect.plugin_gateway:Invoke("post","setting", {setting_name = i, target = nil})
	--		end
	--	end
	--end) -- turns out that nil isnt allowed
	
	script.__recheck_v.Event:Connect(function()
		if gateway:Invoke('get', 'is_outdated') then
			if pn_ and not (pn_:gmatch('(%.rbxm%a?)$')() and not pn_:gmatch('(%.luau?)$')()) then
				app.update_available.Visible = true
			end
		end
	end)
	
	app.settings.content.issues_nsl.Visible = false
	app.settings.content.issues_sl.Visible = false
	
	
	local can = true
	local s, err = pcall(function()
		local lplr = players:GetPlayerByUserId(sts:GetUserId())
		
		if not lplr then can = false return true end
		
		local pi = ps:GetPolicyInfoForPlayerAsync(lplr)
		
		if pi and pi.AllowedExternalLinkReferences and table.find(pi.AllowedExternalLinkReferences, "X") then
			app.settings.content.issues_sl.Visible = true
			app.settings.content.issues_sl.m2.title.Text = app.settings.content.issues_sl.m2.title.Text:gsub("%[SLINKREF_T%]", "Twitter")
			app.settings.content.issues_sl.m2.title.Size = UDim2.new(0,1000,app.settings.content.issues_sl.m2.title.Size.Y.Scale,app.settings.content.issues_sl.m2.title.Size.Y.Offset)
			app.settings.content.issues_sl.m2.title.Size = UDim2.new(0,app.settings.content.issues_sl.m2.title.TextBounds.X,app.settings.content.issues_sl.m2.title.Size.Y.Scale,app.settings.content.issues_sl.m2.title.Size.Y.Offset)
		else
			app.settings.content.issues_sl.Visible = false
			app.settings.content.issues_nsl.Visible = true
			app.settings.content.issues_nsl.m2.title.Size = UDim2.new(0,1000,app.settings.content.issues_nsl.m2.title.Size.Y.Scale,app.settings.content.issues_nsl.m2.title.Size.Y.Offset)
			app.settings.content.issues_nsl.m2.title.Size = UDim2.new(0,app.settings.content.issues_nsl.m2.title.TextBounds.X,app.settings.content.issues_nsl.m2.title.Size.Y.Scale,app.settings.content.issues_nsl.m2.title.Size.Y.Offset)
		end
	end)
	
	if not s then
		app.settings.content.issues_sl.Visible = false
		app.settings.content.issues_nsl.Visible = true
		warn("LRC4 | Unhandled error getting policy information: ", err)
	end
	
	if not can then
		app.settings.content.issues_sl.Visible = false
		app.settings.content.issues_nsl.Visible = true
	end
end