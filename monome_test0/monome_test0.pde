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

// monome emulator size
static final int W = 32;
static final int H = 16;

// open sound control (OSC) communication
OscP5 oscP5;
String host = "127.0.0.1";
int sendPort = 9091;
int receivePort = 9090;

int x, y;
int lastX, lastY;

void setup()
{
  frameRate(24);
  oscP5 = new OscP5(this, host, sendPort, receivePort, "oscEvent");
  oscP5.plug(this, "press", "/40h/press");
  clear();
}

void draw()
{
  ledOn(x, y);
  ledOff(lastX, lastY);
  lastX = x;
  lastY = y;

  x++;
  if (x >= W)
  {
    x = 0;
    y++;
  }
  if (y >= H)
  {
    x = 0;
    y = 0;
  }
}

void clear()
{
  OscMessage message = new OscMessage("/40h/clear");
  message.add(0);
  oscP5.send(message);
}

void ledOn(final int x, final int y)
{
  OscMessage message = new OscMessage("/40h/led");
  message.add(x);
  message.add(y);
  message.add(1);
  oscP5.send(message);
}

void ledOff(final int x, final int y)
{
  OscMessage message = new OscMessage("/40h/led");
  message.add(x);
  message.add(y);
  message.add(0);
  oscP5.send(message);
}

void press(final int x, final int y, final int state)
{
  // empty
}

void oscEvent(final OscMessage message)
{
  // empty
}

