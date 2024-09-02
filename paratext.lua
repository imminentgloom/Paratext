--            PARATEXT
-- 
--     1st edition, 1st version
--      @imminent gloom 2024
-- 
--   mods: Nb, Fx, Fx_Postscript
--        font: 04B_03, 8p
--      screen: b/w, 128x64p
 
-- ---- ---- ----  ---- ---- ---- 

g = grid.connect()

nb = include("nb/lib/nb")
lattice = require("lattice")


persist = true
k1_held = false


function init()
	nb.voice_count = 1
	nb:init()
	nb:add_param("voice", "Track 1")
	nb:add_player_params()
	
	clock.run(grid_redraw_clock)
	clock.run(seq_clock)
	
	my_lattice = lattice:new{
        auto = true,
        ppqn = 480
    }
	
	track_keys = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
	
	track_drum_1 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
	
	track_drum_2 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
    
    track_drum_3 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
    
    track_drum_3 = my_lattice:new_sprocket{
        action = function(x) end,
        division = 1,
        enabled = true
    }
	params_init()
end

function FxPostscript_init() 
    if persist == true then
  	    params:read("/home/we/dust/data/paratext/state.pset")
    else
        setup_fx_defaults()
    end
    
    params:set("voice", 2) -- set this to the number that points to you desired voice
    params:set("fx_postscript_slot", 0) -- seems to need this for insert-mode to take
    params:set("fx_postscript_slot", 4)
    end

function setup_fx_defaults()
   params:set("fx_postscript_slot_drywet", 0.4)
   params:set("fx_postscript_send", 20)
   params:set("fx_postscript_time", 0.55)
   params:set("fx_postscript_feedback", 80)
   params:set("fx_postscript_lp", 5000)
   params:set("fx_postscript_width", 0)
end

function params_init()
	--params:add_control("id", "name", controlspec.new(min,max,"lin",step,default,"unit"))
	--params:set_action("id", function(x)  end)
	
	params:add_option("sequencer", "sequencer",{"keys", "drums"}, 1)
	params:set_action("sequencer", function(x) sequencer = x end)

end

function redraw()
	screen.clear()
	draw_logo()
	draw_params()
	screen.update()
end

function draw_logo()
	screen.font_face(1)
	screen.font_size(16)
	screen.level(15)
	screen.move(0, 20)
	screen.text("paratext")
end

function draw_params()
	screen.font_size(8)
	screen.font_face(1)
	local l1 = 50
	local l2 = 60
	local p1 = 0
	local p2 = 65
  
	if k1_held then
    	screen.move(p1, l1)
    	draw_param("Mix", params:get("fx_postscript_slot_drywet") * 100 .. " %")

    	screen.move(p2, l2)
    	draw_param("<->", params:string("fx_postscript_width"))

    	screen.move(p1, l2)
		draw_param("LP", params:string("fx_postscript_lp"))
	else
		screen.move(p1, l1)
    	draw_param("Time", params:string("fx_postscript_time"))

		screen.move(p2, l2)
		draw_param("Send", params:string("fx_postscript_send"))

		screen.move(p1, l2)
		draw_param("FB", params:string("fx_postscript_feedback"))
	end
end

function draw_param(display_name, name)
	screen.level(15)
	screen.text(display_name .. ": ")
	screen.level(3)
	screen.text(name)
end

function grid_redraw_clock()
	while true do
		clock.sleep(1/30)
		if grid_dirty then
			grid_redraw()
			grid_dirty = false
		end
	end
end

function grid_redraw()
	g:all(0)
	if sequencer == "keys" then
	    grid_draw_keys()
	else
	    grid_draw_drums()
	end
	g:refresh()
end

function grid_draw_keys()
    
end

function grid_draw_drums()
    
end

	
function g.key(x, y, z)

    if sequencer == "keys" then
        grid_press_keys(x, y, z)
    else
        grid_press_drums(x, y, z)    
    end

--[[
local note = 24
    note = note + x
    note = note + 5 * (8 - y)
    local player = params:lookup_param("voice"):get_player()
    if z == 1 then
        player:note_on(note, 1)
    else
        player:note_off(note)
    end
]]--    

end

function grid_press_keys(x, y, z)
    
end

function grid_press_drums(x, y, z)
    
end


function key(n,z)
	if n == 1 then
		if z == 1 then
			k1_held = true
		else
			k1_held = false
		end
	end
		
	if n == 2 then
		if z == 1 then
			prev_feedback = params:get("fx_postscript_feedback")
			params:set("fx_postscript_feedback", prev_feedback * 0.75)
		else
			params:set("fx_postscript_feedback", prev_feedback)
		end
	end
	
	if n == 3 then
		if z == 1 then
			prev_send = params:get("fx_postscript_send")
			params:set("fx_postscript_send", 100)
		else
			params:set("fx_postscript_send", prev_send)
		end
	end
	
	redraw()
end


function enc(n,d)
	if k1_held then
		if n == 1 then 
			params:delta("fx_postscript_slot_drywet",d)
		elseif n == 2 then
			params:delta("fx_postscript_lp",d)
		elseif n == 3 then
			params:delta("fx_postscript_width",d)
		end
	else
		if n == 1 then 
			params:delta("fx_postscript_time",d)
		elseif n == 2 then
			params:delta("fx_postscript_feedback",d)
		elseif n == 3 then
			params:delta("fx_postscript_send",d)
		end
	end
	redraw()
end

-- Sequencers: Common

function seq_clock()
    
end




function cleanup()
	if persist == true then
  	    params:write("/home/we/dust/data/paratext/state.pset")
    end
end