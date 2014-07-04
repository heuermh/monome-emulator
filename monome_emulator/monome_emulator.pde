/*

    Monome emulator written in Processing.
    Copyright (c) 2010 held jointly by the individual authors.

    monome-emulator is free software: you can redistribute it and/or
    modify it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    monome-emulator is distributed in the hope that it will be
    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

*/
import oscP5.*;
import netP5.*;

import java.awt.event.KeyEvent;

// monome emulator size
static final int W = 32;
static final int H = 16;

// button size
static final int S = 28;

// led color
static final int LED[][] = new int[W][H];

// default colors, greyscale 128 style
final int frame = color(24, 27, 30);
final int steel = color(185, 193, 196);
final int ledOff = color(129, 137, 137);
final int ledOn = color(253, 252, 252);
final int highlight = color(0, 0, 80);

// alternate colors, 512 style
//final int frame = color(56, 36, 29);
//final int steel = color(126, 122, 121);
//final int ledOff = color(100, 94, 98);
//final int ledOn = color(245, 124, 77);
//final int highlight = color(80, 0, 80);

// cursor
int cursorX = 0;
int cursorY = 0;

// open sound control (OSC) communication
OscP5 oscP5;
String host = "127.0.0.1";
int sendPort = 9090;
int receivePort = 9091;

void setup()
{
  size(W * S + 5*S + 2*W, H * S + 5*S + 2*H);
  smooth();
  background(0);
  clear(0);

  oscP5 = new OscP5(this, host, sendPort, receivePort, "oscEvent");
  oscP5.plug(this, "clear", "/40h/clear");
  oscP5.plug(this, "led", "/40h/led");
  oscP5.plug(this, "led_col", "/40h/led_col");
  oscP5.plug(this, "led_row", "/40h/led_row");
  oscP5.plug(this, "frame", "/40h/frame");
}

void draw()
{
  fill(0);
  noStroke();
  rect(0, 0, width, height);

  fill(steel);
  stroke(frame);
  strokeWeight(S);
  roundRect(S, S, width - 2*S, height - 2*S, S*2);

  noStroke();
  for (int x = 0; x < W; x++)
  {
    for (int y = 0; y < H; y++)
    {
      fill(LED[x][y]);
      roundRect(2.5*S + x * (S + 2), 2.5*S + y * (S + 2), S, S, 2);
    }
  }

  noFill();
  stroke(highlight);
  strokeWeight(1);
  roundRect(2.5*S + cursorX * (S + 2), 2.5*S + cursorY * (S + 2), S, S, 2);
}

void clear(final int state)
{
  for (int x = 0; x < W; x++)
  {
    for (int y = 0; y < H; y++)
    {
      led(x, y, state);
    }
  }  
}

void led(final int x, final int y, final int state)
{
  if (x > -1 && x < W && y > -1 && y < H)
  {
    if (state == 0)
    {
      LED[x][y] = ledOff;
    }
    else
    {
      LED[x][y] = ledOn;
    }
  }
}

void led_col(final int col, final int data)
{
  led_col(col, (byte) data);
}
// oscP5 isn't able to plug this method
void led_col(final int col, final byte data)
{
  led(col, 0, data & 1);
  led(col, 1, data & 2);
  led(col, 2, data & 4);
  led(col, 3, data & 8);
  led(col, 4, data & 16);
  led(col, 5, data & 32);
  led(col, 6, data & 64);
  led(col, 7, data & 128);
}

void led_row(final int row, final int data)
{
  led_row(row, (byte) data);
}
// oscP5 isn't able to plug this method
void led_row(final int row, final byte data)
{
  led(0, row, data & 1);
  led(1, row, data & 2);
  led(2, row, data & 4);
  led(3, row, data & 8);
  led(4, row, data & 16);
  led(5, row, data & 32);
  led(6, row, data & 64);
  led(7, row, data & 128);
}

void frame(final int a, final int b, final int c, final int d,
  final int e, final int f, final int g, final int h)
{
  frame((byte) a, (byte) b, (byte) c, (byte) d,
    (byte) e, (byte) f, (byte) g, (byte) h);
}
// oscP5 isn't able to plug this method
void frame(final byte a, final byte b, final byte c, final byte d,
  final byte e, final byte f, final byte g, final byte h)
{
  led_col(0, a);
  led_col(1, b);
  led_col(2, c);
  led_col(3, d);
  led_col(4, e);
  led_col(5, f);
  led_col(6, g);
  led_col(7, h);
}

