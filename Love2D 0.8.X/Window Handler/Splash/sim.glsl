//By xXxMoNkEyMaNxXx

extern vec2 vs;//Screen resolution
extern mat2 View;

extern number k;//Spring coefficient
extern number dt;//Time

number height(vec4 data)
{
	return 255.0*data.r+data.g;
}

number speed(vec4 data)
{
	return 0.1*(255.0*data.b-128.0+data.a);
}

vec4 encode(number p,number v)
{
	return clamp(vec4(floor(p)/255.0,mod(p,1.0),floor(10.0*v+128.0)/255.0,mod(10.0*v,1.0)),0.0,1.0);
}

vec4 effect(vec4 _0,Image data,vec2 percent,vec2 _3)
{
	vec4 code=Texel(data,percent);
	number v=speed(code);
	number p=height(code);
	number dv=k*(height(Texel(data,percent+vec2(1,0)/vs))+height(Texel(data,percent+vec2(0,1)/vs))+height(Texel(data,percent-vec2(1,0)/vs))+height(Texel(data,percent-vec2(0,1)/vs))-4.0*p)*dt;
	return encode(p+(v+dv/2.0)*dt,v+dv);
}
