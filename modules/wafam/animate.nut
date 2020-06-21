//The interpolate module is needed to control the interpolation of the animations
fe.load_module("wafam/interpolate");

/*
Animates the values of the properties of an object.
*/
class Animation extends InterpolableBase
{
    object = null;
    config = null;
    blocking = false;

    constructor(lapse, object, config = null, blocking = false)
    {
        this.object = object;
        this.config = config != null ? config : {};
        if(!("interpolation" in this.config)) this.config.interpolation <- interpolations.linear;
        this.blocking = blocking;
        tlapse = lapse;
    }

    function play(func = null)
    {
        if(func != null)
        {
            if("onstoponce" in config) config.onstoponce = func;
            else config.onstoponce <- func;
        }
        interpolator.add(this);
    }

    function setup_properties(prop)
    {
        if("properties" in config) config.properties = prop;
        else config.properties <- prop;
    }
    
    function start(ttime)
    {
        if("onstart" in config) config.onstart(this);
        base.start(ttime);
    }

    function update(ttime)
    {
        if(!("properties" in config)) return true;
        foreach(key, value in config.properties)
        {
            object[key] = animate(value.start, value.end, ttime);
        }
        if("onupdate" in config) config.onupdate(this);
        return base.update(ttime);
    }

    function stop()
    {
        if("onstop" in config) config.onstop(this);
        if("onstoponce" in config)
        {
            config.onstoponce(this);
            delete config.onstoponce;
        }
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