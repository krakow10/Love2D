extern vec4 lol;
vec4 range=vec4(255);

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 seed)
{
	return mod(mod(lol,vec4(mod(seed.x,sqrt(seed.y))*seed.y,mod(seed.x,seed.y)*seed.x,mod(seed.y,seed.x)*seed.y,mod(seed.y,sqrt(seed.x))*seed.x)),range)/range;
}
