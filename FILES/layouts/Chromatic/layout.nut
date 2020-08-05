////////////////////////////////////////////////////////////////////////////////////////////////////////
//Created by Hursty March 2017
//Big thanks for help with the layout.nut to David Marti and Willems Davy

//Make sure your display name matches the cabinet image name.

////////////////////////////////////////////////////////////////////////////////////////////////////////   

class UserConfig {
</ label="--------  Main theme layout  --------", help="Show or hide additional images", order=1 /> uct1="select below";
   </ label="Select wheel location", help="Select wheel location", options="wheel_left,wheel_right", order=4 /> enable_list_type="wheel_left";
   </ label="Select spinwheel art", help="The artwork to spin", options="wheel", order=5 /> orbit_art="wheel";
   </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=6 /> transition_ms="25";  
   </ label="Wheel fade time", help="Time in milliseconds to fade the wheel.", options="Off,2500,5000,7500,10000,12500,15000,17500,20000,22500,25000,27500,30000", order=7 /> wheel_fade_ms="5000";
</ label=" ", help=" ", options=" ", order=8 /> divider1="";
</ label="--------    Extra images     --------", help="Show or hide additional images", order=9 /> uct2="select below";
   </ label="Enable box art", help="Select box art", options="Yes,No", order=10 /> enable_gboxart="No"; 
   </ label="Enable cartridge art", help="Select cartridge art", options="Yes,No", order=11 /> enable_gcartart="No"; 
</ label=" ", help=" ", options=" ", order=12 /> divider2="";
</ label="--------    Game info box    --------", help="Show or hide game info box", order=13 /> uct5="select below";
   </ label="Enable game information", help="Show game information", options="Yes,No", order=14 /> enable_ginfo="Yes";
   </ label="Enable text frame", help="Show text frame", options="Yes,No", order=15 /> enable_frame="Yes"; 
</ label=" ", help=" ", options=" ", order=16 /> divider5="";
</ label="--------    Miscellaneous    --------", help="Miscellaneous options", order=17 /> uct6="select below";
   </ label="Enable random text colors", help=" Select random text colors.", options="Yes,No", order=18 /> enable_colors="Yes";
   </ label="Enable monitor static effect", help="Show static effect when snap is null", options="Yes,No", order=19 /> enable_static="Yes"; 
}




local my_config = fe.get_config();
local flx = fe.layout.width=640;
local fly = fe.layout.height=480;
local flw = fe.layout.width;
local flh = fe.layout.height;
//fe.layout.font="Roboto";

//for fading of the wheel
first_tick <- 0;
stop_fading <- true;
wheel_fade_ms <- 0;
try {	wheel_fade_ms = my_config["wheel_fade_ms"].tointeger(); } catch ( e ) { }

// modules
fe.load_module("fade");
fe.load_module( "animate" );


// Load the cabinet layer using the DisplayName for matching 
local b_art = fe.add_image("Background1.png", 0, 0, flw, flh );
b_art.alpha=255;

// Video Preview or static video if none available
// remember to make both sections the same dimensions and size
if ( my_config["enable_static"] == "Yes" )
{
//adjust the values below for the static preview video snap
   const SNAPBG_ALPHA = 200;
   local snapbg=null;
   snapbg = fe.add_image( "static.mp4", flx*0.264, fly*0.1314, flw*0.7151, flh*0.718 );
   snapbg.trigger = Transition.EndNavigation;
   snapbg.skew_y = 0;
   snapbg.skew_x = 0;
   snapbg.pinch_y = 0;
   snapbg.pinch_x = 0;
   snapbg.rotation = 0;
   snapbg.set_rgb( 155, 155, 155 );
   snapbg.alpha = SNAPBG_ALPHA;
}
 else
 {
 local temp = fe.add_text("", flx*0.155, fly*0.07, flw*0.69, flh*0.57 );
 temp.bg_alpha = SNAPBG_ALPHA;
 }

