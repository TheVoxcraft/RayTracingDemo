class Ray{
    PVector position;
    PVector prev_position;
    float angle;

    float intensity;
    color lightColor;

    int bounces = 0;

    Ray(int x, int y, float _intensity, color _lightColor, float _angle){
        position = new PVector(x, y);
        prev_position = new PVector(x, y);
        intensity = _intensity;
        lightColor = _lightColor;
        angle = (float) Math.toRadians(_angle);
    }

    void step(float step_size){
        float x = step_size * cos(angle);
        float y = step_size * sin(angle);
        prev_position.set(position.x, position.y);
        position.add(x, y);
    }

    void multiplyIntensity(float x){
        intensity *= x;
    }

    void bounce(boolean onVertical, color wallColor){
        bounces += 1;
        // Change angle to do a proper bounce. Opposite axis?
        //double r = Math.toRadians(angle);
        double s = Math.sin(angle);
        
        if(!onVertical){
            //System.out.print("V");
            angle = (float) Math.asin(s);
        } else {
            //System.out.print("H");
            angle = (float) Math.acos(s);
        }

        lightColor = mix_colors(lightColor, wallColor, 0.7);
    }

    color getColor(){
        return color(red(lightColor) * intensity,
                     green(lightColor) * intensity,
                     blue(lightColor) * intensity);
    }
}