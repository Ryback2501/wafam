local supported_img_extensions = [ "png", "jpg", "jpeg", "gif", "bmp", "tga" ];

function add_artwork(label, parent = ::fe, offset = 0)
{
    return parent.add_image(get_artwork_path(label, offset));
}

function get_artwork_path(label, offset = 0)
{
    local name = fe.game_info(Info.Name, offset);
    local emulator = fe.game_info(Info.Emulator, offset);
    local path = fe.path_expand("./scraper/" + emulator + "/" + label + "/");
    local full_path = null;

    foreach(extension in supported_img_extensions)
    {
        full_path = path + name + "." + extension;
        if(fe.path_test(full_path, PathTest.IsFile))
        {
            return full_path;
        }
    }
    foreach(extension in supported_img_extensions)
    {
        full_path = path + emulator + "." + extension;
        if(fe.path_test(full_path, PathTest.IsFile))
        {
            return full_path;
        }
    }
    return null;
}

function fit_aspect_ratio(image, max_width, max_height)
{
    local texture_aspect = image.texture_width / image.texture_height.tofloat();
    local wider = texture_aspect > max_width / max_height.tofloat();
    
    if(wider)
    {
        image.width = max_width;
        image.height = image.width / texture_aspect;
    }
    else // taller
    {
        image.height = max_height;
        image.width = image.height * texture_aspect;
    }
}