//create surface for snap
local surface_snap = fe.add_surface( 640, 480 );
local snap = FadeArt("snap", 0, 0, 640, 480, surface_snap);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = false;

//now position and pinch surface of snap
//adjust the below values for the game video preview snap
surface_snap.set_pos(0, 0, flw, flh);
surface_snap.skew_y = 0;
surface_snap.skew_x = 0;
surface_snap.pinch_y = 0;
surface_snap.pinch_x = 0;
surface_snap.rotation = 0;


// Load the cabinet layer using the DisplayName for matching 
local b_art = fe.add_image("Frame1.png", 0, 0, flw, flh );
b_art.alpha=255;

// Load the cabinet layer using the DisplayName for matching 
local b_art = fe.add_image("cabinets/[DisplayName]", 0, 0, flw, flh );
b_art.alpha=255;

// The following section sets up what type and wheel and displays the users choice

//vertical wheel with three wheels shown horizontal
if ( my_config["enable_list_type"] == "wheel_left" )
{
fe.load_module( "conveyor" );

local wheel_x = [ flx*0.028, flx* 0.028, flx* 0.028, flx* 0.028, flx* 0.028, flx* 0.028, flx* 0.0075, flx* 0.028, flx* 0.028, flx* 0.028, flx* 0.028, flx* 0.028, ]; 
local wheel_y = [ -fly*0.5, -fly*0.4, -fly*0.3, -fly*0.2, fly*0.235, fly*0.194, fly*0.388, fly*0.69, fly*0.41 fly*1.2, fly*1.3, fly*1.4, ];
local wheel_w = [ flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.22, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, ];
local wheel_a = [  255,  255,  255,  255,  255,  255, 255,  255,  255,  255,  255,  255, ];
local wheel_h = [  flh*0.17,  flh*0.17,  flh*0.17,  flh*0.17,  flh*0.17,  flh*0.17, flh*0.22,  flh*0.17,  flh*0.17,  flh*0.17,  flh*0.17,  flh*0.17, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 8;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

conveyor <- Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}


//vertical wheel with three wheels shown horizontal
if ( my_config["enable_list_type"] == "wheel_right" )
{
fe.load_module( "conveyor" );

local wheel_x = [ flx*0.84, flx* 0.84, flx* 0.84, flx* 0.84, flx* 0.82, flx* 0.79, flx* 0.64, flx* 0.79, flx* 0.82, flx* 0.84, flx* 0.84, flx* 0.84, ]; 
local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.400, fly*0.565, fly*0.680 fly*0.795, fly*0.910, fly*0.99, ];
local wheel_w = [ flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.16, flw*0.20, flw*0.30, flw*0.20, flw*0.16, flw*0.13, flw*0.13, flw*0.13, ];
local wheel_a = [  255,  255,  255,  255,  255,  255, 255,  255,  255,  255,  255,  255, ];
local wheel_h = [  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.138,  flh*0.150, flh*0.204,  flh*0.138,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 8;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

conveyor <- Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}



// Game information to show inside text box frame
if ( my_config["enable_ginfo"] == "Yes" )
{

//add frame to make text standout 
if ( my_config["enable_frame"] == "Yes" )
{
local frame = fe.add_image( "frame.png", 0, fly*0.94, flw, flh*0.06 );
frame.alpha = 255;
}

//Year text info
local texty = fe.add_text("[Year]", flx*0.18, fly*0.937, flw*0.13, flh*0.055 );
texty.set_rgb( 255, 255, 255 );
//texty.style = Style.Bold;
//texty.align = Align.Left;

//Title text info
local textt = fe.add_text( "[Title]", flx*0.315, fly*0.942, flw*0.6, flh*0.025  );
textt.set_rgb( 225, 255, 255 );
//textt.style = Style.Bold;
textt.align = Align.Left;
textt.rotation = 0;
textt.word_wrap = false;

//Emulator text info
local textemu = fe.add_text( "[Emulator]", flx* 0.315, fly*0.967, flw*0.6, flh*0.025  );
textemu.set_rgb( 225, 255, 255 );
//textemu.style = Style.Bold;
textemu.align = Align.Left;
textemu.rotation = 0;
textemu.word_wrap = false;

//display filter info
local filter = fe.add_text( "[ListFilterName]: [ListEntry]-[ListSize]  [PlayedCount]", flx*0.7, fly*0.962, flw*0.3, flh*0.02 );
filter.set_rgb( 255, 255, 255 );
//filter.style = Style.Italic;
filter.align = Align.Right;
filter.rotation = 0;

//category icons 

local glogo1 = fe.add_image("glogos/unknown1.png", flx*0.155, fly*0.945, flw*0.045, flh*0.05);
glogo1.trigger = Transition.EndNavigation;

class GenreImage1
{
    mode = 1;       //0 = first match, 1 = last match, 2 = random
    supported = {
        //filename : [ match1, match2 ]
        "action": [ "action" ],
        "adventure": [ "adventure" ],
        "fighting": [ "fighting", "fighter", "beat'em up" ],
        "platformer": [ "platformer", "platform" ],
        "puzzle": [ "puzzle" ],
        "maze": [ "maze" ],
		"paddle": [ "paddle" ],
		"rhythm": [ "rhythm" ],
		"pinball": [ "pinball" ],
		"racing": [ "racing", "driving" ],
        "rpg": [ "rpg", "role playing", "role-playing" ],
        "shooter": [ "shooter", "shmup" ],
        "sports": [ "sports", "boxing", "golf", "baseball", "football", "soccer" ],
        "strategy": [ "strategy"]
    }

    ref = null;
    constructor( image )
    {
        ref = image;
        fe.add_transition_callback( this, "transition" );
    }
    
    function transition( ttype, var, ttime )
    {
        if ( ttype == Transition.ToNewSelection || ttype == Transition.ToNewList )
        {
            local cat = " " + fe.game_info(Info.Category, var).tolower();
            local matches = [];
            foreach( key, val in supported )
            {
                foreach( nickname in val )
                {
                    if ( cat.find(nickname, 0) ) matches.push(key);
                }
            }
            if ( matches.len() > 0 )
            {
                switch( mode )
                {
                    case 0:
                        ref.file_name = "glogos/" + matches[0] + "1.png";
                        break;
                    case 1:
                        ref.file_name = "glogos/" + matches[matches.len() - 1] + "1.png";
                        break;
                    case 2:
                        local random_num = floor(((rand() % 1000 ) / 1000.0) * ((matches.len() - 1) - (0 - 1)) + 0);
                        ref.file_name = "glogos/" + matches[random_num] + "1.png";
                        break;
                }
            } else
            {
                ref.file_name = "glogos/unknown1.png";
            }
        }
    }
}
GenreImage1(glogo1);


// random number for the RGB levels
if ( my_config["enable_colors"] == "Yes" )
{
function brightrand() {
 return 255-(rand()/255);
}

local red = brightrand();
local green = brightrand();
local blue = brightrand();

// Color Transitions
fe.add_transition_callback( "color_transitions" );
function color_transitions( ttype, var, ttime ) {
 switch ( ttype )
 {
  case Transition.StartLayout:
  case Transition.ToNewSelection:
  red = brightrand();
  green = brightrand();
  blue = brightrand();
  //listbox.set_rgb(red,green,blue);
  texty.set_rgb (red,green,blue);
  textt.set_rgb (red,green,blue);
  textemu.set_rgb (red,green,blue);
  break;
 }
 return false;
 }
}}


// Box art to display, uses the emulator.cfg path for boxart image location
if ( my_config["enable_gboxart"] == "Yes" )
{
local boxart = fe.add_artwork("boxart", flx*0.245, fly*0.72, flw*0.1, flh*0.17 );
}

if ( my_config["enable_gcartart"] == "Yes" )
{
local cartart = fe.add_artwork("cartart", flx*0.32, fly*0.83, flw*0.05, flh*0.08 );
}

