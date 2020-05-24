fe.load_module("animate");

function add_animation(anim)
{
    animation.add(anim);
    return anim;
}

function setup_animation(config)
{
    config.play <- false;

    local onstart =  "onStart" in config ? config.onStart : null;
    config.onStart <- function(anim) { anim.config.play = false; if(onstart != null) { onstart(anim); } }

    config.when <- function(anim) { return anim.config.play; }
    return config;
}

function play_animation(anim)
{
    anim.config.play = true;
}