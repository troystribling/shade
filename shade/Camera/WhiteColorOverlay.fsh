varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

void main()
{
    highp vec3 color = vec3(1.0, 1.0, 1.0);
    highp vec4 pixcol = texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = vec4(color, pixcol.a);
}