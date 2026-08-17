/* Consumer used only after OpenStepMesa342.pkg has been installed.
   It may include and link only the selected package prefix. */
#include <stdio.h>
#include <stdlib.h>

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/osmesa.h>

int
main(void)
{
    OSMesaContext context;
    GLubyte *buffer;
    const GLubyte *version;
    const GLubyte *glu_text;
    int width;
    int height;
    int result;

    width = 16;
    height = 16;
    result = 1;
    buffer = (GLubyte *)malloc((size_t)(width * height * 4));
    if (buffer == NULL) {
        fprintf(stderr, "package-mesa-consumer: allocation failed\n");
        return result;
    }

    context = OSMesaCreateContext(GL_RGBA, NULL);
    if (context == NULL) {
        fprintf(stderr, "package-mesa-consumer: OSMesaCreateContext failed\n");
        free(buffer);
        return result;
    }
    if (!OSMesaMakeCurrent(context, buffer, GL_UNSIGNED_BYTE, width, height)) {
        fprintf(stderr, "package-mesa-consumer: OSMesaMakeCurrent failed\n");
        OSMesaDestroyContext(context);
        free(buffer);
        return result;
    }

    glClearColor(0.25f, 0.5f, 0.75f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    version = glGetString(GL_VERSION);
    glu_text = gluErrorString(GL_NO_ERROR);
    if (version == NULL || glu_text == NULL || glGetError() != GL_NO_ERROR) {
        fprintf(stderr, "package-mesa-consumer: GL or GLU failed\n");
        OSMesaDestroyContext(context);
        free(buffer);
        return result;
    }

    printf("package-mesa-consumer: PASS GL_VERSION=%s GLU=%s\n",
           (const char *)version, (const char *)glu_text);
    OSMesaDestroyContext(context);
    free(buffer);
    return 0;
}
