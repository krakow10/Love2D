//By xXxMoNkEyMaNxXx
extern vec2 vs;
extern vec2 pos;
extern vec2 view;
extern number maxi;

number pwr=2;
number pi=3.1415926535898;

//Power of ten based numbaz
//*
number[10] add(number[10] n1,number[10] n2)
{
	number[10] sum;
	for(int i=0;i<10;i++){
		sum[i]=n1[i]+n2[i]
	}
	return sum;
}

number[10] mul(number[10] n1,number[10] n2)
{
	number[10] prod(0);
	for(int i1=0;i1<10;i1++){
		for(int i2=0;i2<10;i2++){
			number place=i1+i2;
			if(place<10){
				prod[place]+=n1[i1]*n2[i2];
			}
		}
	}
	return prod;
}

number[10] mulnum(number[10] n1,number n2)
{
	number[10] prod;
	for(int i=0;i<10;i++){
		prod[i]=n1[i]*n2;
	}
	return prod;
}
//*/
vec3 RGB(number hue)
{
	vec3 temp=vec3(cos(hue*pi),cos((hue+1./3.)*pi),cos((hue+2./3.)*pi));
	return temp*temp;
}

vec4 RGBA(number w)
{
	number mA=pow(maxi,pwr);
	return vec4(RGB(pow(w/maxi,1./4.)),(pow(w,pwr)-mA)/(1-mA));
}

bool check(vec2 point)
{
	number p=(point.x-0.25)*(point.x-0.25)+point.y*point.y;
	return point.x<sqrt(p)-2*p+0.25 || (point.x+1)*(point.x+1)+point.y*point.y<0.0625;

}

vec2 iterate(vec2 point)
{
	return vec2(point.x*point.x-point.y*point.y,2*point.x*point.y);
}
vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 pixel)
{
	//Relative point
	vec2 point=pos+pixel*view/vs;

	number i=0;
	vec2 z=vec2(0);
	if(!check(point)){
		while(z.x*z.x+z.y*z.y<4 && i<maxi){
			z=iterate(z+point);
			i++;
		}
		if(i<maxi){
			return RGBA(i);
		}
	}
	return vec4(0,0,0,1);
}
