color[][] walls = new color[800][600];
int[][] wallGradient = new int[800][600];
color[][] lightmap = new color[800][600];

ArrayList<LightSource> lamps = new ArrayList<LightSource>();
ArrayList<Ray> rays = new ArrayList<Ray>();
int[] screenBuf;

boolean showWallGradient = false;

boolean dragging = false;
LightSource draggingLightSource;

void create_rectangle(int x, int y, int w, int h, color c){
    for (int j = 0; j < h; j++) {
        for (int i = 0; i < w; i++) {
            if(i==0){
                wallGradient[x+i][y+j] = 1;
                wallGradient[x+i+1][y+j] = 1;
            }
            else if(i==w-1){
                wallGradient[x+i][y+j] = 1;
                wallGradient[x+i-1][y+j] = 1;
            }
            if(j==0){
                wallGradient[x+i][y+j] = 2;
                wallGradient[x+i][y+j+1] = 2;
            }
            else if(j==h-1){
                wallGradient[x+i][y+j] = 2;
                wallGradient[x+i][y+j-1] = 2;
            }
            walls[x+i][y+j] = c;
        }
    }
}

void place_light_source(int x, int y, float intensity, color lightColor){
    lamps.add(new LightSource(x, y, intensity, lightColor));
}

void setup(){
    size(600, 400, FX2D);
    
    create_rectangle(100, 100, 100, 100, color(50, 55, 212));
    create_rectangle(250, 100, 100, 100, color(200, 32, 34));

    place_light_source(200, 260, 0.7, color(225,225,225));
    place_light_source(200, 260, 0.9, color(240,50,70));
    place_light_source(200, 50, 0.87, color(30,40,240));
    //place_light_source(200, 100, 0.8, color(200,150,80));
    screenBuf = new int[width*height];
}

boolean check_col(int x, int y){
    if(isVectorOutOfBounds(x, y)){
        return false;
    }
    return walls[x][y] != 0;
}


boolean is_col_vertical(PVector curr){
    int x = (int) curr.x;
    int y = (int) curr.x;
    if(wallGradient[x][y] == 2){
        return true;
    } else {
        return false;
    }
}

void create_rays(){
    int RAYS_PER_LAMP = 360;
    for(LightSource lamp : lamps){
        Ray[] _rays = lamp.createRays(RAYS_PER_LAMP);
        for(Ray r : _rays){
            rays.add(r);
        }
    }
}

boolean isVectorOutOfBounds(PVector p){
    if(p.x < 0 || p.x > width){
        return true;
    }
    else if(p.y < 0 || p.y > height){
        return true;
    }
    return false;
}

boolean isVectorOutOfBounds(int x, int y){
    if(x < 0 || x >= width){
        return true;
    }
    else if(y < 0 || y >= height){
        return true;
    }
    return false;
}

void follow_rays(){
    float STEP_SIZE = 1;
    float FALLOFF = 0.012;
    float CUTOFF_POINT = 0.01;
    int MAX_BOUNCES = 8;

    for(int i = rays.size() - 1; i >= 0; i--){
        Ray r = rays.get(i);

        r.step(STEP_SIZE);
        r.multiplyIntensity(1 - FALLOFF);

        if(check_col((int) r.position.x, (int) r.position.y)){
            boolean onVertical = is_col_vertical(r.position);
            int x = (int) r.position.x;
            int y = (int) r.position.y;
            color bounceColor = walls[x][y];
            r.bounce(onVertical, bounceColor);
        }
        
        if(isVectorOutOfBounds(r.position)){
            rays.remove(i);
        } else if(r.intensity < CUTOFF_POINT){
            rays.remove(i);
        } else if(r.bounces >= MAX_BOUNCES){
            //rays.remove(i);
        }
    }
}

color add_colors(color c1, color c2){
    return color((red(c1)+red(c2)), (green(c1)+green(c2)), (blue(c1)+blue(c2)));
}

color mix_colors(color c1, color c2, float mix){
    return color((1-mix)*red(c1)+red(c2)*mix, (1-mix)*green(c1)+green(c2)*mix, (1-mix)*blue(c1)+blue(c2)*mix);
}

void update_raymap(PImage buffer){
    for(Ray r : rays){
        color rayColor = r.getColor();
        color bufferColor = buffer.get((int) r.position.x, (int) r.position.y);
        buffer.set((int) r.position.x, (int) r.position.y, add_colors(rayColor, bufferColor));
    }
}

void draw_walls(PImage buffer){
    for (int j = 0; j < walls[0].length; j++) {
        for (int i = 0; i < walls.length; i++) {
            if(walls[i][j] != 0){
                color c = walls[i][j];
                buffer.set(i, j, c);
            }
        }
    }
}

void draw_wall_gradient(PImage buffer){
    for (int j = 0; j < wallGradient[0].length; j++) {
        for (int i = 0; i < wallGradient.length; i++) {
            if(walls[i][j] != 0){
                colorMode(HSB, 100);
                color c = color(100/4*wallGradient[i][j],100,100);
                buffer.set(i, j, c);
                colorMode(RGB, 100);
            }
        }
    }
}

PImage create_light_buffer(){
    PImage buffer = new PImage(width, height);

    int FOLLOW_RAY_STEPS = 100;

    create_rays();
    for (int l = 0; l < FOLLOW_RAY_STEPS; ++l) {
        follow_rays();
        if(rays.size() > 0){
            update_raymap(buffer);
        }
    }

    return buffer;
}


PImage buffer;
void draw(){
    background(0, 0, 0);
    frameRate(30);

    if(dragging){
        draggingLightSource.position.set(mouseX, mouseY);
    }

    buffer = create_light_buffer();

    //buffer.filter(BLUR, 3);

    draw_walls(buffer);

    if(showWallGradient){
        draw_wall_gradient(buffer);
    }

    image(buffer, 0, 0);


    
    // Fast blur, 3x3
    /*
    loadPixels();
    shiftBlur3(pixels, screenBuf);
    shiftBlur3(pixels, screenBuf);
    arrayCopy(screenBuf, pixels);
    updatePixels();//*/
    

    text("FPS: "+(int)frameRate, 15, 20);
    text("Rays: "+(int)rays.size(), 15, 20+25*1);
    text("Dragging: "+dragging, 15, 20+25*2);
    text("showWallGradient: "+showWallGradient, 15, 20+25*3);
}

void mousePressed(){
    for(LightSource lamp : lamps){
        if(lamp.distanceTo(new PVector(mouseX, mouseY)) < 50){
            draggingLightSource = lamp;
            dragging = true;
            break;
        }
    }
}
 
void mouseReleased(){
    dragging = false;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      showWallGradient = !showWallGradient; // Toggle
    }
  }
}