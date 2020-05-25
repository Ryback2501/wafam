WorkArrounds For Attract Mode
=============================

This project includes workarounds to I'm going to be adding over time.

Modules
--------
* [animate](#animate)

animate
-------
This extends the `animate` module included in Attract Mode, which is loaded by default.

### How to use it? ###

Clone or download the project and copy the `modules` folder into the Attract Mode folder. There is already a `modules` folder, but don't worry. You are only adding a `wafam` folder with the script inside it.

Then, load the `animate` module with this line.

````squirrel
fe.load_module("wafam/animate");
````

The default `animate` module is loaded, so you only need to load this module into your layout to make the animations work.

### Methods ###

* `add_animation(anim)`: Adds the animation to the animation core and returns it. This allows to create an animation, add it to the animation core and keep its reference in a single line of code.

    Example:
````squirrel
local my_anim = add_animation(PropertyAnimation(item, { property = "alpha", start = 255, end = 0, time = 150 } ));
````

* `setup_animation(config)`: Adds the slots needed to run the animation on demand to the table with the configuration of the animation.

    Example:
````squirrel
local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
local my_anim = PropertyAnimation(item, setup_animation(my_config)));

local my_other_config = { property = "x", start = 100, end = 200, time = 350 };
local my_other_anim = add_animation(PropertyAnimation(another_item, setup_animation(my_other_config))));
````

* `play_animation(anim)`: Plays the animation passed as a parameter. It will only work with animations which configuration tables were setup with `setup_animation`.

    Example:
````squirrel
local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
local my_anim = add_animation(PropertyAnimation(item, setup_animation(my_config))));

play_animation(my_anim);
````

* `play_animation_and_run(anim, func)`: Plays the animation passed as first parameter and, when it finishes, runs the function passed as second parameter. It will only work with animations which configuration tables were setup with `setup_animation`. This method allows to re-use an animation and to run different functions with different calls. It doesn't override the `onStop` property in the configuration of the animation.

    Example:
````squirrel
local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
local my_anim = add_animation(PropertyAnimation(item, setup_animation(my_config))));

local my_other_config = {
    property = "alpha", start = 255, end = 0, time = 150,
    onStop = function(anim) { ::print("Code that will run always when the animation stops."); }
};
local my_other_anim = add_animation(PropertyAnimation(item, setup_animation(my_other_config))));

play_animation_and_run(my_anim, function() { ::print("This code runs after the animation stops.\n"); });
play_animation_and_run(my_other_anim, function() { ::print("This code runs after onStop finishes.\n"); });
````

* `blocking_animations_running()`: Returns `true` if there is one or more animations with the property `blocking` set to `true`.

    Example:
````squirrel
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
````