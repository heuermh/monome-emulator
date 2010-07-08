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

void setup()
{
  frameRate(1);
  oscP5 = new OscP5(this, host, sendPort, receivePort, "oscEvent");
  oscP5.plug(this, "press", "/40h/press");
  clear();
}

int i;

void draw()
{
  if ((i % 2) == 0)
  {
    frameOn();
  }
  else
  {
    frameOff();
  }
  i++;
}

void clear()
{
  OscMessage message = new OscMessage("/40h/clear");
  message.add(0);
  oscP5.send(message);
}

void frameOn()
{
  OscMessage message = new OscMessage("/40h/frame");
  message.add((byte) 255);
  message.add((byte) 255);
  message.add((byte) 255);
  message.add((byte) 255);
  message.add((byte) 255);
  message.add((byte) 255);
  message.add((byte) 255);
  message.add((byte) 255);
  oscP5.send(message);
}

void frameOff()
{
  OscMessage message = new OscMessage("/40h/frame");
  message.add((byte) 0);
  message.add((byte) 0);
  message.add((byte) 0);
  message.add((byte) 0);
  message.add((byte) 0);
  message.add((byte) 0);
  message.add((byte) 0);
  message.add((byte) 0);
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

