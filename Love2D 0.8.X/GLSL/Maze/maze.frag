//By xXxMoNkEyMaNxXx
extern number md;
extern vec2 mp;

extern vec4 C0;
extern vec4 C1;

extern vec2 size;
extern vec4 RAND;

extern number radius;
extern number ratio;

int state(vec4 colour)
{
	if(dot(colour-(C0+C1)/2,C1-C0)>=0){return 1;}
	return 0;
}

vec4 effect(vec4 _0,Image img,vec2 percent,vec2 _1)
{
	if(md==1&&distance(mp,vec2(_1.x,size.y-_1.y))<=pow(radius,1.5)){return C0;}
	int cell=state(Texel(img,percent));
	number rand=mod(mod(mod((percent.y*size.y+percent.x)*size.x/pow(RAND.x,3.3),RAND.w)/pow(RAND.y,2.2),RAND.w)/pow(RAND.z,1.1),RAND.w)/RAND.w;
	vec2 unit=1/size;
	number neighbors=0;
	for(number x=ceil(-radius);x<=floor(radius);x++){
		for(number y=ceil(-sqrt(radius*radius-x*x));y<=floor(sqrt(radius*radius-x*x));y++){
			if(x!=0&&y!=0&&x*x+y*y<=radius*radius){
				neighbors+=state(Texel(img,percent+unit*vec2(x,y)))*pow(radius*radius-x*x-y*y,0.3);
			}
		}
	}
	if(cell==1){if(rand<0.999){return C1;}return C0;}
	if((neighbors==0&&rand>0.99999)||((neighbors>=1&&neighbors/(radius*radius)<ratio)&&rand<pow(0.00001,neighbors))){return C1;}
	return C0;
}
