After cloning, do:

`git submodule update --init --depth 1`

then run:

`./sparse_checkout.sh`

build:
```
g++ main.cpp \
    lib/imgui/imgui.cpp \
    lib/imgui/imgui_draw.cpp \
    lib/imgui/imgui_tables.cpp \
    lib/imgui/imgui_widgets.cpp \
    lib/imgui/imgui_demo.cpp \
    lib/imgui/backends/imgui_impl_glfw.cpp \
    lib/imgui/backends/imgui_impl_opengl3.cpp \
    -Ilib/imgui -Ilib/imgui/backends \
    -lglfw -lGL -ldl -lpthread -lX11 -lXrandr -lXi -lXcursor -lXxf86vm \
    -o imgui_app
```
