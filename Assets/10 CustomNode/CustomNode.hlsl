
float4x4 MyMatrix;

void MyFunction_float(float2 st, float pct, out float Out) 
{
	Out = smoothstep(pct - 0.05, pct, st.y) -smoothstep(pct, pct + 0.05, st.y);
	//Out = smoothstep(pct, pct, st.y);
}