macro_lib = {}
macro_lib.author = "smokingplaya"
macro_lib.version = "0.1.0"

scale = ScreenScale

meta_pl = FindMetaTable("Player")
meta_ent = FindMetaTable("Entity")
meta_panel = FindMetaTable("Panel")

-- log

LOG_OK = 1
LOG_INFO = 2
LOG_ERROR = 3

local notify_types = {
	[LOG_OK] = "OK",
	[LOG_INFO] = "INFO",
	[LOG_ERROR] = "ERROR"
}

local colors = {
	[LOG_OK] = Color(50, 240, 70),
	[LOG_INFO] = Color(50, 160, 240),
	[LOG_ERROR] = Color(240, 50, 50)
}

function log(enum, text)
	--MsgC(colors[enum], "[" .. notify_types[enum] .. "] ", color_white, text, "\n")
	MsgC(colors[enum], notify_types[enum] .. "  ", color_white, text, "\n")
end

-- includes

cl = CLIENT
sv = SERVER

function include_cl(path)
	if sv then
		AddCSLuaFile(path)
		return
	end

	return include(path)
end


function include_sh(path)
	if sv then
		AddCSLuaFile(path)
	end

	return include(path)
end

function include_sv(path)
	if sv then
		return include(path)
	end
end

-- println
function println(...)
	for _, obj in ipairs({...}) do
		local fn = istable(obj) and PrintTable or print
		fn(obj)
	end
end

-- colors
macro_lib.colors = {}

function cache_color(ind, col_or_r, g, b, a)
	macro_lib.colors[ind] = IsColor(col_or_r) and col_or_r or Color(r, g, b, a)
end

function get_cache_color(ind)
	return macro_lib.colors[ind]
end

-- fonts
if cl then
	macro_lib.fonts = {}

	function create_font(name, size, font)
		surface.CreateFont("ml_" .. name, {
			font = font or "Manrope",
			size = ScreenScale(size/2),
			extended = true
		})

		macro_lib.fonts[#macro_lib.fonts+1] = {name, size, font}
	end

	hook.Add("OnScreenSizeChanged", "ml_fonts", function()
		for _, t in ipairs(macro_lib.fonts) do
			create_font(t[1], t[2], t[3])
		end
	end)

	-- panels
	--[[
			Functions:
				panel:Override(name, fn)
				panel:Setup(fn)
	]]

	local panel_list = {}

	local vgui_create = vgui.Create

	function vgui.Create(...)
		local panel = vgui_create(...)
		panel_list[#panel_list+1] = panel
		return panel
	end

	timer.Create("ml_panel_check", 5, 0, function()
		for k, v in ipairs(panel_list) do
			if not IsValid(v) then
				panel_list[k] = nil
			end
		end
	end)

	function meta_panel:Override(name, fn)
		local old_fn = self[name]
		if not old_fn then return end
		self[name] = function(...)
			old_fn()
			fn()
		end
	end

	function meta_panel:Setup(fn)
		if not fn or not isfunction(fn) then return end

		self.m_SetupFunction = fn
		fn(self, self:GetParent():GetWide(), self:GetParent():GetTall())
	end

	local function reaction_on_changes()
		for _, p in ipairs(panel_list) do
			if not IsValid(p) then continue end
			local setup = p.m_SetupFunction
			if not setup then continue end
			setup(p, p:GetParent():GetWide(), p:GetParent():GetTall())
		end
	end

	hook.Add("OnScreenSizeChanged", "ml_panels", reaction_on_changes)

	-- draw lib

	function draw.Box(x, y, w, h, col)
		surface.SetDrawColor(col)
		surface.DrawTexturedRect(x, y, w, h)
	end

	function draw.Outline(x, y, w, h, col, thickness)
		surface.SetDrawColor(col)
		surface.DrawOutlinedRect(x, y, w, h, thickness)
	end
end

-- complete hook library

function hook.GetData(name, ...)
	local args = {}
	local tab = hook.GetTable()[name]

	if not tab then return args end -- if we don't have a hook, we return an empty table

	for _, fn in pairs(tab) do
		local fn_args = {fn(...)}
		args[#args+1] = fn_args
	end

	return args
end
