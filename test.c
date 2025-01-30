#include <raylib.h>

int main() {
    int size;
    InitWindow(800, 800, "TEST");

    unsigned char *data = LoadFileData("res/cyan.png", &size);
    Image image = LoadImageFromMemory(".png", data, size);
    Texture texture = LoadTextureFromImage(image);
    DrawTexturePro(texture, (Rectangle){0, 0, texture.width, texture.height}, (Rectangle){100, 100,
    texture.width, texture.height}, (Vector2){100.0f, 100.0f}, 100.0f, RED);
}
