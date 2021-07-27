//By xXxMoNkEyMaNxXx
extern vec2 vs;

//Drawing colours
extern vec4 primary;//Alive Cell
extern vec4 secondary;//Dead Cell

float near(float x)
{
	return max(0,1-1.8143*x*x);
}

float state(Image img,vec2 pixel)
{
	return clamp(dot(Texel(img,mod(pixel/vs,vec2(1,1)))-secondary,primary-secondary)/dot(primary-secondary,primary-secondary),0,1);
}

vec4 effect(vec4 _0,Image canvas,vec2 _1,vec2 pixel)
{
	float neighbors=0;
	neighbors+=state(canvas,pixel+vec2( 1, 0));
	neighbors+=state(canvas,pixel+vec2( 1, 1));
	neighbors+=state(canvas,pixel+vec2( 0, 1));
	neighbors+=state(canvas,pixel+vec2(-1, 1));
	neighbors+=state(canvas,pixel+vec2(-1, 0));
	neighbors+=state(canvas,pixel+vec2(-1,-1));
	neighbors+=state(canvas,pixel+vec2( 0,-1));
	neighbors+=state(canvas,pixel+vec2( 1,-1));
	return mix(secondary,primary,1-(1-near(neighbors-3))*(1-near(state(canvas,pixel)-1)*near(neighbors-2)));
}
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    // The order of operations matters when doing matrix multiplication.
    return transform_projection * vertex_position;
}
