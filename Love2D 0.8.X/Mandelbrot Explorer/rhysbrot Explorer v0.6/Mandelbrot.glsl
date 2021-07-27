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


vec3 RGB(number hue)
{
	vec3 temp=vec3(cos(hue*pi),cos((hue+1./3.)*pi),cos((hue+2./3.)*pi));
	return temp*temp;
}

vec4 RGBA(number w)
{
	number mA=pow(maxi,pwr);
	return vec4(RGB(pow(w/maxi,.25))*((pow(w,pwr)-mA)/(1-mA)),1);
}

bool check(vec2 point)
{
	number p=(point.x-0.25)*(point.x-0.25)+point.y*point.y;
	return point.x<sqrt(p)-2*p+0.25 || (point.x+1)*(point.x+1)+point.y*point.y<0.0625;

}

vec2 iterate(vec2 point,n)
{
	return vec2(point.x*point.x-point.y*point.y,2*point.x*point.y);
}
vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 ipixel)
{
	//Relative point
	vec2 pixel=vec2(ipixel.x,vs.y-ipixel.y);
	vec2 point=pos+view*(pixel-spot)/size;

	number i=0;
	vec2 z=point;
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
		if(i<maxi){
			return RGBA(i);
		}
	}
	return vec4(0,0,0,1);
}
