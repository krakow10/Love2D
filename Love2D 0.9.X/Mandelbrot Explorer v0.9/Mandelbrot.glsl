//By xXxMoNkEyMaNxXx

number pi=3.1415926535898;

//Rolloff to black
number pwr=2;

//Max number of iterations (Per pixel!)
extern number maxi;

//Screen Size
extern vec2 vs;

//Area being rendered on screen
extern vec2 spot;
extern vec2 size;

//Area of fractal being rendered
extern vec2 pos;
extern vec2 view;

//Mouse position
extern vec2 mouse;


vec3 RGB(number hue)
{
	vec3 temp=vec3(cos(hue*pi),cos((hue+1./3.)*pi),cos((hue+2./3.)*pi));
	return temp*temp;
}

bool check(vec2 point)
{
	number p=(point.x-0.25)*(point.x-0.25)+point.y*point.y;
	return point.x<sqrt(p)-2*p+0.25 || (point.x+1)*(point.x+1)+point.y*point.y<0.0625;

}
/*
local function csqrt(re,im) -- Square root of a complex number with no trig! :>
	if im and im~=0 then
		local m=sqrt(re*re+im*im)
		return sqrt((m+re)/2),re>=0 and (sqrt(m+im)-sqrt(m-im))/2 or im>=0 and (sqrt(m+im)+sqrt(m-im))/2 or (sqrt(m+im)+sqrt(m-im))/-2 --shut up this is the fastest way
	else
		return re>0 and sqrt(re) or 0,re<0 and sqrt(-re) or 0
	end
end
*/
vec2 csqrt(vec2 z)
{
	if(z.y==0){
		if(z.x<0)
			return vec2(0,sqrt(-z.x));
		return vec2(sqrt(z.x),0);
	}else{
		number m=length(z);
		if(z.x>=0)
			return vec2(sqrt((m+z.x)/2),(sqrt(m+z.y)-sqrt(m-z.y))/2);
		else if(z.y>=0)
			return vec2(sqrt((m+z.x)/2),(sqrt(m+z.y)+sqrt(m-z.y))/2);
		else
			return vec2(sqrt((m+z.x)/2),(sqrt(m+z.y)+sqrt(m-z.y))/-2);
	}
}

vec2 iterate(vec2 point)
{
	return vec2(point.x*point.x-point.y*point.y,2*point.x*point.y);
}

number radius=2;
bool drawpoint(vec2 p,vec2 b,number scale)
{
	return distance(p,b)*scale<radius;
}
bool drawline(vec2 l,vec2 p,number scale)
{
	number t=dot(p,l)/dot(l,l);
	if(0<t&&t<1)
		return length(p-l*t)*scale<radius;
	return false;
}

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 ipixel)
{
	//Relative point
	vec2 pixel=vec2(ipixel.x,vs.y-ipixel.y);
	vec2 point=pos+view*(pixel-spot)/size;

	vec2 mpoint=pos+view*(mouse-spot)/size;

	number s=size.x/view.x;

	//Draw stationary points
	if(drawpoint(vec2(.5,0)+csqrt(vec2(.25,0)-mpoint),point,s)||drawpoint(vec2(.5,0)-csqrt(vec2(.25,0)-mpoint),point,s))
		return vec4(1,1,1,1);

	vec2 m=vec2(0);
	vec2 M=vec2(0);
	for(int i=0;i<100;i++){
		vec2 nm=iterate(m)+mpoint;
		vec2 nM=csqrt(M-mpoint);
		if(drawline(nm-m,point-m,s))
			return vec4(.25,.25,.25,1);
		//else if(drawpoint(M,point,s))
			//return vec4(.666,.666,.666,1);
		else
			m=nm;
			M=nM;
	}

	number i=0;
	vec2 z=vec2(0);
	if(!check(point)){
		while(i<maxi){
			vec2 nz=iterate(z)+point;
			number nrr=nz.x*nz.x+nz.y*nz.y;
			if(nrr>4){
				number r=length(z);
				i+=(2-r)/(sqrt(nrr)-r);
				return vec4(RGB(mod(log(i),1)),1);
				//break;
			}
			i++;
			z=nz;
		}
		/*/
		if(i<maxi){
			return RGBA(i);
		}
		//*/
	}
	return vec4(0,0,0,1);
}
vec4 position(mat4 transform_projection,vec4 vertex_position)
{
	return transform_projection*vertex_position;
}
