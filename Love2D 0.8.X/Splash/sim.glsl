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
	return 255.0*data.b-128.0+data.a;
}

vec4 encode(number p,number v)
{
	return clamp(vec4(floor(p)/255.0,mod(p,1.0),floor(v+128.0)/255.0,mod(v,1.0)),0.0,1.0);
}

number r=12.3456789;
vec4 effect(vec4 _0,Image data,vec2 percent,vec2 _3)
{
	vec4 code=Texel(data,percent);
	number v=speed(code);
	number p=height(code);
	number sum=(128.0-p)*(128.0-p)*(128.0-p)/8192.0;
	for(int x=int(-floor(r+0.5));x<=floor(r+0.5);x++){
		int h=int(floor(sqrt(r*r-x*x)+0.5));
		for(int y=-h;y<=h;y++){
			if(!(x==0||y==0))
				sum+=(height(Texel(data,percent+vec2(x,y)/vs))-p)/float(x*x+y*y);
		}
	}
	/*
	sum+=height(Texel(data,percent+vec2( 1, 0)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 0, 1)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-1, 0)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 0,-1)/vs))-p;
	//*/
	/*
	sum+=height(Texel(data,percent+vec2( 1, 1)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-1, 1)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-1,-1)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 1,-1)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 2, 0)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 0, 2)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-2, 0)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 0,-2)/vs))-p;
	//*/
	/*
	sum+=height(Texel(data,percent+vec2( 2, 1)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 1, 2)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-1, 2)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-2, 1)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-2,-1)/vs))-p;
	sum+=height(Texel(data,percent+vec2(-1,-2)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 1,-2)/vs))-p;
	sum+=height(Texel(data,percent+vec2( 2,-1)/vs))-p;
	//*/
	number dv=k*sum*dt;
	return encode(p+(v+dv/2.0)*dt,v+dv-0.001*v*abs(v));
}
