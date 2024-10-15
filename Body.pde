

class Body{
  public boolean glued;
  public Point position;
  public float weight;
  public color body_color, sec_color;
  public int size;
  public int cycle;
  public float[] intro_cycle;
  public int id;
  
  public float multi = 1.0;
  
  private float control_width = 20;
  private float G = 0.04;
  public PVector movement;
  
  
  HashMap<Integer, Float> ind_mag = new HashMap<Integer, Float>();

  
  
  Body(Point _position, int _size, float _weight, boolean _glued, color _color, color _sec_color, int _id){
    id = _id;
    glued = _glued;
    size = _size;
    position = _position;
    weight = _weight;
    body_color = _color;
    sec_color = _sec_color;
    cycle = 0;
    
    intro_cycle = animate_intro();
    movement = new PVector(0,0);
  }
  Body(Point _position, int _size, color _color, color _sec_color, int _id){
    id = _id;
    size = _size;
    position = _position;
    body_color = _color;
    sec_color = _sec_color;
  }
  Body(Point _position, float _weight, int _id){
    id = _id;
    position = _position;
    weight = _weight;
    movement = new PVector(0,0);
  }
 
  void move(ArrayList<Body> bodies, float time){
    PVector sumVector = new PVector(0,0);
    for (Body body : bodies) {
      if(this.id != body.id){
        
        float force = 0;
        float acceleration = 0;
        // distance between this body and the other body
        PVector deltaVector = new PVector(( body.position.x - position.x ), (body.position.y - position.y));
        // length between bodies
        float r = deltaVector.mag();
        // direction vector
        deltaVector.normalize();
        
        // checks if body is outside control width
        if(abs(r) > control_width ){
          // calculating force
          force = (G * (body.weight * weight)/pow(r, 2));
          acceleration = (force / weight) * time;
          ind_mag.put(body.id, acceleration);
          sumVector.add(deltaVector.mult(acceleration));
          
        }else{
          // if this body is within control width, last force is used
          sumVector.add(deltaVector.mult(ind_mag.get(body.id)));
        }
      }
    }
    
    movement.add(sumVector);
    PVector m2 = new PVector();
    PVector.mult(movement, time, m2);
    position.add(m2);
  }
  
  PVector[] get_movement(ArrayList<Body> bodies, PVector sim_position, PVector cur_movement, float span, float time){
    PVector sumVector = new PVector(0,0);
    for (Body body : bodies) {
      if(this.id != body.id){
        
        float force = 0;
        float acceleration = 0;
        // distance between this body and the other body
        PVector deltaVector = new PVector(( body.position.x - sim_position.x ), (body.position.y - sim_position.y));
        // length between bodies
        float r = deltaVector.mag();
        // direction vector
        deltaVector.normalize();
        
        // checks if body is outside control width
        if(abs(r) > control_width ){
          // calculating force
          force = (span * G * (body.weight * weight)/pow(r, 2));
          acceleration = (force / weight) * time;
          ind_mag.put(body.id, acceleration);
          sumVector.add(deltaVector.mult(acceleration));
          
        }else{
          // if this body is within control width, last force is used
          sumVector.add(deltaVector.mult(ind_mag.get(body.id)));
        }
      }
    }
    
    cur_movement.add(sumVector);
    PVector m2 = new PVector();
    PVector.mult(cur_movement, time * span, m2);
    
    PVector[] temp2 = new PVector[3];
    PVector m2_copy = m2.copy();
    temp2[0] = sim_position.add(m2);
    temp2[1] = cur_movement;
    temp2[2] = m2_copy;
    return temp2;
  }
  
  float[] animate_intro(){
    float[] intro = new float[101];
    intro[0] = 0;
    for(int x = 1; x < 100; x = x +1){
      intro[x] = -5 * (sin(x/5.0)/x) + 1;
    }
    intro[100] = 1;
    
    //for(int x = 0; x < 101; x = x +1){
    //  intro[x] = (sin(x/31.4 - PI/2.0) + 1)/2.0;
    //}
    
    return intro;
  }
  boolean get_overlap(Point mouse_pos){
    PVector delta = new PVector(mouse_pos.x - position.x - world_offset.x, mouse_pos.y - position.y - world_offset.y);
    float mag = delta.mag();
    if(mag < size * 1.5){
      return true;
    }
    return false;
  }
}
