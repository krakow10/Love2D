//By xXxMoNkEyMaNxXx
const int fix=1;

extern Image data0[fix];//Position
extern Image data1[fix];//Velocity
extern Image data2[fix];//Acceleration (Stored for Position and velocity dataNs)
extern Image staticData[fix];//Stores values written by previous pass to get more precise data.

extern number tick;
extern number dataN;
extern number pass;
extern vec4 View;

const number base=1.1;
vec4 Encode(vec3 value)
{
	if(length(value)>1.0/255.0){//&&length(value)<1e6
		number lol=max(floor(log(max(max(abs(value.x),abs(value.y)),abs(value.z)))/log(base))+1.0,0);
		return vec4(value/(2.0*pow(base,lol))+vec3(0.5),lol/255.0);
	}
	return vec4(0.5,0.5,0.5,0);
}
vec3 Decode(vec4 data)
{
	return (2.0*data.xyz-1.0)*pow(base,255.0*data.w);
}
vec3 Retrieve(Image[fix] data,vec2 uv,int corrections)
{
	if(corrections>=0){
		vec3 value=Decode(Texel(data[0],uv));
		/*
		int i=1;
		while(i<corrections)
		{
			value+=Decode(Texel(data[i],uv));
			i++;
		}
		//*/
		return value;
	}
	return vec3(0);
}

number k=100.0;
number len=0.01;
number resistance=0.0;
vec3 g=vec3(0,-9.81,0)*0.0;

vec3 extend(vec3 vector,number amount)
{
	return vector+amount*normalize(vector);
}

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 pixel)
{
	vec2 uv=(pixel-View.xy)/View.zw;
	vec2 unit=1.0/View.zw;
	if(uv.x-unit.x*0.9>0&&uv.y-unit.y*0.9>0&&uv.x+unit.x*1.9<1&&uv.y+unit.y*1.9<1){
		if(dataN==2)//Acceleration
		{
			vec3 Node=Retrieve(data0,uv,fix);
			vec3 a=vec3(g);
			a+=k*extend(Retrieve(data0,uv+unit*vec2(1,0),fix)-Node,-len);
			a+=k*extend(Retrieve(data0,uv+unit*vec2(0,1),fix)-Node,-len);
			a+=k*extend(Retrieve(data0,uv+unit*vec2(-1,0),fix)-Node,-len);
			a+=k*extend(Retrieve(data0,uv+unit*vec2(0,-1),fix)-Node,-len);
			return Encode(a);//-Retrieve(data2,uv,int(pass-1))
		}
		else if(dataN==1)//Velocity
		{
			vec3 vel=Retrieve(staticData,uv,fix)+tick*Retrieve(data2,uv,fix);
			return Encode(vel);//-Retrieve(data1,uv,int(pass-1))extend(vel,max(-length(vel),-resistance*dot(vel,vel)))
		}
		else if(dataN==0)//Position
		{
			return Encode(Retrieve(staticData,uv,fix)+tick*Retrieve(data1,uv,fix)+tick*tick/2*Retrieve(data2,uv,fix));//-Retrieve(data0,uv,int(pass-1))
		}
	}
	if(dataN==0&&pass==0){
		return Encode(vec3(uv.x-0.5,0,uv.y-0.5)*10);
	}
	return vec4(0.5,0.5,0.5,0);
}
