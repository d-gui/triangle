module ui.triangle;

version ( GL3 ):
import deps.gl3;
import ui.shaders  : linearShader;
import ui.vertex   : Vertex5;
import ui.glerrors : checkGlError;


nothrow @nogc
void drawTriangle( T )( T x, T y, T x2, T y2, T x3, T y3, float r, float g, float b )
  if ( is( T == int ) || is( T == uint ) || is( T == long ) || is( T == ulong ) )
{
    int viewportWidth  = 800;
    int viewportHeight = 600;
    float windowedViewportCenterX = cast( GLfloat ) viewportWidth  / 2;
    float windowedViewportCenterY = cast( GLfloat ) viewportHeight / 2;

    //
    pragma( inline, true )
    auto deviceX( T windowedX )
    {
        return ( cast( GLfloat ) windowedX - windowedViewportCenterX ) / viewportWidth * 2;
    }

    pragma( inline, true )
    auto deviceY( T windowedY )
    {
        return -( cast( GLfloat ) windowedY - windowedViewportCenterY ) / viewportHeight * 2;
    }

    //
    GLfloat GL_x = deviceX( x );
    GLfloat GL_y = deviceY( y );

    GLfloat GL_x2 = deviceX( x2 );
    GLfloat GL_y2 = deviceY( y2 );

    GLfloat GL_x3 = deviceX( x3 );
    GLfloat GL_y3 = deviceY( y3 );

    //printf( "x,  y  : %d, %d\n", x,  y );
    //printf( "x2, y2 : %d, %d\n", x2, y2 );
    //printf( "x,  y  : %f, %f\n", GL_x,  GL_y );
    //printf( "x2, y2 : %f, %f\n", GL_x2, GL_y2 );

    //
    Vertex5[3] vertices =
    [
        Vertex5( GL_x,  GL_y,  r, g, b ), // start
        Vertex5( GL_x2, GL_y2, r, g, b ), // end
        Vertex5( GL_x3, GL_y3, r, g, b ), // end
    ];

    //auto vao = VAO( vertices );
    GLuint vbo;
    GLuint vao;

    // Style
    glUseProgram( linearShader ); checkGlError( "glUseProgram" );

    // Create buffers
    glGenBuffers( 1, &vbo ); checkGlError( "glGenBuffers" );
    glGenVertexArrays( 1, &vao ); checkGlError( "glGenVertexArrays" );

    // Upload data to GPU
    glBindBuffer( GL_ARRAY_BUFFER, vbo ); checkGlError( "glBindBuffer" );
    glBufferData( GL_ARRAY_BUFFER, vertices.sizeof, vertices.ptr, /*usage hint*/ GL_STATIC_DRAW ); checkGlError( "glBufferData" );

    glBindVertexArray( vao ); checkGlError( "glBindVertexArray" );

    // Describe array
    glVertexAttribPointer(
        /*location*/ 0, 
        /*num elements*/ 2, 
        /*base type*/ GL_FLOAT, 
        /*normalized*/ GL_FALSE,
        Vertex5.sizeof, 
        cast( void* ) Vertex5.x.offsetof
    ); checkGlError( "glVertexAttribPointer 1" );
    glEnableVertexAttribArray( 0 ); checkGlError( "glEnableVertexAttribArray" );

    glVertexAttribPointer(
        /*location*/ 1, 
        /*num elements*/ 3, 
        /*base type*/ GL_FLOAT, 
        /*normalized*/ GL_FALSE,
        Vertex5.sizeof, 
        cast( void* ) Vertex5.r.offsetof
    ); checkGlError( "glVertexAttribPointer 2" );
    glEnableVertexAttribArray( 1 ); checkGlError( "glEnableVertexAttribArray" );

    // Draw
    glDrawArrays( GL_TRIANGLES, /*first*/ 0, /*count*/ cast( int ) vertices.length ); checkGlError( "glDrawArrays" );

    // Free
    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(0);
    glBindVertexArray( 0 );
    glUseProgram( 0 );
    glDeleteBuffers( 1, &vbo );
    glDeleteVertexArrays( 1, &vao );
}