void buttonPressed(final int x, final int y)
{
  OscMessage message = new OscMessage("/40h/press");
  message.add(x);
  message.add(y);
  message.add(1);
  oscP5.send(message);
}

void buttonReleased(final int x, final int y)
{
  OscMessage message = new OscMessage("/40h/press");
  message.add(x);
  message.add(y);
  message.add(0);
  oscP5.send(message);
}

void keyPressed()
{
  switch (keyCode)
  {
    case UP:
      cursorY--;
      break;
    case DOWN:
      cursorY++;
      break;
    case LEFT:
      cursorX--;
      break;
    case RIGHT:
      cursorX++;
      break;
    case CONTROL:
    case KeyEvent.VK_SPACE:
      buttonPressed(cursorX, cursorY);
      buttonReleased(cursorX, cursorY);
      break;
    default:
      break;
  }
  cursorX = constrain(cursorX, 0, W - 1);
  cursorY = constrain(cursorY, 0, H - 1);
}

void mouseMoved()
{
  int i = 0;
  float x = 2.5*S;
  while (x < mouseX)
  {
    x += S + 2; 
    i++;
  }
  int j = 0;
  float y = 2.5*S;
  while (y < mouseY)
  {
    y += S + 2;
    j++;
  }
  cursorX = constrain(i - 1, 0, W - 1);
  cursorY = constrain(j - 1, 0, H - 1);
}

void mousePressed()
{
  buttonPressed(cursorX, cursorY);
}

void mouseReleased()
{
  buttonReleased(cursorX, cursorY);
}

void oscEvent(final OscMessage message)
{
  // empty
}


// see http://code.google.com/p/processing/issues/detail?id=265

private float prevX;
private float prevY;

private void roundRect(final int x, final int y, final int w, final int h, final int r)
{
  beginShape();
  vertex(x+r, y);

  vertex(x+w-r, y);
  prevX = x+w-r;
  prevY = y;
  quadraticBezierVertex(x+w, y, x+w, y+r);

  vertex(x+w, y+h-r);
  prevX = x+w;
  prevY = y+h-r;
  quadraticBezierVertex(x+w, y+h, x+w-r, y+h);

  vertex(x+r, y+h);
  prevX = x+r;
  prevY = y+h;
  quadraticBezierVertex(x, y+h, x, y+h-r);

  vertex(x, y+r);
  prevX = x;
  prevY = y+r;
  quadraticBezierVertex(x, y, x+r, y);

  endShape();
}

private void quadraticBezierVertex(final int cpx, final int cpy, final int x, final int y)
{
  float cp1x = prevX + 2.0/3.0*(cpx - prevX);
  float cp1y = prevY + 2.0/3.0*(cpy - prevY);
  float cp2x = cp1x + (x - prevX)/3.0;
  float cp2y = cp1y + (y - prevY)/3.0;
  bezierVertex(cp1x, cp1y, cp2x, cp2y, x, y);
}

private void roundRect(final float x, final float y, final float w, final float h, final float r)
{
  beginShape();
  vertex(x+r, y);

  vertex(x+w-r, y);
  prevX = x+w-r;
  prevY = y;
  quadraticBezierVertex(x+w, y, x+w, y+r);

  vertex(x+w, y+h-r);
  prevX = x+w;
  prevY = y+h-r;
  quadraticBezierVertex(x+w, y+h, x+w-r, y+h);

  vertex(x+r, y+h);
  prevX = x+r;
  prevY = y+h;
  quadraticBezierVertex(x, y+h, x, y+h-r);

  vertex(x, y+r);
  prevX = x;
  prevY = y+r;
  quadraticBezierVertex(x, y, x+r, y);

  endShape();
}

private void quadraticBezierVertex(final float cpx, final float cpy, final float x, final float y)
{
  float cp1x = prevX + 2.0/3.0*(cpx - prevX);
  float cp1y = prevY + 2.0/3.0*(cpy - prevY);
  float cp2x = cp1x + (x - prevX)/3.0;
  float cp2y = cp1y + (y - prevY)/3.0;
  bezierVertex(cp1x, cp1y, cp2x, cp2y, x, y);
}

