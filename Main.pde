
Color s_set;
ArrayList<Body> bodies;

import java.util.ArrayList;

int bodies_amount = 0;

PVector world_offset;
PVector last_move;

private float time = 0.5;

ArrayList<Star> stars = new ArrayList<Star>();

private int current_spawn = 1;

private float overlap_multi = 1.0;

private boolean overlap_active = false;

private Body hover_body;
private Body focus_body;
private boolean focus_transition;
private boolean focus = false;

boolean watch_mode = false;

float zoom = 1.0;

int glow_strenght = 7;

void setup() {

  world_offset = new PVector(0, 0);
  last_move = new PVector(0, 0);
  size(900, 900);
  
  
  frameRate(120);
  //fullScreen();
  s_set = new Color();
  bodies = new ArrayList<Body>();
  noStroke();
  pixelDensity(2);

  bodies.add(new Body(new Point(width/2, height/2), 40, 50000, false, color(255, 255, 237), color(255, 255, 130, glow_strenght), bodies_amount));
  bodies_amount ++;

  int max_offset = 1000;
  for (int i = 0; i < 1800; i ++) {
    stars.add(new Star(random(- max_offset, width +max_offset), random(-max_offset, height+max_offset), random(0.01, 0.1), int(random(50, 140))));
  }
}
float time_display_clock = 0.0;
void draw() {
  background(s_set.grey);
  
      //println(str(world_offset.x));

  //smooth aninmation transition
  if(focus_transition){
    println(str((focus_body.position.x - world_offset.x) - width/2));
    float deltaFX = (focus_body.position.x + world_offset.x) - (width/2);
    float deltaFY = (focus_body.position.y + world_offset.y) - (height/2);
    
    if(new PVector(deltaFX, deltaFY).mag() > 1.0){
       world_offset.x -= deltaFX / 15.0;
       world_offset.y -= deltaFY / 15.0;
    } else{
      focus_transition = false;
      focus = true;
    }
  
  }
  if(focus){
    world_offset.x = -(focus_body.position.x - width/2);
    world_offset.y = -(focus_body.position.y - height/2);
  }


  for (int i = 0; i < 1000; i ++) {
    fill(230, 230, 230, stars.get(i).alpha);
    circle(stars.get(i).x + world_offset.x * stars.get(i).depth, stars.get(i).y + world_offset.y * stars.get(i).depth, 2);
  }
  
  
  if (get_mode() == 1) {
    cursor(CROSS);
    watch_mode = true;
  } else {
    if(watch_mode){
       cursor(ARROW);
       watch_mode = false;
    }
  }

  textSize(30);
  fill(200, 200, 200);

  // TIME EDIT
  if (get_key()) {
    time_display_clock = millis();
  }
  if (millis() - time_display_clock < 2000) {
    text(str(time), 10, 30);
  }

  if (moving) {
    move();
  }

  //PULLING VARIABLES
  int div = 40;
  //dist
  float div2 = 10.0;
  float sizeDiv = 23.0;

  //pulling visual
  if (pulling) {
    //stroke(#55676C);

    PVector pull = new PVector(mouseX - mx, mouseY - my);
    PVector norm = pull.copy();
    norm.normalize();

    fill(#55676C);

    // BACK TRACK ****
    for (int i = 0; i < min(max(3, int( pull.mag() / div)), 7); i++) {
      if (pull.mag() < 300) {
        circle(mx + (i* ((mouseX - mx)/div2)), my + (i* ((mouseY - my)/div2)), (pull.mag()/sizeDiv)/(sqrt(float(i))));
      } else {
        circle(mx + (i* ((norm.x * 300)/div2)), my + (i* ((norm.y * 300)/div2)), (pull.mag()/(sizeDiv/(1.0+ float(i)*0.05)))/(sqrt(float(i))));
      }
    }
    
    
    // FORWARD TRACK ****
    
    PVector[] last_p = new PVector[3];
    
    Body temp_b = new Body(new Point(mx - world_offset.x, my - world_offset.y), 20, bodies_amount);
    temp_b.movement = (new PVector(mx - mouseX, my - mouseY)).div(100);
    
    last_p[0] = new PVector(mx - world_offset.x, my - world_offset.y);
    last_p[1] = temp_b.movement;
    last_p[2] = new PVector(5.0,5.0);
    
    for(int i = 0; i < 700; i++){
      fill(85,103,108,200-i*1.0);
      last_p = temp_b.get_movement(bodies, last_p[0], last_p[1], 1.0, time);
      circle(last_p[0].x + world_offset.x, last_p[0].y + world_offset.y, 5);
    }

    strokeWeight(20.0);
    strokeCap(ROUND);
    fill(#55676C);
    //line(mx, my, mouseX, mouseY);
    noStroke();
  }
  
  overlap_active = false;
  
  for (Body body : bodies) {
    overlap_multi = 1.0;
    if (!overlap_active && !watch_mode){
      if(body.get_overlap(new Point(mouseX, mouseY))){
        overlap_multi = 1.3;
        hover_body = body;
        overlap_active = true;
        cursor(HAND);
      }else if(overlap_active){
        cursor(ARROW);
        hover_body = null;
        overlap_active = false;
        overlap_multi = 1.0;
      }
    }
    if(body.multi != overlap_multi){
      if(abs(overlap_multi - body.multi) > 0.01){
        body.multi += (overlap_multi - body.multi)/10.0;
      } 
    }
    
    if (body.cycle < 100) {
      body.cycle += 1;
    }

    if (!body.glued) {
      body.move(bodies, time);
    }
    // MAIN BODY DRAW ****
    fill(body.sec_color);
    for(int i = 0; i < 12; i++){

      circle(body.position.x + world_offset.x, body.position.y + world_offset.y, body.size * body.intro_cycle[body.cycle] * (1 + pow(i,2) * 0.005) * body.multi);
    }
  
    fill(body.body_color);
    circle(body.position.x + world_offset.x, body.position.y + world_offset.y, body.size * body.intro_cycle[body.cycle] * body.multi);

  }
  if(!overlap_active && !watch_mode){
    cursor(ARROW);
    hover_body = null;
  }
}


boolean reset = false;

//Moving using the mouse
void move() {
  PVector mouse_pos = new PVector(mouseX, mouseY);
  if (reset) {
    mouse_pos.sub(last_move);
    world_offset.add(mouse_pos);
  }
  reset = true;
  last_move = new PVector(mouseX, mouseY);
}
private boolean press_once;
boolean get_key() {
  if (keyPressed && keyCode == 38 && press_once == false) {
    time += 0.1;
    press_once = true;
    return true;
  }
  if (keyPressed && keyCode == 40 && press_once == false) {
    time -= 0.1;
    press_once = true;
    return true;
  }
  if (keyPressed && keyCode == 39 && press_once == false) {
    current_spawn += 1;
    press_once = true;
    return true;
  }
  if (keyPressed && keyCode == 37 && press_once == false) {
    current_spawn -= 1;
    press_once = true;
    return true;
  }
  if (keyPressed) {
    if (key == 'a' || key == 'A') {
      zoom += 0.01;
    }
    if (key == 's' || key == 'S') {
      zoom -= 0.01;
    }
  }

  time = int(time * 10)/10.0;

  return false;
}
void keyReleased() {
  if (keyCode == 38 || keyCode == 40) {
    press_once = false;
  }
  if (keyCode == 37 || keyCode == 39) {
    press_once = false;
  }
}

int get_mode() {
  if (keyPressed && keyCode == 17) {
    return 1;
  }
  return 0;
}
int mx;
int my;
boolean pulling = false;
boolean moving = false;

void mousePressed() {
  if (get_mode() == 1) {
    moving = true;
  } else {
    if (!overlap_active){
      pulling = true;
      mx = mouseX;
      my = mouseY;
    }else{
      focus_body = hover_body;
      focus_transition = true;
    }
  }
}

void mouseReleased() {
  reset = false;
  moving = false;

  if (get_mode() == 1) {
  } else if(pulling) {
    pulling = false;
    
    if(current_spawn == 1){
      Body b = new Body(new Point(mx - world_offset.x, my - world_offset.y), 20, 20, false, color(123, 196, 255), color(123, 196, 255, glow_strenght), bodies_amount);
      b.movement = (new PVector(mx - mouseX, my - mouseY)).div(100);
      bodies.add(b);


    }else if(current_spawn == 2){
      Body b = new Body(new Point(mx - world_offset.x, my - world_offset.y), 2, 0.1, false, color(230, 230, 230), color(230, 230, 230, glow_strenght), bodies_amount);
      b.movement = (new PVector(mx - mouseX, my - mouseY)).div(100);
      bodies.add(b);


    }else{
      Body b = new Body(new Point(mx - world_offset.x, my - world_offset.y), 40, 100, false, color(123, 196, 255), color(123, 196, 255, glow_strenght), bodies_amount);
      b.movement = (new PVector(mx - mouseX, my - mouseY)).div(100);
      bodies.add(b);
    }
    
    bodies_amount ++;
  }
}

void keyPressed() {
}
