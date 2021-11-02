class LightSource {

    PVector position;
    float intensity;
    color lightColor;

    boolean dragging = false;

    LightSource(int x, int y, float _intensity, color _lightColor){
        position = new PVector(x, y);
        intensity = _intensity;
        lightColor = _lightColor;
    }

    Ray[] createRays(int amt){
        Ray[] rays = new Ray[amt];
        for (int i = 0; i < rays.length; ++i) {
            float angle = i;
            rays[i] = new Ray((int)position.x, (int)position.y, intensity, lightColor, angle);
        }
        return rays;
    }

    float distanceTo(PVector other){
        return position.dist(other);
    }

}