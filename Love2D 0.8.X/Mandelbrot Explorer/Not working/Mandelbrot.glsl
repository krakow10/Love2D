//By xXxMoNkEyMaNxXx
extern number maxi;
extern vec2 vs;

extern number posx1;
extern number posx2;
extern number posx3;
extern number posx4;
extern number posx5;
extern number posx6;
extern number posx7;
extern number posx8;
extern number posx9;
extern number posx10;

extern number posy1;
extern number posy2;
extern number posy3;
extern number posy4;
extern number posy5;
extern number posy6;
extern number posy7;
extern number posy8;
extern number posy9;
extern number posy10;

extern number viewx1;
extern number viewx2;
extern number viewx3;
extern number viewx4;
extern number viewx5;
extern number viewx6;
extern number viewx7;
extern number viewx8;
extern number viewx9;
extern number viewx10;

extern number viewy1;
extern number viewy2;
extern number viewy3;
extern number viewy4;
extern number viewy5;
extern number viewy6;
extern number viewy7;
extern number viewy8;
extern number viewy9;
extern number viewy10;

number[10] posx={posx1,posx2,posx3,posx4,posx5,posx6,posx7,posx8,posx9,posx10};
number[10] posy={posy1,posy2,posy3,posy4,posy5,posy6,posy7,posy8,posy9,posy10};
number[10] viewx={viewx1,viewx2,viewx3,viewx4,viewx5,viewx6,viewx7,viewx8,viewx9,viewx10};
number[10] viewy={viewy1,viewy2,viewy3,viewy4,viewy5,viewy6,viewy7,viewy8,viewy9,viewy10};

number pwr=2;
number pi=3.1415926535898;

//Power of ten based numbaz
number ratio=10000000.;
number[10] add(number[10] n1,number[10] n2)
{
	number[10] sum;
	for(int i=0;i<10;i++){
		sum[i]=n1[i]+n2[i];
	}
	return sum;
}
number[10] sub(number[10] n1,number[10] n2)
{
	number[10] diff;
	for(int i=0;i<10;i++){
		diff[i]=n1[i]-n2[i];
	}
	return diff;
}
number[10] mul(number[10] n1,number[10] n2)
{
	number[10] prod;
	for(int i1=0;i1<10;i1++){
		for(int i2=0;i2<10;i2++){
			int place=i1+i2;
			if(place<10){
				number pp=n1[i1]*n2[i2];
				number mpp=mod(pp,ratio);
				prod[place]+=(pp-mpp)/ratio;
				if(place+1<10){
					prod[place+1]+=mpp;
				}
			}
		}
	}
	return prod;
}
number[10] mulnum(number[10] n1,number n2)
{
	number[10] prod;
	for(int i=0;i<10;i++){
		number pp=n1[i]*n2;
		number mpp=mod(pp,ratio);
		number fpp=floor(mpp);
		prod[i]+=fpp;
		if(i+1<10){
			prod[i+1]+=(mpp-fpp)*ratio;
		}
		if(i>0){
			prod[i-1]+=(pp-mpp)/ratio;
		}
	}
	return prod;
}
//yee


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

bool check(number x,number y)
{
	number p=(x-0.25)*(x-0.25)+y*y;
	return x<sqrt(p)-2*p+0.25 || (x+1)*(x+1)+y*y<0.0625;

}

number[10] iterate_x(number[10] px,number[10] py)
{
	return sub(mul(px,px),mul(py,py));
}
number[10] iterate_y(number[10] px,number[10] py)
{
	return mulnum(mul(px,py),2);
}

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 pixel)
{
	//Relative point
	vec2 percent=pixel/vs;
	number[10] px=add(posx,mulnum(viewx,percent.x));
	number[10] py=add(posy,mulnum(viewy,percent.y));

	if(!check(px[0],py[0])){
		number i=0;
		number[10] zx;
		number[10] zy;
		while(zx[0]*zx[0]+zy[0]*zy[0]<4 && i<maxi){
			zx=add(zx,px);
			zy=add(zy,py);

			zx=iterate_x(zx,zy);
			zy=iterate_y(zx,zy);
			i++;
		}
		if(i<maxi){
			return RGBA(i);
		}
	}
	return vec4(0,0,0,1);
}
