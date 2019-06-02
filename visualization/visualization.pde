import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;

Minim minim;
AudioPlayer groove;
AudioMetaData meta;
FFT fft;
ControlP5 btn;
ControlP5 sld;
Button feb,may,oct;
Slider swsize;
Table fp;

Table tcolor;
color c;
int[] h;
float[] s;
float[] v;
float[] times;
float[] tempo;
PImage img;

Table feature;
float[] rms;

int seg_size=0;
int frame=0;
int r_weight_base=100;
float music_sum=1024;
float auto_add=0;
float ang = 0;
String path;
String fname;
String filename;
String title="Music Visualization";

void setup()
{
  size(800, 650, P3D);
  btn = new ControlP5(this);
  sld = new ControlP5(this);
  colorMode(HSB, 360, 1, 1);  //Color mode = HSV
 
  fp = loadTable("title.csv","header");
  for(TableRow row:fp.rows()){
    filename = row.getString("name");
  }
 
  minim = new Minim(this);
  //load the music file
  groove = minim.loadFile(filename+".wav");
  //load the related data
  img = loadImage(filename+"_spec.png");
  tcolor=loadTable(filename+"_inf.csv","header");
  feature=loadTable(filename+"_rms.csv","header");
  seg_size = tcolor.getRowCount();
  
  h=new int[seg_size+1];
  s=new float[seg_size+1];
  v=new float[seg_size+1];
  times=new float[seg_size+1];
  tempo=new float[seg_size+1];
  
  int i=1;
  for(TableRow row:tcolor.rows()){
    times[i] = row.getFloat("end");
    h[i] = row.getInt("h");
    s[i] = row.getFloat("s");
    v[i] = map(row.getFloat("v"),0,1,0.2,0.8);
    tempo[i] = row.getFloat("tempo");
    i++;
  }
  times[0]=0;
  
  rms=new float[groove.length()/1000 + 1];
  int j=0;
  for(TableRow row2:feature.rows()){
    rms[j] = row2.getFloat("rms");
    j++;
  }

  fft=new FFT(groove.bufferSize(), groove.sampleRate());

  fill(0);
  //'size' controller
  swsize=sld.addSlider("Sound Weight")
  .setColorCaptionLabel(color(0))
  .setPosition(720, 460)
  .setSize(15,100)
  .setRange(0,8)
  .setValue(3);

}

void draw()
{
  background(0,0,0.85);
  
  float position = map( groove.position(), 0, groove.length(), 0, 500 ); // 500: end of X-axis
  fill(0);
  text(filename+" / "+title, 10, 20);
  text(groove.position()/1000+" / "+groove.length()/1000 + "s", width-100, 20);
  text("Space: To play or pause the music.\nS: To save the current frame. ",530, height-50);
  
  //Background color
  for(int ii=1;ii<=seg_size;ii++){
    if(groove.position()/1000>=times[ii-1] && groove.position()/1000<times[ii]){
      fill(h[ii],s[ii],v[ii],50);
      noStroke();
      rect(0,0,width,height-70);
      
    }
  }
  //FFT Spectrum
  stroke(0,0,1);
  fft.forward(groove.right);
  for(int i = 0; i < fft.specSize(); i++)
  {
    line(i + width/2, (height-70)/2 + fft.getBand(i)*8, i + width/2, (height-70)/2 - fft.getBand(i)*8);
  }
  fft.forward(groove.left);
  for(int i = 0; i < fft.specSize(); i++)
  {
    line(-i + width/2, (height-70)/2 + fft.getBand(i)*8, -i + width/2, (height-70)/2 - fft.getBand(i)*8);
  }
  
  //Sound Flower
  strokeWeight(1);
  float a =0;
  float angle = (2*PI)/200;
  int step = groove.bufferSize()/200;
  for(int i = 0;i < groove.bufferSize() - step ; i += step) {
    float x = 400 + cos(a) * (1000 * groove.mix.get(i) + 125);
    float y = (height-70)/2 + sin(a) * (1000 * groove.mix.get(i) + 125);
    float x2 = 400 + cos(a + angle) * (1000 * groove.mix.get(i+step) + 125);
    float y2 = (height-70)/2 + sin(a + angle) * (1000 * groove.mix.get(i+step) + 125);
    line(x,y,x2,y2); 
    a += angle;
 }
  //Progress Controller
  stroke(0,1,1);
  strokeWeight(1);
  line( position, height - 70, position, height ); 
  
  //Arc diagram
  pushMatrix();
  translate(width/2,(height-70)/2);
  rotate(auto_add);
  for(int ii=1;ii<=seg_size;ii++){
    if(groove.position()/1000>=times[ii-1] && groove.position()/1000<times[ii]){
      c=color(h[ii],s[ii],v[ii]);          //color of the segment
     ang = map(tempo[ii],40,200,0,0.075);  //Angular velocity of the diagram
    }
  for(int i=0;i<music_sum;i++){
    int sound_weight=int(groove.left.get(i)*50);
    float sw_size=swsize.getValue();
    float alpha=map(i,0,int(music_sum),0,150);
    
    r_weight_base = int(rms[groove.position()/1000]*1000);  //radius R of the diagram
    noStroke();
    noFill();
    
    rotate(TWO_PI/3);
      pushMatrix();
      rotate(TWO_PI*0.00020*i);
       
      stroke(c,alpha);
      strokeWeight(1);
      ellipse(r_weight_base * 2,0,sound_weight * sw_size,sound_weight * sw_size);  //sound_weight * sw_size: radius r of the circles
    
  popMatrix();
  }  
  auto_add += ang;
  }
  popMatrix();
  fill(0);
  text("Ang: "+(float)(Math.round(ang*60*100))/100 +"rad/s", width-100, 40);
  image(img, 0, height-70,500,70);
}

void mousePressed()
{
  // choose a position to cue to based on where the user clicked.
  // the length() method returns the length of recording in milliseconds.
  if(mouseY>=height-70 && mouseX <=500){
  int position = int( map( mouseX, 0, 500, 0, groove.length() ) );
  groove.cue( position );
  }
}

void keyPressed()
{
  if(key==32){
  if(groove.isPlaying())
  groove.pause();
  else if ( groove.position() == groove.length() )
  {
    groove.rewind();  //return to the start
    groove.play();
  }
  else
  groove.play();  
  }

  if(key == 's')
    saveFrame("snap/"+filename+"-####.png");  //save the present frame of visualization
}