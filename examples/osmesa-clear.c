#include <GL/osmesa.h>
#include <GL/gl.h>

int
main(void)
{
    OSMesaContext context;
    unsigned char pixels[16 * 16 * 4];
    context = OSMesaCreateContext(GL_RGBA, 0);
    if (context == 0) return 1;
    if (!OSMesaMakeCurrent(context, pixels, GL_UNSIGNED_BYTE, 16, 16)) return 2;
    glClearColor(0.0f, 0.5f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    if (glGetError() != GL_NO_ERROR) return 3;
    OSMesaDestroyContext(context);
    return 0;
}
