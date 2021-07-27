//By Quaternions
uniform int b=10;//why not

uniform float n0;
uniform float n1;

uniform sampler2D Font;
uniform sampler2D Sum;

uniform vec2 FontSize;
uniform vec2 DSize;

int ipow(int x,int y){
	if(y==0)
		return 1;
	if(y==1)
		return x;
	if(y==2)
		return x*x;
	if(y>1){
		int p=x;
		for(int i=1;i<y;++i)
			p*=x;
		return p;
	}
}

int imod(int x,int y){
	return x-x/y*y;//lol this looks so silly
}

vec4 SolvedSum(float x,float y0,float y1){//ok fine I'll do extra texture lookups....
	int n=int(floor(y1)-floor(y0));
	if(n>0)
		return texture2D(Sum,vec2(x,mod(y1,1)))-texture2D(Sum,vec2(x,mod(y0,1)))+n*texture2D(Sum,vec2(x,1));//okay this is really good
	else
		return texture2D(Sum,vec2(x,mod(y1,1)))-texture2D(Sum,vec2(x,mod(y0,1)));
}

//This could be quite heavily more optimized.  Different parts sample the same portions of the images.
vec4 effect(vec4 _0,sampler2D _1,vec2 _2,vec2 iPixel)
{
	vec2 p=vec2(iPixel.x-0.5,love_ScreenSize.y-iPixel.y-0.5);//Axtual pixel position

	float fdigit=(love_ScreenSize.x-p.x-1)/DSize.x;
	int digit=int(fdigit);
	int unit=ipow(b,digit);//digit unit

	//Digit start
	int d0i=int(n0/unit+1);//Total digit number, +1 because we don't want to include the entire number before, to be calculated in last step.
	int d0m=imod(d0i,b);//Actual digit number
	float d0f=mod(n0,unit);//if this is greater than unit-1, it's in the middle of turning

	//Digit end
	int d1i=int(n1/unit);
	int d1m=imod(d1i,b);
	float d1f=mod(n1,unit);
	
	//float dn=n1-n0;//Difference, will be treated like total time
	int di=d1i-d0i;//Digit difference.  Apply int(di/b) full turns
	vec2 ip=vec2(FontSize.x*(1-mod(fdigit,1)),p.y/DSize.y*FontSize.y);//Actual position on image texture

	vec4 c=vec4(0,0,0,0);//Total colour
	float w=0;//Total weight

	//Apply full turns
	if(di>=b){
		//Account for blurred motion
		w+=b;
		c+=texture2D(Sum,vec2(ip.x/FontSize.x,1))/FontSize.y;

		//Account for fixed positions
		if(unit>1){
			w+=b*(unit-1);
			for(int i=0;i<b;++i){
				c+=(unit-1)*texture2D(Font,vec2(ip.x/FontSize.x,(ip.y+i*FontSize.y)/(b*FontSize.y)));
			}
		}

		int n=di/b;//How many turns
		w*=n;
		c*=n;
	}

	//Apply partial turn
	if(d0m!=d1m&&di>0){
		//Simplified from code before
		int dn=imod(di,b);

		//blurred motion
		w+=dn;
		c+=SolvedSum(ip.x/FontSize.x,(d0m*FontSize.y+ip.y)/(b*FontSize.y),((d0m+dn)*FontSize.y+ip.y)/(b*FontSize.y))/FontSize.y;

		//fixed exposure
		if(unit>1){
			w+=dn*(unit-1);
			for(int i=d0m;i<d0m+dn;++i){
				c+=(unit-1)*texture2D(Font,vec2(ip.x/FontSize.x,(ip.y+imod(i,b)*FontSize.y)/(b*FontSize.y)));
			}
		}
	}

	//Apply pixel perfect faggotty ass shit
	if(di==-1){
		//Goin real slow ayy lmao motion blur it anyway from d0f to d1f
		w+=d1f-d0f;
		if(d1f<unit-1)//only fixed
			c+=(d1f-d0f)*texture2D(Font,vec2(ip.x/FontSize.x,(ip.y+d1m*FontSize.y)/(b*FontSize.y)));
		else if(d0f>unit-1)//only blurred
			c+=SolvedSum(ip.x/FontSize.x,((d1m+d0f-(unit-1))*FontSize.y+ip.y)/(b*FontSize.y),((d1m+d1f-(unit-1))*FontSize.y+ip.y)/(b*FontSize.y))/FontSize.y;
		else//fixed + blurred
			c+=((unit-1)-d0f)*texture2D(Font,vec2(ip.x/FontSize.x,(ip.y+d1m*FontSize.y)/(b*FontSize.y))) + SolvedSum(ip.x/FontSize.x,(d1m*FontSize.y+ip.y)/(b*FontSize.y),((d1m+d1f-(unit-1))*FontSize.y+ip.y)/(b*FontSize.y))/FontSize.y;
	}else{
		//add rest of n0
		w+=unit-d0f;
		if(d0f<unit-1)//blurred + fixed
			c+=SolvedSum(ip.x/FontSize.x,((d0m-1)*FontSize.y+ip.y)/(b*FontSize.y),(d0m*FontSize.y+ip.y)/(b*FontSize.y))/FontSize.y + (unit-1-d0f)*texture2D(Font,vec2(ip.x/FontSize.x,(ip.y+imod(d0i-1,b)*FontSize.y)/(b*FontSize.y)));
		else//Only blurred
			c+=SolvedSum(ip.x/FontSize.x,(((d0m-1)+d0f-(unit-1))*FontSize.y+ip.y)/(b*FontSize.y),(d0m*FontSize.y+ip.y)/(b*FontSize.y))/FontSize.y;

		//add start of n1
		w+=d1f;
		if(d1f<unit-1)//only fixed
			c+=d1f*texture2D(Font,vec2(ip.x/FontSize.x,(ip.y+d1m*FontSize.y)/(b*FontSize.y)));
		else//blurred + fixed
			c+=SolvedSum(ip.x/FontSize.x,(d1m*FontSize.y+ip.y)/(b*FontSize.y),((d1m+d1f-(unit-1))*FontSize.y+ip.y)/(b*FontSize.y))/FontSize.y + (unit-1)*texture2D(Font,vec2(ip.x/FontSize.x,(ip.y+d1m*FontSize.y)/(b*FontSize.y)));
	}

	return c/w;
}

