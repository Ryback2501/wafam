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

    Example:
    ````squirrel
    interpolator.add(my_interpolable_object);
    ````

* `InterpolableBase`: It is the base class of every interpolable object. Any object that inherits from this class and is added to the interpolator's list of interpolable objects (through the method `add(interpolable)` previously mentioned) will be interpolated along the lapse of time defined.
  
  Methods:
  * `add_to_loop()`: Adds the the interpolable class to the loop of the `Interpolator` class.
  
  This is an example how to inherit from `InterpolableBase`:
  ````squirrel
  class LoggedInterpolable extends InterpolableBase
  {
      constructor(lapse)
      {
          ::print("new!\n");
          base(lapse);
      }

      //When this method is called, the interpolation process of the interpolable class will start
      function play_interpolation()
      {
          add_to_loop();
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
* `InterpolableTriggerBase`: This class, that extends from InterpolableBase, adds functionality to trigger code when the interpolation starts, on every update and when it stops.

  Methods:
  * `setup_config(configuration)`: Receives a configuration table with slots that reference to functions that will be called on concrete events. If it is called with null or without parameter, it will create an empty table. These are the slots with the references:
    * `onstart`: A function that will be called before the animation starts. If this slot isn't set, no method will be called.
    * `onupdate`: A function that will be called on every frame of the animation, after the properties are animated. If this slot isn't set, no method will be called.
    * `onstop`: A function that will be called after the animation ends. If this slot isn't set, no method will be called.
  
    The methods receive a parameter which will be a reference to the `InterpolableTriggerBase` class instance.

    Example:
    ````squirrel
    class Foo extends InterpolableTriggerBase
    {
        //When the instance is created, it can receive the configuration table
        constructor(configuration = null)
        {
            setup_config(configuration);
        }
    }

    local config_table = {
        onstart = function(inter)
        {
            ::print("The interpolation is about to start.\n");
        }
        onupdate = function(inter)
        {
            ::print("The interpolation is updating.\n");
        }
        onstop = function(inter)
        {
            ::print("The interpolation just stopped.\n");
        }
    }

    //The class is created with the configuration table
    local my_foo = Foo(config_table);
    ````

  * `setup_onstoponce(func)`: This method adds a fourth reference to a method that will be executed only once, after the `onstop` function.

    Example:
    ````squirrel
    class Foo extends InterpolableTriggerBase
    {
        //When the instance is created, it can receive the configuration table
        constructor(configuration = null)
        {
            setup_config(configuration);
        }

        //This method would be called to start the interpolation process. The function parameter is optional.
        function play_interpolation(func = null)
        {
            setup_onstoponce(func);
            add_to_loop();
        }
    }

    local my_foo = Foo();

    my_foo.play_interpolation();

    my_foo.play_interpolation( function(inter) { ::print("Only this time, I'm logging that the interpolation just finished.\n"); } );
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
  
  The constructor has the following parameters:
  * `lapse`: The lapse of time, in miliseconds, the animation lasts.
  * `object`: The object which properties the animation will animate.
  * `configuration`: A table with the configuration of the animation. It can contain the `onstart`, `onupdate` and `onstop` slots described in `InterpolableTriggerBase` class and a `properties` slot which is a table with the information of the properties of the object to animate. In that table each slot represents a property to animate. The key of the slot must match the name of the proprty to animate and contains a `start` value and an `end` value. It is also optional, and can be setup after creating the animation (see information about `setup_properties(prop)` function), but if no properties are defined when trying to play an animation, it won't play
  * `is_blocking`: Indicates if the animation is a blocking animation. This is an optional parameter and the default value is `false`. This flag can be checked with the `blocking_animations_running` function.

  > **Note**: If an animation is created without a configuration, the method `setup_properties` must be called before playing the animation to define the animation ranges of the properties to animate.

  Examples:
  ````squirrel
  //Configuration to move an object horizontally
  local config = {
      properties = {
          x = { start = 100, end = 250 },
          y = { start = 250, end = 300 },
          width = { start = 125, end = 75 }
      }  
  };

  //This is a 1 second blocking animation of the foo object
  local animation = Animation(1000, foo, config, true);
  ````

  ````squirrel
  //This animation doesn't have a configuration, so it won't be played.
  local dumb_animation = Animation(5000, foo);
  ````

  Methods:
  * `play(func)`: Plays the animation. If a function is sent as parameter, it will be called when the animation finishes. The function will be called with a reference of the animation.

    Examples:
    ````squirrel
    local config = {
        interpolation = interpolations.linear,
        properties = {
            x = { start = 100, end = 250 }
        }
    };
    
    local animation = Animation(1000, foo, config, true);
    
    animation.play();
    ````

    ````squirrel
    //When the animation finishes, it will print a message
    local my_function = function(anim) {
        ::print("The animation has finished.\n");
    };
    
    animation.play(my_function);
    ````

    > **Note**: If an `onstop` function is defined in the configuration of the animation, it won't be replaced if the animation is played with another function as parameter. In that case, when the animation finishes, the `onstop` function will be called and the function sent as parameter will be called afterwards.

  * `finish()`: Finishes the animation and leaves the properties with the values they have at that moment.

    Example:
    ````squirrel
    local config = {
        interpolation = interpolations.linear,
        properties = {
            x = { start = 100, end = 250 }
        }
    };
    
    local animation = Animation(1000, foo, config, true);
    
    animation.play();

    //The animation is interrupted
    animation.finish();
    ````

  * `setup_properties(prop)`: Replaces the `properties` section of the `configuration` table in the animation by the `prop` table sent as parameter.

    Examples:
    ````squirrel
    //This new animation is useless
    local apparently_dumb_animation = Animation(5000, foo);

    //The table contains only information of the properties to animate
    local config = {
        properties = {
            width = { start = 50, end = 700 },
            x = { start = 150, end = 560 },
            y = { start = 45, end = 300 }
        }
    };

    //The properties to animate are setup
    apparently_dumb_animation.setup_properties(config);

    //And the animation can play
    apparently_dumb_animation.play();
    ````

    ````squirrel
    //This is an example of a table with all the configurations
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

* `AnimatedSprite`: Animates a sequence of sprites.

  The constructor has the following parameters:
  * `atlas`: The image with all the sprites of the animations in it.
  * `configuration`: A table with the configuration of the animation. It can contain the `onstart`, `onupdate` and `onstop` slots described in `InterpolableTriggerBase` class and the following slots:
    * `sprite_width`: The width in pixels of the sub image of a sprite. All the sprites have the same width.
    * `sprite_height`: The height in pixels of the sub image of a sprite. All the sprites have the same height.
    * `animations`: A table with all the different animations of the animated sprite. The key of each slot of the animation is the name of the animation and it contains the following slots:
      * `sequence`: An array with the indexes of the frames in the order of order they appear in the animation.
      * `fps`: The frames per second of the animation.
      * `loop`: If it is `true`, the animation will play without stopping, otherwise, it will stop when it reaches its end. The last frame of the animation will be the frame the one visible after it stops.
  * `is_blocking`: Indicates if the animation is a blocking animation. This is an optional parameter and the default value is `false`. This flag can be checked with the `blocking_animations_running` function.

  Example:
  ````squirrel
  local conf = {
      sprite_width = 32,
      sprite_height = 48,
      animations = {
          iddle = { sequence = [0, 1, 2, 3, 4], fps = 18, loop = true },
          walk = { sequence = [5, 6, 7, 8, 9, 10], fps = 24, loop = true },
          jump = { sequence = [11, 12, 13, 14, 15, 16], fps = 24, loop = false }
      }
  };

  local sprite = AnimatedSprite(fe.add_image("atlas.png"), conf);
  ````

  Methods:
  * `play(animation, func)`: Plays an animation and, if set, runs a function at the end of it. Both parameters are optional. If no animation is indicated, the first of the list of animations will be the one played.

    Example:
    ````squirrel
    local conf = {
        sprite_width = 32,
        sprite_height = 48,
        animations = {
            iddle = { sequence = [0, 1, 2, 3, 4], fps = 18, loop = true },
            walk = { sequence = [5, 6, 7, 8, 9, 10], fps = 24, loop = true },
            jump = { sequence = [11, 12, 13, 14, 15, 16], fps = 24, loop = false }
        },
        onstart = function(anim) {
            ::print("A sprite animation is about to start.\n");
        },
        onupdate = function(anim) {
            ::print("A sprite animation is playing.\n");
        },
        onstop = function(anim) {
            ::print("A sprite animation just finished.\n");
        }
    };

    local sprite = AnimatedSprite(fe.add_image("atlas.png"), conf);
        
    //no animation is defined, so the first will be played. In this case it is 'idle'
    sprite.play();

    // 'walk' animation will be played
    sprite.play("walk");
    ````
  * `finish(frame)`: Finishes the animation and, if defined, sets the frame passed as a parameter.

    Example:
    ````squirrel
    local conf = {
        sprite_width = 32,
        sprite_height = 48,
        animations = {
            iddle = { sequence = [0, 1, 2, 3, 4], fps = 18, loop = true },
            walk = { sequence = [5, 6, 7, 8, 9, 10], fps = 24, loop = true },
            jump = { sequence = [11, 12, 13, 14, 15, 16], fps = 24, loop = false }
        }
    };

    local sprite = AnimatedSprite(fe.add_image("atlas.png"), conf);
    sprite.play();

    //The animation finishes and the sprite 14 of the atlas is the one shown
    sprite.finish(14);

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
