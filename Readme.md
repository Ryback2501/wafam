WorkArrounds For Attract Mode
=============================

This project was created to publish workarounds to help creating layouts for Attract Mode, but I think that things have gone beyond already.

Modules
--------

### How to use the modules? ###

Clone or download the project and copy the `modules` folder into the Attract Mode folder. There is already a `modules` folder, but don't worry. You are only adding a `wafam` folder with the script inside it.

* [interpolate](#interpolate)
* [animate](#animate)
* [artwork](#artwork)

---

interpolate
-----------
This module allows you to create classes that run actions along a defined time lapse.

### Clases ###

* `Interpolator`: This class is stored in the root squirrel table 'interpolator'. It contains a table of interpolable objects. It interpolates all the interpolable objects in it and they are removed when their interpolations finish.

  Methods:

  * `add(interpolable)`: Adds an interpolable object to the list of interpolable objects of the interpolator.

  Example
  ````squirrel
  interpolator.add(my_interpolable_object);
  ````

* `InterpolableBase`: It is the base class of every interpolable object. Any object that inherits from this class and is added to the interpolator's list of interpolable objects (through the method `add(interpolable)` previously mentioned) will be interpolated along the lapse of time defined.
  
  This is an example how to inherit from `InterpolableBase`:
  ````squirrel
  class LoggedInterpolable extends InterpolableBase
  {
      constructor(lapse)
      {
          ::print("new!\n");
          base(lapse);
      }

      // This method is executed before the interpolation begins
      function start(ttime)
      {
          ::print("start(" + ttime + ")\n");
          base.start(ttime);
      }

      // This method is executed on every update of the interpolation
      function update(ttime)
      {
          ::print("update(" + ttime + ")\n");
          return base.update(ttime);
      }

      // This method is executed after the interpolation finishes
      function stop()
      {
          ::print("stop()\n");
          return base.stop();
      }
  }
  ````

---

animate
-------
This module is an alternative animation module. It only supports animations for properties of objects. Particles and Sprite support could be added in the future, but now there aren't plans for that.

Each animation is played only once. There is no support for loops, or pulsed and reversed animations yet.

### How to use it? ###

Load the `animate` module with this line:

````squirrel
fe.load_module("wafam/animate");
````

### Clases ###

* `Animation`: Animates the values of the properties of an object.
  
    The constructor has the follwing parameters:
    * `lapse`: The lapse of time, in miliseconds, the animation lasts.
    * `object`: The object which properties the animation will animate.
    * `config`: A table with the configuration of the animation. This is an optional parameter and the default value is `null`. 
    * `blocking`: Indicates if the animation is a blocking animation. This is an optional parameter and the default value is `false`. This flag can be checked with the `blocking_animations_running` function.

    > **Note**: If an animation is created without a configuration, the method `setup_properties` must be called before playing the animation to define the animation ranges of the properties to animate.

    Example
    ````squirrel
    //Configuration to move an object horizontally
    local config = { properties = { x = { start = 100, end = 250 } } };

    //This is a 1 second blocking animation of the foo object
    local animation = Animation(1000, foo, config, true);
    ````

    ````squirrel
    //This animation doesn't have a configuration, so it won't be played.
    local dumb_animation = Animation(5000, foo);
    ````

    Methods:
    * `play(func = null)`: Plays the animation. If a function is sent as parameter, it will be called when the animation finishes. The function will be called with a reference of the animation.

    Examples
    ````squirrel
    local config = { interpolation = interpolations.linear, properties = { x = { start = 100, end = 250 } } };
    local animation = Animation(1000, foo, config, true);
    animation.play();
    ````

    ````squirrel
    //When the animation finishes, it will print a message
    local my_function = function(anim) { ::print("The animation has finished.\n"); };
    animation.play(my_function)
    ````

    > **Note**: If an `onstop` function is defined in the configuration of the animation, it won't be replaced if the animation is played with another function as parameter. In that case, when the animation finishes, the `onstop` function will be called and the function sent as parameter will be called afterwards.

    * `setup_properties(prop)`: Replaces the `properties` section of the `configuration` table in the animation by the `prop` table sent as parameter.

    Example
    ````squirrel
    //This new animation is useless.
    local apparently_dumb_animation = Animation(5000, foo);

    //The table contains only information of the
    local config = {
        width = { start = 50, end = 700 },
        x = { start = 150, end = 560 },
        y = { start = 45, end = 300 }
    };

    //The information of the properties to animate
    apparently_dumb_animation.setup_properties(config);
    apparently_dumb_animation.play();
    ````

    The structure of the `config` table of an animation:
    * `properties`: A table with the information of the properties to animate. Each slot represents a property to animate and contains a `start` value and an `end` value. The property will be animated from the start value to the end value. The key must match the property to animate.
    * `interpolation`: The interpolation method that will be applied. If this slot isn't set, a linear interpolation method will be used.
    * `onstart`: A function that will be called before the animation starts. If this slot isn't set, no method will be called.
    * `onupdate`: A function that will be called on every frame of the animation. If this slot isn't set, no method will be called.
    * `onstop`: A function that will be called after the animation ends. If this slot isn't set, no method will be called.

    Example:
    ````squirrel
    {
        properties = {
            x = { start = 100, end = 200 },
            y = { start = 100, end = 200 },
            width = { start = 150, end = 300 },
            height = { start = 150, end = 300 },
            alpha = { start = 255, end = 0 }
        },
        interpolation = interpolations.reverse,
        onstart = function(anim) {
            ::print("The animation is about to start.\n");
        },
        onupdate = function(anim) {
            ::print("The animation is playing.\n");
        },
        onstop = function(anim) {
            ::print("The animation just finished.\n");
        }
    }
    ````

### Methods ###

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

---

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
