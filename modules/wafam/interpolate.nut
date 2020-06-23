/*
The class that controls the interpolations of all the interpolable objects.
*/
class Interpolator
{
    interpolables = [];

    constructor()
    {
        fe.add_ticks_callback(this, "interpolate");
    }

    function add(interpolable)
    {
        interpolables.insert(0, interpolable);
    }

    function remove(interpolable)
    {
        local index = interpolables.find(interpolable);
        if(index != null)
            interpolables.remove(index);
    }

    function interpolate(ttime)
    {
        local last = interpolables.len() - 1;
        for(local i = last; i >= 0; i--)
            if(interpolables[i].interpolate(ttime))
                interpolables.remove(i);
    }
}

/*
The base class which any interpolable class must extend in order to work with the interpolator.
*/
class InterpolableBase
{
    tlapse = 0;
    tstart = null;

    constructor(lapse)
    {
        tlapse = lapse;
    }

    function add_to_loop()
    {
        if(interpolator.interpolables.find(this) != null) { stop(); return; }
        interpolator.add(this);
    }

    function interpolate(ttime)
    {
        if(tstart == null) start(ttime);
        if(update(ttime)) return stop();
        return false;
    }

    function start(ttime) { tstart = ttime; }
    function update(ttime) { return ttime - tstart >= tlapse; }
    function stop() { tstart = null; return true; }
}


/*
An interpolable base class that triggers methods when starts, on every update and when stops.
*/
class InterpolableTriggerBase extends InterpolableBase
{
    config = null;

    function setup_onstoponce(func)
    {
        if(func != null)
        {
            if("onstoponce" in config) config.onstoponce = func;
            else config.onstoponce <- func;
        }
    }

    function start(ttime)
    {
        if("onstart" in config) config.onstart(this);
        base.start(ttime);
    }

    function update(ttime)
    {
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
}

//The instance of the interpolator added to the main table.
interpolator <- Interpolator();

//A table with functions to interpolate a  progress (p) that has been normalized (with values between 0 and 1)
interpolations <- {
    constant =   function(p) { return p < 1 ? 0 : 1; },
    linear =     function(p) { return p; },
    reverse =    function(p) { return 1 - p; }

    //The following interpolation methods haven't been tested yet, so...
    //TODO: Test these methods and add them

    // easein2 =    function(p) { return p * p; },
    // easein3 =    function(p) { return p * p * p; },
    // easein4 =    function(p) { return p * p * p * p; },
    // easein5 =    function(p) { return p * p * p * p * p; },
    // easeout2 =   function(p) { return interpolations.reverse( interpolations.easein2( interpolations.reverse(p) ) ); },
    // easeout3 =   function(p) { return interpolations.reverse( interpolations.easein3( interpolations.reverse(p) ) ); },
    // easeout4 =   function(p) { return interpolations.reverse( interpolations.easein4( interpolations.reverse(p) ) ); },
    // easeout5 =   function(p) { return interpolations.reverse( interpolations.easein5( interpolations.reverse(p) ) ); },
    // easeinout2 = function(p) { return mix(interpolations.easein2(p), interpolations.easeout2(p), p); },
    // easeinout3 = function(p) { return mix(interpolations.easein3(p), interpolations.easeout3(p), p); },
    // easeinout4 = function(p) { return mix(interpolations.easein4(p), interpolations.easeout4(p), p); },
    // easeinout5 = function(p) { return mix(interpolations.easein5(p), interpolations.easeout5(p), p); }
}

//These methods are not used 
// function flip(p) { return 1 - p; }
// function intpow(b, e) { local p = b; for(local i = 2; i <= e; i++) p *= b; return p; }
// function mix(p1, p2, w) { return (p1 * (1 - w)) + (p2 * w); }


/*
How to extend InterpolableBase class.

Example:

class LoggedInterpolable extends InterpolableBase
{
    constructor(lapse)
    {
        ::print("new!\n");
        base(lapse);
    }

    function interpolate(ttime)
    {
        ::print("interpolate (" + time_lapse + " - " + tstart +  " - " + ttime + ")\n");
        return base.interpolate(ttime);
    }
    
    function start(ttime)
    {
        ::print("start(" + ttime + ")\n"); base.start(ttime);
    }
    
    function update(ttime)
    {
        ::print("update(" + ttime + ")\n");
        return base.update(ttime);
    }

    function stop()
    {
        ::print("stop()\n");
        return base.stop();
    }
}

local foo = LoggedInterpolable(500);
interpolator.add(foo);
*/