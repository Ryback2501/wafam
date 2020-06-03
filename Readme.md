WorkArrounds For Attract Mode
=============================

This project includes workarounds to I'm going to be adding over time.

Modules
--------

### How to use the modules? ###

Clone or download the project and copy the `modules` folder into the Attract Mode folder. There is already a `modules` folder, but don't worry. You are only adding a `wafam` folder with the script inside it.

* [animate](#animate)
* [artwork](#artwork)

animate
-------
This module has methods that makes it easier to trigger animations on demand. It extends the `animate` module included in Attract Mode, which is loaded by default.

### How to use it? ###

Load the `animate` module with this line:

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

  Parameters:
  - `config`: The configuration of the animation.

  Example:
  ````squirrel
  local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
  local my_anim = PropertyAnimation(item, setup_animation(my_config)));

  local my_other_config = { property = "x", start = 100, end = 200, time = 350 };
  local my_other_anim = add_animation(PropertyAnimation(another_item, setup_animation(my_other_config))));
  ````

* `play_animation(anim)`: Plays the animation passed as a parameter. The animation needs a configuration set up with the `setup_animation` method and must be added to the animation core.

  Parameters:
  - `anim`: The animation to play.

  Example:
  ````squirrel
  local my_config = { property = "alpha", start = 255, end = 0, time = 150 };
  local my_anim = add_animation(PropertyAnimation(item, setup_animation(my_config))));

  play_animation(my_anim);
  ````

* `play_animation_and_run(anim, func)`: Plays an animation and, when it finishes, runs a function. It will only work with animations which configuration tables were setup with `setup_animation`. This method allows to re-use an animation and to run different functions with different calls. It doesn't remove the functionality of the `onStop` property in the configuration of the animation, if it was added.

  Parameters:
  - `anim`: The animation to play first.
  - `func`: The function to run when the animation finishes.

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

artwork
-------

This module allows to load artwork files into normal images. As the created objects are normal images, they don't change when the selected game changes.

### How to use it? ###

Load the `artwork` module with this line:

````squirrel
fe.load_module("wafam/artwork");
````

### Methods ###

* `add_artwork(label, offset, parent)`: Returns an artwork which has been created as an image. Since it is an image, not a real artwork, it doesn't change when the selected game changes.

  Parameters:
  - `label`: The label of the artwork to display. This should correspond to an artwork configured in Attract-Mode (artworks are configured per emulator in the config menu) or scraped using the scraper. Attract- Mode's standard artwork labels are: "snap", "marquee", "flyer", "wheel", and "fanart".
  - `offset`: The offset (from the current selection) of the game to retrieve info on. i.e. -1 = previous game, 0 = current game, 1 = next game... and so on. Default value is 0.
  - `parent`: The object to add the new artwork to. Default value is `fe`.

  Example:
  ````squirrel
  local boxart = add_artwork("flyer");

  local parent = fe.add_surface(800, 600);
  local previous_game_fanart = add_artwork("fanart", parent, -1);
  ````

* `get_artwork_path(label, offset)`: Returns a string with the full path of the artwork.

  Parameters:
  - `label`: The label of the artwork to display. This should correspond to an artwork configured in Attract-Mode (artworks are configured per emulator in the config menu) or scraped using the scraper. Attract- Mode's standard artwork labels are: "snap", "marquee", "flyer", "wheel", and "fanart".
  - `offset`: The offset (from the current selection) of the game to retrieve info on. i.e. -1=previous game, 0=current game, 1=next game... and so on. Default value is 0.

  Example:
  ````squirrel
  local boxart_path = get_artwork_path("flyer");
  local next_game_fanart_path = get_artwork_path("fanart", 1);
  ````

* `fit_aspect_ratio(image, max_width, max_height)`: Scales an image, keeping its aspect ratio, in order to fit the maximum dimensions given as parameters.

  Parameters:
  - `image`: The image to scale and fit.
  - `max_width`: The maximum width of the image.
  - `max_height`: The maximum height of the image.

  Example:
  ````squirrel
  local boxart = add_artwork("flyer");
  fit_aspect_ratio(boxart, 640, 480);
  // If, as an example, the image has a resolution of 1280x720 pixels, its final size will be 640x360 pixels.
  ````
