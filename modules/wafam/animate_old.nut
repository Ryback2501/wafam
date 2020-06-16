/*
NOTE: I discarded this approach because I found some limitations trying to play multiple animations on different properties
of the same object simultaneously (position, width and height).

This is the old version of the animate module. This version extends the original <animate> module included with Attract Mode,
adding some functionality to make easier launching animations on demand.
*/

//This module extends the <animate> module, so it is loaded at the begining.
fe.load_module("animate");

/*
Adds the animation to the animation core and returns it. This allows to create an animation, add it to the animation
core and keep its reference in a single line of code.

Example:
local my_anim = add_animation(PropertyAnimation(item, { property = "alpha", start = 255, end = 0, time = 150 } ));
*/
function add_animation(anim)
{
    animation.add(anim);
    return anim;
}

/*
Adds the slots needed to run the animation on demand to the table with the configuration of the animation.

Parameters:
- config: The configuration of the animation.

Example:
local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
local my_anim = PropertyAnimation(item, setup_animation(my_config)));

Example:
local my_other_config = { property = "x", start = 100, end = 200, time = 350 };
local my_other_anim = add_animation(PropertyAnimation(another_item, setup_animation(my_other_config))));
*/
function setup_animation(config)
{
    config.play <- false;

    if("onStart" in config)
    {
        local onstart = config.onStart;
        config.onStart <- function(anim) { anim.config.play = false; onstart(anim); };
    }
    else
    {
        config.onStart <- function(anim) { anim.config.play = false; };
    }

    config.when <- function(anim) { return anim.config.play; };
    return config;
}

/*
Plays the animation passed as a parameter. The animation needs a configuration set up with the setup_animation method
and must be added to the animation core.

Parameters:
- anim: The animation to play.

Example:
local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
local my_anim = add_animation(PropertyAnimation(item, setup_animation(my_config))));
play_animation(my_anim);
*/
function play_animation(anim)
{
    anim.config.play = true;
}

/*
Plays an animation and, when it finishes, runs a function. It will only work with animations which configuration
tables were setup with `setup_animation`. This method allows to re-use an animation and to run different functions
with different calls. It doesn't remove the functionality of the `onStop` property in the configuration of the
animation, if it was added.

Parameters:
- anim: The animation to play first.
- func: The function to run when the animation finishes.

Example:
local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
local my_anim = add_animation(PropertyAnimation(item, setup_animation(my_config))));

local my_other_config = {
    property = "alpha", start = 255, end = 0, time = 150,
    onStop = function(anim) { ::print("Code that will run always when the animation stops."); }
};
local my_other_anim = add_animation(PropertyAnimation(item, setup_animation(my_other_config))));

play_animation_and_run(my_anim, function() { ::print("This code runs after the animation stops.\n"); });
play_animation_and_run(my_other_anim, function() { ::print("This code runs after onStop finishes.\n"); });
*/
function play_animation_and_run(anim, func)
{
    
    if("afterOnStop" in anim.config == false)
    {
        if("onStop" in anim.config)
        {
            local onstop = anim.config.onStop;
            anim.config.onStop <- function(anim)
            {
                onstop(anim);
                if("afterOnStop" in anim.config && anim.config.afterOnStop != null) { anim.config.afterOnStop(anim); }
            };
        }
        else
        {
            anim.config.onStop <- function(anim)
            {
                if("afterOnStop" in anim.config && anim.config.afterOnStop != null) { anim.config.afterOnStop(anim); }
            };
        }
    }
    anim.config.afterOnStop <- function(anim) { func(); anim.config.afterOnStop = null; };
    play_animation(anim);
}

/*
Returns true if there is one or more animations with the property <blocking> in the configuration set to true.

Example:
local my_config = { property = "alpha", start = 255, end = 0, time = 150, blocking = true };
local my_anim = add_animation(PropertyAnimation(item, setup_animation(my_config))));

function foo()
{
    if(blocking_animations_running())
    {
        ::print("I can't run my code.\n");
        return;
    }
    ::print("I can run my code.\n")
}
*/
function blocking_animations_running()
{
    foreach(anim in animation.animations)
    {
        if("blocking" in anim.config && anim.config.blocking && anim.running)
        {
            return true;
        }
    }
    return false;
}