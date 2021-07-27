//By xXxMoNkEyMaNxXx
extern Image data0;//Position
extern Image data1;//Velocity
extern Image data2;//Acceleration (Stored by first pass for Position and velocity passes)

extern number tick;
extern number pass;
extern vec4 View;

const number base=1.08;
vec3 Decode(vec4 data)
{
	return (2.0*data.xyz-1.0)*pow(base,255.0*data.w);
}
vec4 Encode(vec3 value)
{
	if(length(value)>0){
		number lol=max(floor(log(max(max(abs(value.x),abs(value.y)),abs(value.z)))/log(base))+1.0,0);
		return vec4(value/(2.0*pow(base,lol))+vec3(0.5),lol/255.0);
	}
	return vec4(0.5,0.5,0.5,0);
}

number k=2000.0;
number len=0.1;
number resistance=0.0001;
vec3 g=vec3(0,-9.81,0);

vec3 extend(vec3 vector,number amount)
{
	return vector+max(-length(vector),amount)*normalize(vector);
}

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 pixel)
{
	vec2 uv=(pixel-View.xy)/View.zw;
	vec2 unit=1/View.zw;
	if(uv.x-unit.x*0.9>0&&uv.y-unit.y*0.9>0&&uv.x+unit.x*1.9<1&&uv.y+unit.y*1.9<1){
		if(floor(pass+0.5)==1)//Acceleration
		{
			vec3 Node=Decode(Texel(data0,uv));
			vec3 a=vec3(g);
			a+=k*extend(Decode(Texel(data0,uv+unit*vec2(1,0)))-Node,-len);
			a+=k*extend(Decode(Texel(data0,uv+unit*vec2(0,1)))-Node,-len);
			a+=k*extend(Decode(Texel(data0,uv+unit*vec2(-1,0)))-Node,-len);
			a+=k*extend(Decode(Texel(data0,uv+unit*vec2(0,-1)))-Node,-len);
			return Encode(a);
		}
		else if(floor(pass+0.5)==2)//Velocity
		{
			vec3 vel=Decode(Texel(data1,uv))+tick*Decode(Texel(data2,uv));
			return Encode(extend(vel,-resistance*dot(vel,vel)));
		}
		else if(floor(pass+0.5)==3)//Position
		{
			return Encode(Decode(Texel(data0,uv))+tick*Decode(Texel(data1,uv))+tick*tick/2*Decode(Texel(data2,uv)));
		}
	}else{
		return Encode(vec3(uv.x-0.5,0,uv.y-0.5)*64);
	}
	return vec4(0.5,0.5,0.5,0);
}
