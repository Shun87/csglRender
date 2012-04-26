
precision mediump float;
uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;

varying highp vec2 coordinate;

void main()
{
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = texture2D(SamplerY, coordinate).r;
    
    yuv.yz = texture2D(SamplerUV, coordinate).ra - vec2(0.5, 0.5);
    
    // Using BT.709 which is the standard for HDTV
    rgb = mat3(      1,       1,       1,
               0, -.21482, 2.12798,
               1.28033, -.38059,       0) * yuv;
    
    gl_FragColor = vec4(rgb, 1);
}