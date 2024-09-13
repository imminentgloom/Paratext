--            PARATEXT
-- 
--     1st edition, 1st version
--      @imminent gloom 2024
-- 
--   mods: Nb, Fx, Fx_Postscript
--       font: norns.ttf, 8p
--      screen: b/w, 128x64p
--
--
--            PREFACE
--
-- PARATEXT is a collection of 
-- tools that surround a text; a
-- live input or a voice provided
-- by n.b. et al.
--
-- Preceding the text are two
-- sequencers, one based on 
-- earthsea, another on a faded
-- memory of a borrowed 626.
--
-- An adaption of delayyyyyyyy
-- acts as a postscript.
--
-- Scripts have a suprising
-- number of paratextual layers:
--
--  + a post on lines
--  + a github repository
--  + a manual
--  + demonstration videos
--  + an entry in maiden
--  + a title in a list
--  + an introductory text
--
-- This seems to closely mirror
-- the structure of ease
-- through complexity found
-- througout the monome
-- ecosystem. And, I think, it
-- invites exploration through
-- addition and metaphor. 
--
--
--          NOTES ON USE
--
-- There are two pages, Volumes
-- 1 and 2. Encoders change the
-- delay, each button can be
-- held. Button one shifts to
-- Volume 2, which is much the
-- same as the fisrt, exept the
-- buttons reset and switch
-- between the sequencers.
--
--       ACKNOWLEDGEMENTS
--
--   cfdrake for delayyyyyyyy
--      monome for objects
--     whimsical raps for JF
--  sixolet for fx and n.b. et al.
--         zbs for oilcan

-- ---- ---- ----  ---- ---- ---- 


g = grid.connect()

include("lib/interface")
include("lib/keys")
include("lib/drums")

nb = include("nb/lib/nb")

lattice = require("lattice")
pattern_time = require ("pattern_time")


persist = true
k1_held = false
k2_held = false
k3_held = false

function init()
	params:add_separator("paratext: sequencers")
	params:add_option("sequencer", "sequencer",{"keys", "drums"}, 1)
	params:set_action("sequencer", function(x) sequencer = params:string("sequencer") end)
	params:add_option("crow", "crow", {"off", "keys: cv/gate 1+2", "drum: gates 1-4"}, 1)
	
	params:add_separator("paratext: voices")
	nb.voice_count = 5
	nb:init()
	nb:add_param("voice_keys", "keys")
	nb:add_param("voice_drum_1", "drums - track 1")
	nb:add_param("voice_drum_2", "drums - track 2")
	nb:add_param("voice_drum_3", "drums - track 3")
	nb:add_param("voice_drum_4", "drums - track 4")
	nb:add_player_params()

	setup_lattice()

	keys_init()
	drums_init()

	pattern = pattern_time.new()

	g_clk = clock.run(grid_redraw_clock)
end

function setup_lattice()
	my_lattice = lattice:new{
        auto = true,
        ppqn = 480,
		enabled = true
    }
	
	sprocket_drum_1 = my_lattice:new_sprocket{
        action = t_drum_1(t),
        division = 1,
        enabled = true
    }
	
	sprocket_drum_2 = my_lattice:new_sprocket{
        action = t_drum_2(t),
        division = 1,
        enabled = true
    }
    
    sprocket_drum_3 = my_lattice:new_sprocket{
        action = t_drum_3(t),
        division = 1,
        enabled = true
    }
    
    sprocket_drum_4 = my_lattice:new_sprocket{
        action = t_drum_4(t),
        division = 1,
        enabled = true
    }

	my_lattice:start()
	sprocket_drum_1:start()
	sprocket_drum_2:start()
	sprocket_drum_3:start()
	sprocket_drum_4:start()
end

-- called by fx_postscript after loading so we know it is safe to laod the pset and complete init
function FxPostscript_init() 
    if persist == true then
		nb:stop_all()
  	    params:read("/home/we/dust/data/paratext/state.pset")
    else
        setup_fx_defaults()
    end
    
    params:set("fx_postscript_slot", 0) -- seems to need this for insert-mode to take
    params:set("fx_postscript_slot", 4) -- sets postscript as insert
	params:set("fx_postscript_slot_drywet", 0.4)
	params:bang()
end

function setup_fx_defaults()

   params:set("fx_postscript_time", 0.55)
   params:set("fx_postscript_feedback", 80)
   params:set("fx_postscript_send", 20)
   params:set("fx_postscript_slot_drywet", 0.4)  
   params:set("fx_postscript_lp", 5000)
   params:set("fx_postscript_width", 0)
end

-- utilities
function modulo(num, mod)
	-- % to index 1-based lists
	return ((num - 1) % mod) + 1
end

-- draw interface, see /lib/interface.lua
function redraw()
	screen.clear()
	draw_interface()
	screen.update()
end

-- draw grid using active sequencer, see /lib/keys.lua or /lib/drums.lua
function grid_redraw_clock()
	while true do
		clock.sleep(1/60) -- fps
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

-- send keypresses to active sequencer
function g.key(x, y, z)
	if sequencer == "keys" then
        grid_press_keys(x, y, z)
    elseif sequencer == "drums" then
        grid_press_drums(x, y, z)    
    end
end

-- keys control fx and select sequencer
function key(n,z)
	if z == 1 then
		if n == 1 then k1_held = true end 
		if n == 2 then k2_held = true end
		if n == 3 then k3_held = true end
	else
		if n == 1 then k1_held = false end
		if n == 2 then k2_held = false end
		if n == 3 then k3_held = false end
	end
	
	if k1_held == false then
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

	elseif k1_held == true then
		if n == 2 then
			if z == 1 then
								
			end
		end
		
		if n == 3 then
			if z == 1 then
				local val = params:get("sequencer")
				val = ((val - 1) % 2) + 1
				--val = modulo(val + 1, 2)
				params:set("sequencer", val)
			end				
		end
	end

	redraw()
end

-- encoders set fx prarmeters
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

-- oh shit!
function nb_panic()
	nb:stop_all()
end

-- pps
function cleanup()
	stop_keys()
	stop_drums()
	if persist == true then
  	    params:write("/home/we/dust/data/paratext/state.pset")
    end
end