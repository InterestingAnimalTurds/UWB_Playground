import hypermedia.net.*;


float cos_a;
float sin_a;
JSONObject json;

// Client myClient; 
// String inString;

UDP udp; 

String message;
float range_1;
float range_2;
float range_3; 

PVector position_anchor_1;
PVector position_anchor_2;
PVector position_anchor_3;

PVector position_tag;

float board_box[] = {0,0,0,0};
float first_anchor_position_size[] = {.0,.0,10.0,10.0};
float second_anchor_position_size[] = {.0,.0,10.0,10.0};
float third_anchor_position_size[] = {.0,.0,10.0,10.0};



void setup() {

    size(512, 512);
    background(255,255, 255, 255);
    //udp
    message = " ";
    
    

//     myClient = new Client(this, "0.0.0.0", 52520); 
    //s = new Server(this,52520);
    //define the box
    board_box[0] = width/20;
    board_box[1] = height/20;
    board_box[2] = width- width/20;
    board_box[3] = width -height/20;
    //
    first_anchor_position_size[0] = board_box[2]/2;
    first_anchor_position_size[1] = board_box[1];
    //
    second_anchor_position_size[0] = board_box[0];
    second_anchor_position_size[1] = board_box[3];
    //
    third_anchor_position_size[0] = board_box[2];
    third_anchor_position_size[1] = board_box[3];
    //
     position_anchor_1 = new PVector(first_anchor_position_size[0],first_anchor_position_size[1]);
     position_anchor_2 = new PVector(second_anchor_position_size[0],second_anchor_position_size[1]);
     position_anchor_3 = new PVector(third_anchor_position_size[0],third_anchor_position_size[1]);
     position_tag = new PVector(0,0);

      udp = new UDP( this, 52520);
      udp.listen( true );

}

void draw() {

     background(255);
     position_tag.set(mouseX,mouseY);

     json = parseJSONObject(message + "}");
     if (json == null) {
     println("JSONObject could not be parsed");
     }
    
    
    else{
     JSONArray values = json.getJSONArray("links");

     for (int i = 0; i < values.size(); i++) {
    
      JSONObject links_ = values.getJSONObject(i); 
      int id = links_.getInt("a");
      if(id == 771)
      {
          range_2 = links_.getFloat("r");
          print(id);
          print("   ");
          range_2 = (range_2 - 0.3)/1.5;
          println(range_2);
      }
      else if (id == 3 )
      {
          range_1 = links_.getFloat("r");
          print(id);
          print("   ");
          println(range_1);
      }

      
      
      
      }
    }
  
    
//     if (myClient.available() > 0)
//     { 
//      inString = myClient.readString(); 
//      println(inString);
//     }
//     else {
//      fill(255,0,0);
//      text("No UDP",10,10);
//     }
     float range_1_a = range_1 - 0.6;
     float range_2_a = range_2 - 0.6;
     cos_a = (range_1_a * range_1_a + 1 * 1 - range_2_a * range_2_a) / (2 * range_1_a * 1);
     sin_a = sqrt(1 - cos_a * cos_a);
     float p_x = range_1_a * cos_a;
     float p_y = range_1_a * sin_a;

     //println(message);


     float dist_anchor_1 = PVector.dist(position_anchor_1, position_tag);
     float dist_anchor_2 = PVector.dist(position_anchor_2, position_tag);
     float dist_anchor_3 = PVector.dist(position_anchor_3, position_tag);

    rectMode(CORNERS);
    fill(0, 0, 0, 0);
    stroke(0);
     rect(board_box[0],
         board_box[1],
         board_box[2],
         board_box[3]);

     rectMode(CENTER);
     fill(0, 0, 0, 255);
     stroke(0);
      rect(first_anchor_position_size[0],
         first_anchor_position_size[1],
         first_anchor_position_size[2],
         first_anchor_position_size[3]);
      rect(second_anchor_position_size[0],
         second_anchor_position_size[1],
         second_anchor_position_size[2],
         second_anchor_position_size[3]);
      rect(third_anchor_position_size[0],
         third_anchor_position_size[1],
         third_anchor_position_size[2],
         third_anchor_position_size[3]);
     ellipseMode(CENTER);
     fill(255,100,0,100);
     noStroke();
     ellipse(first_anchor_position_size[0],
             first_anchor_position_size[1],
             2*dist_anchor_1,2*dist_anchor_1);
     fill(100,255,0,100);
     noStroke();
     ellipse(second_anchor_position_size[0],
             second_anchor_position_size[1],
             2*((range_1 * 0.28 * board_box[2])/0.68),2*((range_1 * 0.28 * board_box[2])/0.68));
     fill(0,100,255,100);
     noStroke();
     ellipse(third_anchor_position_size[0],
             third_anchor_position_size[1],
             2*((range_2* 0.28 * board_box[2])/0.68),2*((range_2* 0.28 * board_box[2])/0.68));
     fill(255,100,100,255);
     noStroke();
     ellipse(
          board_box[0] + (p_x * 0.28 * board_box[2])/0.68,
          board_box[1] + (p_y * 0.28 * board_box[2])/0.68,
          10,10
     );
    fill(255,255,255);
    textSize(20);
    textAlign(CENTER);
    text(range_2 - 0.1 ,width/2,height/2);
     
}
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  message = new String( data );

  // print the result
}
