fe.load_module("animate");

function add_animation(anim)
{
    animation.add(anim);
    return anim;
}

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

function play_animation(anim)
{
    anim.config.play = true;
}

function play_animation_and_run(anim, func)
{
    anim.config.afterOnStop <- function(anim) { func(); delete anim.config.afterOnStop; };
    if("onStop" in anim.config)
    {
        local onstop = anim.config.onStop;
        anim.config.onStop <- function(anim) { onstop(anim); if("afterOnStop" in anim.config) { anim.config.afterOnStop(anim); } };
    }
    else
    {
        anim.config.onStop <- function(anim) { if("afterOnStop" in anim.config) { anim.config.afterOnStop(anim); } };
    }
    play_animation(anim);
}

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