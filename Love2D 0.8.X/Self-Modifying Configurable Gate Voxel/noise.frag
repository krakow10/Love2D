//By xXxMoNkEyMaNxXx
vec4 noise(vec4 value,vec4 seed)
{
	return mod(mod(mod(mod(value/seed+2.0*value,1.0)/seed.yzwx+2.0*value.yzwx,1.0)/seed.zwxy+2.0*value.zwxy,1.0)/seed.wxyz+2.0*value.wxyz+vec4(0.5),1.0);
}

vec4 effect(vec4 offset,Image seed,vec2 percent,vec2 _3)
{
	number lol=1.0-offset.x*offset.y*offset.z*offset.a;
	return noise(Texel(seed,percent)/(lol*lol*lol*lol)+offset,offset*lol);
}
