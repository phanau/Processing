uniform float time;
uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

/*
 * Both 2D and 3D texture coordinates are defined, for testing purposes.
 */
varying vec2 v_texCoord2D;
varying vec3 v_texCoord3D;
varying vec4 v_color;

void main( void )
{
	gl_Position = transform * position;

	v_texCoord2D = (texMatrix * vec4(texCoord, 1.0, 1.0)).st;
	v_texCoord3D = position.xyz;
	
	v_color = color;

}


