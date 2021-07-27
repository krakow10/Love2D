//By xXxMoNkEyMaNxXx
uniform float t;

uniform vec2 ScreenOffset;
uniform vec2 ScreenView;
uniform vec3 WorldOffset;
uniform vec2 WorldView;

uniform int n=0;
uniform vec3 objectPosition[96]={vec3(0)};
uniform float objectCharge[96]={0};
uniform float maxPotential;

uniform bool draw_fieldArrows=true;
uniform bool draw_fieldModulo=false;
uniform float cte=0;
uniform float cteModulo=0.5;
uniform vec3 dir=vec3(1,0,0);

uniform float equipotential=0;

uniform bool draw_equipotentialModulo=true;
uniform float animationSpeed=0;
uniform float equipotentialModulo;

uniform float LineThickness=2.4;
uniform float arrowWidth=20;
uniform float arrowLength=15;

uniform vec3 PlusColour=vec3(1,0,0);
uniform vec3 MinusColour=vec3(0,0,1);
uniform vec3 FieldLineColour=vec3(0,0,0);
uniform vec3 EquipotentialLineColour=vec3(0,0.5,0);

uniform bool enabled_canvases[3]={true,true,false};

float getAlpha(float f,float df,float thickness)
{
	if(df!=0)
		return clamp((thickness-2*abs(f/df))/min(2,thickness),0,1);
	return 0;
}

void effects(vec4 _0,sampler2D _1,vec2 _2,vec2 pixel)
{
	vec3 WorldPoint=WorldOffset+vec3((WorldView/ScreenView)*(pixel-ScreenOffset),0);
	float Ep=0;
	vec3 Ef=vec3(0);
	vec3 Ec=vec3(0);
	vec3 dEc=vec3(0);
	for(int i=0;i<n;++i){
		vec3 r=WorldPoint-objectPosition[i];
		float rsq=dot(r,r);
		float qi=objectCharge[i]/sqrt(rsq);
		Ep+=qi;
		Ef+=(qi/rsq)*r;
		Ec+=qi*r;
		dEc+=qi*(dir-(dot(dir,r)/rsq)*r);
	}

	int canvas=0;

	//Electric potential
	if(enabled_canvases[0]){
		vec4 colour=vec4(0,0,0,0);
		if(Ep>0)
			colour=vec4(PlusColour,sqrt(Ep/maxPotential));
		else if(Ep<0)
			colour=vec4(MinusColour,sqrt(-Ep/maxPotential));
		love_Canvases[canvas]=colour;
		++canvas;
	}

	//Equipotential lines
	float f_Ep=Ep-equipotential;
	float df_Ep=length(Ef*vec3(WorldView/ScreenView,1));
	if(draw_equipotentialModulo)
		f_Ep=equipotentialModulo*(mod(f_Ep/equipotentialModulo+mod(0.5+t*animationSpeed,1),1)-0.5);
	if(enabled_canvases[1]){
		love_Canvases[canvas]=vec4(EquipotentialLineColour,getAlpha(f_Ep,df_Ep,LineThickness));
		++canvas;
	}

	//Electric field lines
	if(enabled_canvases[2]){
		float f_Ec=dot(dir,Ec)-cte;
		float df_Ec=length(dEc*vec3(WorldView/ScreenView,1));
		float arrowAlpha=0;
		if(draw_fieldModulo)
			f_Ec=cteModulo*(mod(f_Ec/cteModulo+0.5,1)-0.5);
		if(draw_fieldArrows){
			float dis=f_Ep/df_Ep;
			if(2*abs(dis)<arrowLength){
				arrowAlpha=getAlpha(f_Ep,df_Ep,arrowLength)*getAlpha(f_Ec,df_Ec,arrowWidth*(0.5+dis/arrowLength));
			}
		}
		love_Canvases[canvas]=vec4(FieldLineColour,arrowAlpha+(1-arrowAlpha)*getAlpha(f_Ec,df_Ec,LineThickness));
		++canvas;
	}
}
