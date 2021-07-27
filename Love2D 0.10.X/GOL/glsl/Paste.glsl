//Use a Pixel effect to change B&W to primary and secondary

//primary and secondary colours
extern vec4 primary;
extern vec4 secondary;

vec4 effect(vec4 _0,Image paste,vec2 percent,vec2 _1)
{
	return Texel(paste,percent);
	//vec4 colour=Texel(paste,percent);
	//if((colour.r+colour.g+colour.b)*colour.a<1.5){return primary;}
	//return secondary;
}
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    // The order of operations matters when doing matrix multiplication.
    return transform_projection * vertex_position;
}
