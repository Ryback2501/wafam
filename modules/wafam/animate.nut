//The interpolate module is needed to control the interpolation of the animations
fe.load_module("wafam/interpolate");

/*
Animates the values of the properties of an object.
*/
class Animation extends InterpolableTriggerBase
{
    object = null;
    blocking = false;

    constructor(lapse, animable_object, configuration = null, is_blocking = false)
    {
        object = animable_object;
        config = configuration != null ? configuration : {};
        if(!("interpolation" in config)) config.interpolation <- interpolations.linear;
        blocking = is_blocking;
        tlapse = lapse;
    }

    function play(func = null)
    {
        setup_onstoponce(func);
        add_to_loop();
    }

    function setup_properties(prop)
    {
        if("properties" in config) config.properties = prop;
        else config.properties <- prop;
    }
    
    function update(ttime)
    {
        if(!("properties" in config)) return true;
        foreach(key, value in config.properties) object[key] = animate(value.start, value.end, ttime);
        return base.update(ttime);
    }

    function stop()
    {
        return base.stop();
    }

    function animate(start, end, ttime)
    {
        return start + ((end - start) * config.interpolation(minmax(normalize(ttime - tstart, tlapse))));
    }

    function normalize(elapsed, lapse)
    {
        local result = elapsed / lapse.tofloat();
        return result;
    }
    
    function minmax(value, min = 0.0, max = 1.0)
    {
        if(min > value) value = min;
        if(max < value) value = max;
        return value;
    }
}

class AnimatedSprite extends InterpolableTriggerBase
{
    sprite = null;
    config = null;
    current_animation = null;
    blocking = false;

    constructor(image, configuration, is_blocking = false)
    {
        config = configuration;
        sprite = image;
        sprite.subimg_width = config.sprite_width;
        sprite.subimg_height = config.sprite_height;
        blocking = is_blocking;
    }

    function play(func = null)
    {
        play(null, func);
    }

    function play(animation = null, func = null)
    {
        if(animation == null) foreach(key, value in config.animations) { animation = key; break; }
        current_animation = config.animations[animation];
        
        tlapse = (current_animation.sequence.len() * 1000 /  current_animation.fps).tointeger();
        
        setup_onstoponce(func);
        add_to_loop();
    }

    function update(ttime)
    {
        if(!current_animation.loop && base.update(ttime)) return true;

        local frame = current_animation.sequence[(((ttime - tstart) % tlapse) * current_animation.fps / 1000).tointeger()];
        local frames_per_row = sprite.texture_width / sprite.subimg_width;
        sprite.subimg_x = sprite.subimg_width * (frame % frames_per_row);
        sprite.subimg_y = sprite.subimg_height * (frame / frames_per_row);
        return false;        
    }

    function setup_sequence(sequence)
    {
        if(sequence == null || sequence.len() == 0)
        {
            sequence = [];
            local len = (sprite.texture_width / sprite.subimg_width) * (sprite.texture_height / sprite.subimg_height);
            for(local i = 0; i < len; i++) sequence.append(i);
        }
        return sequence;
    }

}

/*
Returns <true> if there is a blocking interpolable object being interpolated.
*/
function blocking_animations_running()
{
    foreach(interpolable in interpolator.interpolables)
    {
        if("blocking" in interpolable && interpolable.blocking) return true;
    }
    return false;
}